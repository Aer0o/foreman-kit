# Runs every Foreman hook against sample input in a throwaway folder and checks what comes back.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File tests\run-tests.ps1

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$hooks = Join-Path $repo 'plugins\foreman\hooks'
# Not under %TEMP%: the file guard deliberately ignores temp folders.
$work = Join-Path $PSScriptRoot (".work\" + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force $work | Out-Null
$env:FOREMAN_HOME = Join-Path $work 'home'
$script:fail = 0
$script:pass = 0

function Invoke-Hook([string]$name, $payload) {
    $json = if ($payload -is [string]) { $payload } else { $payload | ConvertTo-Json -Compress -Depth 8 }
    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = 'powershell.exe'
    $psi.Arguments = "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$(Join-Path $hooks $name)`""
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.StandardOutputEncoding = [Text.Encoding]::UTF8
    $p = [Diagnostics.Process]::Start($psi)
    $p.StandardInput.Write($json)
    $p.StandardInput.Close()
    $out = $p.StandardOutput.ReadToEnd()
    $err = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    return [pscustomobject]@{ code = $p.ExitCode; out = $out; err = $err }
}

function Check([string]$label, [bool]$ok, [string]$detail = '') {
    if ($ok) { $script:pass++; Write-Host "  PASS  $label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  FAIL  $label  $detail" -ForegroundColor Red }
}

function Write-Transcript([string]$path, [object[]]$entries) {
    $lines = $entries | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 10 }
    [IO.File]::WriteAllLines($path, $lines, (New-Object Text.UTF8Encoding $false))
}

Write-Host "session-start"
$r = Invoke-Hook 'session-start.ps1' @{ session_id = 's1'; hook_event_name = 'SessionStart'; source = 'startup' }
Check 'exits 0' ($r.code -eq 0) $r.err
$ctx = ($r.out | ConvertFrom-Json).hookSpecificOutput.additionalContext
Check 'injects the rules' ($ctx -match 'Never invent a number')
Check 'asks for setup when the profile is blank' ($ctx -match 'FIRST RUN')
Check 'announces a fresh install' ($ctx -match 'was just installed')
Check 'copies his default files' ((Test-Path "$env:FOREMAN_HOME\profile.md") -and (Test-Path "$env:FOREMAN_HOME\doc-style.md"))
Check 'stays under the 10,000-character cap' ($ctx.Length -lt 10000) "length $($ctx.Length)"

Set-Content "$env:FOREMAN_HOME\profile.md" "# Company profile`n- Legal name: Test Electric Ltd." -Encoding UTF8
$old = Join-Path $env:FOREMAN_HOME 'backups\2020-01-01_000000_old.docx'
Set-Content $old 'x'; (Get-Item $old).LastWriteTime = (Get-Date).AddDays(-40)
$r = Invoke-Hook 'session-start.ps1' @{ session_id = 's2'; hook_event_name = 'SessionStart'; source = 'startup' }
$ctx = ($r.out | ConvertFrom-Json).hookSpecificOutput.additionalContext
Check 'loads a filled profile' ($ctx -match 'Test Electric Ltd')
Check 'no setup offer once filled' ($ctx -notmatch 'FIRST RUN')
Check 'no install notice on the second run' ($ctx -notmatch 'was just installed')
Check 'prunes backups older than 30 days' (-not (Test-Path $old))

$state = Get-Content "$env:FOREMAN_HOME\state.json" -Raw | ConvertFrom-Json
$state.lastVersion = '1.9.0'
$state | ConvertTo-Json -Depth 6 | Set-Content "$env:FOREMAN_HOME\state.json" -Encoding UTF8
$r = Invoke-Hook 'session-start.ps1' @{ session_id = 's3'; hook_event_name = 'SessionStart'; source = 'startup' }
$ctx = ($r.out | ConvertFrom-Json).hookSpecificOutput.additionalContext
Check 'announces an update' ($ctx -match 'Foreman was updated to')

