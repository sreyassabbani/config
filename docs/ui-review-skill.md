# UI review skill: design notes

A skill that lets cheap models (Haiku 5.5, Luna 6) find UI issues, a mid model
(Sonnet 5.5, Sol 6.1, Opus 5.5 medium) fix them, and a cheap model check
again. Status marks: **decided**, **proposal** (agreed, not built),
**hypothesis** (the eval decides).

## The idea underneath

A review is an experiment on a grid. Each capture fixes six variables: route,
viewer role, viewport dimensions, theme, other data state and entity. A flaw's
**scope** is the set of variables it holds steady across:

| The flaw persists across… | It probably lives in… |
| --- | --- |
| routes | a shared component or primitive |
| viewer roles | the page itself, not a role branch |
| viewport dimensions | layout that isn't responsive-specific |
| entities | structure rather than data (long names, counts) |

Varying one variable at a time from a baseline points the fixer at the code
that probably owns a flaw; the fixer confirms. No finder can tell that from one
screenshot. A full grid multiplies, while varying from a baseline adds. The
eval follows the same rule.

## Plan

**The owner picks domains and approves inputs** (proposal, temporary). A
domain is related routes, viewers ("all roles" is allowed), viewports, theme,
and entities by name. Before dispatching anything, the orchestrator shows:

- a contact sheet, with viewers as rows, routes as columns, and identical views
  shown once;
- every finder's brief;
- every viewer substitution.

It waits for the owner's approval. Drop this step once captures and briefs are
reliably right.

**Viewers are relationships, not logins** (proposal). For "all roles", the
orchestrator derives viewers from the domain's permission model, reading code
if needed. For a club, that means:

- Super Admin and School Admin;
- the club's sponsor, plus a teacher and a staff member who aren't sponsors;
- a student leader and a member;
- a student who could join, one who can't (wrong grade), and a student admin
  who isn't a member.

Each is captured on their own device, students on phone as well. A denial is a
view too, and a dead end is a finding.

**Coverage.** A viewer exists only if the data holds someone in that
relationship. When the chosen entity lacks one, take the closest entity of the
same kind, and capture one viewer from the original in it too, so comparisons
stay within a single entity. Report the substitution at approval. In the first
run, the seeded 10th Grade Student Government had sponsors but no students, so
its leader and member views came from Service Leadership Council. **Open:**
should the seed give class-government clubs real members?

**Job stories** (proposal): one file per project, written once with the owner.
Each relationship gets a device and frequency, and for each route a reason for
being there and what they need. Non-members usually arrive by a followed link,
such as a channel link in an announcement, so that is their reason. Briefs are
assembled from this file. Without it, cheap models invent generic personas,
and regenerated personas make runs incomparable.

**Data** (decided): the isolated local Convex backend that `bun run dev`
starts, never a cloud deployment. Entities are named and resolved to IDs at
capture time, since a reseed changes IDs but keeps names. Pick on purpose,
never at random, and don't reseed during a round.

## Capture

**Prebuilt commands only** (decided). Finders never write Playwright, read
source or browse; a finder run is a few turns. Cost is turns × context: in the
Oct 21 audit, the dashboard agent took 222 turns and re-read about 58M tokens
of context, while its 31 screenshots were about 60k.

**Collapse identical views** (proposal). Two viewers share a view only if
their screenshots match pixel for pixel, with the parts that differ by person
masked out. Mask only identity fields: the account name, and counts that
depend on the viewer, such as presence and unread. Better still, make those
counts the same for everyone in the seed. The app sidebar varies by school
role and that difference can matter, so it isn't masked. Review it once per
viewer, as the shell's own column. Keep the mapping from viewer to view.
A text signature (final URL, headings, controls) isn't enough. In the first
run it merged School Admin's and the sponsor's views of four routes that
differ on screen. By pixels, the 10th-grade club's 48 desktop captures came
to 28 views: 8 viewers (all but leader and member) × 6 routes. Super Admin's
view was unique on every route.

**Capture details** (decided):

- Pointer at (0, 0), focus blurred and reduced motion before each shot. A hover
  state once distracted Sol from an inset bug.
- Desktop matches the owner's window: about 1680×1020 CSS pixels.
- Wait for hydration before logging in. Submitting early does a native GET
  that put the demo password in a URL.
