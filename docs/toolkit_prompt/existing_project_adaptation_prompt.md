# Existing Project Adaptation Prompt

Use this prompt with Claude Code when you have a project that already has partial Agentic Engineering structure and needs to be upgraded to the current framework version.

**When to use this instead of session0_bootstrap_prompt.md:**
- Project already has `.claude/` folder with agents, rules, skills, phases
- Project has existing code and implementation history
- No PRD exists (or PRD is outdated)
- You want to upgrade docs to current framework version without losing history

---

## Prompt starts below. Copy everything from here.

---

## Existing Project Adaptation

**Project folder:** `[CONFIGURE: path to project root, e.g., projects/kyojin-system]`

This session reads the existing codebase and documentation, then upgrades everything to the current Agentic Engineering Framework version. NO application code will be written or modified. Only documentation and configuration.

**Output language:** All documents are written in English for consistency. Conversational output should be in [CONFIGURE: your preferred language, e.g., "Brazilian Portuguese"]. Replace this placeholder before sending.

Execute in order. Report results after each part.

---

### Phase 1 — Read Everything (DO NOT write anything yet)

Read the entire existing structure before making any changes. This is the most important phase — your understanding of the project determines the quality of every document you create or update.

**Step 1.1 — Read existing documentation:**

```bash
# Find all markdown docs
find . -name "*.md" -not -path '*/node_modules/*' -not -path '*/.next/*' -not -path '*/.git/*' | sort

# Read the main config file
cat CLAUDE.md 2>/dev/null || cat GEMINI.md 2>/dev/null || echo "NO CONFIG FILE FOUND"

# Read project history
cat .claude/phases/project.md 2>/dev/null || cat .antigravity/phases/project.md 2>/dev/null

# Read backlog (may have non-standard names)
find .claude/phases/ .antigravity/phases/ -name "*.md" -not -name "project.md" 2>/dev/null | while read f; do echo "=== $f ==="; cat "$f"; done

# Read all agents
find .claude/agents/ .antigravity/skills/ -name "*.md" 2>/dev/null | while read f; do echo "=== $f ==="; cat "$f"; done

# Read all rules
find .claude/rules/ .antigravity/rules/ -name "*.md" 2>/dev/null | while read f; do echo "=== $f ==="; cat "$f"; done

# Read all skills
find .claude/skills/ .antigravity/skills/ -name "*.md" -o -name "SKILL.md" 2>/dev/null | while read f; do echo "=== $f ==="; cat "$f"; done
```

**Step 1.2 — Read codebase structure:**

```bash
# Project structure
find . -maxdepth 3 -type d -not -path '*/node_modules/*' -not -path '*/.next/*' -not -path '*/.git/*' -not -path '*/venv/*' -not -path '*/__pycache__/*' -not -path '*/dist/*' -not -path '*/build/*' | head -60

# Config files (identify stack)
ls -la package.json tsconfig.json next.config.* nuxt.config.* vite.config.* manage.py pyproject.toml go.mod Cargo.toml Gemfile docker-compose.yml .env.example .env.local 2>/dev/null

# Source file count by type
for ext in ts tsx js jsx py go rb java vue svelte; do
  count=$(find . -name "*.$ext" -not -path '*/node_modules/*' -not -path '*/.next/*' 2>/dev/null | wc -l)
  [ "$count" -gt 0 ] && echo "$ext: $count files"
done

# Key architectural files (routes, models, schemas, migrations)
find . -type f \( -name "schema.*" -o -name "route.*" -o -name "routes.*" -o -name "model.*" -o -name "models.*" -o -name "migration*" -o -name "middleware.*" \) -not -path '*/node_modules/*' 2>/dev/null | head -30

# Database schema if available
find . -name "schema.prisma" -o -name "schema.sql" -o -name "models.py" -o -name "*.entity.ts" 2>/dev/null | head -10
```

**Step 1.3 — Read git history:**

```bash
# Recent history (last 20 commits)
git log --oneline -20 2>/dev/null

# Contributors
git shortlog -sn 2>/dev/null | head -5

# When was first and last commit?
echo "First: $(git log --reverse --format='%ai' | head -1)"
echo "Last: $(git log --format='%ai' -1)"

# Bug fix patterns (for seeding Known Bug Patterns)
git log --oneline --all 2>/dev/null | grep -iE "fix|bug|hotfix|patch|revert" | head -15
```

**Step 1.4 — Read existing PRD (if it exists):**

