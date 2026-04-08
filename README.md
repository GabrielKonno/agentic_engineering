# Agentic Engineering Framework v2.1.0

A meta-framework for preparing an AI agent's workspace — instructions, protocols, validation agents, process skills, domain rules, and quality examples — so the AI can develop software projects autonomously with structured validation.

**This repository does not contain application code.** It contains everything needed to *bootstrap* a project: document templates, process skills, validation agents, quality examples, and interactive prompts. You run the bootstrap once; it creates a self-contained project with its own AI instructions. From that point, the AI develops the project autonomously — implementing, validating via independent subagents, and reporting with evidence. The human approves and directs.

---

## What This Framework Does

This repo is a **factory for AI-ready projects**. It reads your product requirements and generates a complete AI workspace:

```
  YOUR PRD               FRAMEWORK MODULES               BOOTSTRAPPED PROJECT
  (what to build)        (templates + protocols           (ready for development)
                          + skills + examples)
  +-------------+        +--------------------+           +---------------------+
  |  prd.md     |------->| Bootstrap Prompt   |---------->| CLAUDE.md           |
  +-------------+        |                    |           | project.md          |
                         | Reads:             |           | pendencias.md       |
                         |  - 16 templates    |           | 9+ agent .md files  |
                         |  - 2 protocols     |           | 10 process skills   |
                         |  - 10 skills       |           | 3 rules files       |
                         |  - examples/       |           | examples/ (copy)    |
                         |                    |           | settings.json       |
                         +--------------------+           +---------------------+
                                                                    |
                                                          cd projects/my-project
                                                          claude
```

### Two operating modes

**Bootstrap mode** (this repo) — The AI reads your PRD, reads the framework's templates and protocols, and creates all project files inside `projects/[name]/`. Run once per project. Triggered by the session0 bootstrap prompt.

**Development mode** (inside the project) — The AI reads the project's own CLAUDE.md, follows the Session Protocol, proposes sprints, implements tasks, validates via subagents, and reports with evidence. The framework repo is no longer involved.

### How development works (inside a bootstrapped project)

```
Human defines task with criteria --> AI implements -->
AI self-reviews --> AI tests (browser + DB) -->
AI verifies criteria --> AI reports with evidence -->
Human approves or redirects
```

At Level 4 (Auto Pilot), the AI proposes sprints, executes 3-5 tasks autonomously, and stops only on exceptions. The human approves the batch, not individual tasks.

---

## Quick Start

### New project (greenfield)

```
1. Clone this repo
2. Run Claude Code from the repo root: claude
3. Create a PRD: /prd_planning my-project
4. Bootstrap the project: /bootstrap my-project
5. Extract the project to its own repo
```

After extraction, the framework repo is no longer needed for this project — development happens entirely from within the project folder.

### Existing project (has code, needs framework)

```
1. Clone this repo
2. Place your project in projects/[name]/
3. Run Claude Code from the repo root: claude
4. Run: /existing_project_adaptation [name]
```

---

## Available Commands

Run these from the framework root with Claude Code:

| Command | Arguments | Purpose |
|---------|-----------|---------|
| `/prd_planning` | project name | Create PRD interactively — creates `projects/[name]/assets/docs/prd.md` |
| `/prd_change` | project name | Modify existing PRD with full impact analysis |
| `/bootstrap` | project name | Bootstrap project from PRD (Session 0) |
| `/existing_project_adaptation` | project name | Upgrade existing project to framework |
| `/maintenance` | (none) | Edit framework docs, examples, CLAUDE.md |

**Alternative:** The bootstrap logic lives in `.claude/commands/bootstrap.md` and can be adapted for other AI tools.

---

## Repository Structure

