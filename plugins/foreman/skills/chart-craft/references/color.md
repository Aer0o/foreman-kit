# Colour for charts: palettes, codes, and how to apply them

Colour is the loudest thing on a chart. Use it to carry meaning, never to decorate. First decide: is this
a point, a set of categories, or a scale?

## 1. Making a point: grey plus one accent

Set every series or bar to a neutral grey, then set the one element the chart is about to a single strong
accent. The eye goes straight to it.

- Neutral greys, light to dark: `#E6E6E6` `#C9C9C9` `#9A9A9A` `#6B6B6B` `#3D3D3D`
- Accent: his brand colour from `~/.claude/foreman/profile.md`, if it stands out clearly against the greys
  and against white. A very light brand colour (pale yellow, light green) won't; use a darker accent and
  keep the brand colour for the document around the chart.
- No brand colour on file, or it doesn't work: pick one of these and tell him which:
  teal `#0C6E63` · amber `#C8873A` · deep blue `#0072B2` · vermillion `#D55E00` · plum `#8E4585`
- Same accent across a whole deck or report, so "the colour" always means the same thing.

## 2. Categories with no winner: colour-blind-safe palette

For series that are genuinely different things with no ranking (trades, suppliers, buildings). Six at
most; beyond that, group the tail into "Other" or use a table.

**Okabe-Ito**, readable for the common types of colour blindness and in greyscale. Use in this order:

| Order | Name | Code |
|---|---|---|
| 1 | Orange | `#E69F00` |
| 2 | Sky blue | `#56B4E9` |
| 3 | Bluish green | `#009E73` |
| 4 | Yellow | `#F0E442` |
| 5 | Blue | `#0072B2` |
| 6 | Vermillion | `#D55E00` |
| 7 | Reddish purple | `#CC79A7` |
| 8 | Black | `#000000` |

## 3. A scale: one colour, light to dark; opposites: two colours

- **Low to high** (hours, cost, count): shades of one colour, e.g. blues from `#F7FBFF` to `#08306B`.
  Prints fine in greyscale.
- **Above and below a middle** (over and under budget, ahead and behind schedule): two colours from a
  neutral middle, blue against red, or purple against green. Only when the data really has a middle.
- **Never red against green alone.** About 8% of men can't tell them apart. For anything that matters
  (money, safety, pass and fail) add labels or values, not just colour.

## Contrast floor

- Labels and key marks need real contrast against the background (about 4.5:1 for text).
- Colour is never the only signal; pair it with position, a direct label, or the value itself.
- Check the rendered page in greyscale once. If the point survives, it works on a black-and-white printer
  and for colour-blind readers.

## Applying it in Excel and PowerPoint

- Recolour the **chart**, not the workbook theme: select a series, Format, Fill, More Colours, Custom, and
  enter the code. Repeat only for the accent series.
- When building with openpyxl or python-pptx, set each series colour explicitly; never rely on the
  default colour cycle.
- A finished chart can be saved as a chart template (right-click, Save as Template) so the next one starts
  clean.

## The one-line rule

Grey everything, colour the point. Real categories: Okabe-Ito, stop at six. A scale: one colour, light to
dark. Never let the tool choose.
