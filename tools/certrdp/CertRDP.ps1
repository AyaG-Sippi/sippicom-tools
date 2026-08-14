param([string]$FilePath)

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(544)
if (!$isAdmin) {
    try {
        $url = "https://raw.githubusercontent.com/sippicom/tools/main/tools/certrdp/CertRDP.ps1"
        $cmd = "& { irm '$url' | iex }"
        Start-Process powershell.exe -ArgumentList "-sta -NoProfile -ExecutionPolicy Bypass -Command `"$cmd`"" -Verb RunAs -ErrorAction Stop
        exit
    } catch {}
}

if (!$FilePath -or !(Test-Path $FilePath)) {
    Add-Type -AssemblyName System.Windows.Forms
    $d = New-Object System.Windows.Forms.OpenFileDialog
    $d.Filter = "RDP Files (*.rdp)|*.rdp|All Files (*.*)|*.*"
    $d.Title = "SIPPICOM CertRDP — Select RDP File to Sign"
    if ($d.ShowDialog() -ne "OK") { exit }
    $FilePath = $d.FileName
}

Write-Host "`n=== SIPPICOM CERTRDP CLOUD SIGNER ===" -ForegroundColor Yellow
Write-Host "Target RDP: $FilePath" -ForegroundColor Cyan

$c = Get-Content -Path $FilePath
$line = ($c -match '^full address:s:')[0]
$srv = if ($line) { ($line -replace '^full address:s:','' -split ':')[0].Trim() } else { "SippicomHost" }
$sub = "CN=$srv, O=SIPPICOM, C=DE"

Write-Host "Extracted Host: $srv" -ForegroundColor Gray

$cert = (Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert -ErrorAction SilentlyContinue | Where-Object { $_.Subject -like "*$srv*" } | Select-Object -First 1)
if (!$cert) {
    Write-Host "Generating new SHA-256 Code Signing Certificate..." -ForegroundColor Gray
    $cert = New-SelfSignedCertificate -Subject $sub -DnsName $srv -CertStoreLocation Cert:\CurrentUser\My -Type CodeSigningCert -NotAfter (Get-Date).AddYears(5)
}

$tmp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "$srv.cer")
Export-Certificate -Cert $cert -FilePath $tmp -Type CERT | Out-Null
certutil.exe -f -addstore Root "$tmp" | Out-Null
certutil.exe -f -addstore TrustedPublisher "$tmp" | Out-Null
Remove-Item -Path $tmp -Force -ErrorAction SilentlyContinue

$tp = $cert.Thumbprint.ToUpper()
$k = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
if (!(Test-Path $k)) { try { New-Item $k -Force | Out-Null } catch {} }
Set-ItemProperty -Path $k -Name "AllowSignedFiles" -Value 1 -Type DWord -ErrorAction SilentlyContinue
$cur = (Get-ItemProperty -Path $k -Name "TrustedCertThumbprints" -ErrorAction SilentlyContinue).TrustedCertThumbprints
Set-ItemProperty -Path $k -Name "TrustedCertThumbprints" -Value ($cur + ";" + $tp) -Type String -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Terminal Server Client" -Name "RdpLaunchConsentAccepted" -Value 1 -Type DWord -ErrorAction SilentlyContinue

Write-Host "Signing RDP file with rdpsign.exe..." -ForegroundColor Gray
& rdpsign.exe /sha256 $tp "$FilePath"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ RDP File Signed Successfully! Thumbprint: $tp" -ForegroundColor Green
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show("SIPPICOM CertRDP: RDP file signed successfully!`n`nTarget: $FilePath`nThumbprint: $tp`n`nAll certificates trusted & policies configured.", "SIPPICOM CertRDP", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
} else {
    Write-Host "! Error signing RDP file. Exit code: $LASTEXITCODE" -ForegroundColor Red
}
