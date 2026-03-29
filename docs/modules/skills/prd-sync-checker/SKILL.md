---
name: prd-sync-checker
invocation: inline
effort: medium
description: >
  Checks PRD version and content against project.md at session start.
  MUST run at session start (item 4). Skipping risks building on outdated
  requirements — the most expensive type of wasted work.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol item 4
---

# PRD Sync Checker

## When to run
At the START of every session, after reading project.md (item 4 in Session Protocol).

## Process

If `assets/docs/prd.md` does not exist: skip entirely.

### Check A — Version comparison
Compare PRD changelog version with `PRD version:` in the last project.md session entry.
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
4. Update CLAUDE.md/GEMINI.md — if architecture or key patterns changed
5. Ensure PRD changelog is updated
6. Log in session entry: `"PRD synced: vX.X.X → vY.Y.Y — [changes]"`

### Edge cases
- PRD without changelog → add one with version 1.0, run Check B
- Check A version matches project.md → already propagated, skip
- Check B mismatch without version bump → ASK user, fix changelog
- Ambiguous or contradicts existing decision → ASK user

### Decision rules
- If changes are clear and non-contradicting → propagate automatically
- If ambiguous or contradicts existing architectural decision → ASK user
- If both checks show no changes → skip (log nothing)
