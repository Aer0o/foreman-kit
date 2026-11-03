# SPARK installer. Run through "Install SPARK.bat", "Fix SPARK.bat" or "Uninstall SPARK.bat".
# Safe to run again: it only adds what is missing and never overwrites his own SPARK files.
# Pure ASCII on purpose (Windows PowerShell 5.1 reads BOM-less scripts as ANSI).

param(
    [string]$ConfigDir = (Join-Path $env:USERPROFILE '.claude'),
    [string]$MarketplaceRepo = 'Aer0o/spark-kit',
    [string]$MarketplaceDir = '',      # tests: a local folder instead of GitHub
    [switch]$SkipTools,                # tests: config only
    [switch]$Yes,                      # don't ask before installing programs
    [switch]$Uninstall
)

# 'Continue', not 'Stop': in PowerShell 5.1 a native tool writing to stderr would otherwise abort the script.
$ErrorActionPreference = 'Continue'
# PowerShell 5.1 otherwise writes some arrays as {"value":[...],"Count":n} in settings.json.
Remove-TypeData System.Array -ErrorAction SilentlyContinue
$SparkHome = Join-Path $ConfigDir 'spark'
$SettingsPath = Join-Path $ConfigDir 'settings.json'
$Stamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$Report = New-Object System.Collections.Generic.List[string]
$Utf8 = New-Object Text.UTF8Encoding $false

function Say([string]$text, [string]$color = 'Gray') { Write-Host $text -ForegroundColor $color; $Report.Add($text) }
function Ok([string]$text) { Say "  [ OK ] $text" 'Green' }
function Bad([string]$text) { Say "  [FAIL] $text" 'Red' }
function Note([string]$text) { Say "  ...... $text" 'Gray' }

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

