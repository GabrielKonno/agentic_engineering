# Framework Modules

Single source of truth for all templates, agents, rules, and skills used by bootstrap prompts.

## Structure

- `templates/` — Document and config templates used at bootstrap (CLAUDE.md, project.md, pendencias.md, settings.json)
- `agents/` — Agent templates (code-reviewer, validator, security-reviewer, etc.) copied to `.claude/agents/`
- `rules/` — Rules templates (session-rules, evolution-policy, component-design) copied to `.claude/rules/`
- `skills/` — Pre-built process skills copied to projects at bootstrap Step 5.7

## How bootstraps use modules

The bootstrap command (`.claude/commands/bootstrap.md`) references modules instead of containing templates inline. Each step:

1. Reads the relevant module file
2. Adapts placeholders with PRD data and project-specific values
3. Creates the file at the project path

## Tool values

Templates and skills use these Claude Code paths:

| Value | Path |
|-------|------|
| Config file | `CLAUDE.md` |
| Config directory | `.claude/` |
| Subagent tool | Agent tool |

Agent templates are stored at `.claude/agents/[name].md`.

## Editing rules

- **Modify modules here** — this is the single source of truth
- **Never inline templates in bootstrap prompts** — always reference modules
- **After modifying a module**, verify the bootstrap prompt still works (it references the same modules)

---

## Design Rationale

### Three mechanisms for reasoning depth (complementary)

1. **Agent-level (automatic):** `effort:` in agent/skill frontmatter. Applies when that agent/skill is invoked. Security agents always use `effort: high`.
2. **Task-level recommendation (seconds):** AI classifies task complexity → recommends increased reasoning depth in the plan. Human adjusts before approving. No restart needed.
3. **Session-level model switch (restart):** AI detects task needs a different model → saves state with MODEL SWITCH marker → requests restart. AI reverts settings after task completion.

Mechanisms stack: a standard-effort session uses high effort when security agents run (1), can switch to high effort for a financial task (2), and can switch to a more capable model for an architecture task (3).

### Two validation routes

Graduated by task complexity — not all tasks justify subagent overhead:

| Route | When | Phase B method | Token cost |
|-------|------|----------------|------------|
| **Route 1 — Inline** | Routine tasks (UI text, config, simple CRUD) | Inline checklist | ~5–10k |
| **Route 2 — Subagent** | Logic-heavy + architecture/security | code-reviewer + validator subagents; security-reviewer + Red/Blue Team if security-relevant | ~50–150k |

Bias risk near-zero for routine tasks justifies skipping subagent overhead. Logic-heavy and security tasks carry meaningful bias risk from the implementing agent — isolated subagents eliminate that.

### Where protocol behavior lives

The step-by-step behavioral implementation is in skills (not here):
- Session lifecycle → `skills/sprint-proposer/`, `skills/session-end/`, `skills/context-recovery/`
- Validation loop → `skills/validation-orchestrator/`
- Evolution policy and auto-evolution boundaries → `rules/evolution_policy.md`