```bash
find . -name "prd.md" -o -name "PRD.md" -o -name "prd_*.md" -o -name "requirements.md" 2>/dev/null
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
- CLAUDE.md / GEMINI.md: [exists/missing] — [summary of content]
- project.md: [exists/missing] — [N session entries, last session date]
- pendencias/backlog: [filename] — [N items in progress, N items done]
- Agents: [list with names]
- Rules: [list with names]
- Skills: [list with names]
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

**Step 2.1 — Upgrade CLAUDE.md (or GEMINI.md):**

Compare the existing config file against this checklist. Add any missing section:

```
Required sections:
□ Project Overview (name, state, PRD reference, pending tasks reference)
□ Session Protocol — START (10 items including MODEL SWITCH check, PRD sync, sprint proposal)
□ Session Protocol — Task limit per session
□ Three mechanisms for reasoning depth
□ Before implementing (complexity classification, complexity threshold, sprint-approved mode, exception stops)
□ Model switch protocol (5 steps + sprint interaction)
□ Git checkpoint strategy
□ During implementation — self-validation loop (6 steps)
□ ⏭️ enforcement rules
□ Between tasks (4 items including sprint report)
□ Session Protocol — END (8 items including diff-based pattern extraction and agent/skill evolution)
□ Mid-session context recovery (4 steps + signals)
□ Documentation quality rules
□ PRD sync check — edge cases
□ Commands section
□ MCP Servers section
□ Skills section
□ Hooks section
□ Architecture section
□ Key Patterns section
□ Build Order section
□ Design System section
□ File Map section
□ Environment Variables section
```

**Key additions likely missing from older versions:**
- Sprint proposal (Level 4) in Session Protocol START item 6
- Sprint-approved mode in "Before implementing" section
- Exception stops list
- Sprint interaction note in model switch protocol
- Discovery cap (max 3 per sprint)
- Sprint report template in "Between tasks" item 4
- Diff-based pattern extraction in end-of-session item 5
- Agent/skill evolution in end-of-session item 6 (update existing agents/skills with session discoveries)
- Session logs (`.claude/logs/` or `.antigravity/logs/`) — permanent record per session
- Hooks section in config file (smart-formatting PostToolUse hook)
- "2 per-session moments" Level 4 flow (if Level 4 content is missing entirely)

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
□ Progress Log with session entries
```

**Do NOT modify existing session entries.** Add missing sections at the appropriate location.

Add an adaptation session entry at the end of the Progress Log:
```markdown
### [date] — Adaptation Session (Framework Upgrade)

**What was done:**
- Upgraded project documentation to Agentic Engineering Framework v[current]
- Added missing sections: [list]
- Created retroactive PRD from existing codebase analysis
- Verified: agents, rules, skills, phases structure

**Existing structure preserved:**
- [N] session entries in project.md
- [N] agents: [names]
- [N] rules: [names]
- [N] skills: [names]

**PRD version:** v1.0 (retroactive — created from codebase analysis)

**Next step:** [first item from pendencias.md]
```

**Step 2.3 — Upgrade pendencias.md (or equivalent):**

The file may have a non-standard name (e.g., `pendencias_e_melhorias.md`). **Do NOT rename it** — update the reference in CLAUDE.md to point to the actual filename.

Check and upgrade:
```
□ Every task has Context, State, Constraints fields
□ Every task has Complexity classification (routine / logic-heavy / architecture-security)
□ Every task has acceptance criteria with BUILD:/VERIFY:/QUERY:/REVIEW:/MANUAL: tags
□ Criteria are at STRONG level (action + expected result + failure signal)
□ Done section exists (with completed items)
□ Future Improvements section exists
□ Dependency mapping (depends:/parallel:) is optional but noted
```

**For existing tasks without these fields:** Add them based on the task description and your understanding of the codebase. Mark additions with `← added during adaptation` so the user can review.

**Step 2.4 — Upgrade code-reviewer agent:**

Check for:
```
□ Frontmatter with effort: medium
□ Project Patterns section
□ Type Safety section
□ API / Data Mutation Patterns section
□ Performance section
□ Security section (references security-reviewer)
□ Architecture Patterns section (populated, not empty)
□ Known Bug Patterns section (populated from git history)
```

**Seed Known Bug Patterns from git history:**
If the Known Bug Patterns section is empty or sparse, analyze the git log fix commits (from Step 1.3) and the codebase to propose initial patterns:
```bash
# Read recent fix commits for pattern extraction
git log --oneline --all | grep -iE "fix|bug|hotfix|patch" | head -10
```
For each fix: ask "could this recur?" If yes, add the CORRECT pattern (not the mistake).

