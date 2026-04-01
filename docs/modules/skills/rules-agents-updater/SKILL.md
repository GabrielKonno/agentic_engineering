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

### 0. Check cross-session signals

Read the Domain Signals table in project.md.

For each domain with status `active`:
- If **2+ sessions** listed AND type is `logic` → evaluate whether a rules file should be created (same criteria as Step 1: is the domain a core feature? are there enough business rules to justify a dedicated file?)
- If **2+ sessions** listed AND type is `process` → evaluate whether a skill should be created (same criteria as Step 4: is the process complex enough? will it recur?)

If a rules file or skill IS created from a domain signal:
1. Create the rules file/skill following the existing process (Steps 1 or 4)
2. Update the Domain Signals row status in project.md: `active` → `→ .claude/rules/[domain]-rules.md` or `→ .claude/skills/[name]/`

If the domain has 2+ sessions but does NOT yet justify a rules file (e.g., only 1 business rule so far): leave as `active`. The signal keeps accumulating.

### 1. Rules files — create or update

**Create a new rules file when:**
- A module has 3+ business rules affecting code
- Domain Signals table shows 2+ sessions for a domain (detected in Step 0)
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

**After creating — run creation eval:**
- **Subagent agents** (`invocation: subagent`): Generate 2 test scenarios (one with issue agent should detect, one clean). Spawn via Task tool against each. Verify: issue detected + no false flags. Update lineage: `last_eval: sN (2/2 passed)`. If eval fails: improve and re-test.
- **Skills** (`invocation: inline`): If Skill Creator plugin is installed, use it for eval (automates test case generation, grading, iteration). If not installed: skip eval for inline skills (knowledge references, not judgment agents).
- **Deferrable:** If context window is low, log "Eval deferred to session N" and set `last_eval: none (deferred)`.

### 5. Log evolutions

`"[FIX/DERIVED/CAPTURED]: [component] — [what changed and why]"`

Check evolution approval boundaries (see `.claude/rules/evolution-policy.md`) before applying. For human-approval items, propose in session log and wait.

**Re-eval after FIX:** When a FIX evolution modifies a subagent agent, re-run creation eval with original scenarios + 1 new scenario targeting the specific failure that triggered the FIX. All must pass. Update `last_eval:` and append to `fixes:` in frontmatter. DERIVED/CAPTURED evolutions do NOT require re-eval (source patterns already validated or diff is evidence).

### 6. Validate activation chains

After creating or modifying any specialist agent (Step 4), verify the activation chain is complete. Skip this step if the agent is a process agent (criteria-enforcer, diff-pattern-extractor, prd-sync-checker) or a core reviewer (code-reviewer, security-reviewer, validator, arbitrator, red-team, blue-team).

For each specialist agent created or modified:

1. **Gap declaration exists?** — The appropriate reviewer (code-reviewer or security-reviewer) must have a Coverage Gap Declaration paragraph whose domain vocabulary matches the agent's Pushy Description. If missing: add it now, following the existing conditional format (`**If diff touches [trigger]:**` + blockquote with gap phrase + `Recommend: search .claude/agents/`).
2. **Pushy Description echoes vocabulary?** — The agent's `description:` frontmatter must include `"when [reviewer] declares a [domain] gap"` using the same domain noun that the reviewer uses. If mismatched: fix the description now.
3. **Vocabulary alignment grep** — Run: `grep -l "[domain keyword]" .claude/agents/*.md` and verify the specialist appears in results AND the reviewer's gap declaration appears in results. If either is missing: the chain is broken — fix before continuing.

See `.claude/rules/component-design.md` sections 1-3 for the full activation architecture reference.

### 7. Track activation efficacy (periodic)

Every ~10 sessions or during maintenance sessions, review activation chain health:

1. **Gap declarations activated?** — For each Coverage Gap Declaration in code-reviewer.md and security-reviewer.md, check session logs for evidence the gap was triggered and a specialist was spawned. Track using: `[gap: domain | activated: sN, sN | never-activated: true]`
2. **Never-activated gaps** (10+ sessions with no trigger) — Either the specialist domain is rare for this project (acceptable) or the gap vocabulary is mismatched and never matches (fix the chain).
3. **Post-mortem correlation** — If a Validation Failure Post-Mortem identified "review missed pattern" or "subagent context incomplete" as root cause, check whether a gap declaration or specialist agent could have caught it. If yes: add the gap declaration and/or create the specialist agent now.

This step reuses the same `[added: sN | triggered: sN]` tracking convention as Known Bug Patterns in code-reviewer.md.
