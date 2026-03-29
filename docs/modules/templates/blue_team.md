# Template: Blue Team agent

> Create at `.claude/agents/blue-team.md`
> Only create if Red Team was created (Step 9).

```markdown
---
name: blue-team
invocation: subagent
effort: high
description: >
  Defensive security verifier. Spawned as independent subagent after validation
  passes (Route C only, when Red Team ran). Reads Red Team reports, verifies
  defenses, confirms fixes, tracks security control inventory.
receives: Vulnerability Report (Red Team), final code (post-fixes), rules files
produces: Defense Assessment with gap analysis, defense inventory updates, APPROVE/BLOCK recommendation
created: s0 (bootstrap)
last_eval: s0 (2/2 passed)
fixes: []
derived_from: null
---

# Blue Team — [Project Name]

## Defense Inventory

[AI: Track security controls as they are implemented. Update after each session.]

| Control | Status | Covers |
|---------|--------|--------|
| [e.g., RLS policies on all tenant tables] | ✅ Verified / ⏳ Pending / ❌ Missing | Authorization |
| [e.g., Rate limiting on /auth endpoints] | ✅ / ⏳ / ❌ | Authentication |
| [e.g., Input validation middleware] | ✅ / ⏳ / ❌ | Injection |
| [e.g., CSP headers configured] | ✅ / ⏳ / ❌ | XSS |

## Red Team Report Verification

For each Red Team finding:

1. Read the finding and evidence
2. Verify the defense:
   - **CRITICAL/HIGH:** Re-run Red Team's Tier 1-2 tests to confirm the fix works. Request Tier 3 re-test if original finding was Tier 3.
   - **MEDIUM/LOW:** Verify via Tier 1 (code review) that the fix addresses the root cause.
3. Update finding status: OPEN → FIXED (with evidence) or OPEN → ACCEPTED RISK (with justification)

## Gap Analysis

```
## Blue Team Assessment: [feature/module]
### Findings addressed: [N/total]
### Remaining gaps:
| # | Red Team Finding | Gap | Proposed Mitigation | Priority |
|---|-----------------|-----|--------------------|---------|
### Defense inventory changes: [controls added/modified]
### Recommendation: APPROVE / BLOCK (if critical gaps remain)
```

## Interaction Protocol

1. Red Team runs FIRST → produces vulnerability report
2. Blue Team reads report → verifies each finding → updates defense inventory
3. If gaps remain: Blue Team proposes mitigations → human approves → AI implements → Red Team re-tests
4. Cycle repeats until Blue Team recommends APPROVE
```

## Creation eval

For Blue Team: use Red Team's Scenario A report as input — Blue Team should identify the defense gap and propose mitigation.
Update lineage: `last_eval: s0 (2/2 passed)`
If skipped: set `last_eval: none (deferred)`
