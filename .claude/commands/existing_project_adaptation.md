# Existing Project Adaptation Session

This is an **existing project adaptation session** for project **$ARGUMENTS**.

**Project path:** `projects/$ARGUMENTS/`
**Framework root:** `.` (current directory — the agentic_engineering repository root)

## Authorized Operations

- Read and modify documentation files inside `projects/$ARGUMENTS/`
- Create missing documentation files inside `projects/$ARGUMENTS/`
- Copy examples and skills from the framework into the project
- Install MCPs and plugins for the project
- No application code will be written or modified — only documentation and configuration

## Rules

- All documents are written in English for consistency
- Conversational output (reports, questions, summaries) should be in Brazilian Portuguese
- Never modify files in `docs/` or `examples/` (framework read-only references)
- For every document that already exists: **DO NOT overwrite** — read it, identify what's missing, and add only the missing sections. Preserve all existing content, history, and patterns.

## Setup

Before starting the process:

1. Verify `projects/$ARGUMENTS/` exists. If not, stop and tell the user: "Project '$ARGUMENTS' not found in projects/. Use `/bootstrap $ARGUMENTS` for a new project or place the existing project in `projects/$ARGUMENTS/`."

Execute in order. Report results after each part.

---

## Process

This session reads the existing codebase and documentation, then upgrades everything to the current Agentic Engineering Framework version. NO application code will be written or modified. Only documentation and configuration.

---

### Phase 1 — Read Everything (DO NOT write anything yet)

Read the entire existing structure before making any changes. This is the most important phase — your understanding of the project determines the quality of every document you create or update.

**Step 1.1 — Read existing documentation:**

```bash
# Find all markdown docs
find projects/$ARGUMENTS -name "*.md" -not -path '*/node_modules/*' -not -path '*/.next/*' -not -path '*/.git/*' | sort

# Read the main config file
cat projects/$ARGUMENTS/CLAUDE.md 2>/dev/null || echo "NO CONFIG FILE FOUND"

# Read project history
cat projects/$ARGUMENTS/.claude/phases/project.md 2>/dev/null

# Read backlog (may have non-standard names)
find projects/$ARGUMENTS/.claude/phases/ -name "*.md" -not -name "project.md" 2>/dev/null | while read f; do echo "=== $f ==="; cat "$f"; done

# Read all agents
find projects/$ARGUMENTS/.claude/agents/ -name "*.md" 2>/dev/null | while read f; do echo "=== $f ==="; cat "$f"; done

# Read all rules
find projects/$ARGUMENTS/.claude/rules/ -name "*.md" 2>/dev/null | while read f; do echo "=== $f ==="; cat "$f"; done

# Read all skills
find projects/$ARGUMENTS/.claude/skills/ -name "*.md" -o -name "SKILL.md" 2>/dev/null | while read f; do echo "=== $f ==="; cat "$f"; done
```

**Step 1.2 — Read codebase structure:**

```bash
# Project structure
find projects/$ARGUMENTS -maxdepth 3 -type d -not -path '*/node_modules/*' -not -path '*/.next/*' -not -path '*/.git/*' -not -path '*/venv/*' -not -path '*/__pycache__/*' -not -path '*/dist/*' -not -path '*/build/*' | head -60

# Config files (identify stack)
ls -la projects/$ARGUMENTS/package.json projects/$ARGUMENTS/tsconfig.json projects/$ARGUMENTS/next.config.* projects/$ARGUMENTS/nuxt.config.* projects/$ARGUMENTS/vite.config.* projects/$ARGUMENTS/manage.py projects/$ARGUMENTS/pyproject.toml projects/$ARGUMENTS/go.mod projects/$ARGUMENTS/Cargo.toml projects/$ARGUMENTS/Gemfile projects/$ARGUMENTS/docker-compose.yml projects/$ARGUMENTS/.env.example projects/$ARGUMENTS/.env.local 2>/dev/null

# Source file count by type
for ext in ts tsx js jsx py go rb java vue svelte; do
  count=$(find projects/$ARGUMENTS -name "*.$ext" -not -path '*/node_modules/*' -not -path '*/.next/*' 2>/dev/null | wc -l)
  [ "$count" -gt 0 ] && echo "$ext: $count files"
done

# Key architectural files (routes, models, schemas, migrations)
find projects/$ARGUMENTS -type f \( -name "schema.*" -o -name "route.*" -o -name "routes.*" -o -name "model.*" -o -name "models.*" -o -name "migration*" -o -name "middleware.*" \) -not -path '*/node_modules/*' 2>/dev/null | head -30

# Database schema if available
find projects/$ARGUMENTS -name "schema.prisma" -o -name "schema.sql" -o -name "models.py" -o -name "*.entity.ts" 2>/dev/null | head -10
```

