---
name: report-writer
description: Write a report from his notes, photos, drawings or files - site reports, inspection or condition reports, project summaries, close-out reports and proposals. Use when he says "write up a report", "turn my notes into a site report", "I need a proposal for this job", "summarize this job for the owner" or "write up what we found".
---

# Report writer

Turns his notes, photos and numbers into a finished Word report that leads with the answer.

Read first, if present: `~/.claude/spark/profile.md` (company name, address, licence number, logo, who signs)
and `~/.claude/spark/doc-style.md` (how documents look). Use what's there; never invent what isn't.

## 1. Ask at most three questions

Ask only what you can't tell from what he gave you. One question at a time, short:

1. Who reads it? (owner, GC, property manager, inspector, insurer, his own files)
2. What decision does it support? (approve extra work, fix deficiencies, release a payment, accept the proposal)
3. When is it due, and how long should it be? (one page, or a full report with photos)

If the answer is obvious ("site report for the GC on today's visit"), skip that question.

## 2. Show the outline first

Pick the shape below, adjust it to what he actually has, and show it in a few lines: each heading plus one
line on what goes under it. Ask "Look right?" and wait. If he said "just write it", skip this step.

| Report | Shape |
|---|---|
| Site report | Summary · date, site, who attended · work done or observed · issues and deficiencies · actions (who, by when) · photos |
| Inspection or condition | Summary and recommendations by urgency · what was inspected and the limits · findings by area or system · recommendations (urgent / soon / plan for) · photos |
| Project summary or close-out | Outcome in two lines · scope delivered · changes and extras · schedule · cost against budget (his figures) · open items, warranty |
| Proposal | What we propose and the price summary · scope · inclusions · exclusions and clarifications (from profile.md) · schedule · terms and validity · acceptance |

## 3. Draft

- **Answer first.** The opening section says what was found and what you recommend, in plain sentences.
  Someone who reads only page one should know what to do and by when.
- **Every number has a source.** Keep a private list of where each number, date, name, model and
  measurement came from (file and page, photo, or "his message"). If one is missing, write
  `[NEEDS: what is missing]` in the text. Never estimate, round, or fill a gap with a typical value.
- **No code citations from memory.** Never cite an electrical code rule, standard or bulletin by number
  unless he gave you the reference. Write `[NEEDS: code reference]` instead.
- **Findings:** one per paragraph or table row. Where it is, what it is, why it matters, what to do.
- **Photos:** place each next to the finding it shows, with a short caption (where, and what it shows).
  Don't describe anything the photo doesn't show.
- **Money:** totals come from his line items, and the report shows the sum. If his figures don't add up,
  don't correct them; flag it to him.
- **No words in his mouth.** Don't add commitments, recommendations or options he didn't state ("we will
  price that separately", "a sub-panel may be needed"). If one seems worth saying, put it in as
  `[SUGGEST: ...]` with yellow highlighting and list it for him to keep or cut.
- Write as the company ("we"), Canadian spelling, his terms for things.
- Run the **plain-writing** skill on the text before building the file.

## 4. Build the Word file

The file work goes through Anthropic's docx skill (`anthropic-skills:docx` or `document-skills:docx`,
whichever is available). Don't write the Word format by hand.

- Style it from `~/.claude/spark/doc-style.md`. The **doc-design** skill and its house-style reference
  explain how to apply it: letter-size paper, header and footer, tables, logo.
- Give every `[NEEDS: ...]` placeholder yellow highlighting so he can't miss it.
- File name in plain words: "Site report - <site> - <date>.docx". Save it in the folder his source files
  came from; if there's no obvious folder, ask where. Temporary files go in a scratch folder.

## 5. Check before saying done

1. **Numbers:** walk your source list. Every number in the report matches its source, every total adds up
   (do the arithmetic with a calculation, not by eye).
2. **Look at it:**
   - Convert: `soffice --headless --convert-to pdf --outdir <scratch folder> "<report.docx>"`. Call soffice
     directly; Anthropic's soffice.py wrapper is Linux-only.
   - Render: `pdftoppm -png -r 80 "<report.pdf>" "<scratch folder>\page"`.
   - Open the PNGs and look: overlapping text, tables running off the page, photos too big or split,
     headings stranded at the bottom of a page, empty pages, wrong fonts. Fix, re-render, look again,
     **two rounds at most**. Fix breakage, not polish; every round uses his plan.
   - Long report: check page 1, every page with a table or photo, and the last page.
   - If soffice or pdftoppm is missing, don't claim the check. Tell him: "I couldn't preview the pages on
     this PC. Double-click Fix SPARK in the SPARK folder, then ask me again."
3. **Tell him**, in a few lines: the report as a link, how many pages, and every `[NEEDS]` and `[SUGGEST]`
   item as a short list so he can fill them in or cut them.
4. **Offer a PDF:** "Want a PDF copy to send?" If yes, convert into the same folder as the Word file and
   give that link too.

Before he sends it, offer the **proofread** skill as a last check.
