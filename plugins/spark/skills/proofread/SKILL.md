---
name: proofread
description: Last check of a quote, report, letter, email, spreadsheet or slide deck before he sends it. Use when he says "check this before I send it", "proofread this", "anything wrong with this?", "is this ready to go?" or "look this over".
---

# Proofread before sending

You're the second pair of eyes. Find what would embarrass him or cost him money, report it worst first,
and don't touch numbers without asking.

## Read

- Open files through the matching Anthropic skill (docx, pdf, xlsx or pptx: `anthropic-skills:*` or
  `document-skills:*`). Read the whole thing, including headers, footers, tables, comments, speaker notes,
  hidden rows and sheets, and the file's properties (title, author, company).
- Read `~/.claude/spark/profile.md` if present: his correct company name, address, phone, licence number
  and HST number.
- Pasted text (an email): check it as it stands.

## Check

1. **Money and numbers.** Line items add up to subtotals and totals; quantity times rate equals the line
   amount; tax is worked out on the right subtotal at the rate the document states (Ontario HST is 13%);
   the same figure is the same everywhere (summary, table, cover email); amounts in words match the
   figures. Do the arithmetic with a calculation, never by eye.
2. **Units.** Present and consistent: A, V, kVA, kW, AWG, mm, ft or m, hours. No metric and imperial mixed
   for the same thing without a reason. Watch for a unit slip that changes the meaning (V where every
   other line says A).
3. **Dates.** Weekdays match their dates (work it out with a calculation, not from memory). Dates in a
   sensible order (start before finish). A quote's validity hasn't already run out. Right year, especially
   in January. One date format throughout.
4. **Names.** Client, company, site address, people and job or quote numbers spelled the same everywhere.
   His own company details match profile.md.
5. **Leftovers.** `[NEEDS: ...]`, XXX, TBD, TBC, ???, lorem ipsum, "insert here", yellow highlights,
   empty cells meant to be filled, comments, tracked changes not yet accepted.
6. **Old-template traces.** Another client's name, address, job number or project anywhere, including
   the header, footer, file name and file properties. A name that shows up once or twice while the rest of
   the document says another is the usual sign.
7. **Attachments and references.** "See attached", "enclosed", "drawing E-2", "Appendix B", "photos
   below": each one exists, in the document or in the folder he's sending from. If you can't tell, ask.
8. **Spelling.** Canadian: colour, centre, metre, labour, cheque, licence (noun) and license (verb); -ize
   endings are fine. Product and company names keep their own spelling. Typos, doubled words, wrong words
   (their/there, affect/effect, complement/compliment).
9. **Tone.** One clear ask; no apologising for the price; no ALL CAPS or sarcasm; no AI filler ("I hope
   this email finds you well", "seamless", "please don't hesitate"). Use the **plain-writing** skill's
   lists to spot it, but don't rewrite here.

## Report back

A short list, worst first, in up to three groups (leave out empty ones):

- **Fix before sending:** wrong client name, a total that doesn't add up, a missing attachment, a leftover
  placeholder, a wrong date or weekday, an expired validity date.
- **Should fix:** names or units that don't match, spelling, tone.
- **Small stuff:** one line covering formatting nits, unless he asks for detail.

Each item says where (page, section, cell or line) and what, in one line, e.g. "Page 2: the items add up
to a different amount than the total line. Which one is right?"

If you find nothing, say what you checked in one line ("Numbers, dates, names, placeholders, attachments
and spelling all check out.") Don't invent problems to look thorough.

## Fixing

- **Numbers and money: never fix silently.** Show both values and ask which is right.
- Everything else: ask once, "Want me to fix the rest?" If yes, follow the **doc-edit** skill: save a v2
  beside the original, never overwrite, and list what changed. For pasted text, give back the corrected
  version.
