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
- Leave Commands, MCP Servers, Skills & Agents, Hooks empty (filled in later steps)

Create the file at the project root as `CLAUDE.md`.

**The template is a slim orchestrator** (~90 lines). It contains project identity and pointers to skills/rules. Protocol logic lives in process skills (copied in Step 5.7) and session rules (also copied in Step 5.7).

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

### Step 5.5 — Enable Skill Creator plugin

Enable the Skill Creator plugin for automated skill evaluation:

1. Check if already installed: `grep -r "skill-creator" ~/.claude/plugins/installed_plugins.json 2>/dev/null`
2. If not installed: `/plugin install skill-creator@claude-plugins-official`
3. Enable in project settings.json — merge this key into the existing file:
   ```json
   "enabledPlugins": {
     "skill-creator@claude-plugins-official": true
   }
   ```
4. Log "Skill Creator plugin enabled. Will be used for skill eval in Steps 7-12 and on-demand creation."

**If installation fails** (plugin not available, network error, unsupported environment): Log "Skill Creator plugin unavailable — framework creation eval protocol will be used instead." Continue with Step 5.7. The framework's manual creation eval (2 test scenarios per agent) provides the same quality gate without the plugin.

---

### Step 5.7 — Copy pre-built process skills, process agents, and session rules

**Process skills (9 — inline, copied to `.claude/skills/`):**

```bash
cp -r docs/modules/skills/* projects/$ARGUMENTS/.claude/skills/
```

- **Session lifecycle (user-triggered):** sprint-proposer, session-end, context-recovery
- **During implementation:** validation-orchestrator
- **Session end:** project-md-updater, pendencias-updater, config-file-updater, rules-agents-updater, session-log-creator

**Process agents (3 — invoked as subagents, copied to `.claude/agents/`):**

```bash
cp docs/modules/agents/prd_sync_checker.md projects/$ARGUMENTS/.claude/agents/prd-sync-checker.md
cp docs/modules/agents/criteria_enforcer.md projects/$ARGUMENTS/.claude/agents/criteria-enforcer.md
cp docs/modules/agents/diff_pattern_extractor.md projects/$ARGUMENTS/.claude/agents/diff-pattern-extractor.md
```

- **Session start:** prd-sync-checker (called by sprint-proposer skill, step 3, opt-in)
- **Before implementing:** criteria-enforcer (called by validation-orchestrator skill)
- **Session end:** diff-pattern-extractor (called by session-end skill, item 1)

These 3 run as isolated subagents via Agent tool — they produce decisions or analyses where inline execution risks skipping steps. The remaining 9 run inline (main agent reads SKILL.md and follows steps in its own context).

**Session rules (copied to `.claude/rules/`):**

```bash
mkdir -p projects/$ARGUMENTS/.claude/rules
# Extract content between the markdown fences in the template
sed -n '/^```markdown$/,/^```$/p' docs/modules/rules/session_rules.md | sed '1d;$d' > projects/$ARGUMENTS/.claude/rules/session-rules.md
sed -n '/^```markdown$/,/^```$/p' docs/modules/rules/evolution_policy.md | sed '1d;$d' > projects/$ARGUMENTS/.claude/rules/evolution-policy.md
sed -n '/^```markdown$/,/^```$/p' docs/modules/rules/component_design.md | sed '1d;$d' > projects/$ARGUMENTS/.claude/rules/component-design.md
```

This creates session-rules.md (task limits, documentation quality, reasoning depth, scripts convention), evolution-policy.md (evolution classification, auto-evolution boundaries), and component-design.md (agent/skill/rule design principles: gap-declaration activation, Pushy Descriptions, vocabulary alignment, tiered architecture, Preservar+Adicionar).

Skills and agents are auto-discovered by Claude Code from `.claude/skills/` and `.claude/agents/`. No explicit listing is needed in CLAUDE.md.

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

**Before creating any agent or skill in the steps below:** read `assets/examples/README.md` for conventions (frontmatter, structure, output format, invocation type). Then check if a relevant example exists in `assets/examples/agents/` or `assets/examples/skills/`. If found, use as a structural template — adapt to this project's stack and domain. Do NOT copy verbatim if not perfectly suitable for the project.

### Step 7 — Create code-reviewer agent

**If `.claude/agents/code-reviewer.md` already exists:** Do NOT overwrite. Verify it has "Known Bug Patterns" and "Architecture Patterns" sections. Add them if missing. Do not remove existing patterns.

