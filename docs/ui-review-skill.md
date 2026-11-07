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

### 4. Separate passes

**Decided.**

- **Static look:** per screen, viewport and theme. Cheapest; runs most often.
- **States:** the same screen forced into loading, empty, error and long
  content.
- **Interaction:** per component, not per screen. Resizing, safe triangles,
  focus return and hover intent cannot be seen in a still. **The owner
  evaluates this pass by hand for now** (Nov 6): the failure modes are
  conventional enough to script, but the judgment is not worth automating yet.
- **Roles and tasks:** per role, from job stories (decision 8).

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
