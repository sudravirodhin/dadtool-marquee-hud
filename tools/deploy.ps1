# Deploy Marquee into the game's UE4SS Mods folder.
# - Migrates runtime data (performance history + fetched lyrics) from the old
#   "DiscoTracker" folder on first run, then disables the old mod so the two
#   don't both hook the game.
# - Non-destructive to runtime data on subsequent runs (only overwrites Scripts).
param(
  [string]$GameMods = "D:\SteamLibrary\steamapps\common\Dead as Disco\Pagoda\Binaries\Win64\ue4ss\Mods"
)

$src  = Join-Path $PSScriptRoot "..\src"
$old  = Join-Path $GameMods "DiscoTracker"
$new  = Join-Path $GameMods "Marquee"
$dest = Join-Path $new "Scripts"

New-Item -ItemType Directory -Force -Path $dest | Out-Null

# One-time migration: carry over runtime data from the old mod before copying source.
$oldData = Join-Path $old "Scripts\data"
$newData = Join-Path $dest "data"
if ((Test-Path $oldData) -and -not (Test-Path $newData)) {
  Write-Host "Migrating data (history + lyrics): DiscoTracker -> Marquee ..."
  Copy-Item -Recurse -Force $oldData $newData
}

# Copy source (merges into data/, won't clobber migrated history/lyrics).
Copy-Item -Recurse -Force (Join-Path $src "*") $dest

$enabled = Join-Path $new "enabled.txt"
if (-not (Test-Path $enabled)) { New-Item -ItemType File -Path $enabled | Out-Null }

# Disable the old mod so DiscoTracker and Marquee don't both load and double-hook.
$oldEnabled = Join-Path $old "enabled.txt"
if (Test-Path $oldEnabled) {
  Rename-Item -Path $oldEnabled -NewName "enabled.txt.disabled" -Force
  Write-Host "Disabled old DiscoTracker (enabled.txt -> enabled.txt.disabled)."
}

Write-Host "Deployed Marquee -> $dest"
