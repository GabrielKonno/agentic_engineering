---
name: session-start
invocation: user
effort: medium
description: >
  MUST run at the start of every session. Reads project state, checks for model
  switch continuation, syncs PRD, proposes sprint, discovers codebase. Without
  this, the session starts with incomplete context and wrong priorities.
created: framework-v1.7.0 (pre-validated)
derived_from: session_protocol "At the START of every session"
---

# Session Start

## When to run

At the **start of every session**, before any implementation work. This is not optional.
Skip only if explicitly told by the user to work on a specific task without sprint context.

## Process

### 1. Read CLAUDE.md

Read `CLAUDE.md` (project root). This gives you: project identity, architecture, commands, rules, patterns, file map.

### 2. Check for MODEL SWITCH continuation

Check for a MODEL SWITCH block below the Progress Log table in `.claude/phases/project.md`. If one exists:
- This session is a continuation — skip normal task selection
- The task and reason for the switch are in the marker
- Log: "Continuing: [task name] (model switched from [source] to [target])"
- Proceed directly to the validation-orchestrator skill's "Before Implementing" section with the specified task

If no MODEL SWITCH block exists, continue normally.

### 3. Read project.md

Read `.claude/phases/project.md`:
- **First session:** read fully (overview, architectural decisions, module relationships, phases)
- **Returning sessions:** architectural decisions + Project Phases status + Progress Log index

### 4. PRD sync check

Invoke `.claude/agents/prd-sync-checker.md` as subagent. This compares PRD version/content with project.md and propagates changes. Runs in isolated context, no session bias.

### 5. Read pendencias.md

Read `.claude/phases/pendencias.md` — understand what is next, what is in progress, what is blocked.

### 6. Propose sprint

Run `.claude/skills/sprint-proposer/SKILL.md`. This selects 3-5 tasks, orders by dependency, and presents for approval.

### 7. Read relevant rules

Read `.claude/rules/*.md` relevant to the tasks in the proposed sprint.

### 8. Read design system

If modifying UI in this session, read the Design System section of CLAUDE.md or the design system file if it exists.

### 9. Read relevant skills

Read `.claude/skills/*/SKILL.md` if a relevant domain/stack skill exists for the current tasks.

### 10. Codebase discovery

If first session or unfamiliar module:

```bash
find . -maxdepth 2 -type d -not -path '*/node_modules/*' -not -path '*/.next/*' -not -path '*/.git/*' -not -path '*/venv/*' -not -path '*/__pycache__/*' -not -path '*/dist/*' -not -path '*/build/*' | head -40
find . -type f -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.rb" -o -name "*.java" -o -name "*.vue" -o -name "*.svelte" 2>/dev/null | grep -v node_modules | grep -v .next | wc -l
ls -la package.json tsconfig.json next.config.* nuxt.config.* vite.config.* manage.py pyproject.toml go.mod Cargo.toml Gemfile docker-compose.yml 2>/dev/null
```

Explore deeper based on framework detected. File Map in CLAUDE.md is a quick pointer; codebase discovery is the source of truth. If they conflict, trust discovery and update File Map.

---

## Model Switch Protocol

**Trigger:** Task classified as Architecture/Security AND current model is not the most capable.

This protocol saves state and requests a session restart with a more capable model. The next session's step 2 will detect the marker and continue automatically.

### Initiating a model switch:

1. **Save state:** Run session-log-creator, project-md-updater, and pendencias-updater skills. The project-md-updater writes a MODEL SWITCH block below the Progress Log table in project.md (not as a table row):
   ```
   <!-- MODEL SWITCH — active -->
   ### [date] — Session N (MODEL SWITCH — continuing in next session)
   **What was done:** [work before switch]
   **Model switch reason:** Task "[name]" classified as architecture/security
   **Continue with:** Task [N] from pendencias — [task name]
   **Settings changed:** model → [target], effortLevel → high
   **PRD version:** vX.X.X
   ```

2. **Commit:** `git add -A && git commit -m "wip: model switch for [task name]"`

3. **Sprint interruption:** If triggered during a sprint, add to marker:
   `**Sprint interrupted:** Yes — remaining tasks: [list]`
   After restart, do NOT resume the previous sprint — propose a new one.

4. **Update settings:** Edit `~/.claude/settings.json` — change model and effortLevel.

5. **Tell user:** "Task [name] requires [model]. Settings updated. Please restart."

### After model switch task completes:

Evaluate the next task. If routine → revert settings to standard. If next task also needs this model → keep settings. Log the revert decision in project.md.
