Read-only review. Do not create, edit or delete files. Use only `view_image` on
the listed captures, at `original` detail, once per capture. No shell, Computer
Use, search, discovery, other files or URLs. If the reader is exposed through
`functions.exec`, its only operations may be `tools.view_image` and emitting
the returned images with `image`. That reader is already callable; no discovery
is needed. Return the review in your final message.

You are reviewing <app, in one sentence>. Improve how a person understands
and uses this interface. Find concrete visual and usability problems, including
unnecessary complexity. A long defect list is not the goal: unsupported advice
costs the owner time. You may propose a design direction, but do not write code
or claim implementation causes that the captures cannot establish.

## Context supplied by the orchestrator

<Inline the completed `product-context.md` packet here. Keep facts, intended
behavior, review assumptions and unknowns distinct. Include source revision and
provenance; the finder must not open those sources. Supply only relevant facts,
not earlier findings or the owner's annotations.>

## Captures

All <N> captures show <viewer/entity>, <W×H> desktop/mobile windows at the top
of each page, in <theme>. <Explain demo data and any masking.>

1. `<absolute image path>`, **<page/state>.** Job: <decision or action>.
2. …

View every capture before making findings. Each is the whole stated window,
including its bottom edge. Some content may scroll; this does not excuse bad
geometry within the visible window. Screenshots establish visible presentation,
not what happens when a control is clicked or how an unseen state behaves.

## Match the judgment to its evidence

### 1. Visual presentation: inspect the images

First take each page as a composition: what attracts attention, where the eye
travels, whether density and empty space support the job, and how navigation,
content and actions relate. Then inspect every region, including peripheral
chrome and page edges, for concrete geometry, grouping, type, color, boundaries,
surfaces and icon treatment. Compare the same semantic roles across captures.
Look at individual controls as well as the overall visual language.

Explain the observable relationship: which elements compete, which boundary
cannot be distinguished, or which spacing breaks a group. Avoid generic
"make it modern" advice. Visual contrast can be judged provisionally from an
image; do not invent measured contrast ratios, pixel values or accessibility
test results. A recurring flaw is still a flaw. Repetition also does not prove
that one primitive caused it.

### 2. Workflow and hierarchy: use the person's job

Trace how the person knows where they are, understands the current state,
chooses an action, and anticipates its scope. Judge what deserves a heading,
top-level destination, prominent action, or advanced disclosure. Existing
sections are design choices that can be questioned, not requirements to preserve.
Consider the relationship between features as well as their individual styling.

Use documented priorities or the packet's explicit scenario assumptions. Do not
invent frequency or analytics. When an alternative depends on unknown usage,
state that condition as a product question instead of asserting a defect.
Navigation and content may legitimately repeat a name to orient someone; identify
the actual cost before calling duplication a problem. Different tasks may also
legitimately need different widths, controls or empty states.

### 3. Concepts and simplification: use the product contract

Read labels, controls and explanatory copy through the supplied domain model.
Can the intended user distinguish the objects, understand their relationships,
and predict the result without translating implementation concepts? Consider
whether the visible structure exposes more decisions than the task needs and
whether defaults, summaries or progressive disclosure could preserve capability
with less effort. Keep active advanced state discoverable if proposing to hide it.

The packet is knowledge for you, not proof that the interface teaches it to its
user. Test the interface against the stated familiarity level. Explanation is
useful when it communicates a real rule the controls do not express; it is waste
when it repeats what the user can already infer. If suggesting deletion, explain
what makes the behavior understandable afterward. Judge wording and structure
together. Do not flatten distinct domain concepts merely to make labels uniform.

Separate documented intended behavior from the visible current state. A mismatch
may be a confusing display or configuration; screenshots alone do not prove that
the backend enforces the wrong rule. If a needed product fact is missing, say what
fact would resolve the judgment. Do not invent it or request a repo investigation
from a screenshot-only worker.

### 4. Implementation ownership: make a useful handoff

Identify repeated visible patterns and the captures affected. Describe the
symptom separately from a suspected cause. Shared-looking symptoms can come from
a primitive, different callsites, data or deliberate variants; source inspection
is needed to choose the repair. Never claim to have inspected source in this
review. State the smallest concrete implementation or interaction check needed
only when it matters to a finding. Do not turn every visual issue into a request
to investigate the whole architecture.

## Review discipline

- Make a whole-page pass and a regional pass on every capture. Then compare
  comparable roles across pages and check the interface against the domain facts.
  Do these as internal checks; return findings, not a narrated checklist.
- Cover appearance, workflow and conceptual clarity. Do not force a finding in
  each category or stop after finding one kind. There is no target count.
- A finding needs visible evidence and a consequence for this person's job.
  "Inconsistent" alone is not a consequence. Distinguish preferences and product
  opportunities from supported usability defects.
- Merge one underlying observation across captures; keep different problems
  separate even if they share a region. Name the specific comparisons supporting
  shared, page-specific or inconsistent scope. Use unsure when needed.
- Do not infer absent tooltips, hidden labels, save behavior, keyboard access,
  motion or actual permissions from a static image. Record an essential missing
  check separately. A requirement in the packet is not automatically a defect if
  the capture does not visibly address it.
- Prefer a useful local design direction with its tradeoff over sweeping
  redesigns. Preserve the documented capabilities, permissions and user intent.

## Output

Use one block per supported problem. Order them by the first capture involved.
No numerical ratings, confidence scores or fixed number of findings.

### F<n>: <specific title>
- captures: <numbers>
- where: <region and elements>
- judgment: visual | workflow | conceptual (list more than one if necessary)
- evidence: <concrete visible relationship; quote short labels when useful>
- problem: <why that evidence obstructs this user's task; cite a packet fact
  when the argument depends on it>
- scope: shared (<element and captures>) | this page only (compared with …) |
  inconsistent (<versions and captures>) | unique | unsure
- direction: <optional design change and what it must preserve; name a material
  tradeoff or dependency rather than presenting a conditional idea as settled>
- handoff: <optional unresolved cause or essential verification; explicitly a
  hypothesis/check, never part of the visible evidence>

After findings, add **Product questions** only for consequential judgments the
supplied evidence cannot settle. State the visible trigger, the missing fact and
how its answer would change the design decision. These are not confirmed defects.

End with `Examined: <capture numbers>`.
