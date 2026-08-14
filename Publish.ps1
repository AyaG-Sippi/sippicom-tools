$gh = "C:\Program Files\GitHub CLI\gh.exe"
$user = (& $gh api user --jq .login).Trim()
$repo = "sippicom-tools"
$targetUrl = "https://raw.githubusercontent.com/$user/$repo/main"

Write-Host "==================================================================" -ForegroundColor DarkYellow
Write-Host "   SIPPICOM GITHUB PUBLISHER (Target: $user/$repo)" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor DarkYellow

# 1. Create or Verify Repository
$check = & $gh api "repos/$user/$repo" --jq .name 2>$null
if (!$check) {
    Write-Host "--> Creating public repository $user/$repo..." -ForegroundColor Cyan
    & $gh repo create "$repo" --public --description "SIPPICOM Cloud IT Tools Suite (irm | iex)" 2>&1
    Start-Sleep -Seconds 2
} else {
    Write-Host "✓ Repository $user/$repo exists." -ForegroundColor Green
}

# 2. Files to Upload
$rootDir = "C:\Users\aguerster\Documents\__Projects\GitHub_Repo"
$allList = Get-ChildItem -Path $rootDir -Recurse -File

$uploadList = New-Object System.Collections.ArrayList
foreach ($item in $allList) {
    $n = $item.Name
    $p = $item.FullName
    if ($p -match '\\\.git\\') { continue }
    if ($n -match '\.cs$') { continue }
    if ($n.StartsWith("prepare_push")) { continue }
    if ($n.StartsWith("Publish")) { continue }
    if ($n.StartsWith("Upload")) { continue }
    if ($n -eq "GitHubUploader.exe") { continue }
    [void]$uploadList.Add($item)
}

Write-Host "--> Uploading $($uploadList.Count) files to $user/$repo..." -ForegroundColor Cyan

foreach ($f in $uploadList) {
    $rel = $f.FullName.Substring($rootDir.Length).TrimStart('\').Replace('\', '/')
    Write-Host "    Uploading $rel ... " -NoNewline

    $rawBytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $ext = $f.Extension.ToLower()

    if ($ext -eq ".ps1" -or $ext -eq ".md" -or $ext -eq ".txt") {
        $str = [System.Text.Encoding]::UTF8.GetString($rawBytes)
        $str = $str.Replace("https://raw.githubusercontent.com/sippicom/tools/main", $targetUrl)
        $rawBytes = [System.Text.Encoding]::UTF8.GetBytes($str)
    }

    $b64 = [Convert]::ToBase64String($rawBytes)
    $sha = (& $gh api "repos/$user/$repo/contents/$rel" --jq .sha 2>$null)

    $obj = New-Object System.Collections.Generic.Dictionary[string,object]
    $obj["message"] = "Upload $rel"
    $obj["content"] = $b64
    $obj["branch"] = "main"
    if ($sha) {
        $obj["sha"] = $sha
    }

    $tempJson = [System.IO.Path]::GetTempFileName()
    $json = ConvertTo-Json -InputObject $obj -Compress
    [System.IO.File]::WriteAllText($tempJson, $json, [System.Text.Encoding]::UTF8)

    $res = & $gh api "repos/$user/$repo/contents/$rel" -X PUT --input "$tempJson" 2>&1
    Remove-Item $tempJson -Force -ErrorAction SilentlyContinue

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ OK" -ForegroundColor Green
    } else {
        Write-Host "! Response: $res" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor DarkYellow
Write-Host "   🎉 SIPPICOM CLOUD SUITE PUBLISHED TO GITHUB!" -ForegroundColor Green
Write-Host "   Repository URL: https://github.com/$user/$repo" -ForegroundColor Cyan
Write-Host "   Cloud One-Liner: irm $targetUrl/main.ps1 | iex" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor DarkYellow
