---
name: sprint-proposer
invocation: inline
effort: medium
description: >
  Proposes a sprint batch at session start. Reads pendencias.md, selects 3-5 tasks,
  orders by dependency, presents for approval. MUST run at session start (item 6).
  Without this, you work task-by-task instead of efficient sprint batches.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol item 6
---

# Sprint Proposer

## When to run
At the START of every session, after reading pendencias.md (item 6 in Session Protocol).
Skip if MODEL SWITCH continuation is active (item 2 already selected the task).

## Process

### 1. Analyze pendencias.md
- Read all items in "Next Steps" and "In Progress"
- Check dependency graph (`depends:` fields)
- Identify which tasks have satisfied dependencies
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