Write-Host "prompt-router"
$cases = @(
    @('Can you go over the tender docs and tell me what I missed?', 'foreman:tender-review'),
    @('check my quote before I send it to the GC', 'foreman:quote-check'),
    @('what is the catalogue number for a 20A arc fault breaker', 'foreman:spec-lookup'),
    @('pull the lighting fixture schedule from this PDF into Excel', 'foreman:doc-to-excel'),
    @('write a site report for the Main St job', 'foreman:report-writer'),
    @('make this proposal look professional', 'foreman:doc-design'),
    @('proofread this before I send it', 'foreman:proofread'),
    @('write an email to the client chasing the last invoice', 'foreman:client-email'),
    @('fix the wording in this Word document', 'foreman:doc-edit'),
    @('this sounds like AI, make it more natural', 'foreman:plain-writing'),
    @('undo that, get my old file back', 'foreman:foreman-setup'),
    @('spark is not working', 'foreman:foreman-setup')
)
foreach ($c in $cases) {
    $r = Invoke-Hook 'prompt-router.ps1' @{ session_id = 'r1'; hook_event_name = 'UserPromptSubmit'; prompt = $c[0] }
    $ctx = if ($r.out) { ($r.out | ConvertFrom-Json).hookSpecificOutput.additionalContext } else { '' }
    Check "routes: $($c[0])" ($ctx -match [regex]::Escape($c[1])) "got: $ctx"
}
$r = Invoke-Hook 'prompt-router.ps1' @{ session_id = 'r1'; hook_event_name = 'UserPromptSubmit'; prompt = 'thanks' }
Check 'stays quiet on small talk' ([string]::IsNullOrEmpty($r.out)) $r.out
$r = Invoke-Hook 'prompt-router.ps1' @{ session_id = 'r1'; hook_event_name = 'UserPromptSubmit'; prompt = 'we missed the firestopping on the last job' }
Check 'notices a missed item' ($r.out -match 'checklist.md')
$state = Get-Content "$env:FOREMAN_HOME\state.json" -Raw | ConvertFrom-Json
$state.turns = 19
$state | ConvertTo-Json -Depth 6 | Set-Content "$env:FOREMAN_HOME\state.json" -Encoding UTF8
$r = Invoke-Hook 'prompt-router.ps1' @{ session_id = 'r1'; hook_event_name = 'UserPromptSubmit'; prompt = 'ok next' }
Check 'suggests a new chat at turn 20' ($r.out -match 'new chat')

Write-Host "file-guard"
$docs = Join-Path $work 'Documents'
New-Item -ItemType Directory -Force $docs | Out-Null
$doc = Join-Path $docs 'Main St quote.docx'
Set-Content $doc 'original'
$r = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = "python edit.py `"$doc`"" } }
Check 'exits 0' ($r.code -eq 0) $r.err
$b = @(Get-ChildItem "$env:FOREMAN_HOME\backups" -Filter '*Main St quote.docx')
Check 'backs up a quoted path with spaces' ($b.Count -eq 1)
$r = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = "python edit.py `"$doc`"" } }
$b = @(Get-ChildItem "$env:FOREMAN_HOME\backups" -Filter '*Main St quote.docx')
Check 'does not copy the same version twice' ($b.Count -eq 1)
$xl = Join-Path $docs 'takeoff.xlsx'
Set-Content $xl 'sheet'
Set-Content (Join-Path $docs 'fix.py') "import openpyxl`nwb = openpyxl.load_workbook(r'$xl')`nwb.save(r'$xl')"
$r = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = 'python fix.py' } }
Check 'backs up a document named inside the script it runs' (@(Get-ChildItem "$env:FOREMAN_HOME\backups" -Filter '*takeoff.xlsx').Count -eq 1)
$r = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'Write'; cwd = $docs; tool_input = @{ file_path = (Join-Path $docs 'notes.txt'); content = 'x' } }
Check 'ignores a new file' ($r.code -eq 0 -and -not $r.out)
$r = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = "Remove-Item `"$doc`"" } }
Check 'asks before deleting his files' ($r.out -match '"permissionDecision":"ask"')
$r = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = 'Remove-Item $env:TEMP\foreman-work\page-1.png' } }
Check 'lets temp clean-up through' (-not $r.out)
$r = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = 'Get-ChildItem' } }
Check 'quiet on harmless commands' ($r.code -eq 0 -and -not $r.out)

Write-Host "file-guard regressions"
$oldDoc = Join-Path $docs 'Tender 2025.docx'
Set-Content $oldDoc 'last year'
(Get-Item $oldDoc).LastWriteTime = (Get-Date).AddDays(-400)
$null = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = "python edit.py `"$oldDoc`"" } }
$null = Invoke-Hook 'session-start.ps1' @{ session_id = 's4'; hook_event_name = 'SessionStart'; source = 'startup' }
$b = @(Get-ChildItem "$env:FOREMAN_HOME\backups" -Filter '*Tender 2025.docx')
Check 'a backup of an old document survives the 30-day clean-up' ($b.Count -eq 1)
$b | Remove-Item
$null = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = "python edit.py `"$oldDoc`"" } }
Check 'backs up again once the earlier copy is gone' (@(Get-ChildItem "$env:FOREMAN_HOME\backups" -Filter '*Tender 2025.docx').Count -eq 1)

$lock = [IO.File]::Open("$env:FOREMAN_HOME\state.json", 'Open', 'ReadWrite', 'None')
try {
    $r = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = "Remove-Item `"$doc`"" } }
    Check 'still asks before deleting when its state file is locked' ($r.out -match '"permissionDecision":"ask"') $r.out
} finally { $lock.Close() }

