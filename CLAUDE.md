# CLAUDE.md

This file provides guidance to Claude Code when working with the Agentic Engineering Framework repository.

## What This Repository Is

This is a **meta-project** — a framework for creating and managing other projects. There is no application code here. Only documentation, templates, examples, and project folders.

**You do NOT write application code in this repository root.** You bootstrap projects inside `projects/` and develop within them.
 
## Repository Structure

```
agentic_engineering/                        ← Cloned once, kept permanently
├── CLAUDE.md                               ← You are reading this
├── .gitignore                              ← Contains "projects/" — isolates project repos
├── docs/
│   ├── agentic_engineering_framework.md    # Framework concepts (tool-agnostic)
│   ├── modules/                            # Shared templates and skills (single source of truth)
│   │   ├── templates/                      # Document and config templates for bootstrap
│   │   │   ├── claude_md.md                # Config file template (orchestrator format)
│   │   │   ├── project_md.md, pendencias_md.md  # Phase document templates
│   │   │   └── settings_json.md            # Settings + hooks template
│   │   ├── agents/                         # Agent templates (copied to .claude/agents/)
│   │   │   ├── code_reviewer.md, security_reviewer.md  # Core agent templates
│   │   │   ├── validator.md, arbitrator.md # Validation agent templates
│   │   │   ├── red_team.md, blue_team.md   # Security agent templates
│   │   │   └── prd_sync_checker.md, criteria_enforcer.md, diff_pattern_extractor.md  # Process agent templates
│   │   ├── rules/                          # Rules templates (copied to .claude/rules/)
│   │   │   ├── session_rules.md            # Task limits, reasoning depth, scripts convention
│   │   │   ├── evolution_policy.md         # Evolution classification + auto-evolution boundaries
│   │   │   └── component_design.md         # Agent/skill/rule design: gap-declaration, Pushy Descriptions, vocabulary alignment
│   │   └── skills/                         # Pre-built inline process skills (10, copied to projects)
│   │       ├── sprint-proposer/            # Session Protocol and Execution Protocol
│   │       ├── validation-orchestrator/    # as reusable, evolvable components
│   │       └── ... (7 more)               # (see skills/README.md for full list)
├── examples/                               # Quality reference for agents, skills, rules
│   ├── README.md                           # Conventions for creating agents/skills/rules
│   ├── agents/                             # Agent templates by category (20)
│   ├── skills/                             # Skill templates by type (9)
│   └── rules/                              # Rules file templates (11)
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

## Rules

- **Never modify files in `docs/` or `examples/` during bootstrap operations** — these are
  read-only references for project creation. Exception: framework maintenance sessions
  (activate with `/maintenance` command, or when the user explicitly states this is a
  maintenance session / provides a correction plan targeting these files).
- **Always work inside `projects/[project-name]/`** when creating project files
- **Copy `examples/` into the project** during bootstrap (Step 1.5) — projects get their own copy
- **Each project is self-contained** — after bootstrap, development happens from within the project folder with its own CLAUDE.md
- **This CLAUDE.md is for framework operations only** — project development uses the project's own CLAUDE.md