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

**Companion — checklist-alignment sweep (routing sibling):** the back-sweep above sweeps
CODE for pre-existing violations; when the promoted rule defines a new CHECK-WORTHY CONCEPT,
the same session also asks which upstream CHECKLIST (task-authoring / per-diff review /
validation routing / periodic audit) should now reference it — see rules-agents-updater
Step 2b. Rules apply where they are ROUTED, not where they are written.

**Profile gate:** skip for `prototype` (forward-only is acceptable for throwaway code).
Active for `internal-tool`, `production`, `production-financial`.

## Framework-evolution docs — the upstream lifecycle (project → mother framework)

Some lessons a session produces are not about THIS project's domain — they are about the
FRAMEWORK itself: a protocol rule that proved inexecutable, a guard the process was missing,
a blind class in a shared checklist. Those lessons belong to every project, and they reach
the others through the mother framework repo (the repo this project was bootstrapped from).

**When a session discovers a framework-level lesson, ALWAYS record it as
`.claude/docs/framework-evolution-YYYY-MM-DD-<slug>.md`** with:
- the incident/observation and the diagnosis (what the process failed to catch, and why);
- the EXACT texts applied locally (copyable verbatim);
- a **PORTABLE formulation** of each principle — written generically, with role descriptors
  instead of this project's names/domain vocabulary. The mother repo's project-information
  isolation forbids project identifiers in shared templates, so a pre-genericized section is
  what makes the upstream copy-adaptable.

The doc has a DUAL purpose — and that is what decides when it can be retired:
1. **Upstream vehicle** (one-time): the owner runs a `/maintenance` session in the mother
   framework repo, which reads the doc, decides per evolution (graduate / adapt / reject),
   and records the disposition in the mother repo's lineage. Discharged once done.
2. **Continuous feed for the next framework-audit** (where installed): the doc is the detail
   behind the framework-metrics row and — when the evolution installed a MECHANISM — the
   ANCHOR of the efficacy evaluation the next audit must run ("did the guard prevent
   recurrence? was the discipline followed?").

**The four stages (retirable only at the last):**

| Stage | Meaning | Hygiene action |
|---|---|---|
| `pending-upstream` | written, not yet absorbed by the mother repo | — |
| `upstreamed` | a mother-repo `/maintenance` session handled the disposition (graduated OR evaluated-and-kept-local) | mark STATUS at the top of the doc; close the "pending upstream" backlog item |
| `efficacy-evaluated` | a later framework-audit measured whether the installed mechanism worked (closes the recursive loop) | — |
| `archivable` | all of the above fulfilled | move to a legacy archive or remove — via the audits' debt-triage |

**Inviolable rules:**
- **NEVER delete a doc just because it was upstreamed** — upstream discharges purpose (1),
  not purpose (2). While the doc anchors a future audit's efficacy check (or a metrics row
  still references it), it STAYS.
- **Retirement is a DEBT-TRIAGE decision** of the periodic audits (the same KEEP/CLOSE/PROMOTE
  discipline as debt-aging), never an ad-hoc cleanup — the criterion is "did the recursive
  loop close?", which only an audit can answer.
- **Marking STATUS ≠ deleting.** The hygiene for an `upstreamed` doc is changing its header
  from "pending" to "graduated — retained as detail/anchor", never removing it early.
- **The AUTHORITATIVE per-doc disposition lives in the mother repo** (its maintenance commit +
  lineage record under its `assets/docs/`), not here — the isolation rule prevents this
  project from rewriting the mother repo's registry.

**Profile note:** writing the doc costs one file and applies to ALL tiers — any project can
discover a framework lesson. The efficacy stage only runs where framework-audit is installed
(production+); on lower tiers the doc goes from `upstreamed` straight to debt-triage.
````
