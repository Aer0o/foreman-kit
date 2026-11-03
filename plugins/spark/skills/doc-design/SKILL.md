---
name: doc-design
description: Make a Word, PDF or PowerPoint document look clean and professional, or change how his documents look from now on. Use when he says "make this look professional", "clean up the formatting", "this looks messy", "make it look like a real company sent it", or corrects a look ("bigger headings", "use our blue", "too much space").
---

# Document design

Goal: documents that look like a well-run contracting company sent them. Plain, consistent, easy to read
printed and on a phone.

## Where the look comes from

1. `~/.claude/spark/doc-style.md` holds **the values**: font, sizes, spacing, margins, tables, footer,
   slides. Lines under "His corrections" override the list above them. This file is the only source of
   values; don't bring in other numbers.
2. `~/.claude/spark/profile.md` holds the brand colour, logo path, company name, address and licence number.
3. [references/house-style.md](references/house-style.md) explains **how** to apply those values in Word,
   PDF and PowerPoint, the fallbacks, and the anti-patterns. Read it before building or restyling.

If a file is missing or a line is blank, use the fallback from house-style.md and tell him in one line,
e.g. "No brand colour on file, so I used dark grey. Tell me your colour and I'll keep it." Never invent a
brand colour, a logo or company details.

## Who does the file work

This skill decides the look. Anthropic's skills do the file work; call them by name:

- Word: the docx skill (`anthropic-skills:docx` or `document-skills:docx`)
- PowerPoint: the pptx skill · PDF: the pdf skill · Excel: the xlsx skill
- Charts inside any of these: the **chart-craft** skill.

A PDF can't be restyled in place. Restyle the Word or PowerPoint file it came from. If he only has the PDF,
offer to rebuild it as a Word document (text and tables carried over, then styled) saved as a new file.

## Restyling an existing document

- Never overwrite his file. Save as "<name> v2.docx" beside it (next free number; "Quote v3" becomes
  "Quote v4", not "Quote v3 v2").
- Change the look, not the content. Don't reword, reorder or drop anything unless he asked. Every number
  stays exactly as it was.
- Fix the structure first, then the style: real headings (heading styles, not bold body text), real tables
  (not tabs and spaces), real lists, page breaks instead of rows of blank lines.
- If it's built on a template he clearly chose (his letterhead, a client's form), keep that and only clean
  up. If unsure, ask one question.

## New documents

Build in the house style from the first line. Page setup, header and footer, tables and slides are all in
house-style.md.

## Look before you say done

Every time, no exceptions:

1. Convert to PDF: `soffice --headless --convert-to pdf --outdir <scratch folder> "<file>"`. Call soffice
   directly; Anthropic's soffice.py wrapper is Linux-only. Skip this for a file that is already a PDF.
2. Render the pages: `pdftoppm -png -r 80 "<file.pdf>" "<scratch folder>\page"`.
3. Open the PNGs and look at them against the preview checklist at the end of house-style.md. For a long
   document: page 1, every page with a table, chart or photo, and the last page.
4. Something overlaps, runs off the page or breaks: fix it, re-render, look again. Only then say done.

If soffice or pdftoppm is missing, don't claim the check. Tell him: "I couldn't preview the pages on this
PC. Double-click Fix SPARK in the SPARK folder, then ask me again."

If headings or body text in the preview look like the wrong font, check the font note in house-style.md
before changing anything else.

## When he corrects a look

He says "bigger headings", "less space between lines", "use our blue", "drop the grey".

1. Make the change in this document, re-render and look.
2. Add a dated line under "His corrections" in `~/.claude/spark/doc-style.md` with the new value, e.g.
   "2026-11-12: headings bigger (heading 1 16 pt)". If it changes an earlier correction, edit that line
   instead of adding a contradicting one.
3. Tell him in one line: "Done, and I'll use bigger headings from now on."

A one-off ("for this tender use the GC's cover page") doesn't go in the file. If you can't tell, ask:
"Just this one, or from now on?"

## Reply to him

The file as a link and one line on what changed ("Cleaned up the headings and tables, added page numbers").
No list of fonts, sizes or settings unless he asks.
