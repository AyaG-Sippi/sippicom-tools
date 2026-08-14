param()

$url = 'https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main/bin/SippicomPrinterFix.exe'
$dest = Join-Path $env:TEMP 'SippicomPrinterFix.exe'

Write-Host '--> Launching SIPPICOM PrinterFix from Cloud...' -ForegroundColor Cyan

try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, $dest)
    Start-Process -FilePath $dest
    Write-Host '[OK] PrinterFix Multi-Threaded GUI launched successfully!' -ForegroundColor Green
} catch {
    Write-Host '[Error] Could not launch PrinterFix binary.' -ForegroundColor Yellow
}
