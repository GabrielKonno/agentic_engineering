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
created: framework-v1.7.0 (pre-validated)
derived_from: execution_protocol "Before implementing", "During implementation", "Validation Failure Post-Mortem"
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

Invoke `.claude/agents/criteria-enforcer.md` as subagent, passing `Task: [task name]`. Rewrites WEAK criteria to STRONG. Isolated context.

### 2. Classify and route

**Complexity:** Routine (UI, simple CRUD, text) | Logic-heavy (business rules, calculations, state machines) | Architecture/Security (new module, cross-module, security). Recommend reasoning depth accordingly. Architecture/Security triggers model switch protocol (see `session-start` skill).

**Threshold:** Small (single file) → implement directly. Medium (2-5 files) → propose plan, wait for approval. Large (new module, cross-module) → propose plan with risks, wait for approval.

**Sprint-approved mode:** Medium tasks proceed without approval. Large still need approval. See `sprint-proposer` skill.

### 3. Git checkpoint (medium and large)

Commit current state before writing code to enable clean rollback.

---

## Phase A — Implementation

**Build:** Run the project build command. Fix errors before proceeding.

**Tests:** Write tests for testable criteria (`QUERY:`/`VERIFY:` tags with business logic). Run and verify they pass. Skip for tasks with no testable logic (pure styling, config, scaffolding).

**Commit:** Commit implementation before validation. For routine tasks using inline validation, commit can be deferred until after Phase B.

---

## Phase B — Validation

### Route 1 — Inline (routine tasks)

Self-review using `.claude/agents/code-reviewer.md` as a checklist: project patterns, domain rules, Known Bug Patterns, edge cases. Always check security-reviewer.md headers — if changes touch user input, auth, database, APIs, secrets, or HTML rendering, do the full security review.

If UI was modified: use browser automation tools to verify changes visually — code review alone is NOT sufficient for UI verification. Health check dev server first. If dev server unavailable: ❌. If browser automation tools unavailable: ❌ with reason, list VERIFY: criteria as MANUAL:.

Check all acceptance criteria by tag type. Run regression (full test suite or re-check last 2-3 tasks' criteria). Produce report.

### Route 2 — Subagent (logic-heavy + architecture/security)

**Always spawn:**
1. **code-reviewer subagent** — Input: git diff, rules files, Key Patterns, Architectural Decisions.
2. **validator subagent** — Input: git diff, acceptance criteria, Code Review Report, rules files.

**If security-relevant** (auth, RLS, payment, AI/LLM, multi-tenancy, file upload, secrets):
- Add **security-reviewer subagent** before validator.
- If high-risk (auth/RLS/payment/AI): add **Red Team subagent**.
- After validation passes (if Red Team ran): run **Blue Team subagent**.

**If ❌ contradicts mechanical evidence:** spawn **arbitrator subagent**.

**Process report:** All ✅ → done. Any ❌ → fix, commit, re-spawn full subagent sequence from code-reviewer. Max 3 retries. After limit: STOP and escalate to human with diagnosis of what keeps failing and what was tried.

**UI tasks in Route 2:** The validator subagent handles UI verification via browser automation. Ensure the subagent prompt includes that UI files were modified and which VERIFY: criteria require browser verification.

---

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

Each subagent is a fresh Agent tool instance — isolated context. Code-reviewer runs first, validator runs last, receiving all prior reports.

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
- Tests:      ✅/❌/⏭️
- Review:     ✅/❌
- Security:   ✅/❌/⏭️
- Mutation:   ✅/⏭️
- DB:         ✅/❌/⏭️
- UI:         ✅/❌/⏭️
- Migration:  ✅/❌/⏭️
- Regression: ✅/❌
- Validation: ✅/❌/⏭️
### Items for human verification:
- [MANUAL criteria]
### Next from pendencias.md:
- [next task]
```

⏭️ = not applicable to this task. Never use ⏭️ for UI if `.tsx/.jsx/.css/.html` or template files were modified, or for Tests if business logic + test framework exists, or for Migration if migration files are in the diff. ⏭️ is NOT "I skipped it." If browser automation couldn't run (tool unavailable, dev server down, flaky after 3 attempts): use ❌ with reason, list VERIFY: criteria as MANUAL:.

If any finding is worth mentioning in the report, create a task in pendencias.md for it. Findings that die in prose are invisible.

---

## Validation Failure Post-Mortem

**Trigger:** Human reports a bug in a task validated as ✅.

BEFORE fixing, diagnose and improve the validation loop:

1. Identify which step should have caught it
2. Diagnose why it declared ✅
3. Classify root cause → route improvement:
   - Weak criterion → improve criteria rules
   - Partially verified criterion → strengthen Phase B check
   - Tool silenced error → add Known Bug Pattern
   - Review missed pattern → update code-reviewer checklist
   - Test not written → refine Phase A test guidance
   - Subagent context incomplete → update context routing rules
   - AI judgment error → inherent limitation, no doc fix
4. Apply systemic improvement (prevent the class of failure)
5. Log in session log and project.md

Then fix the bug normally.
