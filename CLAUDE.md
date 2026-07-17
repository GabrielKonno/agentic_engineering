# CLAUDE.md

This file provides guidance to Claude Code when working with the Agentic Engineering Framework repository.

## What This Repository Is

This is a **meta-project** — a framework for creating and managing other projects. There is no application code here. Only documentation, templates, examples, and project folders.

**You do NOT write application code in this repository root.** You bootstrap projects inside `projects/` and develop within them.
 
## Repository Structure

```
agentic_engineering/                        ← Cloned once, kept permanently
├── CLAUDE.md                               ← You are reading this
├── README.md                               ← Project overview and quick start
├── .gitignore                              ← Contains "projects/" — isolates project repos
├── .claude/                                ← Active config for this repo (framework runtime)
│   ├── commands/                           # 6 slash commands (5 sessions + 1 utility)
│   │   ├── bootstrap.md                    # Create project structure from PRD (Session 0)
│   │   ├── existing_project_adaptation.md  # Upgrade existing project to current framework
│   │   ├── prd_planning.md                 # Create a PRD interactively
│   │   ├── prd_change.md                   # Modify an existing PRD with impact analysis
│   │   ├── maintenance.md                  # Edit framework docs, examples, CLAUDE.md
│   │   └── audit.md                        # Read-only framework integrity audit (utility)
│   ├── rules/
│   │   └── component-design.md             # Agent/skill/rule design policy (consulted during /maintenance)
│   ├── skills/
│   │   └── cross-cutting-analysis/         # Runtime skill used during PRD sessions
│   ├── docs/                               # Framework notes and ideas (not copied to projects)
│   ├── settings.json                       # Claude Code settings
│   └── settings.local.json                 # Machine-local overrides (gitignored)
│
│   NOTE: `.claude/` here is minimal by design — only what the framework
│   needs to run its own 5 session modes + 1 utility. The agent templates, rules
│   templates, and 14 process skills live under `docs/modules/` as
│   templates, copied to each project's `.claude/` at bootstrap (3 of the skills —
│   codebase-audit, framework-audit, skill-gate — are tier-gated and copied only
│   when the project's risk profile warrants them).
│   When adding a new skill to the framework: place it in BOTH
│   `docs/modules/skills/` (SSoT for bootstrap — copied per tier)
│   AND `.claude/skills/` ONLY if the framework itself needs it at runtime
│   (e.g., cross-cutting-analysis). Project-specific skills go only in the
│   project's `.claude/skills/`.
├── docs/
│   ├── agentic_engineering_framework.md    # Framework concepts (tool-agnostic)
│   ├── modules/                            # Shared templates and skills (single source of truth)
│   │   ├── README.md                       # Module index and structure guide
│   │   ├── templates/                      # Document and config templates for bootstrap
│   │   │   ├── claude_md.md                # Config file template (orchestrator format)
│   │   │   ├── project_md.md, pendencias_md.md  # Phase document templates
│   │   │   ├── metrics_md.md               # Code health time series (internal-tool+)
│   │   │   ├── settings_json.md            # Settings + hooks template
│   │   │   └── check_agent_frontmatter.md  # Component-registry liveness guard (all tiers → scripts/)
│   │   ├── agents/                         # Agent templates (copied to .claude/agents/)
│   │   │   ├── code_reviewer.md, security_reviewer.md  # Core agent templates
│   │   │   ├── validator.md, arbitrator.md # Validation agent templates
│   │   │   ├── red_team.md, blue_team.md   # Security agent templates
│   │   │   ├── prd_sync_checker.md, criteria_enforcer.md, diff_pattern_extractor.md  # Process agent templates
│   │   │   └── skill_reviewer.md           # Skill-gate blind reviewer (internal-tool+)
│   │   ├── rules/                          # Rules templates (copied to .claude/rules/)
│   │   │   ├── session_rules.md            # Task limits, risk tiers, archetypes, debt-aging, deploy gates
│   │   │   ├── evolution_policy.md         # Evolution classification + boundaries + back-sweep
│   │   │   ├── component_design.md         # Agent/skill/rule design: gap-declaration, Pushy Descriptions
│   │   │   ├── ops_rules.md                # Operate/lifecycle dimension template (production+)
│   │   │   └── quality_budgets.md          # Quality caps + delta gate (production+)
│   │   └── skills/                         # Pre-built process skills (14: 11 lifecycle/process + 3 tier-gated)
│   │       ├── sprint-proposer/            # Session Protocol and Execution Protocol
│   │       ├── validation-orchestrator/    # as reusable, evolvable components
│   │       ├── codebase-audit/             # MACRO axis — system health (internal-tool+)
│   │       ├── framework-audit/            # Meta-loop — process blind spots (production+)
│   │       ├── skill-gate/                 # Creation gate — blind review of new skills/rules (internal-tool+)
│   │       └── ... (9 more)               # (see skills/README.md for full list)
├── examples/                               # Quality reference for agents, skills, rules
│   ├── README.md                           # Conventions for creating agents/skills/rules
│   ├── agents/                             # Agent templates by category (20)
│   ├── skills/                             # Skill templates by type (9)
│   └── rules/                              # Rules file templates (11)
├── assets/
│   └── docs/                               # Framework-base source notes (upgrade lineage, not copied to projects)
└── projects/                               ← IGNORED by framework git (local-only workspace)
    └── [project-name]/                     ← Each project gets its own git repo
```

## Repository Lifecycle

