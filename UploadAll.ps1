$gh = "C:\Program Files\GitHub CLI\gh.exe"
$user = "AyaG-Sippi"
$repo = "sippicom-tools"
$rootDir = "C:\Users\aguerster\Documents\__Projects\GitHub_Repo"
$targetUrl = "https://raw.githubusercontent.com/$user/$repo/main"

$filesToUpload = @(
    "main.ps1",
    "README.md",
    "SippiSign_QRCode.png",
    "tools\certrdp\CertRDP.ps1",
    "tools\printerfix\PrinterFix.ps1",
    "tools\autodeploy\AutoDeploy.ps1",
    "tools\autodeploy\AutoDeployFast.ps1",
    "tools\ctrlaltpass\CtrlAltPass.ps1",
    "bin\CertRDP.exe",
    "bin\SippicomPrinterFix.exe",
    "bin\SippicomAutoDeploy.exe",
    "bin\SippicomAutoDeployFast.exe",
    "bin\SippicomCtrlAltPass.exe"
)

Write-Host "Publishing $($filesToUpload.Count) files to https://github.com/$user/$repo ..."

foreach ($relPath in $filesToUpload) {
    $fullPath = Join-Path $rootDir $relPath
    if (!(Test-Path $fullPath)) { continue }

    $webPath = $relPath.Replace('\', '/')
    Write-Host "Uploading $webPath ... " -NoNewline

    $bytes = [System.IO.File]::ReadAllBytes($fullPath)
    if ($relPath.EndsWith(".ps1") -or $relPath.EndsWith(".md")) {
        $text = [System.Text.Encoding]::UTF8.GetString($bytes)
        $text = $text.Replace("https://raw.githubusercontent.com/sippicom/tools/main", $targetUrl)
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    }

    $b64 = [Convert]::ToBase64String($bytes)
    $sha = (& $gh api "repos/$user/$repo/contents/$webPath" --jq .sha 2>$null)

    if ($sha) {
        $res = & $gh api "repos/$user/$repo/contents/$webPath" -X PUT -f message="Upload $webPath" -f content="$b64" -f sha="$sha" -f branch="main" 2>&1
    } else {
        $res = & $gh api "repos/$user/$repo/contents/$webPath" -X PUT -f message="Upload $webPath" -f content="$b64" -f branch="main" 2>&1
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ OK" -ForegroundColor Green
    } else {
        Write-Host "! Status: $res" -ForegroundColor Yellow
    }
}

Write-Host "`nAll files uploaded to https://github.com/$user/$repo"
