# Template: Session Rules

> Create at `.claude/rules/session-rules.md` during bootstrap (Step 5.7).
> This rule is loaded in every session — keep it concise.

````markdown
---
domain: session-management
applies_to: "**/*"
---

# Session Rules

## Risk profile & ceremony tiers

This project's risk profile is recorded in `.claude/phases/project.md` (Overview → **Risk profile:**)
and CLAUDE.md. The profile scales how much process ceremony applies — robustness on demand,
never imposed. Read the profile, then apply ONLY the ceremonies its column marks `✅`.

| Ceremony | prototype | internal-tool | production | production-financial |
|----------|:---------:|:-------------:|:----------:|:--------------------:|
| Per-diff review (Route 1/2), criteria-enforcer, KBP loop | ✅ | ✅ | ✅ | ✅ |
| Session archetypes, per-incident Post-Mortem | ✅ | ✅ | ✅ | ✅ |
| Class-checklist (conditional — zero cost when not triggered) | ✅ | ✅ | ✅ | ✅ |
| CI floor at t=0 | — | ✅ | ✅ | ✅ |
| metrics.md (light series) | — | ✅ | ✅ | ✅ |
| Back-sweep (rules apply backward) | — | ✅ | ✅ | ✅ |
| skill-gate (creation gate for new skills/rules) | — | ✅ | ✅ | ✅ |
| Debt-aging triage | — | ✅ | ✅ | ✅ |
| Post-Mortem ledger (recurring-class detection) | — | ✅ | ✅ | ✅ |
| codebase-audit (`AUDIT_CADENCE`) | — | sparse (~20) | ✅ (~12) | ✅ (~12) |
| ops-rules (lifecycle dimension) | — | — | ✅ | ✅ |
| quality-budgets + delta gate | — | — | ✅ | ✅ |
| Deploy gates (DEPLOY GUARD) | — | — | ✅ | ✅ |
| framework-audit (`FRAMEWORK_AUDIT_CADENCE`) | — | — | sparse (~35) | frequent (~25) |
| Data reconciliation + red-team mandatory on money-paths | — | — | — | ✅ |

> **Mechanism, not policing:** ceremonies are gated by FILE PRESENCE, not a runtime tier check.
> Bootstrap copies a skeleton (codebase-audit, ops-rules, quality-budgets…) ONLY when the tier
> warrants it, so an absent file = an inactive ceremony. To raise/lower a project's ceremony later,
> add or remove the corresponding skeleton — no protocol edit needed. The cadence numbers in
> parentheses are defaults; adjust per project.

## Session lifecycle

- Before implementation work, run `/sprint-proposer` (loads project state, syncs PRD, proposes sprint)
- To run an approved backlog SEGMENT end-to-end, or to keep draining the backlog under an approved admission POLICY (continuous mode) (Level 5, opt-in), run `/autonomous-loop` — ALWAYS after `/sprint-proposer`, which owns session entry for every mode
- Every session with implementation work MUST end with `/session-end`
- If context degrades mid-session, run `/context-recovery`

## Task limits

Maximum 3-5 tasks per session. Up to 7 if all small+related. 1 if large.

Exception: in **Autonomous Loop Mode** (Level 5, opt-in — see the `autonomous-loop` skill), the task
limit is superseded NOT by a context-percentage gate but by a **per-task persistence
discipline**: max ONE task in flight (uncommitted) at a time; each task CLOSED to disk —
code committed + LOOP CONTINUATION marker updated + discoveries filed + new decisions in
their owning doc — before the next opens. There is **NO numeric cap** on context %,
autocompacts, or subagent reports: a count is a stand-in for context usage, which the
model cannot observe (an instructed "estimate" produces confabulation dressed as
measurement). The session runs until the approved backlog SEGMENT is done or an
emergency-degradation signal fires; it ends only at a natural TASK boundary, never
mid-task. In **continuous mode** there is no segment to finish: the queue is governed by an
approved admission policy, and the run ends at a checkpoint (every 10 closed tasks or an audit
due), the discovery brake, a guardrail, or revocation — see `autonomous-loop` → "Continuous mode".
The mode never activates by itself: owner request or explicit acceptance of a
loop proposal only.

### Signals of exceeding

Contradicting earlier findings, skipping validation steps, producing ⏭️ on steps that should be ✅ or ❌.

