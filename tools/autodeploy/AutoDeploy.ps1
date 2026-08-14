param()

$url = "https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main/bin/SippicomAutoDeploy.exe"
$dest = Join-Path $env:TEMP "SippicomAutoDeploy.exe"

Write-Host "--> Launching SIPPICOM AutoDeploy from Cloud..." -ForegroundColor Cyan

try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, $dest)
    Start-Process -FilePath $dest
    Write-Host "✓ AutoDeploy Multi-Threaded GUI launched successfully!" -ForegroundColor Green
} catch {
    Write-Host "! Could not launch AutoDeploy binary." -ForegroundColor Yellow
}
