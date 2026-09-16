---
name: validation-orchestrator
invocation: inline
effort: high
description: >
  Orchestrates the full implementation lifecycle: before implementing (criteria
  enforcement, complexity classification, plan proposal), during implementation
  (two-phase validation loop), and post-mortem diagnosis. Routes to inline
  validation (routine) or subagent chain (logic-heavy/architecture/security).
  MUST run for every task. Skipping this means the human finds the bugs instead
  of the framework.
created: framework-v2.1.0 (pre-validated)
derived_from: 'execution_protocol "Before implementing", "During implementation", "Validation Failure Post-Mortem" — section of docs/agentic_engineering_framework.md in the FRAMEWORK repo; lineage only, NOT shipped to projects, do not attempt to resolve a project path'
---

# Validation Orchestrator

## When to run

This skill covers the full implementation lifecycle for each task:
1. **Before implementing:** criteria enforcement, complexity classification, plan proposal
2. **During implementation:** two-phase validation loop (Phase A + Phase B)
3. **After validation failure:** post-mortem diagnosis (when human reports bug in ✅ task)

---

## Before Implementing

### 1. Enforce criteria quality

**ALWAYS SPAWN `.claude/agents/criteria-enforcer.md` as a subagent before implementing any task**,
passing `Task: [task name]`. It rewrites WEAK criteria to STRONG in an isolated context. This step
is the INVOKER — the only place that mandate lives (component-design §9); the agent's own
frontmatter is read when the registry is BUILT, never when a session must remember to call it.

**ALWAYS REPORT the outcome in the plan and the validation report — `criteria-enforcer: ran — [N
criteria strengthened]` or `skipped — [reason]`. NEVER emit nothing.** A silence is
indistinguishable from a forgetting.

### 2. Classify and route

**Complexity:** Routine (UI, simple CRUD, text) | Logic-heavy (business rules, calculations, state machines) | Architecture/Security (new module, cross-module, security). Recommend reasoning depth accordingly. For Architecture/Security tasks, ALWAYS initiate the model switch protocol: the escalation ladder is `.claude/rules/session-rules.md` §"Reasoning depth mechanisms (complementary)" step 3, `project-md-updater` §"MODEL SWITCH entries" writes the marker, and `sprint-proposer` §1b resumes from it.

**Threshold:** Small (single file) → implement directly. Medium (2-5 files) → propose plan, wait for approval. Large (new module, cross-module) → propose plan with risks, wait for approval.

**Sprint-approved mode:** Medium tasks proceed without approval. Large still need approval. See `sprint-proposer` skill.