# Edits his user PATH in the registry as written, so entries like %USERPROFILE%\bin stay unexpanded
# and the value stays REG_EXPAND_SZ.
function Add-UserPath([string]$dir, [switch]$Front) {
    if (-not $dir -or -not (Test-Path $dir)) { return }
    $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
    $user = [string]$key.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
    $same = { param($entry) [Environment]::ExpandEnvironmentVariables($entry).TrimEnd('\') -ieq $dir.TrimEnd('\') }
    $entries = @($user -split ';' | Where-Object { $_ })
    if (-not $Front -and ($entries | Where-Object { & $same $_ })) { $key.Close(); return }
    $rest = @($entries | Where-Object { -not (& $same $_) })
    if ($Front) { $entries = @($dir) + $rest } else { $entries = $rest + @($dir) }
    $key.SetValue('Path', ($entries -join ';'), [Microsoft.Win32.RegistryValueKind]::ExpandString)
    $key.Close()
    # Tell Windows the environment changed, so Claude sees the new PATH when it restarts.
    [Environment]::SetEnvironmentVariable('SPARK_PATH_REFRESH', '1', 'User')
    [Environment]::SetEnvironmentVariable('SPARK_PATH_REFRESH', $null, 'User')
    Refresh-Path
}

function Parent([string]$path) { if ($path) { return (Split-Path -Parent $path) } return $null }

function Find-First([string[]]$patterns) {
    foreach ($p in $patterns) {
        $hit = Get-ChildItem -Path $p -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($hit) { return $hit.FullName }
    }
    return $null
}

# ---------------------------------------------------------------- settings.json helpers
# Returns $null when the file exists but can't be read, so the caller stops instead of replacing it.
function Read-Settings {
    if (Test-Path $SettingsPath) {
        try {
            $raw = [IO.File]::ReadAllText($SettingsPath)
            if ($raw.Trim()) { return ($raw | ConvertFrom-Json -ErrorAction Stop) }
        } catch {
            return $null
        }
    }
    return New-Object PSObject
}

function Stop-UnreadableSettings {
    Bad "Claude's settings file could not be read, so SPARK changed nothing in it:"
    Bad "  $SettingsPath"
    Bad 'Send this message to whoever gave you SPARK.'
    try {
        New-Item -ItemType Directory -Force $SparkHome | Out-Null
        $header = @("SPARK install report $Stamp", '')
        [IO.File]::WriteAllLines((Join-Path $SparkHome 'install-report.txt'), [string[]]($header + $Report), $Utf8)
    } catch { }
    exit 1
}

function Write-Settings($obj) {
    if (-not (Test-Path $ConfigDir)) { New-Item -ItemType Directory -Force $ConfigDir | Out-Null }
    [IO.File]::WriteAllText($SettingsPath, ($obj | ConvertTo-Json -Depth 20), $Utf8)
}

function Get-Child($obj, [string]$name) {
    if (-not $obj.PSObject.Properties[$name]) { $obj | Add-Member -NotePropertyName $name -NotePropertyValue (New-Object PSObject) }
    return $obj.$name
}

function Set-Prop($obj, [string]$name, $value) {
    if ($obj.PSObject.Properties[$name]) { $obj.$name = $value } else { $obj | Add-Member -NotePropertyName $name -NotePropertyValue $value }
}

function Remove-Prop($obj, [string]$name) {
    if ($obj -and $obj.PSObject.Properties[$name]) { $obj.PSObject.Properties.Remove($name) }
}

function Add-ToList($obj, [string]$name, [string[]]$items) {
    $list = @()
    if ($obj.PSObject.Properties[$name] -and $null -ne $obj.$name) { $list = @($obj.$name | Where-Object { $null -ne $_ }) }
    foreach ($i in $items) { if ($list -notcontains $i) { $list += $i } }
    Set-Prop $obj $name ([object[]]$list)
}

# ---------------------------------------------------------------- uninstall
if ($Uninstall) {
    Say "Removing SPARK from Claude..." 'Cyan'
    if (Test-Path $SettingsPath) {
        Copy-Item $SettingsPath (Join-Path $ConfigDir "settings.before-uninstall-$Stamp.json")
        $s = Read-Settings
        if ($null -eq $s) { Stop-UnreadableSettings }
        Remove-Prop $s.extraKnownMarketplaces 'spark'
        Remove-Prop $s.enabledPlugins 'spark@spark'
        Write-Settings $s
    }
    Ok 'SPARK is switched off. Close Claude fully and open it again.'
    Note "Your company profile, writing notes and backups are still in $SparkHome"
    Note 'The programs SPARK installed (LibreOffice and the rest) were left in place.'
    exit 0
}

Say ''
Say '  SPARK setup' 'Cyan'
Say '  This sets up Claude for your documents. It takes 5 to 15 minutes.' 'Cyan'
Say ''

# ---------------------------------------------------------------- 1. programs
$tools = @(
    @{ name = 'Git';         id = 'Git.Git';                     test = { [bool](Get-Command git -ErrorAction SilentlyContinue) } }
    @{ name = 'Python';      id = 'Python.Python.3.12';          test = { [bool](Find-First @("$env:LOCALAPPDATA\Programs\Python\Python3*\python.exe", "$env:ProgramFiles\Python3*\python.exe")) } }
    @{ name = 'Node.js';     id = 'OpenJS.NodeJS.LTS';           test = { [bool](Get-Command node -ErrorAction SilentlyContinue) } }
    @{ name = 'LibreOffice'; id = 'TheDocumentFoundation.LibreOffice'; test = { Test-Path "$env:ProgramFiles\LibreOffice\program\soffice.exe" } }
    @{ name = 'Pandoc';      id = 'JohnMacFarlane.Pandoc';       test = { [bool]((Get-Command pandoc -ErrorAction SilentlyContinue) -or (Find-First @("$env:LOCALAPPDATA\Pandoc\pandoc.exe", "$env:ProgramFiles\Pandoc\pandoc.exe"))) } }
    @{ name = 'Poppler';     id = 'oschwartz10612.Poppler';      test = { [bool]((Get-Command pdftoppm -ErrorAction SilentlyContinue) -or (Find-First @("$env:LOCALAPPDATA\Microsoft\WinGet\Packages\oschwartz10612.Poppler*\poppler-*\Library\bin\pdftoppm.exe"))) } }
    @{ name = 'QPDF';        id = 'QPDF.QPDF';                   test = { [bool]((Get-Command qpdf -ErrorAction SilentlyContinue) -or (Find-First @("$env:ProgramFiles\qpdf*\bin\qpdf.exe"))) } }
    @{ name = 'Tesseract';   id = 'UB-Mannheim.TesseractOCR';    test = { Test-Path "$env:ProgramFiles\Tesseract-OCR\tesseract.exe" } }
)

if (-not $SkipTools) {
    Say 'Step 1 of 4: programs Claude needs for Word, PDF, Excel and PowerPoint' 'White'
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Bad 'Windows Package Manager (winget) is missing. Open the Microsoft Store, install "App Installer", then run this again.'
        exit 1
    }
    $missing = @($tools | Where-Object { -not (& $_.test) })
    if ($missing.Count -eq 0) {
        Ok 'All programs are already installed.'
    } else {
        Say ('  To install: ' + (($missing | ForEach-Object { $_.name }) -join ', '))
        Say '  Windows may ask "Do you want to allow this app to make changes?" a few times. Click Yes.'
        Say '  Some of these are big downloads. The window may sit still for a few minutes; leave it open.'
        $go = $true
        if (-not $Yes) { $go = (Read-Host '  Install them now? (Y/N)') -match '^[Yy]' }
        if (-not $go) { Bad 'Skipped. Word, PDF, Excel and PowerPoint work will not run until these are installed.' }
        else {
            foreach ($t in $missing) {
                Note "Installing $($t.name)..."
                winget install --id $t.id -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity | Out-Null
                Refresh-Path
                if (& $t.test) { Ok $t.name } else { Bad "$($t.name) did not install. Run Fix SPARK later to try again." }
            }
        }
    }

    # Put the program folders on PATH so Claude can call them by name.
    Add-UserPath "$env:ProgramFiles\LibreOffice\program"
    Add-UserPath (Parent (Find-First @("$env:LOCALAPPDATA\Microsoft\WinGet\Packages\oschwartz10612.Poppler*\poppler-*\Library\bin\pdftoppm.exe")))
    Add-UserPath (Parent (Find-First @("$env:ProgramFiles\qpdf*\bin\qpdf.exe")))
    Add-UserPath "$env:ProgramFiles\Tesseract-OCR"
    Add-UserPath (Parent (Find-First @("$env:LOCALAPPDATA\Pandoc\pandoc.exe", "$env:ProgramFiles\Pandoc\pandoc.exe")))

    # The real Python must come before the Microsoft Store stand-in, which only opens the Store.
    $py = Find-First @("$env:LOCALAPPDATA\Programs\Python\Python312\python.exe", "$env:LOCALAPPDATA\Programs\Python\Python3*\python.exe", "$env:ProgramFiles\Python3*\python.exe")
    if ($py) {
        Add-UserPath (Join-Path (Parent $py) 'Scripts') -Front
        Add-UserPath (Parent $py) -Front
        $ver = Split-Path -Leaf (Parent $py)
        New-Item -ItemType Directory -Force "$env:APPDATA\Python\$ver\Scripts" | Out-Null
        Add-UserPath "$env:APPDATA\Python\$ver\Scripts"
    }

    Say ''
    Say 'Step 2 of 4: add-ons for those programs' 'White'
    if ($py) {
        $pkgs = @('openpyxl', 'pandas', 'python-docx', 'python-pptx', 'pypdf', 'pdfplumber', 'reportlab', 'Pillow',
                  'lxml', 'defusedxml', 'markitdown', 'pytesseract', 'pdf2image', 'pypdfium2')
        & $py -m pip install --user --upgrade --disable-pip-version-check --quiet @pkgs 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Ok 'Python add-ons' } else { Bad 'Python add-ons did not all install. Run Fix SPARK to try again.' }
    } else { Bad 'Python is missing, so its add-ons were skipped.' }

    $npm = Get-Command npm.cmd -ErrorAction SilentlyContinue
    if ($npm) {
        & $npm.Source install -g --silent docx pptxgenjs 2>&1 | Out-Null
        $npmOk = ($LASTEXITCODE -eq 0)
        $root = (& $npm.Source root -g).Trim()
        [Environment]::SetEnvironmentVariable('NODE_PATH', $root, 'User')
        $env:NODE_PATH = $root
        if ($npmOk) { Ok 'Node add-ons' } else { Bad 'Node add-ons did not install. Run Fix SPARK to try again.' }
    } else { Bad 'Node.js is missing, so its add-ons were skipped.' }
    Say ''
}