- Hide the Next dev overlay, and write console errors into each capture's
  inventory. The "Setup · 1 / 3 steps" pill is product UI and stays.
- Never give a subagent a path to the seed file or saved sessions. On Nov 8 a
  Sol child printed the demo password in its own tool output.

**Known gaps:**

- **Below the fold (open).** The app scrolls an inner container, so full-page
  mode can't help; capture the scroll owner's segments.
- The loading check misses this app's placeholders under reduced motion.
- The inventory finds the app sidebar by its text, not by landmark.

## Find

**Tooling describes; the model judges** (decided). The issues the owner
catches are relational (uneven insets, nested radii, drifting row actions,
mismatched siblings), and rules for them would be noisy. Facts that need no
judgment skip the finders and go straight to grouping: console errors, empty
headings, placeholders that never resolve. The first run's crash came that
way: every non-member who opens club settings hits `listRoles` throwing "Not a
club member". **Open:** `npx impeccable detect` as a free floor, only if the
eval shows it adds catches.

**Rows and columns** (proposal). Two lenses over the route × viewer grid:

- **Row:** one viewer's routes on their device, with that person's reason for
  each. It catches poor fit to the job and the same job done two ways. In the
  first run, a non-member met five different no-access treatments across six
  routes. Only a row sees that.
- **Column:** one route across every distinct view at one viewport. It catches
  what only shows between viewers:
  - space held for a control this viewer lacks;
  - a control shown to someone who can't use it;
  - copy aimed at someone else;
  - unexplained divergence, such as the wrong-grade student getting the same
    "Request to join" as the eligible one.

**How each lens gets its images** (proposal; council, Nov 7). Repeated
chrome isn't a token problem: all 28 distinct views of the 10th-grade club
cost about 62k tokens, roughly $0.006 per Haiku run. The problem is attention:
vision models are poor at spotting small differences across near-identical
images.

- **Rows:** full captures, one image each, at native size. Don't pack several
  desktops into one image (that downscales them) or crop the chrome; repeated
  chrome is the evidence for consistency.
- **Columns:** start with one full image per distinct view, plus the inventory
  diff as text. That's what each viewer has gained, lost, relabelled or had
  moved, with boxes. Identical views get an explicit line: "identical to X
  except identity fields". Sameness can be the defect, as with the wrong-grade
  student, and a picture of a diff shows nothing for it. So a shared view is
  still judged once for each viewer's job.
