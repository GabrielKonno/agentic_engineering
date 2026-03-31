---
name: pendencias-updater
invocation: inline
effort: medium
description: >
  Updates pendencias.md at end of every session. Moves completed tasks (with full
  metadata) to done_tasks.md, updates In Progress, adds new items with criteria.
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

Move tasks completed this session to `.claude/phases/done_tasks.md` with full metadata intact (Context, State, Constraints, Complexity, Acceptance criteria marked as `[x]`). Add completion header with session number and date.

Remove the task entirely from pendencias.md.

If `done_tasks.md` does not exist, create it with a header explaining it's an archive read on-demand.

### 2. Update In Progress

If a task was started but not finished: update its status with what was done and what remains.

### 3. Add new items

For every new task discovered during the session, add to "Next Steps" with:
- **Context** — why the task exists
- **State** — project state when this task starts
- **Constraints** — what NOT to do
- **Complexity** — routine / logic-heavy / architecture-security
- **Acceptance criteria** with tags (`BUILD:`, `VERIFY:`, `QUERY:`, `REVIEW:`, `MANUAL:`)

All criteria must be STRONG (action + expected result + failure signal).

### 4. Maintenance

- **Next Steps > 15 items:** flag to user for reprioritization
- If task hit retry limit: mark "⚠️ Blocked: [reason]"
- Update `Last updated:` date in both files

---

## Legacy migration (one-time)

If pendencias.md has a Done section with completed tasks (old format), move all to done_tasks.md on first run. After migration, Done section references done_tasks.md only.
