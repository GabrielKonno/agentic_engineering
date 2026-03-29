# Session 0 — Project Bootstrap (Antigravity)

Send this as a prompt to a Google Antigravity agent from the framework repository root.
The project will be created inside `projects/[project-name]/`.

**Before starting:**
1. Create the project folder: `projects/[project-name]/`
2. Place the PRD at `projects/[project-name]/assets/docs/prd.md` (create one using `docs/toolkit_prompt/prd_planning_prompt.md`)
3. If no PRD exists, the session still works — PRD-derived sections will be marked "to be defined"

Antigravity-specific: This prompt leverages native Planning Mode, Browser Subagent, and multi-agent capabilities. No external Playwright MCP needed.

---

## Prompt starts below. Copy everything from here.

---

## Session 0 — Bootstrap from PRD

**Project folder:** `projects/[CONFIGURE: project-name]` — replace this placeholder before sending.

This session creates the project's documentation structure and configures tools inside the project folder. NO application code will be written. Only documentation and configuration.

**Output language:** All documents (GEMINI.md, AGENTS.md, project.md, pendencias.md) are written in English for consistency. Conversational output (reports, questions, summaries) should be in [CONFIGURE: your preferred language, e.g., "English", "Brazilian Portuguese", "Spanish"]. Replace this placeholder before sending.

Execute in order. Report results after each part.

---

### Step 1 — Read the PRD

If `projects/[project-name]/assets/docs/prd.md` exists, read it completely. Extract:
- Product name and description
- Target audience
- MVP modules/features with priorities
- Features out of scope
- Stack (or "to be defined")
- Constraints (deadline, compliance, platform)
- Business rules per module
- External integrations needed
- Business model

If `projects/[project-name]/assets/docs/prd.md` does not exist, skip this step. Use information from the user to populate documents. Mark unknown sections as "to be defined".

---

### Step 1.5 — Copy examples to project

Copy the framework's examples directory into the project for future reference:

```bash
cp -r examples/ projects/[project-name]/assets/examples/
```

These examples serve as quality reference for creating agents, skills, and rules — both during this bootstrap AND during on-demand creation in future sessions. They are read-only templates, not active configuration.

---

### Step 2 — Create GEMINI.md

**All files from Step 2 onwards are created inside `projects/[project-name]/`.** Paths in this prompt (e.g., `GEMINI.md`, `.antigravity/phases/`) are relative to the project root.

Antigravity reads `GEMINI.md` as its primary context file. This is the equivalent of CLAUDE.md.

**If GEMINI.md already exists:** Do NOT overwrite. Compare the existing content with the template. Add missing sections. Report what was added/changed.

**If GEMINI.md does not exist:** Read the template at `docs/modules/templates/gemini_md.md`. Adapt with PRD data:
- Fill Project Overview from PRD (name, description, modules, owner)
- Fill Architecture from PRD section 5
- Fill Key Patterns based on the stack
- Fill Build Order from PRD module dependencies
- Fill Design System reference
- Fill Environment Variables from stack requirements
- Leave Commands, Skills empty (filled in later steps)

Create the file at the project root as `GEMINI.md`.

**The template references process skills** (`.antigravity/skills/prd-sync-checker/SKILL.md`, etc.) in the Session Protocol. These are copied in Step 5.7 below.

---

### Step 3 — Create AGENTS.md (cross-tool compatibility)

Antigravity v1.20.3+ reads both `GEMINI.md` and `AGENTS.md`. Create `AGENTS.md` at the project root so other tools (Cursor, Claude Code, Codex) can also benefit from the project rules:

**If AGENTS.md already exists:** Do NOT overwrite. Verify it references GEMINI.md for the full context.

**If it does not exist:** Create it:

```markdown
# AGENTS.md

This project uses the Agentic Engineering Framework.
Primary configuration is in GEMINI.md (Antigravity-native).

For any AI agent working on this project:
- Read GEMINI.md for full Session Protocol, Execution Protocol, and project context
- Read .antigravity/phases/project.md for current status and decisions
- Read .antigravity/phases/pendencias.md for the task backlog
- Read .antigravity/rules/*.md for domain-specific rules
- Read .antigravity/skills/*/SKILL.md for task-specific workflows

All documents are in English. Conversational output should follow the language preference in GEMINI.md.
```

---

### Step 4 — Create project.md

**If `.antigravity/phases/project.md` already exists:** Do NOT overwrite. Add a new index row to the Progress Log table. Verify required sections exist.

**If it does not exist:** Read the template at `docs/modules/templates/project_md.md`. Adapt with PRD data:
- Replace `{CONFIG_DIR}` with `.antigravity/`
- Replace `{CONFIG_FILE}` with `GEMINI.md`
- Fill Overview (including `**PRD version:** v1.0.0`), Architectural Decisions, Module Relationships, Project Phases from PRD
- Add Session 0 row to Progress Log index table: `| 0 (Bootstrap) | [date] | PRD analyzed, GEMINI.md + AGENTS.md + agents created | — |`

