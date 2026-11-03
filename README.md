# Foreman

A Claude Code kit for document work in the electrical trade: reports, document design, editing,
proofreading, emails, tender review, quote checks, spec lookups and PDF-to-Excel. Built for one person who
uses Claude Code in the Windows desktop app and doesn't write code.

## What's in it

- **12 skills** in `plugins/foreman/skills/`. Seven are for documents: report-writer, doc-design, doc-edit,
  proofread, client-email, plain-writing and chart-craft. Four are for estimating: tender-review,
  quote-check, spec-lookup and doc-to-excel. The last, foreman-setup, handles setup and repair.
- **Hooks**, in PowerShell:
  - At session start, load the rules and the company profile.
  - Route plain requests to the right skill.
  - Copy any document before a command touches it.
  - Send back answers with part numbers that have no source.
- **Plain Office**, an output style: no code on screen, files given as links.
- **An installer**: installs LibreOffice, Poppler, pandoc, Python and Node through winget, sets up the
  plugin, moves an older SPARK 1 setup over, and runs a self-test.

Word, PDF, PowerPoint and Excel file handling comes from Anthropic's own document skills, which this kit
does not include.

## Install

Download the zip (`dist/Foreman.zip`, or the `installer` folder from the repo download), unblock it, unzip it, and double-click `Install Foreman.bat`. See
`installer/READ ME FIRST.txt`.

## Licence

MIT, except `plugins/foreman/skills/plain-writing`. It is adapted from stop-slop by Hardik Pandya and
keeps its own MIT licence file.
