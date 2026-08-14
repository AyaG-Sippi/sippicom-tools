param(
    [string]$RepoName = "sippicom-tools",
    [switch]$Private
)

$gh = "C:\Program Files\GitHub CLI\gh.exe"
if (!(Test-Path $gh)) {
    $gh = (Get-Command gh -ErrorAction SilentlyContinue).Source
}

Write-Host "==================================================================" -ForegroundColor DarkYellow
Write-Host "   SIPPICOM DIRECT GITHUB API UPLOADER" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor DarkYellow
Write-Host ""

# Fetch authenticated username
$user = (& $gh api user --jq .login 2>$null)
if (!$user) {
    Write-Host "❌ Not logged in to GitHub. Please run 'gh auth login' in your terminal." -ForegroundColor Red
    exit 1
}

Write-Host "✓ Authenticated as GitHub user: $user" -ForegroundColor Green

# Create remote repository if it does not exist
$repoCheck = (& $gh api "repos/$user/$RepoName" --jq .name 2>$null)
if (!$repoCheck) {
    Write-Host "--> Creating remote repository '$user/$RepoName'..." -ForegroundColor Cyan
    $visibilityJson = if ($Private) { '{"name":"' + $RepoName + '","private":true}' } else { '{"name":"' + $RepoName + '","private":false}' }
    $createRes = $visibilityJson | & $gh api "user/repos" -X POST --input - 2>&1
    Write-Host "✓ Created repository https://github.com/$user/$RepoName" -ForegroundColor Green
} else {
    Write-Host "✓ Remote repository https://github.com/$user/$RepoName is ready." -ForegroundColor Green
}

# Local Root Directory
$rootDir = "C:\Users\aguerster\Documents\__Projects\GitHub_Repo"
$targetUrl = "https://raw.githubusercontent.com/$user/$RepoName/main"

# Get all files to upload (excluding local installer scripts)
$allFiles = Get-ChildItem -Path $rootDir -Recurse -File | Where-Object { 
    $_.FullName -notmatch '\\\.git\\' -and 
    $_.Name -ne "prepare_push.ps1" -and 
    $_.Name -ne "PublishToGitHub.ps1"
}

Write-Host "`n--> Uploading $($allFiles.Count) files directly to $user/$RepoName via GitHub REST API..." -ForegroundColor Cyan

foreach ($file in $allFiles) {
    $relPath = $file.FullName.Substring($rootDir.Length).TrimStart('\').Replace('\', '/')
    Write-Host "    Uploading $relPath..." -ForegroundColor Gray

    $rawContent = [System.IO.File]::ReadAllBytes($file.FullName)
    
    # If text file, replace template URLs with user's repository URL
    if ($file.Extension -in @(".ps1", ".md", ".txt")) {
        $text = [System.Text.Encoding]::UTF8.GetString($rawContent)
        $text = $text -replace "https://raw.githubusercontent.com/sippicom/tools/main", $targetUrl
        $rawContent = [System.Text.Encoding]::UTF8.GetBytes($text)
    }

    $b64 = [Convert]::ToBase64String($rawContent)

    # Check if file exists on GitHub to retrieve SHA for update
    $existingSha = (& $gh api "repos/$user/$RepoName/contents/$relPath" --jq .sha 2>$null)
    
    $payloadObj = @{
        message = "Upload $relPath"
        content = $b64
    }
    if ($existingSha) {
        $payloadObj["sha"] = $existingSha
    }

    $jsonPayload = $payloadObj | ConvertTo-Json -Compress

    $res = $jsonPayload | & $gh api "repos/$user/$RepoName/contents/$relPath" -X PUT --input - 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ✓ $relPath uploaded successfully" -ForegroundColor Green
    } else {
        Write-Host "    ! Response for $relPath: $res" -ForegroundColor Yellow
    }
}

Write-Host "`n==================================================================" -ForegroundColor DarkYellow
Write-Host "   🎉 ALL SIPPICOM CLOUD TOOLS PUBLISHED TO GITHUB!" -ForegroundColor Green
Write-Host "   Repository URL:  https://github.com/$user/$RepoName" -ForegroundColor Cyan
Write-Host "   Live One-Liner:  irm $targetUrl/main.ps1 | iex" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor DarkYellow
