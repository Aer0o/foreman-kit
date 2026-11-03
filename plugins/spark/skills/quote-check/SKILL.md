---
name: quote-check
description: Use when he wants a last look at his own quote or bid before sending it (Excel, PDF or Word), e.g. "check my quote", "look over this before I send it", "did I mess up the math", "is this bid ready". Checks math, HST, markup, scope, addenda and typos; never changes his numbers.
---

# Quote check

A last glance at HIS quote before he submits it. You find problems and say exactly where they are.
You do not change his numbers.

## Hard rules

- **Never change a number, a rate, a markup or a total** in his file. Not even an obvious typo. You
  report it with its location and the arithmetic; he makes the change.
- Never open his file for writing. Read only. If he asks you to fix a wording typo (a name, a date),
  do it in a copy named "<original name> - checked" and list every change. Money stays his to change.
- Every finding gives a location he can go to: sheet and cell for Excel ("Pricing!F42"), page and line
  item for PDF or Word ("p. 2, line 'Fire alarm devices'").
- Do not judge whether his rates or prices are right. You check that the quote is consistent with
  itself, with his takeoff and with the tender. Pricing judgment is his.
- Never invent a figure. When you show what a number "should be", it is only the arithmetic of numbers
  already in his file, and you show the sum you did.

## Step 1: Gather

Read the quote: the xlsx skill for Excel (read both the formulas and the values: a typed number where
the rest of the column uses formulas is itself a finding), the pdf skill for PDF, the docx skill for Word.

Then ask, one question at a time, only for what he has not already given you:
1. "Do you have the tender documents or the scope letter for this one?"
2. "Is there a takeoff I should compare quantities against?"
If he says no, carry on and note which checks you could not do.

Also read `~/.claude/spark/profile.md` if present (rates policy, standard exclusions, how he
normally lays out a quote). Never invent its contents.

## Step 2: The checks

**Arithmetic**
- Every extension: quantity times unit price equals the line total.
- Every subtotal and the grand total: re-add them yourself. In Excel, check that SUM ranges cover all
  the rows above them (a row inserted below the range is a classic miss) and that no total is a typed
  number.
- Ignore rounding under one cent. Report anything bigger.

**HST (13% in Ontario)**
- Applied once, at the end, on the full taxable total. Not on a subtotal that leaves lines out.
- Not applied twice (for example, unit prices that already include HST and then HST added again).
- Markup goes on before HST, not after.
- The wording matches the math: a quote that says "plus HST" should not show a total with HST
  already in it, and vice versa.
- Anything beyond the rate and where it applies is a question for his accountant. Say so.

**Markup and rates**
- The same markup percentage on every line or section, unless the quote labels a different one.
- Matches the rates policy in profile.md if that file states one.
- No line where markup is missing or applied twice.

**Quantities and units**
- If a takeoff was given: every quote quantity matches it. List each mismatch with both numbers.
- Units are consistent (each, metres, feet, lot). Metres and feet mixed in one section is a finding.
  A "lot" line with a quantity above 1 is a finding.

**Labour vs material**
- Lines with installed items but no labour. Lines with labour but no material where material is expected.
- Sections where the labour share is far off from the rest of the quote. Flag the outlier with the
  share you calculated; do not say what it should be.

**Scope**
- If tender documents were given: every division or section in the tender scope is priced or is
  named in the exclusions. Every bid form item (separate prices, alternates, unit prices) has an answer.
- Exclusions and clarifications section is present. Flag any exclusion that contradicts the tender
  (excluding something the spec puts in his scope) and quote the spec section.
- Addenda acknowledged: the quote lists every addendum issued. If you do not know how many were
  issued, ask him once.

**Paperwork**
- Validity date present, not already past, and at least as long as any irrevocability period the
  tender requires.
- Client name, project name, address and tender number spelled the same everywhere, and the same as
  in the tender documents. Check headers, footers and the cover letter too.
- Date on the quote is current. Leftovers from an older quote (another project name, an old date,
  another client) are a finding.

## Step 3: Report

Start with one sentence: "Ready to send" or "Not yet: N things to fix first".

Then list findings ranked by money at risk, biggest first:
- If you can compute the dollar difference from his own numbers, show it.
- If it is a scope gap that is not priced at all, mark it "not priced" and put it near the top.
- Pure wording or typo findings go last.

Each finding is one line: what is wrong, where it is, and the numbers involved. Example shape:
"Line total does not match quantity times unit price [Pricing!F42: shows X, quantity x price = Y]".

End with a short "Could not check" line listing anything skipped (no takeoff, no tender, unreadable page).

Keep it in the chat unless he asks for a file. If he asks for one, use the docx skill and give him the
file as a link.