**Step 2.5 — Upgrade security-reviewer:**

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

If they exist: verify they have effort: high in frontmatter, tiered test structure (Tier 1/2/3), and the Tier 3 MANDATORY STOP protocol. Add if missing.

If they don't exist: assess the PRD (once created in Phase 3) for risk indicators. If the project has auth, payments, multi-tenancy, AI/LLM, or PII → create them.

**Step 2.7 — Verify rules files:**

Read each rules file. No structural changes needed — rules files are project-specific. Just verify they are referenced from the code-reviewer's Security section or relevant agent.

**Step 2.8 — Verify skills:**

Read each skill. Verify frontmatter has `effort:` field. Add if missing (most skills are `effort: medium`; security-related are `effort: high`).

---

### Phase 3 — Create Retroactive PRD

The PRD does not need to be speculative — it describes what already exists plus what is planned.

Create `assets/docs/prd.md` with this approach:

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
| 1.0 | [date] | Retroactive PRD — created from codebase analysis during framework adaptation | AI + [owner] |
```

**After creating the PRD:** update CLAUDE.md/GEMINI.md to reference it (`**PRD:** See assets/docs/prd.md`).

---

### Phase 4 — Copy Examples and Fill Gaps

**Step 4.1 — Copy framework examples (if not already present):**

```bash
# Check if examples exist
ls assets/examples/ 2>/dev/null || echo "MISSING"
```

If missing and framework root is accessible:
```bash
cp -r ../../examples/ assets/examples/ 2>/dev/null || echo "Framework examples not accessible — skip, copy manually later"
```

If framework root is not accessible: note in the report that `assets/examples/` should be copied manually.

**Step 4.2 — Create settings.json and initialize logs (if missing):**

```bash
# Create logs directory
mkdir -p .claude/logs 2>/dev/null || mkdir -p .antigravity/logs 2>/dev/null

# Create settings.json if missing (Claude Code only)
if [ ! -f ".claude/settings.json" ] && [ -d ".claude" ]; then
  cat > .claude/settings.json << 'SETTINGS'
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

**Step 4.3 — Verify MCP configuration:**

List installed MCPs and compare against the stack:
```bash
cat .claude/settings.json 2>/dev/null | grep -A5 "mcpServers"
# Or check for MCP config in settings.local.json
cat .claude/settings.local.json 2>/dev/null
```

Report which MCPs are installed and whether any are missing based on the stack.

---

### Phase 5 — Validation and Report

**Step 5.1 — Run consistency check:**

```bash
echo "=== File structure ==="
find .claude -name "*.md" -o -name "*.json" | sort

echo "=== CLAUDE.md references valid files? ==="
# Check that referenced paths exist
grep -oP '`[^`]*\.md`' CLAUDE.md | sort -u | while read ref; do
  path=$(echo "$ref" | tr -d '`')
  [ ! -f "$path" ] && echo "BROKEN REF: $path"
done

echo "=== PRD exists? ==="
ls assets/docs/prd.md 2>/dev/null && echo "YES" || echo "NO"

echo "=== All agents have effort: frontmatter? ==="
for f in .claude/agents/*.md; do
  grep -q "effort:" "$f" 2>/dev/null || echo "MISSING effort: in $f"
done

echo "=== All skills have effort: frontmatter? ==="
find .claude/skills -name "*.md" -o -name "SKILL.md" 2>/dev/null | while read f; do
  grep -q "effort:" "$f" 2>/dev/null || echo "MISSING effort: in $f"
done
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
- [any other new files]

### Preserved (not modified):
- [N] session entries in project.md
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

### PRD version: v1.0 (retroactive)

### Next session should:
- Review TBD sections in PRD
- [first item from pendencias]
```

---

## Quick Reference: What this prompt does vs session0

| Aspect | session0 (greenfield) | This prompt (existing project) |
|--------|----------------------|-------------------------------|
| Reads codebase | No code exists | Full codebase scan + git history |
| Creates docs | From scratch | Upgrades existing, fills gaps |
| PRD | Must exist beforehand | Created retroactively from code |
| Known Bug Patterns | Empty | Seeded from git fix history |
| Architecture Patterns | Empty | Populated from codebase structure |
| Session entries | Session 0 only | All existing entries preserved |
| Rules files | Planned for future | Already exist — verified, not modified |
| Session logs | Empty `.claude/logs/` created | Empty `.claude/logs/` created (same) |
| Hooks | smart-formatting configured | smart-formatting added if Prettier present |
| File naming | Standard names | Adapts to non-standard names |