<#
.SYNOPSIS
    SIPPICOM Unified IT-Solutions Hub (Cloud Bootstrap)
.DESCRIPTION
    One-line executable via:
    irm https://raw.githubusercontent.com/sippicom/tools/main/main.ps1 | iex
#>

$ErrorActionPreference = "Continue"
$BASE_URL = if ($env:SIPPI_REPO_URL) { $env:SIPPI_REPO_URL.TrimEnd('/') } else { "https://raw.githubusercontent.com/sippicom/tools/main" }

function Show-SippicomBanner {
    Clear-Host
    Write-Host "==================================================================" -ForegroundColor DarkYellow
    Write-Host "   SIPPICOM IT-SOLUTIONS — CLOUD SUITE & DEPLOYMENT HUB" -ForegroundColor Yellow
    Write-Host "   We Do IT, We Fix IT, We Deploy IT! (GitHub Powered)" -ForegroundColor Gray
    Write-Host "==================================================================" -ForegroundColor DarkYellow
    Write-Host ""
}

function Show-Menu {
    Show-SippicomBanner
    Write-Host "Available Cloud Tools (Live Memory Execution via irm | iex):" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] 🔐 CertRDP          - RDP Code Signing, PKI Trust & Policy Injector" -ForegroundColor White
    Write-Host "  [2] 🖨️  PrinterFix       - Print Spooler Reset, Force Online, IP & Migration" -ForegroundColor White
    Write-Host "  [3] 🚀 AutoDeploy       - Workstation Software & Setup Deployer (Interactive)" -ForegroundColor White
    Write-Host "  [4] ⚡ AutoDeploy Fast  - Unattended Instant Background Workstation Setup" -ForegroundColor White
    Write-Host "  [5] 🔑 CtrlAltPass      - Password & Credential Generation Suite" -ForegroundColor White
    Write-Host "  [6] 📦 Download All EXEs- Save standalone 64-bit binaries to current folder" -ForegroundColor White
    Write-Host "  [Q] ❌ Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host "Select an option [1-6, Q]: " -NoNewline -ForegroundColor Yellow
}

do {
    Show-Menu
    $choice = Read-Host

    switch ($choice) {
        "1" {
            Write-Host "`n--> Launching CertRDP..." -ForegroundColor Green
            irm "$BASE_URL/tools/certrdp/CertRDP.ps1" | iex
            Write-Host "`nPress any key to return to menu..." -ForegroundColor Gray; [void][Console]::ReadKey($true)
        }
        "2" {
            Write-Host "`n--> Launching PrinterFix..." -ForegroundColor Green
            irm "$BASE_URL/tools/printerfix/PrinterFix.ps1" | iex
            Write-Host "`nPress any key to return to menu..." -ForegroundColor Gray; [void][Console]::ReadKey($true)
        }
        "3" {
            Write-Host "`n--> Launching AutoDeploy (Interactive)..." -ForegroundColor Green
            irm "$BASE_URL/tools/autodeploy/AutoDeploy.ps1" | iex
            Write-Host "`nPress any key to return to menu..." -ForegroundColor Gray; [void][Console]::ReadKey($true)
        }
        "4" {
            Write-Host "`n--> Launching AutoDeploy Fast (Unattended)..." -ForegroundColor Green
            irm "$BASE_URL/tools/autodeploy/AutoDeployFast.ps1" | iex
            Write-Host "`nPress any key to return to menu..." -ForegroundColor Gray; [void][Console]::ReadKey($true)
        }
        "5" {
            Write-Host "`n--> Launching CtrlAltPass..." -ForegroundColor Green
            irm "$BASE_URL/tools/ctrlaltpass/CtrlAltPass.ps1" | iex
            Write-Host "`nPress any key to return to menu..." -ForegroundColor Gray; [void][Console]::ReadKey($true)
        }
        "6" {
            Write-Host "`n--> Downloading Standalone Binaries to current directory..." -ForegroundColor Green
            $binaries = @("CertRDP.exe", "SippicomPrinterFix.exe", "SippicomAutoDeploy.exe", "SippicomAutoDeployFast.exe", "SippicomCtrlAltPass.exe")
            foreach ($bin in $binaries) {
                Write-Host "    Downloading $bin..." -ForegroundColor Cyan
                try {
                    Invoke-WebRequest -Uri "$BASE_URL/bin/$bin" -OutFile ".\$bin"
                    Write-Host "    ✓ Saved $bin" -ForegroundColor Green
                } catch {
                    Write-Host "    ! Could not fetch $bin: $_" -ForegroundColor Yellow
                }
            }
            Write-Host "`nDownload complete. Press any key to return to menu..." -ForegroundColor Gray; [void][Console]::ReadKey($true)
        }
        "Q" {
            Write-Host "`nExiting SIPPICOM Cloud Hub. Have a great day!" -ForegroundColor Yellow
            break
        }
        default {
            Write-Host "`nInvalid selection. Try again." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($choice -ne "Q")
