# Stop: catch part or catalogue numbers in the final answer that appear nowhere in his messages or in
# anything Claude read this session, when the answer gives no source. Sends Claude back once to source
# them or mark them unconfirmed; never loops.

. "$PSScriptRoot\common.ps1"

# Upper-case letter+digit tokens such as QO120 or HOM2040M100PC, not preceded by # (hex colours).
$PartRx = '(?<![#\w-])(?=[A-Z0-9-]{5,24}\b)(?=(?:[A-Z0-9-]*[A-Z]){2})(?=(?:[A-Z-]*\d){2})[A-Z0-9]+(?:-[A-Z0-9]+)*\b'
# One part of a hyphenated token that is a number, a unit or a conductor count, never a part number.
$UnitPartRx = '^(?:\d+(?:V|VA|VAC|VDC|KV|KVA|A|AF|AT|AIC|KAIC|KA|MA|AMP|AMPS|W|KW|KWH|MW|HZ|AWG|MCM|KCMIL|MM|CM|M|IN|FT|LB|LBS|P|PH|PT|H|HR|HRS|MIN|S|C|F|K|ST|ND|RD|TH|X|G)?|C\d+|[A-Z]{1,3})$'
$IgnoreRx = '^(?:(?:HST|ESA|ECRA|ISO|IEC|CSA|NEMA|UL|ULC|IEEE|ANSI|NFPA|OESC|CEC|IP|NEC)[-\d].*|Q[1-4]-?\d{2,4}|FY\d+|COVID-?\d+|DIV-?\d+|(?:NMD|TECK|RWU|RW|TWU|TW|T|ACWU|AC|XHHW|THHN|THWN|NMWU|CAT)-?\d+[A-Z]?)$'
$SourceRx = 'https?://|\bCHECKED\b|\bNOT CONFIRMED\b|(?i:\bcouldn.t confirm\b|\b(?:page|pg\.?|p\.)\s*\d)'

function Get-ResultText($content) {
    if ($content -is [string]) { return $content }
    $out = @()
    foreach ($c in @($content)) {
        if ($c.type -eq 'text') { $out += [string]$c.text }
        elseif ($c.type -eq 'tool_result') { $out += (Get-ResultText $c.content) }
    }
    return ($out -join "`n")
}

function Test-ReadBinaryDoc($content) {
    foreach ($c in @($content)) {
        if ($c.type -eq 'image' -or $c.type -eq 'document') { return $true }
        if ($c.type -eq 'tool_result' -and $c.content -isnot [string] -and (Test-ReadBinaryDoc $c.content)) { return $true }
    }
    return $false
}

function Test-RealPrompt($entry) {
    if ($entry.type -ne 'user') { return $false }
    $content = $entry.message.content
    if ($content -is [string]) { return $true }
    foreach ($c in @($content)) { if ($c.type -eq 'text') { return $true } }
    return $false
}

function Test-NotPart([string]$tok) {
    if ($tok -match $IgnoreRx) { return $true }
    foreach ($seg in ($tok -split '-')) { if ($seg -notmatch $UnitPartRx) { return $false } }
    return $true
}

try {
    $hookIn = Read-HookInput
    if (-not $hookIn -or $hookIn.stop_hook_active) { exit 0 }
    $path = [string]$hookIn.transcript_path
    if (-not $path -or -not (Test-Path -LiteralPath $path)) { exit 0 }

    $entries = @()
    foreach ($line in @(Get-Content -LiteralPath $path -Tail 400 -Encoding UTF8)) {
        if (-not $line) { continue }
        try { $entries += ($line | ConvertFrom-Json) } catch { }
    }

    # This turn starts at his last real prompt; the answer is the text after the last tool result.
    $start = -1
    for ($i = $entries.Count - 1; $i -ge 0; $i--) { if (Test-RealPrompt $entries[$i]) { $start = $i; break } }
    if ($start -lt 0) { exit 0 }
    $lastTool = $start
    for ($i = $start + 1; $i -lt $entries.Count; $i++) { if ($entries[$i].type -eq 'user') { $lastTool = $i } }

    $answerText = [string]$hookIn.last_assistant_message
    if (-not $answerText) {
        $answer = @()
        for ($i = $lastTool + 1; $i -lt $entries.Count; $i++) {
            if ($entries[$i].type -eq 'assistant') {
                foreach ($c in @($entries[$i].message.content)) { if ($c.type -eq 'text') { $answer += [string]$c.text } }
            }
        }
        $answerText = $answer -join "`n"
    }
    if (-not $answerText -or $answerText -cmatch $SourceRx) { exit 0 }

    # Sources: only his own messages and what tools returned. Claude's own words and searches don't count.
    $known = @()
    $readBinary = $false
    for ($i = 0; $i -le $lastTool; $i++) {
        if ($entries[$i].type -ne 'user' -or -not $entries[$i].message) { continue }
        $known += (Get-ResultText $entries[$i].message.content)
        if ($i -gt $start -and (Test-ReadBinaryDoc $entries[$i].message.content)) { $readBinary = $true }
    }
    # A PDF or photo read this turn reaches Claude as an image, not text, so its numbers can't be matched.
    # The skills ask for page references there; don't second-guess them.
    if ($readBinary) { exit 0 }
    $knownText = ($known -join "`n").ToUpperInvariant()

    $unsourced = @()
    foreach ($m in [regex]::Matches($answerText, $PartRx)) {
        $tok = $m.Value
        if (Test-NotPart $tok) { continue }
        if ($knownText.Contains($tok)) { continue }
        if ($unsourced -notcontains $tok) { $unsourced += $tok }
    }
    if ($unsourced.Count -eq 0) { exit 0 }

    $list = ($unsourced | Select-Object -First 8) -join ', '
    Write-HookJson @{
        decision = 'block'
        reason = "SPARK source check: your answer gives part or catalogue numbers ($list) that are not in his messages or in anything you read, and it cites no source. For each one, either add the link or document page it comes from and mark it CHECKED, or mark it NOT CONFIRMED and tell him to check it with the supplier. Then give the corrected answer."
    }
} catch {
    try { Add-Content (Join-Path $SparkHome 'hook-errors.log') ("{0} source-guard: {1}" -f (Get-Date -Format s), $_) } catch { }
}
exit 0
