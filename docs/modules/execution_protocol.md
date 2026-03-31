# Execution Protocol

This module defines the before-implementing, during-implementation (validation loop), between-tasks, and validation orchestration protocols. This is the architectural reference — WHAT happens and WHY.

In v1.7.0, all protocol logic is implemented in skills:
- `validation-orchestrator` skill: before-implementing (criteria enforcement, complexity classification, plan proposal), during-implementation (Phase A + Phase B with 2 validation routes: inline for routine, subagent for logic-heavy/architecture/security), and validation failure post-mortem
- `sprint-proposer` skill: between-tasks workflow (commit, update pendencias, context health check, sprint report)
- `criteria-enforcer` agent: criteria quality enforcement (subagent, called by validation-orchestrator)

CLAUDE.md contains pointers only. The content below is the architectural reference describing the design and rationale.

---

## Before implementing any feature

**This is where technical specification happens.** There is no separate spec document. The PRD defines WHAT. This step translates into HOW. The approved plan is recorded in the session log, referenced in the project.md index.

**For ALL tasks (before determining complexity):**

**Enforce criteria quality** → invoke `.claude/agents/criteria-enforcer.md` as subagent, passing `Task: [task name]`
<!-- Rewrites WEAK criteria to STRONG, runs adversarial review — runs in isolated context, returns upgrade summary -->

**Classify task complexity for model/effort:**
Based on task content, classify and recommend:
- **Routine** (UI changes, simple CRUD, text updates) → current model + effort is fine. No recommendation needed.
- **Logic-heavy** (business rules, calculations, state machines, financial operations) → recommend increased reasoning depth. Log: "Recommend: increase reasoning depth — [reason]"
- **Architecture/Security** (new module design, cross-module changes, security audit, debugging cross-module bugs) → triggers model switch (see model switch protocol below). Log: "Recommend: model switch to most capable model — [reason]"

For routine and logic-heavy: include recommendation in plan, human adjusts reasoning settings if needed (no restart).
For architecture/security: trigger the model switch protocol.

**Complexity threshold:**
- **Small** (single file, bug fix, text update): implement directly → validation loop. No plan needed.
- **Medium** (2-5 files, new component, schema change): propose plan → wait for approval.
- **Large** (new module, cross-module, architectural): propose plan with risks → wait for approval.

**Sprint-approved mode (Level 4):** If the human approved a sprint batch:
- **Small tasks:** implement directly (same as Level 3).
- **Medium tasks:** generate the plan, log it, and proceed WITHOUT waiting for approval.
- **Large tasks:** still require individual plan approval, even within a sprint.
- **Discoveries during implementation:** add new task to pendencias.md with full Context/State/Constraints/Complexity/Criteria. Continue sprint unless the discovery blocks the current task. **Cap: max 3 discoveries per sprint.** After 3, flag to human at next exception stop or sprint report.

**Exception stops (sprint-approved mode pauses only for these):**
- ❌ after 3 retry cycles
- PRD ambiguity or contradiction with existing decision
- MANUAL: criteria (flag in report, continue with next task)
- Context degradation (trigger mid-session recovery)
- Current task blocked by a discovery requiring human input
- False ❌ from subagent escalated by arbitrator (genuinely ambiguous — human decides)

If medium or large (Level 3, or large tasks within sprint):
1. Read relevant `.claude/rules/*.md`
2. Codebase discovery on affected files
3. Propose plan:
   ```
   ## Implementation Plan: [feature name]
   ### Changes needed:
   1. [file] — [what changes and why]
   ### Migration needed: [yes/no]
   ### Risks: [what could break]
   ### Validation strategy: [which criteria, which tools]
   ### Estimated scope: [small / medium / large]
   ```
4. Wait for user approval
   - "go" → implement → validation loop
   - "adjust X" → revise → wait again

After approval: the plan becomes the technical record. Include summary in the session log.

**Model switch protocol (if task classified as Architecture/Security AND current model is not the most capable):**
1. Save state: run session-log-creator, project-md-updater and pendencias-updater skills. The project-md-updater writes a MODEL SWITCH block below the Progress Log table in project.md (not as a table row):
   ```
   <!-- MODEL SWITCH — active -->
   ### [date] — Session N (MODEL SWITCH — continuing in next session)
   **What was done:** [work before switch]
   **Model switch reason:** Task "[name]" classified as architecture/security — requires most capable model + high effort
   **Continue with:** Task [N] from pendencias — [task name]
   **Settings changed:** [model and effort level details]
   **PRD version:** vX.X.X
   ```