**Autonomous Loop Mode (Level 5):** Phase A is executed by an implementer SUBAGENT for medium
tasks under a PLAN-FIRST contract (the plan is drafted INSIDE the implementer's isolated context,
never in the orchestrator's), and Phase B for routine tasks uses ONE merged review+validation
subagent instead of the two-judge chain. Logic-heavy and security routes are unchanged.

### 2a. Ownership of "Before Implementing" in loop mode

**ALWAYS this split:** steps 1-3 above stay with
the ORCHESTRATOR (criteria-enforcer BEFORE dispatch, classification, git checkpoint); ONLY the
implementation plan moves down to the implementer. An implementer that strengthens its own criteria
is grading its own exam, and the criteria are also the validator's yardstick. Full mechanics:
`autonomous-loop` skill.

### 3. Git checkpoint (medium and large)

**ALWAYS COMMIT the current state before writing code**, so the task has a clean rollback
boundary. In loop mode this step stays with the ORCHESTRATOR under the split stated once above at
`### 2a. Ownership of "Before Implementing" in loop mode` — this step is covered by it and does not
restate it (component-design §9: one home per mandate). Full loop-side mechanics:
`autonomous-loop` §`3a. Before dispatch — the ORCHESTRATOR owns "Before Implementing"`.

**ALWAYS REPORT — `checkpoint: committed [hash]` or `skipped — [reason: small task / tree already
clean at a commit]`. NEVER emit nothing.**

---

## Phase A — Implementation

**Build:** Run the project build command. Fix errors before proceeding.

**Tests:** Write tests for testable criteria (`QUERY:`/`VERIFY:` tags with business logic). Run and verify they pass. Skip for tasks with no testable logic (pure styling, config, scaffolding).

**ALWAYS read the runner's EXECUTED COUNT, not just its exit status** (session-rules → "Execution
proof"). Exit 0 with ZERO tests executed, or a summary you cannot parse, is a ❌ — never a ✅. A
suite that finishes implausibly fast is a skip until proven otherwise.

**Commit:** Commit implementation before validation. For routine tasks using inline validation, commit can be deferred until after Phase B.
**ALWAYS REPORT — `phase-A commit: [hash]` or `deferred — routine task, committing after Phase B`. NEVER emit nothing.** This is a DIFFERENT commit from the Step 3 git checkpoint, whose report line does not reach it (component-design §9 rule 3: a sanctioned skip must still be said).

---

## Phase B — Validation

### Route 1 — Inline (routine tasks)

Execute these steps in order. Do not skip steps — each one produces evidence for the validation report.

1. **Code review** — Self-review using `.claude/agents/code-reviewer.md` as a checklist: project patterns, domain rules, Known Bug Patterns, edge cases.
2. **Security check** — Check security-reviewer.md headers. If changes touch user input, auth, database, APIs, secrets, or HTML rendering: do the full security review. If they touch **client-bound data** (see Route 2): spawn the security-reviewer subagent — that trigger applies on every route.
3. **UI verification (if UI files modified)** — Use the project's browser automation MCP to verify visual changes. Navigate to the affected pages, take snapshots, and verify that VERIFY: criteria match what's rendered. Test at a mobile viewport (≤430px) in addition to desktop. Code review alone is NOT sufficient for UI verification — browser automation is mandatory. If browser automation is unavailable: mark UI as ❌ with reason, list VERIFY: criteria as MANUAL:.
4. **Criteria check** — Check all acceptance criteria by tag type (BUILD:/VERIFY:/QUERY:/REVIEW:).
5. **Regression** — Run full test suite or re-check last 2-3 tasks' criteria.
6. **Report** — Produce the validation report using the standard format.

### Route 2 — Subagent (logic-heavy + architecture/security)

**Always spawn:**
1. **code-reviewer subagent** — Input: git diff, rules files, Key Patterns, Architectural Decisions.
2. **validator subagent** — Input: git diff, acceptance criteria, Code Review Report, rules files.

**If security-relevant** (auth, RLS, payment, AI/LLM, multi-tenancy, file upload, secrets):
- Add **security-reviewer subagent** before validator.

**ALWAYS ALSO spawn security-reviewer when the diff touches CLIENT-BOUND DATA — on ANY route, even a
logic-heavy task with no auth change.** It is client-bound when ANY is true:
- the RETURN SHAPE of a server action, API route or RPC changed;
- the props a server component passes into a client component changed;
- a role-gated or privileged figure, field or UI element was added or changed;
- a surface renders personal data or credentials.

**ALWAYS REPORT — `security-reviewer: ran — [verdict]` or `security-reviewer: skipped — no client-bound data ([reason])`, in the Validation Report's `Security reviewer:` slot. NEVER emit nothing.**

> Evidence (production project): with the trigger limited to auth/payment keywords, the
> security-reviewer recorded **0 spawns in 20 sessions** — including two sessions whose work was
> exactly its declared scope (privileged financial figures sent to the client) and that ran as
> logic-heavy tasks.

**Then, for security-relevant or client-bound work:**
- If high-risk (auth/RLS/payment/AI): add **Red Team subagent**.
- After validation passes (if Red Team ran): run **Blue Team subagent**.

**Coverage gap handling — THREE components declare gaps, and they are read in TWO passes.**
The declaring components are `code-reviewer`, `security-reviewer` and **`validator`**
(component-design §1). The first two report BEFORE the validator; the validator reports AFTER it,
so a single pass structurally cannot reach the third.

**Pass 1 — ALWAYS, after receiving the code-reviewer and security-reviewer reports:**
1. READ the Coverage Gap Declaration section in each report (in code-reviewer's report format the
   same section is headed `### Coverage gaps declared:`). The section is ALWAYS present and
   reads `None` when empty — an ABSENT section is a defect in that agent, not a skip condition.
2. For each declared gap, SEARCH `.claude/agents/` descriptions for an agent whose
   description matches the gap's domain vocabulary.
3. Match found → SPAWN it and include its report as additional evidence for the
   validator. No match → RECORD the unaddressed gap in the validation report's
   "Items for human verification" section.

**Pass 2 — ALWAYS, after the VALIDATOR's report comes back, before processing its verdict:**
4. READ the Coverage Gap Declaration section of the **validator's own report** and repeat steps
   2-3 for every gap it declares. The validator declares the `visual regression gap` from INSIDE its own report; code-reviewer declares the same gap earlier on the same trigger, so pass 1 may already have closed it — pass 2 exists because the validator's declaration arrives after pass 1 has run.
5. A specialist spawned in pass 2 returns AFTER the validator, so its report cannot be evidence
   FOR the validator: attach it to the validation report as a post-hoc finding, and if it
   contradicts a ✅ the validator gave, treat that as a ❌ and re-enter the fix loop.

**ALWAYS REPORT — `coverage gaps: pass 1 [N declared, M spawned] | pass 2 [N declared, M spawned]`,
or `none declared` for either pass — IN THE VALIDATION REPORT's `Coverage Gap Declaration` section
AND in the session's own output. NEVER emit nothing.** (The line had no destination; a report
mandate without one is owed by nobody — `/audit` 2026-09-02 M-18.)
This instruction is generic — it names no specific agents and adds zero cost when
no coverage gaps are declared.

