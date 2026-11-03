---
name: spark-setup
description: Set up or repair SPARK. Use on first run when the company profile is blank, when he says "set up SPARK", "update my company info", "learn how I write", or when something is broken ("it can't open Word files", "SPARK isn't working", "fix it").
---

# SPARK setup and repair

His files live in `~/.claude/spark/` (on Windows, `%USERPROFILE%\.claude\spark\`):
`profile.md`, `voice.md`, `doc-style.md`, `checklist.md`. A file that still contains the line
`SPARK:BLANK` has not been filled in yet.

## First-run interview (profile.md)

Goal: fill `profile.md` in about five minutes without it feeling like a form.

1. Say in one line what this is: "Quick setup so I stop asking the same things. Five minutes, skip anything."
2. Ask **one question at a time**, in this order, and accept "skip":
   - Company name and address, phone, email, website.
   - ESA/ECRA licence number and HST number (optional; never guess them).
   - What work he does and who he usually bids to.
   - His standard exclusions and clarifications. Offer: "If you have an old quote handy, drop it in and
     I'll pull them out of it." If he gives a file, read it and propose the list for him to confirm.
   - Quote validity and payment terms.
   - Brand colour and logo. Offer: "Drop your logo file in here and I'll take the colour from it." If he
     gives a logo, copy it to `~/.claude/spark/logo.<ext>` and record that path.
   - Who signs letters and quotes.
3. Write the answers into `profile.md` under its headings. Leave skipped lines empty. Remove the
   `SPARK:BLANK` line.
4. Show him a five-line summary and ask if anything is wrong.

## Learn his writing voice (voice.md)

Offer this after the profile, or when he asks. "Paste two or three emails you wrote yourself, any topic."
From them, note greeting, sign-off, typical length, tone, phrases he repeats, and things he never does
(e.g. no exclamation marks). Write `voice.md`, remove `SPARK:BLANK`, and show him three lines of what you
learned. Never copy client names or private details from the samples into the file.

## Something is broken

1. Check which tools respond: `python --version`, `node --version`, `soffice --version`,
   `pdftoppm -v`, `pandoc --version`. Run them yourself; don't show him the output.
2. Check that the docx, pdf, pptx and xlsx skills are available to you.
3. Tell him in plain words what is missing and the fix:
   - Missing programs: "Double-click **Fix SPARK** in the SPARK folder you installed from. It reinstalls
     what's missing. Then close and reopen Claude."
   - Missing Office skills: "Open Claude, go to Customize (or Settings), then Skills, and make sure the
     Word, PDF, PowerPoint and Excel skills are switched on." If that doesn't help, Fix SPARK turns on
     the backup copy.
4. If everything checks out, say so and ask what he was trying to do when it failed.

## Undo a bad edit

Copies of every Office file are saved before a command touches it, in `~/.claude/spark/backups/`,
named `<date>_<time>_<original name>`, kept 30 days. When he says "undo that" or "get my old file back",
find the newest matching copy, put it back beside the original as "<name> restored", and give him the link.
