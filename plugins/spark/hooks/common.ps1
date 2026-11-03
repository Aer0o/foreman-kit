# Shared helpers for the SPARK hooks. Dot-sourced by each hook script.
# Keep this file pure ASCII: Windows PowerShell 5.1 reads BOM-less scripts as ANSI.

$ErrorActionPreference = 'Stop'
[Console]::InputEncoding = [Text.Encoding]::UTF8
[Console]::OutputEncoding = [Text.Encoding]::UTF8

$PluginRoot = Split-Path -Parent $PSScriptRoot

# SPARK_HOME lets the tests point the hooks at a throwaway folder.
if ($env:SPARK_HOME) {
    $SparkHome = $env:SPARK_HOME
} elseif ($env:CLAUDE_CONFIG_DIR) {
    $SparkHome = Join-Path $env:CLAUDE_CONFIG_DIR 'spark'
} else {
    $SparkHome = Join-Path $env:USERPROFILE '.claude\spark'
}
$StatePath = Join-Path $SparkHome 'state.json'
$BackupDir = Join-Path $SparkHome 'backups'

function Read-HookInput {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { return $null }
    return $raw | ConvertFrom-Json
}

function Write-HookJson($obj) {
    [Console]::Out.Write(($obj | ConvertTo-Json -Compress -Depth 6))
}

function Add-Context($eventName, [string]$text) {
    Write-HookJson @{ hookSpecificOutput = @{ hookEventName = $eventName; additionalContext = $text } }
}

function Get-State {
    if (Test-Path $StatePath) {
        try { return Get-Content $StatePath -Raw -Encoding UTF8 | ConvertFrom-Json } catch { }
    }
    return New-Object PSObject
}

# Write to a side file, then swap it in, so a hook running in parallel never reads half a file.
# Returns $false instead of throwing when the file is busy: state is a convenience, never a blocker.
function Save-State($state) {
    try {
        if (-not (Test-Path $SparkHome)) { New-Item -ItemType Directory -Force $SparkHome | Out-Null }
        $tmp = "$StatePath.$PID.tmp"
        [IO.File]::WriteAllText($tmp, ($state | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding $false))
        # [NullString]::Value, not $null: PowerShell passes $null to .NET string parameters as "".
        if (Test-Path $StatePath) { [IO.File]::Replace($tmp, $StatePath, [NullString]::Value) } else { [IO.File]::Move($tmp, $StatePath) }
        return $true
    } catch {
        Remove-Item "$StatePath.$PID.tmp" -Force -ErrorAction SilentlyContinue
        return $false
    }
}

# Turn what a command line says into a real Windows path: env vars, ~, $HOME, Git Bash /c/ paths.
function Resolve-UserPath([string]$p, [string]$cwd) {
    if (-not $p) { return $null }
    $p = $p.Trim().Trim('"', "'")
    $p = [regex]::Replace($p, '(?i)\$env:([A-Za-z_][A-Za-z0-9_]*)', { param($m) [Environment]::GetEnvironmentVariable($m.Groups[1].Value) })
    $p = [regex]::Replace($p, '(?i)^\$HOME(?=[\\/]|$)', { param($m) $env:USERPROFILE })
    $p = [Environment]::ExpandEnvironmentVariables($p)
    if ($p -match '^~(?=[\\/]|$)') { $p = $env:USERPROFILE + $p.Substring(1) }
    if ($p -match '^/tmp(/.*)?$') { $p = [IO.Path]::GetTempPath() + [string]$Matches[1] }
    elseif ($p -match '^/([A-Za-z])/(.*)$') { $p = $Matches[1].ToUpper() + ':\' + $Matches[2] }
    if (-not [IO.Path]::IsPathRooted($p)) {
        if (-not $cwd) { return $null }
        $p = Join-Path $cwd $p
    }
    try { return [IO.Path]::GetFullPath($p.Replace('/', '\')) } catch { return $null }
}

function Test-TempPath([string]$full) {
    if (-not $full) { return $false }
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    return $full.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase) -or $full -match '(?i)\\spark-work(\\|$)'
}

function Set-StateValue($state, [string]$name, $value) {
    if ($state.PSObject.Properties[$name]) { $state.$name = $value }
    else { $state | Add-Member -NotePropertyName $name -NotePropertyValue $value }
}

# Copy any default file he doesn't have yet. Never overwrites his copies.
function Initialize-SparkHome {
    foreach ($d in @($SparkHome, $BackupDir)) {
        if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force $d | Out-Null }
    }
    foreach ($f in @('profile.md', 'voice.md', 'doc-style.md', 'checklist.md')) {
        $src = Join-Path $PluginRoot "defaults\$f"
        $dst = Join-Path $SparkHome $f
        if ((Test-Path $src) -and -not (Test-Path $dst)) { Copy-Item $src $dst }
    }
}

function Test-Blank([string]$path) {
    if (-not (Test-Path $path)) { return $true }
    return [bool](Select-String -Path $path -SimpleMatch 'SPARK:BLANK' -Quiet)
}
