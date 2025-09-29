param(
  [string]$Message = "chore: site update $(Get-Date -Format 'yyyy-MM-dd HH:mm K')",
  [switch]$NoVersion
)

# Always run from this script's folder
Set-Location -Path $PSScriptRoot

# Optional version bump (ASCII only, use a normal hyphen)
if (-not $NoVersion) {
  "msmd-site $(Get-Date -Format 'yyyy.MM.dd') - $(Get-Date -Format 'yyyy-MM-dd HH:mm K')" |
    Out-File -Encoding utf8 version.txt
}

# Make sure we're in a git repo and on main
git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
  git init | Out-Null
  git branch -M main | Out-Null
}

# Sync latest (safe even on first run)
git fetch origin 2>$null
git pull --rebase origin main 2>$null

# Stage, commit, push
git add -A
$changes = git status --porcelain

if ([string]::IsNullOrWhiteSpace($changes)) {
  Write-Host "OK: No changes to commit."
  exit 0
}

git commit -m $Message
git push origin main

if ($LASTEXITCODE -eq 0) {
  Write-Host "Pushed: $Message"
} else {
  Write-Host "Push failed."
  exit 1
}