2. Commit: `git add -A && git commit -m "wip: model switch for [task name]"`
   **If model switch is triggered during a sprint:** The sprint is interrupted. Add to the MODEL SWITCH marker: `**Sprint interrupted:** Yes — remaining tasks: [list remaining sprint tasks]`. After restart, do NOT resume the previous sprint — propose a new sprint instead. Log the previous sprint as "interrupted: model switch at task N of M".
3. Update model/effort configuration as appropriate for the tool
4. Tell user to restart the session
5. **After task complete:** evaluate next task. If routine → revert to standard settings. Log revert in project.md. If next task also needs the current model: keep settings, skip revert.

### Git checkpoint (medium and large tasks):
Before writing code: `git add -A && git commit -m "checkpoint: before [task name]"`
This enables clean rollback if the task needs to be reverted.

---

## During implementation (validation loop)

**Run validation** → run `.claude/skills/validation-orchestrator/SKILL.md`
<!-- Orchestrates Phase A (implementation) and Phase B (graduated validation by complexity) -->

The validation-orchestrator skill contains the full validation loop detail. Below is the structural overview:

After writing code and BEFORE reporting to the user, execute two phases. The implementing agent handles Phase A. Phase B is graduated by task complexity — routine tasks use inline validation, logic-heavy and architecture/security tasks use independent subagents.

### Graduated validation depth (2 routes)

```
Route 1 — Inline (routine tasks: UI text, config, styling, simple CRUD)
  → Phase B uses inline checklist. No subagent.
  → Bias risk near-zero. Token cost: ~5-10k.

Route 2 — Subagent (logic-heavy + architecture/security)
  → Always: code-reviewer + validator subagents
  → If security-relevant: add security-reviewer (+ Red Team/Blue Team for high-risk)
  → Token cost: ~50-150k depending on security depth.
```

### Validation report format (all routes)

```
## Validation Report: [feature]
### What was implemented:
- [change 1]
### Tests written:
- [test file]: [N] tests covering [what]
### Verification results:
- Build:      ✅/❌ [details]
- Tests:      ✅/❌/⏭️ [N passed, N failed, or skipped if no testable logic]
- Review:     ✅/❌ [inline or "code-reviewer subagent"]
- Security:   ✅/❌/⏭️ [inline / security-reviewer subagent / Red Team results / "no security-relevant changes"]
- Mutation:   ✅/⏭️ [N mutations tested, N criteria confirmed — or "routine task, skipped"]
- DB:         ✅/❌/⏭️ [query results or covered by tests]
- UI:         ✅/❌/⏭️ [screenshot evidence or "no UI changes in this task"]
- Regression: ✅/❌ [test suite results or re-checked tasks]
- Validation: ✅/❌/⏭️ [validator subagent result — or "routine task, inline"]
### Items for human verification:
- [MANUAL criteria]
### Improvements identified → added to pendencias:
- [improvement/better approach found during validation — task created in pendencias.md]
- [or "none"]
### Next from pendencias.md:
- [next task]
```

**⏭️ is NOT valid when:**
- UI: if ANY `.tsx`, `.jsx`, `.html`, `.css`, or template file was modified in this task, UI MUST be ✅ or ❌, never ⏭️. If browser automation couldn't run (tool unavailable, dev server down, flaky after 3 retries): mark as ❌ with reason, list VERIFY: criteria as MANUAL:.
- Tests: if task has QUERY: or VERIFY: criteria with business logic AND test framework is configured, Tests MUST be ✅ or ❌, never ⏭️.
- DB: if task has QUERY: criteria AND database tool is available, DB MUST be ✅ or ❌, never ⏭️.

⏭️ means "not applicable to this task" — NOT "I couldn't do it" or "I skipped it."

**Actionable findings rule:** If during ANY step of the validation loop the AI identifies a bug, a better approach, a missing edge case, or an improvement opportunity that is NOT fixed in the current task — it MUST create a task in pendencias.md with full Context/State/Constraints/Complexity/Criteria. Findings that die in report prose are invisible. If it's worth mentioning, it's worth tracking.

If any ❌ after max retry cycles: STOP and escalate to human with diagnosis.

---

## Validation Orchestration (subagent mechanics)

When spawning validation subagents (Routes B and C), construct the Task tool prompt following this template:

