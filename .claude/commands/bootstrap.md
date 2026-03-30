# Bootstrap Session

This is a **bootstrap session** (Session 0) for project **$ARGUMENTS**.

**Project path:** `projects/$ARGUMENTS/`
**PRD path:** `projects/$ARGUMENTS/assets/docs/prd.md`

## Authorized Operations

- Create all project files inside `projects/$ARGUMENTS/`
- Install MCPs and plugins for the project
- Copy examples and skills from the framework into the project
- No files outside `projects/$ARGUMENTS/` should be created or modified

## Rules

- All documents (CLAUDE.md, project.md, pendencias.md, code-reviewer.md, PRD) are written in English for consistency
- Conversational output (reports, questions, summaries) should be in Brazilian Portuguese
- Never modify files in `docs/` or `examples/` (framework read-only references)
- No application code will be written — only documentation and configuration

## Setup

Before starting the process:

1. If `projects/$ARGUMENTS/` does not exist, create it and `projects/$ARGUMENTS/assets/docs/`
2. If `projects/$ARGUMENTS/assets/docs/prd.md` does not exist, the session still works — PRD-derived sections will be marked "to be defined"

Execute in order. Report results after each part.

---

## Process

### Step 1 — Read the PRD

If `projects/$ARGUMENTS/assets/docs/prd.md` exists, read it completely. Extract:
- Product name and description
- Target audience
- MVP modules/features with priorities
- Features out of scope
- Stack (or "to be defined")
- Constraints (deadline, compliance, platform)
- Business rules per module
- External integrations
- Business model

If `projects/$ARGUMENTS/assets/docs/prd.md` does not exist, skip this step. Use information from the user or CLAUDE.md to populate documents. Mark unknown sections as "to be defined".

---

### Step 1.5 — Copy examples to project

Copy the framework's examples directory into the project for future reference:

```bash
cp -r examples/ projects/$ARGUMENTS/assets/examples/
```

These examples serve as quality reference for creating agents, skills, and rules — both during this bootstrap AND during on-demand creation in future sessions. They are read-only templates, not active configuration.

---

### Step 2 — Create CLAUDE.md

**All files from Step 2 onwards are created inside `projects/$ARGUMENTS/`.** Paths in this prompt (e.g., `CLAUDE.md`, `.claude/phases/`) are relative to the project root.

**If CLAUDE.md already exists:** Do NOT overwrite. Instead, compare the existing content with the template. Add missing sections and update outdated sections. Report what was added/changed.

**If CLAUDE.md does not exist:** Read the template at `docs/modules/templates/claude_md.md`. Adapt with PRD data:
- Fill Project Overview from PRD (name, description, modules, owner)
- Fill Architecture from PRD section 5
- Fill Key Patterns based on the stack
- Fill Build Order from PRD module dependencies
- Fill Design System reference
- Fill Environment Variables from stack requirements
- Leave Commands, MCP Servers, Skills, Hooks empty (filled in later steps)

Create the file at the project root as `CLAUDE.md`.

**The template references process skills** (`.claude/skills/prd-sync-checker/SKILL.md`, etc.) in the Session Protocol. These are copied in Step 5.7 below.

---

### Step 3 — Create project.md

**If `.claude/phases/project.md` already exists:** Do NOT overwrite. Add a new index row to the Progress Log table for this migration/bootstrap session. Verify it has the required sections (Architectural Decisions, Module Relationships, Progress Log index table). Add missing sections.

**If it does not exist:** Read the template at `docs/modules/templates/project_md.md`. Adapt with PRD data:
- Fill Overview from PRD sections 1.1, 1.2, 1.3 (including `**PRD version:** v1.0.0`)
- Fill Architectural Decisions table with stack decisions from PRD
- Fill Module Relationships with dependencies from PRD
- Fill Project Phases from Build Order
- Add Session 0 row to Progress Log index table: `| 0 (Bootstrap) | [date] | PRD analyzed, docs + agents created, stack confirmed | — |`

Create at `.claude/phases/project.md`.

---

### Step 4 — Create pendencias.md

**If `.claude/phases/pendencias.md` already exists:** Do NOT overwrite. Verify existing items have acceptance criteria tags. Add tags to items missing them. Add any new items from the PRD that are not yet tracked.

