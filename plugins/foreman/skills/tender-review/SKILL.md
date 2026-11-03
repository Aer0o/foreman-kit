---
name: tender-review
description: Review tender documents (specs, addenda, Div 26/27/28, scope letters) for missed scope before pricing, and remember misses. Use for "review this tender", "what am I missing" or "we missed X on job Y".
---

# Tender review

Find what the tender documents require that is easy to miss in pricing, and what they are silent on. You
read, cite and flag. You never price anything: no dollars, hours or quantity estimates. If he asks "how
much", say pricing is his call and offer to list what the documents say about that item.

Every finding cites document, section and page (say so if you can't pin one), with at most a short quote
(under 15 words) so he can find the spot. You point at scope; you don't decide what is in or out.

## Step 1: Read everything in one pass

1. List every file he gave you (a folder: all of it, subfolders included).
2. Write ONE script that extracts every file to a scratch text file per document, with a marker per page
   ("=== <file> p. 14 ==="): PDFs with pdfplumber, OCR (Tesseract is installed) for scanned pages, Word
   and Excel with the docx and xlsx methods. Have it print each document's page count and scanned pages.
   Then search and read those text files to the end; don't open PDFs page by page.
3. Inventory: name, date or revision, pages, what it is (spec section, addendum, scope letter, drawing
   list, bid form).
4. **Addenda:** search for "Addendum No.", "Addendum #", "issued by addendum" and compare with the addenda
   he gave you. A referenced addendum that's missing goes at the very top: the review is incomplete
   without it.
5. **Drawings:** compare any drawing list with the drawings provided; flag listed drawings you didn't get.
6. Later addenda override earlier text. When one changes an item, cite both and say which wins.

## Step 2: His context

- Checklist: `~/.claude/foreman/checklist.md`; if missing, the default at this skill's base directory plus
  `../../defaults/checklist.md` (tell him in one line). If `~/.claude/foreman/checklist-spark1.md` exists
  (his SPARK 1 list), use its items too, skipping repeats.
- `~/.claude/foreman/profile.md` if present (trades he does and doesn't carry, standard exclusions), only to
  judge relevance.

## Step 3: Walk the checklist

Search the extracted text for all checklist items in one script. Each item lands in one bucket:

- **In the documents, easy to miss:** required, and the kind of thing that slips out of a price. Record
  what, document, section, page, short quote.
- **Silent:** the checklist expects it, the documents say nothing, and it matters here. Becomes an RFI
  question.
- **Not relevant:** skip silently. Don't pad.

Then read for what the checklist doesn't cover: named products with no alternates, unusual testing or
warranty terms, after-hours or phased work, owner-supplied equipment, Division 26 work assigned inside
another division's section (mechanical, architectural, civil), bid form items (separate prices,
alternates, unit prices). Add those to the first bucket.

**Conflicts** (spec vs addendum, scope letter or drawing notes): list both sources side by side; don't
pick one.

## Step 4: Report

Ask once, unless he has said before: "Do you want this as a Word report or right here in the chat?"

1. **Stop first** (only if needed): missing addenda, missing drawings, unreadable pages.
2. **Easy to miss in pricing**, grouped by checklist heading, likeliest real cost first:
   "<what is required> [<document>, Section <number>, p. <page>]".
3. **Documents are silent: questions for an RFI.** One line each.
4. **Conflicts between documents.**
5. **Documents read:** the inventory, short.

One line per finding. A Word report: ONE python-docx script, styled from
`~/.claude/foreman/doc-style.md`, saved beside the tender files as "Tender review - <project>.docx" (never
overwrite; add " (2)"). Convert and render in one command, then look at page 1 and the last page:
`soffice --headless --convert-to pdf --outdir "<scratch>" "<file>"; pdftoppm -png -r 50 "<scratch>\<name>.pdf" "<scratch>\p"`

## Step 5: Offer the RFI

"Want me to draft the RFI questions?" If yes: numbered, each citing its document and section; neutral and
factual, asking the consultant to confirm scope; in his voice from `~/.claude/foreman/voice.md` if present;
as text to paste into an email, or a Word file if he asks. Never send anything.

## Remembering misses

When he says "we missed X on job Y", "add X to the checklist" or "next time check X":

1. Read `~/.claude/foreman/checklist.md` (missing: copy the default there first).
2. Pick the closest existing heading. No new heading unless he asks.
3. Already covered? Don't duplicate; tell him which line covers it and offer to reword it.
4. Otherwise append one line at the end of that heading's list:
   `- <the check, ending in a question> (added YYYY-MM-DD, missed on <job>)`
   (leave out "missed on" if he named no job).
5. Touch only that line. Never rewrite, reorder or delete others.
6. Confirm in one sentence: what you added, under which heading.

Never edit the default checklist inside the plugin; updates replace it.
