---
name: context-recovery
invocation: user
effort: medium
description: >
  Emergency mid-session recovery when context is degrading. Saves state via
  end-of-session skills, commits, and requests a new session. Trigger when
  contradicting earlier decisions, repeating mistakes, or losing track of state.
created: framework-v1.7.0 (pre-validated)
derived_from: session_protocol "Mid-session context recovery"
---

# Context Recovery

## When to run

When context window is getting full and quality is degrading. The user can also trigger this by saying "save state and start fresh".

### Signals of degradation:
- Contradicting earlier decisions or self-review findings
- Re-asking questions that were already answered
- Forgetting patterns from CLAUDE.md or rules files
- Inconsistent validation results
- Producing skip markers (⏭️) on steps that should be ✅ or ❌

## Process

### 1. STOP implementation

Immediately stop the current task. Do not attempt to finish it — partial work with degraded context produces more bugs than stopping.

### 2. Run end-of-session skills (minimum subset)

At minimum, run these three:
- `.claude/skills/session-log-creator/SKILL.md` — record what was done and where you stopped
- `.claude/skills/project-md-updater/SKILL.md` — update progress log
- `.claude/skills/pendencias-updater/SKILL.md` — ensure current task state is saved

If context allows, also run the full `/session-end` skill for complete state preservation.

### 3. Commit

```bash
git add -A && git commit -m "wip: [task name] — context limit"
```

### 4. Tell the user

"Context is degrading. I've saved state. Please start a new session to continue with fresh context."

The next session's `/session-start` will pick up where this one left off via the progress log and pendencias state.