**If ❌ contradicts mechanical evidence:** spawn **arbitrator subagent**.

**Process report:** All ✅ → done. Any ❌ → fix, commit, re-spawn full subagent sequence from code-reviewer. Max 3 retries. After limit: STOP and escalate to human with diagnosis of what keeps failing and what was tried.

**UI tasks in Route 2:** The validator subagent handles UI verification via browser automation MCP. When spawning the validator, include in the prompt: (1) that UI files were modified, (2) which VERIFY: criteria require browser verification, and (3) the app URL or route where changes are visible. The validator will navigate, take snapshots, and verify elements match criteria.

---

## Review receipts — every reviewer verdict leaves a durable artifact

This section is the WRITER of the receipt discipline (session-rules → "Autonomous loop watchdog" →
RECEIPT) and the EXECUTOR of the pre-deploy gate (session-rules → "Deploy gates").

**Every time a reviewer subagent returns a verdict (code-reviewer, security-reviewer, validator, red
team, data or specialist reviewers), ALWAYS:**
1. **SAVE its final report verbatim** — `mkdir -p .claude/logs/review-reports` first — to
   `.claude/logs/review-reports/s<N>-<reviewer>-<k>.md` (session, reviewer, sequence), and commit it.
2. **APPEND one line to the receipts ledger `.claude/logs/review-reports/receipts.md`, IN THE SAME
   COMMIT as the saved report:**
   `- <reviewer> · <VERDICT> · report: .claude/logs/review-reports/s<N>-<reviewer>-<k>.md · commits: <sha7>, <sha7>`
   — `<VERDICT>` MUST appear verbatim inside the saved report. The ledger exists from the moment of
   the verdict; the session log is written only at session end, so a gate run mid-session could not
   read a receipt kept only there. `session-log-creator` copies this session's lines into the log.
3. **NEVER paste an internal agent id** into a log or report — the saved report IS the evidence.