- **Paired crops** come later, only for views similar enough to diff:
  1. compare against one fixed reference, never a chain of viewer-to-viewer
     deltas;
  2. match elements by role and name, and undo uniform shifts ("32px inserted
     at y…") before diffing pixels;
  3. snap each changed area to its smallest meaningful container in both
     captures, plus padding and an alignment neighbour. This needs container
     boxes in the capture; it records only controls today;
  4. crop the union of old and new bounds at the same coordinates from both
     images, so a gap left behind still shows;
  5. merge nearby regions, and fall back to full views past about 35–40%
     coverage or 4 regions;
  6. render base | variant with labels outside the crop, and no outlines or
     heatmaps, which a finder may critique as UI.
- **Recall aids to test:**
  - an automatic 2× strip of each capture's header bar, where dense defects
    hide;
  - an automatic sweep of overlapping crops after the whole-view pass.

  Unlike a zoom the finder calls itself, these don't depend on the finder
  noticing something first.

Luna 6's image handling is unverified. OpenAI documents 32×32 patches with
per-model multipliers, and a 1680×1020 capture fits GPT-5.6's high-detail
limit unchanged. Record actual usage rather than assuming it.

Inputs are sealed: a finder gets its brief and captures, never the owner's
screenshots, critiques or past audit findings.

**Briefs steer** (Nov 8 baseline). Nearly every finding traced to a brief
line. Two of three runs reported "never says whether the club is active",
taken straight from the job description. Two lines probably hid the one
defect every run saw but none reported (see Evals):

- "Pages may continue below the fold; judge what is visible" made columns cut
  off at the bottom look normal.
- The scope rules teach comparison, and the cut-off band was identical on all
  six captures. One run called it "a shared layout detail rather than a
  defect."

**Output** (decided): one finding per flaw, listing every capture it appears
on, in capture order. Each finding has captures, where, problem, effect and
scope. There are no 1–10 scores, no severity and no confidence: in Theo's hill
climb, scores for unchanged screenshots moved by almost a point, and
self-ratings are the same noise. Priority comes later, from reach.

Scope must cite the other captures:

- **shared:** list where it appears;
- **this page only:** name where the same element looks right;
- **inconsistent:** name both versions;
- **unique:** the element has no counterpart on any other capture;
- **unsure:** the captures can't tell.

**Text first for geometry** (hypothesis). Give a layout transcript beside the
screenshot (insets, radii, type, x positions; repeated siblings as one template
plus deviations). Nobody yet knows how well Haiku 5.5 or Luna 6 see geometry.

**Held states are captured; motion stays with the owner** (proposal, Nov 7;
narrows the Nov 6 decision). Any state that holds still is a still: hover,
keyboard focus, pressed, open, selected, disabled. The capture command drives
the state and the finder judges the image, so no finder ever interacts.

- **State strip:** one image per control, cropped to the control plus its open
  overlay and some surroundings, showing rest | hover | focus | pressed | open.
  It answers how a control behaves across its states, which is how the owner
  judges it. The first strips cost about 500–1,000 tokens each.
- **Opening by keyboard** moves focus into the overlay, so it's a separate state
  from opening by mouse.
- **Which controls:** one strip per component variant and placement, not per
  trigger. Identical class strings in this Tailwind app mark the same variant.
  On the six club routes, 28 triggers opened 15 overlays, 9 of them unique.
- **Fresh load per state.** The first strips leaked state: a focus ring left
  over in "rest", and a pressed button released over the trigger opened the
  popover. Reload before each state, and release away from the trigger.
- **The real risk is noise, not tokens.** Most strips will be fine, and a cheap
  model shown a perfect strip may invent a problem. Put known-good controls in
  the eval and count those findings.

What a still can't show stays with the owner: motion, timing, hover intent,
safe triangles, focus moving during a transition, layout shift while opening.
The owner's own state screenshots become answer-key cases for strips.

## Group, fix, re-check

**Group by owner; rank by reach** (proposal). Findings merge by rendering
component, and one mid model fixes each group, serially at first. Three or more
callsites with the same flaw point at the primitive. Reach is the viewers a
flaw touches times how often they come, from the job stories: a flaw in Super
Admin's view alone reaches one person, while one in the shared header reaches
everyone daily.

**The fixer decides the level** (proposal). Text overflow can come from a
callsite (missing `min-width: 0`), from content (a raw ID) or from the
primitive (no truncation), and a screenshot can't tell which. The four kinds,
all seen in `ia-app`:

- **primitive defect:** Tooltip's `data-state` overwrote Toggle's;
- **callsite misuse:** a labeled control inside an icon-only Button;
- **bespoke where a primitive exists:** hand-rolled tile rows instead of
  CardGroup;
- **missing primitive API:** CardGroup corners couldn't express an inset.

Before changing a primitive, the fixer checks every callsite against the job
stories. It escalates a missing API to the owner (`ia-app` `AGENTS.md`).
Mapping elements to primitives is hard because only 24 of 103 `ia-app`
primitives emit `data-slot`: add it to the rest, or read component names from
React in dev builds (as react-grab does).

**Re-check** (proposal): recapture every view that uses what changed, from the
import graph. A fix passes when its finding is gone and a finder sees no new
defect in those views compared with before.

**Packaging** (decided Nov 8): one skill, `home/agents/skills/ui-review`, so
only one description loads into every session. The orchestrator fills
`finder-brief.md` and inlines it in each task, so a finder never reads a file
other than its captures, and briefs name no harness-specific tools. App
specifics (login, password file, identity masks, shell width) live in the
manifest, not the scripts. **Open:** a fixer brief, after the first fix.

## Evals

Real routes from the running app (decided Nov 6), changed one step at a time:

1. **Baseline:** the Super Admin row for 10th Grade Student Government, the
   view the owner judged. Screenshots only; three runs each of Haiku 5.5 and
   Luna 6.
2. Then, one at a time against it:
   - full-image columns;
   - the inventory diff;
   - paired crops instead of full views for similar columns;
   - the header strip;
   - the regional sweep;
   - a callable zoom;
   - the text transcript;
   - the other rows.

   Also test body-only row crops. That directly tests whether cutting the
   chrome loses alignment and header findings.

Column defects need the owner's own labels; the Super Admin critique can't
score them. Planted defects are out (the owner declined fixtures on Nov 6),
so the eval relies on natural ones. Keep three runs per arm unless variance
shows that isn't enough; one member suggested five. Log tokens and wall time
for each arm.

**Baseline results** (Nov 8). The baseline moved to Girls Who Code, which has
every relationship. Haiku 5.5 × 3 on the Super Admin row:

- 24–25 findings per run, merging to 41 clusters; 15 were found by all three.
- Per run: 2 model requests (all six images read at once, then the answer),
  93–153 s and 20–33k output tokens, mostly reasoning. That's about
  $0.015–0.02 at $0.10/$0.50 per MTok.
- Luna 6 × 3 failed on its weekly limit. Meters were not read; the skill's
  `scripts/plan-usage` reads them now.
- Merged one-line titles dropped each finding's argument. The audit needs
  each run's verbatim output and logged reasoning, plus every cluster
  with its full blocks.

**Sort every miss by its reasoning log** (proposal). The fix depends on the
kind:

- never saw it: image aids (zoom, strips, crops);
- saw it and dismissed it: the brief;
- saw it and blamed the wrong thing: the output format, with the symptom
  reported apart from any guessed cause.

In the baseline, the onboarding pill's in-flow `h-20` spacer (`onboarding.tsx`,
mounted inside `SidebarInset`) cut every column 80px short of the window.

