# UI review skill: design notes

Working notes for a skill that lets cheap models (Haiku 5.5, Luna 6) find UI
issues. A mid model (Sonnet 5.5, Sol 6.1, Opus 5.5 medium) fixes them, then a
cheap model checks again. Finding issues is the cheap model's whole job.

Status: **decided**, **proposal** (agreed direction, not built), or
**hypothesis** (the eval decides).

## Decisions

### 1. The model finds issues; tooling describes, never judges

**Decided.** Scripts report facts (geometry, type, capabilities, probe
outcomes). The model decides what is wrong.

Why: the issues the owner catches are relational. Uneven insets, nested radii,
drifting row actions and mismatched sibling controls depend on context: a
footer can justify a larger bottom inset. Rules for these would be noisy.
Impeccable's 62 detector rules cover overflow, contrast, nested cards and
repeated text, but not these.

### 2. Prebuilt commands only

**Decided.** The cheap model never writes Playwright scripts, never reads
source, and stays within about 15 turns. Each look is one command that returns
an image path and a short text report.

Why: in the Oct 21 Claude audit, the dashboard agent took 222 turns, wrote
about 190k characters of scripts and commands, and read back about 370k
characters of tool output. Across turns it re-read about 58M tokens of context;
its 31 screenshots were about 60k. Cost is turns × context, so anything the
model writes stays in context and gets paid for on every later turn. The paused
page agents spent about 50 turns each reading source before writing a finding.

### 3. No 1–10 scores

**Decided.** Score recall on known issues, plus noise (findings the fixer must
discard). Run each configuration three times.

Why: in Theo's UI hill climb, scores for unchanged screenshots moved by almost
a point, and adding reference apps moved a 9 to a 7.4. Judges that knew the
target score may have drifted toward it.

### 4. One finder pass over a capture matrix; interaction separate

**Proposal** (Nov 7; replaces four separate passes). Static look, states and
roles are parameters of one capture, not separate passes: page × role ×
viewport × theme × state. Whether an inset, an empty state or a message is
wrong depends on the content, the data state and who is looking. So one finder
judges one capture, with that role's job stories in hand.

Prune the matrix:

- Capture a role only where its DOM differs from another role's.
- Spot-check themes.
- Force loading, empty and error only where the page loads data.
- Capture shared screens (error page, app shell) once, not once per route.

**Interaction** stays separate: resizing, safe triangles, focus return and
hover intent cannot be seen in a still. The owner evaluates it by hand for now
(Nov 6). The failure modes are conventional enough to script, but the judgment
is not worth automating yet.

### 5. Text first for geometry

**Hypothesis.** Next to one screenshot, give the model a layout transcript:
container insets, radii, text styles and x positions. Repeated siblings
collapse into one template plus the rows that differ. The screenshot stays for
weight, color and optical issues that text can't carry.

Why: cheap models are strongest at text. From a screenshot, Sol missed the
announcement panel's bottom inset even with critique, frontend-design and
`.impeccable.md` loaded. Alternatives rejected for now:

- **A ruler on demand** fixes precision, not recall. The model has to suspect
  an issue before asking to measure it.
- **Overlays on every box** are noise, and a selective overlay needs someone to
  choose the boxes.
- **Crops** lose context, such as the footer that justifies an inset, and add
  images. Crops also hide page-level problems like "six left edges".

The squint test (blurred screenshot) and spot-the-difference (stacked rows)
survive as single probes.

### 6. Interactions as an inventory plus probes

**Deferred** (Nov 6; the owner evaluates interactions by hand). Kept here for
when that changes.

- **Capability inventory:** for each component, its kind, what renders it, and
  what it can do (resizable, collapsible, persisted, truncated labels).
- **Probe battery:** scripted experiments by component kind, each returning
  one line. Examples: a diagonal pointer path toward a submenu, Escape, focus
  return, tooltip delay, edge drag with reload, neighbor movement on toggle.
- **Primitive vs callsite:** run each probe on every callsite of a primitive.
  If all fail, the primitive is at fault; if one fails, the callsite is.
- **Recordings:** only as a 3–4 frame filmstrip when a text outcome is
  ambiguous.

Why: interaction failure modes form a small catalog of conventions, unlike
visual taste, and reading recordings is expensive. The catalog's sources are
the interaction video behind section 7 of `ia-app` `ui-quality-guide.md`, plus
the owner's examples.

### 7. Component provenance from the running app

**Deferred** with decision 6. Map an element to its React component and file
in dev builds with react-grab or bippy, rather than having the model read
source.

### 8. Personas as fixed job stories

**Proposal.** Each project gets one short file of rows: role, device,
situation, top tasks and frequency, written once with the owner. The model may
propose a missing row for the owner to accept.

Why: cheap models invent generic personas, regenerated personas make runs
incomparable, and the project context is exactly what the model lacks. Start
from the Users section of `ia-app/agent-notes/design-context.md` (formerly
`.impeccable.md`).

