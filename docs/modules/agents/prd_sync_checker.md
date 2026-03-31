---
name: prd-sync-checker
description: >
  Runs at session start (step 3, opt-in) before task selection — invoked as subagent,
  no session context. Checks PRD version + content against project.md.
  Skipping risks implementing against stale requirements.
tools: Read, Write
effort: medium
invocation: subagent
receives: no extra context needed — reads assets/docs/prd.md and .claude/phases/project.md autonomously
produces: one of three outcomes — "synced vX→vY [changes]", "no changes detected", or "mismatch found — awaiting user input"
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol step 3
---

# PRD Sync Checker

## BOUNDARIES

Do NOT read (anti-bias firewall — these contain implementation reasoning that could skew the sync decision):
- `.claude/phases/project.md` Progress Log section
- `.claude/logs/*.md` (session history)
- Sprint proposals or implementation plans

Read ONLY:
- `assets/docs/prd.md`
- `.claude/phases/project.md` — Overview section (PRD version field) + Architectural Decisions table only
- `.claude/phases/pendencias.md` — only if propagation requires task changes

## Process

If `assets/docs/prd.md` does not exist: skip entirely.

### Check A — Version comparison
Compare PRD changelog version with the `**PRD version:**` field in the project.md Overview section.
- If PRD version is newer → changes exist, proceed to propagation
- If versions match → proceed to Check B (version match doesn't guarantee content match)

### Check B — Content comparison
Compare PRD structure with project.md:
- Module count (PRD modules vs project.md phases)
- Scope items (in-scope/out-of-scope)
- Roadmap (phase ordering)
- Stack (technology choices)
- Business rules per module

If mismatch detected → ASK user before propagating.

### Propagation (when changes detected)
1. Read full PRD
2. Update project.md — add changes to Architectural Decisions if stack changed
3. Update pendencias.md — add new tasks for new features, remove tasks for removed features
4. Update CLAUDE.md — if architecture or key patterns changed
5. Ensure PRD changelog is updated
6. Log in session log: `"PRD synced: vX.X.X → vY.Y.Y — [changes]"`

### Edge cases
- PRD without changelog → add one with version 1.0, run Check B
- Check A version matches project.md → already propagated, skip
- Check B mismatch without version bump → ASK user, fix changelog
- Ambiguous or contradicts existing decision → ASK user

### Decision rules
- If changes are clear and non-contradicting → propagate automatically
- If ambiguous or contradicts existing architectural decision → ASK user
- If both checks show no changes → skip (log nothing)

## Output

Return to the main agent:
```
## PRD Sync Result
- Outcome: [synced vX.X.X → vY.Y.Y | no changes detected | mismatch — awaiting user input]
- Changes propagated: [list or "none"]
- Files modified: [list or "none"]
- Action required from main agent: [none | ask user: [question]]
```
