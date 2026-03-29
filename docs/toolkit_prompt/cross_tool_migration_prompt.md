# Cross-Tool Migration Prompt

Use this prompt when you need to switch AI tools mid-project (e.g., Claude Code rate limits hit, want to try Antigravity, or switching between tools for different task types).

Works bidirectionally: Claude Code → Antigravity or Antigravity → Claude Code.

---

## Prompt

```
## Cross-Tool Migration

I need to migrate this project's Agentic Engineering setup from [SOURCE TOOL] to [TARGET TOOL].

The project content (rules, skills, phases, agents) must be preserved. Only the folder structure and config files change.

Execute in order.

---

### Step 1 — Identify current setup

Scan the project for existing Agentic Engineering files:

```bash
# Check for Claude Code setup
echo "=== Claude Code ==="
ls -la CLAUDE.md 2>/dev/null
ls -la .claude/phases/ 2>/dev/null
ls -la .claude/rules/ 2>/dev/null
ls -la .claude/agents/ 2>/dev/null
ls -la .claude/skills/ 2>/dev/null

# Check for Antigravity setup
echo "=== Antigravity ==="
ls -la GEMINI.md 2>/dev/null
ls -la AGENTS.md 2>/dev/null
ls -la .antigravity/phases/ 2>/dev/null
ls -la .antigravity/rules/ 2>/dev/null
ls -la .antigravity/skills/ 2>/dev/null
```

Report what exists.

---

### Step 2 — Create target structure

**If migrating TO Antigravity (from Claude Code):**

```bash
# Create Antigravity directory structure
mkdir -p .antigravity/phases
mkdir -p .antigravity/rules
mkdir -p .antigravity/skills/code-reviewer
mkdir -p .antigravity/skills/security-reviewer

# Copy phases (content is identical, just different location)
cp .claude/phases/project.md .antigravity/phases/project.md
cp .claude/phases/pendencias.md .antigravity/phases/pendencias.md 2>/dev/null
# Handle non-standard backlog naming (copy first match)
for f in .claude/phases/pendencias*.md; do
  [ -f "$f" ] && [ "$(basename "$f")" != "pendencias.md" ] && cp "$f" .antigravity/phases/pendencias.md 2>/dev/null && break
done

# Copy rules (identical content)
cp .claude/rules/*.md .antigravity/rules/

# Convert agents to skills (Antigravity uses skills, not agents)
# code-reviewer agent becomes code-reviewer skill
cp .claude/agents/code-reviewer.md .antigravity/skills/code-reviewer/SKILL.md
# security-reviewer agent becomes security-reviewer skill
cp .claude/agents/security-reviewer.md .antigravity/skills/security-reviewer/SKILL.md 2>/dev/null
# red-team and blue-team agents become skills (conditional — may not exist)
if [ -f ".claude/agents/red-team.md" ]; then
  mkdir -p .antigravity/skills/red-team
  cp .claude/agents/red-team.md .antigravity/skills/red-team/SKILL.md
fi
if [ -f ".claude/agents/blue-team.md" ]; then
  mkdir -p .antigravity/skills/blue-team
  cp .claude/agents/blue-team.md .antigravity/skills/blue-team/SKILL.md
fi
# validator and arbitrator agents become skills (mandatory — should exist)
if [ -f ".claude/agents/validator.md" ]; then
  mkdir -p .antigravity/skills/validator
  cp .claude/agents/validator.md .antigravity/skills/validator/SKILL.md
fi
if [ -f ".claude/agents/arbitrator.md" ]; then
  mkdir -p .antigravity/skills/arbitrator
  cp .claude/agents/arbitrator.md .antigravity/skills/arbitrator/SKILL.md
fi

# Copy any other skills (handle both flat and folder formats)
# Flat format: .claude/skills/name.md → .antigravity/skills/name/SKILL.md
for skill in .claude/skills/*.md; do
  if [ -f "$skill" ]; then
    name=$(basename "$skill" .md)
    mkdir -p ".antigravity/skills/$name"
    cp "$skill" ".antigravity/skills/$name/SKILL.md"
  fi
done
# Folder format: .claude/skills/name/SKILL.md → .antigravity/skills/name/SKILL.md
for skill_dir in .claude/skills/*/; do
  name=$(basename "$skill_dir")
  if [ -f "$skill_dir/SKILL.md" ]; then
    mkdir -p ".antigravity/skills/$name"
    cp "$skill_dir/SKILL.md" ".antigravity/skills/$name/SKILL.md"
  fi