**Step 1.3 — Read git history:**

```bash
# Recent history (last 20 commits)
cd projects/$ARGUMENTS && git log --oneline -20 2>/dev/null; cd -

# Contributors
cd projects/$ARGUMENTS && git shortlog -sn 2>/dev/null | head -5; cd -

# When was first and last commit?
cd projects/$ARGUMENTS && echo "First: $(git log --reverse --format='%ai' | head -1)" && echo "Last: $(git log --format='%ai' -1)" 2>/dev/null; cd -

# Bug fix patterns (for seeding Known Bug Patterns)
cd projects/$ARGUMENTS && git log --oneline --all 2>/dev/null | grep -iE "fix|bug|hotfix|patch|revert" | head -15; cd -
```

**Step 1.4 — Read existing PRD (if it exists):**

```bash
find projects/$ARGUMENTS -name "prd.md" -o -name "PRD.md" -o -name "prd_*.md" -o -name "requirements.md" 2>/dev/null
```

If found: read it. If not found: this is expected — we will create a retroactive PRD in Phase 3.

**Step 1.5 — Produce a reading report:**

Before proceeding, present a summary of everything you read:

```
## Reading Report

### Stack identified:
- Framework: [...]
- Database: [...]
- Auth: [...]
- Deploy: [...]

### Project maturity:
- First commit: [date]
- Total commits: [N]
- Source files: [N]
- Modules identified: [list]

### Existing framework docs:
- CLAUDE.md: [exists/missing] — [summary of content]
- project.md: [exists/missing] — [N rows in Progress Log index, last session date]
- pendencias/backlog: [filename] — [N items in progress, N items done]
- Agents: [list with names]
- Rules: [list with names]
- Skills: [list with names]
- Process skills: [N of 10 installed] — [list missing: prd-sync-checker, sprint-proposer, criteria-enforcer, validation-orchestrator, diff-pattern-extractor, project-md-updater, pendencias-updater, config-file-updater, rules-agents-updater, session-log-creator]
- PRD: [exists/missing]

### What needs to be created:
- [ ] [list of missing documents]

### What needs to be upgraded:
- [ ] [list of existing docs that need updates]

### Observations:
- [anything unusual, non-standard naming, etc.]
```

**Wait for user confirmation before proceeding to Phase 2.**

---

### Phase 2 — Upgrade Existing Documents

For every document that already exists: **DO NOT overwrite.** Read it, identify what's missing compared to the current framework, and add only the missing sections. Preserve all existing content, history, and patterns.

**Step 2.1 — Upgrade CLAUDE.md:**

Compare the existing config file against this checklist. Add any missing section:

```
Required sections (compare against docs/modules/templates/claude_md.md):
□ Project Overview (name, state, PRD reference, pending tasks reference, session logs)
□ Session Protocol — START (10 items including MODEL SWITCH check, PRD sync skill, sprint proposal skill)
□ Session Protocol — Task limit per session
□ Three mechanisms for reasoning depth
□ Before implementing (criteria-enforcer skill, complexity classification, complexity threshold, sprint-approved mode, exception stops)
□ Model switch protocol (5 steps + sprint interaction)
□ Git checkpoint strategy
□ During implementation (validation-orchestrator skill trigger + actionable findings rule)
□ Validation Failure Post-Mortem (7 root causes including "subagent context incomplete")
□ Between tasks (4 items including sprint report)
□ Session Protocol — END (5 items, priority-ordered, delegated to process skills)
□ Mid-session context recovery (4 steps + signals)
□ Documentation quality rules
□ Commands section
□ MCP Servers section
□ Skills section (including 10 process skills list)
□ Hooks section
□ Architecture section
□ Key Patterns section
□ Build Order section
□ Design System section
□ File Map section
□ Environment Variables section
```

