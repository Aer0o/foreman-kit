---
name: chart-craft
description: Make clear, honest, professional charts and data slides in Excel or PowerPoint (and charts placed in Word reports). Use before making any chart or graph, or when he says "make a chart of this", "graph these numbers", "put this in a slide", "this chart looks off" or "it looks like default Excel".
---

# Chart craft

Bad charts start with picking a chart type. Good ones start with deciding what the chart should say.
Decide that first, then make the result look deliberate instead of default.

The file work goes through Anthropic's skills: the xlsx skill for Excel, the pptx skill for PowerPoint,
the docx skill for a chart in a Word report (`anthropic-skills:*` or `document-skills:*`). Build **native,
editable charts** so he can change the numbers later; use a picture of a chart only when the target can't
hold a native one. (In code, the same rules apply: set an explicit palette, never the library default.)

## 1. Write the sentence first

Finish this before choosing anything: "This chart shows that ______."

- "Labour is most of the cost on this change order."
- "Three of the eight floors carry most of the deficiencies."
- "We're behind on rough-in but ahead on trim-out."

That sentence picks the chart type, what to highlight, and the title. If you can't write it, ask him what
he wants the reader to take away.

## 2. Pick the form from the sentence

Full picker: [references/chart-picker.md](references/chart-picker.md). Short version:

| The sentence is about | Use | Not |
|---|---|---|
| Change over time | Line (column for 8 or fewer periods) | Pie, 3D |
| Comparing items | Horizontal bar, sorted by value | Vertical bars with slanted labels |
| Parts of a whole | Stacked bar, or a labelled number or table | Pie with 5+ slices, donut, 3D pie |
| How a total builds up | Waterfall (budget to final cost) | Stacked column |
| One number that matters | Big number plus one line of context | A one-bar chart |
| Exact values he'll read off | A clean table | Any chart |

Sort bars by value unless the categories have a natural order (months, floors, phases).

## 3. Strip the junk

Remove, in this order: heavy gridlines (delete or make faint grey), chart border, legend (label lines and
bars directly instead), markers on busy lines, an axis you've made redundant with data labels, and always
3D, shadows, gradients and bevels. Test: remove an element; if the chart still makes its sentence, leave it
out.

## 4. Colour with intent

Rules and colour codes: [references/color.md](references/color.md).

- **Making a point:** everything grey, **one accent** on the thing the sentence is about. The accent is
  his brand colour from `~/.claude/spark/profile.md` if it's dark enough to stand out; otherwise use one of
  the accents in color.md. Same accent across a whole deck or report.
- **Categories with no winner:** a colour-blind-safe palette, six colours at most. Past six, group the rest
  into "Other" or use a table.
- **Low to high:** shades of one colour. Never red against green alone.

## 5. Don't let the chart mislead

- Bar and column axes start at zero. Always.
- One scale per axis. Avoid two vertical axes on one chart; use two small charts instead.
- Don't pick a time window that fakes a trend.
- Never invent a number or fill a gap. Every figure comes from his data; if some is missing, show the gap
  and tell him.

## 6. Format the numbers

- Round to what matters: thousands don't need cents. Two or three significant figures is usually right.
- In tables: right-aligned, same decimals down a column.
- Units once, in the axis title or chart title, not on every label.
- A value label touching its bar beats a value the reader has to find on an axis.

## Excel and PowerPoint: escaping the default look

1. Delete gridlines and the chart border.
2. Recolour the series to grey, then the one series or bar that carries the point to the accent. Change
   the chart's colours, not the workbook theme.
3. Remove the legend and label directly.
4. Title = the takeaway sentence, not the topic. "Labour is 60% of this change order", not "Cost breakdown".
5. Sort the source data so bars come out in order.
6. Set a real number format (rounded, with the unit). Turn off anything 3D.
7. Font matches his documents (`~/.claude/spark/doc-style.md`).

If a chart keeps fighting you, a small, tidy table with the key row in bold often says it better,
especially for three to eight exact numbers on a slide.

## Slides

One point per slide. The slide title states the conclusion. Put a short note right on the chart (an arrow
and a few words) rather than a paragraph beside it. The point should survive a three-second glance.

## Look before you say done

Convert the file: `soffice --headless --convert-to pdf --outdir <scratch folder> "<file>"` (call soffice
directly; Anthropic's soffice.py wrapper is Linux-only). Render:
`pdftoppm -png -r 80 "<file.pdf>" "<scratch folder>\page"`. Look at the chart: labels overlapping or cut
off, legend still there, wrong colours, axis not at zero. Fix and re-render, two rounds at most. If soffice or pdftoppm is
missing, don't claim the check; tell him to double-click Fix SPARK in the SPARK folder.

## Checklist

- [ ] I can say the one sentence this chart makes, and the title says it.
- [ ] The type fits (bar to compare, line for time, table for exact values).
- [ ] Bars sorted; bar axis starts at zero.
- [ ] Gridlines, border, 3D and legend gone or muted; direct labels.
- [ ] Grey plus one accent, or six or fewer colour-blind-safe colours.
- [ ] Numbers rounded, unit shown once.
- [ ] Every number from his data; nothing invented.

Words on the chart or slide go through the **plain-writing** skill; the page around it follows
**doc-design**.