```
agentic_engineering/
├── CLAUDE.md                           ← Meta-project contract (Claude Code reads this)
├── .gitignore                          ← Ignores projects/ folder
├── README.md                           ← You are here
│
├── docs/
│   ├── agentic_engineering_framework.md    ← Core concepts (read this to understand the methodology)
│   │
│   ├── modules/                            ← Single source of truth (v2.1.0)
│   │   ├── session_protocol.md             ← Session Protocol (START, END, recovery)
│   │   ├── execution_protocol.md           ← Execution Protocol (validation loop)
│   │   ├── templates/                      ← Document and config templates
│   │   ├── agents/                         ← Agent templates (9 agents)
│   │   ├── rules/                          ← Rules templates (3 rules files)
│   │   └── skills/                         ← 10 pre-built process skills
│   │
├── examples/                           ← Quality reference templates (copied to projects)
│   ├── README.md                       ← Conventions for creating agents/skills
│   ├── agents/                         ← 20 agent templates (quality, domain, ops, security, compliance)
│   ├── skills/                         ← 9 skill templates (stack, domain, process)
│   └── rules/                          ← 11 rules templates (auth, compliance, i18n, scheduling, resilience, integration, etc.)
│
└── projects/                           ← Local workspace (git-ignored)
    └── [project-name]/                 ← Each project gets its own git repo
```

---

## What Bootstrap Creates

When you run the bootstrap prompt, the AI creates these files *inside your project* (not in this repo):

| Created file | Source in this repo | Purpose |
|---|---|---|
| `CLAUDE.md` | `modules/templates/claude_md.md` | AI instructions — embeds Session Protocol + Execution Protocol |
| `.claude/phases/project.md` | `modules/templates/project_md.md` | Engineering handoff (architectural decisions, phase status, progress log) |
| `.claude/phases/pendencias.md` | `modules/templates/pendencias_md.md` | Prioritized backlog with verifiable acceptance criteria |
| `.claude/agents/code-reviewer.md` | `modules/agents/code_reviewer.md` | Quality checklist + Known Bug Patterns (grows every session) |
| `.claude/agents/validator.md` | `modules/agents/validator.md` | Independent validation subagent — verifies with isolated context |
| `.claude/agents/arbitrator.md` | `modules/agents/arbitrator.md` | Resolves conflicts between validator judgment and mechanical evidence |
| `.claude/agents/security-reviewer.md` | `modules/agents/security_reviewer.md` | OWASP Top 10 checklist |
| `.claude/agents/red-team.md` | `modules/agents/red_team.md` | Adversarial security testing (conditional — if project has auth, payments, etc.) |
| `.claude/agents/blue-team.md` | `modules/agents/blue_team.md` | Defensive security verification (conditional — only if red-team exists) |
| `.claude/skills/*` (10 skills) | `modules/skills/*` | Inline process skills — copied entirely, one per protocol step |
| `.claude/rules/session-rules.md` | `modules/rules/session_rules.md` | Task limits, documentation quality, reasoning depth, scripts convention |
| `.claude/rules/evolution-policy.md` | `modules/rules/evolution_policy.md` | Evolution classification (FIX/DERIVED/CAPTURED) + auto-evolution boundaries |
| `.claude/rules/component-design.md` | `modules/rules/component_design.md` | Agent/skill/rule design: gap-declaration, Pushy Descriptions, vocabulary alignment |
| `.claude/agents/prd-sync-checker.md`, `criteria-enforcer.md`, `diff-pattern-extractor.md` | `modules/agents/prd_sync_checker.md`, etc. | Process agents — invoked as subagents; isolated context |
| `assets/examples/*` | `examples/*` | Quality reference for on-demand agent/skill creation (read-only copy) |
| `.claude/settings.json` | `modules/templates/settings_json.md` | Permissions + auto-formatting hooks |

### Why files in this repo reference things that don't exist here

Templates and protocols reference paths like `.claude/agents/code-reviewer.md` and `.claude/agents/prd-sync-checker.md`. These files do not exist in this repo — they are created during bootstrap inside the project folder.

Templates are blueprints. The paths they contain are the paths those files will have *after bootstrap creates them*. When reading a template, the context is the future project directory, not the framework root.

**Files created only during development** (not at bootstrap):
- `.claude/phases/done_tasks.md` — archive of completed tasks (created when first task completes)
- `.claude/rules/*.md` — domain-specific rules (created when 3+ patterns accumulate from the same domain; `session-rules.md`, `evolution-policy.md`, and `component-design.md` are created at bootstrap)
- `.claude/logs/*.md` — session logs (one per session, first created at end of session 0)

