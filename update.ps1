param(
  [string]$Message = "chore: site update $(Get-Date -Format 'yyyy-MM-dd HH:mm K')",
  [switch]$NoVersion
)

# always run from this script’s folder
Set-Location -Path $PSScriptRoot

# optional: quick version bump
if (-not $NoVersion) {
  "msmd-site $(Get-Date -Format 'yyyy.MM.dd') — $(Get-Date -Format 'yyyy-MM-dd HH:mm K')" |
    Out-File -Encoding utf8 version.txt
}

# ensure repo is on 'main' (don’t fail if already set)
git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { git init; git branch -M main }

# pull latest (ok if first push)
git fetch origin 2>$null
git pull --rebase origin main 2>$null

# stage/commit only if there are changes
git add -A
$changes = git status --porcelain
if ([string]::IsNullOrWhiteSpace($changes)) {
  Write-Host "✅ No changes to commit."
  exit 0
}

git commit -m $Message
git push origin main
Write-Host "🚀 Pushed: $Message"
