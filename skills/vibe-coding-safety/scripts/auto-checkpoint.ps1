# AI 回复结束后自动 git commit，防止丢失未提交的修改
try { while ($null -ne ($line = [Console]::In.ReadLine())) {} } catch {}
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Output '{}'; exit 0 }
Set-Location $root
$s = git status --porcelain 2>$null
if (-not $s) { Write-Output '{}'; exit 0 }

# 没有 .gitignore 时警告
$log = Join-Path $root ".git/checkpoint.log"
if (-not (Test-Path .gitignore)) { Add-Content $log "[checkpoint] 警告: 没有 .gitignore，敏感文件可能被提交" }

$n = ($s | Measure-Object).Count
$t = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$msg = "[checkpoint] $t ($n files)"
git add -A 2>$null
$result = git commit -m $msg --no-verify 2>&1
if ($LASTEXITCODE -eq 0) { Add-Content $log $msg }
else { Add-Content $log "[checkpoint] 提交失败: $t - $result" }
Write-Output '{}'
