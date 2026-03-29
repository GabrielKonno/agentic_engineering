---
name: pendencias-updater
invocation: inline
effort: medium
description: >
  Updates pendencias.md at end of every session. Moves completed tasks (with full metadata)
  to done_tasks.md, updates In Progress, adds new items with full Context/State/Constraints/Criteria.
  MUST run at end of every session (item 3). Without this, the backlog drifts from
  reality and the next session starts with wrong priorities.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol end-of-session item 3
---

# pendencias.md Updater

## When to run
At the END of every session, after session-log-creator and project-md-updater.
Also runs between tasks during a sprint (to move completed tasks immediately).

## Process

### 1. Move completed tasks to done_tasks.md
Move tasks completed this session from "In Progress" or "Next Steps" to `.claude/phases/done_tasks.md`.

**Move the FULL task block** — all metadata intact (Context, State, Constraints, Complexity, Changes, Acceptance criteria). Mark all criteria as checked (`[x]`). Add a completion header:

```markdown
---

### Task N: [Name]
Completed: Session X ([date])

[full task body with all metadata, criteria marked as [x]]
```

**Remove the task entirely from pendencias.md** — it should not remain in the Done section.

If `done_tasks.md` does not exist, create it:
```markdown
# [Project] — Completed Tasks

> Archive of completed tasks with full metadata. Not read at session start.
> Read on-demand by sprint-proposer (dependency checks) or when investigating history.

Last updated: [date]
```

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

### 5. Maintenance
- **Next Steps > 15 items:** flag to user for reprioritization
- If task hit retry limit: mark "⚠️ Blocked: [reason]"
- Update `Last updated:` date in both pendencias.md and done_tasks.md

### 6. Backward compatibility
If the existing Done section in pendencias.md contains completed tasks (legacy format from before
this change), move ALL of them to done_tasks.md on the first run. This is a one-time migration.
After migration, the Done section should reference done_tasks.md only.