---

## How Modules Interact

The framework has five component types, each serving a distinct role:

```
TOOLKIT PROMPTS          TEMPLATES               PROTOCOLS
(human entry points)     (what to create)        (when things happen)

  /bootstrap ----------> claude_md.md -------.   session_protocol.md
  /prd_planning          project_md.md       |   execution_protocol.md
  /prd_change            pendencias_md.md    |        |
  /existing_adaptation   agent templates (6) |   embedded in project's
                              |              |   CLAUDE.md at bootstrap
                     created at bootstrap    |        |
                              |              |        v
                              v              |   PROCESS SKILLS
                        PROJECT FILES        |   (how to execute)
                        (instances in the    |   10 pre-built skills
                         bootstrapped        |   that implement each
                         project)            |   protocol step
                                             |        |
                        EXAMPLES             |   trigger at runtime
                        (copied to project's |        |
                         assets/examples/)   |        v
                              |              |   AGENTS (subagent .md)
                        read-only reference  |   code-reviewer, validator,
                        for on-demand        |   security-reviewer, etc.
                        creation             |        |
                                             |   consult at runtime
                                             |        v
                                             |   RULES (domain logic)
                                             |   created during development
                                             '--------'
```

**Dependency flow:** PRD --> bootstrap prompt reads PRD --> creates project files from templates. Templates embed protocols --> protocols trigger skills. Skills orchestrate agents --> agents consult rules. Examples are copied to the project as reference for creating new agents/skills on demand.