**Key additions likely missing from older versions:**

*Session Protocol additions:*
- Sprint proposal (Level 4) in Session Protocol START item 6 — skill trigger: sprint-proposer
- Sprint-approved mode in "Before implementing" section (Level 4 auto-pilot)
- Exception stops list (including "False ❌ from subagent escalated by arbitrator")
- Sprint interaction note in model switch protocol
- Discovery cap (max 3 per sprint)
- Sprint report template in "Between tasks" item 4
- Diff-based pattern extraction in end-of-session **item 1** (first priority) — skill trigger: diff-pattern-extractor
- Agent/skill evolution in end-of-session **item 5** — skill trigger: rules-agents-updater
- Session logs (`.claude/logs/`) — permanent record per session
- Hooks section in config file (smart-formatting PostToolUse hook)

*Validation additions (in CLAUDE.md as skill triggers, detail lives in skills):*
- Criteria-enforcer skill trigger in "Before implementing" section
- Validation-orchestrator skill trigger in "During implementation" section
- Validation Failure Post-Mortem section (7 root causes including "subagent context incomplete")

*Agent/skill infrastructure (verified in Steps 2.4-2.8, not CLAUDE.md sections):*
- **validator agent** (`.claude/agents/validator.md`) — mandatory, independent verification
- **arbitrator agent** (`.claude/agents/arbitrator.md`) — mandatory, conflict resolution
- **`invocation:` frontmatter** on all review/validation agents/skills (`subagent` or `inline`)
- **`receives:` / `produces:` frontmatter** on `invocation: subagent` agents/skills (I/O contract)
- **Lineage frontmatter** on all agents/skills (`created:`, `last_eval:`, `fixes:`, `derived_from:`)
- **Efficacy tracking** on Known Bug Patterns (`[added: sN | triggered: sN | false-positive: N]`)
- **"Known Bug Patterns triggered"** field in Code Review Report output format
- **"Evolutions applied"** section in session log template

*Process skills (copied in Step 2.9 — the v1.6.0 slim orchestrator delegates to these):*
- 10 process skills implementing Session Protocol and Execution Protocol steps
- Without these skills, every skill trigger in CLAUDE.md is a broken reference

**For each addition, log:**
```
Added to CLAUDE.md: [section name] — [reason: missing from current version]
```

**Step 2.2 — Upgrade project.md:**

Check for required sections:
```
□ Overview (stack, repo, deploy, database)
□ Architectural Decisions table
□ Module Relationships (ASCII diagram + cross-module flows)
□ Project Phases with completion criteria
□ Progress Log index table (session, date, summary, log reference)
```

**Do NOT modify existing Progress Log entries.** Add missing sections at the appropriate location.

If the Progress Log uses the old format (full session entry blocks), convert it to an index table during this adaptation. Extract session number, date, and 1-line summary from each block. Use `—` for the Log column (no log files exist for old sessions). Preserve old entries below the table as a legacy block.

Add an adaptation row to the Progress Log index table:

```markdown
| Adaptation | [date] | Framework upgrade to v[current], retroactive PRD created | — |
```

Also create a session log in `.claude/logs/` with the detailed adaptation record:
```markdown
# Adaptation Session — [date]

## Summary
Upgraded project documentation to Agentic Engineering Framework v[current].

## What was done
- Added missing sections: [list]
- Created retroactive PRD from existing codebase analysis
- Verified: agents, rules, skills, phases structure

## Preserved
- [N] rows in Progress Log index
- [N] agents: [names]
- [N] rules: [names]
- [N] skills: [names]

## PRD version: v1.0.0 (retroactive — created from codebase analysis)
## Next session should: [first item from pendencias.md]
```

