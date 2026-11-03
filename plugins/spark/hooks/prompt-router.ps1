# UserPromptSubmit: route plain English to the right SPARK skill, so he never has to type a command,
# and suggest a fresh chat once a conversation gets long.

. "$PSScriptRoot\common.ps1"

# First match wins per skill; at most two skills are suggested per prompt.
$Routes = @(
    @{ skill = 'spark-setup';    rx = '\bset ?up spark\b|\bspark (is )?(not|isn.t) working\b|\bcan.?t open (the |my |this )?(word|excel|pdf|powerpoint|file)|\bundo (that|the last)|\b(get|bring) (my |the )?(old|original|previous) (file|version|copy)|\brestore\b|\blearn how i write\b' }
    @{ skill = 'tender-review';  rx = '\btender|\baddend|\bbid (doc|package|set)|\bspec(ification)? section|\bdiv(ision)?\.? ?2[678]\b|\brfi\b|\bscope (gap|review)|\bmissed scope' }
    @{ skill = 'quote-check';    rx = '\b(check|review|look (at|over)|go over|double.?check)\b.{0,40}\b(my |the |this )?(quote|estimate|proposal price|pricing)\b|\bbefore i (send|submit)\b.{0,30}\bquote' }
    @{ skill = 'spec-lookup';    rx = '\bpart (number|no\.?|#)|\bcatalog(ue)? (number|no\.?|#)|\bmodel (number|no\.?)|\bdata ?sheet|\bspec ?sheet|\bcut ?sheet|\bcsa (approved|listed|certified)|\bcul\b|\bequivalent (to|for)\b' }
    @{ skill = 'doc-to-excel';   rx = '\b(into|to|in|as) (an? )?(excel|spreadsheet|xlsx)\b|\b(pull|extract|get|copy) (the |all )?(table|tables|list|schedule|quantities)\b|\bschedule (out of|from)\b' }
    @{ skill = 'report-writer';  rx = '\breport\b|\bwrite.?up\b|\bsummary of (the )?(job|project|site|visit)' }
    @{ skill = 'doc-design';     rx = '\blook(s)? (more )?(professional|better|nicer|clean|good)|\bformat(ting)?\b|\blayout\b|\bletterhead\b|\btemplate\b|\bbranding\b|\bmake it (look|pretty|nice)|\bstyle (it|this)\b|\bslides?\b|\bdeck\b|\bpresentation\b' }
    @{ skill = 'proofread';      rx = '\bproof ?read|\btypos?\b|\bspell(ing)? check|\bcheck (it|this|everything) before\b|\banything wrong with\b|\bready to send\b' }
    @{ skill = 'client-email';   rx = '\bemail\b|\be-mail\b|\bletter to\b|\breply to\b|\bwrite back\b|\brespond to (the |this |his |her )?(client|gc|contractor|customer|supplier|inspector)\b' }
    @{ skill = 'chart-craft';    rx = '\bchart\b|\bgraph\b|\bplot\b' }
    @{ skill = 'plain-writing';  rx = '\bsounds? (like )?(ai|a robot|robotic|chatgpt)|\btighten\b|\bless wordy\b|\bmore natural\b|\bsimplify (the )?(wording|text|language)|\bplain english\b' }
    @{ skill = 'doc-edit';       rx = '\b(edit|fix|change|update|revise|correct|rework)\b.{0,40}\b(doc|document|file|word|report|proposal|letter|contract|spreadsheet|sheet|slides?)\b' }
)

try {
    $hookIn = Read-HookInput
    if (-not $hookIn) { exit 0 }
    $prompt = [string]$hookIn.prompt
    $notes = New-Object System.Collections.Generic.List[string]

    $hits = @()
    foreach ($r in $Routes) {
        if ($hits.Count -ge 2) { break }
        if ($prompt -match $r.rx) { $hits += $r.skill }
    }
    if ($hits.Count -gt 0) {
        $names = ($hits | ForEach-Object { "spark:$_" }) -join ', '
        $notes.Add("SPARK: skill to use for this request: $names. Load it before you start.")
    }

    # Only a miss on a job or a bid, not 'I forgot to attach the drawings'.
    $missRx = '\b(we|i) (missed|forgot|left out|didn.t (carry|include|price))\b.{0,80}\b(job|tender|bid|quote|project|estimate|takeoff|scope)\b'
    if ($prompt -match $missRx -or $prompt -match '\badd .{1,80} to (the|my) checklist\b') {
        $notes.Add('SPARK: he may be reporting an item missed on a bid. If so, after helping, ask in one line whether to add it to his tender checklist (checklist.md in his SPARK folder); add it as a dated line only if he says yes or asked for it outright.')
    }

    # Long-chat nudge at 20, 40, 60 turns: long chats use his Pro limit faster and drift.
    $state = Get-State
    $turns = 0
    if ($state.sessionId -eq $hookIn.session_id -and $state.turns) { $turns = [int]$state.turns }
    $turns++
    Set-StateValue $state 'turns' $turns
    Set-StateValue $state 'sessionId' $hookIn.session_id
    $null = Save-State $state
    if ($turns -ge 20 -and ($turns % 20) -eq 0) {
        $notes.Add('SPARK: this chat is long. After answering, suggest in one line that he starts a new chat for the next job, because long chats use up his plan faster and get less accurate.')
    }

    if ($notes.Count -gt 0) { Add-Context 'UserPromptSubmit' ($notes -join "`n") }
} catch {
    try { Add-Content (Join-Path $SparkHome 'hook-errors.log') ("{0} prompt-router: {1}" -f (Get-Date -Format s), $_) } catch { }
}
exit 0
