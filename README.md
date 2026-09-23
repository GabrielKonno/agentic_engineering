# Agentic Engineering Framework v2.33.0

A meta-framework for preparing an AI agent's workspace — instructions, protocols, validation agents, process skills, domain rules, and quality examples — so the AI can develop software projects autonomously with structured validation.

**This repository does not contain application code.** It contains everything needed to *bootstrap* a project: document templates, process skills, validation agents, quality examples, and interactive prompts. You run the bootstrap once; it creates a self-contained project with its own AI instructions. From that point, the AI develops the project autonomously — implementing, validating via independent subagents, and reporting with evidence. The human approves and directs.

---

## What This Framework Does

This repo is a **factory for AI-ready projects**. It reads your product requirements and generates a complete AI workspace:

```
  YOUR PRD               FRAMEWORK MODULES               BOOTSTRAPPED PROJECT
  (what to build)        (templates + agents +            (ready for development)
                          rules + skills + examples)
  +-------------+        +--------------------+           +---------------------+
  |  prd.md     |------->| Bootstrap Prompt   |---------->| CLAUDE.md           |
  +-------------+        |                    |           | project.md          |
                         | Reads:             |           | pendencias.md       |
                         |  - 8 doc templates |           | 7-10 agent .md files|
                         |  - 10 agent files  |           | 12-15 process skills|
                         |  - 5 rules files   |           | 3-5 rules files     |
                         |  - 15 skills       |           | examples/ (copy)    |
                         |  - examples/       |           | settings.json       |
                         +--------------------+           +---------------------+
                                                                    |
                                                          cd projects/my-project
                                                          claude
```

> The **Reads** column is the full framework set. The **Output** column is a RANGE because of
> **tier-gating by risk profile** (`prototype` → `production-financial`): the low number is the
> baseline every project gets (12 lifecycle skills, 3 core rules files), the high number is the
> FULL set, which a `production` project already receives — `bootstrap.md` gates
> codebase-audit/skill-gate at internal-tool+ and framework-audit/ops-rules/quality-budgets at
> **production+**, so the SKILL and RULES sets are complete from `production` upward. `production-financial` still
> adds three things of its own — reconciliation queries, mandatory red-team on money paths, and a
> tighter framework-audit cadence — so it is the ceremony that differs at that tier, not the
> component set (`/audit` 2026-09-03 P-24). A `prototype` gets the lean core (no audits/ops/budgets/CI),
> while `production`+ gets everything. See `docs/modules/rules/session_rules.md` → *Risk profile & ceremony tiers*.

### Session modes

The framework has 5 session modes in the framework repo, plus project-repo execution after bootstrap:

**Framework repo** (this repo) — 5 session modes, each activated by a slash command:
- `/prd_planning` — Create a PRD interactively
- `/prd_change` — Modify an existing PRD with impact analysis
- `/bootstrap` — Create project structure from PRD (Session 0)
- `/existing_project_adaptation` — Upgrade existing project to framework
- `/maintenance` — Edit framework docs, examples, CLAUDE.md, this repo's own `.claude/` runtime, and `assets/docs/` records

Plus one utility, not a session mode:
- `/audit` — read-only integrity check across 17 dimensions via 6 parallel agents; writes and commits its dated report under `assets/docs/` — plus, in verification mode, one appended row in its own defect-series table

**Project repo** (inside the project) — The AI reads the project's own CLAUDE.md, follows the Session Protocol, proposes sprints, implements tasks, validates via subagents, and reports with evidence. The framework repo is no longer involved.

### How development works (inside a bootstrapped project)

```
Human defines task with criteria --> AI implements -->
AI self-reviews --> AI tests (browser + DB) -->
AI verifies criteria --> AI reports with evidence -->
Human approves or redirects
```

At Level 4 (Auto Pilot), the AI proposes sprints, executes 3-5 tasks autonomously, and stops only on exceptions. The human approves the batch, not individual tasks.

