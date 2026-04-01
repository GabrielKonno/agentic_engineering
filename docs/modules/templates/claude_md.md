# Template: CLAUDE.md (slim orchestrator)

> Create at project root as `CLAUDE.md`.
> This is the v1.7.0 slim orchestrator (~90 lines). Protocol logic lives in process skills, loaded on demand.
> For the full protocol reference, see `docs/modules/session_protocol.md` and `docs/modules/execution_protocol.md`.

```markdown
# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview

[NAME from PRD] — [1-line description from PRD].

**Current state:** [list modules from PRD with ⏳]
**Owner:** [from PRD]
**PRD:** See `assets/docs/prd.md`
**Pending tasks:** See `.claude/phases/pendencias.md`
**Session logs:** See `.claude/logs/` (permanent record, one file per session)

## Session Protocol

- Before implementation work, run `/sprint-proposer` to load context and propose a sprint
- Every session with implementation work MUST end with `/session-end`
- If context degrades mid-session: run `/context-recovery`
- Task limits, documentation quality, reasoning depth: see `.claude/rules/session-rules.md`
- Implementation workflow (before/during/after): handled by `validation-orchestrator` skill

## Commands

[Fill with stack commands from PRD:]
- dev server
- build
- lint
- migrations (if applicable)
- test (if applicable)

## MCP Servers

[Filled in Step 5 below]

## Skills & Agents

Auto-discovered from `.claude/skills/` and `.claude/agents/`. Each file's `description:` frontmatter tells Claude when to use it.

[Domain-specific skills added during bootstrap or later sessions.]

## Hooks

[Configured in Step 14 below — depends on project formatter.]

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
