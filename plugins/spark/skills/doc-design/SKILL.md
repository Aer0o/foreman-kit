---
name: doc-design
description: Make a Word document, PDF or slide deck look clean and professional, or change his house style. Use for "make this look professional", "clean up the formatting", "make a deck" or "use our blue".
---

# Document design

Documents and decks that look like a well-run contracting company sent them: plain, consistent, easy to
read printed and on a phone.

## Where the look comes from

Read all three in one round before building:

1. `~/.claude/spark/doc-style.md`: **the values** (font, sizes, spacing, margins, tables, footer, slides).
   Lines under "His corrections" override the list. The only source of values.
2. `~/.claude/spark/profile.md`: brand colour, logo path, company name, address, licence number.
3. [references/house-style.md](references/house-style.md): **how** to apply them in Word, PDF and
   PowerPoint, fallbacks, anti-patterns, preview checklist.

Missing file or blank line: use the house-style.md fallback and say so in one line ("No brand colour on
file, so I used dark slate. Tell me your colour and I'll keep it."). Never invent a colour, logo or
company details.

File work: python-docx, python-pptx or openpyxl directly (the SPARK rules say when to load the docx/pptx skill). Charts inside: grey plus one accent on the point, title
states the takeaway, direct labels, nothing 3D.

A PDF can't be restyled in place: restyle the Word or PowerPoint file it came from, or offer to rebuild
the PDF as a new Word document.

## Restyling an existing document

- v2 copy per the SPARK rules ("Quote v3" becomes "Quote v4", not "Quote v3 v2").
- Change the look, not the content: no rewording, reordering or dropping unless asked; every number stays.
- Structure first: real headings (not bold body text), real tables (not tabs and spaces), real lists,
  page breaks instead of blank lines.
- Built on a template he clearly chose (his letterhead, a client's form): keep it, only clean up. Unsure:
  ask one question.
- Do the whole restyle in ONE script that opens his file, applies every change and saves the copy.

## New documents and decks

Gather his content plus the three files in one go, then write ONE script that builds the whole thing in the
house style (Word with python-docx; slides with pptxgenjs or python-pptx, every slide in the
same script). Never build and then patch with many small edits; to fix, change the script and rerun.

## Look once

1. Convert and render in one command (skip the convert for a PDF):
   `soffice --headless --convert-to pdf --outdir "<scratch>" "<file>"; pdftoppm -png -r 50 "<scratch>\<name>.pdf" "<scratch>\p"`
2. Check against the preview checklist in house-style.md. Long document: page 1, pages with a table,
   chart or photo, and the last page. Deck: every slide (small at 50 dpi).
3. Real breakage only (overlap, off the page, a page spilling over): fix the script, rebuild, re-render,
   once. To read small text, re-render one page at `-r 100 -f N -l N`. Wrong-looking font: see the font
   note in house-style.md first.

## When he corrects a look

"Bigger headings", "less space between lines", "use our blue", "drop the grey":

1. Change it in the script, rebuild, look once.
2. Add a dated line under "His corrections" in doc-style.md with the new value, e.g. "2026-11-12: headings
   bigger (heading 1 16 pt)". If it changes an earlier correction, edit that line instead.
3. Tell him: "Done, and I'll use bigger headings from now on."

A one-off ("for this tender use the GC's cover page") doesn't go in the file. Can't tell? "Just this one,
or from now on?"

Reply with the file as a link and one line on what changed. No fonts or settings unless he asks.
