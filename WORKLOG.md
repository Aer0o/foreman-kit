# WORKLOG: SPARK

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
- **Checked:**
  - 40/40 hook tests pass.
  - `claude plugin validate` passes, with the expected warning about the missing version.
  - The v1 migration was run on a fake v1 layout. It kept his profile and checklist, removed the old
    hooks, and left his own skill and hook alone. A second run was idempotent.