**If it does not exist:** Read the template at `docs/modules/templates/pendencias_md.md`. Adapt with PRD data:
- Fill tasks from Build Order with full Context/State/Constraints/Complexity/Criteria
- Ensure every task has acceptance criteria with `BUILD:`/`VERIFY:`/`QUERY:`/`REVIEW:`/`MANUAL:` tags
- Criteria quality standard: every criterion must have 3 parts (action, expected result, failure signal)

Create at `.claude/phases/pendencias.md`.

---

### Step 5 — Discover and install MCPs

**5a. Install browser automation (default for every project):**
```bash
npx @anthropic-ai/claude-code mcp add playwright -- npx -y @anthropic-ai/mcp-server-playwright
```

**5b. Search for available MCPs:**

**Source 1 — npm registry (preferred, most secure):**
```bash
npm search @modelcontextprotocol/server 2>/dev/null | head -20
npm search mcp-server 2>/dev/null | head -20
```

**Source 2 — claude-code-templates CLI:**
```bash
npx claude-code-templates@latest --list-mcps 2>/dev/null || echo "CLI not available"
```

**Source 3 — Web search via Playwright (complementary):**
Use ONLY if sources 1 and 2 returned no result.

**5c. Decide which to install** based on the project stack:

| Stack includes | Recommended MCP | When to install |
|---------------|----------------|-----------------|
| Supabase | supabase MCP | If Supabase project exists |
| PostgreSQL (not Supabase) | postgres MCP | If database exists |
| GitHub repo | github MCP | If repo exists |
| React/Next.js/Vue with libs | context7 MCP | Yes |
| Other service | Search in sources 1-3 | Assess need + security |

**5d. Security validation (MANDATORY before installing any MCP):**

```
□ Trusted source? (official org, verified publisher, >10k downloads)
□ Actively maintained? (published within last 6 months)
□ Reasonable permissions? (read-only by default)
□ Open source? (public repo with auditable code)
□ Actually relevant? (solves concrete problem for this stack)
```

If any fails: do not install, log reason. If uncertain: ASK user.

**Rules:** Max 5 MCPs on day 1. Only install if resource exists. Register in CLAUDE.md "MCP Servers" section.

---

### Step 5.5 — Install Skill Creator plugin

Install the Skill Creator plugin for automated skill evaluation:

```bash
/plugin install skill-creator@claude-plugins-official
```

**If installation succeeds:** Log "Skill Creator plugin installed. Will be used for skill eval in Steps 7-12 and on-demand creation."

**If installation fails** (plugin not available, network error, unsupported environment): Log "Skill Creator plugin unavailable — framework creation eval protocol will be used instead." Continue with Step 5.7. The framework's manual creation eval (2 test scenarios per agent) provides the same quality gate without the plugin.

---

### Step 5.7 — Copy pre-built process skills

Copy the framework's process skills to the project:

```bash
cp -r docs/modules/skills/* projects/$ARGUMENTS/.claude/skills/
```

This copies 10 process skills that implement the Session Protocol and Execution Protocol:
- **Session start:** prd-sync-checker, sprint-proposer
- **Before implementing:** criteria-enforcer
- **During implementation:** validation-orchestrator
- **Session end:** diff-pattern-extractor, project-md-updater, pendencias-updater, config-file-updater, rules-agents-updater, session-log-creator

These skills are referenced by the Session Protocol in CLAUDE.md (created in Step 2). They contain the detailed process instructions for each workflow step.

Register all 10 in CLAUDE.md "Skills" section under "Process skills (copied from framework)".

---

### Step 6 — Discover and install Skills

**6a. Search (in priority order):**

**Source 1 — Plugin marketplace (if available):**
If the plugin marketplace is accessible, browse for skills relevant to the stack:
```
/plugin marketplace browse
```
If this command is not recognized, skip to Source 2.

**Source 2 — CLI:**
```bash
npx claude-code-templates@latest --list-skills 2>/dev/null || echo "CLI not available"
```

**Source 3 — Web via Playwright (complementary):**
Only if Sources 1 and 2 returned no result.

**6b. Decide:**