Create at `.antigravity/phases/project.md`.

---

### Step 5 — Create pendencias.md

**If `.antigravity/phases/pendencias.md` already exists:** Do NOT overwrite. Verify items have acceptance criteria tags.

**If it does not exist:** Read the template at `docs/modules/templates/pendencias_md.md`. Adapt with PRD data:
- Replace `{CONFIG_FILE}` with `GEMINI.md`
- Fill tasks from Build Order with full Context/State/Constraints/Complexity/Criteria
- Note: `VERIFY:` criteria use Browser Subagent (native), not Playwright MCP

Create at `.antigravity/phases/pendencias.md`.

---

### Step 5.7 — Copy pre-built process skills

Copy the framework's process skills to the project:

```bash
cp -r docs/modules/skills/* projects/[project-name]/.antigravity/skills/
```

After copying, translate `.claude/` paths to `.antigravity/` in all skill files:

```bash
find projects/[project-name]/.antigravity/skills -type f \( -name "SKILL.md" -o -name "*.sh" \) -exec sed -i 's/\.claude\//\.antigravity\//g' {} \;
```

This copies 10 process skills that implement the Session Protocol and Execution Protocol:
- **Session start:** prd-sync-checker, sprint-proposer
- **Before implementing:** criteria-enforcer
- **During implementation:** validation-orchestrator
- **Session end:** diff-pattern-extractor, project-md-updater, pendencias-updater, config-file-updater, rules-agents-updater, session-log-creator

Register all 10 in GEMINI.md "Skills" section under "Process skills (copied from framework)".

---

### Step 6 — Configure MCP Servers

Antigravity has native Browser Subagent, so Playwright MCP is NOT needed. Focus on data and repo tools.

**6a. Search for available MCPs:**

**Source 1 — Antigravity MCP settings UI:**
Open Antigravity Settings → MCP Servers → browse available servers.

**Source 2 — npm registry (fallback):**
```bash
npm search @modelcontextprotocol/server 2>/dev/null | head -20
npm search mcp-server 2>/dev/null | head -20
```

**6b. Decide which to install** based on the project stack:

| Stack includes | Recommended MCP | How to configure |
|---------------|----------------|-----------------|
| Supabase | Supabase MCP | Add in Antigravity MCP settings |
| PostgreSQL | PostgreSQL MCP | Add in MCP settings |
| GitHub repo | GitHub MCP | Add in MCP settings |
| Other service | Search in sources 1-2 | Assess need + security |

**6c. Security validation (MANDATORY before installing any MCP):**

```
□ Trusted source? (official org, verified publisher, >10k downloads)
□ Actively maintained? (published within last 6 months)
□ Reasonable permissions? (read-only by default)
□ Open source? (public repo with auditable code)
□ Actually relevant? (solves concrete problem for this stack)
```

If any fails: do not install, log reason. If uncertain: ASK user.

**Rules:** Max 4 MCPs on day 1 (no Playwright needed). Only install if resource exists.

---

### Step 7 — Discover and install Skills

Antigravity skills live in `.antigravity/skills/[name]/` with `SKILL.md` and optional `scripts/` directory.

**7a. Search:**

**Source 1 — Plugin marketplace (if available):**
Browse for skills relevant to the stack via Antigravity or web search.

**Source 2 — CLI (cross-tool skills):**
```bash
npx claude-code-templates@latest --list-skills 2>/dev/null || echo "CLI not available"
```
Note: claude-code-templates skills are markdown files adaptable for Antigravity's skill format.

**7b. Validation:**
- ✅ Focuses on QUALITY/PERFORMANCE of the stack → install
- ❌ Focuses on design/architecture OPINION → do NOT install
- ❌ Contradicts PRD or GEMINI.md patterns → do NOT install

Register in GEMINI.md "Skills" section. No skill found? That is fine — skills are optional.

---

### Steps 8-12 — Create skills (agents)

**Before creating any skill in the steps below:** read `assets/examples/examples_instructions.md` for conventions (frontmatter, structure, output format, invocation type). Then check if a relevant example exists in `assets/examples/agents/` or `assets/examples/skills/`. If found, use as a structural template — adapt to this project's stack and domain.

Note: In Antigravity, all review/validation agents use the skill format (`.antigravity/skills/[name]/SKILL.md`) with `invocation: subagent` frontmatter. They are spawned via Agent Manager.

### Step 8 — Create code-reviewer skill

**If `.antigravity/skills/code-reviewer/SKILL.md` already exists:** Do NOT overwrite. Verify it has Known Bug Patterns and Architecture Patterns sections. Add them if missing.

**If it does not exist:** Read the template at `docs/modules/templates/code_reviewer.md`. Adapt:
- Replace `{CONFIG_DIR}` with `.antigravity/`
- Replace `{CONFIG_FILE}` with `GEMINI.md`
- Replace `{SUBAGENT_TOOL}` with `Agent Manager`
- Create at `.antigravity/skills/code-reviewer/SKILL.md`

