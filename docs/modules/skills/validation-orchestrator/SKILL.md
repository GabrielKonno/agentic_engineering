---
name: validation-orchestrator
invocation: inline
effort: high
description: >
  Orchestrates the full implementation lifecycle: before implementing (criteria
  enforcement, complexity classification, plan proposal), during implementation
  (two-phase validation loop), and post-mortem diagnosis. Routes to inline
  validation (routine), 2-subagent pair (logic-heavy), or full chain
  (architecture/security). MUST run for every task. Skipping this means the
  human finds the bugs instead of the framework.
created: framework-v1.7.0 (pre-validated)
derived_from: execution_protocol "Before implementing", "During implementation", "Validation Failure Post-Mortem"
---

# Validation Orchestrator

## When to run

This skill covers the full implementation lifecycle for each task:
1. **Before implementing:** criteria enforcement, complexity classification, plan proposal
2. **During implementation:** two-phase validation loop (Phase A + Phase B)
3. **After validation failure:** post-mortem diagnosis (when human reports bug in ✅ task)

Run this skill when a task is selected for implementation.

---

## Before Implementing

### 1. Enforce criteria quality

Invoke `.claude/agents/criteria-enforcer.md` as subagent, passing `Task: [task name]`. This rewrites WEAK criteria to STRONG and runs adversarial review. Runs in isolated context.

### 2. Classify task complexity

Based on task content, classify and recommend:
- **Routine** (UI changes, simple CRUD, text updates) → current model + effort is fine
- **Logic-heavy** (business rules, calculations, state machines, financial) → recommend `/effort high`
- **Architecture/Security** (new module, cross-module, security audit) → trigger model switch protocol (see `session-start` skill)

### 3. Complexity threshold

- **Small** (single file, bug fix, text update): implement directly → validation loop. No plan needed.
- **Medium** (2-5 files, new component, schema change): propose plan → wait for approval.
- **Large** (new module, cross-module, architectural): propose plan with risks → wait for approval.

**Sprint-approved mode:** Medium tasks proceed without approval. Large tasks still need approval. See `sprint-proposer` skill.

### 4. Plan template (medium and large tasks)

If medium or large, propose:
```
## Implementation Plan: [feature name]
### Changes needed:
1. [file] — [what changes and why]
### Migration needed: [yes/no]
### Risks: [what could break]
### Validation strategy: [which criteria, which tools]
### Estimated scope: [small / medium / large]
```

Wait for user approval. After approval: the plan becomes the technical record. Include summary in the session log.

### Git checkpoint (medium and large tasks)

Before writing code: `git add -A && git commit -m "checkpoint: before [task name]"`
This enables clean rollback if the task needs to be reverted.

---

## Phase A — Implementation (all complexity levels)

**Step 1 — Build check:**
Run the project build command. If errors: fix and rebuild. Do NOT proceed with build errors.

**Step 2 — Write tests** (if task involves business logic, integrations, or state changes):
Translate `QUERY:` and `VERIFY:` criteria into executable tests. Run tests — they must pass.
Skip for: simple CRUD with no logic, scaffolding, UI styling, configuration.

If test framework is not yet configured AND task involves business logic:
1. Install and configure the test framework (see stack skill)
2. Write ONE test for the simplest QUERY: criterion
3. Run it — confirm the framework works
4. Proceed with implementation. Log: "Test framework configured: [name]"

**Step 3 — Commit implementation:**
```bash
git add -A && git commit -m "feat: [task name] — pending validation"
```
For routine tasks using inline validation (Route A): commit can be deferred until after Phase B.

## Phase B — Validation (graduated by complexity)

### Route A — Routine tasks (inline validation)

**Step 4 — Self-review:** Read `.claude/agents/code-reviewer.md` as a checklist:
- Project patterns, domain rules, Known Bug Patterns, Architecture Patterns
- **Security** — ALWAYS read security-reviewer.md section headers. If changes touch user input, auth, database, APIs, AI/LLM, secrets, or HTML rendering: read FULL checklist.
- Edge cases: empty? null? zero? negative?

**Step 5 — UI verification** (web projects, if UI was modified):
Health check first: `curl -s -o /dev/null -w "%{http_code}" http://localhost:[PORT]`
If running: navigate → action → verify → screenshot. Max 3 attempts.
If not running and UI was modified: ❌ with reason.

**Step 6 — Check acceptance criteria** by tag type. Passing tests count as verification.
Then run **regression:** full test suite or re-execute QUERY: criteria from last 2-3 tasks.

**Step 7 — Report** (see report format below).

### Route B — Logic-heavy tasks (2 subagents)

**Step 4 — Spawn code-reviewer subagent:**
Input: git diff, rules files, Key Patterns, Architecture Patterns, Architectural Decisions table.
Output: Code Review Report.