For the full architecture diagram and bootstrap pipeline details, see [Framework Architecture](docs/agentic_engineering_framework.md#framework-architecture) in the deep reference.

---

## Workflow

### 1. Create the PRD

Before bootstrapping, define what you're building:

**Run:** `/prd_planning [project-name]`

The AI asks questions about the product, then generates a structured PRD with modules, business rules, acceptance criteria, stack, and roadmap. The PRD is saved to `projects/[name]/assets/docs/prd.md`.

### 2. Bootstrap the project

Run Claude Code from the repo root:

**Run:** `/bootstrap [project-name]`

The AI reads the PRD and creates the entire project structure — see [What Bootstrap Creates](#what-bootstrap-creates) above for the full list of files and their sources.

### 3. Extract to its own repo

```bash
cd projects/[project-name]
git init
git remote add origin [your-repo-url]
git add -A && git commit -m "chore: bootstrap from agentic framework"
git push -u origin main
```

### 4. Develop

From now on, work from inside the project:

```bash
cd projects/[project-name]
claude
```

#### The development cycle

**You feed the backlog. The AI plans and executes.**

You don't command tasks directly. Instead, you describe what you need — with context — and the AI adds structured tasks to the backlog (`pendencias.md`). When a session starts, the AI reads the backlog and proposes a sprint.

```
You describe a need (with context)
  ↓
AI adds structured tasks to pendencias.md
  (acceptance criteria, complexity, dependencies)
  ↓
Session starts → AI reads backlog → proposes sprint
  ↓
You approve the sprint (or adjust)
  ↓
AI executes all tasks autonomously
  ↓
AI reports results → You review
```

#### How to describe a need

Give the AI context, not just commands. The more you describe the *what* and *why*, the better the AI structures the tasks:

```
Bad:  "Fix the financial dashboard"
Good: "The financial dashboard shows wrong profit values when a month
       has both paid and unpaid distributions. Currently it sums all
       transactions regardless of is_paid status. It should only count
       is_paid=true for the Caixa card, and show both paid+unpaid in
       the Gastos Comprometidos card. This is in the Financial module,
       Dashboard tab, Monthly Summary section."
```

The AI takes your description and creates tasks with:
- **Context** — why the task exists
- **State** — what the project looks like when the task starts
- **Constraints** — what to avoid
- **Acceptance criteria** — verifiable `VERIFY:`, `QUERY:`, `BUILD:` tags
- **Complexity** — routine, logic-heavy, or architecture/security

You can feed multiple needs in one session. The AI accumulates them in the backlog and proposes the best sprint order based on dependencies and priorities.

#### Session flow

```
START → Read docs → Propose sprint → Human approves →
  For each task:
    Phase A: Implement → Build → Tests → Commit →
    Phase B: Independent validation (graduated by complexity) → Report →
    Pick next task →
END → Update project.md → Update pendencias.md → Update agents/skills →
      Create session log → Commit
```

### 5. Evolve

The framework learns from your project:

- **Known Bug Patterns** grow every session (bugs fixed become future checks)
- **Rules files** capture domain logic (financial rules, database rules, etc.)
- **Agents and skills** evolve with discoveries (new security findings, new pitfalls)
- **Session logs** preserve the full history of decisions and reasoning

---

## What each command does

| Command | When to use | Input | Output |
|---------|-------------|-------|--------|
| `/prd_planning [name]` | Before starting any project | Your product description | Structured PRD document |
| `/bootstrap [name]` | Starting a new project | PRD at `assets/docs/prd.md` | Full project documentation structure |
| `/existing_project_adaptation [name]` | Upgrading an existing project | Existing codebase + partial docs | Upgraded docs + retroactive PRD |
| `/prd_change [name]` | Product scope changes | Change description | Updated PRD + propagation to engineering docs |

---

## Maturity Levels

| Level | Name | Human role | AI role |
|-------|------|-----------|---------|
| 1 | Autocomplete | Tests, integrates, reviews everything | Suggests code snippets |
| 2 | Autocreate | Tests and reports bugs | Creates complete code |
| 3 | Auto Execute | Approves plans and results | Implements, validates independently via subagents, reports with evidence |
| **4** | **Auto Pilot (recommended)** | **Approves sprint batches** | **Plans sprints, executes autonomously, stops only on exceptions** |

Start at Level 3. Move to Level 4 after 3-5 sessions when the validation loop is reliable.

---

## Key Concepts

**Acceptance Criteria** — Every task has verifiable criteria tagged with `BUILD:`, `VERIFY:`, `QUERY:`, `REVIEW:`, or `MANUAL:`. The AI uses these to validate its own work before reporting.

**Self-Validation Loop** — Two-phase validation after every implementation. Phase A (implementing agent): build → write tests → commit. Phase B (graduated by complexity): routine tasks use inline checklists; logic-heavy and architecture/security tasks spawn independent subagents (code-reviewer, validator, security-reviewer, Red Team, Blue Team) with isolated context — the agent that wrote the code never judges its own work. No task is reported as "done" without evidence.

**Known Bug Patterns** — Every bug fixed becomes a check in future reviews. The AI gets smarter every session. Max 20 patterns; when exceeding, domain patterns are promoted to rules files.

**Sprint Mode** — At Level 4, the AI proposes a batch of 3-5 tasks, the human approves once, and the AI executes all tasks without pausing between them. Stops only on persistent failures, ambiguity, or context degradation.

**Session Logs** — Permanent record of every session (what was done, decisions made, reasoning, git diff). Not read by the AI during normal sessions — exists for human reference and project history.

**Graduated Validation** — Validation depth scales with task risk via 2 routes. Route 1 (Inline): routine tasks (UI text, config changes) use inline checklists — low cost, fast. Route 2 (Subagent): logic-heavy and architecture/security tasks always spawn code-reviewer + validator subagents; security-relevant tasks adaptively add security-reviewer and Red Team/Blue Team based on risk level. The AI classifies each task and routes to the appropriate depth automatically.

**Anti-Bias Firewall** — When validation subagents are spawned, they receive the code diff, checklists, and acceptance criteria — but NOT the implementing agent's reasoning, session logs, or implementation plans. This context isolation prevents confirmation bias: the validating agent judges the code against the criteria without knowing WHY it was written that way.

---

## Deep Dive

For the full methodology, concepts, and design rationale:

**Read:** `docs/agentic_engineering_framework.md`

This is the tool-agnostic reference document (1900+ lines) covering: repository orientation, problem definition, maturity model, project structure, framework architecture (component types, bootstrap pipeline, two-repo architecture), document boundaries, session protocol, execution protocol, validation orchestration protocol, 6 evolutions, browser automation, MCP discovery, on-demand creation, task parallelism, test automation, security testing tiers, risks and mitigations, and principles.