# Contextual brief C: Luna Max and a direct Sol High review

The richer brief helped Luna explain concepts and access rules, but did not produce broad visual coverage. Sol High gave a more useful contextual review in this batch and recovered the short-column symptom with a source hypothesis. Both approaches still missed much of the owner's detailed visual critique. This is a development experiment, not a general model ranking.

## What ran

- Three independent GPT-6 Luna runs at max reasoning, on new brief C.
- Then one independent GPT-6.1 Sol run at high reasoning, with the same product packet and images, full product documentation and selective read-only source access.
- Same six Girls Who Code / Super Admin / 1680×1020 dark captures as before. Every arm has an image-only folder; SHA-256 inventory verifies identical copies.
- All source material is pinned to capture revision 4c2a5546. The source snapshot has 264 files; availability is not the same as loading all of them into the model.
- The Sol task and source snapshot were prepared before Luna returned. No reviewer received the owner's annotations, historical findings, other reviewers' outputs or evaluation reports. The orchestrator knew those examples when designing C, so these are not held-out screenshots.
- This compares practical workflows. Model, detailed instructions, source access, cache state and repetition count differ. It does not isolate any one causal factor and does not test implementation or the full fixer/re-check chain.

All 24 final finding blocks and seven product questions are preserved verbatim and mapped in [results.json](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/results.json). Every item appears in the comparison below; none was silently removed for being wrong.

## What changed in the brief

The [finder brief](/Users/sreysus/config/home/agents/skills/ui-review/finder-brief.md) is now organized around four evidence needs:

1. **Visual:** composition and regional inspection, comparing geometry, typography, boundaries, surfaces and icons through their actual roles.
2. **Workflow:** user task, current location/state, action scope and prominence, with frequency assumptions explicitly marked.
3. **Concepts:** a plain-language product contract, worked access example, defaults and exceptions. Knowledge supplied to a reviewer is not evidence that the interface teaches it to a user.
4. **Implementation:** observed symptoms versus suspected causes; repeated symptoms create a source/callsite handoff rather than proof of a primitive defect.

Design directions and simplification proposals are now allowed, with capabilities/tradeoffs preserved. Product questions are separate from supported defects. The old brief's blanket repetition/sameness rules are replaced with task-based judgments. We removed the old scenario's unsupported demand for an explicit active/inactive indicator and its assertion that the announcements description guarantees member-read-only behavior. Their disappearance from output is therefore not an independently discovered improvement.

The context packet specifies actor authority, familiarity and task assumptions, role/unit/channel distinctions, independent placement/read/post settings, OR/AND and ancestor rules, automatic channels, whiteboards and account setup. It marks missing analytics and unseen states. The image reader and wrapper are named explicitly, eliminating the perceived need for tool discovery.

| Written input | Words | Bytes |
| --- | ---: | ---: |
| Previous Luna Max B++ task | 818 | 5,628 |
| New Luna Max C task | 2,011 | 14,475 |
| Product packet within C | 760 | 5,397 |
| Sol direct task, including same packet | 1,371 | 10,550 |

The Luna task is 2.46× the previous word count. This is a bundle of changes: domain facts, scenario corrections, review instructions, tool guidance and output schema. An observed change cannot be attributed just to adding product context.

## Audit

All three Luna C runs pass the strict operation audit: six original-detail views, one per capture, one image-only wrapper, no discovery, shell, Computer Use or other file access.

Sol also viewed each image once at original detail. Its six wrappers made 13 read-only shell searches/reads inside the pinned snapshot, using cat, rg, nl, sed and tail. All three complete product documents were read; relevant source was consulted selectively. Some requested layout files were absent, limiting that inspection. No edits, external access, app interaction, delegation or prior-review reads were logged.

The generic image-only audit intentionally rejects Sol's source reads and stops parsing that mixed wrapper before counting its images. Its diagnostic is retained as [sol-direct-image-only-audit.json](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-image-only-audit.json), **not used as Sol's eligibility result**. The separate [source-enabled audit](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-source-audit.json) manually checks all logged operations and uses the image-only AST checker on the isolated image block. Sol passes its actual declared scope.

The previous B++ batch has only one compliant trial under its tool rule; two used discovery. Historical raw results remain informative but are not three clean controlled baselines.

## Quality: what improved and what still failed

Luna now connects “Make this role a group” to directory tabs rather than organizational units, explains the audience formula, and makes useful conditional handoffs. All three report the access-form ambiguity. Two identify the role-group label. These are useful changes in the kinds and arguments of its findings.

However, it still returns a narrow conceptual review. None reports the exact recurring short-column symptom, raised-tab contrast, isolated tab row, field-boundary contrast or the full typography system. The prior B++ compliant trial returned four findings; C returns four, five and three. Longer reasoning and a richer brief did not produce broader visual inspection in these runs.