### 9. Neutral baseline capture

**Decided.** Before the baseline screenshot, move the pointer to (0, 0) and
blur focus. Capture hover and focus states separately and on purpose.

Why: a hover state on the announcement list distracted Sol from the inset bug.

### 10. Impeccable

**Decided** (Nov 6): the 21 Impeccable skills were deleted from
`~/.codex/skills`. They were unmanaged copies from March 2026, critique's top
priority is landing-page slop, 17 of them load frontend-design first, and Sol
missed the inset bug with them loaded. In `ia-app`, `.impeccable.md` became
`agent-notes/design-context.md` (branch `tooling/root-cleanup`).

**Open:** `npx impeccable detect` as a free floor, only if the eval shows it
adds catches. It needs no skills installed.

### 11. Find by page, fix by owner

**Proposal** (Nov 7). Pages are the unit for finding, since they can be
captured. They are the wrong unit for fixing, since most defects live in shared
things: the error page, the shell, Panel, Tooltip.

1. **Find:** cheap models, one per capture, in parallel. Finders report and
   never propose code, so several cannot conflict over a shared page.
2. **Group:** merge findings by the component or primitive that rendered the
   element. One defect seen through five routes becomes one item with five
   pieces of evidence.
3. **Fix:** a mid-tier model per group, not per page. Fixers run one at a time
   at first, so two agents never edit the same file.
4. **Re-check:** re-capture every page that uses what changed, from the import
   graph, not just the page where the defect was found.

The group step doubles as the primitive signal: a defect under one primitive
across several callsites is probably the primitive's. The Oct 22 audit primer
used the same rule (recurs at three or more callsites → primitive level).

### 12. One skill with role files

**Proposal** (Nov 7). `SKILL.md` is the orchestrator: plan captures, dispatch
finders, group, dispatch fixers, re-check. `finder.md` (cheap model: one
capture in, structured findings out) and `fixer.md` (mid model: one group in,
a fix or an escalation out) are files the orchestrator tells each subagent to
read. That works for Claude subagents and Codex delegates alike.

Why not three skills: every installed skill's description loads into every
session.

### 13. Finders locate; fixers decide the level

**Proposal** (Nov 7). The finder reports where a defect is and which component
rendered it, plus a hunch about its level. It does not decide. Text overflow
shows why: it can come from a callsite (a flex child missing `min-width: 0`),
from content (a raw ID where a name belongs), or from the primitive (no
truncation). A screenshot can't tell these apart.

The fixer chooses among four kinds, all seen in `ia-app`:

- **Primitive defect:** Tooltip's `data-state` overwrote Toggle's pressed
  state; DatePicker's popover stayed open after a pick (5 callsites).
- **Callsite misuse:** a labeled control inside an icon-only Button, whose
  selector enlarged the chevron.
- **Bespoke instead of a primitive:** six dashboard widgets hand-rolled tile
  rows instead of using CardGroup.
- **Missing primitive API:** CardGroup's corner options could not express the
  inset shape.

Before changing a primitive, the fixer checks every callsite and the job
stories of the people who reach them. A missing API is escalated to the owner
before any code is written, as `ia-app` `AGENTS.md` already requires.

**Gap:** only 24 of `ia-app`'s 103 primitives emit `data-slot`. Button,
Dialog, Badge and most others don't, so the page alone often can't say which
primitive rendered an element. Either add `data-slot` to the rest (the shadcn
convention) or read component names from React in dev builds (as react-grab
does).

## Evals

**Decided** (Nov 6): test on real pages from the current `ia-app` `main`, not
replayed commits or planted fixtures.

1. The owner picks pages, with role, viewport and theme.
2. The prebuilt capture command takes static screenshots, which also tests
   that command.
3. The owner writes critiques before seeing any model output, so model
   findings don't anchor the ground truth.
4. Cheap models run against the same captures; score recall on the owner's
   critiques and count noise.

Findings the owner marks real later become further cases. The 13 UI Principles
screenshots (`~/.t3/userdata/attachments/03c046b3-*`) and the owner's markups
remain available as an older static set.

## Open questions

- **Waiting on:** the owner gives the eval pages once the `ia-app` branch
  `fix/ui-library-reliability` is done (asked Nov 6).
- Start IA-app-specific or generic?
- How good is Haiku 5.5 or Luna 6 vision on geometry? Unknown until a baseline.
- Which pages first?

## Evidence

- Oct 22 audit: `~/workflow/ia-app-archives/ia-cleanup-evidence-20261028/`
  (`ui-audit-2026-10-22/` holds the primer, harness, findings and boards).
- Audit transcripts:
  `~/.claude/projects/-Users-sreysus-workflow-ia-app/65a08503-f856-49e7-a79f-911afcbbb194/subagents/`
- UI Principles thread: T3 thread `03c046b3-4b49-41c8-87ca-3404b703ffe6`.
- Theo's UI hill-climb video transcript, shared in the conversation that
  started these notes (Nov 2026).
