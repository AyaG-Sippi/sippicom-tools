$gh = "C:\Program Files\GitHub CLI\gh.exe"
$token = (& $gh auth token).Trim()
$user = (& $gh api user --jq .login).Trim()
$repo = "sippicom-tools"
$targetUrl = "https://raw.githubusercontent.com/$user/$repo/main"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$headers = @{
    'Authorization' = "Bearer $token"
    'User-Agent'    = 'Sippicom-Tools-Uploader'
    'Accept'        = 'application/vnd.github.v3+json'
}

# 1. Create or Verify Repository
Write-Host "Verifying repository https://github.com/$user/$repo ..." -ForegroundColor Cyan
try {
    $rCheck = Invoke-RestMethod -Uri "https://api.github.com/repos/$user/$repo" -Headers $headers -Method Get -ErrorAction Stop
    Write-Host "✓ Repository exists: $($rCheck.full_name)" -ForegroundColor Green
} catch {
    Write-Host "Creating repository $user/$repo..." -ForegroundColor Cyan
    $createBody = @{
        name        = $repo
        description = 'SIPPICOM Cloud IT Tools and Workstation AutoDeploy Suite (irm | iex)'
        private     = $false
        auto_init   = $true
    } | ConvertTo-Json
    $rCheck = Invoke-RestMethod -Uri 'https://api.github.com/user/repos' -Headers $headers -Method Post -Body $createBody
    Write-Host "✓ Created repository: $($rCheck.full_name)" -ForegroundColor Green
    Start-Sleep -Seconds 2
}

# 2. Upload Files
$rootDir = "C:\Users\aguerster\Documents\__Projects\GitHub_Repo"
$filesToUpload = @(
    'main.ps1',
    'README.md',
    'SippiSign_QRCode.png',
    'tools\certrdp\CertRDP.ps1',
    'tools\printerfix\PrinterFix.ps1',
    'tools\autodeploy\AutoDeploy.ps1',
    'tools\autodeploy\AutoDeployFast.ps1',
    'tools\ctrlaltpass\CtrlAltPass.ps1',
    'bin\CertRDP.exe',
    'bin\SippicomPrinterFix.exe',
    'bin\SippicomAutoDeploy.exe',
    'bin\SippicomAutoDeployFast.exe',
    'bin\SippicomCtrlAltPass.exe'
)

Write-Host "`n--> Uploading $($filesToUpload.Count) files directly to GitHub..." -ForegroundColor Cyan

foreach ($relPath in $filesToUpload) {
    $fullPath = Join-Path $rootDir $relPath
    if (!(Test-Path $fullPath)) { continue }

    $webPath = $relPath.Replace('\', '/')
    Write-Host "    Uploading $webPath ... " -NoNewline

    $bytes = [System.IO.File]::ReadAllBytes($fullPath)
    if ($relPath.EndsWith('.ps1') -or $relPath.EndsWith('.md')) {
        $text = [System.Text.Encoding]::UTF8.GetString($bytes)
        $text = $text.Replace('https://raw.githubusercontent.com/sippicom/tools/main', $targetUrl)
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    }

    $b64 = [Convert]::ToBase64String($bytes)

    # Check for existing SHA
    $sha = $null
    try {
        $existing = Invoke-RestMethod -Uri "https://api.github.com/repos/$user/$repo/contents/$webPath" -Headers $headers -Method Get -ErrorAction Stop
        $sha = $existing.sha
    } catch {
        # File does not exist yet
    }

    $bodyMap = @{
        message = "Upload $webPath"
        content = $b64
        branch  = 'main'
    }
    if ($sha) {
        $bodyMap['sha'] = $sha
    }

    $jsonBody = $bodyMap | ConvertTo-Json -Compress

    try {
        $uploadRes = Invoke-RestMethod -Uri "https://api.github.com/repos/$user/$repo/contents/$webPath" -Headers $headers -Method Put -Body $jsonBody -ContentType 'application/json' -ErrorAction Stop
        Write-Host "✓ OK" -ForegroundColor Green
    } catch {
        Write-Host "! Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor DarkYellow
Write-Host "   🎉 SIPPICOM CLOUD SUITE PUBLISHED SUCCESSFULLY TO GITHUB!" -ForegroundColor Green
Write-Host "   Repository URL: https://github.com/$user/$repo" -ForegroundColor Cyan
Write-Host "   Live One-Liner: irm $targetUrl/main.ps1 | iex" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor DarkYellow
