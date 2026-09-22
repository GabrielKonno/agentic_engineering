---
domain: component-design
paths:
  - "docs/modules/agents/**"
  - "docs/modules/skills/**"
  - "docs/modules/rules/**"
  - "docs/modules/templates/**"
  - "examples/agents/**"
  - "examples/skills/**"
  - "examples/rules/**"
  - ".claude/commands/**"
  - ".claude/skills/**"
  - ".claude/rules/**"
---

# Component Design Policy

## 1. Activation Architecture — Gap-Declaration

Specialist agents are activated through gap declarations, not hardcoded routing.

**Flow:** A DECLARING component — there are THREE: `code-reviewer`, `security-reviewer` and
`validator` (which declares the visual regression gap from inside its own Validation Report) —
declares what it CANNOT
fully cover → main Claude reads the gap declaration in the report → searches
`.claude/agents/` descriptions for a matching specialist → spawns if found.

**Why this exists:** Subagents cannot spawn other subagents (Claude Code hard limit).
A declaring component cannot call the specialist directly. Gap declarations bridge this by
routing activation through main Claude.

**When adding a new specialist domain:**
1. Add a gap declaration to the appropriate DECLARING COMPONENT (a reviewer, or the validator) using the specialist's key vocabulary
2. Create the agent with a Pushy Description that echoes that vocabulary
3. Add a "When spawned" section explaining context needs and report outcomes
4. Zero changes to orchestration (validation-orchestrator) needed

## 2. Pushy Description Pattern

Agent descriptions must communicate both PURPOSE and ACTIVATION. Structure:

