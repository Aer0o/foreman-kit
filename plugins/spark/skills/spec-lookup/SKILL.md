---
name: spec-lookup
description: Look up a part number, catalogue number, rating or spec with a source he can click, or say it couldn't be confirmed. Use for "what's the part number for", "find me the datasheet" or "is this CSA approved".
---

# Spec lookup

He has been burned by made-up part numbers. This skill exists to stop that.

**No catalogue number, part number, rating, dimension, certification or spec value without a source he can
click**: the manufacturer's product page or datasheet (URL), or a page in a document he gave you (file and
page). No source means "couldn't confirm", however confident you are. Memory is not a source.

One fact per line, each labelled **CHECKED** (you read the value on the source yourself; give the link or
file and page) or **NOT CONFIRMED** (no source, or sources disagree; say what you'd search and where).

## How to look things up

1. **His documents first** (specs, drawings, submittals), searched in one pass. Cite file and page.
2. **Then the web**, if search and fetch are available:
   - Several parts: run their searches in the same step, not one after another.
   - Open the page and find the exact value. A search snippet is not enough; they're often stale or for a
     different model.
   - Manufacturer's site and datasheets first. A distributor listing is second best and labelled
     "distributor listing". Stop once a fact is CHECKED on the manufacturer's page.
   - Match the part number character for character; suffixes change the product (voltage, colour, finish,
     mounting, poles). Explain a suffix only from the datasheet's ordering guide, citing the page.
   - A PDF datasheet: read it (WebFetch, or pdfplumber once downloaded), cite the page.
3. **No web tools?** Say so, then give him the exact search words, the manufacturer site, and what to look
   for on the datasheet.

## Canada and Ontario

- Products installed in Ontario need a Canadian mark (CSA, cUL, cETL...). Note which one the source shows.
  "UL" without the small "c" is a US listing only: flag it.
- Confirm the mark from the datasheet or the certifier's listing, not a product photo. No Canadian mark on
  any source: NOT CONFIRMED, and he should ask the supplier for the certificate before ordering.
- Code questions (Ontario Electrical Safety Code): no rule numbers or values from memory. Point him to the
  code book or ESA and say what to look up.

## Equals and substitutions

"Is X equal to Y": key values side by side, each with its own source and label; every difference, and every
value you couldn't confirm for one of them. Never declare them equal: whether an alternate is accepted is
the engineer's call through the spec's approved-equal or substitution process. Say that once.

## Never

Prices or stock levels (those come from his supplier). A "typical" value to fill a gap ("usually 10 kA").
A shortened or cleaned-up part number.

## Answer format

A small table per product:

| What | Value | Status | Source |
|---|---|---|---|
| Catalogue number | (exact, as printed) | CHECKED | (link) |
| Rating | (value with units) | CHECKED | (datasheet link, p. 2) |
| Canadian certification | (mark) | NOT CONFIRMED | search "(terms)" on (site) |

Then one line on anything to double-check with the supplier. Several products: offer once to put them in an
Excel sheet with a Source column.
