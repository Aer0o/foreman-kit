---
name: doc-to-excel
description: Pull tables or lists out of PDFs, Word files, scans, photos or emails into a clean Excel file with a source for every row. Use for "put this in Excel" or "pull the panel schedule out of this PDF".
---

# Documents to Excel

Turn tables and lists from his documents into a clean Excel file he can sort, filter and price from. Never
guess a value you cannot read.

## 1. Read every source in one go

- ONE script extracts every page of every source and prints it with page markers: PDF tables with
  pdfplumber, Word with the docx method, Excel or CSV with openpyxl. Not page by page in separate steps.
- Scans and photos: OCR (Tesseract is installed) in the same script, keeping word-level confidence.
- A saved .eml is plain text, attachments included. A .msg that won't open: ask him to save it as PDF or
  paste the text.
- A table running over several pages is one table.

## 2. Say the plan

A few lines: which tables, on which pages, roughly how many rows, the sheets you'll make. Ask one question
only if something is ambiguous (two near-identical tables: one sheet or two?). Otherwise carry on.

## 3. Build the whole workbook with one script

The script builds every sheet, then prints rows per sheet and any formula errors. Fix by changing the
script and rerunning, not by patching the workbook.

- One table per sheet, short plain sheet names (31 characters max). Row 1 is the only header: no title rows,
  merged cells, or blank rows and columns inside. Freeze the top row, filter on, readable widths.
- Numbers stored as numbers ("$", commas and spaces stripped, number format applied); dates as dates. Units
  in the header ("Length (m)", "Qty (ea)"); a column mixing units is split or flagged, never converted.
- **Identifiers stay text** (part, catalogue, circuit and drawing numbers, leading zeros, dashes), or Excel
  turns "0012" into 12 and "1-4" into a date. Copy part numbers exactly as printed.
- **Source** column on every row: "Specs.pdf p. 14"; for emails, sender and date.
- Totals are formulas. A total printed in the document goes in a "Total per document" cell beside the
  formula total; if they differ, flag it and change neither.
- **Review** column last, empty for clean rows. Fill it, naming the cell and why ("Qty unreadable on p. 4"),
  for: OCR confidence under about 80 percent; characters OCR confuses (0/O, 1/l, 5/S, 8/B); a value you
  couldn't read; a total that doesn't match.
- Unreadable stays empty with a Review note; never fill from context or a neighbouring row. Never invent
  rows, drop odd ones, or round numbers printed with more precision.

## 4. Save and check

- "<source name> - extracted.xlsx" next to the source; never overwrite, add " (2)".
- Recalculate: `soffice --headless --convert-to csv --outdir <scratch> "<file>"` and read the values back; no formula errors. Printed row counts must match the source rows;
  if not, find out why first.
- Render page 1 only, in one command, to check headers and widths:
  `soffice --headless --convert-to pdf --outdir "<scratch>" "<file>"; pdftoppm -png -r 50 -f 1 -l 1 "<scratch>\<name>.pdf" "<scratch>\p"`

## 5. Tell him

Three or four lines: the link; sheets and rows; how many rows need review (filter the Review column);
anything you couldn't extract (a blurry page, a table OCR couldn't read).
