# Product context packet

The orchestrator completes this before dispatch. Inline the result in the
finder task: a screenshot worker should not have to rediscover product behavior.
This is a template, not permission to invent research or add all project docs.

## Person and job

- App/domain: <what the product does, in ordinary language>.
- Viewer and authority: <relationship to the entity, permissions relevant here>.
- Visit: <trigger, main decisions, intended successful outcome>.
- Familiarity: <what they know about the domain, app and specialized concepts>.
- Priorities/frequency: <documented facts, or explicitly labeled review scenario
  assumptions>. Unknown: <what would change a hierarchy/disclosure judgment>.

## Domain and behavior

Explain each object a reviewer needs, how objects relate, and any distinction
that a simpler interface must preserve. Use plain language before schema names.
Include relevant defaults, combination rules, exceptions, inherited state,
destructive consequences and whose permissions are being displayed. Prefer a
small worked example for a non-obvious rule; derive it from the source contract.
If current and legacy behavior coexist, identify which applies to the captured
entities, or leave that version unknown. Do not generalize a new rule over old
rows merely because the feature documentation describes the new behavior.

State intended behavior separately from observed configuration. Identify which
facts are owner requirements, product documentation or implementation evidence.
Do not present a source component's current layout as the intended design.

## Visible state and boundaries

Describe the actor, entity, capture revision, viewport, theme, fixture data and
relevant intentional features. Give each capture's job in the capture list.
List what the captures do not establish, such as hidden states, frequency,
runtime enforcement or other viewers. Do not include credentials or account
files. Sources are provenance for the parent; image-only finders do not read them.

## Source ledger

For every consequential fact above, record <revision, path/section, evidence
kind>. Resolve contradictions if practical; otherwise mark them unknown. Prefer
the revision used for captures. Record any unavoidable version mismatch.

## Handoff boundary

Describe what the reviewer can judge with this evidence and what the later
implementer must verify. A visual worker reports repeated symptoms; an
implementer inspects relevant shared components and callsites before choosing
where to change code. Conceptual changes must preserve the supplied rules.

Keep owner annotations, previous model findings and answer keys out of the
packet during discovery evaluations. Supplying domain facts and priorities is
legitimate context; supplying a list of defects makes it a different task.
