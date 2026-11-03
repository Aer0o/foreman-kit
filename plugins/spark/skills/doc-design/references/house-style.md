# House style: how to apply it

The values (font, sizes, spacing, margins, footer, slide rules) live in `~/.claude/spark/doc-style.md`,
with his corrections at the bottom overriding the list. This file says how to apply them. Fallbacks here
apply only when doc-style.md or profile.md is silent.

## Fonts

- One font family for everything: body, headings, tables, header, footer, slides. Size and weight make the
  hierarchy, not extra fonts.
- Aptos is the current Office default, but on some PCs it's a download-on-demand cloud font that
  LibreOffice (and older Office) can't see. Look for an Aptos file in `C:\Windows\Fonts` or
  `%LOCALAPPDATA%\Microsoft\Windows\Fonts`. If it isn't there, use the fallback in doc-style.md (Calibri)
  so the preview, the PDF and the person receiving it all see the same thing.
- Last resort if neither is installed: Segoe UI, which every Windows PC has.
- PDF export embeds the font, so a PDF looks the same on any machine.

## Page setup (Word)

- **Letter size**, portrait (8.5 x 11 in; Canada uses letter, not A4). Anthropic's docx tooling can default
  to A4, so set the page size explicitly (12240 x 15840 twips).
- Margins from doc-style.md on all four sides (2 cm is about 1134 twips).
- Use **styles**, not direct formatting: set Normal, Title, Heading 1, Heading 2 and Caption to the
  doc-style.md sizes. One change then updates the whole document, and Word's navigation pane works.
- Line spacing and space-after go on Normal. Headings get about twice as much space above as below, and
  "keep with next" so a heading never sits alone at the bottom of a page.
- Text left-aligned, ragged right. No justified text. Centre nothing except, at most, a cover title block.
- Real bullet and numbered lists with a hanging indent; one level deep where possible.

## Header, footer, first page

- Footer as doc-style.md says: company name left, "Page X of Y" right, using real page-number fields (never
  typed numbers), caption size, dark grey.
- If profile.md has an ESA/ECRA licence number, add it to the footer of client-facing documents next to
  the company name.
- First page: logo top left from the profile.md path, sized by height (about 1.5 to 2 cm tall), never
  stretched. Below it: document title, client and site, date. Turn on "different first page" so a running
  header doesn't repeat on page 1.
- Pages 2 onward: an optional quiet header with the document title in caption size, grey.
- Letters: letterhead block (logo, company name, address, phone, email) on page 1 only.

## Colour

- One accent: the brand colour from profile.md. Use it where doc-style.md says (headings, table header
  text) plus at most one thin rule under the title. Nowhere else.
- Body text near-black (#1A1A1A), secondary text dark grey (#595959).
- Check the accent is dark enough to read as text on white (contrast about 4.5:1). Yellows, light greens
  and oranges usually fail. If it fails, use near-black for heading text and keep the brand colour for the
  title rule and chart highlights only. Tell him why in one line.
- No brand colour on file: use dark slate (#2F3B45) and tell him.

## Tables

- Thin rules: 1 pt line under the header row, 0.5 pt light grey (#BFBFBF) lines between rows (or none on a
  short table). No vertical lines, no outer box.
- Header row: bold, accent-coloured text, set to repeat on every page. No fill, or a very light grey
  (#F2F2F2). No fills on body rows, no zebra stripes.
- Numbers right-aligned, same number of decimals down a column, units in the column header rather than in
  every cell. Text left-aligned.
- Totals row bold, with a 1 pt rule above it.
- Cell padding about 0.1 in so text never touches a rule. Rows don't split across pages.
- Table width equals the text width, never past the margin. Set column widths explicitly; the description
  column takes the slack.

## PowerPoint

- 16:9. Slide rules from doc-style.md: one idea per slide, the title states the point, at most five short
  bullets, body text no smaller than the minimum size.
- Titles left-aligned and in the same position on every slide. Same font as his documents.
- Brand colour on the title or one thin accent bar, and on the highlighted item in a chart. White or very
  light background.
- Logo small in one corner, or only on the title and closing slides.
- For site work, one good photo with a title that says what it shows beats a slide of bullets.

## Photos and images

- Fit within the text width, keep the aspect ratio, never stretch.
- Shrink large phone photos (about 1600 px on the long side is plenty) so the file can be emailed.
- Caption under each photo, caption size: what and where.
- Many photos: two per row in a borderless two-column table.

## Anti-patterns: remove on sight

- Clip-art, stock icons, WordArt, shadows, glow, bevels, 3D effects, gradients, decorative page borders.
- Centred body text or everything centred. Justified text.
- More than one font family. Underlining for emphasis. Paragraphs in ALL CAPS.
- Walls of bold, or whole sentences in bold. Bold a key figure or a label, sparingly.
- Emoji anywhere.
- Rainbow charts or tables, a coloured fill on every row, heavy black grid lines on every cell.
- Several accent colours, or the brand colour plus Office's default blues.
- Blank lines, spaces or tabs used for layout. Typed page numbers. Headings made from bold body text.
- Floating text boxes over content, stretched logos, shrinking body text below the doc-style.md size to
  squeeze something onto a page.

## Preview checklist (look at the rendered PNGs)

- Nothing overlaps; nothing runs past a margin or off the page.
- No heading stranded at the bottom of a page, no table row split, no near-empty page.
- Tables fit the width, and the header row repeats on continued tables.
- Logo crisp and in proportion; photos not cut off.
- "Page X of Y" correct and the footer on every page; first-page header right.
- One font throughout; the accent shows only where intended; all text readable.
- Any `[NEEDS: ...]` highlights still visible.
