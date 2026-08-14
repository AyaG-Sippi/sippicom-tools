param()

$BASE_URL = "https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main"
$exeUrl = "$BASE_URL/bin/SippicomCtrlAltPass.exe"
$localExe = [System.IO.Path]::Combine($env:TEMP, "SippicomCtrlAltPass.exe")

Write-Host "--> Launching SIPPICOM CtrlAltPass from Cloud..." -ForegroundColor Cyan

try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($exeUrl, $localExe)
    Start-Process -FilePath $localExe
    Write-Host "✓ CtrlAltPass GUI launched successfully!" -ForegroundColor Green
} catch {
    Write-Host "Notice: $($_.Exception.Message)" -ForegroundColor Yellow
}
