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
derived_from: "the dual-axis review model — this skill is the MACRO axis (whole-system health); the per-diff reviewers are the MICRO axis. Framework-layer lineage records stay in the framework repo and are NOT copied to projects, so this field names the CONCEPT, never a path a project cannot open (/audit 2026-09-03 N-9)."
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

**ALWAYS append the `metrics.md` row with `Status: IN PROGRESS` BEFORE fanning out** — step 5 replaces
it when the run ends. A usage-limit cut must leave the audit visible as INCOMPLETE, never as "never
opened"; an `IN PROGRESS` row NEVER resets the cadence clock.

Spawn `general-purpose` subagents IN PARALLEL, one per dimension. Each reads the relevant slice
of the codebase and returns findings only (no fixes):

- **Separation / maintainability** — oversized files (vs `quality-budgets.md` caps), god modules,
  cross-module imports that violate the Architectural Decisions, duplication. **Process components
  too:** ALWAYS measure the byte size of every `.claude/rules/*.md`, `.claude/skills/*/SKILL.md` and
  `.claude/agents/*.md` (`wc -c`). Above **~140k** → a finding: plan a split by SUBJECT now, while
  there is room to choose the cut. Above **~150k** → a high finding. Every split made AFTER a file
  overflowed is a split made under pressure, and pressure produces a cut by SIZE instead of by
  subject.
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

**ALWAYS WRITE each measured value back INTO the reconciliation item itself** — measured value ·
date · session — in the rules file that defines the query (`ops-rules.md` or its split files), and
strike or mark `SUPERSEDED` any caveat the measurement contradicts ("production pending", "not run
yet"). Recording the value only in `metrics.md` is NOT enough: the item's own text is what the next
reader trusts.
**Self-check (execute and report):** grep the item file for the caveat words
(`pending|not run|not yet|parked`) → every remaining hit is either struck through or dated AFTER this
measurement.

> Evidence (production project): items kept reading "production pending" and "production = 0"
> after TWO audits had measured their real values, because each audit wrote the numbers only into
> the metrics series. A caveat written while a migration waited for the owner outlived the apply
> and disarmed the item.

### 5. Metrics rollup + budget check

Complete this run's row in `.claude/phases/metrics.md` (the code health time series; step 1 opened it). Compare against
`.claude/rules/quality-budgets.md` caps; each breached budget → a finding.

**ALWAYS fill the row's `Status` column LAST, from what actually ran** — `COMPLETE`, or
`INCOMPLETE (steps N,M not run — reason)` — and ALWAYS write the per-step line beside it
(`steps: 1 ✅ · 2 ✅ · 3 ✅ · 4 ✅ · 5 ✅ · 6 ⏭️ (structural reason) · 7 ✅`; session-rules →
"Cadence integrity": a step skipped for capacity makes the run INCOMPLETE). Steps 1-4 are the expensive half and are exactly the
ones a usage limit, a dead fan-out agent, or an owner interrupt kills first; step 5 is cheap and
survives. NEVER write `COMPLETE` because the metrics step itself succeeded (session-rules →
"Cadence integrity"). The data in a partial row stays valid and readable; only the completeness
claim is withheld — and withholding it is what keeps the cadence honest.
**ALWAYS RUN session-rules → "Cadence integrity"'s self-check over the row's Status cell and REPORT it as
`steps self-check: [1 match | RED]`** — the rule's self-check had no executing step (`/audit` 2026-09-16 A-19):
`grep -E '^\| *[0-9]+ *\|' .claude/phases/metrics.md | tail -1 | awk -F'|' '{print $4}' | grep -oiE 'steps:' | wc -l`
→ **expected 1**, and the same cell piped to `grep -cE '⏭️ *([^( ]|$)'` → **expected 0**. It selects the LAST
DATA ROW, never the file's last line: a table followed by prose read RED on a healthy row (this batch's
pre-commit verifier, 2026-09-19).