**Step 2.3 — Upgrade pendencias.md (or equivalent):**

The file may have a non-standard name (e.g., `pendencias_e_melhorias.md`). **Do NOT rename it** — update the reference in CLAUDE.md to point to the actual filename.

Check and upgrade:
```
□ Every task has Context, State, Constraints fields
□ Every task has Complexity classification (routine / logic-heavy / architecture-security)
□ Every task has acceptance criteria with BUILD:/VERIFY:/QUERY:/REVIEW:/MANUAL: tags
□ Criteria are at STRONG level (action + expected result + failure signal)
□ done_tasks.md exists (or legacy Done section — will be migrated by pendencias-updater)
□ Future Improvements section exists
□ Dependency mapping (depends:/parallel:) is optional but noted
□ Evolution classification (FIX/DERIVED/CAPTURED) noted for items that originated from bug fixes or pattern captures during codebase analysis
```

**For existing tasks without these fields:** Add them based on the task description and your understanding of the codebase. Mark additions with `← added during adaptation` so the user can review.

**Before Steps 2.4-2.8:** If `assets/examples/examples_instructions.md` exists, read it for conventions (frontmatter fields, structure, output format, invocation types). Use these conventions when creating or upgrading any agent or skill.

**Step 2.4 — Upgrade code-reviewer agent/skill:**

Check for:
```
□ Frontmatter with effort: medium
□ Frontmatter with invocation: subagent
□ Frontmatter with receives: and produces: fields (I/O contract)
□ Frontmatter with lineage fields: created:, last_eval:, fixes:, derived_from:
□ Input section (what the subagent reads when invoked)
□ Output section with "Known Bug Patterns triggered" field in report format
□ BOUNDARIES section (what NOT to read — anti-bias firewall)
□ Project Patterns section
□ Type Safety section
□ API / Data Mutation Patterns section
□ Performance section
□ Security section (references security-reviewer)
□ Architecture Patterns section (populated, not empty)
□ Known Bug Patterns section (populated from git history, with efficacy tracking metadata)
```

**Seed Known Bug Patterns from git history:**
If the Known Bug Patterns section is empty or sparse, analyze the git log fix commits (from Step 1.3) and the codebase to propose initial patterns:
```bash
# Read recent fix commits for pattern extraction
cd projects/$ARGUMENTS && git log --oneline --all | grep -iE "fix|bug|hotfix|patch" | head -10; cd -
```
For each fix: ask "could this recur?" If yes, add the CORRECT pattern (not the mistake) with efficacy tracking metadata: `[added: adaptation | triggered: never | false-positive: 0]`.

**Step 2.5 — Upgrade security-reviewer:**

Check frontmatter:
```
□ Frontmatter with effort: high
□ Frontmatter with invocation: subagent
□ Frontmatter with receives: and produces: fields (I/O contract)
□ Frontmatter with lineage fields: created:, last_eval:, fixes:, derived_from:
□ Input section (what the subagent reads when invoked)
□ Output section (report format the subagent produces)
□ BOUNDARIES section (what NOT to read — anti-bias firewall)
```

Compare against the full checklist (9 sections):
```
□ 1. Injection Prevention (SQL, XSS, Prompt, Command, LDAP/XML/NoSQL)
□ 2. Authentication and Authorization
□ 3. Data Protection (sensitive data, in transit, at rest)
□ 4. Input Validation
□ 5. API Security
□ 6. Dependency Security
□ 7. Security Headers
□ 8. Stack-Specific Security (delegation note to stack skill / Red Team)
□ 9. Red Team Thinking (5 questions)
```

Add missing sections. **Do NOT remove existing customizations** — they may contain project-specific security rules.

**Step 2.6 — Verify Red Team / Blue Team:**

