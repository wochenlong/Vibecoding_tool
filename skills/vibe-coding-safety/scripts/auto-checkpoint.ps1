# auto-checkpoint.ps1
# Hook script: auto-commit all working directory changes after each AI response.
# Works with Cursor (stop hook), Claude Code (PostToolUse), and Codex (Stop).

# ── 1. Consume stdin (hook runners send JSON; must drain or pipe hangs) ──
try { while ($null -ne ($line = [Console]::In.ReadLine())) {} } catch {}

# ── 2. Locate the git repo root ──
try {
    $repoRoot = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $repoRoot) {
        Write-Output '{}'
        exit 0
    }
} catch {
    Write-Output '{}'
    exit 0
}

Set-Location $repoRoot

# ── 3. Skip if no uncommitted changes ──
$status = git status --porcelain 2>$null
if (-not $status) {
    Write-Output '{}'
    exit 0
}

# ── 4. Build a timestamped commit message ──
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$changedCount = ($status | Measure-Object).Count
$message = "[checkpoint] auto-save $timestamp ($changedCount files)"

# ── 5. Stage and commit ──
git add -A 2>$null
git commit -m $message --no-verify 2>$null

# ── 6. Return success to the hook runner ──
Write-Output '{}'
exit 0