**Step 5 — Spawn validator subagent:**
Input: git diff, acceptance criteria, Code Review Report, rules files, Architectural Decisions table.
Output: Validation Report with ✅/❌/⏭️ per category.

**Step 6 — Process report:**
- All ✅ → proceed to report
- Any ❌ AND mechanical evidence contradicts → spawn arbitrator
- Any ❌ AND evidence agrees → fix → commit → re-spawn from Step 4. Max 3 retries.

**Step 7 — Report.**

### Route C — Architecture/security tasks (full chain)

**Step 4 — code-reviewer subagent** (same as Route B)
**Step 5 — security-reviewer subagent:** Input: git diff, security-reviewer.md, stack skill, rules.
**Step 6 — Red Team** (if triggered by auth/RLS/payment/AI/multi-tenancy/file-upload changes)
**Step 7 — validator subagent** (receives all prior reports)
**Step 8 — Process report** (same as Route B Step 6)
**Step 9 — Blue Team** (after validation passes, if Red Team ran)
**Step 10 — Report.**

## Subagent mechanics

Construct subagent prompt with: role definition, files to read (explicit paths), evidence to evaluate, prior reports, report format, BOUNDARIES.

**Context routing — ALWAYS include:**
- Agent's own .md file
- All `.claude/rules/*.md` files
- CLAUDE.md: Key Patterns, Architecture
- project.md: Architectural Decisions table ONLY

**IF security-relevant:**
- `.claude/agents/security-reviewer.md`
- Stack security skill in `.claude/skills/*/SKILL.md` (if exists)

**IF UI task:**
- Design System section of CLAUDE.md

**NEVER include (anti-bias firewall):**
- project.md Progress Log
- `.claude/logs/*.md` (session history)
- Sprint proposals or implementation plans
- Any file the implementing agent wrote as part of the task explanation

**Sequencing (Route B):** code-reviewer → validator
**Sequencing (Route C):** code-reviewer → security-reviewer → Red Team → validator → arbitrator (if needed) → Blue Team

**Retry flow:** Fix → commit "fix: [task] — validation fix N" → re-spawn from step 1. Max 3 cycles. After limit: STOP and escalate to human:
```
## Validation Escalation: [task name]
### Retry cycles exhausted: 3/3
### Persistent failures:
- [category]: [what keeps failing and why]
### What was tried:
- Fix 1: [description] → [result]
- Fix 2: [description] → [result]
- Fix 3: [description] → [result]
### Diagnosis: [root cause hypothesis]
### Recommendation: [what the human should decide]
```

## Validation report format

```
## Validation Report: [feature]
### What was implemented:
- [change 1]
### Tests written:
- [test file]: [N] tests covering [what]
### Verification results:
- Build:      ✅/❌
- Tests:      ✅/❌/⏭️
- Review:     ✅/❌
- Security:   ✅/❌/⏭️
- Mutation:   ✅/⏭️
- DB:         ✅/❌/⏭️
- UI:         ✅/❌/⏭️
- Regression: ✅/❌
- Validation: ✅/❌/⏭️
### Items for human verification:
- [MANUAL criteria]
### Next from pendencias.md:
- [next task]
```

## ⏭️ rules
- UI modified → MUST be ✅ or ❌, never ⏭️
- Business logic with test framework → Tests MUST be ✅ or ❌
- QUERY: criteria with DB tool → DB MUST be ✅ or ❌
- ⏭️ means "not applicable" — NOT "I couldn't do it"

## Actionable findings rule
If during ANY step of the validation loop the AI identifies a bug, a better approach, a missing edge case, or an improvement opportunity that is NOT fixed in the current task — it MUST create a task in pendencias.md with full Context/State/Constraints/Complexity/Criteria. Findings that die in report prose are invisible. If it's worth mentioning, it's worth tracking.

---

## Validation Failure Post-Mortem

**Trigger:** The human reports a bug in a task that was validated as ✅.

BEFORE fixing the bug, diagnose and improve the validation loop:

1. **Identify** which validation step should have caught it
2. **Diagnose** why that step declared ✅ (partial execution? silent failure? missing criterion? weak criterion?)
3. **Classify** the root cause and route the improvement to the correct document:
   - Weak/incomplete criterion → improve criteria quality rules
   - Partially verified multi-step criterion → strengthen Phase B criteria check
   - Tool silenced an error → add Known Bug Pattern
   - Review missed a pattern → update code-reviewer checklist
   - Test not written for testable logic → refine Phase A Step 2 skip conditions
   - Subagent context incomplete → update context routing rules
   - AI judgment error → inherent limitation, no doc fix
4. **Apply** the systemic improvement (prevent the CLASS of failure, not just this instance)
5. **Log** the post-mortem in the session log (`.claude/logs/`) and note it in the project.md Progress Log index row

Then fix the bug normally. The validation loop improves before the bug is fixed.