If they exist: verify they have `effort: high`, `invocation: subagent`, `receives:`, `produces:`, and lineage fields (`created:`, `last_eval:`, `fixes:`, `derived_from:`) in frontmatter, tiered test structure (Tier 1/2/3), and the Tier 3 MANDATORY STOP protocol. Add if missing.

If they don't exist: assess the PRD (once created in Phase 3) for risk indicators. If the project has auth, payments, multi-tenancy, AI/LLM, or PII → create them. Read templates at `docs/modules/templates/red_team.md` and `docs/modules/templates/blue_team.md`. Replace `{CONFIG_DIR}` with `.claude/`, `{CONFIG_FILE}` with `CLAUDE.md`, `{SUBAGENT_TOOL}` with `Task tool`.

**Step 2.6.1 — Verify validator agent/skill:**

If it exists: verify it has `invocation: subagent`, `effort: high`, `receives:`, `produces:`, Input, Output, Verification Process, and BOUNDARIES sections. Add if missing.

If it doesn't exist: create it. The validator is mandatory for ALL projects. Read the template at `docs/modules/templates/validator.md`. Adapt:
- Replace `{CONFIG_DIR}` with `.claude/`
- Replace `{CONFIG_FILE}` with `CLAUDE.md`
- Replace `{SUBAGENT_TOOL}` with `Task tool`
- Create at `.claude/agents/validator.md`

**Creation eval (DEFERRABLE if context is low):** See agent template for 2 test scenarios. Update lineage after eval.

**Step 2.6.2 — Verify arbitrator agent/skill:**

If it exists: verify it has `invocation: subagent`, `effort: high`, `receives:`, `produces:`, three terminal rulings (UPHOLD/OVERRIDE/ESCALATE), and BOUNDARIES sections.

If it doesn't exist: create it. The arbitrator is mandatory for ALL projects. Read the template at `docs/modules/templates/arbitrator.md`. Adapt:
- Replace `{CONFIG_DIR}` with `.claude/`
- Replace `{CONFIG_FILE}` with `CLAUDE.md`
- Replace `{SUBAGENT_TOOL}` with `Task tool`
- Create at `.claude/agents/arbitrator.md`

**Creation eval (DEFERRABLE if context is low):** See agent template for 2 test scenarios. Update lineage after eval.

**Step 2.7 — Verify rules files:**

Read each rules file. No structural changes needed — rules files are project-specific. Just verify they are referenced from the code-reviewer's Security section or relevant agent.

**Step 2.8 — Verify and upgrade skills:**

Read each skill. Verify frontmatter has `effort:` field. Add if missing (most skills are `effort: medium`; security-related are `effort: high`). For review/validation/security skills, verify `invocation: subagent` and `receives:`/`produces:` fields. For knowledge/reference skills, verify `invocation: inline`.

**Verify lineage fields** on all agents/skills: `created:`, `last_eval:` (subagent only), `fixes:`, `derived_from:`. Add if missing — set `created:` to the adaptation session, `last_eval: none (pre-framework)`, `fixes: []`, `derived_from: null`.

**Flat→folder migration (Claude Code skills):** If any skills exist as flat files (`.claude/skills/[name].md`), migrate to the Anthropic folder format:
```bash
for skill in projects/$ARGUMENTS/.claude/skills/*.md; do
  if [ -f "$skill" ]; then
    name=$(basename "$skill" .md)
    mkdir -p "projects/$ARGUMENTS/.claude/skills/$name"
    mv "$skill" "projects/$ARGUMENTS/.claude/skills/$name/SKILL.md"
    echo "Migrated: $skill → projects/$ARGUMENTS/.claude/skills/$name/SKILL.md"
  fi
done
```
After migration, update any references in CLAUDE.md from `.claude/skills/[name].md` to `.claude/skills/[name]/SKILL.md`.

**Step 2.9 — Copy pre-built process skills:**

The v1.6.0 CLAUDE.md template references 10 process skills by path (e.g., `.claude/skills/prd-sync-checker/SKILL.md`). Without these skills, every skill trigger in Session Protocol is a broken reference.

