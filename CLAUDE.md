# SPARK kit: Claude notes

SPARK is a Claude Code kit for Oleg's friend, an electrical contractor and estimator in Ontario.
He runs Claude Code in the Windows desktop app (Code tab, Local sessions) on the Pro plan and uses it for
documents: Word, PDF, PowerPoint, Excel, reports, tenders, quotes, emails. He is not a coder and will
never edit these files. Everything has to work without him touching it.

- **v1** (July 2026) was a drop-in `~/.claude` folder. Its files are lost from Oleg's PC; only the memory
  note `spark-kit-for-friend` survived. **v2** (this repo) is a plugin plus an installer.
- **Public repo** `Aer0o/spark-kit`: his PC pulls plugin updates from it with no GitHub login.
  **Nothing personal goes in here**: no names, company data, client data, prices or Oleg's own notes.
- **Git:** AUTO tier (2026-11-03). Claude commits and pushes freely. Claude files tracked.

## Layout

```
.claude-plugin/marketplace.json   marketplace "spark" -> plugin ./plugins/spark
plugins/spark/                    the plugin (updates itself on his PC)
  skills/<name>/SKILL.md          one folder per skill
  hooks/hooks.json, hooks/*.ps1   PowerShell hooks
  output-styles/                  "Plain Office" output style
  core/rules.md                   always-on rules, injected by the SessionStart hook
  defaults/                       first-run copies: profile, voice, checklist, doc style
installer/                        Install / Fix / Uninstall .bat + install.ps1
tests/                            hook fixtures + runner
```

## His data lives OUTSIDE the plugin

Plugin updates replace `plugins/spark/` wholesale, so anything he or Claude edits lives in
`%USERPROFILE%\.claude\spark\` (written by the installer and the SessionStart hook from `defaults/` when missing):

| file | what |
|---|---|
| `profile.md` | company profile: name, address, licence, trades, rates policy, brand colours, logo path |
| `voice.md` | how he writes: greeting, sign-off, tone, phrases he uses, phrases he hates |
| `checklist.md` | missed-scope checklist for tender review; Claude appends items when he mentions a miss |
| `doc-style.md` | his document house style (fonts, sizes, colours); Claude updates it when he corrects a look |
| `backups\` | copies of Office files taken before a command touched them; pruned after 30 days |
| `state.json` | hook state: last health check, last version seen, turn counter |

Skills refer to these as `~/.claude/spark/<file>` and must say: read it if present, never invent its contents.

## Rules for writing anything in this repo

- **`.ps1` files are pure ASCII.** Windows PowerShell 5.1 reads BOM-less files as ANSI, so one em-dash
  breaks the parse. `@(Get-Content -Tail N)` keeps its `@()`: a one-line file otherwise returns a string.
- Hooks run as `powershell.exe -NoProfile -ExecutionPolicy Bypass -File <script>`; never assume `pwsh`.
- **Skill prose is for Claude, not for him**, but anything Claude says to him must be plain English:
  no code shown, no jargon, file paths given as links, one question at a time.
- Never invent numbers, prices, part numbers or code clauses. Flag, don't fix, anything that changes money.
- New Office files are built directly with python-docx / openpyxl / python-pptx (cheaper on his Pro plan; real
  runs gave clean results). Anthropic's docx / pdf / pptx / xlsx skills (`anthropic-skills:*` or
  `document-skills:*`) load only for tracked changes, complex edits of his files, PDF forms, or after a failure.
  We cannot copy them (proprietary licence).
- Run stop-slop on README, cheat sheet and any text he reads.
