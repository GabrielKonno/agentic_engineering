# Template: Evolution Policy

> Create at `.claude/rules/evolution-policy.md` during bootstrap.
> This rule governs how framework components evolve — loaded in every session.

```markdown
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
- Skills content (knowledge/process — errors caught by eval loops)
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
```