Copy from the framework:
```bash
# Copy each process skill, preserving any project-customized versions
for skill_dir in ./docs/modules/skills/*/; do
  skill_name=$(basename "$skill_dir")
  if [ ! -d "projects/$ARGUMENTS/.claude/skills/$skill_name" ]; then
    cp -r "$skill_dir" "projects/$ARGUMENTS/.claude/skills/$skill_name"
    echo "Copied: $skill_name"
  else
    echo "SKIPPED (already exists): $skill_name — verify manually against framework version"
  fi
done
```

**Expected skills (all 10 must be present after this step):**
- **Session start:** prd-sync-checker, sprint-proposer
- **Before implementing:** criteria-enforcer
- **During implementation:** validation-orchestrator
- **Session end:** diff-pattern-extractor, project-md-updater, pendencias-updater, config-file-updater, rules-agents-updater, session-log-creator

Register all 10 in CLAUDE.md "Skills" section under "Process skills (copied from framework)".

---

### Phase 3 — Create Retroactive PRD

The PRD does not need to be speculative — it describes what already exists plus what is planned.

Create `projects/$ARGUMENTS/assets/docs/prd.md` with this approach:

**Sections to populate from codebase analysis (what IS):**
- 1.1 Problem — infer from the project's purpose
- 1.2 Solution — describe what the product does today
- 2.1 In Scope (MVP) — list modules/features that are ALREADY IMPLEMENTED, mark as ✅
- 3.x Functional Requirements — for each implemented module: document the business rules you can infer from the code (database schema, API routes, UI flows). Mark each as `[Inferred from code — verify with owner]`
- 5.1 Stack — extracted from package.json / config files (this is factual)
- 5.3 Data Model — extracted from schema/models

**Sections to populate from pendencias.md (what is PLANNED):**
- 2.1 In Scope — add pending features marked as ⏳
- 2.2 Out of Scope — features explicitly excluded or deferred
- 8. Roadmap — current phase + remaining phases

**Sections that need user input (mark as TBD):**
- 1.3 Target Audience (personas) — `[TBD — describe your users]`
- 1.4 Competitive Differentiator — `[TBD]`
- 7. Business Model — `[TBD — describe monetization]`
- 4. Non-Functional Requirements — `[TBD — define performance/security/availability targets]`
- 6. Design and UX — `[TBD or reference existing design system]`

**Changelog:**
```
| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0.0 | [date] | Retroactive PRD — created from codebase analysis during framework adaptation | AI + [owner] |
```

**After creating the PRD:** update CLAUDE.md to reference it (`**PRD:** See assets/docs/prd.md`).

---

### Phase 4 — Copy Examples and Fill Gaps

**Step 4.1 — Copy framework examples (if not already present):**

```bash
# Check if examples exist
ls projects/$ARGUMENTS/assets/examples/ 2>/dev/null || echo "MISSING"
```

If missing, copy from the framework root:
```bash
cp -r ./examples/ projects/$ARGUMENTS/assets/examples/ 2>/dev/null || echo "Framework examples not accessible — copy manually from the framework's examples/ directory"
```

**Step 4.2 — Create settings.json and initialize logs (if missing):**

Read the template at `docs/modules/templates/settings_json.md` for the reference configuration. If `projects/$ARGUMENTS/.claude/settings.json` or `projects/$ARGUMENTS/.claude/settings.local.json` already exists, **merge** the keys rather than overwriting.