Sol's stronger contributions include the exact bottom band and plausible spacer cause, ambiguity between the overview announcements feed and the announcements channel, assignment-import naming, directory-group naming, hidden-at-rest person-management actions, permission bulk grants, and the separation of channel placement from access. Some were already found by earlier Haiku runs; new to this round is not necessarily new to the experiment.

Sol's short-column finding is **source-assisted**. It read the onboarding source as well as the images; this cannot establish that a source-free Sol would identify the same symptom. It correctly treats the spacer as a cause to verify and preserves the intended launcher.

### False claims and orchestration errors

- **C2 F1 is false:** the setup launcher is visible on People and Club settings, which it calls absent. Tool compliance does not establish perceptual accuracy.
- **C3 F1 mixes a defensible salience preference with an unsupported overlap claim:** the People list ends above the launcher band. It does not identify the actual lost-column-height problem.
- **C2 F2 / C3 F2 are not established missing features:** the source already displays the first unit and a +N count when a person has unit names (People page, lines 1506–1559). The screenshots alone do not establish whether those demo members have assignments. An unassigned-state cue might be useful, but that is a different claim requiring evidence.
- **I supplied an incomplete contract:** the packet describes version-2 selected people as additive exceptions, while legacy CUSTOM/private channels can be explicit-only until saved. The channel-list summary deliberately says Selected people in that legacy branch. C1 F4 overgeneralizes the packet; C2 F5 acknowledges checking the active configuration, but shares the incomplete premise.
- Sol could consult that compatibility source but did not identify the legacy exception either. More capable review with source access is not exhaustive verification.
- Read-only wording versus the posting selector remains a legitimate presentation/configuration question, not proof of unauthorized posting. Source inspection shows a specific compatibility check worth doing: the editor initializes from raw postingPolicy, while effectiveChannelPolicy also considers legacy visibility. The captured row's stored policy version was not queried anew.

The [post-dispatch correction](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/product-context-correction.md) preserves exactly what was missing. Original input tasks were not rewritten. The reusable packet template now asks which behavior version applies to captured entities. Shared context can amplify an orchestrator mistake across independent workers.

## Complete new-output comparison

References open each run's full verbatim review. F means a finding; Q means a product question. A reference records what was reported, not that the owner accepted it. Each finding/question has one primary family in this table.

