param([string]$Branch = "main")

$fsw = New-Object IO.FileSystemWatcher (Get-Location), "*"
$fsw.IncludeSubdirectories = $true
$fsw.EnableRaisingEvents = $true

$action = {
  git add -A | Out-Null
  git diff --cached --quiet
  if ($LASTEXITCODE -ne 0) {
    git commit -m "auto: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-Null
    git pull --rebase origin $using:Branch 2>$null | Out-Null
    git push origin $using:Branch
    Write-Host "Pushed at $(Get-Date)"
  }
}

Register-ObjectEvent $fsw Changed -Action $action | Out-Null
Register-ObjectEvent $fsw Created -Action $action | Out-Null
Register-ObjectEvent $fsw Deleted -Action $action | Out-Null
Register-ObjectEvent $fsw Renamed -Action $action | Out-Null

Write-Host "Watching for changes… Ctrl+C to stop."
while ($true) { Start-Sleep 1 }
