---
name: doc-edit
description: Edit an existing Word, Excel, PowerPoint or PDF file he gives you, keeping his formatting and never overwriting the original. Use when he says "fix this report", "update this quote", "change the dates in this", "reuse this for the new job", "mark up this contract" or "make these changes".
---

# Editing his documents

## Before touching anything

- Open the file through the matching Anthropic skill: the docx skill (`anthropic-skills:docx` or
  `document-skills:docx`), or the xlsx, pptx or pdf skill. That skill does the file work; don't write
  Office formats by hand.
- If what to change isn't clear, ask one question. If he only said "fix this", read it, list the three to
  five changes you'd make, and ask which ones.
- Read `~/.claude/spark/profile.md` if present: company name, signer, licence number.

## Never overwrite the original

- Save the edited copy beside the original as "<name> v2.<ext>". If v2 exists, use v3, and so on. If the
  name already ends in a version ("Quote v3.docx"), go to the next number ("Quote v4.docx"), never
  "Quote v3 v2.docx".
- Keep the same file type unless he asks for another.
- A backup copy also lands in `~/.claude/spark/backups/` automatically. That's a safety net, not the plan.

## Tracked changes or clean edits

- **Goes to someone else** who will want to see what changed (client, GC, owner, inspector, engineer,
  supplier, lawyer), especially a contract, spec or anything they sent him for comment: tracked changes.
- **His own document** that he'll send as final: clean edits.
- Can't tell: ask "Should the changes show as tracked changes, or clean?"
- For tracked changes use the docx skill's tracked-change method. The author is the company name or the
  signer from profile.md, never "Claude". Questions and reasons go in Word comments, not in the text.

## Keep his formatting

- Edit inside the existing file; don't rebuild it from scratch. The docx skill's edit-in-place route keeps
  his styles, letterhead, numbering, headers and footers.
- New text takes the style of the text around it: same font, size and heading level.
- Don't restyle unless he asks. Making it look better is the **doc-design** skill.
- **Reusing an old job's document** (last month's quote for a new client): replace every trace of the old
  job, including client name, site address, dates, job or quote number, header and footer, and the file's
  properties (title, author, company). List anything you weren't sure about.

## Excel

- Keep formulas. Change the inputs, never type a number over a formula. If a formula looks wrong, flag it
  and leave it.
- Keep sheets, named ranges, formatting, column widths and hidden sheets as they are.
- After editing, recalculate and check no cell shows #REF!, #VALUE!, #DIV/0! or #NAME?. Converting to PDF
  with soffice (below) also recalculates.
- If a total changes because of your edit, tell him the old and new value.

## PowerPoint

Keep the slide master, layouts, fonts and colours. Edit text inside its placeholder. If new text doesn't
fit, shorten it or split the slide; don't shrink the font below the size the deck already uses.

## PDF

Tell him plainly: "PDFs aren't built for editing. Changing the text in one usually breaks the layout."
Then offer, in this order:

1. Rebuild it as a Word document he can edit and keep (best if he'll reuse it).
2. Mark it up: highlights and comments on the PDF, saved as "<name> v2.pdf" (the pdf skill).
3. If it's a fillable form, fill in the fields.

If he has the Word file the PDF came from, ask for that instead.

## Money and numbers

Never change a price, quantity, rate, total, tax or payment date unless he told you the new value. If one
looks wrong, flag it in your summary and leave it.

## Check before saying done

1. Convert the new copy: `soffice --headless --convert-to pdf --outdir <scratch folder> "<file>"`. Call
   soffice directly; Anthropic's soffice.py wrapper is Linux-only.
2. Render: `pdftoppm -png -r 80 "<file.pdf>" "<scratch folder>\page"`. Look at page 1 and every page you
   changed. Fix anything that moved, overlapped or broke, then render again (two rounds at most).
3. If soffice or pdftoppm is missing, don't claim the check; tell him to double-click Fix SPARK in the
   SPARK folder.
4. If you rewrote sentences, run the **plain-writing** skill on the new text only.

## Tell him

- The new file as a link.
- What changed, as a short plain list. Group repeats: "Changed the site address on page 1 and in the
  footer", "Moved the start date to the new date in three places".
- Anything you flagged but didn't change, then at most one question.
