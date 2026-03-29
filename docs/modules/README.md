# Framework Modules

Single source of truth for all templates and protocols used by bootstrap prompts.

## Structure

- `session_protocol.md` — Session Protocol (START, END, between-tasks, mid-session recovery)
- `execution_protocol.md` — Execution Protocol (before implementing, validation loop, validation orchestration)
- `templates/` — Document and agent templates used at bootstrap
- `skills/` — Pre-built process skills copied to projects at bootstrap Step 5.7

## How bootstraps use modules

Bootstrap prompts (`session0_bootstrap_prompt.md`, `session0_bootstrap_antigravity.md`) reference modules instead of containing templates inline. Each step:

1. Reads the relevant module file
2. Adapts placeholders with PRD data and project-specific values
3. Creates the file at the project path

## Tool-agnostic placeholders

Shared protocols use placeholders for tool-specific paths:

| Placeholder | Claude Code | Antigravity |
|-------------|------------|-------------|
| `{CONFIG_FILE}` | `CLAUDE.md` | `GEMINI.md` |
| `{CONFIG_DIR}` | `.claude/` | `.antigravity/` |
| `{AGENTS_PATH}` | `.claude/agents/` | `.antigravity/skills/` |
| `{SUBAGENT_TOOL}` | Task tool | Agent Manager |

Each bootstrap provides the mapping. Templates in `templates/` have tool-specific variants where needed (`claude_md.md` vs `gemini_md.md`).

## Editing rules

- **Modify modules here** — this is the single source of truth
- **Never inline templates in bootstrap prompts** — always reference modules
- **After modifying a module**, verify both bootstrap prompts still work (they reference the same modules)