| Stack | Recommended | Notes |
|-------|------------|-------|
| React / Next.js | react-best-practices | If available |
| Other | Search by technology | If available |

**Validation:**
- ✅ Focuses on QUALITY/PERFORMANCE of the stack → install
- ❌ Focuses on design/architecture OPINION → do NOT install (conflicts with project decisions)
- ❌ Contradicts PRD or CLAUDE.md patterns → do NOT install
- ❌ Covers 3+ languages/frameworks → too generic, do NOT install

Register in CLAUDE.md "Skills" section. No skill found? That is fine — skills are optional.

---

### Steps 7-12 — Create agents and skills

**Before creating any agent or skill in the steps below:** read `assets/examples/examples_instructions.md` for conventions (frontmatter, structure, output format, invocation type). Then check if a relevant example exists in `assets/examples/agents/` or `assets/examples/skills/`. If found, use as a structural template — adapt to this project's stack and domain. Do NOT copy verbatim if not perfectly suitable for the project.

### Step 7 — Create code-reviewer agent

**If `.claude/agents/code-reviewer.md` already exists:** Do NOT overwrite. Verify it has "Known Bug Patterns" and "Architecture Patterns" sections. Add them if missing. Do not remove existing patterns.

**If it does not exist:** Read the template at `docs/modules/templates/code_reviewer.md`. Adapt:
- Replace `{CONFIG_DIR}` with `.claude/`
- Replace `{CONFIG_FILE}` with `CLAUDE.md`
- Create at `.claude/agents/code-reviewer.md`

**Creation eval (DEFERRABLE if context is low):** See template for eval scenarios. Update lineage after eval.

### Step 8 — Create security-reviewer agent

This agent is created at bootstrap for ALL projects (security is universal).

**If `.claude/agents/security-reviewer.md` already exists:** Do NOT overwrite. Verify it has: prompt injection section, tiered security testing model reference, and Section 8 delegation.

**If it does not exist:** Read the template at `docs/modules/templates/security_reviewer.md`. Adapt:
- Replace `{CONFIG_DIR}` with `.claude/`
- Replace `{CONFIG_FILE}` with `CLAUDE.md`
- Create at `.claude/agents/security-reviewer.md`

After creating, verify code-reviewer references it in the Security section.

**Creation eval (DEFERRABLE if context is low):** See template for eval scenarios.

### Step 9 — Create Red Team / Blue Team agents (if project risk warrants it)

Assess the PRD for security risk indicators:

```
PRD indicates ANY of these → CREATE Red Team + Blue Team agents:
  - User authentication (login, signup, password reset)
  - Multi-tenancy (org/team separation, row-level security)
  - Payment processing (Stripe, cards, financial transactions)
  - AI/LLM integration (prompts, embeddings, function calling)
  - Sensitive data storage (PII, health records, financial data)
  - External API integrations with credentials
  - File uploads from users

PRD indicates NONE of these → security-reviewer is sufficient, skip this step
```

**If creating:** Read templates at `docs/modules/templates/red_team.md` and `docs/modules/templates/blue_team.md`. Adapt with stack-specific attack vectors and security settings from PRD.
- Replace `{CONFIG_DIR}` with `.claude/`
- Replace `{CONFIG_FILE}` with `CLAUDE.md`
- Replace `{SUBAGENT_TOOL}` with `Task tool`
- Fill Stack Attack Surface table from PRD
- Fill Stack Security Settings from framework
- Create at `.claude/agents/red-team.md` and `.claude/agents/blue-team.md`

**Creation eval (DEFERRABLE if context is low):** See templates for eval scenarios.

### Step 10 — Create validator agent

The validator is mandatory for ALL projects. Read the template at `docs/modules/templates/validator.md`. Adapt:
- Replace `{CONFIG_DIR}` with `.claude/`
- Replace `{CONFIG_FILE}` with `CLAUDE.md`
- Replace `{SUBAGENT_TOOL}` with `Task tool`
- Create at `.claude/agents/validator.md`

**Creation eval (DEFERRABLE if context is low):** See template for eval scenarios.

### Step 11 — Create arbitrator agent