```
1. Role definition — "You are the [agent name]. Your role is [purpose]."
2. Files to read — explicit paths from the context routing rules below
3. Evidence to evaluate — "Read the git diff via `git diff HEAD~1`" + acceptance criteria (copied into prompt)
4. Prior reports (if any) — "Read [report path] for findings from previous reviewers"
5. Report format — the exact structure the subagent must produce
6. BOUNDARIES — "Do NOT read: [NEVER list]. Do NOT access implementation plans, session logs, or progress entries."
```

The implementing agent does NOT package file contents into the prompt. It provides paths and the subagent reads them directly.

**Context routing rules:**
```
ALWAYS instruct the subagent to read:
  - The agent's own .md file (code-reviewer reads code-reviewer.md, etc.)
  - .claude/rules/*.md (ALL rules files — cost is low, risk of omission is high)
  - CLAUDE.md sections: Key Patterns, Architecture
  - project.md: Architectural Decisions table ONLY

IF security-relevant:
  - .claude/agents/security-reviewer.md
  - Stack security skill in .claude/skills/*/SKILL.md (if exists)

IF UI task:
  - Design System section of CLAUDE.md
  - Instruct subagent that UI files were modified and browser automation is required for VERIFY: criteria

NEVER instruct the subagent to read (anti-bias firewall):
  - project.md Progress Log (contains implementation reasoning)
  - .claude/logs/*.md (session history)
  - Sprint proposals or implementation plans
  - Any file the implementing agent wrote as part of the task explanation
```

**Sequencing (Route 2 — subagent):**
```
Always:
  1. code-reviewer subagent → Code Review Report
  2. validator subagent (receives Code Review Report) → Validation Report

If security-relevant, insert between 1 and 2:
  - security-reviewer subagent → Security Review Report
  - Red Team subagent (if auth/RLS/payment/AI) → Vulnerability Report

After validation passes (if Red Team ran):
  - Blue Team subagent → Defense Assessment

If ❌ contradicts mechanical evidence:
  - arbitrator subagent
```

Each subagent is a fresh Task tool instance — isolated context, no carryover between invocations.

**Retry flow:** When validator returns ❌: fix → commit `"fix: [task] — validation fix N"` → re-spawn from step 1 of subagent sequence. Max 3 retry cycles. After limit: STOP and escalate to human with diagnosis.

**Large task mitigation:** For large tasks (diff exceeds ~300 lines or criteria exceed 10), split validation into sequential subagent calls: (1) code review + criteria evaluation, (2) mutation testing. Each call gets a fresh context.

**Validation Failure Post-Mortem (when human finds a bug in a ✅ task):**
If the human reports a bug in a task that was validated as ✅, BEFORE fixing:
1. Identify which validation step should have caught it
2. Diagnose why that step declared ✅ (partial execution? silent failure? missing criterion? weak criterion?)
3. Classify the root cause and route the improvement to the correct document:
   - Weak/incomplete criterion → improve criteria quality rules
   - Partially verified multi-step criterion → strengthen Phase B criteria check
   - Tool silenced an error → add Known Bug Pattern
   - Review missed a pattern → update code-reviewer checklist
   - Test not written for testable logic → refine Phase A Step 2 skip conditions
   - **Subagent context incomplete** → update context routing rules
   - AI judgment error → inherent limitation, no doc fix
4. Apply the systemic improvement (prevent the CLASS of failure, not just this instance)
5. Log the post-mortem in the session log (`.claude/logs/`) and note it in the project.md Progress Log index row
Then fix the bug normally. The validation loop improves before the bug is fixed.

---

## Between tasks (after validation passes, before picking next task):

1. Commit (if not already committed): for routine tasks with inline validation, `git add -A && git commit -m "feat: [task name] — validated"`. For subagent-validated tasks, the `feat:` commit was made before Phase B — it already stands.
2. Update pendencias.md: move completed task to `done_tasks.md` (full metadata), confirm next task in pendencias.md
3. If this is task 3+ in the current session: evaluate context health. If degrading → trigger mid-session recovery instead of continuing.
4. **Sprint-approved mode:** If executing a sprint, pick next task from the batch and proceed directly to "Before implementing". Do NOT re-propose the sprint or ask for confirmation. If all sprint tasks are done, produce a consolidated sprint report:
   ```
   ## Sprint Report: Session N
   ### Tasks completed: [N/N]
   | Task | Result | Issues |
   |------|--------|--------|
   | [name] | ✅/❌ | [MANUAL: items or notes] |
   ### Discoveries added to backlog: [N new tasks]
   ### Known Bug Patterns added: [N]
   ### Rules files created/updated: [list]
   ### Next sprint suggestion: [top 3-5 tasks]
   ```
