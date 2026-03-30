---
name: sprint-proposer
invocation: inline
effort: medium
description: >
  Proposes a sprint batch at session start. Reads pendencias.md, selects 3-5 tasks,
  orders by dependency, presents for approval. Also manages sprint-approved mode
  (exception stops, between-tasks workflow, sprint reports). MUST run at session
  start (item 6). Without this, you work task-by-task instead of efficient batches.
created: framework-v1.7.0 (pre-validated)
derived_from: session_protocol item 6, execution_protocol "Sprint-approved mode" and "Between tasks"
---

# Sprint Proposer

## When to run
At the START of every session, after reading pendencias.md (item 6 in Session Protocol).
Skip if MODEL SWITCH continuation is active (item 2 already selected the task).
**After a model switch restart:** do NOT resume the previous sprint — propose a new one. The previous sprint was interrupted and context has changed.

## Process

### 1. Analyze pendencias.md
- Read all items in "Next Steps" and "In Progress"
- Check dependency graph (`depends:` fields)
- Identify which tasks have satisfied dependencies (a task in "Next Steps" or "In Progress" whose dependencies are all completed)
- If a `depends:` references a task number not found in pendencias.md, check `.claude/phases/done_tasks.md` — the dependency may have been archived there. If found in done_tasks.md, the dependency is satisfied.
- Note complexity classification of each task

### 2. Select tasks
- Pick 3-5 dependency-satisfied tasks
- Order by: dependency resolution first, then priority
- Respect task limit (3-5 standard, up to 7 if all small+related, 1 if large)
- Mix: prefer starting with a small warm-up task if available

### 3. Present sprint proposal

```
## Sprint Proposal: Session N
### Tasks selected (N):
1. Task [N] — [name] (complexity, estimated scope)
2. Task [N] — [name] (complexity, estimated scope)
### Execution order: [N → N → N]
### Reasoning depth: [recommendations per task]
### Risks: [anything that might cause a stop]
### What I need from you:
- Approve this sprint (I will execute all tasks, stopping only on exceptions)
- OR adjust: remove/add/reorder tasks
```

### 4. Handle response
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
