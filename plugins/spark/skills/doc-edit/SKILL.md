---
name: doc-edit
description: Edit an existing Word, Excel, PowerPoint or PDF file, keeping its formatting and saving a v2 copy. Use for "fix this report", "update this quote", "reuse this for the new job" or "mark up this contract".
---

# Editing his documents

## Before touching anything

- In one round, read the file through the matching skill (docx, xlsx, pptx or pdf) and
  `~/.claude/spark/profile.md` (company, signer, licence number).
- Unclear what to change: ask one question. Only "fix this": list the three to five changes you'd make and
  ask which.

## The copy

"<name> v2.<ext>" beside the original, next free number; a name ending in a version goes up ("Quote
v3.docx" to "Quote v4.docx", never "Quote v3 v2.docx"). Same file type unless asked. The automatic backup
in `~/.claude/spark/backups/` is a safety net, not the plan.

## Tracked changes or clean

- **Goes to someone else** who will want to see what changed (client, GC, owner, inspector, engineer,
  supplier, lawyer), especially a contract, spec or anything sent to him for comment: tracked changes.
- **His own document** he'll send as final: clean edits.
- Can't tell: "Should the changes show as tracked changes, or clean?"
- Tracked changes use the docx skill's method. Author: the company name or signer from profile.md, never
  "Claude". Questions and reasons go in Word comments, not the text.

## Every change in one pass

Write ONE script that opens the file, makes all the changes and saves the copy (the docx skill's
edit-in-place or tracked-change route), not a chain of small edits. If the check finds a problem, fix the
script and rerun.

- Edit inside the existing file; don't rebuild it. That keeps his styles, letterhead, numbering, headers
  and footers. New text takes the style around it. Don't restyle unless he asks.
- **Reusing an old job's document:** replace every trace of the old job: client, site address, dates, job
  or quote number, header, footer and file properties (title, author, company). List anything unsure.
- Never change a price, quantity, rate, total, tax or payment date unless he gave you the new value.
- **Excel:** keep formulas; change inputs, never type over a formula (a wrong-looking formula: flag, leave).
  Keep sheets, named ranges, formatting, widths, hidden sheets. Recalculate; no #REF!, #VALUE!, #DIV/0! or
  #NAME?. A total your edit changes: tell him old and new.
- **PowerPoint:** keep master, layouts, fonts, colours; edit inside placeholders. Text that doesn't fit:
  shorten or split the slide, never shrink below the deck's size.
- **PDF:** tell him "PDFs aren't built for editing. Changing the text in one usually breaks the layout."
  Offer, in order: rebuild as a Word document he can keep; mark it up with highlights and comments as
  "<name> v2.pdf"; fill the fields if it's a form. If he has the Word original, ask for that.
- Sentences you rewrite: lead with the point, no filler, active voice, one idea per sentence.

## Check once

Convert and render the copy in one command (this also recalculates Excel):
`soffice --headless --convert-to pdf --outdir "<scratch>" "<file>"; pdftoppm -png -r 50 "<scratch>\<name>.pdf" "<scratch>\p"`
Look at page 1 and every page you changed. Anything moved, overlapping or broken: fix the script, re-render,
once.

## Tell him

The new file as a link; what changed as a short plain list, repeats grouped ("Changed the site address on
page 1 and in the footer"); anything flagged but not changed; at most one question.
