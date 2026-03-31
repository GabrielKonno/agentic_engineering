---
name: context-recovery
invocation: user
effort: medium
description: >
  Emergency mid-session recovery when context is degrading. Saves state via
  3 end-of-session sub-skills, commits WIP, and requests a new session.
  Trigger: contradicting earlier decisions, repeating mistakes, losing track.
created: framework-v1.7.0 (pre-validated)
derived_from: session_protocol "Mid-session context recovery"
---

# Context Recovery

## When to run

When context quality is degrading mid-session (contradicting decisions, forgetting patterns, inconsistent results). The user can also trigger this by saying "save state and start fresh".

## Process

### 1. STOP implementation

Immediately stop. Do not attempt to finish the current task — partial work with degraded context produces more bugs than stopping.

### 2. Save state (3 sub-skills)

Run these directly (not via `/session-end`):
- `.claude/skills/session-log-creator/SKILL.md` — record what was done and where you stopped
- `.claude/skills/project-md-updater/SKILL.md` — update progress log
- `.claude/skills/pendencias-updater/SKILL.md` — ensure current task state is saved

### 3. Commit

Commit all WIP state with a descriptive message noting the context recovery.

### 4. Tell the user

"Context is degrading. I've saved state. Please start a new session to continue with fresh context."

The next session's `/session-start` will pick up via the progress log and pendencias state.