At Level 5 (Backlog Loop — opt-in, per session), the AI stops implementing and becomes an ORCHESTRATOR: it works through a whole approved backlog segment — or, in continuous mode, keeps taking every task that passes an approved admission policy — delegating implementation to isolated subagents and closing each task to disk before opening the next. See [Maturity Levels](#maturity-levels) and [Autonomous Loop](#key-concepts).

---

## Quick Start

### Setup: clone or fork?

The framework is designed to be customized over time — `examples/` grows with your patterns, new agent/skill templates get added for your domain, rules files capture team conventions. The `/maintenance` mode exists specifically for editing framework docs and examples.

- **Fork (recommended)** — if you intend to accumulate your own examples/templates/rules, contribute back, or use the framework across multiple projects over time. Fork on GitHub, then:
  ```bash
  git clone [your-fork-url] ~/agentic_engineering
  cd ~/agentic_engineering
  git remote add upstream [original-repo-url]
  # later: git fetch upstream && git merge upstream/main   # pull core updates
  ```
- **Clone** — if you just want to try the framework once or consume it without customizing. `git clone [url]` and you're done. You can always convert to a fork later.

Either way, `projects/` stays gitignored — your project repos are always separate from the framework repo.

### New project (greenfield)

```
1. Clone or fork this repo (see above)
2. Run Claude Code from the repo root: claude
3. Create a PRD: /prd_planning my-project
4. Bootstrap the project: /bootstrap my-project
5. Attach your remote and push (see Workflow below)
```

After bootstrap, the project already has its own git repo with an initial `chore: bootstrap from agentic framework` commit. The framework repo is no longer needed for this project — development happens entirely from within the project folder.

### Existing project (has code, needs framework)

```
1. Clone or fork this repo (see above)
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
| `/maintenance` | (none) | Edit framework docs, examples, CLAUDE.md, this repo's own `.claude/` runtime, `assets/docs/` records |
| `/audit` | (none) | Read-only integrity check across 17 dimensions via 6 parallel agents; writes and commits its dated report to `assets/docs/` (plus, in verification mode, one row in its own defect-series table) |

**Alternative:** The bootstrap logic lives in `.claude/commands/bootstrap.md` and can be adapted for other AI tools.

---

## Repository Structure

```
agentic_engineering/
├── CLAUDE.md                           ← Meta-project contract (Claude Code reads this)
├── .gitignore                          ← Ignores projects/ folder
├── .gitattributes                      ← Keeps *.sh LF
├── README.md                           ← You are here
│
├── .claude/                            ← Active config for this repo (makes the slash commands work)
│   ├── commands/                       ← 6 slash commands: /bootstrap, /prd_planning, /prd_change, /existing_project_adaptation, /maintenance, /audit
│   ├── rules/                          ← component-design.md (consulted during /maintenance when editing agents/skills/rules)
│   ├── skills/                         ← cross-cutting-analysis (runtime skill used during PRD sessions)
│   ├── scripts/                        ← d16-gate.sh (project-information isolation gate) + probe-sandbox.sh (where a check that WRITES, a negation proof or a persisted script executes — never a read-only scan) — both run by /maintenance and /audit
│   ├── docs/                           ← Framework notes and ideas (git-ignored, not copied to projects)
│   └── settings.json                   ← Claude Code settings
│
├── docs/
│   ├── agentic_engineering_framework.md    ← Core concepts (read this to understand the methodology)
│   │
│   ├── modules/                            ← Single source of truth (v2.33.0)
│   │   ├── templates/                      ← Document and config templates (8, incl. the frontmatter and rules-scope guards)
│   │   ├── agents/                         ← Agent templates (10 agents)
│   │   ├── rules/                          ← Rules templates (5 rules files)
│   │   └── skills/                         ← 15 pre-built skills (12 lifecycle + 3 tier-gated)
│   │
├── examples/                           ← Quality reference templates (copied to projects)
│   ├── README.md                       ← Conventions for creating agents, skills and rules
│   ├── agents/                         ← 20 agent templates (quality, domain, ops, security, compliance)
│   ├── skills/                         ← 9 skill templates (stack, domain, process)
│   └── rules/                          ← 11 rules templates (auth, compliance, i18n, scheduling, resilience, integration, etc.)
│
├── assets/                             ← Framework-layer records (never copied to projects)
│   └── docs/                           ← /audit reports + upstream lineage docs
│
└── projects/                           ← Local workspace (git-ignored)
    └── [project-name]/                 ← Each project gets its own git repo
```

**Note on `.claude/` vs `docs/modules/`:** the framework repo's own `.claude/` is minimal — only what it needs to run its own 5 session modes + 1 utility. The 15 process skills, 10 agent templates and 5 rules templates live under `docs/modules/` as **templates**, and each project receives a TIER-GATED SUBSET of them — 12 skills + 3 rules at the baseline, the full set from `production` upward (`bootstrap.md` gates codebase-audit/skill-gate at internal-tool+ and framework-audit/ops-rules/quality-budgets at production+) — copied into that project's `.claude/`, never into the framework's own. This asymmetry is intentional: the framework repo has no code to review, so it doesn't need `.claude/agents/` itself.

---

## What Bootstrap Creates

When you run the bootstrap prompt, the AI creates these files *inside your project* (not in this repo):

| Created file | Source in this repo | Purpose |
|---|---|---|
| `CLAUDE.md` | `modules/templates/claude_md.md` | AI instructions — orchestrates skills that implement Session Protocol + Execution Protocol |
| `.claude/phases/project.md` | `modules/templates/project_md.md` | Engineering handoff (architectural decisions, phase status, progress log) |
| `.claude/phases/pendencias.md` | `modules/templates/pendencias_md.md` | Prioritized backlog with verifiable acceptance criteria |
| `.claude/phases/done_tasks.md` | (written directly by bootstrap Step 4 — no template) | Destination for completed tasks — `pendencias-updater` moves them here at session end |
| `.claude/agents/code-reviewer.md` | `modules/agents/code_reviewer.md` | Quality checklist + Known Bug Patterns (grows every session) |
| `.claude/agents/validator.md` | `modules/agents/validator.md` | Independent validation subagent — verifies with isolated context |
| `.claude/agents/arbitrator.md` | `modules/agents/arbitrator.md` | Resolves conflicts between validator judgment and mechanical evidence |
| `.claude/agents/security-reviewer.md` | `modules/agents/security_reviewer.md` | OWASP Top 10 checklist |
| `.claude/agents/red-team.md` | `modules/agents/red_team.md` | Adversarial security testing (conditional — if project has auth, payments, etc.) |
| `.claude/agents/blue-team.md` | `modules/agents/blue_team.md` | Defensive security verification (conditional — only if red-team exists) |
| `.claude/skills/*` (12–15 skills, tier-gated) | `modules/skills/*` | Lifecycle process skills (12, incl. `autonomous-loop`) + codebase-audit/framework-audit/skill-gate (tier-gated) |
| `.claude/rules/session-rules.md` | `modules/rules/session_rules.md` | Task limits, documentation quality, reasoning depth, scripts convention |
| `.claude/rules/evolution-policy.md` | `modules/rules/evolution_policy.md` | Evolution classification (FIX/DERIVED/CAPTURED) + auto-evolution boundaries |
| `.claude/rules/component-design.md` | `modules/rules/component_design.md` | Agent/skill/rule design: gap-declaration, Pushy Descriptions, vocabulary alignment |
| `.claude/agents/prd-sync-checker.md`, `criteria-enforcer.md`, `diff-pattern-extractor.md` | `modules/agents/prd_sync_checker.md`, etc. | Process agents — invoked as subagents; isolated context |
| `assets/examples/*` | `examples/*` | Quality reference for on-demand agent/skill creation (read-only copy) |
| `.claude/settings.json` | `modules/templates/settings_json.md` | Permissions + owner statusline + formatter and skill-gate hooks |
| `scripts/check-agent-frontmatter.mjs` | `modules/templates/check_agent_frontmatter.md` | Component-registry liveness guard — invalid agent/skill frontmatter fails loud instead of silently vanishing (also wired as a CI `guards` stage) |
| `scripts/check-rules-paths.mjs` | `modules/templates/check_rules_paths.md` | Rules load-scope guard — every rule carries `paths:` (loaded only when a matching file is read) or is declared always-loaded; fails on the ignored `applies_to:` key and on an unscoped, undeclared rule, and REPORTS dead globs without failing (CI `guards` stage) |
| `.claude/skills/codebase-audit/` *(internal-tool+)* | `modules/skills/codebase-audit/` | MACRO axis — periodic system health audit |
| `.claude/phases/metrics.md` *(internal-tool+)* | `modules/templates/metrics_md.md` | Code health time series (one row per audit) |
| `.claude/skills/skill-gate/` + `.claude/agents/skill-reviewer.md` + `.claude/drafts/` *(internal-tool+)* | `modules/skills/skill-gate/`, `modules/agents/skill_reviewer.md` | Creation gate — new skills/rules drafted, blind-reviewed, and promoted (never self-approved) |
| `.claude/skills/framework-audit/` *(production+)* | `modules/skills/framework-audit/` | Meta-loop — periodic process blind-spot audit |
| `.claude/phases/framework-metrics.md` *(production+)* | `modules/templates/framework_metrics_md.md` | Process health time series (one row per meta-audit) |
| `.claude/rules/ops-rules.md` *(production+)* | `modules/rules/ops_rules.md` | Operate/lifecycle dimension checklist |
| `.claude/rules/quality-budgets.md` *(production+)* | `modules/rules/quality_budgets.md` | Quality caps + code-reviewer delta gate |

### Why files in this repo reference things that don't exist here

Templates and protocols reference paths like `.claude/agents/code-reviewer.md` and `.claude/agents/prd-sync-checker.md`. These files do not exist in this repo — they are created during bootstrap inside the project folder.

Templates are blueprints. The paths they contain are the paths those files will have *after bootstrap creates them*. When reading a template, the context is the future project directory, not the framework root.

**Files created only during development** (not at bootstrap):
- `.claude/rules/*.md` — domain-specific rules (created when 3+ patterns accumulate from the same domain; `session-rules.md`, `evolution-policy.md`, and `component-design.md` are created at bootstrap)
- `.claude/logs/*.md` — session logs (one per session, first created at end of session 0)

---

## How Modules Interact

The framework has six component types, each serving a distinct role:

```
TOOLKIT PROMPTS          TEMPLATES               PROCESS SKILLS
(human entry points)     (what to create)        (how to execute)

  /bootstrap ----------> claude_md.md -------.   12 lifecycle skills (+3 tier-gated)
  /prd_planning          project_md.md       |   implement Session Protocol
  /prd_change            pendencias_md.md    |   + Execution Protocol
  /existing_adaptation   agent templates (10)|        |
                         rules templates (5) |   copied to project
                              |              |   at bootstrap
                     created at bootstrap    |        |
                              |              |        v
                              v              |   AGENTS (subagent .md)
                        PROJECT FILES        |   code-reviewer, validator,
                        (instances in the    |   security-reviewer, etc.
                         bootstrapped        |        |
                         project)            |   consult at runtime
                                             |        |
                        EXAMPLES             |        v
                        (copied to project's |   RULES (domain logic)
                         assets/examples/)   |   created during development
                              |              '--------'
                        read-only reference
                        for on-demand
                        creation
```

**Dependency flow:** PRD --> bootstrap prompt reads PRD --> creates project files from templates. Skills implement protocol concepts (Session Protocol, Execution Protocol). Skills orchestrate agents --> agents consult rules. Examples are copied to the project as reference for creating new agents/skills on demand.

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

### 3. Attach your remote and push

Bootstrap already initializes the project as a git repo and creates the initial `chore: bootstrap from agentic framework` commit. You only need to attach your remote and push:

```bash
cd projects/[project-name]
git remote add origin [your-repo-url]
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
       records regardless of their settled/unsettled status. It should only
       count settled ones for the first summary card, and show both settled
       and unsettled in the second. This is in the reporting module,
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

At **Level 5** the flow changes shape. After you approve a loop plan (segment mode) or an admission policy (continuous mode), the main agent orchestrates instead of implementing:

```
START → Propose loop plan (phases cut by dependency, not by a task count) → Human approves ONCE →
  For each phase:
    For each task: dispatch implementer subagent → verify its work from DISK →
                   validate (geometry by risk) → commit → close the task to disk
    Phase boundary: task-closure check → 1-line report per task → next phase (no re-approval)
END (segment done) → Final report → session-end ONCE
```

A stop mid-segment writes a `LOOP CONTINUATION` marker in `project.md`; the next session resumes at the next phase with no new approval.

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
| `/maintenance` | Changing the framework itself, or absorbing lessons projects recorded | An audit report or pending `framework-evolution-*.md` docs | Framework edits + write-back and receipts in the audit report |
| `/audit` | After an upstream absorption, before a MINOR/MAJOR bump, on request, or after a `/maintenance` session applies an audit batch AND evidence from OUTSIDE the loop is waiting (a pending project evolution doc, or a HIGH tagged `[observed in use]`) | The repository (and the last report, in verification mode) | Its dated report in `assets/docs/` (+1 defect-series row in verification mode) with stable finding IDs |

---

## Maturity Levels

| Level | Name | Human role | AI role |
|-------|------|-----------|---------|
| 1 | Autocomplete | Tests, integrates, reviews everything | Suggests code snippets |
| 2 | Autocreate | Tests and reports bugs | Creates complete code |
| 3 | Auto Execute | Approves plans and results | Implements, validates independently via subagents, reports with evidence |
| **4** | **Auto Pilot (recommended)** | **Approves sprint batches** | **Plans sprints, executes autonomously, stops only on exceptions** |
| 5 | Backlog Loop (opt-in, per session) | Approves a whole backlog segment once — or an admission policy (continuous mode) — and supervises checkpoints | Orchestrates: delegates implementation to subagents, verifies from disk, closes each task to disk, resumes across sessions |

Start at Level 3. Move to Level 4 after 3-5 sessions when the validation loop is reliable. Use Level 5 per session, on top of Level 4, for backlogs of mostly small/medium independent tasks — it never activates by itself, and large or architecture/security tasks stay out of it.

---

## Key Concepts

**Acceptance Criteria** — Every task has verifiable criteria tagged with `BUILD:`, `VERIFY:`, `QUERY:`, `REVIEW:`, or `MANUAL:`. The AI uses these to validate its own work before reporting.

**Self-Validation Loop** — Two-phase validation after every implementation. Phase A (implementing agent): build → write tests → commit. Phase B (graduated by complexity): routine tasks use inline checklists; logic-heavy and architecture/security tasks spawn independent subagents (code-reviewer, validator, security-reviewer, Red Team, Blue Team) with isolated context — the agent that wrote the code never judges its own work. No task is reported as "done" without evidence.

**Known Bug Patterns** — Every bug fixed becomes a check in future reviews. The AI gets smarter every session. Max 20 patterns; when exceeding, domain patterns are promoted to rules files.

**Sprint Mode** — At Level 4, the AI proposes a batch of 3-5 tasks, the human approves once, and the AI executes all tasks without pausing between them. Stops only on persistent failures, ambiguity, or context degradation.

**Autonomous Loop (Level 5)** — An opt-in mode where the main agent orchestrates instead of implementing, so its context holds sprint state rather than implementation reasoning and survives long sessions.
- **How to start it:** ask for it ("run the backlog in loop mode", "autonomous mode", "continuous mode") or accept the loop offer in a sprint proposal. An ambiguous request gets ONE question: segment or continuous.
- **Segment mode:** you approve a fixed task list once; the AI cuts it into phases by dependency and resource conflicts, runs every phase, and reports at each boundary. If the session ends mid-segment, a `LOOP CONTINUATION` marker lets the next session resume with no new approval. Say "cancel the loop" to revoke.
- **Continuous mode:** you approve an ADMISSION POLICY instead of a list. The AI re-reads the backlog at every task boundary and executes every task that passes it — including tasks you register mid-session. Tasks the AI discovers enter only in a capped class; large or architecture/security tasks are held for you. A checkpoint digest every 10 tasks and a discovery brake keep you supervising. An empty queue is idle, not an end; re-entry across sessions uses the native `/loop /sprint-proposer continuous`. Say "cancel continuous mode" to revoke.
- **What it never does:** activate by itself, relax the validation geometry after a streak of green, run an audit autonomously, or run an agent that mutates the working tree in parallel with one that reads it.

**Model by Risk Class** — Every agent declares its own `model:` in frontmatter, decided by what its report produces and written once. A component whose verdict gates a commit stays at `inherit` (the orchestrator's model); one that only extracts or compares runs a cheaper tier, as does the breadth pass of an audit fan-out. The field is written EXPLICITLY even when it is `inherit`, because an absent field and a decided one are indistinguishable — and the whole point is that `grep -rn "^model:"` answers which model reviewed which commit. Skills never carry it: a skill loads into the current context and never spawns.

**The Owner’s Meter** — A project’s `settings.json` ships a statusline printing the model, the context-window percentage and the session cost. The framework sets NO numeric context gate for the AI: a model cannot observe its own context usage, and an instructed estimate is confabulation. In Level-5 loop mode the `autonomous-loop` skill therefore forbids self-estimated percentages and tells the orchestrator to ask the OWNER for the real meter — this is that meter, rendered for a human and never entering the AI’s judgement.

**Review Receipts** — A reviewer verdict counts only when its final report is saved under `.claude/logs/review-reports/` and cited by a line in that folder's receipts ledger. Before a migration reaches production or the deploy PR opens, every code commit in the range must carry a receipt or an explicit owner exemption; the AI checks this and blocks the deploy otherwise.

**Session Logs** — Permanent record of every session (what was done, decisions made, reasoning, git diff). Not read by the AI during normal sessions — exists for human reference and project history.

**Graduated Validation** — Validation depth scales with task risk via 2 routes. Route 1 (Inline): routine tasks (UI text, config changes) use inline checklists — low cost, fast. Route 2 (Subagent): logic-heavy and architecture/security tasks always spawn code-reviewer + validator subagents; security-relevant tasks adaptively add security-reviewer and Red Team/Blue Team based on risk level. The AI classifies each task and routes to the appropriate depth automatically.

**Anti-Bias Firewall** — When validation subagents are spawned, they receive the code diff, checklists, and acceptance criteria — but NOT the implementing agent's reasoning, session logs, or implementation plans. This context isolation prevents confirmation bias: the validating agent judges the code against the criteria without knowing WHY it was written that way.

---

## Deep Dive

For the full methodology, concepts, and design rationale:

**Read:** `docs/agentic_engineering_framework.md`

This is the tool-agnostic reference document (1900+ lines) covering: repository orientation, problem definition, maturity model, project structure, framework architecture (component types, bootstrap pipeline, two-repo architecture), document boundaries, session protocol, execution protocol, validation orchestration protocol, 6 evolutions, browser automation, MCP discovery, on-demand creation, task parallelism, test automation, security testing tiers, risks and mitigations, and principles.