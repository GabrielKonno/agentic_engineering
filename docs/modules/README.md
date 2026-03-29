# Framework Modules

Single source of truth for all templates and protocols used by bootstrap prompts.

## Structure

- `session_protocol.md` — Session Protocol (START, END, between-tasks, mid-session recovery)
- `execution_protocol.md` — Execution Protocol (before implementing, validation loop, validation orchestration)
- `templates/` — Document and agent templates used at bootstrap
- `skills/` — Pre-built process skills copied to projects at bootstrap Step 5.7

## How bootstraps use modules

The bootstrap prompt (`session0_bootstrap_prompt.md`) references modules instead of containing templates inline. Each step:

1. Reads the relevant module file
2. Adapts placeholders with PRD data and project-specific values
3. Creates the file at the project path

## Tool values

Protocols and templates use these Claude Code paths:

| Value | Path |
|-------|------|
| Config file | `CLAUDE.md` |
| Config directory | `.claude/` |
| Subagent tool | Task tool |

Agent templates are stored at `.claude/agents/[name].md`.

## Editing rules

- **Modify modules here** — this is the single source of truth
- **Never inline templates in bootstrap prompts** — always reference modules
- **After modifying a module**, verify the bootstrap prompt still works (it references the same modules)