> **In loop mode, the "Signals of exceeding" are the EMERGENCY stop (→ `/context-recovery`
> immediately), NOT a pacing knob.** Autocompacts are non-events: per-task persistence +
> re-anchoring from the DISK after each compact refreshes grounding from canonical docs (so
> successive compacts do NOT compound drift), and a subagent report is disposable — if a
> compact blurs it mid-task, re-derive the implementation from the working-tree diff and
> RE-RUN a read-only validation rather than trust the compressed memory (NEVER commit on a
> verdict a compact intervened on). A mid-work autocompact costs at most the single
> in-flight task.

## Autonomous loop watchdog — liveness vs judgment, and the receipt discipline

A watchdog is only worth anything if it is INDEPENDENT of what it watches. The loop
orchestrator (the main agent) shares context and biases with the work it produces → it is
NOT independent for JUDGMENT errors (a vacuous test, a weak check — the class fresh-context
reviewers exist to catch). But it IS the natural authority for LIVENESS (did the reviewer
actually RUN? does the component EXIST in the registry?). The rule separates the two and
never collapses them:

- **LIVENESS — the ORCHESTRATOR's duty (mechanical, not rationalizable):**
  1. At **loop start** and before any **money-path/security** task, run the component
     liveness guard (`node scripts/check-agent-frontmatter.mjs`, or `npm run check:agents`
     when registered). A component whose frontmatter fails to parse VANISHES from the
     registry silently (see component-design §8) — the class that can disable the very
     reviewers that enforce rigor.
  2. A review-agent spawn that returns **"Agent type not found"** is a **HARD STOP** —
     never a silent fallback to a general-purpose agent. If a substitute is genuinely
     needed (registry broken mid-session), it is DECLARED in the report, never disguised
     as the named reviewer's approval.
- **JUDGMENT — the duty of an INDEPENDENT SUBAGENT (fresh context):** whether the code is
  right, whether the test proves what it claims. The orchestrator CANNOT self-review this —
  it would inherit its own blind spot. Money-path and security work require the real
  subagent (code-reviewer / red-team / data reviewers), not the orchestrator's correlated
  second opinion.
- **RECEIPT — the bridge between the two:** a review verdict only COUNTS when accompanied
  by a verifiable artifact from a real subagent. A "reviewer APPROVE" written from the
  orchestrator's own MEMORY is not evidence that a review happened and cannot enter the
  log/commit. No receipt → the review didn't happen → the task does not close.
  - **ALWAYS SAVE the reviewer's FINAL report verbatim** to
    `.claude/logs/review-reports/s<N>-<reviewer>-<k>.md` and commit it; the writer is
    `validation-orchestrator` → "Review receipts". A spawn's agent id is NOT a receipt: nobody can
    re-read it after the session, and internal agent ids do not belong in visible artifacts.
  - **ALWAYS CITE each saved report by one line in the receipts ledger
    `.claude/logs/review-reports/receipts.md`, in the same commit** — `session-log-creator` copies
    this session's lines into the log's `## Review receipts`.

> Evidence (production project, 20-session window): the receipt rule existed and **0 of 20 logs**
> carried a receipt anyone could re-read — the "APPROVE" lines were prose. Two sessions shipped code
> with no independent reviewer, and one applied migrations to production before the adversarial
> reviewer ran; that reviewer then found three exploitable holes and forced a corrective migration.
> The rule only stopped a session from CLAIMING a review; it never stopped SHIPPING without one.

## Execution proof — "passed" and "ran" are different propositions

Every automated verification answers "did it PASS?". Almost none answers **"did it RUN?"** — and
the second is the one that fails in silence, because the ABSENCE of execution produces exactly
the same green as a successful execution. It applies to test suites, linters, type-checks,
migration runners, and any CI job with a skip path. This is the tooling sibling of the RECEIPT
discipline above: a receipt proves a REVIEWER ran; a count proves a TOOL ran.

- **ALWAYS report a verification with its executed COUNT, and give the count a FLOOR.** "Tests
  pass" is not evidence; "247 tests across 39 files executed, 0 failed" is.
- **A guard on that count ALWAYS fails CLOSED in three states** — the third is the load-bearing one:
  1. the tool exited != 0 → propagate (it already failed loudly);
  2. the tool exited 0 having executed **ZERO** units → RED, never green;
  3. the tool exited 0 and its summary is **UNREADABLE** → RED. *"I could not READ it" is NEVER
     "it is healthy"* — degrading unparseable output to "0 problems" is the very class the guard
     exists to catch.
- **NEVER treat a skip as a pass.** A CI stage that skips on missing secrets/config reports the
  same green as one that ran; make the skip itself RED unless the owner declared it.