**If it does not exist:** Read the template at `docs/modules/agents/code_reviewer.md`. Adapt:
- **Pre-fill "Architecture Patterns" from PRD:** Read the PRD's stack, framework, and architectural constraints. Add 3-7 stack-specific structural rules that are predictable from the technology choice (e.g., Next.js App Router → server/client component separation; Prisma → transaction usage for multi-table ops; Django → fat models/thin views). Keep the existing generic rules and append project-specific ones below them. Do NOT invent speculative patterns — only add rules that are well-established conventions for the chosen stack.
- **Pre-select Coverage Gap Declarations from PRD:** Review the four optional gap sections (accessibility, performance, concurrency, data integrity). Remove sections that are clearly irrelevant to this project's domain (e.g., remove accessibility gap if project has no UI; remove concurrency gap if project has no shared state or booking logic). Keep sections that match PRD features. When in doubt, keep the section — it is conditional and only activates when matching diffs appear.
- **Keep "Known Bug Patterns" empty** — this section is populated by `rules-agents-updater` as real bugs emerge during development, not from predictions.
- Create at `.claude/agents/code-reviewer.md`

**Creation eval (DEFERRABLE if context is low):** See template for eval scenarios. Update lineage after eval.

### Step 8 — Create security-reviewer agent

This agent is created at bootstrap for ALL projects (security is universal).

**If `.claude/agents/security-reviewer.md` already exists:** Do NOT overwrite. Verify it has: prompt injection section, tiered security testing model reference, and Section 8 delegation.

**If it does not exist:** Read the template at `docs/modules/agents/security_reviewer.md`. Adapt:
- **Pre-select Coverage Gap Declarations from PRD:** Review the five optional gap sections (static analysis, secrets coverage, federation protocol, compliance, infrastructure security). Remove sections clearly irrelevant to this project (e.g., remove federation protocol gap if no OAuth/OIDC/SAML; remove infrastructure security gap if no IaC/Docker/K8s). Keep sections that match PRD's tech stack and architecture. When in doubt, keep — gaps are conditional and only fire when matching diffs appear.
- **Compliance Probe context:** If the PRD indicates the project handles personal data (PII, CPF, health records, payment data), note this in the agent so the Compliance Probe section activates from session 1 rather than waiting for a diff to reveal it.
- **Keep Section 8 (Stack-Specific Security) as-is** — this delegates to the stack skill and Red Team agent by design.
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

**If creating:** Read templates at `docs/modules/agents/red_team.md` and `docs/modules/agents/blue_team.md`. Adapt with stack-specific attack vectors and security settings from PRD.
- Fill Stack Attack Surface table from PRD
- Fill Stack Security Settings from framework
- Create at `.claude/agents/red-team.md` and `.claude/agents/blue-team.md`

**Creation eval (DEFERRABLE if context is low):** See templates for eval scenarios.

### Step 10 — Create validator agent

The validator is mandatory for ALL projects. Read the template at `docs/modules/agents/validator.md`. Adapt with project-specific context. Create at `.claude/agents/validator.md`.

**Creation eval (DEFERRABLE if context is low):** See template for eval scenarios.

### Step 11 — Create arbitrator agent

The arbitrator is mandatory for ALL projects. Read the template at `docs/modules/agents/arbitrator.md`. Adapt with project-specific context. Create at `.claude/agents/arbitrator.md`.

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

### Step 12.5 — Pre-install specialist agents and validate activation chains

#### Step 12.5a — Pre-install specialist agents matching kept gap declarations

Read the project's `.claude/agents/code-reviewer.md` and `.claude/agents/security-reviewer.md` (created in Steps 7-8). Identify which Coverage Gap Declaration sections were KEPT (not removed during pre-selection). For each kept gap, check if a matching specialist example exists in `assets/examples/agents/`:

| Gap declaration (in reviewer) | Specialist example to install |
|-------------------------------|-------------------------------|
| accessibility gap (code-reviewer) | accessibility-checker.md |
| performance gap (code-reviewer) | performance-auditor.md |
| concurrency gap (code-reviewer) | concurrency-tester.md |
| data integrity gap (code-reviewer) | data-integrity-checker.md |
| static analysis gap (security-reviewer) | sast-scanner.md |
| secrets coverage gap (security-reviewer) | secrets-scanner.md |
| federation protocol gap (security-reviewer) | oauth-flow-tester.md |
| compliance gap (security-reviewer) | compliance-auditor.md |
| infrastructure security gap (security-reviewer) | iac-scanner.md |

For each match found: copy from `assets/examples/agents/` to `.claude/agents/`, adapting only:
- `created:` lineage: change from `example` to `s0 (bootstrap — pre-installed from example template)`
- Verify the `description:` gap phrase matches the reviewer's gap declaration vocabulary

If a gap was KEPT but no matching example exists in `assets/examples/agents/`: register in `pendencias.md` — "Create specialist agent for [gap] when domain implementation begins."

#### Step 12.5b — Validate activation chains

For every specialist agent created or pre-installed in Steps 7-12.5a that uses gap-declaration activation, verify the chain is complete. Note: code-reviewer and security-reviewer are SOURCES of gaps (not targets) — skip them. Validator, arbitrator, red-team, and blue-team are spawned by protocol, not by gap declaration — skip them too.

For each remaining specialist agent:

1. Verify it has a matching Coverage Gap Declaration in code-reviewer.md or security-reviewer.md whose domain vocabulary echoes the agent's Pushy Description
2. If no match: add the gap declaration to the appropriate reviewer following the existing conditional format (see `docs/modules/rules/component_design.md` sections 1-3)
3. Run a vocabulary alignment check: `grep "[domain keyword]" .claude/agents/code-reviewer.md .claude/agents/security-reviewer.md` — the domain must appear in at least one reviewer

