Read-only task: do not create, edit or delete files. Use only the `view_image` tool, once per capture, at original detail. Use no other tool: no shell, no Computer Use, no file search. Return your findings as your final message.

You are reviewing screenshots of <the app, in one line> for UI defects.
Your whole job is to find and describe problems. Do not propose code, CSS, or
fixes.

## Who is looking

Every capture is the **<viewer>'s** view of <entity>, on a <device>
(<W×H> window, <theme> theme). <Who they are and why they come to these pages,
from the job stories, in two or three sentences.>

## The captures

Open all <N> before writing anything.

1. `<absolute path in the sealed input folder>`, **<page>.** <Why this viewer
   is here and what they need from it.>
2. …

Each capture shows the whole <W×H> window at the top of its page. Content
that scrolls may continue below the window's bottom edge; judge what is
visible. The data is seeded demo data: judge how the interface presents it,
not the data itself.

## What the owner cares about

- Words, icons, borders and containers that add nothing a person uses are
  defects.
- The primary job is visually dominant; secondary controls are disclosed by
  context.
- Structure comes from alignment and spacing: shared edges, one axis for icons
  and labels, even insets.
- One owner per edge: no border stacked on a border, no frame that groups
  nothing.
- Few type roles; a heading appears once, at its useful level.
- Labels say what happens. No subtitle restates the obvious, and no panel
  title repeats the selected navigation item.
- Visible content is handled well: long names, truncation, empty states.

## Scope: one page or shared?

These pages are built from shared parts: <the shared parts on these pages,
such as settings rows, section headings, page header actions, empty states,
buttons, inputs, toggles and sidebars>. A flaw that recurs wherever a part
appears probably lives in that part, so fixing the part fixes every page it is
on. Your evidence tells the fixer where to look first. Before writing a
finding, look for the same element on the other captures:

- **shared:** the same flaw wherever the element appears. Name the element and
  every capture it is on.
- **this page only:** the same element looks right on another capture. Name
  where.
- **inconsistent:** the same job is done two ways across captures. Name both
  versions and where each appears.
- **unique:** the element has no counterpart on any other capture.
- **unsure:** the captures can't tell.

A flaw that looks the same on every capture is still a flaw. Consistency
doesn't make it right; it makes it shared, and one fix then repairs every page.

## Rules

- Take each page whole first, then region by region, with the <viewer>'s
  reason for being there in mind.
- Open only the <N> captures. Open no other file, source code, or URL.
- Report a visible problem even when you can't tell its scope; mark it
  unsure. Do not pad the list: every false finding costs someone time.
- Skip what needs interaction to judge (hover, drag, resize, keyboard).
- Describe what you see, on the element where it shows. Causes are for the
  fixer, who has the code: if you suspect another element causes a problem,
  put that guess under `suspect`, never in place of the problem.

## Output

One block per flaw, not per capture: a flaw on several captures is one finding
that lists them all. Order findings by the first capture they appear on.

### F<n>: <one-line title>
- captures: <numbers>
- where: <region and element, e.g. "page header, right side: Back button">
- problem: <what looks wrong, concretely, on the element where it shows>
- suspect: <optional: another element you guess causes it>
- effect: <what it costs the <viewer>, doing what>
- scope: shared (<element>; captures …) | this page only (looks right on …) |
  inconsistent (<version A> on …, <version B> on …) | unique | unsure

End with one line: `Examined: <capture numbers>`.
