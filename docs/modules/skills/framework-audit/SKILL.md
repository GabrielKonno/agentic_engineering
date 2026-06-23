---
name: framework-audit
invocation: user
effort: high
description: >
  Periodic META-audit of this project's own PROCESS (not its code). Asks "what is my process
  NOT catching?" — fans out agents over logs / protocols / components / the Post-Mortem ledger /
  metrics and hunts for dimensions with no owner, missing axes, recurring escape classes, and
  aspirational mechanisms that don't actually run. USE PROACTIVELY when sprint-proposer reports
  FRAMEWORK_AUDIT_CADENCE reached or at a phase boundary. NOT a code review (codebase-audit owns
  that). Without this, process blind spots survive for ~100 sessions until a human happens to ask
  the meta-question. Produces a batch of FRAMEWORK improvements (BEHAVIOR class) → explicit owner
  approval → implement. It is the recursive generator of the other improvements.
created: framework-v2.3.0 (pre-validated)
derived_from: framework-base-upgrade.md §3.7 + framework-base-deepdive.md §A2
---

# Framework Audit (the meta-loop)

`codebase-audit` asks "is the code healthy?". This asks the recursive question one level up:
"is my PROCESS catching what it should?" It is the mechanism that discovers the rules the
framework is MISSING — the thing that otherwise only happens when a human remembers to ask.

> A robust framework is not the one with the most rules — it is the one with a mechanism to
> discover the rules it LACKS.

## Profile gate

Active for `production` (sparse, `FRAMEWORK_AUDIT_CADENCE` ~35 sessions) and
`production-financial` (more frequent, ~25). Not copied for `prototype` / `internal-tool`.
Cadence is SPARSER than codebase-audit — process blind spots accrete slower than code rot.

## When to run

Proposed by `sprint-proposer` Step 0 at a phase boundary OR when `FRAMEWORK_AUDIT_CADENCE`
sessions have passed since the last framework-audit. The owner accepts or defers.

## Process — the six questions (fan out general-purpose agents to answer each)

1. **Dimension coverage** — does every dimension have an owner? (review/learning, continuity/
   memory, ops, security, eval.) Which is orphaned?
2. **Axis coverage** — does the MACRO axis exist and run (codebase-audit)? The temporal bridge
   (back-sweep)? The lifecycle bridge (ops)?
3. **Recurring-class scan** — read the Post-Mortem Ledger + KBP promotion ledger. Is a CLASS of
   escape recurring that no mechanism owns? (Any ledger row with `Recurring? = YES`.)
4. **Aspirational-vs-real audit** — are there fields/mechanisms CLAIMED but not running?
   (e.g., a `last_eval:` that always reads `none`; a cadence trigger never firing.) Name them
   honestly — an unenforced field is documentation debt.
5. **Meta-metrics review** — read `framework-metrics.md`: is the escape rate rising? Any reviewer
   with high false-positive (cry-wolf)? Any Known Bug Pattern that never triggers (dead weight)?
6. **Back-sweep of process rules** — did a recently promoted PROCESS rule condemn OLDER framework
   artifacts? Apply it backward to the project's own components.

## Meta-metrics rollup (harvested, not a daemon)

As part of this run, append one row to `.claude/phases/framework-metrics.md` (a sibling of the
code `metrics.md`), harvested from artifacts that already exist:

| Metric | Source (already exists) | Healthy |
|--------|-------------------------|---------|
| Escape rate (escapes ÷ tasks shipped, this window) | Post-Mortem Ledger rows | low and ↓ |
| False-positive per reviewer | KBP `false-positive:` counters | low |
| KBP liveness (which trigger vs never) | KBP `triggered:` counters | no pattern dead 20+ sessions |
| Mechanism utilization (routes/specialists/gates fired) | validation reports / Progress Log | none never-spawned |
| Drift incidents caught | prd-sync-checker reports | ↓ |
| Debt aging (count of LOW, oldest age) | Future Improvements stamps | not growing unbounded |

This is a STEP of framework-audit, not a continuous system. One row per meta-audit.

## Output & safety

Produce a batch of FRAMEWORK improvements (BEHAVIOR class). This loop PROPOSES; it does not
auto-modify protocol. Per `evolution-policy.md`, a BEHAVIOR-class batch requires **explicit
owner approval before implementing** — the human gate is mandatory here. Read-only / dry-run
friendly until approved.

```
## Framework Audit Report — Session N
### Q1 Dimension coverage: [orphaned dimensions, or "all owned"]
### Q2 Axis coverage: [missing axes/bridges, or "complete"]
### Q3 Recurring escape classes: [classes with no owner, or "none"]
### Q4 Aspirational-vs-real: [claimed-but-not-running mechanisms, or "none"]
### Q5 Meta-metrics: [escape rate trend, dead KBPs, cry-wolf reviewers]
### Q6 Process back-sweep: [old artifacts a new process rule condemns]
### Proposed framework improvements (BEHAVIOR — needs owner approval):
| # | Improvement | Dimension | Rationale |
### Awaiting owner decision: approve / defer / reject each.
```

## Honest limit

This complements but does not replace per-incident self-correction (the Post-Mortem Ledger) or
the per-diff KBP loop. It catches NEW blind-spot classes periodically; the ledger catches known
classes per-incident. Neither is a proof of correctness — both are nets, declared as nets.
