$git = "C:\Users\aguerster\AppData\Local\Microsoft\WinGet\Packages\Git.MinGit_Microsoft.Winget.Source_8wekyb3d8bbwe\cmd\git.exe"
$gh = "C:\Program Files\GitHub CLI\gh.exe"

$user = "AyaG-Sippi"
$repo = "sippicom-tools"
$token = (& $gh auth token).Trim()

$repoDir = "C:\Users\aguerster\Documents\__Projects\GitHub_Repo"
Set-Location $repoDir

Write-Host "==================================================================" -ForegroundColor DarkYellow
Write-Host "   SIPPICOM LOCAL GIT PUSH ENGINE (AyaG-Sippi/sippicom-tools)" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor DarkYellow

# Ensure GitHub remote repository exists
Write-Host "--> Verifying remote repository via GitHub CLI..." -ForegroundColor Cyan
& $gh repo create "$repo" --public --description "SIPPICOM Cloud IT Tools Suite (irm | iex)" 2>&1 | Out-Null

# Clean any existing local git config
if (Test-Path "$repoDir\.git") {
    Remove-Item -Path "$repoDir\.git" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "--> Initializing local Git repository..." -ForegroundColor Cyan
& $git init -b main
& $git config user.name "$user"
& $git config user.email "ayag-sippi@users.noreply.github.com"

# Set authenticated remote URL
$remoteUrl = "https://${user}:${token}@github.com/${user}/${repo}.git"
& $git remote add origin $remoteUrl

Write-Host "--> Staging all SIPPICOM tools, scripts, and binaries..." -ForegroundColor Cyan
& $git add .

Write-Host "--> Creating commit..." -ForegroundColor Cyan
& $git commit -m "Initial commit of SIPPICOM Cloud Tools suite (irm | iex)"

Write-Host "--> Pushing to GitHub (main branch)..." -ForegroundColor Cyan
& $git push -u origin main -f

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==================================================================" -ForegroundColor DarkYellow
    Write-Host "   🎉 SIPPICOM CLOUD SUITE PUSHED TO GITHUB VIA LOCAL GIT!" -ForegroundColor Green
    Write-Host "   Repository URL: https://github.com/$user/$repo" -ForegroundColor Cyan
    Write-Host "   Live Hub:       irm https://raw.githubusercontent.com/$user/$repo/main/main.ps1 | iex" -ForegroundColor Yellow
    Write-Host "==================================================================" -ForegroundColor DarkYellow
} else {
    Write-Host "! Git push returned exit code: $LASTEXITCODE" -ForegroundColor Red
}