### 6. Debt-aging triage — the backlog AND the Known Bug Patterns

Read `pendencias.md` "Future Improvements". For each item older than `DEBT_AGE` (~30 sessions
by its `[added sN]` stamp): verdict KEEP (re-stamp) / CLOSE (obsolete) / PROMOTE (active task).
**Before judging ages, ALWAYS COUNT the items that carry NO age stamp.** An unstamped item cannot be
triaged by age: if they are a large share, the triage is structurally incomplete — say so, and record
the step as ⏭️ with that structural reason, never as done.

**ALWAYS CONSUME the deferred semantic back-sweeps in this SAME step, at every tier this skill is
installed** — this step is their invoker (the extractor files them only at `internal-tool`+, where
this skill exists).
`diff-pattern-extractor` files a rule whose wrong pattern is not greppable as a task tagged
`[back-sweep sN] not greppable`:
```bash
grep -n 'not greppable' .claude/phases/pendencias.md
```
ALWAYS give EVERY hit an explicit verdict: **SWEPT** (the semantic sweep was done now — N violations
found, each filed as a task tagged `origin: discovered (sN, codebase-audit)`, like every other task this
skill writes — `/audit` 2026-09-16 A-24) / **CLOSE** (obsolete) / **KEEP** (with a reason). A hit left without a
verdict makes this step ⏭️ for CAPACITY, and the audit `INCOMPLETE`.

**ALWAYS CHECK that every guard script has an EXECUTABLE invoker** (component-design §9) — a script
that exits non-zero on a violation is a control only if something RUNS it. List the project's
guard/check scripts (e.g. `ls scripts/check-*`, or the `check:*` entries of its task runner), and for
each one grep its name in the CI workflows and in `.claude/skills`, `.claude/commands` and
`.claude/agents`:
```bash
# Invokers = CI config (any provider present) + hook runners (`.claude/settings.json` hooks, `.husky/`,
# `.pre-commit-config.yaml`, `lefthook.yml`) + a `Makefile` + skills/commands/agents. Without the hook runners
# and the Makefile, guards with real invokers printed NO INVOKER (`/audit` 2026-09-16 A-13). A task-runner alias whose
# command names the script (a package.json "check:agents" running scripts/check-agent-frontmatter.mjs)
# counts as the script's own name. Names match at word boundaries: check-backup is not check-backup-age.
CI=$(ls -d .github/workflows .gitlab-ci.yml .circleci azure-pipelines.yml bitbucket-pipelines.yml Jenkinsfile \
  .husky .pre-commit-config.yaml lefthook.yml Makefile 2>/dev/null)
HOOKS=$(grep -hsE '"command" *:' .claude/settings.json)   # hook COMMANDS only — a permissions.allow entry naming a script is not an invoker
n=0; k=0
for s in $(ls scripts/check-* 2>/dev/null); do
  b=$(basename "$s"); b=${b%.*}; n=$((n+1)); names="$b"
  q=$(printf '%s' "$b" | sed 's/[.]/[.]/g')   # a dot in a name is a literal dot, never "any character"
  [ -f package.json ] && names="$names $(grep -oE '"[A-Za-z0-9:_.-]+": *"[^"]*'"$q"'[^"]*"' package.json | cut -d'"' -f2)"
  hit=0; for nm in $names; do nq=$(printf '%s' "$nm" | sed 's/[.]/[.]/g')
    re="(^|[^A-Za-z0-9:_.-])$nq([^A-Za-z0-9:_-]|[.][a-z]|\$)"
    { grep -rqsE "$re" $CI .claude/skills .claude/commands .claude/agents || printf '%s\n' "$HOOKS" | grep -qE "$re"; } && hit=1; done
  [ "$hit" = 1 ] || { k=$((k+1)); echo "NO INVOKER: $b"; }
done
echo "guard invokers: $n scripts checked, $k without invoker"
```
**Expected: no `NO INVOKER` line; the last line gives the counts for the report slot.** Adjust the
`scripts/check-*` glob when the project keeps its guards elsewhere — and say so in the report. A mention in a rules file, a log or `pendencias.md` does NOT count — that is
prose, and prose is where orphaned guards live. Each `NO INVOKER` line is a finding.

