---
domain: component-design
applies_to: "docs/modules/agents/**,docs/modules/skills/**,docs/modules/rules/**,examples/agents/**,examples/skills/**,examples/rules/**"
---

# Component Design Policy

## 1. Activation Architecture — Gap-Declaration

Specialist agents are activated through gap declarations, not hardcoded routing.

**Flow:** Reviewer agent (code-reviewer, security-reviewer) declares what it CANNOT
fully cover → main Claude reads the gap declaration in the report → searches
`.claude/agents/` descriptions for a matching specialist → spawns if found.

**Why this exists:** Subagents cannot spawn other subagents (Claude Code hard limit).
The reviewer cannot call the specialist directly. Gap declarations bridge this by
routing activation through main Claude.

**When adding a new specialist domain:**
1. Add a gap declaration to the appropriate reviewer using the specialist's key vocabulary
2. Create the agent with a Pushy Description that echoes that vocabulary
3. Add a "When spawned" section explaining context needs and report outcomes
4. Zero changes to orchestration (validation-orchestrator) needed

## 2. Pushy Description Pattern

Agent descriptions must communicate both PURPOSE and ACTIVATION. Structure:

```
[Core function — what the agent does, how it does it, what value it adds].
USE PROACTIVELY when [trigger conditions]
  or when [reviewer] declares a [domain] gap.
NOT needed for [exclusions].
Without this, [consequence of skipping].
Produces [Report Name] → [OUTCOME_A / OUTCOME_B].
```

**Core function line (MANDATORY):** One sentence explaining what the agent does and
its methodology. Without this, the description is a trigger with no substance —
Claude knows WHEN to activate but not WHAT it's activating or WHY it's valuable.

Example: "Audits concurrent database operations for race conditions using
transaction isolation analysis, lock pattern verification, and controlled
parallel request probes."

**Activation lines:**
- The gap phrase MUST echo the reviewer's gap declaration verbatim
- Trigger conditions should name specific file types or code patterns
- Exclusions prevent false activation on unrelated diffs