```bash
# Create logs directory
mkdir -p projects/$ARGUMENTS/.claude/logs 2>/dev/null

# Create settings.json if missing (Claude Code only)
if [ ! -f "projects/$ARGUMENTS/.claude/settings.json" ] && [ -d "projects/$ARGUMENTS/.claude" ]; then
  cat > projects/$ARGUMENTS/.claude/settings.json << 'SETTINGS'
{
  "permissions": {
    "defaultMode": "bypassPermissions",
    "allow": [
      "Edit(CLAUDE.md)",
      "Edit(.claude/**)",
      "Write(.claude/**)",
      "Read",
      "Bash(git *)",
      "Bash(npm *)",
      "Bash(npx *)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "if [[ \"$CLAUDE_TOOL_FILE_PATH\" == *.js || \"$CLAUDE_TOOL_FILE_PATH\" == *.ts || \"$CLAUDE_TOOL_FILE_PATH\" == *.jsx || \"$CLAUDE_TOOL_FILE_PATH\" == *.tsx || \"$CLAUDE_TOOL_FILE_PATH\" == *.json || \"$CLAUDE_TOOL_FILE_PATH\" == *.css || \"$CLAUDE_TOOL_FILE_PATH\" == *.md ]]; then npx prettier --write \"$CLAUDE_TOOL_FILE_PATH\" 2>/dev/null || true; fi",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
SETTINGS
  echo "Created settings.json with hooks"
fi
```

**Note:** The smart-formatting hook requires Prettier. If the project doesn't use Prettier, create settings.json with only the `permissions` block and skip the `hooks` section.

**Step 4.3 — Discover and install MCPs:**

**4.3a. Check existing MCPs:**
```bash
cat projects/$ARGUMENTS/.claude/settings.json 2>/dev/null | grep -A5 "mcpServers"
cat projects/$ARGUMENTS/.claude/settings.local.json 2>/dev/null
```

**4.3b. Install browser automation (default for every project):**
```bash
npx @anthropic-ai/claude-code mcp add playwright -- npx -y @anthropic-ai/mcp-server-playwright
```

**4.3c. Install stack-based MCPs** based on the stack identified in Phase 1:

| Stack includes | Recommended MCP | When to install |
|---------------|----------------|-----------------|
| Supabase | supabase MCP | If Supabase project exists |
| PostgreSQL (not Supabase) | postgres MCP | If database exists |
| GitHub repo | github MCP | If repo exists |
| React/Next.js/Vue with libs | context7 MCP | Yes |

**4.3d. Security validation (MANDATORY before installing any MCP):**
```
□ Trusted source? (official org, verified publisher, >10k downloads)
□ Actively maintained? (published within last 6 months)
□ Reasonable permissions? (read-only by default)
□ Open source? (public repo with auditable code)
□ Actually relevant? (solves concrete problem for this stack)
```

If any fails: do not install, log reason. If uncertain: ASK user. Max 5 MCPs on day 1.

Register installed MCPs in CLAUDE.md "MCP Servers" section.

**Step 4.4 — Install Skill Creator plugin:**

```bash
/plugin install skill-creator@claude-plugins-official
```

**If installation succeeds:** Log "Skill Creator plugin installed."

**If installation fails** (plugin not available, network error, unsupported environment): Log "Skill Creator plugin unavailable — framework creation eval protocol will be used instead." Continue normally.

**Step 4.5 — Discover and install stack skills:**

Search for available skills relevant to the project stack:
```bash
npx claude-code-templates@latest --list-skills 2>/dev/null || echo "CLI not available"
```

If the stack has framework-specific patterns AND no pre-made skill was found, create a stack skill:
```bash
mkdir -p projects/$ARGUMENTS/.claude/skills/[stack-name]
# Create projects/$ARGUMENTS/.claude/skills/[stack-name]/SKILL.md with key patterns, common mistakes, security settings
```

Register in CLAUDE.md "Skills" section.

**Step 4.6 — Identify future rules:**

Analyze the retroactive PRD (created in Phase 3) for modules with complex business logic (3+ business rules). For each, register in pendencias.md:
```
- Create `.claude/rules/[module]-rules.md` when starting implementation of [module]
```
Do NOT create rules now — wait until implementation when the details are known.

---

### Phase 5 — Validation and Report

**Step 5.1 — Run consistency check:**