$r = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = "Copy-Item a.docx `$env:TEMP\foreman-work\; Remove-Item -Recurse `"$docs\Old Job`"" } }
Check 'a temp folder elsewhere in the command does not hide a real delete' ($r.out -match '"permissionDecision":"ask"')
$r = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = 'python make_report.py --out "C:\Jobs\45 Kennedy Rd North\report.docx"' } }
Check 'no delete prompt for a street name with Rd' (-not $r.out) $r.out
$r = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = "python -c `"import openpyxl; wb = openpyxl.load_workbook('t.xlsx'); del wb['Sheet']; wb.save('t.xlsx')`"" } }
Check 'no delete prompt for removing a sheet in Python' (-not $r.out) $r.out
$r = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = "python -c `"import os; os.remove(r'$doc')`"" } }
Check 'asks when Python deletes one of his files' ($r.out -match '"permissionDecision":"ask"')

$bashDoc = Join-Path $docs 'bash test.xlsx'
Set-Content $bashDoc 'x'
$bashPath = '/' + $bashDoc.Substring(0, 1).ToLower() + '/' + $bashDoc.Substring(3).Replace('\', '/')
$null = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'Bash'; cwd = $docs; tool_input = @{ command = "python fix.py `"$bashPath`"" } }
Check 'backs up a Git Bash style /c/ path' (@(Get-ChildItem "$env:FOREMAN_HOME\backups" -Filter '*bash test.xlsx').Count -eq 1)

