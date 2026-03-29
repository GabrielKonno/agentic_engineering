---
name: project-md-updater
invocation: inline
effort: medium
description: >
  Updates project.md with a session entry at end of every session. Includes decisions,
  bugs, PRD version, next step. MUST run at end of every session (item 2).
  Without this, the next session has no context of what happened.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol end-of-session item 1
---

# project.md Updater

## When to run
At the END of every session, after diff-pattern-extractor.

## Process

### 1. Gather session data
- What tasks were completed (from pendencias.md changes)
- Architectural decisions made (and why)
- Bugs found and fixed
- PRD version at end of session
- What the next session should start with

### 2. Write session entry
Add a new entry to the Progress Log section:

```markdown
### [date] — Session N

**What was done:**
- [task]: [approach, key decisions]

**Decisions made:**
- [decision]: [reasoning]

**Bugs found:**
- [bug]: [root cause, fix applied]

**PRD version:** vX.X.X

**Next step:** [specific action from pendencias.md]
```

### 3. If feature incomplete
Document what was attempted and why it's incomplete. Include enough context for the next session to continue.

### 4. Run session-entry.sh (optional)
If `scripts/session-entry.sh` exists, run it to pre-fill git stats:
```bash
bash .claude/skills/project-md-updater/scripts/session-entry.sh
```