done

# Copy examples (identical content, same location — shared at project root)
# assets/examples/ is tool-agnostic and does not move between .claude/ and .antigravity/
# Just verify it exists:
ls assets/examples/ 2>/dev/null && echo "assets/examples/ present" || echo "WARNING: assets/examples/ not found"

# Copy session logs (permanent record — must be preserved)
if [ -d ".claude/logs" ]; then
  mkdir -p .antigravity/logs
  cp .claude/logs/*.md .antigravity/logs/ 2>/dev/null
  echo "Session logs copied: $(ls .claude/logs/*.md 2>/dev/null | wc -l) files"
fi
```

**If migrating TO Claude Code (from Antigravity):**

```bash
# Create Claude Code directory structure
mkdir -p .claude/phases
mkdir -p .claude/rules
mkdir -p .claude/agents
mkdir -p .claude/skills

# Copy phases
cp .antigravity/phases/project.md .claude/phases/project.md
cp .antigravity/phases/pendencias.md .claude/phases/pendencias.md

# Copy rules
cp .antigravity/rules/*.md .claude/rules/

# Convert skills to agents (for code-reviewer, security-reviewer, red-team, blue-team) and skills (for others)
if [ -f ".antigravity/skills/code-reviewer/SKILL.md" ]; then
  cp .antigravity/skills/code-reviewer/SKILL.md .claude/agents/code-reviewer.md
fi
if [ -f ".antigravity/skills/security-reviewer/SKILL.md" ]; then
  cp .antigravity/skills/security-reviewer/SKILL.md .claude/agents/security-reviewer.md
fi
if [ -f ".antigravity/skills/red-team/SKILL.md" ]; then
  cp .antigravity/skills/red-team/SKILL.md .claude/agents/red-team.md
fi
if [ -f ".antigravity/skills/blue-team/SKILL.md" ]; then
  cp .antigravity/skills/blue-team/SKILL.md .claude/agents/blue-team.md
fi
if [ -f ".antigravity/skills/validator/SKILL.md" ]; then
  cp .antigravity/skills/validator/SKILL.md .claude/agents/validator.md
fi
if [ -f ".antigravity/skills/arbitrator/SKILL.md" ]; then
  cp .antigravity/skills/arbitrator/SKILL.md .claude/agents/arbitrator.md
fi

# Copy other skills (preserve Anthropic folder format)
for skill_dir in .antigravity/skills/*/; do
  name=$(basename "$skill_dir")
  if [ "$name" != "code-reviewer" ] && [ "$name" != "security-reviewer" ] && [ "$name" != "red-team" ] && [ "$name" != "blue-team" ] && [ "$name" != "validator" ] && [ "$name" != "arbitrator" ] && [ -f "$skill_dir/SKILL.md" ]; then
    mkdir -p ".claude/skills/$name"
    cp "$skill_dir/SKILL.md" ".claude/skills/$name/SKILL.md"
  fi
done

# Verify examples (identical content, same location — shared at project root)
# assets/examples/ is tool-agnostic and does not move between .claude/ and .antigravity/
ls assets/examples/ 2>/dev/null && echo "assets/examples/ present" || echo "WARNING: assets/examples/ not found"

