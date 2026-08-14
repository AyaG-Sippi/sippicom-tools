<#
.SYNOPSIS
    SIPPICOM CtrlAltPass Cloud Launcher
.DESCRIPTION
    irm https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main/tools/ctrlaltpass/CtrlAltPass.ps1 | iex
#>

$BASE_URL = "https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main"
$exeUrl = "$BASE_URL/bin/SippicomCtrlAltPass.exe"
$localExe = [System.IO.Path]::Combine($env:TEMP, "SippicomCtrlAltPass.exe")

Write-Host "--> Launching SIPPICOM CtrlAltPass from Cloud..." -ForegroundColor Cyan

try {
    (New-Object System.Net.WebClient).DownloadFile($exeUrl, $localExe)
    Start-Process -FilePath $localExe
    Write-Host "✓ CtrlAltPass GUI launched successfully!" -ForegroundColor Green
} catch {
    Write-Host "Generating fallback password in console..." -ForegroundColor Yellow
    $chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%^&*()-_=+"
    $bytes = New-Object byte[] 18
    (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes)
    $pass = ""
    foreach ($b in $bytes) { $pass += $chars[$b % $chars.Length] }
    Write-Host "Generated Password: $pass" -ForegroundColor Green
    Set-Clipboard -Value $pass
    Write-Host "✓ Copied to clipboard!" -ForegroundColor Cyan
}
