<#
.SYNOPSIS
    SIPPICOM Workstation AutoDeploy Fast (Instant Unattended Edition)
.DESCRIPTION
    irm https://raw.githubusercontent.com/sippicom/tools/main/tools/autodeploy/AutoDeployFast.ps1 | iex
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(544)
if (!$isAdmin) {
    try {
        $url = "https://raw.githubusercontent.com/sippicom/tools/main/tools/autodeploy/AutoDeployFast.ps1"
        $cmd = "& { irm '$url' | iex }"
        Start-Process powershell.exe -ArgumentList "-sta -NoProfile -ExecutionPolicy Bypass -Command `"$cmd`"" -Verb RunAs -ErrorAction Stop
        exit
    } catch {}
}

# 1. Parallel Multi-Threaded Winget Installs
$packages = @(
    @{ Id = "Microsoft.Office"; Args = "--locale de-DE" },
    @{ Id = "Adobe.Acrobat.Reader.64-bit"; Args = "" },
    @{ Id = "VideoLAN.VLC"; Args = "" },
    @{ Id = "7zip.7zip"; Args = "" }
)

$jobs = @()
foreach ($pkg in $packages) {
    $script = {
        param($pId, $pArgs)
        winget install --id $pId --exact --silent --accept-package-agreements --accept-source-agreements $pArgs
    }
    $jobs += Start-Job -ScriptBlock $script -ArgumentList $pkg.Id, $pkg.Args
}

while (($jobs | Where-Object { $_.State -eq 'Running' }).Count -gt 0) {
    Start-Sleep -Seconds 1
}
$jobs | Remove-Job -Force

# 2. Adobe Acrobat Reader Auto-Update Task
try {
    $armExe = "C:\Program Files (x86)\Common Files\Adobe\ARM\1.0\AdobeARM.exe"
    if (Test-Path $armExe) {
        schtasks /Create /TN "Adobe Acrobat Update Task" /TR "`"$armExe`"" /SC DAILY /ST 10:00 /RU "SYSTEM" /RL HIGHEST /F | Out-Null
        Set-Service -Name "AdobeARMservice" -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name "AdobeARMservice" -ErrorAction SilentlyContinue
    }
} catch {}

# 3. Power Optimization
powercfg /change monitor-timeout-ac 0
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /h off
