---
name: validation-orchestrator
invocation: inline
effort: high
description: >
  Orchestrates the two-phase validation loop after implementation. Routes to
  inline validation (routine), 2-subagent pair (logic-heavy), or full chain
  (architecture/security). MUST run after every implementation. Skipping this
  means the human finds the bugs instead of the framework.
created: framework-v1.6.0 (pre-validated)
derived_from: execution_protocol "During implementation"
---

# Validation Orchestrator

## When to run
After writing code for any task, BEFORE reporting to the user.

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
- All rules files
- CLAUDE.md: Key Patterns, Architecture
- project.md: Architectural Decisions table ONLY

**NEVER include (anti-bias firewall):**
- project.md Progress Log
- Session logs
- Sprint proposals or implementation plans

**Sequencing (Route B):** code-reviewer → validator
**Sequencing (Route C):** code-reviewer → security-reviewer → Red Team → validator → arbitrator (if needed) → Blue Team

**Retry flow:** Fix → commit "fix: [task] — validation fix N" → re-spawn from step 1. Max 3 cycles.

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
