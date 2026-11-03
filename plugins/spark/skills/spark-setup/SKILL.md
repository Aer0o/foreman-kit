---
name: spark-setup
description: Set up or repair SPARK: fill in his company profile, learn how he writes, restore an old file, or fix it when it can't open Word files. Use for "set up SPARK", "undo that" or "SPARK isn't working".
---

# SPARK setup and repair

His files live in `~/.claude/spark/` (`%USERPROFILE%\.claude\spark\`): `profile.md`, `voice.md`,
`doc-style.md`, `checklist.md`. A file still containing the line `SPARK:BLANK` hasn't been filled in.

## First-run interview (profile.md)

Fill `profile.md` in about five minutes without it feeling like a form.

1. One line: "Quick setup so I stop asking the same things. Five minutes, skip anything."
2. **One question at a time**, in this order, accepting "skip":
   - Company name and address, phone, email, website.
   - ESA/ECRA licence number and HST number (optional; never guess them).
   - What work he does and who he usually bids to.
   - Standard exclusions and clarifications. Offer: "If you have an old quote handy, drop it in and I'll
     pull them out of it." From a file, propose the list for him to confirm.
   - Quote validity and payment terms.
   - Brand colour and logo: "Drop your logo file in here and I'll take the colour from it." Copy a logo to
     `~/.claude/spark/logo.<ext>` and record that path.
   - Who signs letters and quotes.
3. Write all answers into `profile.md` under its headings in one write; skipped lines stay empty. Remove
   `SPARK:BLANK`.
4. Show a five-line summary and ask if anything is wrong.

## Learn his writing voice (voice.md)

After the profile, or when he asks: "Paste two or three emails you wrote yourself, any topic." Note
greeting, sign-off, typical length, tone, repeated phrases, things he never does (e.g. no exclamation
marks). Write `voice.md`, remove `SPARK:BLANK`, show him three lines of what you learned. Never copy client
names or private details from the samples.

## Something is broken

1. Check every tool in ONE command, without showing him the output:
   `python --version; node --version; soffice --version; pdftoppm -v; pandoc --version`
2. Check whether the docx, pdf, pptx and xlsx skills are available (only needed for tracked changes, complex edits of his own files and PDF forms).
3. Tell him plainly what's missing and the fix:
   - Programs: "Double-click **Fix SPARK** in the SPARK folder you installed from. It reinstalls what's
     missing. Then close and reopen Claude."
   - Office skills: "Open Claude, go to Customize (or Settings), then Skills, and make sure the Word, PDF,
     PowerPoint and Excel skills are switched on." If that doesn't help, Fix SPARK turns on the backup copy.
4. All fine: say so and ask what he was trying to do when it failed.

## Undo a bad edit

Every Office file is copied to `~/.claude/spark/backups/` before a command touches it, named
`<date>_<time>_<original name>`, kept 30 days. For "undo that" or "get my old file back": find the newest
matching copy, put it beside the original as "<name> restored", and give him the link.