```bash
echo "=== File structure ==="
find projects/$ARGUMENTS/.claude -name "*.md" -o -name "*.json" | sort

echo "=== CLAUDE.md references valid files? ==="
# Check that referenced paths exist
grep -oP '`[^`]*\.md`' projects/$ARGUMENTS/CLAUDE.md | sort -u | while read ref; do
  path=$(echo "$ref" | tr -d '`')
  [ ! -f "projects/$ARGUMENTS/$path" ] && echo "BROKEN REF: $path"
done

echo "=== PRD exists? ==="
ls projects/$ARGUMENTS/assets/docs/prd.md 2>/dev/null && echo "YES" || echo "NO"

echo "=== All agents have effort: frontmatter? ==="
for f in projects/$ARGUMENTS/.claude/agents/*.md; do
  grep -q "effort:" "$f" 2>/dev/null || echo "MISSING effort: in $f"
done

echo "=== All agents have invocation: frontmatter? ==="
for f in projects/$ARGUMENTS/.claude/agents/*.md; do
  grep -q "invocation:" "$f" 2>/dev/null || echo "MISSING invocation: in $f"
done

echo "=== All agents have lineage frontmatter? ==="
for f in projects/$ARGUMENTS/.claude/agents/*.md; do
  grep -q "created:" "$f" 2>/dev/null || echo "MISSING lineage (created:) in $f"
done

echo "=== Validator and arbitrator exist? ==="
ls projects/$ARGUMENTS/.claude/agents/validator.md 2>/dev/null || echo "MISSING validator"
ls projects/$ARGUMENTS/.claude/agents/arbitrator.md 2>/dev/null || echo "MISSING arbitrator"

echo "=== Skills use folder format? ==="
for f in projects/$ARGUMENTS/.claude/skills/*.md; do
  [ -f "$f" ] && echo "FLAT FORMAT (needs migration): $f"
done 2>/dev/null

echo "=== All skills have effort: frontmatter? ==="
find projects/$ARGUMENTS/.claude/skills -name "SKILL.md" 2>/dev/null | while read f; do
  grep -q "effort:" "$f" 2>/dev/null || echo "MISSING effort: in $f"
done

echo "=== All 10 process skills present? ==="
for skill in prd-sync-checker sprint-proposer criteria-enforcer validation-orchestrator diff-pattern-extractor project-md-updater pendencias-updater config-file-updater rules-agents-updater session-log-creator; do
  ls "projects/$ARGUMENTS/.claude/skills/$skill/SKILL.md" 2>/dev/null || echo "MISSING process skill: $skill"
done

echo "=== Known Bug Patterns have efficacy tracking? ==="
grep -c "\[added:" projects/$ARGUMENTS/.claude/agents/code-reviewer.md 2>/dev/null || echo "No efficacy tracking in code-reviewer"
```

**Step 5.2 — Produce the adaptation report:**

```
## Adaptation Complete — Framework Upgrade Report

### Documents upgraded:
- CLAUDE.md: [sections added/modified]
- project.md: [adaptation entry added, sections added]
- pendencias.md: [tasks upgraded with metadata]
- code-reviewer.md: [Known Bug Patterns seeded, sections added]
- security-reviewer.md: [sections added]
- [other agents/skills]: [changes]

### Documents created:
- assets/docs/prd.md (retroactive — [N] sections populated, [N] TBD)
- .claude/logs/ (initialized — session logs start from next session)
- .claude/agents/validator.md (if created)
- .claude/agents/arbitrator.md (if created)
- [any other new files]

### Process skills: [N of 10 copied from framework]
- [list copied / list skipped (already existed)]

### Preserved (not modified):
- [N] rows in Progress Log index
- [N] rules files: [names]
- [N] existing Known Bug Patterns
- All existing git history

### PRD sections needing user input:
- [ ] 1.3 Target Audience
- [ ] 1.4 Competitive Differentiator
- [ ] 7. Business Model
- [ ] [other TBD sections]

### MCPs: [list with status]
### Skills: [list with status]
### Hooks: smart-formatting [ACTIVE / SKIPPED: no Prettier]

### Non-standard naming:
- [e.g., pendencias_e_melhorias.md — reference updated in CLAUDE.md]

### PRD version: v1.0.0 (retroactive)

### Next session should:
- Review TBD sections in PRD
- [first item from pendencias]
```