- All three runs saw the empty band. One dismissed it, one blamed the pill for
  covering the lists, and none connected the band to the short columns.
- All three reported the pill itself, which the owner intends.

**Revised brief** (Nov 8, same six captures). Three edits:

- the window's bottom edge replaced "below the fold";
- a line saying a flaw identical on every capture is still a flaw;
- a `suspect` field, so the symptom is reported apart from a guessed cause.

Results:

- **Haiku × 3:** two of three reported the columns stopping about 80px above
  the window's bottom edge. One even suspected "a fixed overlay that reserves
  the bottom band". The third folded the band into its complaint about the
  pill.
- **Opus 5.5 on the old brief:** noticed that "its band shortens every page",
  but inside a finding against the pill.
- **Every run, Opus included,** still reported the pill itself. The owner's
  intent wasn't in any brief.
- **Size and cost:** 21–27 findings per run. `suspect` was used 2–5 times per
  run. Haiku took 131–186 s and 28–40k output tokens per run.

**Luna 6** (Nov 9, medium reasoning; three runs on each brief, same
captures):

- None of the six reported the short columns. All six reported the setup pill,
  and most said it covers the content.
- 2–6 findings per run, against Haiku's 21–27. Each run took 27–45 s, 3 model
  requests and 1–2k output tokens, with almost no reasoning. That didn't
  move the Codex meter.
- Two runs built a contact sheet with PIL in `/tmp`, and two opened the
  captures in Preview on the owner's screen, despite "run no commands except
  to view the images". The inputs stayed sealed, but a finder with a shell
  will use it. Luna's image-viewing tool is enough by itself.

The edits were written knowing this defect, so this shows Haiku can reach the
judgment when the brief doesn't excuse it. It doesn't show the edits help
elsewhere; that needs defects nobody tuned against.

The owner writes a critique before seeing finder output, and it stays out of
every path a finder gets. Score recall on it within what the owner saw, plus
noise. Findings on views the owner hasn't judged stay unscored until reviewed.
The baseline only tests the row pass on the least typical viewer, so findings
from other viewers' rows and from columns never count toward it.

## Evidence

- Oct 22 audit: `~/workflow/ia-app-archives/ia-cleanup-evidence-20261028/`
  (`ui-audit-2026-10-22/` holds the primer, harness, findings and boards).
- Audit transcripts:
  `~/.claude/projects/-Users-sreysus-workflow-ia-app/65a08503-f856-49e7-a79f-911afcbbb194/subagents/`
- UI Principles thread: T3 thread `03c046b3-4b49-41c8-87ca-3404b703ffe6`.
- Theo's UI hill-climb video transcript: pasted into the first message of
  `~/.claude/projects/-Users-sreysus-config/64ebcb4c-3495-491c-b5c2-03011d88a0d0.jsonl`.
