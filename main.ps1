<#
.SYNOPSIS
    SIPPICOM Unified Cloud Hub (GitHub irm | iex Engine)
.DESCRIPTION
    Execute live from any PowerShell session:
    irm https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main/main.ps1 | iex
#>

$BASE_URL = "https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main"

function Show-Header {
    Clear-Host
    Write-Host "==================================================================" -ForegroundColor DarkYellow
    Write-Host "   SIPPICOM IT-SOLUTIONS — CLOUD SUITE & DEPLOYMENT HUB" -ForegroundColor Yellow
    Write-Host "   Live GitHub Execution Engine (irm | iex)" -ForegroundColor Gray
    Write-Host "==================================================================" -ForegroundColor DarkYellow
    Write-Host ""
}

function Launch-Tool {
    param(
        [string]$ToolName,
        [string]$Ps1RelPath,
        [string]$ExeName
    )
    Write-Host "`n--> Launching $ToolName via SIPPICOM Cloud Engine..." -ForegroundColor Cyan
    $exeUrl = "$BASE_URL/bin/$ExeName"
    $targetPath = [System.IO.Path]::Combine($env:TEMP, $ExeName)
    
    try {
        Write-Host "    Fetching $ExeName ..." -ForegroundColor Gray
        (New-Object System.Net.WebClient).DownloadFile($exeUrl, $targetPath)
        Start-Process -FilePath $targetPath
        Write-Host "    ✓ $ToolName launched successfully!" -ForegroundColor Green
    } catch {
        Write-Host "    ! Fallback: executing cloud PowerShell script..." -ForegroundColor Yellow
        $scriptUrl = "$BASE_URL/$Ps1RelPath"
        irm $scriptUrl | iex
    }
}

do {
    Show-Header
    Write-Host "Select a SIPPICOM Cloud Tool:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] 🔐 CertRDP          - RDP Code Signing & PKI Trust Suite" -ForegroundColor White
    Write-Host "  [2] 🖨️  PrinterFix       - Multi-Threaded Print Spooler, IP & Migration Hub" -ForegroundColor White
    Write-Host "  [3] 🚀 AutoDeploy       - Workstation Software & Setup Deployer (Interactive)" -ForegroundColor White
    Write-Host "  [4] ⚡ AutoDeploy Fast  - Unattended Silent Workstation Deployer" -ForegroundColor White
    Write-Host "  [5] 🔑 CtrlAltPass      - Enterprise Password & Credential Generator" -ForegroundColor White
    Write-Host "  [6] 📦 Download All EXEs- Save all standalone binaries locally" -ForegroundColor White
    Write-Host "  [Q] ❌ Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host "Enter selection [1-6, Q]: " -NoNewline -ForegroundColor Yellow

    $choice = Read-Host

    switch ($choice) {
        "1" { Launch-Tool "CertRDP" "tools/certrdp/CertRDP.ps1" "CertRDP.exe"; Start-Sleep -Seconds 1 }
        "2" { Launch-Tool "PrinterFix" "tools/printerfix/PrinterFix.ps1" "SippicomPrinterFix.exe"; Start-Sleep -Seconds 1 }
        "3" { Launch-Tool "AutoDeploy" "tools/autodeploy/AutoDeploy.ps1" "SippicomAutoDeploy.exe"; Start-Sleep -Seconds 1 }
        "4" { Launch-Tool "AutoDeploy Fast" "tools/autodeploy/AutoDeployFast.ps1" "SippicomAutoDeployFast.exe"; Start-Sleep -Seconds 1 }
        "5" { Launch-Tool "CtrlAltPass" "tools/ctrlaltpass/CtrlAltPass.ps1" "SippicomCtrlAltPass.exe"; Start-Sleep -Seconds 1 }
        "6" {
            Write-Host "`n--> Downloading standalone binaries to current directory..." -ForegroundColor Cyan
            $bins = @("CertRDP.exe", "SippicomPrinterFix.exe", "SippicomAutoDeploy.exe", "SippicomAutoDeployFast.exe", "SippicomCtrlAltPass.exe")
            foreach ($b in $bins) {
                Write-Host "    Downloading $b ..." -NoNewline
                try {
                    (New-Object System.Net.WebClient).DownloadFile("$BASE_URL/bin/$b", ".\$b")
                    Write-Host " ✓ OK" -ForegroundColor Green
                } catch {
                    Write-Host " ! Failed" -ForegroundColor Red
                }
            }
            Write-Host "`nAll binaries downloaded. Press any key to continue..."; [void][Console]::ReadKey($true)
        }
        "Q" {
            Write-Host "`nExiting SIPPICOM Cloud Hub. Have a great day!" -ForegroundColor Yellow
            break
        }
    }
} while ($choice -ne "Q")
