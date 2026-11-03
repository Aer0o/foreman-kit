# What's inside Foreman

Everything the kit installs or changes on his PC, in one place. Paths use `%USERPROFILE%`, his Windows
user folder (for example `C:\Users\Dan`).

## 1. Plugins

| Plugin | From | When | What it is |
|---|---|---|---|
| **foreman** | `https://github.com/Aer0o/foreman-kit.git` (marketplace "foreman") | Always | Everything in sections 2 to 5. Updates itself when the GitHub repo changes. |
| **document-skills** | `https://github.com/anthropics/skills.git` (Anthropic's own) | Only if his Claude app doesn't already have the Word/PDF/PowerPoint/Excel skills | Anthropic's docx, pdf, pptx and xlsx skills. Usually not needed: the desktop app syncs them from his account. |

No MCP servers, no slash commands, no agents. Foreman adds nothing he has to type.

## 2. Skills (12)

Claude picks these from what he types. A hook also points Claude at the right one, so he never needs a command.

**Documents**

| Skill | What it does | He'd say |
|---|---|---|
| report-writer | Site, inspection and close-out reports, and proposals, from his notes, photos and files. Summary first, his letterhead, gaps marked `[NEEDS: ...]` in yellow, ideas he didn't state marked `[SUGGEST: ...]`. | "turn my notes into a site report" |
| doc-design | Makes a Word file, PDF or slide deck look professional in his house style (fonts, sizes, brand colour, tables, footers). Remembers his corrections. | "make this look professional" |
| doc-edit | Edits his existing Word, Excel, PowerPoint or PDF files and saves a v2 copy. Uses tracked changes when it goes to a client or GC. | "fix this report", "update this quote" |
| proofread | Last check before sending: totals add up, dates, names, leftover placeholders, wrong client from a reused template. | "check this before I send it" |
| client-email | Emails and letters in his own voice: chasing payment, change orders, delays, quote covers, declining work. | "write an email chasing the invoice" |
| plain-writing | Makes text sound human and direct, not like AI. (Adapted from stop-slop by Hardik Pandya, MIT licence.) | "this sounds like AI" |
| chart-craft | Clean, honest charts in Excel and PowerPoint, with his brand colour as the one accent. | "make a chart of this" |

**Estimating**

| Skill | What it does | He'd say |
|---|---|---|
| tender-review | Reads tender documents and addenda against a 98-item missed-scope checklist. Every finding has a document and page. Drafts RFI questions. Learns each miss he reports. | "what am I missing in this tender" |
| quote-check | Checks his quote: math, HST 13%, markup, scope against the tender, addenda, exclusions, validity. Never changes his numbers; flags them. | "check my quote" |
| spec-lookup | Part numbers, ratings, CSA/cUL listing. Each fact is CHECKED with a link or page, or marked NOT CONFIRMED. | "catalogue number for a 20A AFCI for a QO panel" |
| doc-to-excel | Pulls tables out of PDFs, Word files, scans and emails into Excel: numbers as numbers, totals as formulas, a source on every row. Reads scanned pages with OCR. | "put this schedule in Excel" |

**Setup**

| Skill | What it does | He'd say |
|---|---|---|
| foreman-setup | The 5-minute first-run interview (company profile, logo, writing voice), fixing problems, and restoring a backed-up file. | "set up Foreman", "undo that" |

## 3. Hooks (4, all PowerShell, run automatically)

| Hook | When | What it does |
|---|---|---|
| session-start | Each new chat | Loads the Foreman rules, his company profile and writing voice (under 3,000 tokens). On first run, offers the setup interview. Once a week, checks that LibreOffice, Python and the rest are still installed. Announces Foreman updates once. Deletes backups older than 30 days. |
| prompt-router | Each message he sends | Points Claude at the right skill. Notices "we missed X on the last job" and offers to add it to his checklist. After 20 messages, suggests a fresh chat. |
| file-guard | Before Claude runs a command or writes a file | Copies any document it is about to touch to `foreman\backups\`. Asks him before anything deletes files outside temp folders. |
| source-guard | When Claude finishes an answer | If the answer has a part number that isn't in his files or any page Claude opened, and no source, sends Claude back once to source it or mark it unconfirmed. |

A hook that fails logs to `foreman\hook-errors.log` and never stops his chat.

## 4. Always-on rules and reply style

- **Foreman rules** (`core/rules.md`), loaded every chat:
  - never invent a number, price, part number or code clause
  - source every fact
  - flag money, don't fix it
  - never overwrite an original
  - talk plain
  - work in few steps
  - look at the pages once before saying done
  - learn from corrections
  - build new files directly; load Anthropic's Office skills only for tracked changes, complex edits and PDF forms
- **"Plain Office" reply style**, switched on automatically: answer first, no code on screen, saved files as
  links, one question at a time, Canadian spelling.

## 5. His own files (`%USERPROFILE%\.claude\foreman\`)

Plugin updates never touch these. Claude fills and updates them as he works.

| File | What |
|---|---|
| `profile.md` | Company name, address, licence and HST numbers, trades, standard exclusions, brand colour, logo, who signs. |
| `voice.md` | How he writes: greeting, sign-off, tone, phrases he uses and avoids. |
| `doc-style.md` | Document house style. His corrections are added as dated lines. |
| `checklist.md` | The tender missed-scope checklist. His own misses are added with dates. |
| `checklist-spark1.md`, `spark1-notes.md` | Only if he had SPARK 1: his old checklist, and the old notes Claude had saved. |
| `logo.<ext>` | His logo, if he gives one during setup. |
| `backups\` | Copies of documents taken before Claude touched them, kept 30 days. |
| `install-report.txt` | Result of the last install or Fix run. |
| `state.json`, `hook-errors.log` | Housekeeping. |

## 6. Claude settings (`%USERPROFILE%\.claude\settings.json`)

The installer merges these in and keeps everything already there. Values marked "if unset" are only written when
he hasn't chosen one himself.

| Setting | Value | Why |
|---|---|---|
| `extraKnownMarketplaces.foreman` | git, `https://github.com/Aer0o/foreman-kit.git`, autoUpdate on | Where Foreman comes from, and keeps it updated. HTTPS, because GitHub over SSH needs keys he doesn't have. |
| `enabledPlugins` | `foreman@foreman` (plus `document-skills@anthropic-agent-skills` only if needed) | Switches Foreman on. |
| `permissions.defaultMode` | `acceptEdits` (if unset) | Claude can save files without asking each time. |
| `permissions.allow` | Read-only file listing, python, node, soffice, pdftoppm, pdftotext, pandoc, qpdf, tesseract, WebSearch, WebFetch | The document tools run without a prompt. |
| `permissions.deny` | `.env` files, files named like passwords, `.kdbx` vaults, the NotebookEdit tool | Keeps secrets out of reach and drops a tool he'll never use. |
| `autoCompactWindow` + `modelSettings.claude-opus-5-5.autoCompactWindow` | 200000 (if unset) | Long chats get summarised at 200k tokens instead of near 1M, so each step re-reads far less. |
| `modelSettings.claude-opus-5-5.effortLevel` | `high` (if unset) | Default thinking for Opus 5.5. The effort picker in the app still overrides it per chat. |
| `promptSuggestionEnabled` | false (if unset) | Suggested next prompts cost a request after every reply. |
| `disableBundledSkills` | true (if unset) | Hides Claude Code's built-in coding skills he'll never use, so they stop costing context. |
| `env.CLAUDE_CODE_DISABLE_EXPLORE_PLAN_AGENTS` | 1 (if unset) | No code-exploring helper agents. Each one would start its own costly context. |

A copy of his settings from before Foreman is saved as `foreman\settings.before-foreman-<date>.json`.

## 7. Programs installed (winget, only if missing)

Git, Python 3.12, Node.js LTS, LibreOffice, Pandoc, Poppler, QPDF, Tesseract OCR.

The program folders are added to his user PATH (kept in its original format), and `NODE_PATH` is set.

**Python add-ons** (`pip --user`): openpyxl, pandas, python-docx, python-pptx, pypdf, pdfplumber, reportlab,
Pillow, lxml, defusedxml, markitdown, pytesseract, pdf2image, pypdfium2.

**Node add-ons** (`npm -g`): docx, pptxgenjs.

## 8. The zip he double-clicks from

| File | What |
|---|---|
| `Install Foreman.bat` | First install. Asks before installing programs. |
| `Fix Foreman.bat` | The same installer, without asking. Puts back anything missing. Safe to run any time. |
| `Uninstall Foreman.bat` | Switches Foreman off. Leaves his files, the programs and the other settings in place. |
| `READ ME FIRST.txt` | One page: install, use, fix. |
| `What to say.txt` | Example requests for each kind of job, and good habits. |
| `files\install.ps1` | The installer itself. |

## 9. Moved over from SPARK 1 (if found)

His filled-in company profile, his tender checklist and his old notes are kept. The old SPARK 1 files are moved
to `foreman\spark1-backup-<date>\`, and their hook entries are taken out of settings.json, so nothing runs twice.
