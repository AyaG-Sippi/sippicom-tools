<#
.SYNOPSIS
    SIPPICOM Workstation AutoDeploy (Interactive Multi-Threaded Edition)
.DESCRIPTION
    irm https://raw.githubusercontent.com/sippicom/tools/main/tools/autodeploy/AutoDeploy.ps1 | iex
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(544)
if (!$isAdmin) {
    try {
        $url = "https://raw.githubusercontent.com/sippicom/tools/main/tools/autodeploy/AutoDeploy.ps1"
        $cmd = "& { irm '$url' | iex }"
        Start-Process powershell.exe -ArgumentList "-sta -NoProfile -ExecutionPolicy Bypass -Command `"$cmd`"" -Verb RunAs -ErrorAction Stop
        exit
    } catch {}
}

Clear-Host
Write-Host "==================================================================" -ForegroundColor DarkYellow
Write-Host "   SIPPICOM WORKSTATION AUTODEPLOY — MULTI-THREADED CLOUD ENGINE" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor DarkYellow
Write-Host ""

$winget = if (Get-Command winget -ErrorAction SilentlyContinue) { "winget" } else { "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe" }

$packages = @(
    @{ Name = "Microsoft 365 Office (German)"; Id = "Microsoft.Office"; Args = "--locale de-DE" },
    @{ Name = "Adobe Acrobat Reader DC"; Id = "Adobe.Acrobat.Reader.64-bit"; Args = "" },
    @{ Name = "VLC Media Player"; Id = "VideoLAN.VLC"; Args = "" },
    @{ Name = "7-Zip Utility"; Id = "7zip.7zip"; Args = "" }
)

Write-Host "Installing Core Software Packages concurrently in parallel..." -ForegroundColor Cyan

$jobs = @()
foreach ($pkg in $packages) {
    $script = {
        param($pName, $pId, $pArgs)
        $log = "[$([DateTime]::Now.ToString('HH:mm:ss'))] Starting installation of $pName..."
        $cmd = "winget install --id $pId --exact --silent --accept-package-agreements --accept-source-agreements $pArgs"
        $res = Invoke-Expression $cmd
        return "[$([DateTime]::Now.ToString('HH:mm:ss'))] ✓ Finished $pName"
    }
    $jobs += Start-Job -ScriptBlock $script -ArgumentList $pkg.Name, $pkg.Id, $pkg.Args
}

while (($jobs | Where-Object { $_.State -eq 'Running' }).Count -gt 0) {
    Write-Host "." -NoNewline -ForegroundColor Yellow
    Start-Sleep -Seconds 2
}
Write-Host "`n"

foreach ($j in $jobs) {
    $out = Receive-Job -Job $j
    Write-Host $out -ForegroundColor Green
    Remove-Job -Job $j
}

# Adobe Reader Automatic Update Task Configuration
Write-Host "`n--> Configuring Adobe Acrobat Reader Update Task..." -ForegroundColor Cyan
try {
    $armExe = "C:\Program Files (x86)\Common Files\Adobe\ARM\1.0\AdobeARM.exe"
    if (Test-Path $armExe) {
        $taskCmd = "schtasks /Create /TN `"Adobe Acrobat Update Task`" /TR `"`"$armExe`"`" /SC DAILY /ST 10:00 /RU `"SYSTEM`" /RL HIGHEST /F"
        Invoke-Expression $taskCmd | Out-Null
        Set-Service -Name "AdobeARMservice" -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name "AdobeARMservice" -ErrorAction SilentlyContinue
        Write-Host "✓ Adobe Update Task & Service configured successfully!" -ForegroundColor Green
    }
} catch {
    Write-Host "! Adobe task notice: $_" -ForegroundColor Yellow
}

# Workstation Power & Standby Policy
Write-Host "`n--> Configuring Power Management (Never Sleep on AC)..." -ForegroundColor Cyan
powercfg /change monitor-timeout-ac 0
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /h off
Write-Host "✓ Power management configured!" -ForegroundColor Green

Write-Host "`n==================================================================" -ForegroundColor DarkYellow
Write-Host "   WORKSTATION DEPLOYMENT COMPLETED SUCCESSFULLY ✓" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor DarkYellow
