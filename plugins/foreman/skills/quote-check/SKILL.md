---
name: quote-check
description: Check his own quote or bid before he sends it: math, HST, markup, scope, addenda, typos. Never changes his numbers. Use for "check my quote", "did I mess up the math" or "is this bid ready".
---

# Quote check

A last look at HIS quote before he submits it. Find problems and say exactly where they are.

- **Never change a number, rate, markup or total**, not even an obvious typo. Report it with its location
  and the arithmetic; he makes the change. Read only. A wording fix he asks for (a name, a date) goes in a
  copy named "<original name> - checked", with every change listed.
- Every finding has a location: "Pricing!F42" for Excel, "p. 2, line 'Fire alarm devices'" for PDF or Word.
- Don't judge his rates or prices. Check the quote agrees with itself, his takeoff and the tender. A "should
  be" figure is only arithmetic on his own numbers, with the sum shown.

## Step 1: Gather

Read the quote in one go: for Excel, one script that dumps every sheet with formulas and values side by
side (a typed number in a column of formulas is a finding); pdfplumber or python-docx for PDF or Word. Read
`~/.claude/foreman/profile.md` too (rates policy, standard exclusions).

Then ask, one at a time, only what he hasn't given you: "Do you have the tender documents or scope letter
for this one?", then "Is there a takeoff I should compare quantities against?" If not, carry on and note
the checks you couldn't do.

## Step 2: The checks

Run all the arithmetic in one script, not cell by cell.

- **Arithmetic:** every extension (quantity x unit price = line total); every subtotal and the grand total
  re-added. In Excel, SUM ranges cover every row above them (a row inserted below the range is a classic
  miss) and no total is typed. Ignore rounding under one cent.
- **HST (13% in Ontario):** applied once, at the end, on the full taxable total, not a subtotal that leaves
  lines out. Not doubled (unit prices already including HST, then HST again). Markup before HST, not after.
  Wording matches the math ("plus HST" with no HST in the total, and vice versa). Anything beyond the rate
  and where it applies: a question for his accountant.
- **Markup:** the same percentage on every line or section unless labelled otherwise; matches profile.md's
  rates policy if it states one; none missing or applied twice.
- **Quantities and units:** with a takeoff, every quantity matches (list both numbers per mismatch). Units
  consistent; metres and feet mixed in one section, or a "lot" line with quantity above 1, is a finding.
- **Labour vs material:** installed items with no labour; labour with no material where material is
  expected; a section whose labour share is far off the rest (give the share you calculated, not what it
  should be).
- **Scope:** with tender documents, every division or section in scope is priced or named in the
  exclusions; every bid form item (separate prices, alternates, unit prices) is answered. An exclusions and
  clarifications section exists. Flag any exclusion that contradicts the spec, quoting the spec section.
  Every addendum issued is acknowledged; if you don't know how many were issued, ask once.
- **Paperwork:** validity date present, not past, and at least the tender's irrevocability period. Client,
  project, address and tender number spelled the same everywhere and as in the tender, headers, footers and
  cover letter included. Quote date current; no leftovers from an older quote.

## Step 3: Report

One opening sentence: "Ready to send" or "Not yet: N things to fix first".

Findings ranked by money at risk, biggest first. Show the dollar difference when his own numbers give it.
An unpriced scope gap is marked "not priced" and goes near the top. Wording and typos last. One line each:
what, where, the numbers, e.g. "Line total does not match quantity times unit price [Pricing!F42: shows X,
quantity x price = Y]".

End with a short "Could not check" line (no takeoff, no tender, unreadable page). Keep it in the chat unless
he asks for a file; then build it in one python-docx script and give him the link.