- **ALWAYS TREAT DURATION as evidence:** a full suite that finishes implausibly fast is a skip
  until proven otherwise — say the wall time out loud alongside the count.
- **When the guard is SCRIPTED, ALWAYS PUT the verdict in a PURE function in its own module** —
  NEVER inside the wrapper that spawns the process. A verdict trapped in a `spawn` can only be "proven"
  by reading its source, which is exactly the weak proxy this class teaches you to distrust. A
  pure decision is unit- and mutation-testable, and the mutant that matters is the **NEUTER**
  (keep the condition, kill its effect), not the DELETE.
- **NEVER pipe a gate through a filter** (`| tail`, `| head`, `| grep`) when its exit status is the
  verdict — the shell reports the FILTER's status, so a red gate prints its last lines and returns 0.
  ALWAYS run the gate bare, or with `set -o pipefail`, and report its exit code.
- **ALWAYS spawn a gate script's subprocesses WITHOUT a shell** (`execFileSync(bin, [args])`, never
  `execSync("bin args")`). On Windows a shell routes through `cmd.exe`, where `^` is an escape
  character: a range `a^..b` reached git as `a..b` and the first commit of every range went
  unchecked, silently — a gate that loses input errs in the PERMISSIVE direction.

> Evidence (production project, two incidents): a CI test job fell into a missing-secrets skip
> path and reported `pass` in 39 seconds for 200+ test files; and a stray residue left by a
> concurrent write caused a `ReferenceError` at IMPORT time, so the suite reported SUCCESS having
> executed ZERO tests. In both, the only clue was the DURATION and a human noticed it — never the
> status, because no mechanism was asking. The two "NEVER pipe / NEVER use a shell" lines come from
> one session building five gate scripts: a `| tail` let a commit ship on a red gate, and the
> `cmd.exe` case surfaced only because a POSITIVE test came back with ZERO commits checked.

## Task presentation

When proposing sprints or listing tasks, ALWAYS include for each task:
- **Model:** current (default), or model switch required (architecture/security)
- **Effort:** current settings (routine), extended thinking (logic-heavy), or high + model switch (architecture/security)
- **Justification:** one-line reason for the recommendation

Derive from each task's `Complexity:` field. If no complexity field exists, classify before presenting.

## Reasoning depth mechanisms (complementary)

1. **Agent-level (automatic):** `effort:` in agent/skill frontmatter. Security agents always `effort: high`.
2. **Task-level (2 seconds):** AI MUST recommend effort level in plan and sprint proposal. Human adjusts if needed.
3. **Session-level model switch (5 seconds):** AI saves state with MODEL SWITCH marker → requests restart. The procedure lives in two installed components: `project-md-updater` §"MODEL SWITCH entries" WRITES the marker block into `.claude/phases/project.md`, and `sprint-proposer` §1b DETECTS it on restart and resumes from it.
4. **Component-level model (declarative):** `model:` in AGENT frontmatter. Mechanisms 1-3 only ESCALATE; this is the only one that DESCENDS. See "Model by risk class" below.

Mechanisms stack: a standard-effort session uses high effort when security agents run (mechanism 1), can switch to high effort for a financial task (mechanism 2), and can switch to a more capable model for an architecture task (mechanism 3) — while mechanism 4 holds each spawned agent at the model its own risk class warrants, independently of the other three.

## Model by risk class — the DESCENDING direction (mechanism 4)

Mechanisms 1-3 answer "when is the current model NOT ENOUGH?" and have no answer for "when is it
MORE than enough?". An agent with no `model:` inherits the orchestrator's model, so in an autonomous
loop — where the orchestrator runs the most capable model available — EVERY agent of EVERY risk
class runs that model, including the ones that only extract or compare.

**ALWAYS set `model:` in the frontmatter of every agent (`invocation: subagent`), decided by the
component's RISK CLASS, written ONCE, and never adjusted per session:**

| What the component's contract produces | `model:` | Why |
|---|---|---|
| A VERDICT that gates a commit — reviewers, validator, arbitrator, red/blue team, criteria-enforcer, skill-reviewer | `inherit` | The verdict IS the rigor, and rigor is not a cost lever. |
| An EXTRACTION or a COMPARISON carrying no verdict — pattern extractors, sync checkers | `sonnet` | The output is a list, not a judgement. |
| The BREADTH pass of a fan-out — audit dimensions, parallel sweeps | `sonnet` | Cheap breadth, reserved depth: the depth specialists it escalates to keep `inherit`. |

