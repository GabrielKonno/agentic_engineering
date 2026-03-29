---
name: pendencias-updater
invocation: inline
effort: medium
description: >
  Updates pendencias.md at end of every session. Moves completed tasks to Done,
  updates In Progress, adds new items with full Context/State/Constraints/Criteria.
  MUST run at end of every session (item 3). Without this, the backlog drifts from
  reality and the next session starts with wrong priorities.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol end-of-session item 2
---

# pendencias.md Updater

## When to run
At the END of every session, after project-md-updater.

## Process

### 1. Move completed tasks
Move tasks completed this session from "In Progress" or "Next Steps" to "Done" section.

### 2. Update In Progress
If a task was started but not finished: update its status with what was done and what remains.

### 3. Add new items
For every new task discovered during the session, add to "Next Steps" with:

**Required fields:**
- **Context** — why the task exists (business problem, discovery, bug)
- **State** — what the project state will be when this task starts (which modules done, which data exists)
- **Constraints** — what NOT to do (anti-patterns, things that seem right but aren't)
- **Complexity** — routine / logic-heavy / architecture-security
- **Acceptance criteria** with tags (`BUILD:`, `VERIFY:`, `QUERY:`, `REVIEW:`, `MANUAL:`)

**Criteria quality enforcement:**
- All criteria must be at STRONG level (3 parts: action + expected result + failure signal)
- If a criterion is WEAK: rewrite before saving

### 4. Adversarial Review before saving
For each new criterion, ask:
1. "How could a wrong implementation still pass this?" — if easy, strengthen
2. "Am I checking a snapshot or a transformation?" — if snapshot, add before/after
3. "What if 0 items, 1 item, negative?" — add edge cases
4. For VERIFY: criteria, "could this pass with hardcoded data?" — add complementary QUERY:

### 5. Archive management
- **Done section > 30 items:** archive older items to "Done (archived)" at bottom
- **Next Steps > 15 items:** flag to user for reprioritization
- If task hit retry limit: mark "⚠️ Blocked: [reason]"
