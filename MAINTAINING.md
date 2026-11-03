# Maintaining SPARK

## How an update reaches his PC

His `settings.json` points at this repo (`extraKnownMarketplaces.spark`, a `git` source with the HTTPS URL
`https://github.com/Aer0o/spark-kit.git`, `autoUpdate: true`). Not the `github` source type: that one clones over
SSH and fails on a PC without GitHub keys (checked 2026-11-03). The plugin has **no `version` field on purpose**: Claude Code then uses the commit SHA
as the version, so every push to `main` counts as an update. (`claude plugin validate` warns about the
missing version; ignore it. Adding a version would freeze him on that version until it changes.)

Claude Code checks for updates after the first message of a session, with a random delay of up to
10 minutes. The new version loads in his **next** session.

## Shipping a change

1. Edit under `plugins/spark/`.
2. Run the tests: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\run-tests.ps1`
3. If he should hear about it, add a line at the **top** of `plugins/spark/core/changelog.md`:
   `2.0.1 | One plain sentence about what changed for him.` The SessionStart hook shows it once.
4. Commit and push to `main`.

Never put anything personal in this repo. It is public, because his PC pulls updates without a GitHub login.

## What lives where on his PC

| Path | What | Who changes it |
|---|---|---|
| `%USERPROFILE%\.claude\plugins\...` | this plugin, managed by Claude Code | updates |
| `%USERPROFILE%\.claude\spark\` | profile, voice, doc style, checklist, backups, state | Claude, while he works |
| `%USERPROFILE%\.claude\settings.json` | marketplace + plugin switch + permissions | the installer |

## When he reports a problem

Ask for `%USERPROFILE%\.claude\spark\install-report.txt` and `hook-errors.log` (same folder, only exists if
a hook failed). A failing hook logs the error there and exits cleanly, so his session carries on.

## Things not verified on his machine

- That the desktop app's Code tab loads the plugin hooks exactly as the CLI does. The docs say it reads the
  same settings; the first-session "SPARK is ready" line is the proof.
- Whether his account's built-in Word/PDF/PowerPoint/Excel skills are switched on. The installer turns on
  Anthropic's `document-skills` plugin only when it can't find them.
