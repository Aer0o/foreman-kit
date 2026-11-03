# WORKLOG: SPARK

## 2026-11-03 · Full model runs with SPARK loaded

- **How:** `claude -p --plugin-dir plugins/spark --setting-sources local` with a test profile (Northline Electric,
  #1F4E79). Oleg's own settings and hooks were off. The CLI needed `claude auth login` first.
- **Report from site notes:**
  - It picked report-writer, said "SPARK is ready", and produced a clean one-page report with letterhead, brand
    colour, summary first and `[NEEDS]` in yellow.
  - It caught 6 spares against 10 new circuits without changing the figures.
  - It cost 47 turns / $3.15 because of five render-fix rounds, and it added two commitments he never made.
  - Fixed: at most two render rounds (in rules.md, report-writer, doc-design, doc-edit and chart-craft), and a
    "no words in his mouth" rule with `[SUGGEST: ...]`.
- **Part number:** spec-lookup found QO120CAFI on Schneider's Canadian page and data sheet, with every value
  CHECKED and linked. It said which pack variant the CSA line came from. 19 turns / $1.43.
- **3-slide deck from the report:** each title states the point, one accent colour, numbers only from the report,
  `[NEEDS: date]` kept. 23 turns / $1.57.
- **PDF schedule to Excel:** picked doc-to-excel and extracted 5 rows. Numbers are numeric, totals are formulas
  (54 fixtures, 1,462 W, checked by hand), there's a Source column, freeze and filter are on, and the answer
  says the totals are its own math. 24 turns / $1.65.
- **Hooks:** no hook errors in any run and no tools missing. No backups were taken because the test folder is
  under %TEMP%, which file-guard skips by design; the unit tests cover backups.
- **Not covered:** the desktop app on his PC, Anthropic's own docx/pptx skills (not loaded with
  `--setting-sources local`, so Claude used python-docx/python-pptx directly), and the Plain Office style
  (init still reports `default`, though the replies read plain).

## 2026-11-03 · SPARK 2 built

- **Why:** Oleg's estimator friend uses Claude Code (Windows desktop app, Pro) mostly for documents. The
  July v1 kit was lost from Oleg's PC, so v2 was rebuilt from its memory note. It is now an auto-updating
  plugin instead of loose `~/.claude` files.
- **Built:**
  - 12 skills, 4 PowerShell hooks, the Plain Office output style (forced on while the plugin is
    enabled), and defaults for profile, voice, doc style and a 98-item missed-scope checklist.
  - The installer, with Install / Fix / Uninstall `.bat` files, his two text guides and 40 hook tests.
- **Decisions:**
  - **Anthropic's docx/pdf/pptx/xlsx skills:** not bundled, because their licence is proprietary. His
    desktop app normally syncs them. When they are missing, the installer switches on Anthropic's own
    `document-skills` plugin, so he never runs two copies.
  - **No `version` in plugin.json:** each commit becomes an update for him.
  - **His data lives in `~/.claude/spark/`,** outside the plugin, so updates never overwrite it.
- **Code review (11 findings, all fixed, regression test for each):**
  - Old documents' backups were pruned the next day: `Copy-Item` keeps the file date.
  - An unparseable settings.json was silently replaced.
  - A locked state file skipped the delete prompt.
  - Delete prompt problems:
    - A temp folder anywhere in a command hid real deletes.
    - It nagged on "Kennedy Rd" and on `del wb['Sheet']`.
  - Git Bash, `$env:` and temp-script paths weren't backed up.
  - Source-guard problems:
    - It blocked hex colours, electrical units and quote numbers.
    - Claude's own search words counted as a source.
  - "I forgot to attach" wrote to the checklist.
  - CLAUDE.md notes were lost in the migration.
  - User PATH was written as REG_SZ.
- **Found while testing:**
  - The `github` marketplace source clones over SSH and fails on a PC without keys, so both marketplaces now use
    `git` + HTTPS.
  - `File.Replace(..., $null)` fails in PS 5.1, because PowerShell passes `$null` as `""`. Fixed with
    `[NullString]::Value`.
  - Pushes failed silently: Git Credential Manager stores credentials per path, so this repo has none. This
    repo now uses the gh credential helper locally.
- **Checked:**
  - 61/61 hook and installer tests pass.
  - A real installer run on Oleg's PC installed LibreOffice, Pandoc, Poppler, QPDF and Tesseract, and every
    self-test passed.
  - `claude -p --plugin-dir` loads all 12 skills and the SessionStart hook fires.
  - A clean config installs `spark@spark` from GitHub over HTTPS, and a push updated it from 76cdab19de4a
    to d19feacdd634.
- **Not checked:**
  - A full model run: the CLI on Oleg's PC isn't logged in.
  - The desktop app installing the plugin from settings alone.
  - Anything on the friend's PC.
- **Earlier checks:**
  - 40/40 hook tests pass.
  - `claude plugin validate` passes, with the expected warning about the missing version.
  - The v1 migration was run on a fake v1 layout. It kept his profile and checklist, removed the old
    hooks, and left his own skill and hook alone. A second run was idempotent.
