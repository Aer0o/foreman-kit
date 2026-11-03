---
name: doc-to-excel
description: Use when he wants tables or lists pulled out of PDFs, Word files, scans, photos or emails into a spreadsheet, e.g. "put this in Excel", "turn this schedule into a spreadsheet", "pull the panel schedule out of this PDF", "make a list of all the fixtures". Builds a clean .xlsx with a source for every row and marks anything unreadable.
---

# Documents to Excel

Turn tables and lists from his documents into a clean Excel file he can sort, filter and price from.
Build the workbook with the xlsx skill. Never guess a value you cannot read.

## Step 1: Read the sources

- PDF: the pdf skill. Word: the docx skill. Existing Excel or CSV: the xlsx skill.
- Emails: a saved .eml file is plain text, read it directly (attachments included). If an Outlook .msg
  file will not open, ask him to save the email as PDF or paste the text in. One question.
- Scanned PDFs and photos: OCR through the pdf skill (Tesseract is installed by this kit). Keep the
  word-level confidence the OCR gives you; you need it in Step 3.
- Read every page. A table that continues over several pages is one table, not several.

## Step 2: Plan, then confirm once

Tell him in a few lines what you found: which tables, on which pages, roughly how many rows, and the
sheets you plan to make. If something is ambiguous (two tables with almost the same columns: one sheet
or two?), ask that one question. Otherwise go ahead without waiting.

## Step 3: Build the workbook (xlsx skill)

**Layout**
- One table per sheet. Sheet names short and plain (Excel allows 31 characters), e.g. "Panel LP-2",
  "Lighting fixtures".
- Row 1 is the only header row. No title rows above it, no merged cells anywhere, no blank rows or
  blank columns inside the table.
- Freeze the top row. Turn the filter on for the header row. Set column widths so headers are readable.

**Values**
- Numbers are stored as numbers, not text: strip "$", commas and stray spaces, then apply a number
  format. Dates are real dates.
- Units go in the header, not in the cells: "Length (m)", "Load (kVA)", "Qty (ea)". If one column
  mixes units, do not convert anything silently: split it into two columns or flag the rows.
- **Keep identifiers as text**: part numbers, catalogue numbers, circuit numbers, drawing numbers,
  anything with leading zeros or dashes. Excel will otherwise turn "0012" into 12 or "1-4" into a date.
- Copy part numbers exactly as printed. Do not correct, complete or reformat them.

**Source column**
- Every row gets a "Source" column with file name and page, e.g. "Specs.pdf p. 14". For emails use the
  sender and date. For multi-file jobs this is how he traces any row back.

**Totals**
- Totals are formulas (SUM and so on), never typed numbers.
- If the document printed its own total, put that in a separate "Total per document" cell next to the
  formula total. If they differ, flag it in the Review column. Do not change either one.

**Review column**
- Add a last column "Review". Leave it empty for clean rows. Fill it when a row needs his eye:
  - OCR confidence low on any cell in the row (roughly below 80 percent),
  - a number that contains characters OCR often confuses (0 and O, 1 and l, 5 and S, 8 and B),
  - a value you could not read at all,
  - a total that does not match the document.
  Say which cell and why, e.g. "Qty unreadable on p. 4".

## Never guess

- If a value is unreadable, leave the cell empty and say so in the Review column. Never fill it from
  context, a neighbouring row or what "should" be there.
- Never invent rows to make a list look complete, and never drop rows that look odd.
- Never round numbers that were printed with more precision.

## Step 4: Save and check

- Save next to the source file unless he says otherwise. Name it after the source, e.g.
  "<source name> - extracted.xlsx". Never overwrite an existing file; add " (2)" to the name.
- Recalculate the workbook (the xlsx skill has a step for this) and make sure no formula shows an error.
- Count the rows on each sheet and compare against the rows in the source. If they differ, find out
  why before telling him it is done.

## Step 5: Tell him

Three or four plain lines:
- the file, as a link,
- how many sheets and rows,
- how many rows need his review, and where to find them (filter the Review column),
- anything you could not extract at all (a page too blurry, a table that is an image you could not OCR).
