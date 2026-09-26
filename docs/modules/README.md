# Framework Modules

Single source of truth for all templates, agents, rules, and skills used by bootstrap prompts.

## Structure

- `templates/` — Document and config templates used at bootstrap (CLAUDE.md, project.md, pendencias.md, settings.json, metrics.md, framework-metrics.md, check-agent-frontmatter.mjs liveness guard, check-rules-paths.mjs rules load-scope guard)
- `agents/` — Agent templates (code-reviewer, validator, security-reviewer, etc.) copied to `.claude/agents/`
- `rules/` — Rules templates (session-rules, evolution-policy, component-design, ops-rules, quality-budgets) copied to `.claude/rules/`
- `skills/` — 15 pre-built process skills copied to projects at bootstrap Step 5.7 (12 lifecycle/process, incl. `autonomous-loop`) and Step 5.8 (3 tier-gated: codebase-audit, framework-audit, skill-gate)

## Layers — core and teams

Every module belongs to ONE layer. **Core** serves any team (session cycle, backlog, evolution,
generic validation). **IT** is the software team, installed by default today. The layer does NOT
change where a component is installed: bootstrap copies both layers (tier-gated modules per the
risk profile), because IT is the only distributed team. It records which components a non-code team would still need, and it is where a
future team's modules will be listed.

**The directory layout does not follow the layers yet — ON PURPOSE.** The physical split
(`core/`, `teams/<team>/`) is deferred until a SECOND team is distributed by the framework, so the
path citations to `docs/modules/` are rewritten once, in the batch that gives the new directories a
reason to exist (owner decision, 2026-09-26).

| Layer | Skills | Agents | Rules | Templates |
|-------|--------|--------|-------|-----------|
| **Core** | `sprint-proposer`, `session-end`, `session-log-creator`, `context-recovery`, `pendencias-updater`, `project-md-updater`, `config-file-updater`, `rules-agents-updater`, `commit`, `cross-cutting-analysis`, `autonomous-loop`; tier-gated: `framework-audit`, `skill-gate` | `prd_sync_checker`, `skill_reviewer` (tier-gated) | `session_rules`, `evolution_policy`, `component_design` | `claude_md`, `project_md`, `pendencias_md`, `settings_json`, `check_agent_frontmatter`, `check_rules_paths`, `framework_metrics_md` |
| **Core, with code vocabulary** | `validation-orchestrator` — the per-task cycle is generic; its three routes are code routes | `criteria_enforcer` — every deliverable has acceptance criteria; its BUILD/VERIFY/QUERY/REVIEW tags are code tags · `diff_pattern_extractor` — spawned by the core session-end skill every session, but it reads the diff: it is IT's learning sensor | — | — |
| **IT** | tier-gated: `codebase-audit` | `code_reviewer`, `security_reviewer`, `red_team`, `blue_team`, `validator`, `arbitrator` | `quality_budgets`, `ops_rules` | `metrics_md` |

**When a module is ADDED, ALWAYS add it to this table in the same edit** — it is an inventory
surface, like the lists above (`/maintenance` → the inventory propagation sweep).

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

### Four mechanisms for reasoning depth (complementary)

1. **Agent-level (automatic):** `effort:` in agent/skill frontmatter. Applies when that agent/skill is invoked. Security agents always use `effort: high`.
2. **Task-level recommendation (seconds):** AI classifies task complexity → recommends increased reasoning depth in the plan. Human adjusts before approving. No restart needed.
3. **Session-level model switch (restart):** AI detects task needs a different model → saves state with MODEL SWITCH marker → requests restart. AI reverts settings after task completion.
4. **Component-level model (declarative):** `model:` in AGENT frontmatter, decided by the component's risk class and written once. Mechanisms 1-3 only ESCALATE; this is the only one that DESCENDS, and without it every spawned agent inherits the orchestrator's model whatever its risk class. Policy: `rules/session_rules.md` → "Model by risk class".

Mechanisms stack: a standard-effort session uses high effort when security agents run (1), can switch to high effort for a financial task (2), and can switch to a more capable model for an architecture task (3) — while (4) holds each spawned agent at the model its own risk class warrants, independently of the other three.

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
- Segment or continuous orchestration (Level 5, opt-in) → `skills/autonomous-loop/`
- Validation loop → `skills/validation-orchestrator/`
- Evolution policy and auto-evolution boundaries → `rules/evolution_policy.md`
