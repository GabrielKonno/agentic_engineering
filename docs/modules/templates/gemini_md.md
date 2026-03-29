# Template: GEMINI.md (orchestrator)

> Create at project root as `GEMINI.md`.
> This is the v1.6.0 slim orchestrator template (~200 lines). Protocol details are in process skills.
> For the full protocol reference, see `docs/modules/session_protocol.md` and `docs/modules/execution_protocol.md`.

```markdown
# GEMINI.md

This file provides guidance to Antigravity agents when working with this repository.

## Project Overview

[NAME from PRD] — [1-line description from PRD].

**Current state:** [list modules from PRD with ⏳]
**Owner:** [from PRD]
**PRD:** See `assets/docs/prd.md`
**Pending tasks:** See `.antigravity/phases/pendencias.md`
**Session logs:** See `.antigravity/logs/` (permanent record, one file per session)

## Session Protocol

### At the START of every session:
1. Read `GEMINI.md` (this file)
2. **Check for MODEL SWITCH continuation:** Read last entry of `.antigravity/phases/project.md`. If it contains a "MODEL SWITCH" marker:
   - This session is a continuation — skip normal task selection
   - The task and reason for the switch are in the marker
   - Log: "Continuing: [task name] (model switched from [source] to [target])"
   - Proceed directly to "Before implementing" with the specified task
3. Read `.antigravity/phases/project.md` — full on first session; architectural decisions + status + last 2 entries on returning sessions
4. **PRD sync check** → run `.antigravity/skills/prd-sync-checker/SKILL.md`
   <!-- Compares PRD version/content with project.md, propagates changes -->
5. Read `.antigravity/phases/pendencias.md` — what is next
6. **Propose sprint** → run `.antigravity/skills/sprint-proposer/SKILL.md`
   <!-- Selects 3-5 tasks, orders by dependency, presents for approval -->
7. Read `.antigravity/rules/*.md` relevant to current task
8. Read design system if modifying UI
9. Read `.antigravity/skills/*/SKILL.md` if relevant skill exists for current task
10. **Codebase discovery** (if first session or unfamiliar module):
    ```bash
    find . -maxdepth 2 -type d -not -path '*/node_modules/*' -not -path '*/.next/*' -not -path '*/.git/*' -not -path '*/venv/*' -not -path '*/__pycache__/*' -not -path '*/dist/*' -not -path '*/build/*' | head -40
    ```
    File Map in GEMINI.md is a quick pointer; codebase discovery is the source of truth. If they conflict, trust discovery and update File Map.

### Task limit per session:
Maximum 3-5 tasks per session. Up to 7 if all small+related. 1 if large.
Signals of exceeding: contradicting earlier findings, skipping validation steps, producing ⏭️ on steps that should be ✅ or ❌.

### Three mechanisms for reasoning depth (complementary):
1. **Agent-level (automatic):** `effort:` in skill frontmatter. Security skills always warrant high effort.
2. **Task-level (2 seconds):** AI recommends increased reasoning depth in plan. Human adjusts.
3. **Session-level model switch (5 seconds):** AI saves state with MODEL SWITCH marker → updates config → requests restart.

### Before implementing any feature:
- **Enforce criteria quality** → run `.antigravity/skills/criteria-enforcer/SKILL.md`
  <!-- Rewrites WEAK criteria to STRONG, runs adversarial review -->
- **Antigravity Planning Mode:** For medium and large tasks, use native Planning Mode.
- **Classify task complexity:**
  - Routine → current model + reasoning fine
  - Logic-heavy → recommend increased reasoning depth
  - Architecture/Security → trigger model switch protocol (below)
- **Complexity threshold:**
  - Small: use Fast Mode → implement directly. No plan needed.
  - Medium: use Plan Mode → generate plan → wait for approval.
  - Large: use Plan Mode → plan with risks → wait for approval.

If medium or large, generate Implementation Plan artifact:
```
## Implementation Plan: [feature name]
### Changes needed:
1. [file] — [what changes and why]
### Migration needed: [yes/no]
### Risks: [what could break]
### Validation strategy: [which criteria, which tools]
### Estimated scope: [small / medium / large]
```

**Sprint-approved mode (Level 4):** If human approved a sprint batch:
- Small: implement directly. Medium: proceed without approval. Large: still need approval.
- Discoveries: add to pendencias.md. Cap: max 3 per sprint.
- **Exception stops** (sprint pauses only for these):
  - ❌ after 3 retry cycles
  - PRD ambiguity or contradiction with existing decision
  - MANUAL: criteria (flag in report, continue with next task)
  - Context degradation (trigger mid-session recovery)
  - Current task blocked by a discovery requiring human input
  - False ❌ from subagent escalated by arbitrator (genuinely ambiguous — human decides)

**Model switch protocol** (if task is Architecture/Security AND current model is not the most capable):
1. Save state: run project-md-updater and pendencias-updater skills. Add MODEL SWITCH marker to project.md:
   ```
   ### [date] — Session N (MODEL SWITCH — continuing in next session)
   **What was done:** [work before switch]
   **Model switch reason:** Task "[name]" classified as architecture/security
   **Continue with:** Task [N] from pendencias — [task name]
   **Settings changed:** model → [target], reasoning → maximum
   **PRD version:** vX.X.X
   ```
2. Commit: `git add -A && git commit -m "wip: model switch for [task name]"`
   If triggered during a sprint: add `**Sprint interrupted:** Yes — remaining tasks: [list]` to marker. After restart, propose new sprint (do NOT resume previous).
3. Update model configuration in Antigravity settings
4. Tell user: "Task [name] requires [model]. Settings updated. Please restart."
5. After task complete: if next task is routine → revert settings. If next also needs this model → keep.

### Git checkpoint (medium and large tasks):
Before writing code: `git add -A && git commit -m "checkpoint: before [task name]"`

### During implementation:
- **Validation loop** → run `.antigravity/skills/validation-orchestrator/SKILL.md`
  <!-- Phase A (implement + commit) then Phase B (graduated validation by complexity) -->

### Between tasks (after validation passes):
1. Commit if not already committed
2. Update pendencias.md: mark task as Done, confirm next
3. If task 3+ in session: evaluate context health → mid-session recovery if degrading
4. **Sprint-approved mode:** pick next task, proceed directly. If all done, produce sprint report:
   ```
   ## Sprint Report: Session N
   ### Tasks completed: [N/N]
   | Task | Result | Issues |
   |------|--------|--------|
   | [name] | ✅/❌ | [MANUAL: items or notes] |
   ### Discoveries added to backlog: [N]
   ### Known Bug Patterns added: [N]
   ### Next sprint suggestion: [top 3-5 tasks]
   ```

### At the END of every session (in order):
1. **Extract patterns** → run `.antigravity/skills/diff-pattern-extractor/SKILL.md`
   <!-- Scans git diff, adds to Known Bug Patterns / Architecture Patterns -->
2. **Update project.md** → run `.antigravity/skills/project-md-updater/SKILL.md`
   <!-- Session entry with decisions, bugs, PRD version -->
   **Create session log** → run `.antigravity/skills/session-log-creator/SKILL.md`
   <!-- Permanent verbose record in .antigravity/logs/ -->
3. **Update pendencias.md** → run `.antigravity/skills/pendencias-updater/SKILL.md`
   <!-- Move completed to Done, add new items with full criteria -->
4. **Update GEMINI.md** → run `.antigravity/skills/claude-md-updater/SKILL.md`
   <!-- When module status, patterns, rules, or File Map changed -->
5. **Update rules/skills/PRD** → run `.antigravity/skills/rules-agents-updater/SKILL.md`
   <!-- Create rules files, update skills with discoveries, on-demand creation -->

### Mid-session context recovery:
If context is degrading (contradicting earlier decisions, repeating mistakes):
1. STOP implementation
2. Run end-of-session skills (at minimum items 2 and 3)
3. Commit: `git add -A && git commit -m "wip: [task] — context limit"`
4. Tell user: "Context is degrading. Please start a new session."

## Commands

[Fill with stack commands from PRD:]
- dev server
- build
- lint
- migrations (if applicable)
- test (if applicable)

## Skills

[Filled in Step 7 below]

**Process skills (copied from framework):**
- prd-sync-checker, sprint-proposer, criteria-enforcer, validation-orchestrator
- diff-pattern-extractor, project-md-updater, pendencias-updater
- claude-md-updater, rules-agents-updater, session-log-creator

## Architecture

[Extract from PRD section 5. If undefined, suggest and register as decision.]

- **Framework**: [...]
- **Styling**: [...]
- **Database**: [...]
- **Auth**: [...]
- **Deploy**: [...]

## Key Patterns

[AI: Based on the PRD stack, define 3-5 key technical patterns for this project.]

## Build Order

[Derive from PRD: order modules by dependency and value.]

1. [Setup + Auth] ⏳
2. [Most fundamental module] ⏳
3. [Module depending on previous] ⏳

## Design System

[If PRD defines it: reference. If not: mark "to be created in Phase X".]

## File Map

[Empty until code is written. Populated by codebase discovery as modules are built.]

## Environment Variables

[List variables needed based on stack, without values:]
- `[VAR_NAME]` — [description]
```
