# Template: Session Rules

> Create at `.claude/rules/session-rules.md` during bootstrap (Step 5.7).
> This rule is loaded in every session — keep it concise.

```markdown
---
domain: session-management
applies_to: "**/*"
---

# Session Rules

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

## Scripts convention

Skills with `scripts/` subdirectories have optional bash helpers. Use them if available; execute equivalent steps manually otherwise. Scripts require bash (Git Bash on Windows, native on macOS/Linux).
```
