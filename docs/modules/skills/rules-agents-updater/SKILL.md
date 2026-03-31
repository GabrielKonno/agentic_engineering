---
name: rules-agents-updater
invocation: inline
effort: medium
description: >
  Updates rules files, agents, skills, and PRD at end of session when domain
  discoveries or pattern changes occurred. Creates new rules files when domain
  logic accumulates. MUST evaluate at end of every session (item 5). Without this,
  agents and rules become stale and stop matching the project's actual patterns.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol end-of-session item 5
---

# Rules, Agents, and Skills Updater

## When to run
At the END of every session, after config-file-updater. Only if domain discoveries, pattern changes, or new rules emerged this session. If nothing to update, skip.

## Process

### 1. Rules files — create or update

**Create a new rules file when:**
- A module has 3+ business rules affecting code
- Same logic referenced 2+ times across sessions
- A bug was caused by domain misunderstanding
- 3+ Known Bug Patterns from same domain (DERIVED promotion)

Path: `.claude/rules/[domain]-rules.md`. See `assets/examples/rules/` for reference templates.

### 2. Update existing agents and skills

For each discovery: "If I were reading this agent/skill in a new session, would I miss the pattern I just found?" If yes, add it now. Route discoveries to the appropriate agent or skill based on the type of finding.

### 3. Update PRD (rare)

ONLY if product scope changed. Always update changelog with new version.

### 4. Create skills or agents on-demand

**When:** A complex process was executed 2+ times and will recur (skill), or a specialized review role is needed (agent).

Check `assets/examples/` for conventions and structural templates before creating. Frontmatter must include `effort:`, `invocation:`, and lineage fields.

**Do NOT create if:** one-time pattern, rules file more appropriate, Known Bug Pattern suffices, or duplicates existing content.

### 5. Log evolutions

`"[FIX/DERIVED/CAPTURED]: [component] — [what changed and why]"`

Check evolution approval boundaries (see `.claude/rules/evolution-policy.md`) before applying. For human-approval items, propose in session log and wait.