$tmpScripts = Join-Path ([IO.Path]::GetTempPath()) ('foreman-test-' + [guid]::NewGuid().ToString('N').Substring(0, 6))
New-Item -ItemType Directory -Force $tmpScripts | Out-Null
$pptDoc = Join-Path $docs 'Owner deck.pptx'
Set-Content $pptDoc 'x'
Set-Content (Join-Path $tmpScripts 'deck.py') "p = r'$pptDoc'"
$null = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = $docs; tool_input = @{ command = "python `"$tmpScripts\deck.py`"" } }
Remove-Item $tmpScripts -Recurse -Force
Check 'reads a script kept in the temp folder' (@(Get-ChildItem "$env:FOREMAN_HOME\backups" -Filter '*Owner deck.pptx').Count -eq 1)

$env:FOREMAN_TEST_DOCS = $docs
$envDoc = Join-Path $docs 'env quote.docx'
Set-Content $envDoc 'x'
$null = Invoke-Hook 'file-guard.ps1' @{ tool_name = 'PowerShell'; cwd = 'C:\'; tool_input = @{ command = 'python edit.py "$env:FOREMAN_TEST_DOCS\env quote.docx"' } }
Check 'expands $env: paths' (@(Get-ChildItem "$env:FOREMAN_HOME\backups" -Filter '*env quote.docx').Count -eq 1)

$r = Invoke-Hook 'prompt-router.ps1' @{ session_id = 'r2'; hook_event_name = 'UserPromptSubmit'; prompt = 'I forgot to attach the drawings, here they are' }
Check 'a forgotten attachment is not a missed checklist item' ($r.out -notmatch 'checklist')

Write-Host "source-guard"
$tr = Join-Path $work 'transcript.jsonl'
$user = @{ type = 'user'; message = @{ role = 'user'; content = 'What breaker do I need for a 20A AFCI circuit in a Square D QO panel?' } }
$answerBad = @{ type = 'assistant'; message = @{ role = 'assistant'; content = @(@{ type = 'text'; text = 'Use the QO120CAFI, or the QO120PCAFI for the plug-on version. Wire it with 14AWG NMD90 on a 120V circuit.' }) } }
Write-Transcript $tr @($user, $answerBad)
$r = Invoke-Hook 'source-guard.ps1' @{ session_id = 'g1'; transcript_path = $tr; stop_hook_active = $false }
Check 'blocks invented part numbers' ($r.out -match '"decision":"block"' -and $r.out -match 'QO120CAFI') $r.out
Check 'does not flag units or cable types' ($r.out -notmatch '14AWG|NMD90|120V')
$r = Invoke-Hook 'source-guard.ps1' @{ session_id = 'g1'; transcript_path = $tr; stop_hook_active = $true }
Check 'never loops' (-not $r.out)
$answerSourced = @{ type = 'assistant'; message = @{ role = 'assistant'; content = @(@{ type = 'text'; text = 'Use the QO120CAFI (CHECKED: https://example.com/qo120cafi).' }) } }
Write-Transcript $tr @($user, $answerSourced)
$r = Invoke-Hook 'source-guard.ps1' @{ session_id = 'g1'; transcript_path = $tr; stop_hook_active = $false }
Check 'passes a sourced answer' (-not $r.out)
$toolUse = @{ type = 'assistant'; message = @{ role = 'assistant'; content = @(@{ type = 'tool_use'; id = 't1'; name = 'Read'; input = @{ file_path = 'C:\x\spec.pdf' } }) } }
$toolRes = @{ type = 'user'; message = @{ role = 'user'; content = @(@{ type = 'tool_result'; tool_use_id = 't1'; content = 'Panel schedule: breaker QO120CAFI, qty 12' }) } }
Write-Transcript $tr @($user, $toolUse, $toolRes, $answerBad)
$r = Invoke-Hook 'source-guard.ps1' @{ session_id = 'g1'; transcript_path = $tr; stop_hook_active = $false }
Check 'allows numbers found in his documents' ($r.out -notmatch 'QO120CAFI,|\(QO120CAFI') $r.out
$plain = @{ type = 'assistant'; message = @{ role = 'assistant'; content = @(@{ type = 'text'; text = 'Done. I saved the report for the 2026 job.' }) } }
Write-Transcript $tr @($user, $plain)
$r = Invoke-Hook 'source-guard.ps1' @{ session_id = 'g1'; transcript_path = $tr; stop_hook_active = $false }
Check 'quiet on normal answers' (-not $r.out)

function Test-Answer([string]$text, $extra = @()) {
    $a = @{ type = 'assistant'; message = @{ role = 'assistant'; content = @(@{ type = 'text'; text = $text }) } }
    Write-Transcript $tr (@($user) + $extra + @($a))
    return Invoke-Hook 'source-guard.ps1' @{ session_id = 'g2'; transcript_path = $tr; stop_hook_active = $false }
}
$r = Test-Answer 'Headings in #1F4E79, totals in #C00000.'
Check 'hex colours are not part numbers' (-not $r.out) $r.out
$r = Test-Answer 'Use a 24VDC supply, 4-20MA signal, 3C-14AWG cable, rated to CSA-C22. Quote Q-2026-014.'
Check 'units, cable sizes, standards and quote numbers pass' (-not $r.out) $r.out
$r = Test-Answer 'I checked it: use the QO120PCAFI.'
Check 'a lower-case "checked" is not a source' ($r.out -match 'QO120PCAFI')
$search = @{ type = 'assistant'; message = @{ role = 'assistant'; content = @(@{ type = 'tool_use'; id = 't2'; name = 'WebSearch'; input = @{ query = 'QO120PCAFI datasheet' } }) } }
$noRes = @{ type = 'user'; message = @{ role = 'user'; content = @(@{ type = 'tool_result'; tool_use_id = 't2'; content = 'No results found.' }) } }
$r = Test-Answer 'Use the QO120PCAFI.' @($search, $noRes)
Check "Claude's own search words don't count as a source" ($r.out -match 'QO120PCAFI')
$pdfRead = @{ type = 'user'; message = @{ role = 'user'; content = @(@{ type = 'tool_result'; tool_use_id = 't1'; content = @(@{ type = 'document'; source = @{ type = 'base64'; data = 'JVBERi0=' } }) }) } }
$r = Test-Answer 'The panel schedule lists the HOM2040M100PC.' @($toolUse, $pdfRead)
Check 'trusts numbers read from a PDF this turn' (-not $r.out) $r.out
Write-Transcript $tr @($user)
$r = Invoke-Hook 'source-guard.ps1' @{ session_id = 'g3'; transcript_path = $tr; stop_hook_active = $false; last_assistant_message = 'Order the QO120PCAFI.' }
Check 'uses last_assistant_message when it is given' ($r.out -match 'QO120PCAFI')

Write-Host "installer"
$inst = Join-Path $repo 'installer\files\install.ps1'
$cfg = Join-Path $work 'cfg'
New-Item -ItemType Directory -Force $cfg | Out-Null
$broken = "{`n  `"model`": `"sonnet`",`n  `"env`": { `"X`": `"1`" },`n}"
[IO.File]::WriteAllText("$cfg\settings.json", $broken)
$p = Start-Process powershell.exe -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$inst`"", '-ConfigDir', "`"$cfg`"", '-SkipTools', '-MarketplaceDir', "`"$repo`"") -Wait -PassThru -WindowStyle Hidden
Check 'refuses to touch a settings file it cannot read' ($p.ExitCode -eq 1 -and [IO.File]::ReadAllText("$cfg\settings.json") -eq $broken) "exit $($p.ExitCode)"