**Creation eval (DEFERRABLE):** See template for eval scenarios. Use Agent Manager for spawning.

### Step 9 — Create security-reviewer skill

Universal skill for ALL projects. Read `docs/modules/templates/security_reviewer.md`. Adapt:
- Replace `{CONFIG_DIR}` with `.antigravity/`
- Replace `{CONFIG_FILE}` with `GEMINI.md`
- Replace `{SUBAGENT_TOOL}` with `Agent Manager`
- Create at `.antigravity/skills/security-reviewer/SKILL.md`

**Creation eval (DEFERRABLE):** See template for eval scenarios.

### Step 10 — Create Red Team / Blue Team skills (if project risk warrants it)

Assess the PRD for security risk indicators (auth, multi-tenancy, payments, AI/LLM, sensitive data, file uploads). If present, read `docs/modules/templates/red_team.md` and `docs/modules/templates/blue_team.md`. Adapt:
- Replace `{CONFIG_DIR}` with `.antigravity/`
- Replace `{CONFIG_FILE}` with `GEMINI.md`
- Replace `{SUBAGENT_TOOL}` with `Agent Manager`
- Fill Stack Attack Surface table from PRD
- Create at `.antigravity/skills/red-team/SKILL.md` and `.antigravity/skills/blue-team/SKILL.md`

If PRD shows no security risk indicators → security-reviewer is sufficient, skip this step.

### Step 11 — Create validator skill

Mandatory for ALL projects. Read `docs/modules/templates/validator.md`. Adapt:
- Replace `{CONFIG_DIR}` with `.antigravity/`
- Replace `{CONFIG_FILE}` with `GEMINI.md`
- Replace `{SUBAGENT_TOOL}` with `Agent Manager`
- Create at `.antigravity/skills/validator/SKILL.md`

### Step 12 — Create arbitrator skill

Mandatory for ALL projects. Read `docs/modules/templates/arbitrator.md`. Adapt:
- Replace `{CONFIG_DIR}` with `.antigravity/`
- Replace `{CONFIG_FILE}` with `GEMINI.md`
- Replace `{SUBAGENT_TOOL}` with `Agent Manager`
- Create at `.antigravity/skills/arbitrator/SKILL.md`.

---

### Step 13 — Create proactive stack skills

If the stack has framework-specific patterns AND no existing skill was found in Step 7, create a stack skill:

```bash
mkdir -p .antigravity/skills/[stack-name]
# Create .antigravity/skills/[stack-name]/SKILL.md
```

Include: key patterns, common mistakes, stack-specific security, testing conventions, project adaptations.

Also create domain-specific test patterns when entering complex domains (financial, state machines, multi-step workflows). Create as `.antigravity/skills/[domain]-test-patterns/SKILL.md`.

Do NOT create if: pre-made skill already installed, stack too generic, AI unfamiliar.

---

### Step 14 — Identify future rules

Analyze the PRD and list modules with complex business logic (3+ business rules).

For each, register in pendencias.md:
```
- Create `.antigravity/rules/[module]-rules.md` when starting implementation of [module]
```

Do NOT create the rule now — wait until implementation.

---

### Step 15 — Initialize logs and finalize

Create `.antigravity/logs/` directory for session logs:
```bash
mkdir -p .antigravity/logs
```

---

### Step 16 — Report

```
## Session 0 — Bootstrap Complete (Antigravity)

### Files created:
- GEMINI.md ([lines] lines)
- AGENTS.md ([lines] lines) — cross-tool compatibility
- .antigravity/phases/project.md ([lines] lines)
- .antigravity/phases/pendencias.md ([lines] lines)
- .antigravity/skills/code-reviewer/SKILL.md ([lines] lines)
- .antigravity/skills/security-reviewer/SKILL.md ([lines] lines)
- .antigravity/skills/red-team/SKILL.md ([lines] lines) ← if created (Step 10)
- .antigravity/skills/blue-team/SKILL.md ([lines] lines) ← if created (Step 10)
- .antigravity/skills/validator/SKILL.md ([lines] lines) ← mandatory (Step 11)
- .antigravity/skills/arbitrator/SKILL.md ([lines] lines) ← mandatory (Step 12)
- .antigravity/logs/ (initialized)
- assets/examples/ (copied from framework)

### Process skills: copied from framework (Step 5.7):
- prd-sync-checker, sprint-proposer, criteria-enforcer, validation-orchestrator
- diff-pattern-extractor, project-md-updater, pendencias-updater
- config-file-updater, rules-agents-updater, session-log-creator

### MCPs configured:
- [name]: [WORKING / ERROR: detail]

### Skills installed:
- [name or "none"]
- [stack-skill if created] (proactive — Step 13)
- [domain-test-patterns if created] (proactive — Step 13)

### Rules planned for future creation:
- [module] → .antigravity/rules/[module]-rules.md

### Build Order:
1. [first step — NEXT SESSION]
2. [...]

### Decisions made:
- [list]

### PRD version: v[X.X.X]

### Next session should:
- [specific action from first Build Order item]
```