| Observation / question | Luna C1 | Luna C2 | Luna C3 | Sol High | Provisional assessment |
| --- | --- | --- | --- | --- | --- |
| Launcher scope, space and attention | — | [C2 F1](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c2-1.md) | [C3 F1](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c3-1.md) | [S1 F2](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | C2 claims absence falsely; C3 calls overlap without the actual short-columns symptom. S1 identifies the band and preserves the intended launcher. |
| Role group versus directory tab | [C1 F1](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c1-1.md) | [C2 F3](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c2-1.md) | — | [S1 F5](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | Useful contextual candidate. S1 checks the existing tooltip; C2 appropriately asks for that check. |
| Channel audience formula | [C1 F2](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c1-1.md) | [C2 F4](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c2-1.md) | [C3 F3](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c3-1.md) | [S1 F8](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | All C runs apply context to visible wording; S1 adds the unit-helper qualification and admin-bypass consequence. |
| Read-only cues versus posting setting | [C1 F3](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c1-1.md), [C1 Q1](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c1-1.md) | — | [C3 Q1](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c3-1.md) | [S1 F9](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | Configuration/presentation question, not proof of unauthorized posting. S1 also checks the visibility icon and selector initialization. |
| Selected people audience summary | [C1 F4](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c1-1.md) | [C2 F5](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c2-1.md) | — | — | Not established as wrong. Packet omits legitimate legacy explicit-only policy. C2 preserves a verification caveat. |
| Unit memberships absent from People rows | — | [C2 F2](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c2-1.md) | [C3 F2](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c3-1.md) | — | Unconfirmed from this fixture; source already renders names and +N when present. Do not implement as a missing feature on this evidence. |
| Two announcement destinations | — | — | — | [S1 F1](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md), [S1 Q1](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | Useful conceptual candidate; distinct feed/channel surfaces are supported, relationship needs a product decision. |
| Resting-state person-management discovery | — | — | — | [S1 F3](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | Source supports hidden hover/focus footer; no claim that keyboard or hover operation fails. |
| Import units versus importing assignments | — | [C2 Q1](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/luna-c2-1.md) | — | [S1 F4](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | S1 resolves the operation from docs/source and proposes accurate visible wording. C2 leaves the task relationship open. |
| Bulk permission grants with collapsed detail | — | — | — | [S1 F6](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | Concrete scope/disclosure candidate, already related to earlier Haiku findings; not new to the whole experiment. |
| Conversation route to channel settings | — | — | — | [S1 F7](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | Source supports a desktop discoverability concern; not an exact match for the owner breadcrumb proposal. |
| Whiteboard editing policy and disable semantics | — | — | — | [S1 F10](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | Contextual candidate; some supporting copy is source-derived below the visible edge. Actual reader expectations remain a design judgment. |
| Automatic unit-channel creation scope | — | — | — | [S1 F11](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | Distinguishes future default and backfill, seeks predictable consequences; source shows direct mutation, runtime behavior not exercised. |
| Placement independent of access | — | — | — | [S1 F12](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | Directly addresses unit/channel relationship at the operation, while acknowledging there are no nested units in this capture. |
| Administrative overview priorities | — | — | — | [S1 Q2](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | Usage question, not an accepted requirement to redesign the overview. |
| Whiteboard and import prominence | — | — | — | [S1 Q3](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | Conditional product question; no usage-based decision to demote either. |
| Verifying an audience change | — | — | — | [S1 Q4](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings/sol-direct-1.md) | Product question about the needed preview, not evidence that every workflow needs a complete member preview. |

## Coverage against the owner's annotations

A dash means the final output did not make that observation, not that the model is incapable. Related findings and opposite judgments are explicitly qualified. There is no total recall score: some annotations are proposals, some candidates are disputed, and no fresh owner acceptance labeling has happened.

| Owner observation | Luna C1 | Luna C2 | Luna C3 | Sol High |
| --- | --- | --- | --- | --- |
| Columns stop above window bottom | — | — | — | F2: exact symptom + source hypothesis |
| People tabs have raised depth against flat rest | — | — | — | — |
| People tabs leave an isolated short top row | — | — | — | — |
| People list feels sparse/lopsided | — | — | — | F3: related unused space, different discoverability diagnosis |
| Full text-role/color/size system | — | — | — | — |
| Crowded chat controls | — | — | — | — |
| Monotonous chat icons | — | — | — | — |
| Chat/Whiteboards peer hierarchy | — | — | — | Q3: conditional prominence question; no chosen redesign |
| Inconsistent back controls / breadcrumb hierarchy | — | — | — | F7: related route-discovery concern, not breadcrumbs |
| Remove unnecessary General heading | — | — | — | — |
| Section/field title hierarchy | — | — | — | — |
| Specific field/picker/textarea boundary contrast | — | — | — | — |
| Simplify overexposed Selected people editor | — | — | — | — |
| Remove helper explanations judged obvious | F2 instead calls for clearer rules | F4 instead calls for a rule summary | F3 instead calls for clearer rules | F8/F12 instead call for rule clarity |
| Exact reorder/indent helper judged redundant | — | — | — | F12 challenges missing semantics, not redundancy |
| Broader unit/channel/placement relationship | F2/F4: narrower access claims | F3/F4/F5: narrower group/access claims | F3: narrower access claim | F11/F12: creation and independent placement/access |
| Surface/background coherence across controls | — | — | — | — |

Sol addresses unit/channel relationships more directly, but does not reproduce the proposed breadcrumb system or choose to demote Whiteboards. It leaves usage-dependent prominence as a product question, which is appropriate given the missing evidence. Neither review justifies deleting helper text solely because the owner finds the rule familiar.

## Child execution costs

Input includes repeated harness/history and image costs across model requests. Cached input is a subset of input. Output includes reasoning; reasoning is shown separately, not added again. Requests are transcript token-count records, not an audited API invoice.

| Run | Findings | Questions | Wall | Requests | Input | Cached input | Uncached input | Output | Reasoning subset |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| C1 · gpt-6-luna max | 4 | 1 | 153 s | 2 | 60.6k | 39.0k | 21.6k | 8.3k | 7.2k |
| C2 · gpt-6-luna max | 5 | 1 | 227 s | 2 | 60.7k | 26.0k | 34.7k | 12.4k | 10.9k |
| C3 · gpt-6-luna max | 3 | 1 | 230 s | 2 | 60.6k | 39.0k | 21.6k | 12.5k | 11.5k |
| S1 · gpt-6.1-sol high | 12 | 4 | 135 s | 7 | 404.5k | 342.4k | 62.1k | 5.2k | 0.5k |
| **Luna C ×3 total** | **12** | **3** | **231 s batch span** | **6** | **181.9k** | **104.1k** | **77.8k** | **33.2k** | **29.7k** |
| **Previous Luna B++ ×3 raw total** | **10** | **0** | **103 s batch span** | **8** | **223.9k** | **118.3k** | **105.6k** | **15.3k** | **13.1k** |

The new batch's output is 2.17× the previous raw batch, with 2.26× the reasoning tokens and roughly twice the batch latency. The written task grew much more than total input per two-request compliant run: old B++-2 used 57.8k input, new C runs about 60.6k. Harness and image context are substantial. The raw old batch had extra discovery/model requests, so its larger total input does not show the longer brief was intrinsically cheaper.

Sol took 135 seconds versus 153–230 seconds per Luna C run. It used 404.5k input across seven requests, but 342.4k was cached. Its 62.1k uncached input is below the combined three-Luna 77.8k, and it generated only 5.2k output versus 33.2k combined. A single Luna used 21.6–34.7k uncached input and 8.3–12.5k output. These are usage dimensions, not equal-price units; unknown model weights and subscription rules prevent a dollar-cost winner.

## Orchestrator preparation and review cost

Initial authoring and preparation took about **6 min 21 s** from the user request to dispatch. This includes rewriting reusable skill templates, checking source documentation, preparing the domain packet, copying images, exporting pinned source and creating tasks. It is not a measurement of recurring packet preparation alone.

The parent transcript permits approximate phase accounting. It is a long inherited session with repeated cached prefill, so report cached and uncached amounts separately. Token boundaries use the latest logged usage record before each phase cutoff. The snapshot below is at 2026-11-10T01:35:11.544369+00:00; subsequent reporting/tool usage is not included.

| Parent phase | Input | Cached input | Uncached input | Output incl. reasoning |
| --- | ---: | ---: | ---: | ---: |
| initial authoring and preparation | 874.9k | 803.6k | 71.3k | 13.7k |
| luna dispatch audits and sol dispatch | 1268.3k | 1238.3k | 30.0k | 4.8k |
| post sol adjudication and reporting to snapshot | 1523.0k | 1502.5k | 20.6k | 21.7k |

Initial preparation alone used 71.3k uncached input and 13.7k output, comparable in scale to the three Luna children's uncached input. A cost argument that counts only workers therefore omits material work in this experiment. But charging all reusable template engineering and this custom comparison report to every future review would also be misleading.

The remaining parent work includes checking false visual claims, discovering the compatibility omission, preserving logs, grouping all 24 blocks, and reporting. None is measured human labor: the owner has not yet spent time validating these candidate labels. No estimate of their eventual review time is disguised as an observation.

The prepared 760-word packet can be reused for the same domain/revision/viewer and updated when facts or priorities change. Image copying/task generation is mechanical. Determining the right semantics, resolving version differences and adjudicating subtle claims remain judgment work. This experiment did not measure their steady-state cost, and Sol received the same prepared packet, so it does not establish how much a source-only direct reviewer would save on preparation.

### Shared subscription meters

- Before Luna: Codex 5-hour meter 25%; after Luna and parent callbacks: 29%.
- Before Sol: 29%; after Sol: 32%.
- Weekly: 5% → 6% → 6%.

These are +4 and +3 percentage-point shared-account intervals, including parent and any concurrent sessions, with different meter timestamps. They are not the children's price or evidence of a precise marginal cost. Model-specific billing/rates were unavailable; no invented conversion to dollars is made.

## Consequence for the skill

Keep C as the current experimental brief: its clearer evidence boundaries and domain grounding are useful. Treat this Luna configuration as a candidate conceptual/access-clarity pass, with visual coverage unresolved. The direct Sol workflow produced the more useful review of these pages in this sample, but still needs visual scrutiny and owner adjudication.

The next deployment of the skill should reuse the templates and verified domain facts, identify compatibility behavior when relevant, and account for preparation plus adjudication. This result does not establish a universal model hierarchy, prove a whole-codebase rewrite is needed, or demonstrate the fixer/re-check chain.

## Artifacts

- [Finder brief](/Users/sreysus/config/home/agents/skills/ui-review/finder-brief.md), [context template](/Users/sreysus/config/home/agents/skills/ui-review/product-context.md), [direct reviewer brief](/Users/sreysus/config/home/agents/skills/ui-review/direct-review-brief.md).
- [Exact C1 task](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/task-luna-max-c-1.md), [C2 task](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/task-luna-max-c-2.md), [C3 task](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/task-luna-max-c-3.md), [Sol task](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/task-sol-high-direct.md).
- [Given context](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/product-context.md), [later correction](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/product-context-correction.md), [source provenance](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/source-provenance.json), [image hashes](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/inventory.json).
- [All results/mappings](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/results.json), [parent accounting](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/parent-costs.json), [brief sizes](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/brief-size.json), [audit and verbatim outputs](/Users/sreysus/workflow/ia-app-archives/ui-review-eval-20261109/gwc-r2-context/findings).
- [Previous comprehensive comparison](/Users/sreysus/config/docs/ui-review-comparison-2026-11-09.md).
