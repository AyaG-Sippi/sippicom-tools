<#
.SYNOPSIS
    SIPPICOM Workstation AutoDeploy Fast Cloud Launcher
.DESCRIPTION
    irm https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main/tools/autodeploy/AutoDeployFast.ps1 | iex
#>

$BASE_URL = "https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main"
$exeUrl = "$BASE_URL/bin/SippicomAutoDeployFast.exe"
$localExe = [System.IO.Path]::Combine($env:TEMP, "SippicomAutoDeployFast.exe")

Write-Host "--> Launching SIPPICOM AutoDeploy Fast from Cloud..." -ForegroundColor Cyan

try {
    (New-Object System.Net.WebClient).DownloadFile($exeUrl, $localExe)
    Start-Process -FilePath $localExe
    Write-Host "✓ AutoDeploy Fast initiated in background!" -ForegroundColor Green
} catch {
    Write-Host "! Running in-memory silent Winget installer..." -ForegroundColor Yellow
    winget install --id Microsoft.Office --exact --silent --accept-package-agreements --accept-source-agreements --locale de-DE
    winget install --id Adobe.Acrobat.Reader.64-bit --exact --silent --accept-package-agreements --accept-source-agreements
    winget install --id VideoLAN.VLC --exact --silent --accept-package-agreements --accept-source-agreements
    winget install --id 7zip.7zip --exact --silent --accept-package-agreements --accept-source-agreements
}