The arbitrator is mandatory for ALL projects. Read the template at `docs/modules/templates/arbitrator.md`. Adapt:
- Replace `{CONFIG_DIR}` with `.claude/`
- Replace `{CONFIG_FILE}` with `CLAUDE.md`
- Replace `{SUBAGENT_TOOL}` with `Task tool`
- Create at `.claude/agents/arbitrator.md`

**Creation eval (DEFERRABLE if context is low):** See template for eval scenarios.

### Step 12 — Create proactive stack skills

If the stack identified in the PRD has framework-specific patterns AND no existing skill was found in Step 6, create a stack skill using the Anthropic folder format:

```bash
mkdir -p .claude/skills/[stack-name]
# Create .claude/skills/[stack-name]/SKILL.md
```

**Trigger:** Stack is defined in PRD + no pre-made skill found + framework has known patterns.

**Include in the stack skill:**
- Key patterns for the framework (ORM, middleware, routing, component model)
- Common mistakes to avoid
- Stack-specific security settings (debug mode, secure cookies, CSRF, headers)
- Testing framework and conventions
- Project-specific adaptations (from PRD constraints)

**Also create domain-specific test patterns** when the project enters a domain with complex verification needs. Create as `.claude/skills/[domain]-test-patterns/SKILL.md` with:
- Critical test scenarios table (Scenario | Why | Example test)
- STRONG criteria examples for the domain
- Edge cases checklist

**Do NOT create if:** pre-made skill already installed, stack too generic, AI unfamiliar with framework.

---

### Step 13 — Identify future rules

Analyze the PRD and list modules with complex business logic (3+ business rules).

For each, register in pendencias.md:
```
- Create `.claude/rules/[module]-rules.md` when starting implementation of [module]
```

Do NOT create the rule now — wait until implementation when the details are known.

---

### Step 14 — Create settings.json, configure hooks, and initialize logs

Create `.claude/logs/` directory for session logs:
```bash
mkdir -p .claude/logs
```

Read the template at `docs/modules/templates/settings_json.md`. Create `.claude/settings.json` with the permissions and hooks configuration.

**Prerequisite:** Prettier must be installed (`npm install -D prettier`). If the project does not use Prettier, skip the hooks section.

**Note:** If `.claude/settings.json` or `.claude/settings.local.json` already exists, merge the keys rather than overwriting.

---

### Step 15 — Report

```
## Session 0 — Bootstrap Complete

### Files created:
- CLAUDE.md ([lines] lines)
- .claude/phases/project.md ([lines] lines)
- .claude/phases/pendencias.md ([lines] lines)
- .claude/agents/code-reviewer.md ([lines] lines)
- .claude/agents/security-reviewer.md ([lines] lines)
- .claude/agents/red-team.md ([lines] lines) ← if created (Step 9)
- .claude/agents/blue-team.md ([lines] lines) ← if created (Step 9)
- .claude/agents/validator.md ([lines] lines) ← mandatory (Step 10)
- .claude/agents/arbitrator.md ([lines] lines) ← mandatory (Step 11)
- .claude/skills/[domain]-test-patterns/SKILL.md ([lines] lines) ← if created (Step 12)
- .claude/settings.json
- .claude/logs/ (initialized — session logs start from session 1)
- assets/examples/ (copied from framework — Step 1.5)

### Process skills: copied from framework (Step 5.7):
- prd-sync-checker, sprint-proposer, criteria-enforcer, validation-orchestrator
- diff-pattern-extractor, project-md-updater, pendencias-updater
- config-file-updater, rules-agents-updater, session-log-creator

### Hooks configured:
- smart-formatting (PostToolUse → Write/Edit/MultiEdit): Prettier auto-format [ACTIVE / SKIPPED: no Prettier]

### MCPs installed:
- [name]: [WORKING / ERROR: detail]

### Skills installed:
- [name or "none"]
- [stack-skill if created] (proactive — Step 12)
- [domain-test-patterns if created] (proactive — Step 12)

### Rules planned for future creation:
- [module] → .claude/rules/[module]-rules.md

### Build Order:
1. [first step — NEXT SESSION]
2. [...]

### Decisions made:
- [list]

### PRD version: v[X.X.X]

### Next session should:
- [specific action from first Build Order item]
```
