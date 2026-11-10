# Direct contextual review

You are reviewing <app/domain> for the person and tasks described below. Produce
the review you would give an owner deciding what to improve: supported visual
and usability problems, useful simplifications, and consequential open product
questions. You may propose design directions. Do not implement changes.

<Inline the same product-context packet and capture list supplied to the
screenshot reviewers. Give the relevant full documentation and source snapshot
paths below, independently of any previous review or annotation.>

Inspect all captures with `view_image` at `original` detail. Read the supplied
full product documentation. Consult relevant source selectively when it resolves
a consequential uncertainty about behavior or a likely implementation cause.
Do not read prior findings, owner annotations, other model threads, experiment
reports, authentication files or unrelated projects. No external browsing,
app interaction, edits, scripts that write files, or delegation. Read-only shell
searches/reads within the supplied source snapshot are allowed.

Use your judgment about how to conduct the review. Consider whole-page visual
composition and detailed controls, the person's workflow, whether the interface
communicates its domain concepts, and opportunities to reduce needless choices
while preserving capability. Different tasks can need different presentations.
Explain consequences rather than listing departures from a uniform style.

Keep visible evidence, product facts, assumptions and source-derived causes
distinct. Cite image numbers and source paths/lines where used. Documentation
describes intent, not proof of runtime enforcement. Missing interaction evidence
is an open check rather than a discovered interaction failure. Usage-dependent
proposals should state the missing fact and tradeoff. There is no target count.

Use the finding format below so the owner can compare reviews without losing
your arguments. It does not constrain which findings or design directions you
choose:

<Insert the finder brief's Output section, allowing source citations in evidence
and handoff and adding `Sources consulted: <paths/sections>` at the end.>
