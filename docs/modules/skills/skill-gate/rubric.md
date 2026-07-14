---
name: skill-gate-rubric
mode: observation
description: >
  Rubric applied by the skill-reviewer (or red-team, for sensitive drafts) to every
  draft component. The presence of this file activates the gate; `mode: observation`
  additionally requires human confirmation at promotion time.
---

# Skill Gate Rubric

Apply every section to the draft. Sections 1–2 produce `problems[]` and
`overlaps[]`; section 3 produces `empirical_claims[]`; section 4 produces
`detected_category`. A draft with ANY unresolved section-1 problem is
`approved: false`.

## 1. Form (failures reprove)

**1.1 Frontmatter conventions** — per `assets/examples/README.md`: `name:`
(lowercase, hyphenated), `effort:`, `invocation:`, `description:` (Pushy format for
process components: what + MUST-trigger + consequence of skipping; contextual
format for knowledge components), lineage fields (`created:`, `derived_from:`).

**1.2 Class over narrative** — the component must state "when encountering a
problem of type X, do steps Y". Session autobiography ("on Friday's session I
tried A, then B") reproves: narrative forces every future reader to re-derive the
lesson. Report as `type: generalization`.

**1.3 Self-sufficiency** — operational test: *would an agent that has never seen
this project execute this correctly, with no session context?* Any step that
requires knowing what the authoring session was doing reproves as
`type: context-dependence`. This is the property that makes the component
reusable months later.

**1.4 Unambiguous trigger** — the `description:` must make it decidable WHEN to
load the component and when NOT to. Vague triggers ("useful for backend work")
reprove as `type: ambiguity`.

**1.5 Executable precision** — commands complete and runnable, paths explicit,
stop conditions stated, output formats shown. "Run the migration" without the
command reproves as `type: ambiguity`.

**1.6 Size** — a skill body beyond ~150 lines signals wrong scope. Recommend a
split (`type: format`, with the proposed split in `suggested_fix`).

## 2. Overlap

Compare the draft against the provided component index (names + descriptions):

- `duplicate` — an existing component already covers this trigger and content.
  Promotion is blocked; consolidation is a human decision.
- `partial` — overlapping trigger or content; recommend boundary adjustments.
- `complementary` — adjacent but distinct; recommend cross-references.

## 3. Procedural vs. empirical claims (the safety-critical section)

Classify EVERY factual assertion in the draft:

**Procedural** (verifiable by consistency — no flag needed): instructions,
sequences, conventions, formats, decisions internal to the system.
- "Validate input length limits before submitting to the external service" ✓
- "Rules files are loaded via paths: globs" ✓ (internal mechanism)
- "Run the rollback migration before marking a schema task complete" ✓ (sequence)

**Empirical** (truth requires external data or observation — MUST be listed in
`empirical_claims[]`): any claim about the external world. Examples across
project archetypes:
- "The premium service takes ~40 minutes" — measured duration (service business)
- "The provider's free tier rate-limits at 100 req/min" — external system
  behavior; empirical even when it cites documentation (docs drift, limits change)
- "The data source returns split-adjusted prices by default" — third-party data
  behavior (pipeline/integration)
- "This copy converts better" — conversion/usage metric (web/marketing)
- "Vendor Y delivers in Z days" — third-party behavior (operations)
- "Most users run the tool on Windows" — user-population claim (CLI/library)

**Borderline rule:** durations, prices, conversion/usage metrics, vendor/API/
data-source behavior, and user preferences are ALWAYS empirical — even when
stated confidently, even when sourced from official docs. When in doubt,
classify as empirical: a false "procedural" label lets an unverified claim
enter the library as fact; a false "empirical" label merely adds a flag.

For each empirical claim, fill `how_to_verify` with a concrete verification path
(measure it, ask the owner, check real data).

## 4. Sensitive category

Set `detected_category: sensitive` if the draft touches ANY of: credentials or
secrets; deploy or infrastructure; client/personal data; external side-effects
(messaging, e-mail, webhooks, third-party writes); financial operations;
permissions or access control. A wrong or insecure skill is worse than a bad
commit — it is a procedure future sessions will reuse WITH confidence.

## 5. Verdict discipline

- Emit the JSON verdict in the exact schema defined in the skill-reviewer agent.
- Empty arrays as `[]` on a single line (the promotion script greps for this).
- Every problem carries a `suggested_fix` — a verdict that only condemns forces
  the author to guess.
