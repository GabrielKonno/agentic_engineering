---
name: project-md-updater
invocation: inline
effort: medium
description: >
  Updates project.md with a concise index row and PRD version at end of every session.
  Detailed records are in session logs. MUST run AFTER session-log-creator. Without
  this, the next session has no context of what happened.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol end-of-session item 2
---

# project.md Updater

## When to run
At the END of every session, AFTER session-log-creator (needs the log filename).

## Process

### 1. Write concise index row

Add a new row to the Progress Log table in project.md:

```markdown
| N | YYYY-MM-DD | [1-line specific summary] | `logs/[filename].md` |
```

### 2. Update PRD version

Update the `**PRD version:**` field in project.md Overview with the current PRD version.

### 3. Update Project Phases

Update phase status markers (⏳ → ✅) if a phase was completed this session.

### 4. MODEL SWITCH entries

If this is a model switch (not normal session end), write the full MODEL SWITCH block **below** the Progress Log table:

```markdown
<!-- MODEL SWITCH — active -->
### [date] — Session N (MODEL SWITCH — continuing in next session)
**What was done:** [work before switch]
**Model switch reason:** Task "[name]" classified as architecture/security
**Continue with:** Task [N] from pendencias — [task name]
**Settings changed:** [model and effort level details]
**PRD version:** vX.X.X
```

Do NOT add an index row yet. The continuation session adds the row when the task completes and removes the MODEL SWITCH block.

If sprint was interrupted: add `**Sprint interrupted:** Yes — remaining tasks: [list]`

### 5. Incomplete features

If a feature stopped mid-session, the index row summary should note it: "Auth module — partial, blocked by schema issue."

---

## Legacy migration (one-time)

If the Progress Log uses the old format (individual session blocks instead of an index table), convert it on first run: extract session data into table rows, keep old entries below as a `<!-- Legacy entries -->` block.