This step prevents "orphan agents" that exist in `.claude/agents/` but are never spawned because the reviewer-to-orchestrator-to-specialist activation chain is broken.

---

### Step 13 — Pre-create domain rules from PRD

Analyze the PRD for domain signals. For each domain that is a **core feature or architectural pattern** in the PRD (not a passing mention), check if a matching example template exists in `assets/examples/rules/`:

| PRD signal (keywords/features) | Rules file to create | Example template |
|---|----|---|
| Multilingual, i18n, localization, multi-language | i18n-rules.md | examples/rules/i18n-rules.md |
| Microservices, event-driven, message queue, saga | distributed-systems-rules.md | examples/rules/distributed-systems-rules.md |
| Scheduling, cron, appointments, calendar, booking | scheduling-rules.md | examples/rules/scheduling-rules.md |
| High-availability, retry, circuit-breaker, fallback | resilience-rules.md | examples/rules/resilience-rules.md |
| Rate limiting, throttling, API quotas | rate-limiting-rules.md | examples/rules/rate-limiting-rules.md |
| E-commerce, cart, checkout, payment, orders | e-commerce-rules.md | examples/rules/e-commerce-rules.md |
| Full-stack, frontend + backend, SSR, API + UI | frontend-backend-integration-rules.md | examples/rules/frontend-backend-integration-rules.md |
| Auth, login, permissions, roles, OAuth | auth-rules.md | examples/rules/auth-rules.md |
| PII, LGPD, GDPR, personal data, consent | compliance-rules.md | examples/rules/compliance-rules.md |
| Multi-tenancy, organization isolation, RLS | multi-tenancy-rules.md | examples/rules/multi-tenancy-rules.md |
| Observability, logging, tracing, metrics, alerts | observability-rules.md | examples/rules/observability-rules.md |

**Guard:** Only pre-create when BOTH conditions are met: (1) the domain is a core feature or architectural pattern in the PRD, and (2) a matching example template exists in `assets/examples/rules/`.

For each match: copy from `assets/examples/rules/` to `.claude/rules/`, adapting:
- `applies_to:` frontmatter: reference the project's actual module names from the PRD
- Remove clearly irrelevant sections that contradict the PRD (e.g., RTL layout section in i18n-rules.md if the project targets only Portuguese/English)
- Add an HTML comment at the top of the file body: `<!-- Seeded from example template at bootstrap. Refined by rules-agents-updater as project-specific patterns emerge. -->`
- Do NOT rewrite code examples to match the project's stack — leave for `rules-agents-updater` to refine with real code patterns

For modules with complex business logic but WITHOUT a matching example template: register in `pendencias.md` as a future task:
```
- Create `.claude/rules/[module]-rules.md` when starting implementation of [module]
```

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
- **Session lifecycle:** sprint-proposer, session-end, context-recovery
- **Implementation:** validation-orchestrator
- **Session end:** project-md-updater, pendencias-updater, config-file-updater, rules-agents-updater, session-log-creator

### Process agents: copied from framework templates (Step 5.7):
- .claude/agents/prd-sync-checker.md (session start — subagent)
- .claude/agents/criteria-enforcer.md (before implementing — subagent)
- .claude/agents/diff-pattern-extractor.md (session end — subagent)

### Rules: copied from framework (Step 5.7):
- .claude/rules/session-rules.md (task limits, documentation quality, reasoning depth, scripts convention)
- .claude/rules/evolution-policy.md (evolution classification, auto-evolution boundaries)
- .claude/rules/component-design.md (agent/skill/rule design: gap-declaration, Pushy Descriptions, vocabulary alignment, tiered architecture)

### Domain rules pre-created (from example templates — Step 13):
- .claude/rules/[domain]-rules.md ← seeded, refined by rules-agents-updater
- [list each pre-created rules file, or "none — no PRD domain signals matched example templates"]

### Specialist agents pre-installed (from example templates — Step 12.5):
- .claude/agents/[specialist].md ← activation chain verified
- [list each pre-installed specialist, or "none — no gap declarations kept"]

### Hooks configured:
- smart-formatting (PostToolUse → Write/Edit/MultiEdit): Prettier auto-format [ACTIVE / SKIPPED: no Prettier]

### MCPs installed:
- [name]: [WORKING / ERROR: detail]

### Skills installed:
- [name or "none"]
- [stack-skill if created] (proactive — Step 12)
- [domain-test-patterns if created] (proactive — Step 12)

### Rules planned for future creation (no example template):
- [module] → .claude/rules/[module]-rules.md
- [or "none — all detected domains had example templates"]

### Build Order:
1. [first step — NEXT SESSION]
2. [...]

### Decisions made:
- [list]

### PRD version: v[X.X.X]

### Next session should:
- [specific action from first Build Order item]
```
