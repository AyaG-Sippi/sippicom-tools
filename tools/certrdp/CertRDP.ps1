$FilePath = if ($args.Count -gt 0) { $args[0] } else { $null }

$url = 'https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main/bin/CertRDP.exe'
$dest = Join-Path $env:TEMP 'CertRDP.exe'

Write-Host '--> Launching SIPPICOM CertRDP from Cloud...' -ForegroundColor Cyan

try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, $dest)
    if ($FilePath) {
        Start-Process -FilePath $dest -ArgumentList ('"' + $FilePath + '"')
    } else {
        Start-Process -FilePath $dest
    }
    Write-Host '[OK] CertRDP launched successfully!' -ForegroundColor Green
} catch {
    Write-Host '[Error] Could not launch CertRDP binary.' -ForegroundColor Yellow
}