> Evidence (production project): five check scripts that exit 1 lived only in prose. One watched the
> age of the only backup; the backup aged 13 of its 14 allowed days while the instrument that would
> have caught it was one command away and nothing ran it.

**ALWAYS triage the Known Bug Patterns in this SAME step** — this step is their INVOKER
(component-design §9). The verdicts are DEFINED in `code-reviewer.md` → `### Periodic review — the triage VERDICTS`, which
schedules nothing on its own. Read the KBP list with its `triggered:` / `false-positive:` counters
and give EVERY pattern older than 10 sessions an explicit verdict: **REMOVE** (`triggered: never`),
**REFINE** (frequent false-positive — too broad), **PROMOTE** (frequent triggered → DERIVED rule in
a rules file), or **KEEP**. A KBP list that only ever grows is dead weight the reviewer pays for on
every single diff.

### 7. Recurring-class scan

Read the `## Validation Post-Mortem Ledger` in `project.md`. Any root-cause class with
`Recurring? = YES` is a class with no systemic owner → propose a framework-level fix (or escalate
to `framework-audit`).

## Output

Produce the report, then write every actionable finding as a task in `pendencias.md` (findings
that die in prose are invisible). NEVER auto-fix.

ALWAYS tag each task this step writes `origin: discovered (sN, codebase-audit)` — continuous mode
admits discovered tasks only in a restricted, capped class (`autonomous-loop` → "Continuous mode" →
C3), and an untagged task is read as `owner`.

```
## Codebase Audit Report — Session N
### Completion status: COMPLETE | INCOMPLETE (steps N,M not run — reason)   ← ALWAYS first line
### Steps: 1 ✅ · 2 ✅ · 3 ✅ · 4 ✅ · 5 ✅ · 6 ✅ · 7 ✅   (⏭️ only with a structural reason in parentheses)
### Steps self-check: [1 match | RED — the metrics.md row's Status cell carries no `steps:` line, or a bare ⏭️]   (ALWAYS present)
### Breadth findings (by dimension):
| Dimension | Findings | Severity | → task added |
### Depth findings (specialists run): [list, or "none — no confirmed money/security findings"]
### Ops checklist: [PASS count / GAP list]   (production+)
### Reconciliation: [anomalies found, or "0 — clean"]; written back into N items   (production-financial)
### Metrics vs budgets: [breached budgets, or "all within caps"]
### Debt triage: [N KEEP / N CLOSE / N PROMOTE] — [K items without an age stamp]
### Deferred back-sweeps: [N SWEPT / N CLOSE / N KEEP, or "none queued"]   (ALWAYS present)
### Guard invokers: [N scripts checked, 0 without invoker | K without invoker — list]   (ALWAYS present)
### Process component sizes: [largest file — bytes; files above ~140k, or "none"]   (ALWAYS present)
### KBP triage: [N KEEP / N REMOVE / N REFINE / N PROMOTE]   (ALWAYS present)
### Recurring escape classes: [classes flagged, or "none"]
### Tasks added to pendencias.md: [N]
```

**ALWAYS emit the `Completion status` line, and make it match the `metrics.md` row's `Status`.**
An INCOMPLETE run ALWAYS queues its unexecuted steps as a REOPEN task in `pendencias.md`, tagged
`origin: discovered (sN, codebase-audit)` like every other task this skill writes — the
cadence will not re-propose the audit on its behalf, because an INCOMPLETE entry never satisfied
the clock in the first place.

## Safety

Investigation-only. Read-only against prod. Cost-disciplined: breadth is cheap and parallel;
depth is reserved for confirmed high-risk findings. Archives tasks; the owner prioritizes fixes.
