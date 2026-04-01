# AI 回复结束后自动 git commit，防止丢失未提交的修改
try { while ($null -ne ($line = [Console]::In.ReadLine())) {} } catch {}
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Output '{}'; exit 0 }
Set-Location $root
$s = git status --porcelain 2>$null
if (-not $s) { Write-Output '{}'; exit 0 }
$n = ($s | Measure-Object).Count
$t = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git add -A 2>$null
git commit -m "[checkpoint] $t ($n files)" --no-verify 2>$null
Write-Output '{}'