# ---------------------------------------------------------------- 2. SPARK 1 clean-up
Say 'Step 3 of 4: moving your old SPARK setup over' 'White'
if (-not (Test-Path $SparkHome)) { New-Item -ItemType Directory -Force $SparkHome | Out-Null }
$v1Backup = Join-Path $SparkHome "spark1-backup-$Stamp"
$v1Items = @(
    'CLAUDE.md', 'company-profile.md',
    'skills\tender-review', 'skills\quote-check', 'skills\doc-to-excel', 'skills\spec-lookup', 'skills\client-email',
    'hooks\session-start.ps1', 'hooks\prompt-router.ps1', 'hooks\source-guard.ps1'
)
$moved = 0
foreach ($rel in $v1Items) {
    $src = Join-Path $ConfigDir $rel
    if (-not (Test-Path $src)) { continue }
    if ($rel -eq 'CLAUDE.md') {
        if (-not (Select-String -Path $src -Pattern 'SPARK' -CaseSensitive -Quiet)) { continue }
        # SPARK 1 wrote this file, but Claude may have added things he asked it to remember. Keep them where SPARK 2 looks.
        Copy-Item $src (Join-Path $SparkHome 'spark1-notes.md') -Force
        Ok 'Kept your notes from SPARK 1'
    }
    if ($rel -eq 'hooks\session-start.ps1' -and -not (Select-String -Path $src -Pattern 'company-profile' -Quiet)) { continue }
    if ($rel -eq 'hooks\prompt-router.ps1' -and -not (Select-String -Path $src -Pattern 'tender|quote' -Quiet)) { continue }
    if ($rel -eq 'hooks\source-guard.ps1' -and -not (Select-String -Path $src -Pattern 'catalog|part' -Quiet)) { continue }

    # Keep what he taught SPARK 1: a filled-in profile and his checklist.
    if ($rel -eq 'company-profile.md') {
        $filled = @(Select-String -Path $src -Pattern ':\s*\S' -ErrorAction SilentlyContinue).Count
        $newProfile = Join-Path $SparkHome 'profile.md'
        $newIsBlank = (-not (Test-Path $newProfile)) -or (Select-String -Path $newProfile -SimpleMatch 'SPARK:BLANK' -Quiet)
        if ($filled -ge 3 -and $newIsBlank) { Copy-Item $src $newProfile -Force; Ok 'Kept your company profile' }
    }
    if ($rel -eq 'skills\tender-review') {
        $old = Get-ChildItem $src -Recurse -Filter '*checklist*' -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($old) { Copy-Item $old.FullName (Join-Path $SparkHome 'checklist-spark1.md') -Force; Ok 'Kept your old tender checklist' }
    }

    $dest = Join-Path $v1Backup $rel
    New-Item -ItemType Directory -Force (Split-Path -Parent $dest) | Out-Null
    Move-Item $src $dest -Force
    $moved++
}

