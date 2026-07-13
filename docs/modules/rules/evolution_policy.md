# Template: Evolution Policy

> Create at `.claude/rules/evolution-policy.md` during bootstrap.
> This rule governs how framework components evolve — loaded in every session.

````markdown
---
domain: evolution-policy
applies_to: "**/*"
---

# Evolution Policy

## Classification

Every evolution must be classified by trigger:

| Mode | Trigger | Examples |
|------|---------|----------|
| **FIX** | Something failed that should have worked | Bug missed by review → fix agent checklist. Rule contradicts code → fix rule. |
| **DERIVED** | Something works but can be consolidated | 3+ Known Bug Patterns from same domain → derive rules file. |
| **CAPTURED** | Pattern observed in real usage | Diff scan finds recurring pattern → capture as Known Bug Pattern. |

Follow-up: FIX → re-run eval if component has `last_eval`. DERIVED/CAPTURED → no eval needed.

Log format: `"[FIX/DERIVED/CAPTURED]: [component] — [what changed and why]"`

## Auto-evolution boundaries

If the evolution changes **DATA** (what the agent knows) → apply autonomously.
If it changes **BEHAVIOR** (how the agent acts) → requires human approval.

**Autonomous (no approval needed):**
- Known Bug Patterns, Architecture Patterns (factual — from diffs)
- File Map, Commands in CLAUDE.md (factual — reflects filesystem)
- Skills content (knowledge/process — errors caught by eval loops; NEW components enter via the creation gate below when skill-gate is installed)
- Agent checklist items — ADDING new checks (from real bugs via FIX)
- Lineage metadata, efficacy tracking (append-only)

**Requires human approval:**
- Session Protocol / Execution Protocol / Validation Protocol
- Task limits, retry limits, sprint mechanics
- Context routing rules
- Rules files (domain business logic)
- PRD
- Agent checklist items — REMOVING or WEAKENING existing checks
- Changing an agent's invocation type, report format, or trigger conditions

Check this list before making end-of-session updates. For human-approval items, propose the change in the session log and wait for confirmation.

## Component creation gate (when `.claude/skills/skill-gate/` exists)

Creating a NEW skill or rules file is still an autonomous evolution — but it routes
through an independent gate instead of self-approval:

- NEVER write a new component directly into `.claude/skills/` or `.claude/rules/`.
  New components are drafted in `.claude/drafts/` and promoted only after a blind
  review approves them (process: `.claude/skills/skill-gate/SKILL.md`).
- In-place UPDATES to existing components stay direct (this policy's boundaries
  above apply unchanged). If an update ADDS an empirical claim — a fact about the
  external world (durations, prices, vendor/API behavior, metrics) — ALWAYS mark
  it `verified: false` inline. framework-audit Q5 audits compliance.
- If skill-gate is NOT installed (prototype tier), creation follows
  rules-agents-updater Step 4 directly.

**`verified: false` rules (apply regardless of tier):**
- Consuming: treat each listed claim as hypothesis, not fact; flag to the user
  whenever a decision depends on it.
- Removing the flag is EXCLUSIVELY a human decision or driven by real recorded
  data (e.g., a measured duration replacing an estimated one). NEVER remove it on
  your own reasoning — that is the exact failure the flag exists to prevent.

## Back-sweep — rules apply backward (internal-tool+ profiles)

A rule or check only earns its keep if it also condemns the code that PRE-DATES it.
Otherwise "the rule exists" silently means "the rule is enforced from now on" while old
violations live on undetected — forward-only blindness.

**Clause:** When a new check is CAPTURED or a rules file is DERIVED (a Known Bug Pattern
promoted, or a fresh rule authored), it MUST be swept backward across the existing codebase
in the same session:

1. Derive a greppable signature from the new rule (the wrong pattern it forbids).
2. Grep the whole codebase for pre-existing matches.
3. Each hit that is a genuine violation becomes a tracked task `[back-sweep sN]` in
   `pendencias.md` — NOT fixed silently (the fix is prioritized like any other task).

The executor is the `diff-pattern-extractor` (end of session — it already promotes rules,
so it owns the sweep). Back-sweep ARCHIVES findings as tasks; it never auto-edits code.

**Profile gate:** skip for `prototype` (forward-only is acceptable for throwaway code).
Active for `internal-tool`, `production`, `production-financial`.
````
