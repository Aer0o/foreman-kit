# Builds dist\Foreman.zip: the installer folder he double-clicks from. The plugin itself is not in the
# zip; his Claude downloads it from GitHub and keeps it updated.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File tools\build-zip.ps1

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $repo 'dist'
$stage = Join-Path $dist 'Foreman'

if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force $stage | Out-Null
Copy-Item (Join-Path $repo 'installer\*') $stage -Recurse

$zip = Join-Path $dist 'Foreman.zip'
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path $stage -DestinationPath $zip
Remove-Item $stage -Recurse -Force
Write-Host "Built $zip ($([math]::Round((Get-Item $zip).Length / 1KB)) KB)"
