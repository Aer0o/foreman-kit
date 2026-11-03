---
name: client-email
description: Write an email or letter to a client, GC, supplier, inspector or property manager in his own voice. Use when he says "write an email to", "chase this payment", "tell the GC we're delayed", "send the quote over", "say no to this job", "ask them for the drawings", "reply to this" or "write a letter to".
---

# Emails and letters in his voice

Read first, if present:

- `~/.claude/spark/voice.md`: his greeting, sign-off, length, tone, phrases he uses and phrases he never
  uses. If it still contains `SPARK:BLANK`, or its lines are empty, there's no voice on file yet.
- `~/.claude/spark/profile.md`: company name, phone, who signs.

## No voice on file yet

Write plain and short. After the first draft, offer once: "Want me to learn how you write? Paste two or
three emails you've sent, any topic." From them, note greeting, sign-off, typical length, tone, phrases he
repeats and things he never does. Write those into voice.md, remove the `SPARK:BLANK` line, and show him
three lines of what you learned. Never copy client names, amounts or private details into voice.md.

## Every email

- **Short.** Most emails under 120 words. A letter fits on one page.
- **Open with the point.** No "I hope this email finds you well", "I wanted to reach out", "just
  following up", "please don't hesitate to contact me", "thank you for your patience".
- **One ask**, stated plainly near the end, with a date when there is one ("Can you confirm by Friday,
  Nov 13?"). Check the weekday against the date with a calculation.
- **Specific.** Site, invoice or quote number, amount, dates, all from what he gave you. Anything missing
  becomes `[NEEDS: invoice number]`. Never invent a number, date or name.
- **Subject line says what it is**, e.g. "Invoice [number] for <site> is overdue".
- **Polite and firm.** No apologising for charging for work. No threats he didn't ask for. No ALL CAPS.
  Exclamation marks only if his voice uses them.
- **No legal claims.** Don't quote laws, contract clauses or code rules unless he gave you the text. If he
  wants legal pressure, write what he tells you and say once that you can't give legal advice.
- Run the **plain-writing** skill on the draft, then match it to voice.md: his greeting, his sign-off,
  his length, his phrases.

## Patterns

Starting points, not templates. Vary the wording from one email to the next.

- **Chasing payment.** Invoice number, amount, original due date. Ask for payment by a date, or for the
  date it will be paid. First reminder friendly; a second one firmer and names the next step he chose
  (for example pausing work, or interest as his terms state). Attach the invoice and say so.
- **Change order or extra work.** What changed, who asked for it and when, the extra work, cost and time
  impact (his figures only). Ask for written approval before the work goes ahead.
- **Delay notice.** What's delayed, why (facts, not blame), the new date or when he'll know, and what he
  needs from them. Sent as soon as he knows.
- **Quote cover email.** What the quote covers in one line, the total if he wants it in the email, the
  exclusions or assumptions worth pointing out, how long it's valid, the next step. Attach the quote.
- **Declining a job.** Thanks, a short reason or none, and the door left open if he wants that. Two to
  four sentences.
- **Asking for information.** Why you need it in one line, the items numbered if there's more than one,
  and the date you need them by. Still one ask: "send these".
- **Replying.** Answer their question in the first line.

## Letters

For a formal letter (delay notice to an owner, response to a deficiency list, reference letter), build a
Word letter with Anthropic's docx skill (`anthropic-skills:docx` or `document-skills:docx`) on his
letterhead, styled from `~/.claude/spark/doc-style.md` as the **doc-design** skill describes: date,
recipient and address, a "Re:" line, body, signer from profile.md. Save as "Letter - <recipient> -
<date>.docx", then check it: `soffice --headless --convert-to pdf --outdir <scratch folder> "<file>"`
(call soffice directly; Anthropic's soffice.py wrapper is Linux-only) and
`pdftoppm -png -r 80 "<file.pdf>" "<scratch folder>\page"`, and look at the page before saying it's done.
Offer a PDF copy.

## Handing it over

- Subject on its own line, then the body as plain text he can copy straight into Outlook. No bold and no
  bullet symbols inside the email; use "1." style numbering if a list is needed.
- Under it: any `[NEEDS]` items, and what to attach.
- He sends it. You never send anything.

## When he changes a draft

If he says "too stiff", "I'd never say that" or rewrites a line, fix the draft, then add a dated line to
voice.md under "Notes from corrections" or "Phrases he never uses". Tell him in one line: "Got it, I'll
write it that way from now on."
