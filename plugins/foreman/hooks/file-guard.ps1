# PreToolUse (PowerShell, Bash, Write, Edit): ask before a command deletes anything outside temp folders,
# and copy any existing document the call is about to touch into the Foreman backups folder.
# It never blocks on its own failure.

. "$PSScriptRoot\common.ps1"

$DocExt = 'docx|docm|doc|xlsx|xlsm|xls|pptx|ppt|pdf|rtf|odt|ods|odp|csv|txt|md'
$PathRx = "(?i)""([^""\r\n]+?\.(?:{0}))""|'([^'\r\n]+?\.(?:{0}))'|([^\s""'<>|*?()=,;]+\.(?:{0}))\b"
$DocRx = $PathRx -f $DocExt
$ScriptRx = $PathRx -f 'py|js|mjs|cjs|ps1'
$ShellDeleteRx = '(?i)^(Remove-Item|rm|rmdir|del|erase|ri|Clear-Content)(?:\s+(.*))?$'
$CodeDeleteRx = '(?i)\b(?:os\.remove|os\.unlink|os\.rmdir|shutil\.rmtree|unlinkSync|rmSync|rmdirSync|\.unlink)\(\s*r?(["''])(.+?)\1'

function Get-Paths([string]$text, [string]$rx) {
    $found = @()
    foreach ($m in [regex]::Matches($text, $rx)) {
        foreach ($g in 1..3) { if ($m.Groups[$g].Success) { $found += $m.Groups[$g].Value } }
    }
    return $found
}

# Every statement in a shell command that deletes something, with what it deletes.
# Quoted text is swapped out first so a ';' or 'del' inside a string (python -c "...") isn't read as a command.
function Get-ShellDeleteTargets([string]$cmd) {
    $quoted = New-Object System.Collections.Generic.List[string]
    $masked = [regex]::Replace($cmd, '"[^"]*"|''[^'']*''', { param($m) $quoted.Add($m.Value); "@@Q$($quoted.Count - 1)@@" })
    $targets = @()
    foreach ($stmt in ($masked -split '[;\r\n|&]+')) {
        $s = $stmt.Trim().TrimStart('(', '{').Trim()
        if ($s -notmatch $ShellDeleteRx) { continue }
        $rest = [string]$Matches[2]
        # Skip switches (-Force, -rf, /q) but keep Git Bash paths like /c/Jobs.
        $words = @($rest -split '\s+' | Where-Object { $_ -and -not $_.StartsWith('-') -and (-not $_.StartsWith('/') -or $_ -match '^/[a-z]/') })
        if ($words.Count -eq 0) { $targets += '?'; continue }
        foreach ($w in $words) {
            $targets += [regex]::Replace($w, '@@Q(\d+)@@', { param($m) $quoted[[int]$m.Groups[1].Value] })
        }
    }
    return $targets
}

function Backup-Doc([string]$path, $state) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return }
    $item = Get-Item -LiteralPath $path
    if ($item.FullName.StartsWith($ForemanHome, [StringComparison]::OrdinalIgnoreCase)) { return }
    if (Test-TempPath $item.FullName) { return }
    if ($item.Length -gt 200MB) { return }

    $seen = $state.backedUp
    if (-not $seen) { $seen = New-Object PSObject; Set-StateValue $state 'backedUp' $seen }
    $key = $item.FullName.ToLowerInvariant()
    $stamp = $item.LastWriteTimeUtc.Ticks.ToString()
    # One copy per version of the file, as long as that copy still exists.
    $prev = $seen.$key
    if ($prev -and $prev.stamp -eq $stamp -and (Test-Path -LiteralPath (Join-Path $BackupDir $prev.file))) { return }

    if (-not (Test-Path $BackupDir)) { New-Item -ItemType Directory -Force $BackupDir | Out-Null }
    $base = "{0}_{1}" -f (Get-Date -Format 'yyyy-MM-dd_HHmmss'), $item.BaseName
    $name = $base + $item.Extension
    $n = 2
    while (Test-Path -LiteralPath (Join-Path $BackupDir $name)) { $name = "$base ($n)$($item.Extension)"; $n++ }
    $dest = Join-Path $BackupDir $name
    Copy-Item -LiteralPath $item.FullName -Destination $dest
    # Copy-Item keeps the document's own date; the 30-day clean-up must count from the day of the backup.
    (Get-Item -LiteralPath $dest).LastWriteTime = Get-Date
    Set-StateValue $seen $key ([pscustomobject]@{ stamp = $stamp; file = $name })
}

try {
    $hookIn = Read-HookInput
    if (-not $hookIn) { exit 0 }
    $tool = [string]$hookIn.tool_name
    $cwd = [string]$hookIn.cwd
    $candidates = @()
    $scriptTexts = @()

    if ($tool -eq 'Write' -or $tool -eq 'Edit' -or $tool -eq 'MultiEdit') {
        $candidates += [string]$hookIn.tool_input.file_path
    } elseif ($tool -eq 'PowerShell' -or $tool -eq 'Bash') {
        $cmd = [string]$hookIn.tool_input.command
        $candidates += Get-Paths $cmd $DocRx
        # Scripts run by the command often hold the real document paths, so read those too.
        foreach ($s in (Get-Paths $cmd $ScriptRx)) {
            $script = Resolve-UserPath $s $cwd
            if ($script -and (Test-Path -LiteralPath $script -PathType Leaf) -and (Get-Item -LiteralPath $script).Length -lt 200KB) {
                $text = Get-Content -LiteralPath $script -Raw -Encoding UTF8
                $scriptTexts += $text
                $candidates += Get-Paths $text $DocRx
            }
        }

        # Decide about deleting first, and say it before any file work that could fail.
        $risky = @()
        foreach ($t in (Get-ShellDeleteTargets $cmd)) {
            if ($t -eq '?') { $risky += $t; continue }
            if (-not (Test-TempPath (Resolve-UserPath $t $cwd))) { $risky += $t }
        }
        foreach ($text in @($cmd) + $scriptTexts) {
            foreach ($m in [regex]::Matches($text, $CodeDeleteRx)) {
                if (-not (Test-TempPath (Resolve-UserPath $m.Groups[2].Value $cwd))) { $risky += $m.Groups[2].Value }
            }
        }
        if ($risky.Count -gt 0) {
            Write-HookJson @{ hookSpecificOutput = @{
                hookEventName = 'PreToolUse'
                permissionDecision = 'ask'
                permissionDecisionReason = 'Foreman: this command deletes files. Only say yes if you asked for something to be deleted.'
            } }
        }
    } else {
        exit 0
    }

    $state = Get-State
    foreach ($c in ($candidates | Where-Object { $_ } | Select-Object -Unique)) {
        $full = Resolve-UserPath $c $cwd
        if ($full) { try { Backup-Doc $full $state } catch { } }
    }
    $null = Save-State $state
} catch {
    try { Add-Content (Join-Path $ForemanHome 'hook-errors.log') ("{0} file-guard: {1}" -f (Get-Date -Format s), $_) } catch { }
}
exit 0
