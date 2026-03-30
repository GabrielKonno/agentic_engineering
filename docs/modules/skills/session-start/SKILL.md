---
name: session-start
invocation: user
effort: medium
description: >
  Run before implementation work to load project state, sync PRD, and propose a
  sprint. Not needed for planning discussions, task management, or quick fixes.
  Without this, implementation sessions start without project context and wrong
  priorities.
created: framework-v1.7.0 (pre-validated)
derived_from: session_protocol "At the START of implementation sessions"
---

# Session Start

## When to run

Before **implementation work** — when you intend to build, fix, or validate code.

Not needed for:
- Planning discussions or architecture reviews
- Adding/reorganizing tasks in pendencias.md
- Quick fixes where the user specifies the exact task
- Framework maintenance sessions

Claude Code automatically handles: CLAUDE.md reading, rules loading (via `applies_to` globs), skill/agent discovery (via `description:` frontmatter), and codebase exploration.

## Process

### 1. Check for MODEL SWITCH continuation

Check for a MODEL SWITCH block below the Progress Log table in `.claude/phases/project.md`. If one exists:
- This session is a continuation — skip normal task selection
- The task and reason for the switch are in the marker
- Log: "Continuing: [task name] (model switched from [source] to [target])"
- Proceed directly to the validation-orchestrator skill's "Before Implementing" section with the specified task

If no MODEL SWITCH block exists, continue normally.

### 2. Read project.md

Read `.claude/phases/project.md`:
- **First session:** read fully (overview, architectural decisions, module relationships, phases)
- **Returning sessions:** architectural decisions + Project Phases status + Progress Log index

### 3. PRD sync check (opt-in)

Ask the user: **"Do you want me to run the PRD sync check?"**

If yes: invoke `.claude/agents/prd-sync-checker.md` as subagent. This compares PRD version/content with project.md and propagates changes. Runs in isolated context, no session bias.

If no: skip. The user knows whether the PRD changed or was already synced.

### 4. Read pendencias.md

Read `.claude/phases/pendencias.md` — understand what is next, what is in progress, what is blocked.

### 5. Propose sprint

Run `.claude/skills/sprint-proposer/SKILL.md`. This selects 3-5 tasks, orders by dependency, and presents for approval.

---

## Model Switch Protocol

**Trigger:** Task classified as Architecture/Security AND current model is not the most capable.

This protocol saves state and requests a session restart with a more capable model. The next session's step 1 will detect the marker and continue automatically.

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
