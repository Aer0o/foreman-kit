---
name: chart-craft
description: Make clear, honest charts and data slides in Excel, PowerPoint or Word. Use for "make a chart of this", "graph these numbers", "put this in a slide" or "it looks like default Excel".
---

# Chart craft

Decide what the chart should say, then make it look deliberate instead of default. File work goes through
openpyxl or python-pptx (in Word, a picture of the chart, or the docx skill if it must stay editable). Build **native, editable charts** so he can change the numbers later; a
picture of a chart only when the target can't hold one. In code, set an explicit palette.

## 1. Write the sentence first

"This chart shows that ______", e.g. "Labour is most of the cost on this change order", "We're behind on
rough-in but ahead on trim-out". It picks the type, the highlight and the title. Can't write it? Ask him
what the reader should take away.

## 2. Pick the form

| The sentence is about | Use | Not |
|---|---|---|
| Change over time | Line (column for 8 or fewer periods) | Pie, 3D |
| Comparing items | Horizontal bar, sorted by value | Vertical bars with slanted labels |
| Parts of a whole | Stacked bar, or a labelled number or table | Pie with 5+ slices, donut, 3D pie |
| How a total builds up | Waterfall (budget to final cost) | Stacked column |
| One number that matters | Big number plus one line of context | A one-bar chart |
| Exact values he'll read off | A clean table | Any chart |

Sort bars by value unless the categories have a natural order (months, floors, phases). Other cases:
[references/chart-picker.md](references/chart-picker.md).

## 3. Strip, colour, label

- Remove heavy gridlines (or make them faint grey), the border, the legend (label directly), markers on
  busy lines, any 3D, shadow, gradient or bevel.
- **Making a point:** everything grey, **one accent** on what the sentence is about: his brand colour from
  `~/.claude/foreman/profile.md` if dark enough, else one from [references/color.md](references/color.md).
  Same accent across a deck or report. Set it on the series, not the workbook theme.
- **Categories with no winner:** the colour-blind-safe palette in color.md, six at most; the rest go into
  "Other" or a table. **Low to high:** shades of one colour. Never red against green alone.
- Bar and column axes start at zero. One scale per axis (two small charts beat two vertical axes). No time
  window that fakes a trend. A gap in his data stays a gap, and you tell him.
- Round to what matters, real number format, unit once in the axis or chart title, value labels on the
  bars. Font from `~/.claude/foreman/doc-style.md`.
- Title = the takeaway: "Labour is 60% of this change order", not "Cost breakdown".
- A chart that keeps fighting you: a small table with the key row in bold, especially for three to eight
  exact numbers.

**Slides:** one point per slide, the title states it, a short note on the chart (arrow and a few words)
instead of a paragraph. Readable in three seconds. Short labels, no filler.

## Build and check

Write ONE script that builds the whole file with every chart, and run it once; fix by changing the script,
never by patching the file with many small edits. Convert and render in one command:
`soffice --headless --convert-to pdf --outdir "<scratch>" "<file>"; pdftoppm -png -r 50 "<scratch>\<name>.pdf" "<scratch>\p"`
Look once at each chart: labels overlapping or cut off, a leftover legend, wrong colours, an axis not at
zero. One more round only for real breakage.