$mixed = @'
{ "hooks": { "Stop": [ { "hooks": [
  { "type": "command", "command": "powershell.exe -File C:/Users/x/.claude/hooks/source-guard.ps1" },
  { "type": "command", "command": "echo his-own-hook" } ] } ] },
  "permissions": { "allow": null },
  "enabledPlugins": { "spark@spark": true },
  "extraKnownMarketplaces": { "spark": { "source": { "source": "git", "url": "https://github.com/Aer0o/spark-kit.git" } } } }
'@
[IO.File]::WriteAllText("$cfg\settings.json", $mixed)
$p = Start-Process powershell.exe -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$inst`"", '-ConfigDir', "`"$cfg`"", '-SkipTools', '-MarketplaceDir', "`"$repo`"") -Wait -PassThru -WindowStyle Hidden
$s = Get-Content "$cfg\settings.json" -Raw | ConvertFrom-Json
$stopCmds = @($s.hooks.Stop | ForEach-Object { $_.hooks } | ForEach-Object { $_.command })
Check 'keeps his own hook that shared a group with a SPARK 1 hook' ($stopCmds -contains 'echo his-own-hook' -and -not ($stopCmds -match 'source-guard')) ($stopCmds -join ' | ')
Check 'an empty allow list becomes a clean list' ($p.ExitCode -eq 0 -and @($s.permissions.allow | Where-Object { $null -eq $_ }).Count -eq 0 -and @($s.permissions.allow).Count -gt 5)
Check 'turns Foreman on' ($s.enabledPlugins.'foreman@foreman' -eq $true)
Check 'switches off the kit under its old SPARK name' (-not $s.enabledPlugins.PSObject.Properties['spark@spark'] -and -not $s.extraKnownMarketplaces.PSObject.Properties['spark'])
Check 'pulls Foreman over HTTPS, not SSH' ($s.extraKnownMarketplaces.foreman.source.source -eq 'directory' -or $s.extraKnownMarketplaces.foreman.source.url -like 'https://*')
Check 'sets the Pro-plan savings' ($s.autoCompactWindow -eq 200000 -and $s.promptSuggestionEnabled -eq $false -and $s.disableBundledSkills -eq $true -and $s.modelSettings.'claude-opus-5-5'.effortLevel -eq 'high' -and $s.env.CLAUDE_CODE_DISABLE_EXPLORE_PLAN_AGENTS -eq '1' -and @($s.permissions.deny) -contains 'NotebookEdit')