**Pre-deploy gate (production+ profiles) — BEFORE applying a migration to production, and BEFORE
opening the deploy PR, ALWAYS run this over the range being shipped** (replace `src` with the
project's code roots from CLAUDE.md):
```bash
R=origin/main..HEAD; L=.claude/logs/review-reports/receipts.md
if ! C=$(git log --no-merges --format=%H "$R" -- src 2>&1); then
  echo "RED: range $R unreadable — nothing checked"          # no remote yet, bad ref: FAILS CLOSED
else n=0; k=0
  for c in $C; do n=$((n+1))
    git log -1 --format=%B "$c" | grep -qE '^Review-Exempt: .{10,}' && continue
    grep -E '^- [^·]+ · [^·]+ · ' "$L" 2>/dev/null | grep -q "${c:0:7}" || { k=$((k+1)); echo "NO RECEIPT: ${c:0:7}"; }
  done
  echo "review receipts: $n commits in range, $k without receipt"
fi
```
**Expected: exactly one line, `review receipts: N commits in range, 0 without receipt`.** The check
reads ONLY receipt lines of the ledger — never a log's commit list, where every commit's hash appears.
Any `NO RECEIPT` or `RED:` line blocks the deploy until a review runs, the range is readable, or the
owner exempts the commit. An exemption is written at commit time as a `Review-Exempt: <reason>`
trailer; for a commit that already exists, NEVER rewrite it — append
`- exempt · owner decision · <reason> · commits: <sha7>` to the ledger. A commit that
touches schema or migrations additionally needs a receipt from the adversarial or data reviewer when
the project has one.

**ALWAYS REPORT — `review receipts: N commits in range, 0 without receipt` or `review receipts: N commits in range, K without receipt — deploy blocked` or `review receipts: RED — range unreadable — deploy blocked`. NEVER emit nothing.**

## Subagent mechanics

**Context routing — ALWAYS include:**
- Agent's own .md file
- All `.claude/rules/*.md` files
- CLAUDE.md: Key Patterns, Architecture
- project.md: Architectural Decisions table ONLY
- IF security-relevant: security-reviewer.md + stack security skill
- IF UI task: Design System section + instruct subagent that UI files were modified and browser automation is required for VERIFY: criteria (subagent's CLAUDE.md lists available browser tools under MCP Servers)
- IF migration files in diff: instruct validator that migration verification is required (Step 6 — check rollback migration exists and runs without errors)

**NEVER include (anti-bias firewall):**
- project.md Progress Log
- `.claude/logs/*.md` (session history)
- Sprint proposals or implementation plans
- Files the implementing agent wrote as task explanation

Each subagent is a fresh Agent tool instance — isolated context.

**Ordering — ALWAYS:** spawn code-reviewer FIRST; spawn validator LAST of the JUDGING chain (a pass-2 specialist may run after it — see the coverage-gap passes; `/audit` M-21), passing it all prior reports.

---

## Validation report format

```
## Validation Report: [feature]
### What was implemented:
- [change 1]
### Tests written:
- [test file]: [N] tests covering [what]
### Verification results:
- Build:      ✅/❌
- Tests:      ✅/❌/⏭️  (N executed / N failed — ALWAYS the count, never just the verdict)
- Review:     ✅/❌
- Security:   ✅/❌/⏭️
- Security reviewer: ran — [verdict] | skipped — no client-bound data ([reason])
- Mutation Tests:   ✅/⏭️  (N mutants, N NEUTER)
- DB:         ✅/❌/⏭️
- UI:         ✅/❌/⏭️/BASELINE-CREATED  (BASELINE-CREATED is reachable only when the CODE-REVIEWER declared the gap, since a specialist spawned from THIS report's own declaration runs after this row is written)
- Migration:  ✅/❌/⏭️
- Regression: ✅/❌  (N executed)
- Validation: ✅/❌/⏭️
### Coverage Gap Declaration:
- [pass 1: N declared, M spawned | pass 2: N declared, M spawned | none declared]
- [each declared gap with no specialist report, flagged ⚠️ — NEVER ❌]
### Items for human verification:
- [MANUAL criteria]
### Next from pendencias.md:
- [next task]
```

⏭️ = not applicable to this task. Never use ⏭️ for UI if `.tsx/.jsx/.css/.html` or template files were modified, or for Tests if business logic + test framework exists, or for Migration if migration files are in the diff. ⏭️ is NOT "I skipped it." If browser automation couldn't run (tool unavailable, dev server down, flaky after 3 attempts): use ❌ with reason, list VERIFY: criteria as MANUAL:.

**ALWAYS carry the executed COUNT on Tests, Regression, and Mutation — a bare ✅ is not
evidence.** A run that exited 0 having executed ZERO units, or whose summary could not be parsed,
is ❌ with the reason, NEVER ✅ and NEVER ⏭️ (session-rules → "Execution proof": "I could not read
it" is not "it is healthy").

ALWAYS create a task in pendencias.md for every finding mentioned in the report — findings that die in prose are invisible.

ALWAYS tag each such task `origin: discovered (sN, task M)` — continuous mode admits discovered tasks only in a restricted, capped class (`autonomous-loop` → "Continuous mode" → C3), and an untagged task is read as `owner`.

---

## Validation Failure Post-Mortem

**Trigger:** Human reports a bug in a task validated as ✅.

BEFORE fixing, diagnose and improve the validation loop:

1. Identify which step should have caught it
2. Diagnose why it declared ✅
3. Classify root cause → route improvement (use the STABLE class name in brackets — the ledger depends on it):
   - `weak-criterion` → improve criteria rules
   - `partial-verification` → strengthen Phase B check
   - `tool-silenced-error` → add Known Bug Pattern
   - `review-missed-pattern` → update code-reviewer checklist
   - `test-not-written` → refine Phase A test guidance
   - `subagent-context-incomplete` → update context routing rules
   - `spec-authoring-bug` → strengthen criteria-enforcer AUTHORING checks (the spec itself mandated the bug)
   - `ai-judgment-limit` → inherent limitation, no doc fix
4. Apply systemic improvement (prevent the CLASS of failure, not the instance)
5. **Record in the Post-Mortem Ledger (internal-tool+ profiles).** ALWAYS append one row to the
   `## Validation Post-Mortem Ledger` table in `project.md` with: session, escape symptom, the step
   that should have caught it, the root-cause class from step 3, where the systemic fix was routed,
   and `Recurring?` — set to `YES (Nx)` if this root-cause class already appears in the ledger,
   else `no`. A `YES` means a one-off fix is NOT enough: flag it for the next codebase-audit /
   framework-audit as a class with a missing owner.
6. Log in session log and project.md.

For `prototype` profile: do steps 1-4 and 6 (skip the ledger row). Then fix the bug normally.
