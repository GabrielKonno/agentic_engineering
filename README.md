# Agentic Engineering Framework v1.4.0

A methodology for AI-assisted software development where the AI implements, validates, and reports with evidence — and the human approves and directs.

Instead of the human testing in the browser, taking screenshots, and reporting bugs, the AI runs a two-phase validation loop — implements and commits, then spawns independent subagents for review and verification with isolated context. The human exits the "test and report" loop and enters the "approve and direct" loop.

---

## How it works

```
Human defines task with criteria → AI implements →
AI self-reviews → AI tests (browser + DB) →
AI verifies criteria → AI reports with evidence →
Human approves or redirects
```

At Level 4 (Auto Pilot), the AI proposes sprints, executes 3-5 tasks autonomously, and stops only on exceptions. The human approves the batch, not individual tasks.

---

## Quick Start

### New project (greenfield)

```
1. Clone this repo
2. Create a PRD for your project (use the PRD planning prompt)
3. Run Claude Code from the repo root
4. Send the session0 bootstrap prompt
5. Extract the project to its own repo
```

### Existing project (has code, needs framework)

```
1. Clone this repo
2. Open docs/toolkit_prompt/existing_project_adaptation_prompt.md — copy its content
3. Run Claude Code from your project root
4. Paste the adaptation prompt — the AI reads your codebase and creates/upgrades docs
```

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
│   ├── bootstrap_claude/
│   │   └── session0_bootstrap_prompt.md    ← Bootstrap prompt for Claude Code
│   │
│   ├── bootstrap_antigravity/
│   │   └── session0_bootstrap_antigravity.md ← Bootstrap prompt for Antigravity
│   │
│   └── toolkit_prompt/
│       ├── prd_planning_prompt.md              ← Create a PRD from scratch
│       ├── prd_change_prompt.md                ← Modify an existing PRD
│       ├── existing_project_adaptation_prompt.md ← Adapt existing project
│       └── cross_tool_migration_prompt.md      ← Migrate between tools
│
├── examples/                           ← Quality reference templates (copied to projects)
│   ├── examples_instructions.md        ← Conventions for creating agents/skills
│   ├── agents/                         ← 10 agent templates (quality, domain, ops, security)
│   ├── skills/                         ← 9 skill templates (stack, domain, process)
│   └── rules/                          ← 3 rules templates (multi-tenancy, e-commerce, auth)
│
└── projects/                           ← Local workspace (git-ignored)
    └── [project-name]/                 ← Each project gets its own git repo
```

---

## Workflow

### 1. Create the PRD

Before bootstrapping, define what you're building. Use the PRD planning prompt with any AI chat tool (Claude.ai, ChatGPT, etc.):

**Open:** `docs/toolkit_prompt/prd_planning_prompt.md`

The AI asks questions about the product, then generates a structured PRD with modules, business rules, acceptance criteria, stack, and roadmap. Save the result as `projects/[name]/assets/docs/prd.md`.

### 2. Bootstrap the project

Run Claude Code from the repo root and send the bootstrap prompt:

**Open:** `docs/bootstrap_claude/session0_bootstrap_prompt.md`

The AI reads the PRD and creates the entire project structure:

| Created | Purpose |
|---------|---------|
| `CLAUDE.md` | Session Protocol + Execution Protocol (how the AI works in this project) |
| `project.md` | Handoff document (decisions, status, session history) |
| `pendencias.md` | Prioritized backlog with verifiable acceptance criteria |
| `code-reviewer.md` | Quality checklist + Known Bug Patterns (grows every session) |
| `security-reviewer.md` | OWASP Top 10 checklist |
| `red-team.md` / `blue-team.md` | Adversarial security testing (if project has auth, payments, etc.) |
| `validator.md` | Independent validation agent — verifies implementation with isolated context |
| `arbitrator.md` | Resolves conflicts between validator judgment and mechanical evidence |
| `.claude/settings.json` | Permissions + auto-formatting hook (Claude Code only) |
| `assets/examples/` | Agent/skill templates for future reference |
| `.claude/logs/` | Session log directory |

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

## What each prompt does

| Prompt | When to use | Input | Output |
|--------|-------------|-------|--------|
| **PRD Planning** | Before starting any project | Your product description | Structured PRD document |
| **Session 0 Bootstrap** | Starting a new project | PRD at `assets/docs/prd.md` | Full project documentation structure |
| **Existing Project Adaptation** | Upgrading an existing project | Existing codebase + partial docs | Upgraded docs + retroactive PRD |
| **PRD Change** | Product scope changes | Change description | Updated PRD + propagation to engineering docs |
| **Cross-Tool Migration** | Switching between Claude Code and Antigravity | Existing project setup | Migrated setup in target tool's format |

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

---

## Deep Dive

For the full methodology, concepts, and design rationale:

**Read:** `docs/agentic_engineering_framework.md`

This is the tool-agnostic reference document (1500+ lines) covering: problem definition, maturity model, project structure, document boundaries, session protocol, execution protocol, validation orchestration protocol, 6 evolutions, browser automation, MCP discovery, on-demand creation, task parallelism, test automation, security testing tiers, risks and mitigations, and principles.