$cfg2 = Join-Path $work 'cfg2'
New-Item -ItemType Directory -Force "$cfg2\spark" | Out-Null
Set-Content "$cfg2\spark\profile.md" "# Company profile`n- Legal name: Test Electric Ltd." -Encoding UTF8
Set-Content "$cfg2\spark\voice.md" "<!-- SPARK:BLANK -->" -Encoding UTF8
$p = Start-Process powershell.exe -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$inst`"", '-ConfigDir', "`"$cfg2`"", '-SkipTools', '-MarketplaceDir', "`"$repo`"") -Wait -PassThru -WindowStyle Hidden
Check 'carries a SPARK 2 test install over to the foreman folder' ((Select-String "$cfg2\foreman\profile.md" -Pattern 'Test Electric' -Quiet) -and (Select-String -Path "$cfg2\foreman\voice.md" -Pattern 'FOREMAN:BLANK' -SimpleMatch -Quiet) -and -not (Test-Path "$cfg2\spark"))
$cfg3 = Join-Path $work 'cfg3'
New-Item -ItemType Directory -Force "$cfg3\spark\backups", "$cfg3\foreman" | Out-Null
Set-Content "$cfg3\spark\profile.md" "# Company profile`n- Legal name: Old Name Ltd." -Encoding UTF8
Set-Content "$cfg3\spark\backups\2026-11-01_120000_quote.docx" 'x'
Set-Content "$cfg3\foreman\profile.md" "<!-- FOREMAN:BLANK -->" -Encoding UTF8
Set-Content "$cfg3\foreman\voice.md" "- Greeting: Hi folks" -Encoding UTF8
Set-Content "$cfg3\spark\voice.md" "- Greeting: OLD" -Encoding UTF8
$p = Start-Process powershell.exe -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$inst`"", '-ConfigDir', "`"$cfg3`"", '-SkipTools', '-MarketplaceDir', "`"$repo`"") -Wait -PassThru -WindowStyle Hidden
Check 'fills a blank foreman profile from the old folder, keeps his filled voice, merges backups' ((Select-String "$cfg3\foreman\profile.md" -Pattern 'Old Name' -Quiet) -and (Select-String "$cfg3\foreman\voice.md" -Pattern 'Hi folks' -Quiet) -and (Test-Path "$cfg3\foreman\backups\2026-11-01_120000_quote.docx"))

$own = '{ "autoCompactWindow": 500000, "modelSettings": { "claude-opus-5-5": { "effortLevel": "xhigh" } } }'
[IO.File]::WriteAllText("$cfg\settings.json", $own)
$p = Start-Process powershell.exe -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$inst`"", '-ConfigDir', "`"$cfg`"", '-SkipTools', '-MarketplaceDir', "`"$repo`"") -Wait -PassThru -WindowStyle Hidden
$s = Get-Content "$cfg\settings.json" -Raw | ConvertFrom-Json
Check 'keeps his own effort and compaction choices' ($s.autoCompactWindow -eq 500000 -and $s.modelSettings.'claude-opus-5-5'.effortLevel -eq 'xhigh' -and $s.modelSettings.'claude-opus-5-5'.autoCompactWindow -eq 200000)

$log = Join-Path $env:FOREMAN_HOME 'hook-errors.log'
Check 'no hook logged an error' (-not (Test-Path $log)) $(if (Test-Path $log) { Get-Content $log -Raw })

Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
Write-Host ""
Write-Host "$script:pass passed, $script:fail failed"
if ($script:fail -gt 0) { exit 1 }
