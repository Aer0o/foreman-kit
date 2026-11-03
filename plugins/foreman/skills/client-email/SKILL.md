---
name: client-email
description: Write an email or letter to a client, GC, supplier or inspector in his own voice. Use for "write an email to", "chase this payment", "tell the GC we're delayed" or "reply to this".
---

# Emails and letters in his voice

Read first, if present: `~/.claude/foreman/voice.md` (greeting, sign-off, length, tone, phrases he uses and
never uses; `FOREMAN:BLANK` or empty lines mean no voice on file) and `~/.claude/foreman/profile.md` (company,
phone, who signs).

**No voice on file:** write plain and short. After the first draft, offer once: "Want me to learn how you
write? Paste two or three emails you've sent, any topic." Note greeting, sign-off, length, tone, repeated
phrases and things he never does; write them into voice.md, remove `FOREMAN:BLANK`, show him three lines of
what you learned. Never copy client names, amounts or private details into it.

## Every email

- **Short:** most under 120 words; a letter fits on one page.
- **Open with the point.** No "I hope this email finds you well", "I wanted to reach out", "just following
  up", "please don't hesitate to contact me", "thank you for your patience".
- **One ask** near the end, with a date when there is one ("Can you confirm by Friday, Nov 13?"); check
  the weekday with a calculation.
- **Specific:** site, invoice or quote number, amount, dates, all from what he gave you; missing ones
  become `[NEEDS: invoice number]`.
- **Subject says what it is:** "Invoice [number] for <site> is overdue".
- **Polite and firm:** no apologising for charging, no threats he didn't ask for, no ALL CAPS, exclamation
  marks only if his voice uses them.
- **No legal claims:** no laws, contract clauses or code rules unless he gave you the text. If he wants
  legal pressure, write what he says and note once that you can't give legal advice.
- Active voice, one idea per sentence, no AI words (delve, robust, seamless, leverage). Then match voice.md.

## Patterns (starting points; vary the wording)

- **Chasing payment:** invoice number, amount, original due date; ask for payment by a date, or the date
  it will be paid. First reminder friendly; a second firmer, naming the next step he chose (pausing work,
  interest per his terms). Attach the invoice and say so.
- **Change order:** what changed, who asked and when, the extra work, cost and time (his figures only).
  Ask for written approval before the work goes ahead.
- **Delay notice:** what, why (facts, not blame), the new date or when he'll know, what he needs from them.
- **Quote cover:** what it covers in one line, the total if he wants it shown, exclusions worth pointing
  out, validity, next step. Attach the quote.
- **Declining a job:** thanks, a short reason or none, the door left open if he wants. Two to four sentences.
- **Asking for information:** why in one line, items numbered, the date needed. One ask: "send these".
- **Replying:** answer their question in the first line.

## Letters

A formal letter (delay notice to an owner, deficiency response, reference letter) is a Word file built by
ONE python-docx script: letter size, styled from `~/.claude/foreman/doc-style.md` (its Calibri
fallback if it says Aptos), letterhead from profile.md on page 1, then date, recipient and address, "Re:"
line, body, signer. Save as "Letter - <recipient> - <date>.docx". Convert and render in one command and
look once:
`soffice --headless --convert-to pdf --outdir "<scratch>" "<file>"; pdftoppm -png -r 50 "<scratch>\<name>.pdf" "<scratch>\p"`
Offer a PDF copy (the check made one; copy it beside the letter).

## Handing it over

Subject on its own line, then the body as plain text to paste into Outlook (no bold or bullet symbols;
"1." numbering if needed). Under it: any `[NEEDS]` items and what to attach. He sends it; you never do.

## When he changes a draft

"Too stiff", "I'd never say that" or a rewritten line: fix the draft, add a dated line to voice.md under
"Notes from corrections" or "Phrases he never uses", and tell him: "Got it, I'll write it that way from
now on."