**ALWAYS WRITE `model: inherit` EXPLICITLY — never omit the field to mean it.** An absent field and
a decided one are indistinguishable by grep, and the whole value of this mechanism is that
`grep -rn "^model:" .claude/agents/` answers which model reviewed which commit.

**NEVER WRITE `model:` INTO A SKILL.** Skills are `invocation: user` or `invocation: inline` — they
load into the current context and never spawn, so nothing reads the field. That is the `last_eval:`
class: a field with no executor.

**NEVER DOWNGRADE a component's model because a run of tasks validated clean.** The model is fixed
by the component's risk class, never by the streak — the same rule the validation geometry carries.

**NEVER PIN a dated model ID.** Any generation alias is permitted (`opus`, `sonnet`, `haiku`,
`fable`) plus `inherit`. The table above gives the DEFAULT per risk class, not the whole set — a
project whose orchestrator runs below the top tier may legitimately RAISE a money-path reviewer,
which is mechanism 4 used in the escalating direction. A pinned dated ID is a version claim that
decays silently.

> kept as HYPOTHESES — that a cheaper model performs equivalently on a component whose contract is
> extraction or comparison is an EMPIRICAL claim, and no run has measured it. Signal: a validation
> post-mortem whose root-cause class is `review-missed-pattern` or `weak-criterion` on a task whose
> chain included a non-`inherit` agent — it lives in the Post-Mortem Ledger in `project.md`.
> **unmeasured — no measurer below `production`, AND none above it either:** `framework-audit` Q4
> is the HYPOTHESIS check, but its counting command reads ONE hardcoded signal out of
> `## Orchestration lessons` in the session logs, so it enumerates this component and can produce
> no count for it. Naming Q4 as the measurer without saying this would be the `last_eval:` class —
> a field whose executor does not reach it. Q4 measures this rule only once its count becomes
> per-component and can read the Post-Mortem Ledger.

## Documentation quality

- Be specific: "Fixed month reopening to restore paid entries too" NOT "Fixed a bug"
- Include WHY: "Added parseDateOnly() because toISOString() shifts dates across timezones"
- Constraints go in rules files, not just session logs

## Owner decision → normative document in the SAME commit

A decision the owner takes in a session is usually recorded where it was taken — a rules file, a
log, `pendencias.md`. When it changes a business rule, a phase's scope, or invalidates a statement
in the PRD (or a phase spec that is normative for its phase), recording it there is not enough: the
PRD keeps describing a system that no longer exists, while its version stays unchanged — so a sync
check that compares VERSIONS cannot see the drift.

- **ALWAYS propagate that decision to the normative document in the SAME commit** that records it,
  with an entry in the PRD's Changelog and a PRD version bump.
- **The recording file POINTS at the PRD section — NEVER becomes the only home of the decision.**
- **Self-check at session end** — executed and reported by `session-log-creator` (its invoker): when
  `git diff <session-range> -- .claude/rules .claude/phases` adds a line containing `owner decision`
  (case-insensitive), `git diff <session-range> --stat -- assets/docs` MUST be non-empty — or the log
  states `owner decision with no normative effect — [reason]`.
- The PRD sync check (`prd-sync-checker`) stays the backstop; this rule is the control.

> Evidence (production project): the same drift — owner decisions recorded in rules files and
> logs, never reaching the normative spec — recurred in **5 sessions** after it was first measured.
> Every instance was FOUND by the PRD sync checker afterwards; none was PREVENTED. The version check
> passed each time, because the versions still matched.

## Session archetypes (all profiles)

Not every session is an implementation session. Declare the archetype at the start; it tells
`session-end` what to extract and what to legitimately skip (a skipped step here is "N/A",
NOT degraded rigor).

| Archetype | What it is | session-end adaptation |
|-----------|-----------|------------------------|
| `implementation` (default) | Building/fixing code | Full flow: diff-pattern-extractor first, then all updaters |
| `investigation` | Research/analysis, no code shipped | SKIP diff-pattern-extractor; DO write session log + project.md index; findings → tasks in pendencias, tagged `origin: discovered` |
| `framework-maintenance` | Editing this project's own agents/skills/rules/docs | SKIP app-code pattern extraction; instead log each component change with FIX/DERIVED/CAPTURED; re-check activation chains / counts |
| `ops` | Runtime, deploy, infra, incident | SKIP app-pattern extraction; update ops-rules + metrics.md; log incident + reconciliation outcome |

If a session mixes archetypes, run the union of their session-end steps.

## Debt-aging (internal-tool+ profiles)