```
[Core function — what the agent does, how it does it, what value it adds].
USE PROACTIVELY when [trigger conditions]
  or when [declaring component] declares a [domain] gap.
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
- The gap phrase MUST echo the DECLARING COMPONENT's gap declaration verbatim — and when two components declare the same gap, name both (`code-reviewer or validator`)
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
| Declaring component (code-reviewer, security-reviewer, **validator**) | Gap declaration in report | "X gap: ... Recommend: search .claude/agents/" |
| Specialist agent | Pushy Description | "when [declaring component] declares a X gap" |

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

**A rule KEPT AS HYPOTHESES ALWAYS lives inside a `> ` blockquote, with `kept as HYPOTHESES` on one line.**
Its measurer (`framework-audit` → Q4 → the HYPOTHESIS check) discovers components by joining `> ` lines
only, so a hypothesis stated in plain prose is measured by nobody while the check still reports its
authorized `N/A` (`/audit` 2026-09-20 AA-1; the line-wrap half is `/audit` 2026-09-16 A-3).
**`framework-audit` ships at `production`+ ONLY.** Below that tier nothing measures a hypothesis, so the
rule that keeps one ALWAYS says `unmeasured — no measurer at <tier>` where it names its signal, exactly as
a lineage doc's efficacy anchor does. The blockquote is still required: it is what makes the rule
discoverable the day the tier rises (this batch's pre-commit verifier, 2026-09-20).

## 7. Native Mechanisms — Don't Reinvent

Claude Code provides these natively — do not build custom replacements:

| Mechanism | What it does | Don't build |
|-----------|-------------|-------------|
| `description:` frontmatter | Semantic discovery of agents/skills | Routing tables, activation registries |
| Agent tool isolation | Fresh context per subagent | Context sharing between subagents |
| Rules `paths:` globs | Lazy loading per file pattern | Manual conditional loading |
| CLAUDE.md auto-read | Loaded every session | "Read project config" steps in skills |

**ALWAYS scope a rules file with `paths:` (a YAML list of globs) — NEVER with `applies_to:` or any other key.**
The harness reads `paths:` only: a rule without it loads in EVERY session and EVERY subagent, and a scope
written in another key is intent with no mechanism — the §8 class, one key over. A rule stays unscoped only
when it governs the session itself — in a project, listed with its reason in the shipped guard's
`ALWAYS_LOADED` (`docs/modules/templates/check_rules_paths.md`; this repo runs no such guard).
**NEVER instruct an agent to "read all `.claude/rules/*.md`"** — with scoping, that line
cancels the gain exactly in the subagents; name the files under review instead, and the Read loads the rules.

> Evidence (production project, 2026-09): 19 rules files declared scope in `applies_to:` and loaded in full —
> ~52% of a 1M window before any work; a 200k subagent died on its starting context. After `paths:`, the
> always-loaded share was ~5% and a subagent started at ~63k tokens, measured by a control/test agent pair.

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

**The same rule governs GUARD SCRIPTS, one level down.** A script that exits non-zero on a violation
is a control only when something EXECUTES it: a CI job, or a step in a skill, command or agent.
A mention in a rules file, a log or the backlog is prose — it is where orphaned guards live.
- **ALWAYS wire a new guard script to an executable invoker in the SAME change that creates it**,
  and name the invoker in the script's header.
- A guard that cannot run in CI (it reads a gitignored file, it needs production secrets) ALWAYS gets
  a skill step instead — usually the session-start skill — never "run it by hand".
- **IN A PROJECT** the periodic check is `codebase-audit` → "Debt-aging triage" →
  **"every guard script has an EXECUTABLE invoker"** — the heading so the reader can navigate, the
  verbatim string so the claim can be grepped (**NEVER WRAP IT ACROSS A LINE BREAK**). It ships at
  `internal-tool`+; at `prototype` nothing checks it periodically and the same-change wiring is
  the only control.
- **IN THIS FRAMEWORK REPO NOTHING CHECKS IT PERIODICALLY — stated, not implied.** This repo runs
  no `codebase-audit` (`.claude/skills/` holds `cross-cutting-analysis` only) and carries no risk
  profile, so the tier words above have no referent here. The same-change wiring is the ONLY
  control on this side (`/audit` 2026-09-21 AC-19).

> Evidence (production project): five guard scripts that exit 1 had no invoker at all. One watched
> the age of the only backup, which then aged 13 of its 14 allowed days; the script had been run by
> hand 3 times in 20 sessions.

**Same family as §6 (banned anti-patterns need a mechanical self-check) and §8 (a component can be
PRESENT and absent from the registry).** In all three, only a mechanical check separates
"installed" from "actually running" — the textual claim never does.

## 10. A MANDATE IS WRITTEN LAST — its destination is written first

§9 says the instruction to invoke X belongs to whoever owns the moment X runs. This is the
ordering rule one level down, and it governs the EDIT, not the design.

**WHEN A BATCH ADDS A MANDATE TO RECORD, REPORT OR LOG ANYTHING, ALWAYS WRITE THE DESTINATION
FIRST — in the same batch, before the sentence that mandates it.** In order:

1. **NAME the destination and open it.** The slot, the log verb, the report line, the status cell.
2. **VERIFY the component that OWNS it admits the new value** — follow it to whoever WRITES that
   surface, not whoever reads it. A mandate addressed to a component that does not own the
   destination is written by nobody.
3. **SWEEP every surface that ENUMERATES the destination's vocabulary.** A log verb set, a status
   set and a report enumeration are usually three separate files, and extending one of them is the
   common failure.
4. **ONLY THEN write the mandate.**

**NEVER write the mandate first and the destination after.** It reads like progress and produces an
obligation nobody can honour — and the defect does not announce itself, because the mandate is
present, correct and unexecutable.

> Evidence (this repo, 2026-09-20): a batch adding an adopt-vs-create gate mandated recording in
> four places. Three independent pre-commit verification rounds found, across them, a destination
> that did not exist, one that could not admit the value, one owned by a different component, and a
> log-verb set extended in 1 of 16 surfaces that enumerate it. The rounds found 11, then 16, then 15:
> each repair added mandates faster than it added destinations. **The batch was abandoned; only this
> rule shipped, because it is the only part that mandates no recording of its own.**

**In the FRAMEWORK REPO this pairs with the maintenance command's slot gate** — the one that
harvests every new `ALWAYS REPORT` key and checks, in both directions, that a slot exists for it.
**That gate is framework-only and reaches NO bootstrapped project**, and even where it runs its
harvest sees only keys introduced by the literal phrase `ALWAYS REPORT` — never a new log verb
and never a new status value, which are two of the destination kinds step 1 above enumerates.
**So in a project this rule stands alone, and in the framework it still covers destinations that
gate cannot see.** The gate asks whether a slot exists; this rule fixes WHEN it is written, so the
gate has something true to find.
