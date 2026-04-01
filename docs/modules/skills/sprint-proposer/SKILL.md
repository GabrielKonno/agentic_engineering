---
name: sprint-proposer
invocation: user
effort: medium
description: >
  Run before implementation work to load project state, sync PRD, and propose a
  sprint. Checks for model switch continuation, reads project.md, optionally syncs
  PRD, analyzes pendencias.md, selects 3-5 tasks by dependency, and presents for
  approval. Also manages sprint-approved mode (exception stops, between-tasks
  workflow, sprint reports). Not needed for planning discussions, task management,
  or quick fixes. Without this, implementation sessions start without project
  context and wrong priorities.
created: framework-v1.7.0 (pre-validated)
derived_from: session_protocol "At the START of implementation sessions"
---

# Sprint Proposer

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

### 4. Analyze pendencias.md and propose sprint

Read `.claude/phases/pendencias.md`. If MODEL SWITCH continuation was active (step 1), skip this step entirely.

After a model switch restart: do NOT resume the previous sprint — propose a new one. The previous sprint was interrupted and context has changed.

#### 4a. Analyze
- Read all items in "Next Steps" and "In Progress"
- Check dependency graph (`depends:` fields)
- Identify which tasks have satisfied dependencies (a task in "Next Steps" or "In Progress" whose dependencies are all completed)
- If a `depends:` references a task number not found in pendencias.md, check `.claude/phases/done_tasks.md` — the dependency may have been archived there. If found in done_tasks.md, the dependency is satisfied.
- Note complexity classification of each task

#### 4b. Select tasks
- Pick 3-5 dependency-satisfied tasks
- Order by: dependency resolution first, then priority
- Respect task limit (3-5 standard, up to 7 if all small+related, 1 if large)
- Mix: prefer starting with a small warm-up task if available

#### 4c. Present sprint proposal

```
## Sprint Proposal: Session N
### Tasks selected (N):
1. Task [N] — [name] (complexity, estimated scope)
2. Task [N] — [name] (complexity, estimated scope)
### Execution order: [N → N → N]
### Model & effort:
- Task [N]: [complexity] → [recommendation]
- Task [N]: [complexity] → [recommendation]
### Risks: [anything that might cause a stop]
### What I need from you:
- Approve this sprint (I will execute all tasks, stopping only on exceptions)
- OR adjust: remove/add/reorder tasks
```

**Model & effort mapping** (derive from each task's `Complexity:` field in pendencias.md):
- `routine` → `current settings`
- `logic-heavy` → `recommend extended thinking`
- `architecture/security` → `⚠️ model switch required (interrupts sprint)`

#### 4d. Handle response
- **Human approves** → enter sprint-approved mode (medium tasks proceed without approval)
- **Human adjusts** → apply adjustments and confirm
- **Human wants task-by-task** → proceed as Level 3 (present each task individually)

### Rules
- Only include tasks with satisfied dependencies
- Never include a task whose prerequisite is also in the sprint (sequential dependency)
- If a task is classified as architecture/security, it will trigger model switch — note this in Risks
- Large tasks (1 per session) should not be batched with other tasks

---

## Sprint-Approved Mode (Level 4)

When the human approves a sprint batch (step 4 above), the following rules apply:

- **Small tasks:** implement directly (same as Level 3).
- **Medium tasks:** generate the plan, log it, and proceed WITHOUT waiting for approval.
- **Large tasks:** still require individual plan approval, even within a sprint.
- **Discoveries during implementation:** add new task to pendencias.md with full Context/State/Constraints/Complexity/Criteria. Continue sprint unless the discovery blocks the current task. **Cap: max 3 discoveries per sprint.** After 3, flag to human at next exception stop or sprint report.

### Exception stops

Sprint-approved mode pauses only for these conditions:

- ❌ after 3 retry cycles
- PRD ambiguity or contradiction with existing decision
- MANUAL: criteria (flag in report, continue with next task)
- Context degradation (trigger `/context-recovery`)
- Current task blocked by a discovery requiring human input
- False ❌ from subagent escalated by arbitrator (genuinely ambiguous — human decides)

---

## Between Tasks (after validation passes)

After the validation-orchestrator skill completes successfully:

1. **Commit** if not already committed: for routine tasks with inline validation, `git add -A && git commit -m "feat: [task name] — validated"`. For subagent-validated tasks, the `feat:` commit was made before Phase B — it already stands.
2. **Update pendencias.md:** move completed task to `done_tasks.md` (full metadata), confirm next task in pendencias.md.
3. **Context health check:** If this is task 3+ in the session, evaluate context health. If degrading → run `/context-recovery` instead of continuing.
4. **Sprint-approved mode:** pick next task from the batch and proceed directly to the validation-orchestrator's "Before Implementing" section. Do NOT re-propose the sprint or ask for confirmation. If all sprint tasks are done, produce a sprint report:

```
## Sprint Report: Session N
### Tasks completed: [N/N]
| Task | Result | Issues |
|------|--------|--------|
| [name] | ✅/❌ | [MANUAL: items or notes] |
### Discoveries added to backlog: [N new tasks]
### Known Bug Patterns added: [N]
### Rules files created/updated: [list]
### Next sprint suggestion: [top 3-5 tasks]
```
