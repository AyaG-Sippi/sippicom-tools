$gh = "C:\Program Files\GitHub CLI\gh.exe"
$user = "AyaG-Sippi"
$repo = "sippicom-tools"
$targetUrl = "https://raw.githubusercontent.com/$user/$repo/main"

# Create repo if needed
& $gh repo create "$repo" --public --description "SIPPICOM Cloud IT Tools Suite (irm | iex)"

$rootDir = "C:\Users\aguerster\Documents\__Projects\GitHub_Repo"

# List files
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

Write-Host "Starting upload of $($filesToUpload.Count) files to $user/$repo..."

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
    $sha = & $gh api "repos/$user/$repo/contents/$webPath" --jq .sha 2>$null

    $tmp = [System.IO.Path]::GetTempFileName()
    $body = @{
        message = "Publish $webPath"
        content = $b64
        branch  = "main"
    }
    if ($sha) { $body["sha"] = $sha }

    $json = $body | ConvertTo-Json -Compress
    [System.IO.File]::WriteAllText($tmp, $json, [System.Text.Encoding]::UTF8)

    $out = & $gh api "repos/$user/$repo/contents/$webPath" -X PUT --input "$tmp"
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue

    Write-Host "DONE"
}

Write-Host "Upload process complete! Repository: https://github.com/$user/$repo"
