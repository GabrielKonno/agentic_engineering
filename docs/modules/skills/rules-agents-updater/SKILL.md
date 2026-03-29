---
name: rules-agents-updater
invocation: inline
effort: medium
description: >
  Updates rules files, agents, skills, and PRD at end of session. Creates new rules
  files when domain logic accumulates. Updates existing agents with session discoveries.
  MUST evaluate at end of every session (item 5). Without this, agents and rules
  become stale and stop matching the project's actual patterns.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol end-of-session item 5
---

# Rules, Agents, and Skills Updater

## When to run
At the END of every session, after config-file-updater.

## Process

### 1. Rules files — create or update

**Create a new rules file when:**
- A module has 3+ business rules affecting code
- Same logic referenced 2+ times across sessions
- A bug was caused by domain misunderstanding
- 3+ Known Bug Patterns are from the same domain (DERIVED promotion)

**Format:** See `assets/examples/rules/` for reference templates.
**Path:** `.claude/rules/[domain]-rules.md`

### 2. Update existing agents and skills

For each discovery from this session, ask: "If I were starting a new session and reading this agent/skill, would I miss the pattern I just discovered?" If yes, add it now:

- New RLS edge case → add to red-team.md (new Tier 1 or Tier 2 test)
- Framework pitfall → add to stack skill (new pitfall entry)
- New attack vector → add to security-reviewer.md (new checklist item)
- Verified defense → update blue-team.md Defense Inventory

### 3. Update PRD (rare)
ONLY if product scope changed. Always update changelog with new version. Log: "PRD updated to vX.Y"

### 4. Create skills or agents on-demand

**Reactive (pattern repeated):** A complex process was executed 2+ times and will recur.
- **Skill:** migration steps, deploy pipeline, data import
- **Agent:** specialized review role (performance-auditor, accessibility-checker)

**Proactive (predictable from context):** PRD, stack, or domain makes it predictable.
- New framework with specific patterns
- New domain with known conventions

**Before creating:**
1. Read `assets/examples/examples_instructions.md` for conventions
2. Check if relevant example exists in `assets/examples/`
3. If found: use as structural template — adapt to project
4. If not: create from scratch following conventions

**Frontmatter requirements:** `effort:`, `invocation:`, `receives:`/`produces:` (subagent only), lineage fields.

**Creation eval (subagent agents only):** 2 test scenarios. Update `last_eval` in lineage. DEFERRABLE if context is low.

**Do NOT create if:** one-time pattern, rules file more appropriate, Known Bug Pattern suffices, duplicates existing content, or contradicts patterns in config/rules.

### 5. Auto-evolution boundaries check

Before applying any update, check:
- Changes DATA (what agent knows) → apply autonomously
- Changes BEHAVIOR (how agent acts) → propose in session log, wait for human approval

### 6. Log evolutions
`"[FIX/DERIVED/CAPTURED]: [component] — [what changed and why]"` or
`"Created skill/agent: [name] — [trigger: proactive/reactive]"`
