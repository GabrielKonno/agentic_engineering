---
name: codebase-audit
invocation: user
effort: high
description: >
  Periodic holistic health audit of the SYSTEM (not a single diff). Answers "is the codebase
  as a whole healthy?" — fans out general-purpose agents across dimensions (separation/
  maintainability, security, performance, types/tests), runs the ops checklist, harvests
  metrics against quality budgets, and triages aged debt. Reuses existing specialist agents
  for depth ONLY on confirmed money/security findings. USE PROACTIVELY when sprint-proposer
  reports AUDIT_CADENCE reached or at a phase boundary. NOT needed per-diff (the per-diff
  reviewers own that). Without this, whole-system rot (a 3000-line file, PITR left OFF, aged
  debt) accumulates silently until ~100 sessions in. Produces a Codebase Audit Report →
  archives findings as tracked tasks; NEVER auto-fixes.
created: framework-v2.3.0 (pre-validated)
derived_from: framework-base-upgrade.md §2.1 (dual-axis review) — the MACRO axis
---

# Codebase Audit

The MICRO axis ("is this change good?") is owned by the per-diff reviewers. This skill is the
MACRO axis ("is the SYSTEM healthy?"): a periodic, breadth-first audit that archives work
instead of fixing it.

## Profile gate

Active for `internal-tool` (sparse), `production`, `production-financial`. Not copied for
`prototype`. Read the project's risk profile from `project.md` Overview to scale depth (financial
profiles add data reconciliation; lighter profiles stop at the breadth pass).

## When to run

Proposed by `sprint-proposer` Step 0 when `AUDIT_CADENCE` sessions (default ~12; ~20 for
internal-tool) have passed since the last audit, OR at a phase boundary. The owner accepts or
defers — this is a large unit of work, prioritized like any other.

## Process

### 1. Breadth pass — fan out (cheap, parallel)

Spawn `general-purpose` subagents IN PARALLEL, one per dimension. Each reads the relevant slice
of the codebase and returns findings only (no fixes):

- **Separation / maintainability** — oversized files (vs `quality-budgets.md` caps), god modules,
  cross-module imports that violate the Architectural Decisions, duplication.
- **Security** — surface scan for the project's risk classes (authz on every endpoint, secrets,
  injection, unsafe rendering). Confirmed money/auth findings → mark for the depth pass.
- **Performance** — N+1s, missing pagination/indexes, heavy client bundles.
- **Types / tests** — type-bypass count (`as any` etc.) vs budget, test-coverage gaps on
  business logic, "fragile" snapshot-only tests.

### 2. Depth pass — reuse specialists (reserved, NOT broad)

ONLY for findings the breadth pass CONFIRMED in money/security paths, spawn the existing
specialist agents for depth (red-team, data-integrity-checker, performance-auditor, etc. —
whichever the project has). Do not run specialists speculatively; depth is the expensive tier.

### 3. Ops checklist (production+)

Walk `.claude/rules/ops-rules.md` category by category (backups/recovery, observability,
CI, secret rotation, deploy safety, connection management, data reconciliation). Each category:
PASS / GAP → task.

### 4. Data reconciliation (production-financial only)

Run the project's reconciliation queries against PROD **read-only** (SELECT only). Anomalies
expected = 0; any nonzero is a high-priority finding.

### 5. Metrics rollup + budget check

Append one row to `.claude/phases/metrics.md` (the code health time series). Compare against
`.claude/rules/quality-budgets.md` caps; each breached budget → a finding.

### 6. Debt-aging triage

Read `pendencias.md` "Future Improvements". For each item older than `DEBT_AGE` (~30 sessions
by its `[added sN]` stamp): verdict KEEP (re-stamp) / CLOSE (obsolete) / PROMOTE (active task).

### 7. Recurring-class scan

Read the `## Validation Post-Mortem Ledger` in `project.md`. Any root-cause class with
`Recurring? = YES` is a class with no systemic owner → propose a framework-level fix (or escalate
to `framework-audit`).

## Output

Produce the report, then write every actionable finding as a task in `pendencias.md` (findings
that die in prose are invisible). NEVER auto-fix.

```
## Codebase Audit Report — Session N
### Breadth findings (by dimension):
| Dimension | Findings | Severity | → task added |
### Depth findings (specialists run): [list, or "none — no confirmed money/security findings"]
### Ops checklist: [PASS count / GAP list]   (production+)
### Reconciliation: [anomalies found, or "0 — clean"]   (production-financial)
### Metrics vs budgets: [breached budgets, or "all within caps"]
### Debt triage: [N KEEP / N CLOSE / N PROMOTE]
### Recurring escape classes: [classes flagged, or "none"]
### Tasks added to pendencias.md: [N]
```

## Safety

Investigation-only. Read-only against prod. Cost-disciplined: breadth is cheap and parallel;
depth is reserved for confirmed high-risk findings. Archives tasks; the owner prioritizes fixes.