$settings = Read-Settings
if ($null -eq $settings) { Stop-UnreadableSettings }
if (Test-Path $SettingsPath) { Copy-Item $SettingsPath (Join-Path $SparkHome "settings.before-spark2-$Stamp.json") }
# Drop SPARK 1's hook entries; the plugin brings its own.
if ($settings.PSObject.Properties['hooks']) {
    foreach ($evt in @($settings.hooks.PSObject.Properties.Name)) {
        $groups = @()
        foreach ($g in @($settings.hooks.$evt)) {
            $keep = @($g.hooks | Where-Object {
                $c = "$($_.command) $(@($_.args) -join ' ')"
                $c -notmatch '[\\/]\.claude[\\/]hooks[\\/](session-start|prompt-router|source-guard)\.ps1'
            })
            if ($keep.Count -lt @($g.hooks).Count) { $moved++ }
            if ($keep.Count -gt 0) { Set-Prop $g 'hooks' ([object[]]$keep); $groups += $g }
        }
        if ($groups.Count -eq 0) { Remove-Prop $settings.hooks $evt }
        else { Set-Prop $settings.hooks $evt ([object[]]$groups) }
    }
    if (@($settings.hooks.PSObject.Properties).Count -eq 0) { Remove-Prop $settings 'hooks' }
}
if ($moved -gt 0) { Ok "Old SPARK files moved to $v1Backup" } else { Ok 'No old SPARK files to move' }
Say ''

