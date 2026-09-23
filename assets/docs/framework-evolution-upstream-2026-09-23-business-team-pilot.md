# Framework-evolution upstream — 2026-09-23 — the multi-agent reporting pilot

**Source (one doc):** `framework-evolution-2026-09-23-business-team-pilot.md`, written by the
production multi-tenant project (tier `production-financial`). Throughout this doc it is called
"the production project".
**Absorbed in:** v2.33.0 (MINOR). **Session:** `/maintenance`, 2026-09-23. The owner authorized the
absorption after the Step 0 sweep and chose "bump now, audit later".

## Context

The source doc measures Phase 1 of the Core + Teams proposal, a local-only framework note that is
not tracked. A second, non-IT team (a profitability analyst, a report synthesizer and a blind
validator, with an IT data engineer on `sonnet`) produced one monthly report end to end. The
validator APPROVED it with a zero-difference oracle match. The pilot's cut condition was declared
beforehand: "correct with ONE data round and no cross-team requests". It was NOT met: 3 rounds and
16 cross-team requests were needed, and the second round changed the result's sign. Measured cost
was ≈1.43M subagent tokens, roughly ten times the proposal's estimate.

**Scope decision:** most of the doc is input to Phase 3 (the `team.md` manifest), which the owner
has not scheduled. The framework has no team module yet, so nothing that depends on one graduates
here. Only principles that already apply to single-team projects ship now: reviewer subagents,
non-`inherit` extractors and hook-confined agents all exist today.

## Dispositions

| # | Evolution (source section) | Verdict | Landed in |
|---|---|---|---|
| G1 | §4.4 + the §1 `model:` measurement: whether a cheaper extractor is safe depends on the TOPOLOGY, i.e. a mechanical lock or a judging consumer downstream | **graduated as HYPOTHESIS EVIDENCE only** | `docs/modules/rules/session_rules.md` → "Model by risk class": the first measurement and its topology reading, inside the HYPOTHESIS blockquote (n=1). A drafted ALWAYS/NEVER topology rule was CUT before commit: two shipped `sonnet` defaults would violate it on arrival, and it contradicts the section's "decided by risk class, written once" |
| G2 | Gap #4 (installed ≠ available: an agent created mid-session cannot be spawned in that session) | **adapted** to FAILURE HANDLING: a same-session `not found` on a new agent is expected, and the spawn (a creation eval included) moves to the next session. It does not forbid the same-session creation evals bootstrap already runs | `docs/modules/rules/component_design.md` §8 rule 4, marked `verified: false`. Also in this repo's own `.claude/rules/component-design.md` §8 |
| G3 | §5b's review lesson (a denylist is always one form behind; the allowlist is per tool, on the field that tool uses) + gaps #1, #2, #9 (restriction by mechanism, not prose; "aggregates only" = refuse row ids) + gap #11 (a live probe must be owner-requested) | **adapted** (genericized into checklist items) | `docs/modules/agents/security_reviewer.md` → new section 13, "AI-Agent Tool Gates", and its line in "What this review covered". **ROUTING is not changed:** no invoker yet sends a hook/permission diff to the security reviewer (`AE-15`, open) |
| G4 | §4.5 + gap #5 (the coordinator is not a copy layer) | **adapted**, scoped to the one place the framework already has a coordinator saving a subagent's output | `docs/modules/skills/validation-orchestrator/SKILL.md` → Review receipts item 1 ("verbatim means untransformed"). The "save a transformed copy and have the producer audit it" half was CUT: nothing records it |
| G5 | §4.2 (non-tautological oracle) | **adapted** | `docs/modules/rules/ops_rules.md` §6 Data reconciliation, one checklist item |
| G6 | §4.3 (cut condition declared BEFORE) | **adapted** | `docs/modules/rules/evolution_policy.md` → "Framework-evolution docs": a pilot's doc records its cut condition and WHEN it was declared. No shipped step can force "before", so the doc states which it was |
| D1 | §4.1 (a cross-team request is a contract, and a contract is a file) + gaps #3, #5 (write-scope half), #6, #7, #8, #10, #11 (protocol half) | **deferred to Phase 3**: requirements for the `team.md` manifest, already mirrored in the proposal's §10.1 item 4 | — |
| R1 | The query runner, the tool-gate hook and their tests | **kept project-local**: stack-specific code. Hooks stay project-local by the owner's earlier decision (the rules-gate precedent). The portable lesson shipped as G3 | — |
| R2 | Hub incident 2 (an opening prompt with an unfilled `<name>` placeholder was accepted silently) | **kept project-local**: it came from a hand-written handoff, not a framework template | — |
| R3 | Efficacy anchors E1–E6 + Meta | **kept project-local**: they measure the project's own team and hypothesis cycle | — |

**Not changed:** bootstrap installs all six targets as it already did. No command pipeline change,
no new component, no new report key.

## Migration

Six independent text additions; no coordinated refresh set. See `existing_project_adaptation.md`
→ "v2.33.0 migration". `security-reviewer` is offered as an in-place insert, never a refresh,
because it is customized at bootstrap.

## Efficacy anchors — and who measures them

| Anchor | Verifiable question | Measurer |
|---|---|---|
| G1 | Does a second run with a non-`inherit` extractor record its errors by axis (locked vs narrated) and name who caught each? | **unmeasured, no measurer at any tier.** `framework-audit` Q4 enumerates hypotheses but counts only one hardcoded signal (as the rule itself states), so it cannot produce this count |
| G2 | Does any later session log show a spawn attempted in the same session that created the agent? | **unmeasured, no measurer at any tier**: nothing reads spawn failures by creation session |
| G3 | Does the next hook or permission-rule diff reviewed by `security-reviewer` list section 13 in `Sections checked`? | **unmeasured, no measurer at any tier**: no audit reads that line, and no invoker routes such a diff yet (`AE-15`) |
| G4 | Does any saved review report differ from the subagent's returned text? | **unmeasured, no measurer at any tier** |
| G5, G6 | Text items, no mechanism installed | **unmeasured, no measurer at any tier** |
| Source E1–E6 | The project's own questions | the production project's own `framework-audit` (installed at its tier), per its own doc |

## Discharge

The source doc is **dischargeable**: the production project's next session marks its header
`upstreamed`, citing this file and the absorbing commit. The owner did NOT authorize this session to
mark it from here, and this session made no edit under `projects/`.
