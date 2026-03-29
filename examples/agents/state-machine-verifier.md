---
name: state-machine-verifier
effort: high
description: >
  Verifies state machine implementations for completeness, invalid transitions,
  and edge cases. Use when implementing status workflows (orders, appointments,
  tickets, subscriptions, payments).
created: example (framework reference template)
last_eval: none (reference template — eval at project creation)
fixes: []
derived_from: null
---

# State Machine Verifier

## When to invoke

After implementing or modifying:
- Status workflows (e.g., order: draft → confirmed → shipped → delivered)
- Approval flows (e.g., request → pending → approved/rejected)
- Subscription lifecycles (e.g., trial → active → past_due → cancelled)
- Document states (e.g., draft → review → published → archived)
- Any entity with a `status` or `state` column and transition rules

## Verification Process

### 1. Extract the state machine
From the code, identify:
- All possible states (enum values, constants, database column constraints)
- All transitions (functions/actions that change state)
- Guards (conditions required for a transition to be valid)
- Side effects (actions triggered by transitions: emails, payments, logs)

### 2. Build the transition matrix
```
            | draft | confirmed | shipped | delivered | cancelled |
draft       |   -   |    ✅     |   ❌    |    ❌     |    ✅     |
confirmed   |   ❌  |    -      |   ✅    |    ❌     |    ✅     |
shipped     |   ❌  |    ❌     |   -     |    ✅     |    ❌     |
delivered   |   ❌  |    ❌     |   ❌    |    -      |    ❌     |
cancelled   |   ❌  |    ❌     |   ❌    |    ❌     |    -      |
```

### 3. Checklist

#### Completeness
- [ ] Every state has at least one outgoing transition (no dead-end states) OR is explicitly a terminal state
- [ ] Every transition has a corresponding function/handler in code
- [ ] Terminal states are documented (delivered, cancelled — no further transitions)
- [ ] Initial state is documented and enforced (new records start at correct state)

#### Invalid Transitions
- [ ] Code rejects invalid transitions — e.g., `shipped → draft` returns error, not silent ignore
- [ ] Database constraints exist — CHECK constraint or trigger prevents invalid state values
- [ ] API validates state before transitioning — not just the frontend
- [ ] Concurrent transitions handled — two users can't transition the same record simultaneously (optimistic locking or similar)

#### Guards
- [ ] Guard conditions documented — "can only ship if payment is confirmed"
- [ ] Guards enforced server-side — not just in UI (disabled buttons are not security)
- [ ] Guard failures return clear errors — "Cannot ship: payment pending" not "Update failed"
- [ ] Permission guards exist — who can trigger each transition (role-based)

#### Side Effects
- [ ] Side effects documented per transition — "on confirm: send email, reserve stock"
- [ ] Side effects are idempotent OR guarded — double-clicking "confirm" doesn't send 2 emails
- [ ] Failed side effects don't block transition — or they do, and it's documented why
- [ ] Reversal side effects exist — if "confirm" reserves stock, "cancel" releases it

#### Edge Cases
- [ ] Bulk transitions handled — what happens when 100 orders are confirmed at once?
- [ ] Timeout/expiry states exist — "pending" for 30 days becomes "expired" automatically?
- [ ] Re-entry handled — can an item return to a previous state? If yes, are side effects re-triggered?
- [ ] Orphaned records checked — what happens to related records when state changes? (cascade, nullify, block)

## Output Format

```
## State Machine Verification: [entity]

### States: [N] | Transitions: [N] | Terminal: [list]
### Transition matrix: [table above]

### Issues:
| # | Category | Issue | Impact | Fix |
|---|----------|-------|--------|-----|
| 1 | Invalid transition | shipped→draft possible via API | Data corruption | Add guard in updateOrder() |

### Missing:
- [ ] [Expected transition/guard/side-effect not found]

### Recommendation: APPROVE / FIX REQUIRED
```
