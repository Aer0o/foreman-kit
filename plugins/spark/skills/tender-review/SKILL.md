---
name: tender-review
description: Use when he hands over tender or bid documents (specs, drawing lists, addenda, Division 26/27/28 sections, scope letters) and wants missed scope found before pricing, e.g. "review this tender", "what am I missing in this bid", "check these specs for scope". Also use when he reports a miss to remember, e.g. "we missed X on job Y" or "add X to the checklist".
---

# Tender review

Find what is in the tender documents but easy to miss in pricing, and what the documents are silent
on. You never price anything. You read, you cite, you flag.

## Hard rules

- Never put a dollar figure, hours, or a quantity estimate on anything. If he asks "how much", say
  pricing is his call and offer to list what the documents say about that item.
- Every finding cites where it came from: document name, section number, page. If you cannot pin the
  page or section, say so in the finding. A finding without a source is not a finding.
- Quote at most a short phrase (under 15 words) from the document, so he can find the spot.
- Never invent what a document says. If a page is unreadable, list it as unreadable.
- Flag, don't fix. You do not decide what is in or out of his scope; you point at it.

## Step 1: Collect and read everything

1. List every file he gave you (if he gave a folder, list the whole folder, including subfolders).
2. Read each one in full. Use the pdf skill for PDFs, the docx skill for Word, the xlsx skill for
   Excel. For long PDFs read in page ranges until you reach the end; do not stop at a summary page.
   Scanned pages: run OCR through the pdf skill (Tesseract is installed) and note which pages were scanned.
3. Build a document inventory: name, date or revision, number of pages, what it is (spec section,
   addendum, scope letter, drawing list, bid form).
4. **Addenda check.** Search every document for references to addenda ("Addendum No.", "Addendum #",
   "issued by addendum"). Compare against the addenda he actually gave you. If any referenced addendum
   is missing, put it at the very top of the report: the review is incomplete until he has it.
5. **Drawing check.** If there is a drawing list, compare it against the drawings provided. Flag any
   listed drawing you did not receive.
6. Later addenda override earlier text. When an addendum changes an item, cite both and say which wins.

## Step 2: Load his context

- Checklist: read `~/.claude/spark/checklist.md`. If it does not exist, use the default copy: this
  skill's base directory (shown when the skill loads) plus `../../defaults/checklist.md`, i.e. the
  `defaults/checklist.md` file next to this plugin's `skills` folder. Tell him in one line if you had
  to fall back to the default.
- Old checklist: if `~/.claude/spark/checklist-spark1.md` exists (his checklist from SPARK 1), read it
  too. Its items count the same; skip any that repeat the main checklist.
- Profile: read `~/.claude/spark/profile.md` if present (trades he does and does not carry, standard
  exclusions). Use it only to judge what is relevant. Never invent its contents; if it is missing,
  carry on without it.

## Step 3: Walk the checklist

For each checklist item, search all documents. Each item lands in exactly one bucket:

- **In the documents, easy to miss.** The documents require it, and it is the kind of thing that
  slips out of a price. Record: what is required, document, section, page, short quote.
- **Silent.** The checklist expects it, the documents say nothing, and it matters for this job. Turn
  it into a question for an RFI.
- **Not relevant.** Skip it silently. Do not pad the report.

Then read for things the checklist does not cover: named products with no alternates allowed,
unusual testing or warranty terms, after-hours or phased work, owner-supplied equipment, work
assigned to "Division 26" inside another division's section (mechanical, architectural, civil),
bid form items (separate prices, alternates, unit prices). Add those to the first bucket.

**Conflicts.** Where two documents disagree (spec vs addendum, spec vs scope letter, spec vs
drawing notes), list both sources side by side. Do not pick one.

## Step 4: Report

Before writing, ask him one question: "Do you want this as a Word report or right here in the chat?"
If he has said before, don't ask again.

Report layout, in this order:

1. **Stop first** (only if needed): missing addenda, missing drawings, unreadable pages.
2. **Easy to miss in pricing.** Grouped by the checklist headings. Inside each group, put the items
   most likely to carry real cost first. Each line: the item, then the source in brackets.
   Shape: "<what is required> [<document>, Section <number>, p. <page>]".
3. **Documents are silent: questions for an RFI.** One line each.
4. **Conflicts between documents.**
5. **Documents read.** The inventory from Step 1, short.

Keep it short: one line per finding, no paragraphs of explanation. For a Word report use the docx
skill, follow `~/.claude/spark/doc-style.md` if present, save it next to the tender files with a name
like "Tender review - <project>.docx", and give him the file as a link. Never overwrite an existing
file; add " (2)" to the name.

## Step 5: Offer the RFI

End with one offer: "Want me to draft the RFI questions?" If yes:

- Number each question. Each one cites the document and section it is about.
- Neutral, factual tone, asking the consultant to confirm scope, not arguing.
- Write in his voice using `~/.claude/spark/voice.md` if present.
- Give it as text he can paste into an email, or a Word file if he asks. Never send anything yourself.

## Remembering misses (the checklist grows)

When he says something like "we missed X on job Y", "add X to the checklist", or "next time check X":

1. Read `~/.claude/spark/checklist.md`. If it does not exist yet, copy the default (path in Step 2) to
   that location first.
2. Pick the heading it belongs under. If none fits, use the closest one; do not create a new heading
   unless he asks.
3. If an item already covers it, do not add a duplicate. Tell him which line already covers it, and
   offer to reword that line instead.
4. Otherwise append one line at the end of that heading's list, phrased as a check, in this shape:
   `- <the check, ending in a question> (added YYYY-MM-DD, missed on <job>)`
   Use today's date. Leave out the "missed on" part if he did not name a job.
5. Edit only that one line. Never rewrite, reorder or delete other lines.
6. Confirm in one plain sentence: what you added and under which heading.

Never edit the default checklist inside the plugin; it is replaced on every update.
