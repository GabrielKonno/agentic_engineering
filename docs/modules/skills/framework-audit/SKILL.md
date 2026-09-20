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
derived_from: "the meta-loop axis — this skill audits the PROCESS (are the rules being followed, do the controls still fire), where codebase-audit audits the SYSTEM. Framework-layer lineage records stay in the framework repo and are NOT copied to projects, so this field names the CONCEPT, never a path a project cannot open (/audit 2026-09-03 P-23)."
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
   **ALWAYS run the ORPHAN-MANDATE check as part of Q4** (component-design §9): for every
   component whose own text claims it "must run" at some point in the cycle, grep the component
   that OWNS that moment for an instruction to invoke it. A mandate that lives ONLY in the
   invoked component's frontmatter/inventory has no invoker and its real spawn count is
   typically ZERO — report the count, not the claim. Same for the self-checks themselves: a
   check that has never gone red is unproven, not passing.
   **ALWAYS run the DID-IT-LAND check as part of Q4:** for every improvement this audit APPROVED
   in an earlier session, do not ask "is the required text present?" — read the structure AROUND
   it. Classify each as **CONFIRMED** / **PARTIALLY-APPLIED** / **APPLIED-BUT-CLASS-NOT-SWEPT** /
   **INTRODUCED-A-DEFECT**, with file:line evidence per verdict. A fix that landed under the wrong
   heading, contradicts its neighbour, or orphaned the block below it passes every presence check
   and is still broken. **ALWAYS REPORT the tally — `did-it-land: N confirmed, M defective` or
   `did-it-land: N/A — no prior approvals`. NEVER emit nothing.**
   **ALWAYS run the HYPOTHESIS check as part of Q4.** A shipped component may keep a rule "as
   HYPOTHESES" — installed on one observation because it is cheap — and NAME the signal that would
   measure it. This check is that measurer; without it the rule reads as settled contract and nobody
   counts anything (`/audit` 2026-09-15 B-11).
   **ALWAYS ENUMERATE the rules, then COUNT each one's named signal in the session logs since the last
   framework-audit:**
   ```bash
   # N (the components to measure) and M (every component that STATES the rule) differ in ONE respect:
   # N keeps only `> ` lines before joining. Both JOIN, so the wrapped shape counts in both (`/audit`
   # 2026-09-16 A-3), and both EXCLUDE the two files that DEFINE the mechanism — this skill and the
   # component-design rule — whose own text otherwise matches and made M permanently exceed N
   # (this check's pre-commit verifier, 2026-09-20).
   hyp() { for f in $(grep -rlE 'HYPOTHES' .claude/skills .claude/rules); do
     case "$f" in */framework-audit/*|*component?design*) continue ;; esac
     if [ "$1" = quoted ]; then grep -E '^> ' "$f"; else cat "$f"; fi \
       | tr -d '\r' | tr '\n' ' ' | grep -qE 'kept as[ >]*HYPOTHES' && echo "$f"; done; }
   hyp quoted            # N — the components this check can measure; each gets a count below
   hyp any | wc -l       # M — components stating the rule at all; expected: equal to N's count
   FM=.claude/phases/framework-metrics.md
   if [ ! -f "$FM" ]; then echo "RED: $FM missing — no window"; else
     SINCE=$(grep -E '^\| *[0-9]+ *\| *[0-9]{4}-[0-9]{2}-[0-9]{2} *\| *COMPLETE' "$FM" | tail -1 | awk -F'|' '{gsub(/[- ]/,"",$3); print $3}')
     echo "window: logs dated on or after ${SINCE:-the first log (no COMPLETE row yet)}"
     for f in .claude/logs/*.md; do d=$(basename "$f" | cut -c1-8); [ "$d" \< "${SINCE:-0}" ] || sed -n '/^## Orchestration lessons/,/^## /p' "$f"; done \
       | grep -iE '^- (mutator/reader overlap|scratchpad collision):' | grep -viE ':[[:space:]]*none([[:space:][:punct:]]|$)' | wc -l   # autonomous-loop's signal
   fi
   ```
   **Expected: the first command lists every component carrying such a rule, and each gets a count.
   Zero is `not exercised` — NEVER `effective`.** The window starts at the date of the last
   `COMPLETE` row in `framework-metrics.md` (an INCOMPLETE row does not close a window — session-rules →
   "Cadence integrity") and is matched against the `YYYYMMDD_` prefix of each log's filename. A log
   dated the audit day counts in both windows; say so when one does.
   **NEVER use file modification times** — a fresh clone reset them and read `0` over two logged
   occurrences, and a missing metrics file read `0` instead of failing (this check's pre-commit
   verifier, 2026-09-16).
   **ANCHOR the listing on the blockquote (`^> `) and COUNT TYPED LINES, never bare words:** the unanchored
   listing matched this very fence and its own report string, so `N/A` was unreachable; a bare
   `mutator|scratchpad` count read a negated "none — no scratchpad collision" as one occurrence and
   missed a real one phrased without either word (this check's pre-commit verifier, 2026-09-16).
   **ALWAYS REPORT BOTH COUNTS — `hypotheses: N components of M carrying the rule — [component: exercised K | not exercised]` or `hypotheses: N/A — no rule kept as HYPOTHESES (M=0)`. NEVER emit nothing.**
   **`N < M` is RED: a component states the rule outside a `> ` blockquote, and the listing cannot see it.**
   Without the denominator a missed component emits the AUTHORIZED `N/A` string and reads as health
   (`/audit` 2026-09-20 AA-1). **A rule kept as HYPOTHESES ALWAYS lives inside a `> ` blockquote** — that is
   what makes it discoverable; `component_design.md` carries the authoring half.
5. **Meta-metrics review** — read `framework-metrics.md`: is the escape rate rising? Any reviewer
   with high false-positive (cry-wolf)? Any Known Bug Pattern that never triggers (dead weight)?
   If skill-gate is installed, also: any promoted skill never loaded since promotion (cross-check
   `.claude/skill-gate/promotion.log` against session logs — dead weight)? Any `verified: false`
   claim older than ~20 sessions with no verification attempt (stale hypothesis being consumed
   as if pending forever)? Any in-place update that added an empirical claim WITHOUT the flag
   (evolution-policy compliance)?
6. **Back-sweep of process rules** — did a recently promoted PROCESS rule condemn OLDER framework
   artifacts? Apply it backward to the project's own components.

## Meta-metrics rollup (harvested, not a daemon)

As part of this run, append one row to `.claude/phases/framework-metrics.md` (a sibling of the
code `metrics.md`, created at bootstrap from `docs/modules/templates/framework_metrics_md.md` —
that template defines the row schema, including the `Status` column), harvested from artifacts
that already exist:

| Metric | Source (already exists) | Healthy |
|--------|-------------------------|---------|
| Escape rate (escapes ÷ tasks shipped, this window) | Post-Mortem Ledger rows | low and ↓ |
| False-positive per reviewer | KBP `false-positive:` counters | low |
| KBP liveness (which trigger vs never) | KBP `triggered:` counters | no pattern dead 20+ sessions |
| Mechanism utilization (routes/specialists/gates fired) | validation reports / Progress Log | none never-spawned |
| Drift incidents caught | prd-sync-checker reports | ↓ |
| Debt aging (count of LOW, oldest age) | Future Improvements stamps | not growing unbounded |

This is a STEP of framework-audit, not a continuous system. One row per meta-audit.

**ALWAYS write an `IN PROGRESS` row to `framework-metrics.md` BEFORE fanning out the six questions**,
and replace its status when the run ends — a usage-limit cut must leave the audit visible as
INCOMPLETE, never as "never opened". An `IN PROGRESS` row NEVER resets the cadence clock
(session-rules → "Cadence integrity").

**ALWAYS stamp the row with `Status: COMPLETE | INCOMPLETE (questions N,M not answered — reason)`,
derived from which of the six questions actually ran** — never from the fact that the rollup step
itself succeeded. The six questions are the expensive half (fan-out over logs, ledgers, components);
this rollup is the cheap half that survives an interrupt. An INCOMPLETE row records valid data but
does NOT satisfy `FRAMEWORK_AUDIT_CADENCE` (session-rules → "Cadence integrity").
**ALWAYS write the per-question line beside the status, in the row's Status cell AND under the report's
`### Completion status` heading** — `steps: 1 ✅ · 2 ✅ · 3 ✅ · 4 ✅ · 5 ✅ · 6 ⏭️ (structural reason)`. The
rule requires it of every periodic mechanism, and this skill wrote none, so every entry failed the rule's
own self-check by construction (`/audit` 2026-09-16 A-7).
**ALWAYS RUN session-rules → "Cadence integrity"'s self-check over the row, and REPORT it as
`steps self-check: [1 match | RED]`** — the rule's self-check had no executing step (`/audit` 2026-09-16 A-19).
It selects the LAST DATA ROW, never the file's last line — the template's table is followed by prose:
```bash
FM=.claude/phases/framework-metrics.md; ROW=$(grep -E '^\| *[0-9]+ *\|' "$FM" | tail -1)
printf '%s\n' "$ROW" | awk -F'|' '{print $4}' | grep -oiE 'steps:' | wc -l             # expected: 1
printf '%s\n' "$ROW" | awk -F'|' '{print $4}' | grep -cE '⏭️ *([^( ]|$)'                # expected: 0
```

## Output & safety

Produce a batch of FRAMEWORK improvements (BEHAVIOR class). This loop PROPOSES; it does not
auto-modify protocol. Per `evolution-policy.md`, a BEHAVIOR-class batch requires **explicit
owner approval before implementing** — the human gate is mandatory here. Read-only / dry-run
friendly until approved.

**Framework-evolution docs (ALWAYS, both directions — see evolution-policy →
"Framework-evolution docs — the upstream lifecycle"):**
- **Produce:** every approved improvement batch is recorded (or an existing doc updated) as
  `.claude/docs/framework-evolution-YYYY-MM-DD-<slug>.md`, including the PORTABLE formulation —
  it is the upstream vehicle to the mother framework repo AND the anchor the NEXT audit
  evaluates.
- **Consume:** at the start of the run, READ every framework-evolution doc not yet
  `efficacy-evaluated` whose evolution installed a mechanism — Q4 MUST evaluate whether that
  mechanism actually RAN and WORKED since (this is the step that closes the recursive loop
  and advances the doc's lifecycle stage).

```
## Framework Audit Report — Session N
### Completion status: COMPLETE | INCOMPLETE (questions N,M not answered — reason)   ← ALWAYS first line
steps: 1 ✅ · 2 ✅ · 3 ✅ · 4 ✅ · 5 ✅ · 6 ✅   ← ⏭️ only with a structural reason in parentheses
steps self-check: [1 match | RED]
### Q1 Dimension coverage: [orphaned dimensions, or "all owned"]
### Q2 Axis coverage: [missing axes/bridges, or "complete"]
### Q3 Recurring escape classes: [classes with no owner, or "none"]
### Q4 Aspirational-vs-real: [claimed-but-not-running mechanisms, or "none"] + did-it-land: [N confirmed, M defective | N/A] + hypotheses: [N components of M carrying the rule — exercised K | not exercised, or N/A (M=0)]
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
