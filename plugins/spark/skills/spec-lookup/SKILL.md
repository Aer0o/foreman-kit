---
name: spec-lookup
description: Use when he asks about a part number, catalogue number, product, rating or spec value, e.g. "what's the part number for", "find me the datasheet", "is this CSA approved", "what's the rating on", "is X equal to Y". Every answer comes with a source he can click, or it says it couldn't be confirmed.
---

# Spec lookup

He has been burned by made-up part numbers. This skill exists to stop that.

## The hard rule

**No catalogue number, part number, rating, dimension, certification or spec value without a source
he can click.** A source is one of:
- a manufacturer's product page or datasheet (URL), or
- a page in a document he gave you (file name and page number).

If you cannot find a source, the answer is "couldn't confirm", not your best guess. This applies even
when you are confident from memory. Memory is not a source.

## Labels

Mark every fact you give him:
- **CHECKED**: you read the value on the source page yourself. Give the link (or file and page).
- **NOT CONFIRMED**: no source found, or sources disagree. Say what you would search and where.

Never mix the two in one line. One fact per line.

## How to look things up

1. **Documents first.** If he gave specs, drawings or submittals, search them first. Cite file and page.
2. **Then the web**, if web search and web fetch are available in this session:
   - Search, then **open the page** and find the exact value on it. A search result snippet is not
     enough; snippets are often out of date or from a different model.
   - Prefer the manufacturer's own site and its datasheets or spec sheets (often PDFs). Distributor
     listings are second best: label them "distributor listing" because they are often wrong or stale.
   - Match the part number exactly, character for character. Suffixes change the product (voltage,
     colour, finish, mounting, number of poles). Explain a suffix only if the manufacturer's ordering
     guide on the datasheet says what it means, and cite that page.
   - If the datasheet is a PDF, read it with the pdf skill and cite the page.
3. **No web tools in this session?** Say so plainly, then give him: the exact words to search, the
   manufacturer site to search on, and what to look for on the datasheet.

## Canada and Ontario

- Products installed in Ontario need a Canadian certification mark. Note which mark the source shows
  (for example CSA, cUL, cETL). "UL" without the small "c" is a US listing only: flag it.
- Confirm the mark from the datasheet or the certifier's online listing, not from a product photo.
- If no Canadian mark is shown on any source, mark certification NOT CONFIRMED and tell him to ask
  the supplier for the certificate before ordering.
- Code questions (what the Ontario Electrical Safety Code requires): do not quote rule numbers or
  values from memory. Point him to the code book or to ESA, and say what to look up.

## Equals and substitutions

When he asks "is X equal to Y":
- Put the key values side by side, each with its own source and label.
- Point out every difference you find, and every value you could not confirm for one of the two.
- Never declare them equal. Whether an alternate is accepted is the engineer's call, through the
  approved-equal or substitution process in the spec. Say that once.

## Never

- Never give prices or stock levels. Prices come from his supplier.
- Never fill a gap with a "typical" value ("usually 10 kA", "most are 4 inch"). Typical is a guess.
- Never shorten or "clean up" a part number. Copy it exactly as the source shows it.

## Answer format

Short. A small table per product works well:

| What | Value | Status | Source |
|---|---|---|---|
| Catalogue number | (exact, as printed) | CHECKED | (link) |
| Rating | (value with units) | CHECKED | (datasheet link, p. 2) |
| Canadian certification | (mark) | NOT CONFIRMED | search "(terms)" on (site) |

Then one line on anything he should double-check with the supplier. If he looks up several products,
offer once to put them in an Excel sheet (the doc-to-excel skill, with the sources in a column).