**Anti-pattern:** Descriptions that are ONLY triggers ("USE PROACTIVELY when X.
NOT needed for Y. Without this Z.") with no statement of what the agent actually
does. This loses information compared to a plain description.

## 3. Vocabulary Alignment

The activation chain has three layers that must use matching vocabulary:

| Layer | Produces | Key phrase |
|-------|----------|------------|
| validation-orchestrator | Reads gap declarations from reports | "Coverage Gap Declaration" |
| Reviewer (code-reviewer, security-reviewer) | Gap declaration in report | "X gap: ... Recommend: search .claude/agents/" |
| Specialist agent | Pushy Description | "when [reviewer] declares a X gap" |

If vocabulary breaks at ANY link, the specialist exists but is never spawned.

**Verification:** After adding or modifying a gap declaration, grep for the gap
phrase in the specialist agent's description. The match must be exact or near-exact.

## 4. Agent vs Rule — Tiered Decision

| Check types needed | Create | Why |
|-------------------|--------|-----|
| Code inspection only (REVIEW:) | Rules-Driven Check in code-reviewer + rules file | Code-reviewer already reads the diff; no extra context cost |
| Code inspection + DB queries (REVIEW: + QUERY:) | Standalone agent | Needs to execute queries that code-reviewer cannot |
| Code inspection + DB queries + controlled probes (REVIEW: + QUERY: + VERIFY:) | Standalone agent with tier-3 | Needs human approval for destructive/invasive probes |

Do NOT create standalone agents for checks that are purely code-review-level.
Each standalone agent costs 15-25k tokens for separate context.

**Rules-Driven Checks** activate conditionally when a corresponding rules file
exists in the project (e.g., scheduling checks activate only when
`.claude/rules/scheduling-rules.md` exists). This makes them zero-cost for
projects that don't need them.

## 5. Content Modification — Preservar + Adicionar

When modifying existing agents, skills, or rules:

**Default: Preserve + Add.** Append new sections. Never remove or rewrite
sections that contain useful information.

**Substitution allowed** when ALL of:
1. The substitution represents a REAL, PRACTICAL improvement (not cosmetic)
2. NO information or relevant data is lost
3. The new content is strictly better than what it replaces

**Deletion allowed** when:
1. The content is provably unused (no triggers, no references)
2. The content duplicates what exists elsewhere
3. The content conflicts with current architecture

When planning changes, classify each as: ADD (new section — default),
SUBSTITUTE (replace — must justify), DELETE (remove — must justify), or
RELOCATE (move to another component — must justify, and see below).

### RELOCATE — extracting content into another component

An EXTRACTION (content leaving one component to live in another) is neither an ADD nor a DELETE:
the content survives, but its home changes. It is the operation that produces a component split,
and it has one rule that decides whether the split helps or hurts:

**The SOURCE component ALWAYS POINTS at the relocated content — it NEVER restates it.** Two
copies of a mandate is the failure §9 describes one level up: the next editor fixes one home and
the other silently diverges. A pointer that names the target component and the section is the
whole obligation.

**When relocating, ALWAYS:**
1. **NAME what stays SHARED** and point at it from the new component, rather than duplicating it.
2. **SWEEP every INVOKER of the moved content** — every component that referenced it by section
   name now cites a heading in a different file (component-design §9: the instruction to invoke X
   belongs to whoever executes the moment X runs, and that invoker just moved).
3. **RUN the inventory sweep for the NEW component** (counts, indexes, install lists in BOTH
   command twins) — a split ADDS an artifact even though nothing was created from scratch.
4. **REPORT the classification** — `relocated: [what] from [source] to [target]; source now points`.

## 6. Instruction Writing — Imperative over Descriptive

Instructions inside agents, skills, and rules that need to produce **consistent behavior**
MUST follow the trigger–action–format pattern. Descriptive text explains mechanisms;
imperative text drives action. Both are valid — but only imperatives fire reliably.

**Pattern:**
```
When [trigger situation], ALWAYS [action verb] with:
- **Field 1:** [what to include]
- **Field 2:** [what to include]
```

**Three properties of a reliable behavioral instruction:**
1. **Imperative verb in CAPS** — "ALWAYS include", "MUST produce", "NEVER omit"
2. **Dedicated section** — not buried inside a mechanism description or rationale paragraph
3. **Explicit output format** — fields/columns that make omission structurally visible

| Writing style | Example | Behavior |
|---------------|---------|----------|
| Descriptive (informational) | "AI recommends `/effort high` in plan" | Understood but inconsistently applied |
| Imperative (behavioral) | "ALWAYS include Model, Effort, and Justification for each task" | Reliably triggers action |

**When to use each:**
- **Descriptive:** explaining WHY a mechanism exists, how components interact, architectural rationale
- **Imperative:** any step the AI must execute every time — output fields, checks, format requirements

**Anti-pattern:** Burying a behavioral requirement inside a mechanism explanation.
"The system uses X to achieve Y" reads as documentation. If X must happen every time,
give it its own line: "ALWAYS do X."

**Applies to:** process steps in skills, checklist items in agents, constraint rules
in rules files — any instruction where inconsistent execution causes a bug.

**Banned process anti-patterns need a MECHANICAL self-check.** When an evolution BANS a
process anti-pattern (not a code one), the textual prohibition is not enough — the executor
operates under end-of-session context pressure, and the anti-pattern is usually the path of
least resistance. Attach to the rule a one-line mechanical self-check (a grep/count with an
explicit expected result), executed and REPORTED by the very step the rule governs. Evidence
(production project, 2026-07): the exact prohibition of a backlog anti-pattern lived as
normative text inside the executing skill and still failed for ~50 sessions, costing two mass
cleanups. Code checks (lint, type ratchets) already follow this discipline — process checks
must too.

## 7. Native Mechanisms — Don't Reinvent

Claude Code provides these natively — do not build custom replacements:

| Mechanism | What it does | Don't build |
|-----------|-------------|-------------|
| `description:` frontmatter | Semantic discovery of agents/skills | Routing tables, activation registries |
| Agent tool isolation | Fresh context per subagent | Context sharing between subagents |
| Rules `paths:` globs | Lazy loading per file pattern | Manual conditional loading |
| CLAUDE.md auto-read | Loaded every session | "Read project config" steps in skills |

**Subagent depth limit:** Only main Claude can use the Agent tool. Design
activation flows that route through main Claude's report reading, not through
direct agent-to-agent calls.

## 8. Component Frontmatter — invalid YAML makes the component VANISH silently (FRAMEWORK-AGENT-YAML-01)

A component's `name:`/`description:` frontmatter is how the harness discovers it (§7). But
the failure mode of BROKEN frontmatter is not an error — it is **silent disappearance**: an
invalid YAML block fails to parse, the harness cannot read `name:`, and the component is
simply ABSENT from the registry. The Agent tool then answers `Agent type '<name>' not found`
and lists the survivors, with **no boot-time error**. "The file exists" is NOT "the component
is in the registry".

**The confirmed instance (2026-07, production project — self-inflicted by a process
improvement):** an automated metadata stamp wrote a `last_eval:` value as an UNQUOTED YAML
scalar containing `: ` (colon-space):

```yaml
last_eval: 2026-07-14 (retrospective — healthy: CLEAN verdict …)   # BROKEN — YAML reads `healthy:` as a nested map
last_eval: "2026-07-14 (retrospective — healthy: CLEAN verdict …)" # FIXED  — quoted scalar
```

It silently disabled the three reviewer agents that ENFORCE rigor, and stayed broken until a
fresh session tried to spawn a mandatory reviewer and failed loud. The registry reloads when
the file is READ, so the break only manifests in a session that reads the broken file at
start — never the session that wrote it.

**Rules (for THIS framework repo and for bootstrapped projects):**
1. **Any frontmatter scalar containing `:` / `#` / a leading `& * ! @ %` — or free-text
   prose — MUST be quoted.** When in doubt, quote it. A stamped metadata value (eval notes,
   dates with parentheticals) is the classic offender.
2. **The mechanical guard lives at `docs/modules/templates/check_agent_frontmatter.md`**
   (extracted to `scripts/check-agent-frontmatter.mjs` in every project at bootstrap Step
   5.7, wired as a CI stage in Step 14.2): it validates every `.claude/agents/*.md` +
   `.claude/skills/*/SKILL.md` frontmatter, asserts `name:` matches the file, and fails loud
   (exit 1) on the colon-space class and on a full YAML-parse failure. In maintenance
   sessions HERE, after editing any skill/agent frontmatter (including this repo's own
   `.claude/skills/`), re-check the frontmatter — quoted scalars, `name:` matching the
   file/dir.
3. **A session that spawns a named agent and gets "Agent type not found" treats it as a
   HARD STOP** — never a silent fallback to a general-purpose agent (projects: see
   session-rules → "Autonomous loop watchdog" and its receipt discipline).

## 9. Activation instructions belong to the INVOKER, never to the INVOKED

A component's `description:` frontmatter is read when the harness builds the REGISTRY (§7) — NOT
when someone needs to REMEMBER to invoke it. A mandate written inside the component that must be
spawned ("runs at the start of every session") is therefore read by nobody: its only reader would
be a session that had already decided to spawn it. **The instruction to invoke X belongs to
whoever executes the moment X must run.**

**When declaring that a component MUST run at some point in the cycle, ALWAYS:**
1. **Write the instruction in the component that OWNS that moment** — the session-start skill, the
   session-end skill, the orchestrator, the command. Cross-referencing it from the invoked
   component's frontmatter is fine as documentation; it is NEVER the only home.
2. **Attach a one-line MECHANICAL self-check** with an explicit expected result (a grep/count),
   executed AND REPORTED by that same step (§6) — normative prose alone does not survive
   end-of-session context pressure.
3. **Require the skip to be SAID.** A conscious skip is legitimate; SILENCE is not — a silence is
   indistinguishable from a forgetting. The invoking step ALWAYS reports "ran — [outcome]" or
   "skipped — [reason]", never nothing.
4. **PROVE the self-check by NEGATION before trusting it.** Run it against a state where it MUST
   go red; a check that can never fail is decoration, not a control. (The very session that
   catalogued this class shipped a self-check grepping the WRONG token — it matched prose in the
   body instead of the canonical line, and would have passed forever.)

> Evidence (production project): an agent declared "mandatory at the start of every session"
> logged ZERO spawns across 24 audited sessions. The mandate lived in that agent's own frontmatter
> and in an inventory list; the skill that actually opens a session never mentioned it. Nobody
> reads the frontmatter of an agent that is not being invoked.

**Same family as §6 (banned anti-patterns need a mechanical self-check) and §8 (a component can be
PRESENT and absent from the registry).** In all three, only a mechanical check separates
"installed" from "actually running" — the textual claim never does.
