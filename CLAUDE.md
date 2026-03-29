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
│   │   ├── session_protocol.md             # Session Protocol (START, END, recovery)
│   │   ├── execution_protocol.md           # Execution Protocol (validation loop, orchestration)
│   │   ├── templates/                      # Document and agent templates for bootstrap
│   │   │   ├── claude_md.md, gemini_md.md  # Config file templates (orchestrator format)
│   │   │   ├── project_md.md, pendencias_md.md  # Phase document templates
│   │   │   ├── code_reviewer.md, security_reviewer.md  # Core agent templates
│   │   │   ├── validator.md, arbitrator.md # Validation agent templates
│   │   │   ├── red_team.md, blue_team.md   # Security agent templates
│   │   │   └── settings_json.md            # Settings + hooks template
│   │   └── skills/                         # Pre-built process skills (copied to projects)
│   │       ├── prd-sync-checker/           # 10 process skills implementing
│   │       ├── sprint-proposer/            # Session Protocol and Execution Protocol
│   │       ├── criteria-enforcer/          # as reusable, evolvable components
│   │       ├── validation-orchestrator/    # (see skills/README.md for full list)
│   │       └── ... (6 more)
│   ├── bootstrap_claude/
│   │   └── session0_bootstrap_prompt.md    # Bootstrap for Claude Code (references modules)
│   ├── bootstrap_antigravity/
│   │   └── session0_bootstrap_antigravity.md # Bootstrap for Antigravity (references modules)
│   └── toolkit_prompt/
│       ├── prd_planning_prompt.md              # Create a PRD from scratch
│       ├── prd_change_prompt.md                # Modify an existing PRD
│       ├── cross_tool_migration_prompt.md      # Migrate between Claude Code ↔ Antigravity
│       └── existing_project_adaptation_prompt.md # Upgrade existing project to framework
├── examples/                               # Quality reference for agents, skills, rules
│   ├── agents/                             # Agent templates by category
│   ├── skills/                             # Skill templates by type
│   └── rules/                              # Rules file templates
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
- **Get their own git:** `git init` + `git remote add origin [project-repo-url]`
- **Self-contained after bootstrap** — examples/ copied into `assets/examples/`, own CLAUDE.md, own Session Protocol
- **Development happens here** — `cd projects/[project-name] && claude`
- **Two git repos coexist:** framework git ignores the folder, project git only sees itself

## What You Do Here

### 1. Bootstrap a new project (most common)

The user will say something like: "Bootstrap project X" or send the session0 prompt.

**Process:**
1. Read `docs/bootstrap_claude/session0_bootstrap_prompt.md` (or the Antigravity variant in `docs/bootstrap_antigravity/`)
2. Create the project folder: `projects/[project-name]/`
3. Verify the PRD exists: `projects/[project-name]/assets/docs/prd.md`
4. Execute the session0 prompt — all files created inside `projects/[project-name]/`
5. Report bootstrap results

**If no PRD exists:** Tell the user to create one first using `docs/toolkit_prompt/prd_planning_prompt.md` (they can do this in a chat tool like claude.ai, then paste the result as `prd.md`).

**After bootstrap, the user will:**
```bash
cd projects/[project-name]
git init
git remote add origin [project-repo-url]
git add -A && git commit -m "chore: bootstrap from agentic framework"
git push -u origin main
```

From this point, development happens from inside the project folder with its own CLAUDE.md. The framework repo is no longer involved.

### 2. Adapt an existing project

The user has a project with existing code and partial framework structure.

**Process:**
1. Read `docs/toolkit_prompt/existing_project_adaptation_prompt.md`
2. This runs from the **project root** (not the framework root) — the user should `cd` into the project first

### 3. Create or refine a PRD

The user wants to define a product before bootstrapping.

**Process:**
1. Read `docs/toolkit_prompt/prd_planning_prompt.md` (creation) or `docs/toolkit_prompt/prd_change_prompt.md` (modification)
2. Follow the interactive process in the prompt
3. Save the result to `projects/[project-name]/assets/docs/prd.md`

### 4. Migrate between tools

The user wants to switch a project from Claude Code to Antigravity or vice versa.

**Process:**
1. Read `docs/toolkit_prompt/cross_tool_migration_prompt.md`
2. This runs from the project root

## Rules

- **Never modify files in `docs/` or `examples/` during bootstrap operations** — these are 
  read-only references for project creation. Exception: framework maintenance sessions 
  (when the user explicitly states this is a maintenance session, or provides a correction 
  plan / audit report targeting these files).
- **Always work inside `projects/[project-name]/`** when creating project files
- **Copy `examples/` into the project** during bootstrap (Step 1.5) — projects get their own copy
- **Each project is self-contained** — after bootstrap, development happens from within the project folder with its own CLAUDE.md
- **This CLAUDE.md is for bootstrap operations only** — project development uses the project's own CLAUDE.md