# Copy session logs (permanent record — must be preserved)
if [ -d ".antigravity/logs" ]; then
  mkdir -p .claude/logs
  cp .antigravity/logs/*.md .claude/logs/ 2>/dev/null
  echo "Session logs copied: $(ls .antigravity/logs/*.md 2>/dev/null | wc -l) files"
fi
```

---

### Step 3 — Create/update config file

**If migrating TO Antigravity:**

Read the existing `CLAUDE.md` and create `GEMINI.md` with the same content, adapting:
- All `.claude/` paths → `.antigravity/`
- "CLAUDE.md" self-references → "GEMINI.md"
- `.claude/agents/code-reviewer.md` → `.antigravity/skills/code-reviewer/SKILL.md`
- Add Antigravity-specific: Planning Mode references, Browser Subagent instead of Playwright MCP
- Remove Claude Code-specific: `npx @anthropic-ai/claude-code mcp add` commands

Also create `AGENTS.md` for cross-tool compatibility:
```markdown
# AGENTS.md

This project uses the Agentic Engineering Framework.
Primary configuration is in GEMINI.md (Antigravity-native).

For any AI agent: read GEMINI.md for full context.
```

**If migrating TO Claude Code:**

Read the existing `GEMINI.md` and create `CLAUDE.md` with the same content, adapting:
- All `.antigravity/` paths → `.claude/`
- "GEMINI.md" self-references → "CLAUDE.md"
- `.antigravity/skills/code-reviewer/SKILL.md` → `.claude/agents/code-reviewer.md`
- Browser Subagent references → Playwright MCP
- Add `npx @anthropic-ai/claude-code mcp add` commands for MCP installation
- Remove Antigravity-specific: Planning Mode artifacts, Agent Manager references

Also create `.claude/settings.json` if it does not exist:
```json
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
  }
}
```

**Note:** This is a minimal settings.json. If the source project had hooks (e.g., smart-formatting), add them manually — hooks are not transferable between tools.

---

### Step 4 — Update internal references

Scan ALL migrated markdown files and update paths:

```bash
# If migrated TO Antigravity:
find .antigravity -name "*.md" -exec grep -l "\.claude/" {} \;
# For each file found: replace .claude/ with .antigravity/
# Replace CLAUDE.md references with GEMINI.md

# If migrated TO Claude Code:
find .claude -name "*.md" -exec grep -l "\.antigravity/" {} \;
# For each file found: replace .antigravity/ with .claude/
# Replace GEMINI.md references with CLAUDE.md
```

Also update references in:
- `project.md` session entries (paths mentioned in logs)
- `pendencias.md` task descriptions (if they reference specific paths)
- `rules/*.md` files (if they reference other docs by path)
- All agents/skills (`validator.md`, `arbitrator.md`, `code-reviewer.md`, `security-reviewer.md`, etc.) — update `.claude/` ↔ `.antigravity/` and `CLAUDE.md` ↔ `GEMINI.md` in Input sections, BOUNDARIES sections, and context routing paths

---

### Step 5 — Configure MCPs in target tool

MCPs cannot be migrated — they must be reconfigured in the target tool.

Read the "MCP Servers" section from the source config file (CLAUDE.md or GEMINI.md) and install each one in the target tool:

**If target is Antigravity:**
- Open Antigravity Settings → MCP Servers
- Add each MCP from the list with appropriate credentials
- Browser testing: NOT needed as MCP — Antigravity has native Browser Subagent

**If target is Claude Code:**
- Install each MCP via CLI:
  ```bash
  npx @anthropic-ai/claude-code mcp add [name] -- [command]
  ```
- Install Playwright MCP for browser testing (not native in Claude Code):
  ```bash
  npx @anthropic-ai/claude-code mcp add playwright -- npx -y @anthropic-ai/mcp-server-playwright
  ```

---

### Step 6 — Verify migration

```bash
# === Verify target structure ===
# If migrated TO Claude Code:
find .claude -name "*.md" | sort
grep "Session Protocol" CLAUDE.md
grep -r ".antigravity/" .claude/ 2>/dev/null  # Should return nothing
grep "GEMINI.md" CLAUDE.md 2>/dev/null        # Should return nothing

# If migrated TO Antigravity:
find .antigravity -name "*.md" | sort
grep "Session Protocol" GEMINI.md
grep -r ".claude/" .antigravity/ 2>/dev/null  # Should return nothing
grep "CLAUDE.md" GEMINI.md 2>/dev/null        # Should return nothing
```

---

### Step 7 — Add session entry

Add a migration session entry to the target project.md:

```markdown
### [date] — Migration Session ([source] → [target])

**What was done:**
- Migrated Agentic Engineering setup from [source tool] to [target tool]
- Copied: phases, rules, skills/agents, logs
- Created: [GEMINI.md|CLAUDE.md] adapted from [CLAUDE.md|GEMINI.md]
- Reconfigured MCPs: [list]
- Updated internal path references

**Source files preserved:** [YES — source .claude/.antigravity folder kept as backup | NO — deleted after verification]

**PRD version:** v[X.X.X] (unchanged — migration does not affect product scope)

**Next step:** [continue with next task from pendencias.md]
```

---

### Step 8 — Decision: keep or remove source files?

Options:
- **Keep both:** Source folder remains as backup. No risk, minor clutter. Recommended for first migration.
- **Remove source:** Delete source folder after verifying target works. Cleaner. Recommended after confirming target tool works for 2-3 sessions.
- **Keep config files only:** Remove source folders but keep both CLAUDE.md and GEMINI.md (if project might switch back).

ASK the user which option they prefer.
```

---

## Quick Reference: What maps to what

| Claude Code | Antigravity | Content identical? |
|------------|-------------|-------------------|
| `CLAUDE.md` | `GEMINI.md` | Same structure, different paths and tool-specific sections |
| (none) | `AGENTS.md` | Cross-tool compat file (Antigravity creates it) |
| `.claude/phases/project.md` | `.antigravity/phases/project.md` | ✅ Identical content, different path |
| `.claude/phases/pendencias.md` | `.antigravity/phases/pendencias.md` | ✅ Identical content |
| `.claude/rules/*.md` | `.antigravity/rules/*.md` | ✅ Identical content |
| `.claude/agents/code-reviewer.md` | `.antigravity/skills/code-reviewer/SKILL.md` | Same content, different format convention |
| `.claude/agents/security-reviewer.md` | `.antigravity/skills/security-reviewer/SKILL.md` | Same content, different format convention |
| `.claude/agents/red-team.md` (conditional) | `.antigravity/skills/red-team/SKILL.md` (conditional) | Same content, different format. Only exists if PRD has high-risk features |
| `.claude/agents/blue-team.md` (conditional) | `.antigravity/skills/blue-team/SKILL.md` (conditional) | Same content, different format. Only exists if PRD has high-risk features |
| `.claude/agents/validator.md` (mandatory) | `.antigravity/skills/validator/SKILL.md` (mandatory) | Same content, different format. Independent validation agent |
| `.claude/agents/arbitrator.md` (mandatory) | `.antigravity/skills/arbitrator/SKILL.md` (mandatory) | Same content, different format. Conflict resolution agent |
| `.claude/skills/*/SKILL.md` | `.antigravity/skills/*/SKILL.md` | ✅ Identical content and format (both use Anthropic folder format) |
| `.claude/settings.json` | Antigravity Settings UI | Not transferable — reconfigure manually |
| MCPs via `claude mcp add` | MCPs via Settings UI | Same MCPs, different install method |
| Playwright MCP (external) | Browser Subagent (native) | Same capability, Antigravity doesn't need MCP |
| `assets/examples/` | `assets/examples/` | ✅ Identical content, same path (tool-agnostic, lives at project root) |
| `.claude/logs/*.md` | `.antigravity/logs/*.md` | ✅ Identical content, different path (session logs preserved during migration) |

**Frontmatter preservation:** When migrating agents/skills, preserve all frontmatter fields including `invocation:`, `receives:`, `produces:`, and **lineage fields** (`created:`, `last_eval:`, `fixes:`, `derived_from:`). These define the subagent I/O contract and evolution history — they are tool-agnostic and apply to both Claude Code (Task tool) and Antigravity (Agent Manager). Only path references inside the content need updating (`.claude/` ↔ `.antigravity/`, `CLAUDE.md` ↔ `GEMINI.md`).

**Process skills (v1.6.0):** The 10 pre-built process skills (prd-sync-checker, sprint-proposer, criteria-enforcer, validation-orchestrator, diff-pattern-extractor, project-md-updater, pendencias-updater, claude-md-updater, rules-agents-updater, session-log-creator) migrate by copying from `.claude/skills/` to `.antigravity/skills/` (or vice versa). The skills use generic relative paths internally — the agent interprets `.claude/` paths as `.antigravity/` equivalents automatically.

## When to migrate vs when to start fresh

| Situation | Recommendation |
|-----------|---------------|
| Rate limits hit mid-task | Migrate — preserve context, continue immediately |
| Trying a different tool for evaluation | Migrate — compare tools with same project context |
| Starting a completely new project | Don't migrate — use the appropriate session0 prompt directly |
| Switching permanently after evaluation | Migrate, then remove source after 2-3 sessions |