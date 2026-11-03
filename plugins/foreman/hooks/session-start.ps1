# SessionStart: load the rules, his profile and voice; first-run setup; weekly tool check;
# update notice; prune old backups. Any failure is logged and the session starts normally.

. "$PSScriptRoot\common.ps1"

try {
    $hookIn = Read-HookInput
    Initialize-ForemanHome
    $state = Get-State
    $now = Get-Date
    $parts = New-Object System.Collections.Generic.List[string]

    $parts.Add((Get-Content (Join-Path $PluginRoot 'core\rules.md') -Raw -Encoding UTF8))
    $parts.Add("His files: profile.md, voice.md, doc-style.md and checklist.md in $ForemanHome. Read doc-style.md before making or restyling a document.")

    $profilePath = Join-Path $ForemanHome 'profile.md'
    if (Test-Blank $profilePath) {
        $parts.Add('FIRST RUN: his company profile is empty. Answer whatever he asks first, then offer the five-minute setup in one line (foreman-setup skill). Offer it once per session, not every reply.')
    } else {
        $profileText = Get-Content $profilePath -Raw -Encoding UTF8
        if ($profileText.Length -gt 3000) { $profileText = $profileText.Substring(0, 3000) + "`n[profile cut short; read the full file if needed]" }
        $parts.Add("## His company profile`n$profileText")
    }

    $voicePath = Join-Path $ForemanHome 'voice.md'
    if (-not (Test-Blank $voicePath)) {
        $voice = Get-Content $voicePath -Raw -Encoding UTF8
        if ($voice.Length -gt 1500) { $voice = $voice.Substring(0, 1500) }
        $parts.Add("## How he writes`n$voice")
    }

    # Notes he built up under SPARK 1 (its CLAUDE.md), kept by the installer.
    $oldNotes = Join-Path $ForemanHome 'spark1-notes.md'
    if (Test-Path $oldNotes) {
        $parts.Add("Older notes from SPARK 1 (things he asked Claude to remember) are in $oldNotes. Read them when a question touches his habits, clients or past jobs.")
    }

    # Update notice: first line of changelog.md is "<version> | <one line for him>".
    $top = @(Get-Content (Join-Path $PluginRoot 'core\changelog.md') -TotalCount 1 -Encoding UTF8)
    if ($top.Count -gt 0 -and $top[0] -match '^\s*([^|]+?)\s*\|\s*(.+)$') {
        $version = $Matches[1]; $note = $Matches[2]
        $seen = $state.lastVersion
        if (-not $seen) {
            $parts.Add("Foreman $version was just installed. At the start of your first reply, say in one line that Foreman is ready.")
        } elseif ($seen -ne $version) {
            $parts.Add("Foreman was updated to $version. At the start of your first reply, tell him in one line: $note")
        }
        Set-StateValue $state 'lastVersion' $version
    }

    # Weekly check that the Office tools are still on this PC.
    $lastCheck = $null
    if ($state.lastHealthCheck) { try { $lastCheck = [datetime]$state.lastHealthCheck } catch { } }
    if (-not $lastCheck -or ($now - $lastCheck).TotalDays -ge 7 -or $state.missingTools) {
        $missing = @()
        foreach ($tool in @('python', 'node', 'soffice', 'pdftoppm', 'pandoc')) {
            $found = Get-Command $tool -ErrorAction SilentlyContinue | Select-Object -First 1
            # The Microsoft Store 'python' stand-in only opens the Store, so it doesn't count.
            if (-not $found -or $found.Source -match '\\WindowsApps\\') { $missing += $tool }
        }
        Set-StateValue $state 'lastHealthCheck' $now.ToString('o')
        Set-StateValue $state 'missingTools' ($missing -join ', ')
    }
    if ($state.missingTools) {
        $parts.Add("TOOLS MISSING on this PC: $($state.missingTools). Word/PDF/Excel/PowerPoint work may fail. Tell him once, plainly: double-click Fix Foreman in his Foreman folder, then reopen Claude.")
    }

    # Backups older than 30 days go, and so does the record of them.
    if (Test-Path $BackupDir) {
        Get-ChildItem $BackupDir -File -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt $now.AddDays(-30) } |
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
    if ($state.backedUp) {
        foreach ($p in @($state.backedUp.PSObject.Properties)) {
            if (-not $p.Value.file -or -not (Test-Path -LiteralPath (Join-Path $BackupDir $p.Value.file))) { $state.backedUp.PSObject.Properties.Remove($p.Name) }
        }
    }

    Set-StateValue $state 'turns' 0
    Set-StateValue $state 'sessionId' $(if ($hookIn) { $hookIn.session_id } else { '' })
    $null = Save-State $state

    $text = $parts -join "`n`n"
    if ($text.Length -gt 9500) { $text = $text.Substring(0, 9500) }
    Add-Context 'SessionStart' $text
} catch {
    try { Add-Content (Join-Path $ForemanHome 'hook-errors.log') ("{0} session-start: {1}" -f (Get-Date -Format s), $_) } catch { }
}
exit 0
