---
name: ui-review
description: Use when the user asks for a UI review, to run UI finders on screenshots, or to score or audit finder output.
---

# UI review: orchestrator

You run the review. Cheap finders find defects in screenshots, a mid model
fixes them, and a cheap finder checks again. Reasons and open questions:
`~/config/docs/ui-review-skill.md`.

Scripts are in this skill's `scripts/` folder. Commands below are relative to
this skill's folder; give `RUN` and `MANIFEST` as absolute paths, outside any
repo. Once per machine, run `npm install --prefix scripts`. If Chromium is missing, also run
`node scripts/node_modules/playwright-core/cli.js install chromium`.

## 1. Scope with the owner

- A domain is related routes, viewers, viewports, theme, and entities by name.
- Viewers are relationships to the entity, derived from its permission model,
  not logins. Students are also captured on phone.
- Ask only what blocks this step, and say what any term means before asking.
  Product questions that come up along the way are not for the owner now: pick
  what the tooling needs, and note or file the product issue.

## 2. Capture

- Use the local backend that the app's dev command starts, never a shared
  deployment. Don't reseed during a round.
- Look up entity IDs by name in the local data just before capturing. For a
  Convex app, first confirm that `CONVEX_DEPLOYMENT` in the Convex package's
  `.env.local` starts with `local:`. Then, from that package, run
  `direnv exec . bunx convex data <table> --format jsonLines`.
- Write a manifest; `manifest.example.json` is one for `ia-app` clubs.
  - `app`: the base URL, the login form, and where the demo password lives.
  - `pages`: route templates.
  - `entities`: IDs by key.
  - `viewers`: logins, each with an entity and viewports.
  - `identity` and `shell`: what `views.mjs` masks.
- Run `node scripts/capture.mjs MANIFEST`. It writes a PNG per viewer ×
  viewport × page, plus an inventory beside each: final path, console errors,
  and the visible controls with their boxes.
- The capture only reads. Never add steps that click inside an overlay.
- The capture reads the password from the app's file and never prints it.
  Never give a subagent a path to that file or to `~/.cache/ui-review/auth`.
- Facts that need no judgment skip the finders and go straight to grouping:
  console errors, a "still loading" line, empty headings.

## 3. Collapse identical views

- Run `node scripts/views.mjs RUN`. It groups each entity × page × viewport by
  exact pixels and writes `RUN/views.json`. Before comparing, it masks:
  - identity fields, the inventory labels that match `identity` (an account
    name, "N online"), using the union of the group's boxes;
  - on viewports listed in `shell`, the app sidebar. The sidebar is then
    reviewed once per viewer instead of per page.
- Run `node scripts/contact.mjs RUN ENTITY VIEWPORT` for each viewport. It makes
  a contact sheet: viewers as rows, pages as columns, and a repeat shown as
  "same as X".

## 4. Write the briefs

Fill `finder-brief.md` once per finder lens: the viewer, their reason for each
page, and the captures. Keep its principles, scope rules and output format.
Never add severity or confidence.

- Finders do what the brief says, so every line steers what they report.
- Never write a line that excuses a class of defect. "Pages may continue below
  the fold; judge what is visible" excuses content cut off at the bottom.
- Keep the line that says a flaw that looks the same on every capture is still
  a flaw. Scope rules alone teach finders that consistent means fine.
- Don't score a brief change on the defect that prompted it. Test the change
  on defects the owner labels that nobody tuned against.

## 5. Get approval, then dispatch

- Show the owner the contact sheets, every brief and every viewer
  substitution, and wait for approval.
- **Seal the inputs.** Copy each arm's captures into its own folder,
  `RUN/input-<arm>/`, holding nothing else. Inline the brief in the task, with
  absolute paths into that folder. Never include the owner's screenshots,
  critiques or earlier findings.
- **Targets in T3:**
  - Haiku: `claudeAgent`, `claude-haiku-5-5`, effort `medium`.
  - Luna: `codex`, `gpt-6-luna`, reasoningEffort `medium`.
  - Run each arm three times.
- **Take meter readings around the batch:**

  ```sh
  scripts/plan-usage --json > RUN/usage-before.json
  # ...dispatch, wait...
  scripts/plan-usage --since RUN/usage-before.json > RUN/usage.txt
  ```

  A meter at 100% means that provider's runs will fail. Readings are whole
  percents, so one small batch can show +0. The meters count every session on
  the account, including yours.
- **If a provider is unavailable, report it.** Don't substitute another model.

## 6. Audit each run

```sh
node scripts/audit.mjs RUN/input-<arm> --since <dispatch time> --save RUN/findings --as <arm> > RUN/findings/stats-<arm>.txt
```

- It finds every Claude or Codex run whose task named that folder.
- It checks the run stayed sealed: every tool call names only paths inside
  the folder.
- It prints model requests, tool calls, wall time and tokens.
- It saves each run's final message verbatim as `<arm>-<n>.md` and its logged
  reasoning as `<arm>-<n>-reasoning.md`. The logs hold a summary of the
  reasoning, not the raw reasoning.
- Read every run's stats. A run that isn't sealed doesn't count.

## 7. Merge without losing words

- Read every block in every run. Then write `RUN/findings/clusters.json`:
  `{title, runs, clusters: [{title, captures, ids: ["<arm>-1:F3", …]}]}`.
- Run `node scripts/merge.mjs RUN/findings`.
  - It writes `merged.md`: one table per number of runs, with an empty Label
    column.
  - It writes `merged-verbatim.md`: every cluster followed by each run's full
    block.
  - It refuses if a block is in no cluster.
- Don't judge findings while merging: the owner labels them.

## 8. Score

- The owner labels each cluster: real, not real, or partly. Recall counts only
  against what the owner judged; noise is the findings labelled not real.
- Read the reasoning log for every miss and sort it. Each kind needs a
  different fix:

  | Miss | Fix it in |
  | --- | --- |
  | Never saw it | images: zoom, strips, crops |
  | Saw it and dismissed it | the brief: a missing principle, or a line that excused it |
  | Saw it and blamed the wrong thing | the output format: the symptom apart from any guessed cause; the fixer finds causes in the code |

## 9. Fix and re-check

- Group findings by the component that renders them. Three or more callsites
  with the same flaw point at the primitive.
- Rank groups by reach: the viewers a flaw touches times how often they come.
- One mid model fixes each group, serially. It decides the level: primitive,
  callsite, a bespoke element where a primitive exists, or a missing primitive
  API. Before changing a primitive it checks every callsite; it escalates a
  missing API to the owner.
- Re-check: capture again with the same manifest and a new `out`. Give a finder
  the before and after captures of every view the fix touched. A fix passes
  when its finding is gone and the finder sees no new defect.