Backlog items under "Future Improvements" in `pendencias.md` MUST carry a session stamp
`[added sN]`. The periodic codebase-audit triages items older than `DEBT_AGE` (default ~30
sessions) with an explicit verdict per item: **KEEP** (still valid, re-stamp), **CLOSE**
(obsolete/done), or **PROMOTE** (turn into an active task now). This prevents "documented in
the backlog" from silently becoming "resolved forever."

## Cadence integrity — a periodic mechanism anchors on CONCLUSION, never on DATE

Every periodic mechanism (codebase-audit, framework-audit, retro, health-check) has TWO
artifacts: the one that RECORDS what was done and the one that SATISFIES the clock. When they
are the same entry and the run was PARTIAL, half a job resets the whole clock — and the failure
mode is cruelly asymmetric: the EXPENSIVE half (broad judgment, fan-out, context) dies first,
while the CHEAP half (counters, greps, queries) survives and writes the reassuring line.

- **Writer — ALWAYS declare completion.** Every cadence entry (metrics row, Progress Log row,
  audit report) MUST carry `status: COMPLETE` or
  `status: INCOMPLETE (steps N,M not executed — reason)`. Recording a partial run stays CORRECT
  and desirable: the data it produced is valid. What it may NOT do is reset the clock.
- **Reader — ALWAYS anchor on the last `COMPLETE`.** Count cadence from the most recent
  `COMPLETE` entry, SKIPPING partial ones. An `INCOMPLETE` entry NEVER satisfies the cadence.
- **Anti-thrash corollary — ALWAYS separate the two claims.** An interrupted audit is not wasted
  work: *the data it produced* stays valid (keep reading it); only *the claim of completeness* is
  false (never trust it). NEVER discard a partial run's findings on the grounds that it was partial.
- **`COMPLETE` is a PER-STEP checklist, never an adjective.** ALWAYS write the steps line beside the
  status — `steps: 1 ✅ · 2 ✅ · 3 ⏭️ (reason) · 4 ✅`. `COMPLETE` is allowed only when EVERY step is
  ✅, or ⏭️ with a STRUCTURAL reason written in the line (the step cannot be executed as it stands —
  e.g. a debt triage over backlog items that carry no age stamp). A step skipped for CAPACITY
  (context, time, a usage limit, "later") makes the entry `INCOMPLETE`.
  **Self-check (execute and report):** `grep -oiE 'steps:' ` over the entry (a report heading or a table
  row's Status cell) → exactly 1 match, and no `⏭️` without a `(` after it.
- **ALWAYS write an `IN PROGRESS` marker to disk BEFORE fanning out** — a usage-limit cut must leave
  the run visible as `INCOMPLETE`, never as "never opened". The marker NEVER resets the clock.

> Evidence (production project): a MACRO audit lost 10 of its 11 fan-out agents to a usage
> limit. The session logged `interrupted` honestly — but the entry the cadence reader consults
> said "cadence FULFILLED". Three sessions later the reader correctly concluded "not due" from a
> lying anchor. The breadth half of the audit (separation · security · performance · types)
> stayed frozen ~16 sessions while the cheap half kept publishing reassuring numbers.
> Later the same project recorded two audits `COMPLETE` — one with its triage step only MEASURED,
> one with "partial triage" — so the adjective absorbed both without telling a structural skip from
> a capacity one; that is what the per-step line fixes.

## Deploy gates (production+ profiles)

A multi-session feature that ships all-or-nothing MUST be gated behind owner-defined exit
criteria, recorded as a `DEPLOY GUARD` block in `pendencias.md` (see the pendencias template).
Hard rule: do NOT open the deploy PR (e.g., `dev → main`) until the guard's criteria are met.
When met, convert the block to `✅ FULFILLED (sN)` with the PR hash — preserve the original as
history. This is a distinct gate tier ABOVE the per-diff CI gate and the per-task validation gate.

**The review-receipt gate — BEFORE applying a migration to production and BEFORE opening the deploy
PR, ALWAYS verify that every code commit in the range carries a review receipt.** The executor is
`validation-orchestrator` → "Review receipts". A commit with no receipt blocks the deploy unless the
owner exempted it explicitly — a `Review-Exempt: <reason>` trailer written at commit time, or, for a
commit that already exists, an `exempt · owner decision` line in the receipts ledger. An implicit
exemption does not exist.
A project MAY script this check and run it in CI on the deploy PR; the rule does not depend on it.

## Scripts convention

Skills with `scripts/` subdirectories have optional bash helpers. Use them if available; execute equivalent steps manually otherwise. Scripts require bash (Git Bash on Windows, native on macOS/Linux).
````
