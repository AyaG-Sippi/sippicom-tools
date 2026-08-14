<#
.SYNOPSIS
    SIPPICOM PrinterFix Cloud Launcher
.DESCRIPTION
    irm https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main/tools/printerfix/PrinterFix.ps1 | iex
#>

$BASE_URL = "https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main"
$exeUrl = "$BASE_URL/bin/SippicomPrinterFix.exe"
$localExe = [System.IO.Path]::Combine($env:TEMP, "SippicomPrinterFix.exe")

Write-Host "--> Launching SIPPICOM PrinterFix from Cloud..." -ForegroundColor Cyan

try {
    (New-Object System.Net.WebClient).DownloadFile($exeUrl, $localExe)
    Start-Process -FilePath $localExe
    Write-Host "✓ PrinterFix Multi-Threaded GUI launched successfully!" -ForegroundColor Green
} catch {
    Write-Host "! Could not launch GUI. Running in-memory Spooler reset..." -ForegroundColor Yellow
    Stop-Service -Name spooler -Force -ErrorAction SilentlyContinue
    $dir = "C:\Windows\System32\spool\PRINTERS"
    if (Test-Path $dir) { Get-ChildItem -Path $dir | Remove-Item -Force -ErrorAction SilentlyContinue }
    Start-Service -Name spooler -ErrorAction SilentlyContinue
    Get-Printer | Set-Printer -WorkOffline $false -Paused $false -ErrorAction SilentlyContinue
    Write-Host "✓ Print spooler reset & queues forced online!" -ForegroundColor Green
}