# ---------------------------------------------------------------- 3. Claude settings
Say 'Step 4 of 4: switching SPARK on in Claude' 'White'
$markets = Get-Child $settings 'extraKnownMarketplaces'
if ($MarketplaceDir) {
    Set-Prop $markets 'spark' ([pscustomobject]@{ source = [pscustomobject]@{ source = 'directory'; path = $MarketplaceDir } })
} else {
    Set-Prop $markets 'spark' ([pscustomobject]@{ source = [pscustomobject]@{ source = 'git'; url = "https://github.com/$MarketplaceRepo.git" }; autoUpdate = $true })
}
$plugins = Get-Child $settings 'enabledPlugins'
Set-Prop $plugins 'spark@spark' $true

# Both marketplaces use plain HTTPS git URLs: the 'github' source type clones over SSH, which fails on a PC
# with no GitHub keys.
# Anthropic's Word/PDF/PowerPoint/Excel skills: the desktop app usually brings them with his account.
# Only when they aren't there do we switch on Anthropic's own copy, so he never has two.
$accountSkills = Find-First @("$env:LOCALAPPDATA\Claude-Data\*\local-agent-mode-sessions\skills-plugin\*\*\skills\docx\SKILL.md")
if ($accountSkills) {
    Ok 'Word, PDF, PowerPoint and Excel skills: already in your Claude app'
} else {
    Set-Prop $markets 'anthropic-agent-skills' ([pscustomobject]@{ source = [pscustomobject]@{ source = 'git'; url = 'https://github.com/anthropics/skills.git' }; autoUpdate = $true })
    Set-Prop $plugins 'document-skills@anthropic-agent-skills' $true
    Ok "Word, PDF, PowerPoint and Excel skills: switched on Anthropic's copy"
}

$perm = Get-Child $settings 'permissions'
if (-not $perm.PSObject.Properties['defaultMode']) { Set-Prop $perm 'defaultMode' 'acceptEdits' }
Add-ToList $perm 'allow' @(
    'PowerShell(Get-ChildItem *)', 'PowerShell(Get-Content *)', 'PowerShell(Test-Path *)', 'PowerShell(Get-Item *)',
    'PowerShell(python *)', 'PowerShell(py *)', 'PowerShell(node *)', 'PowerShell(soffice *)', 'PowerShell(pdftoppm *)',
    'PowerShell(pdftotext *)', 'PowerShell(pandoc *)', 'PowerShell(qpdf *)', 'PowerShell(tesseract *)',
    'Bash(python *)', 'Bash(node *)', 'Bash(soffice *)', 'Bash(pdftoppm *)', 'Bash(pdftotext *)', 'Bash(pandoc *)',
    'WebSearch', 'WebFetch'
)
Add-ToList $perm 'deny' @('Read(**/.env)', 'Read(**/.env.*)', 'Read(**/*password*)', 'Read(**/*.kdbx)', 'NotebookEdit')

# Pro plan: every tool call re-reads the whole chat, so keep chats short and drop what a document user never
# needs. Each value is set only when he hasn't chosen one himself; the effort picker in the app still wins.
function Set-Default($obj, [string]$name, $value) { if (-not $obj.PSObject.Properties[$name]) { Set-Prop $obj $name $value } }
Set-Default $settings 'autoCompactWindow' 200000
Set-Default $settings 'promptSuggestionEnabled' $false
Set-Default $settings 'disableBundledSkills' $true
$modelSettings = Get-Child $settings 'modelSettings'
$opus = Get-Child $modelSettings 'claude-opus-5-5'
Set-Default $opus 'effortLevel' 'high'
Set-Default $opus 'autoCompactWindow' 200000
$envVars = Get-Child $settings 'env'
Set-Default $envVars 'CLAUDE_CODE_DISABLE_EXPLORE_PLAN_AGENTS' '1'
Write-Settings $settings
Ok 'SPARK is switched on and will update itself'
Say ''

