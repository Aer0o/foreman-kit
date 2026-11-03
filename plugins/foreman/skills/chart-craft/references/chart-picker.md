# Chart picker: choose by what you're trying to say

Start from the one-sentence takeaway, then pick the simplest form that carries it. Bar and line charts do
most of the real work.

## By intent

### Change over time
- **Line:** the default for time (monthly billings, hours per week). Several series: label each line
  directly, four lines at most.
- **Area:** one series where the running total matters.
- **Slopegraph:** two points in time, many items; shows who went up and who went down in one look.
- **Column:** a few time buckets (eight or fewer months or phases) compared one by one.
- Avoid: pie over time, 3D, two vertical axes.

### Comparing items
- **Horizontal bar, sorted by value:** the safest chart there is. Long names fit and the ranking reads
  instantly. The reflex for "compare X across jobs, floors, suppliers or trades".
- **Grouped bar:** two or three sub-series per item (budget and actual per phase). More than three
  turns to mush; use small multiples instead.
- **Dot plot:** many items with values close together.
- Avoid: vertical bars with slanted labels (turn the chart sideways instead), pie for comparing.

### Parts of a whole
- **100% stacked bar:** parts across a few groups. Keep the segment order the same in every bar.
- **A labelled number or table:** often better than a pie: "Labour 58%, material 34%, equipment 8%".
- **Waterfall:** how a total is built or bridged, e.g. original contract, plus each change order, to the
  final contract value.
- Pie or donut: only two or three slices, only when the whole matters more than the comparison. Never 3D,
  never five or more slices, never exploded.

### Spread of values
- **Histogram:** where values bunch up (how long service calls take).
- **Box plot:** compare spreads across groups.

### Two things related
- **Scatter:** two measured quantities; add a trend line only if the relationship is real.
- Don't imply one causes the other from a scatter alone.

### One number that matters
- **Big number plus one line of context:** "87% of deficiencies closed (target 100% by handover)". Show
  the comparison that gives it meaning: against target, against last month.

### Exact values he'll read off
- **Table.** For a budget, a price comparison or a schedule of values, a clean table beats a chart. Bold
  the total row; a faint accent on the one key cell at most. Numbers right-aligned and rounded sensibly.

## When a table beats a chart
- Eight or fewer numbers people will actually read.
- Several units in one view (%, $, hours).
- The exact value matters more than the shape.
- You only want a chart "to look visual". A tidy table reads as more rigorous.

## Charts to avoid, and what to use instead

| Tempting | Problem | Use instead |
|---|---|---|
| Pie with 5+ slices | Angles are unreadable | Sorted horizontal bar |
| 3D anything | Distorts the values | Flat 2D |
| Two vertical axes | Invents a relationship | Two small charts |
| Radar or spider | Area misleads, hard to compare | Grouped bar |
| Bar axis not starting at zero | Exaggerates differences | Start at zero |
| Rainbow colours | No hierarchy, not colour-blind safe | Grey plus one accent |
| Gauges and speedometers | Decoration over data | Big number plus context |

## Small multiples
When one chart gets crowded (many series or groups), repeat a small identical chart per group in a grid,
same axes and scale. Comparing shapes across a grid is far easier than untangling eight lines in one frame.
