param()

$url = "https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main/bin/SippicomAutoDeployFast.exe"
$dest = Join-Path $env:TEMP "SippicomAutoDeployFast.exe"

Write-Host "--> Launching SIPPICOM AutoDeploy Fast from Cloud..." -ForegroundColor Cyan

try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, $dest)
    Start-Process -FilePath $dest
    Write-Host "✓ AutoDeploy Fast initiated in background!" -ForegroundColor Green
} catch {
    Write-Host "! Could not launch AutoDeployFast binary." -ForegroundColor Yellow
}
