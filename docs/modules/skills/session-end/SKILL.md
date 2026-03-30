---
name: session-end
invocation: user
effort: medium
description: >
  MUST run at the end of every session. Orchestrates pattern extraction, session
  log creation, project/pendencias/config/rules updates in priority order.
  Without this, the next session starts with stale context and lost patterns.
created: framework-v1.7.0 (pre-validated)
derived_from: session_protocol "At the END of every session"
---

# Session End

## When to run

At the **end of every session**, before the conversation closes. This is not optional.
Also called by `context-recovery` skill when context is degrading mid-session.

## Evolution classification

Every evolution applied during end-of-session steps must be classified by its trigger:

| Mode | Trigger | Examples |
|------|---------|----------|
| **FIX** | Something failed that should have worked | Bug missed by review → fix agent checklist. Rule contradicts code → fix rule. |
| **DERIVED** | Something works but can be consolidated | 3+ Known Bug Patterns from same domain → derive rules file. Agent accumulates similar checks → derive organized sections. |
| **CAPTURED** | Pattern observed in real usage | Diff scan finds recurring pattern → capture as Known Bug Pattern. Structural decision → capture as Architecture Pattern. |

The classification determines follow-up actions:
- **FIX** → re-run eval if the component has a `last_eval` in its lineage
- **DERIVED** → no eval needed (source patterns were already validated individually)
- **CAPTURED** → no eval needed (the diff is the evidence)

Log each evolution with its classification: `"[FIX/DERIVED/CAPTURED]: [component] — [what changed and why]"`

## Process (in priority order)

Before running any step, create a task list to track progress:

- [ ] diff-pattern-extractor (subagent — invoke via Agent tool)
- [ ] session-log-creator
- [ ] project-md-updater
- [ ] pendencias-updater
- [ ] config-file-updater
- [ ] rules-agents-updater

Mark each task complete only after the skill finishes.

### 1. Extract patterns from diff

Invoke `.claude/agents/diff-pattern-extractor.md` as subagent. This scans git diff and adds to Known Bug Patterns / Architecture Patterns. Runs in isolated context.

### 2. Create session log + Update project.md

Run `.claude/skills/session-log-creator/SKILL.md` — creates the primary detailed record in `.claude/logs/`.

Then run `.claude/skills/project-md-updater/SKILL.md` — writes a concise index row referencing the session log + PRD version + phase status.

### 3. Update pendencias.md

Run `.claude/skills/pendencias-updater/SKILL.md` — moves completed tasks to `done_tasks.md` with full metadata, adds new items with full criteria.

### 4. Update CLAUDE.md

Run `.claude/skills/config-file-updater/SKILL.md` — updates module status, patterns, rules, or File Map when they changed during this session.

### 5. Update rules/agents/skills/PRD

Run `.claude/skills/rules-agents-updater/SKILL.md` — creates rules files, updates agents with discoveries, handles on-demand creation.

## Priority and context limits

**Documentation updates are mandatory.** Items 1-3 are critical minimum. Items 4-5 can be deferred if context window is low.

If context is severely limited (cannot complete all 5 steps): do at minimum items 2 and 3 (session log + pendencias), then commit and tell the user to start fresh.

## Auto-evolution boundaries

The rule: if the evolution changes **DATA** (what the agent knows), it is safe for autonomous evolution. If it changes **BEHAVIOR** (how the agent acts), it requires human approval.

**Agent evolves autonomously (no human approval needed):**
- Known Bug Patterns (factual — derived from diffs)
- Architecture Patterns (factual — derived from structural decisions)
- File Map in CLAUDE.md (factual — reflects filesystem)
- Commands section in CLAUDE.md (factual — reflects what works)
- Skills content (knowledge/process — errors are caught by eval loops)
- Agent checklist items — **ADDING** new checks (from real bugs via FIX mechanism)
- Lineage metadata (append-only)
- Efficacy tracking fields (append-only metrics)

**Requires human approval before modification:**
- Session Protocol / Execution Protocol / Validation Orchestration Protocol
- Task limits, retry limits, sprint mechanics
- Context routing rules
- Rules files (domain business logic)
- PRD
- Agent checklist items — **REMOVING or WEAKENING** existing checks
- Changing an agent's `invocation` type, report format, or trigger conditions

The agent checks this list before making updates. For human-approval items, propose the change in the session log and wait for confirmation instead of applying directly.
