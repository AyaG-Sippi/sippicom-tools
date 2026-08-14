param(
    [string]$RepoName = "sippicom-tools",
    [switch]$Private
)

$ghPath = if (Get-Command gh -ErrorAction SilentlyContinue) { (Get-Command gh).Source } else { "C:\Program Files\GitHub CLI\gh.exe" }
$gitPath = if (Get-Command git -ErrorAction SilentlyContinue) { (Get-Command git).Source } else { "C:\Program Files\Git\cmd\git.exe" }

Write-Host "==================================================================" -ForegroundColor DarkYellow
Write-Host "   SIPPICOM GITHUB REPOSITORY UPLOADER" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor DarkYellow
Write-Host ""

# Check GH CLI Auth Status
$authStatus = & $ghPath auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  You are not logged in to GitHub CLI yet." -ForegroundColor Yellow
    Write-Host "Running 'gh auth login' now... Please follow the prompts in the terminal:" -ForegroundColor Cyan
    & $ghPath auth login
}

# Verify login
$user = (& $ghPath api user --jq .login 2>$null)
if (!$user) {
    Write-Host "❌ Login was not completed. Please run 'gh auth login' and try again." -ForegroundColor Red
    exit 1
}

Write-Host "✓ Logged in to GitHub as user: $user" -ForegroundColor Green

# Navigate to GitHub_Repo directory
$repoDir = "C:\Users\aguerster\Documents\__Projects\GitHub_Repo"
Set-Location $repoDir

# Initialize Git
if (!(Test-Path "$repoDir\.git")) {
    Write-Host "--> Initializing local Git repository..." -ForegroundColor Cyan
    & $gitPath init -b main
}

# Update URLs in scripts with the actual GitHub username
Write-Host "--> Updating script repository URLs to: https://raw.githubusercontent.com/$user/$RepoName/main ..." -ForegroundColor Cyan
$targetUrl = "https://raw.githubusercontent.com/$user/$RepoName/main"

$filesToUpdate = Get-ChildItem -Path $repoDir -Filter "*.ps1" -Recurse
foreach ($file in $filesToUpdate) {
    $content = Get-Content $file.FullName -Raw
    $updated = $content -replace "https://raw.githubusercontent.com/sippicom/tools/main", $targetUrl
    Set-Content -Path $file.FullName -Value $updated -NoNewline
}

$readmeFile = "$repoDir\README.md"
if (Test-Path $readmeFile) {
    $rContent = Get-Content $readmeFile -Raw
    $rUpdated = $rContent -replace "https://raw.githubusercontent.com/sippicom/tools/main", $targetUrl
    Set-Content -Path $readmeFile -Value $rUpdated -NoNewline
}

# Commit all files
Write-Host "--> Staging & committing files..." -ForegroundColor Cyan
& $gitPath add .
& $gitPath commit -m "Initial commit of SIPPICOM Cloud Tools suite (irm | iex)"

# Create remote repo and push
$visibility = if ($Private) { "--private" } else { "--public" }
Write-Host "--> Creating and pushing to remote GitHub repository: $user/$RepoName ($visibility)..." -ForegroundColor Cyan

& $ghPath repo create "$RepoName" $visibility --source=. --push 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==================================================================" -ForegroundColor DarkYellow
    Write-Host "   🎉 REPOSITORY PUBLISHED SUCCESSFULLY TO GITHUB!" -ForegroundColor Green
    Write-Host "   Repository URL: https://github.com/$user/$RepoName" -ForegroundColor Cyan
    Write-Host "   Cloud One-Liner: irm $targetUrl/main.ps1 | iex" -ForegroundColor Yellow
    Write-Host "==================================================================" -ForegroundColor DarkYellow
} else {
    Write-Host "--> Attempting standard remote push..." -ForegroundColor Cyan
    & $gitPath push -u origin main
}
