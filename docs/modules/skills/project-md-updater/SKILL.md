---
name: project-md-updater
invocation: inline
effort: medium
description: >
  Updates project.md with a concise index row and PRD version at end of every session.
  Detailed session records are written by session-log-creator. MUST run at end of
  every session (item 2), AFTER session-log-creator. Without this, the next session
  has no context of what happened.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol end-of-session item 2
---

# project.md Updater

## When to run
At the END of every session, AFTER session-log-creator (needs the log filename to reference).

## Process

### 1. Gather session data
- What tasks were completed (from pendencias.md changes)
- Session number
- Date
- Log filename (from session-log-creator — the most recent file in `.claude/logs/`)

### 2. Write concise index row
Add a new row to the Progress Log table in project.md:

```markdown
| N | YYYY-MM-DD | [1-line summary: tasks done + key outcome] | `logs/[filename].md` |
```

The 1-line summary should be specific: "Financial module CRUD + auth middleware" not "Worked on features."

### 3. Update PRD version
Update the `**PRD version:**` field in the project.md Overview section with the current PRD version.

### 4. Update Project Phases
Update phase status markers (⏳ → ✅) if a phase was completed this session.
This section is the primary progress tracker and must stay accurate.

### 5. MODEL SWITCH entries
If this is a model switch (not a normal session end), write the full MODEL SWITCH block
**below** the Progress Log table (not as a table row):

```markdown
<!-- MODEL SWITCH — active -->
### [date] — Session N (MODEL SWITCH — continuing in next session)
**What was done:** [work before switch]
**Model switch reason:** Task "[name]" classified as architecture/security
**Continue with:** Task [N] from pendencias — [task name]
**Settings changed:** [model and effort level details]
**PRD version:** vX.X.X
```

Do NOT add an index row yet. The index row is added when the continuation session resolves the switch.
When the continuation session starts and completes the task, REMOVE the MODEL SWITCH block and add a normal index row.

### 6. If feature incomplete
Ensure the session log (written by session-log-creator) captures what was attempted and why
it stopped. The index row summary should note the incompleteness: "Auth module — partial,
RLS policy blocked by schema issue."

### 7. Backward compatibility
If the Progress Log is in the old format (individual session entry blocks with "What was done",
"Decisions made", "Bugs found", etc., instead of an index table), convert it during the first
session-end update:
1. Extract session number, date, and 1-line summary from each block
2. Create the index table with these entries (use `—` for the Log column since no log files exist for old sessions)
3. Keep the old entries below the table as a clearly marked legacy block:
   ```markdown
   <!-- Legacy entries (pre-index format) — preserved for reference, will not be updated -->
   ```
This is a one-time migration.

### 8. Run session-entry.sh (optional)
If `scripts/session-entry.sh` exists, run it to get git stats for the session log:
```bash
bash .claude/skills/project-md-updater/scripts/session-entry.sh
```
(Scripts require bash — Git Bash on Windows, native on macOS/Linux. If unavailable, the AI executes the equivalent steps manually.)
