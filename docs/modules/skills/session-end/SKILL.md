---
name: session-end
invocation: user
effort: medium
description: >
  MUST run at the end of every implementation session. Orchestrates pattern
  extraction, session log, project/pendencias/config/rules updates in priority
  order. Without this, the next session starts with stale context and lost patterns.
created: framework-v2.1.0 (pre-validated)
derived_from: session_protocol "At the END of every session"
---

# Session End

## When to run

At the **end of every implementation session**, before the conversation closes.

Evolution classification and approval boundaries: see `.claude/rules/evolution-policy.md`.

## Process (in priority order)

### 1. Extract patterns from diff

Invoke `.claude/agents/diff-pattern-extractor.md` as subagent. Scans git diff, adds to Known Bug Patterns / Architecture Patterns. Isolated context.

### 2. Create session log + Update project.md

Run `.claude/skills/session-log-creator/SKILL.md` — creates the detailed record in `.claude/logs/`.

Then run `.claude/skills/project-md-updater/SKILL.md` — writes index row referencing the log + PRD version + phase status.

### 3. Update pendencias.md

Run `.claude/skills/pendencias-updater/SKILL.md` — moves completed tasks to `done_tasks.md`, adds new items with criteria.

### 4. Update CLAUDE.md

Run `.claude/skills/config-file-updater/SKILL.md` — updates module status, patterns, File Map when changed.

### 5. Update rules/agents/skills/PRD

Run `.claude/skills/rules-agents-updater/SKILL.md` — creates rules files, updates agents with discoveries.

## Priority and context limits

Items 1-3 are the critical minimum. Items 4-5 can be deferred if context window is low.

If severely limited: do at minimum items 2 and 3 (session log + pendencias), commit, and tell the user to start fresh.