### Framework repo (this repo)
- **Clone once:** `git clone [url] ~/agentic_engineering`
- **Update periodically:** `git pull` — updates docs, examples, prompts
- **`projects/` is in `.gitignore`** — framework git never sees project files
- **Never modified during bootstrap** — docs/ and examples/ are read-only references

### Project repos (inside projects/)
- **Created during bootstrap** inside `projects/[project-name]/`
- **Get their own git:** bootstrap runs `git init` + initial commit automatically. User only attaches the remote afterwards: `git remote add origin [project-repo-url]`
- **Self-contained after bootstrap** — examples/ copied into `assets/examples/`, own CLAUDE.md, own Session Protocol
- **Development happens here** — `cd projects/[project-name] && claude`
- **Two git repos coexist:** framework git ignores the folder, project git only sees itself

## Session Modes

This repository supports 5 session modes, each activated by its slash command:

| Mode | Command | Purpose |
|------|---------|---------|
| **PRD Planning** | `/prd_planning [project-name]` | Create a new PRD interactively |
| **PRD Change** | `/prd_change [project-name]` | Modify an existing PRD with impact analysis |
| **Bootstrap** | `/bootstrap [project-name]` | Create project structure from PRD (Session 0) |
| **Existing Project Adaptation** | `/existing_project_adaptation [project-name]` | Upgrade existing project to current framework |
| **Framework Maintenance** | `/maintenance` | Edit framework docs/examples (no project work) |

Each command sets the session mode, configures authorized operations, and guides the workflow. The project name argument maps to `projects/[project-name]/`.

**Utilities:** `/audit` — read-only integrity check across 17 dimensions (structural, references, process logic, quality, document accuracy, project-information isolation, and one meta dimension — D17 process coverage, which hunts flows the repo executes or promises but never documented). Launches 6 parallel audit agents and produces a consolidated report. No files are modified.

**Alternative (non-Claude Code):** The bootstrap logic lives in `.claude/commands/bootstrap.md` and can be adapted for other AI tools.

## What You Do Here

### 1. Bootstrap a new project (most common)

The user will say something like: "Bootstrap project X" or use the `/bootstrap` command.

**Process:**
1. Run `/bootstrap [project-name]`
2. The command creates the project folder, reads the PRD, and executes all bootstrap steps inside `projects/[project-name]/`
3. Report bootstrap results

**If no PRD exists:** Tell the user to create one first with `/prd_planning [project-name]`. Alternatively, the bootstrap works without PRD — sections will be marked "to be defined".

**After bootstrap** the project folder is already a git repo with a single `chore: bootstrap from agentic framework` commit (created by Steps Setup→14.5). The user only needs to attach the remote and push:

```bash
cd projects/[project-name]
git remote add origin [project-repo-url]
git push -u origin main
```

From this point, development happens from inside the project folder with its own CLAUDE.md. The framework repo is no longer involved.

### 2. Adapt an existing project

The user has a project with existing code and partial framework structure placed inside `projects/[project-name]/`.

**Process:**
1. Run `/existing_project_adaptation [project-name]`
2. The command reads the entire codebase, upgrades docs, creates a retroactive PRD, and fills gaps

### 3. Create or refine a PRD

The user wants to define a product before bootstrapping.

**Process:**
1. Run `/prd_planning [project-name]` (creation) or `/prd_change [project-name]` (modification)
2. The command guides an interactive process of discovery, architecture, and deep-dive
3. PRD is saved to `projects/[project-name]/assets/docs/prd.md`

### 4. Absorb framework evolutions from a project (upstream)

Projects discover framework-level lessons and record them as
`projects/[name]/.claude/docs/framework-evolution-*.md` (a convention shipped in the
evolution-policy template). Upstreaming them is a **maintenance** operation:

**Process:**
1. Run `/maintenance` naming the evolution docs as sources
2. Follow the command's "Upstream intake" section: read each doc, decide per evolution
   (graduate / adapt / reject), genericize (isolation is TOTAL), record the batch in a
   lineage doc under `assets/docs/`
3. Never edit the project's own docs — the project marks them `upstreamed` in its own session

## Rules

- **Never modify files in `docs/` or `examples/` during bootstrap operations** — these are
  read-only references for project creation. Exception: framework maintenance sessions
  (activate with `/maintenance` command, or when the user explicitly states this is a
  maintenance session / provides a correction plan targeting these files).
- **Always work inside `projects/[project-name]/`** when creating project files
- **Copy `examples/` into the project** during bootstrap (Step 1.5) — projects get their own copy
- **Each project is self-contained** — after bootstrap, development happens from within the project folder with its own CLAUDE.md
- **This CLAUDE.md is for framework operations only** — project development uses the project's own CLAUDE.md
- **Project-information isolation is TOTAL.** No project-specific information (project/client
  names, people, domains, infra identifiers, single-project vocabulary in examples) in ANY
  framework-layer artifact: tracked files, templates (double severity — they broadcast to every
  future project), lineage docs, `.claude/docs/` notes, or the agent's persistent memory.
  Refer to projects by role descriptor ("projeto-fonte", "the landing-page prototype") and
  resolve the actual folder at runtime from `projects/*/`'s own docs. Enforced mechanically
  by `/audit` D16 across ALL agent-reachable surfaces: tracked files, `.claude/docs/`, the
  agent's persistent memory (path resolved from session context), and git history —
  commit contents AND commit messages (leaks survive deletion; unpushed hits are locally
  fixable, pushed ones escalate to the owner).