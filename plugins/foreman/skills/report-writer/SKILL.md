---
name: report-writer
description: Write a site, inspection, close-out or project report, or a proposal, from his notes, photos and files. Use for "write up a report", "turn my notes into a site report" or "I need a proposal".
---

# Report writer

Turns his notes, photos and numbers into a finished Word report that leads with the answer.

## 1. Gather in one go

In one round of reads: everything he gave you, `~/.claude/foreman/profile.md` (company, address, licence
number, logo, signer) and `~/.claude/foreman/doc-style.md` (the look). No folder listings or tool checks.

Ask only what you can't tell, one question at a time, three at most: who reads it (owner, GC, property
manager, inspector, insurer, his files); what decision it supports (approve extra work, fix deficiencies,
release a payment, accept the proposal); how long (one page, or full with photos). Skip what the request
already answers.

Show an outline (headings plus one line each, then "Look right?") only if the report will run past two
pages or he asked to see it first. Otherwise write it. Shapes:

| Report | Shape |
|---|---|
| Site report | Summary; date, site, who attended; work done or observed; issues and deficiencies; actions (who, by when); photos |
| Inspection or condition | Summary and recommendations by urgency; what was inspected and the limits; findings by area or system; recommendations (urgent / soon / plan for); photos |
| Project summary or close-out | Outcome in two lines; scope delivered; changes and extras; schedule; cost against budget (his figures); open items, warranty |
| Proposal | What we propose and the price summary; scope; inclusions; exclusions and clarifications (from profile.md); schedule; terms and validity; acceptance |

## 2. Write

- **Answer first:** what was found and what to do, by when. Page one alone should be enough.
- Keep a private source list for every number, date, name, model and measurement (file and page, photo,
  "his message"). No estimates, rounding or typical values.
- No code rule, standard or bulletin number unless he gave the reference: `[NEEDS: code reference]`.
- One finding per paragraph or table row: where, what, why it matters, what to do.
- Each photo beside the finding it shows, captioned where and what. Don't describe what it doesn't show.
- Totals come from his line items; if they don't add up, flag it, don't correct.
- **No words in his mouth.** Commitments, recommendations or options he didn't state ("we will price that
  separately", "a sub-panel may be needed") go in as `[SUGGEST: ...]` for him to keep or cut.
- "We" as the company, Canadian spelling, his terms. Lead with the point, cut filler and stock phrases,
  active voice, one idea per sentence, no AI words (delve, robust, comprehensive). Findings flat;
  recommendations as instructions ("Replace the two scorched breakers").

## 3. Build it with one script

Write ONE script that builds the whole report with python-docx and run it once. Never create
the file and then patch it with many small edits; to fix anything, change the script and rerun it.

Values from doc-style.md (lines under "His corrections" win); colour and logo from profile.md:

- Letter size set explicitly (12240 x 15840 twips; the tooling defaults to A4), margins from doc-style.md.
- Font: if doc-style.md says Aptos, use its fallback (Calibri) unless a correction asks for Aptos (often a
  cloud font the preview can't see). Don't search font folders.
- Real styles (Title, Heading 1 and 2 with keep-with-next, Caption), real lists, left-aligned text.
- Tables: bold header row in the accent colour, repeating on each page; thin grey rules, no vertical lines
  or fills; numbers right-aligned; rows don't split; full text width.
- Footer: company name (plus licence number if on file) left, "Page X of Y" fields right. Logo top left on
  page 1, sized by height (1.5 to 2 cm), different first page.
- Photos within the text width, aspect kept, long side about 1600 px; many photos two per row in a
  borderless table.
- Accent: brand colour; too light to read as text, near-black headings. None on file: #2F3B45, say so in
  one line.
- Every `[NEEDS]` and `[SUGGEST]` highlighted yellow.
- "Site report - <site> - <date>.docx" in the folder his files came from (ask if none). Temp files in scratch.

## 4. Check once

1. Have the script (or one calculation) check every total against your source list.
2. Convert and render in one command:
   `soffice --headless --convert-to pdf --outdir "<scratch>" "<report.docx>"; pdftoppm -png -r 50 "<scratch>\<name>.pdf" "<scratch>\p"`
   Look at page 1, pages with a table or photo, and the last page: overlaps, tables off the page, photos
   split or too big, stranded headings, empty pages. Real breakage only: fix the script, rebuild,
   re-render, once. To read small text, re-render one page at `-r 100 -f N -l N`.
   **Page limit:** if a one-page report spills over, make ONE fix that cuts with room to spare (tighter
   wording, smaller table text, less spacing). Still over after that: stop, deliver it, and ask "It runs onto
   a second page. Want me to cut something?" Never keep re-rendering to squeeze it.
3. Tell him: the link, the page count, and each `[NEEDS]` and `[SUGGEST]` as a short list.
4. "Want a PDF copy to send?" The check already made one; copy it beside the Word file.

Before he sends it, offer the **proofread** skill as a last check.
