$url = 'https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main/bin/SippicomCtrlAltPass.exe'
$dest = Join-Path $env:TEMP 'SippicomCtrlAltPass.exe'

Write-Host '--> Launching SIPPICOM CtrlAltPass from Cloud...' -ForegroundColor Cyan

try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, $dest)
    Start-Process -FilePath $dest
    Write-Host '[OK] CtrlAltPass launched successfully!' -ForegroundColor Green
} catch {
    Write-Host '[Error] Could not launch CtrlAltPass binary.' -ForegroundColor Yellow
}
