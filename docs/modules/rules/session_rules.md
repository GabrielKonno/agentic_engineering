# Template: Session Rules

> Create at `.claude/rules/session-rules.md` during bootstrap (Step 5.7).
> This rule is loaded in every session — keep it concise.

````markdown
---
domain: session-management
applies_to: "**/*"
---

# Session Rules

## Risk profile & ceremony tiers

This project's risk profile is recorded in `.claude/phases/project.md` (Overview → **Risk profile:**)
and CLAUDE.md. The profile scales how much process ceremony applies — robustness on demand,
never imposed. Read the profile, then apply ONLY the ceremonies its column marks `✅`.

| Ceremony | prototype | internal-tool | production | production-financial |
|----------|:---------:|:-------------:|:----------:|:--------------------:|
| Per-diff review (Route 1/2), criteria-enforcer, KBP loop | ✅ | ✅ | ✅ | ✅ |
| Session archetypes, per-incident Post-Mortem | ✅ | ✅ | ✅ | ✅ |
| Class-checklist (conditional — zero cost when not triggered) | ✅ | ✅ | ✅ | ✅ |
| CI floor at t=0 | — | ✅ | ✅ | ✅ |
| metrics.md (light series) | — | ✅ | ✅ | ✅ |
| Back-sweep (rules apply backward) | — | ✅ | ✅ | ✅ |
| skill-gate (creation gate for new skills/rules) | — | ✅ | ✅ | ✅ |
| Debt-aging triage | — | ✅ | ✅ | ✅ |
| Post-Mortem ledger (recurring-class detection) | — | ✅ | ✅ | ✅ |
| codebase-audit (`AUDIT_CADENCE`) | — | sparse (~20) | ✅ (~12) | ✅ (~12) |
| ops-rules (lifecycle dimension) | — | — | ✅ | ✅ |
| quality-budgets + delta gate | — | — | ✅ | ✅ |
| Deploy gates (DEPLOY GUARD) | — | — | ✅ | ✅ |
| framework-audit (`FRAMEWORK_AUDIT_CADENCE`) | — | — | sparse (~35) | frequent (~25) |
| Data reconciliation + red-team mandatory on money-paths | — | — | — | ✅ |

> **Mechanism, not policing:** ceremonies are gated by FILE PRESENCE, not a runtime tier check.
> Bootstrap copies a skeleton (codebase-audit, ops-rules, quality-budgets…) ONLY when the tier
> warrants it, so an absent file = an inactive ceremony. To raise/lower a project's ceremony later,
> add or remove the corresponding skeleton — no protocol edit needed. The cadence numbers in
> parentheses are defaults; adjust per project.

## Session lifecycle

- Before implementation work, run `/sprint-proposer` (loads project state, syncs PRD, proposes sprint)
- Every session with implementation work MUST end with `/session-end`
- If context degrades mid-session, run `/context-recovery`

## Task limits

Maximum 3-5 tasks per session. Up to 7 if all small+related. 1 if large.

Signals of exceeding: contradicting earlier findings, skipping validation steps, producing ⏭️ on steps that should be ✅ or ❌.

## Task presentation

When proposing sprints or listing tasks, ALWAYS include for each task:
- **Model:** current (default), or model switch required (architecture/security)
- **Effort:** current settings (routine), extended thinking (logic-heavy), or high + model switch (architecture/security)
- **Justification:** one-line reason for the recommendation

Derive from each task's `Complexity:` field. If no complexity field exists, classify before presenting.

## Reasoning depth mechanisms (complementary)

1. **Agent-level (automatic):** `effort:` in agent/skill frontmatter. Security agents always `effort: high`.
2. **Task-level (2 seconds):** AI MUST recommend effort level in plan and sprint proposal. Human adjusts if needed.
3. **Session-level model switch (5 seconds):** AI saves state with MODEL SWITCH marker → requests restart. See execution protocol for full model switch initiation; `sprint-proposer` skill detects the marker on restart.

Mechanisms stack: a standard-effort session uses high effort when security agents run (mechanism 1), can switch to high effort for a financial task (mechanism 2), and can switch to a more capable model for an architecture task (mechanism 3).

## Documentation quality

- Be specific: "Fixed reopenMonth deleting only unpaid" NOT "Fixed a bug"
- Include WHY: "Added parseLocal() because toISOString() shifts dates in UTC-3 timezone"
- Constraints go in rules files, not just session logs

## Session archetypes (all profiles)

Not every session is an implementation session. Declare the archetype at the start; it tells
`session-end` what to extract and what to legitimately skip (a skipped step here is "N/A",
NOT degraded rigor).

| Archetype | What it is | session-end adaptation |
|-----------|-----------|------------------------|
| `implementation` (default) | Building/fixing code | Full flow: diff-pattern-extractor first, then all updaters |
| `investigation` | Research/analysis, no code shipped | SKIP diff-pattern-extractor; DO write session log + project.md index; findings → tasks in pendencias |
| `framework-maintenance` | Editing this project's own agents/skills/rules/docs | SKIP app-code pattern extraction; instead log each component change with FIX/DERIVED/CAPTURED; re-check activation chains / counts |
| `ops` | Runtime, deploy, infra, incident | SKIP app-pattern extraction; update ops-rules + metrics.md; log incident + reconciliation outcome |

If a session mixes archetypes, run the union of their session-end steps.

## Debt-aging (internal-tool+ profiles)

Backlog items under "Future Improvements" in `pendencias.md` MUST carry a session stamp
`[added sN]`. The periodic codebase-audit triages items older than `DEBT_AGE` (default ~30
sessions) with an explicit verdict per item: **KEEP** (still valid, re-stamp), **CLOSE**
(obsolete/done), or **PROMOTE** (turn into an active task now). This prevents "documented in
the backlog" from silently becoming "resolved forever."

## Deploy gates (production+ profiles)

A multi-session feature that ships all-or-nothing MUST be gated behind owner-defined exit
criteria, recorded as a `DEPLOY GUARD` block in `pendencias.md` (see the pendencias template).
Hard rule: do NOT open the deploy PR (e.g., `dev → main`) until the guard's criteria are met.
When met, convert the block to `✅ FULFILLED (sN)` with the PR hash — preserve the original as
history. This is a distinct gate tier ABOVE the per-diff CI gate and the per-task validation gate.

## Scripts convention

Skills with `scripts/` subdirectories have optional bash helpers. Use them if available; execute equivalent steps manually otherwise. Scripts require bash (Git Bash on Windows, native on macOS/Linux).
````
