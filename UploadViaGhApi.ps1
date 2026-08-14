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
    & $gh repo create "$repo" --public --description "SIPPICOM Cloud IT Tools & Workstation AutoDeploy Suite (irm | iex)" 2>&1
    Start-Sleep -Seconds 2
} else {
    Write-Host "✓ Repository $user/$repo is active." -ForegroundColor Green
}

# 2. Files to Upload
$rootDir = "C:\Users\aguerster\Documents\__Projects\GitHub_Repo"
$files = Get-ChildItem -Path $rootDir -Recurse -File | Where-Object { 
    $_.FullName -notmatch '\\\.git\\' -and 
    $_.Name -notmatch '\.cs$' -and 
    $_.Name -notmatch '^prepare_push' -and 
    $_.Name -notmatch '^PublishToGitHub' -and 
    $_.Name -notmatch '^UploadViaGhApi' -and
    $_.Name -ne "GitHubUploader.exe"
}

Write-Host "--> Uploading $($files.Count) files to $user/$repo..." -ForegroundColor Cyan

foreach ($f in $files) {
    $rel = $f.FullName.Substring($rootDir.Length).TrimStart('\').Replace('\', '/')
    Write-Host "    Uploading $rel ... " -NoNewline

    $rawBytes = [System.IO.File]::ReadAllBytes($f.FullName)
    
    # Replace template URLs in script files
    if ($f.Extension -in @(".ps1", ".md", ".txt")) {
        $str = [System.Text.Encoding]::UTF8.GetString($rawBytes)
        $str = $str.Replace("https://raw.githubusercontent.com/sippicom/tools/main", $targetUrl)
        $rawBytes = [System.Text.Encoding]::UTF8.GetBytes($str)
    }

    $b64 = [Convert]::ToBase64String($rawBytes)

    # Check for existing SHA
    $sha = (& $gh api "repos/$user/$repo/contents/$rel" --jq .sha 2>$null)
    
    $tempJson = [System.IO.Path]::GetTempFileName()
    if ($sha) {
        $json = @{ message = "Upload $rel"; content = $b64; sha = $sha; branch = "main" } | ConvertTo-Json -Compress
    } else {
        $json = @{ message = "Upload $rel"; content = $b64; branch = "main" } | ConvertTo-Json -Compress
    }
    [System.IO.File]::WriteAllText($tempJson, $json, [System.Text.Encoding]::UTF8)

    $res = & $gh api "repos/$user/$repo/contents/$rel" -X PUT --input "$tempJson" 2>&1
    Remove-Item $tempJson -Force -ErrorAction SilentlyContinue

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ OK" -ForegroundColor Green
    } else {
        Write-Host "! Response: $res" -ForegroundColor Yellow
    }
}

Write-Host "`n==================================================================" -ForegroundColor DarkYellow
Write-Host "   🎉 SIPPICOM CLOUD SUITE PUBLISHED SUCCESSFULLY TO GITHUB!" -ForegroundColor Green
Write-Host "   Repository URL: https://github.com/$user/$repo" -ForegroundColor Cyan
Write-Host "   Live One-Liner: irm $targetUrl/main.ps1 | iex" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor DarkYellow