# ---------------------------------------------------------------- 4. self-test
if (-not $SkipTools) {
    Say 'Checking that everything works...' 'White'
    $t = Join-Path $env:TEMP "spark-selftest-$Stamp"
    New-Item -ItemType Directory -Force $t | Out-Null
    $pyCode = @"
import sys, docx, openpyxl, pptx
d = docx.Document(); d.add_heading('SPARK test', 1); d.add_paragraph('If you can read this, Word files work.'); d.save(sys.argv[1] + r'\test.docx')
wb = openpyxl.Workbook(); ws = wb.active; ws['A1'] = 2; ws['A2'] = 3; ws['A3'] = '=A1*A2'; wb.save(sys.argv[1] + r'\test.xlsx')
p = pptx.Presentation(); s = p.slides.add_slide(p.slide_layouts[0]); s.shapes.title.text = 'SPARK test'; p.save(sys.argv[1] + r'\test.pptx')
print('ok')
"@
    [IO.File]::WriteAllText("$t\make.py", $pyCode, $Utf8)
    $nodeCode = "require('docx'); require('pptxgenjs'); console.log('ok');"
    [IO.File]::WriteAllText("$t\check.js", $nodeCode, $Utf8)

    function Run-Check([string]$label, [scriptblock]$block) {
        try { if (& $block) { Ok $label } else { Bad $label } } catch { Bad "$label ($($_.Exception.Message))" }
    }
    Run-Check 'Make Word, Excel and PowerPoint files' { $py -and ((& $py "$t\make.py" $t 2>&1) -match 'ok') }
    Run-Check 'Node add-ons load' { (node "$t\check.js" 2>&1) -match 'ok' }
    Run-Check 'Turn Word into PDF' {
        & soffice --headless --convert-to pdf --outdir $t "$t\test.docx" 2>&1 | Out-Null
        Test-Path "$t\test.pdf"
    }
    Run-Check 'Preview PDF pages as pictures' {
        & pdftoppm -png -r 50 -f 1 -l 1 "$t\test.pdf" "$t\page" 2>&1 | Out-Null
        [bool](Get-ChildItem $t -Filter 'page*.png')
    }
    Run-Check 'Excel formulas calculate' {
        & soffice --headless --convert-to csv --outdir $t "$t\test.xlsx" 2>&1 | Out-Null
        (Test-Path "$t\test.csv") -and ((Get-Content "$t\test.csv" -Raw) -match '\b6\b')
    }
    Run-Check 'Turn PowerPoint into PDF' {
        Remove-Item "$t\test.pdf" -ErrorAction SilentlyContinue
        & soffice --headless --convert-to pdf --outdir $t "$t\test.pptx" 2>&1 | Out-Null
        Test-Path "$t\test.pdf"
    }
    Run-Check 'Pandoc' { [bool](Get-Command pandoc -ErrorAction SilentlyContinue) }
    Run-Check 'Read scanned pages (Tesseract)' { [bool](Get-Command tesseract -ErrorAction SilentlyContinue) }
    Remove-Item $t -Recurse -Force -ErrorAction SilentlyContinue
    Say ''
}

$failed = @($Report | Where-Object { $_.Contains('[FAIL]') }).Count
$reportPath = Join-Path $SparkHome 'install-report.txt'
$header = @("SPARK install report $Stamp", "Windows $([Environment]::OSVersion.Version)", '')
[IO.File]::WriteAllLines($reportPath, [string[]]($header + $Report), $Utf8)

if ($failed -eq 0) {
    Say '  All done.' 'Green'
} else {
    Say "  Finished with $failed problem(s). Send this file to whoever gave you SPARK:" 'Yellow'
    Say "  $reportPath" 'Yellow'
}
Say ''
Say '  IMPORTANT: quit Claude completely and open it again.' 'Cyan'
Say '  (Right-click the Claude icon by the clock, choose Quit, then start Claude.)' 'Cyan'
Say '  In the Code tab, pick a folder and make sure the session is set to Local.' 'Cyan'
Say ''
exit 0
