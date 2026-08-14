<#
.SYNOPSIS
    SIPPICOM CertRDP Cloud Launcher
.DESCRIPTION
    irm https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main/tools/certrdp/CertRDP.ps1 | iex
#>

$BASE_URL = "https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main"
$exeUrl = "$BASE_URL/bin/CertRDP.exe"
$localExe = [System.IO.Path]::Combine($env:TEMP, "CertRDP.exe")

Write-Host "--> Launching SIPPICOM CertRDP from Cloud..." -ForegroundColor Cyan

try {
    (New-Object System.Net.WebClient).DownloadFile($exeUrl, $localExe)
    Start-Process -FilePath $localExe
    Write-Host "✓ CertRDP GUI launched successfully!" -ForegroundColor Green
} catch {
    Write-Host "Running in-memory PowerShell signer fallback..." -ForegroundColor Yellow
    
    Add-Type -AssemblyName System.Windows.Forms
    $d = New-Object System.Windows.Forms.OpenFileDialog
    $d.Filter = "RDP Files (*.rdp)|*.rdp|All Files (*.*)|*.*"
    $d.Title = "SIPPICOM CertRDP — Select RDP File"
    if ($d.ShowDialog() -eq "OK") {
        $f = $d.FileName
        $c = Get-Content -Path $f
        $line = ($c -match '^full address:s:')[0]
        $srv = if ($line) { ($line -replace '^full address:s:','' -split ':')[0].Trim() } else { "SippicomHost" }
        $sub = "CN=$srv, O=SIPPICOM, C=DE"

        $cert = (Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert -ErrorAction SilentlyContinue | Where-Object { $_.Subject -like "*$srv*" } | Select-Object -First 1)
        if (!$cert) {
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

        & rdpsign.exe /sha256 $tp "$f"
        [System.Windows.Forms.MessageBox]::Show("SIPPICOM CertRDP: RDP file signed successfully!`n`nTarget: $f`nThumbprint: $tp", "SIPPICOM CertRDP")
    }
}
