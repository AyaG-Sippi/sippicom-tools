<#
.SYNOPSIS
    SIPPICOM CtrlAltPass (Password & Credential Generator)
.DESCRIPTION
    irm https://raw.githubusercontent.com/sippicom/tools/main/tools/ctrlaltpass/CtrlAltPass.ps1 | iex
#>

function Generate-SippicomPassword {
    param([int]$length = 16)
    $chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%^&*()-_=+"
    $bytes = New-Object byte[] $length
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($bytes)
    $res = ""
    for ($i = 0; $i -lt $length; $i++) {
        $res += $chars[$bytes[$i] % $chars.Length]
    }
    return $res
}

Clear-Host
Write-Host "==================================================================" -ForegroundColor DarkYellow
Write-Host "   SIPPICOM CTRLALTPASS — SECURE CREDENTIAL & PASSWORD SUITE" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor DarkYellow
Write-Host ""

$p1 = Generate-SippicomPassword -length 16
$p2 = Generate-SippicomPassword -length 20
$p3 = Generate-SippicomPassword -length 24
$pin = (Get-Random -Minimum 100000 -Maximum 999999).ToString()

Write-Host "Generated Enterprise Passwords:" -ForegroundColor Cyan
Write-Host "  • Standard (16 chars):  $p1" -ForegroundColor Green
Write-Host "  • High-Sec  (20 chars):  $p2" -ForegroundColor Green
Write-Host "  • Ultra-Sec (24 chars):  $p3" -ForegroundColor Green
Write-Host "  • Secure PIN (6 digits): $pin" -ForegroundColor Yellow
Write-Host ""
Set-Clipboard -Value $p1
Write-Host "✓ Standard password ($p1) has been copied to your clipboard!" -ForegroundColor Cyan
Write-Host ""
