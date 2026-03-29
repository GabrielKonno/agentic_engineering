---
name: criteria-enforcer
invocation: inline
effort: high
description: >
  Enforces criteria quality before implementation. Rewrites WEAK criteria to STRONG.
  Runs adversarial review on each criterion. MUST run before implementing any task.
  Skipping this is the #1 cause of false-positive validation results.
created: framework-v1.6.0 (pre-validated)
derived_from: execution_protocol "Before implementing"
---

# Criteria Enforcer

## When to run
Before implementing ANY task, after reading the task from pendencias.md.

## Process

### 1. Read criteria
Read the task's acceptance criteria from pendencias.md. Each criterion should have a tag: `BUILD:`, `VERIFY:`, `QUERY:`, `REVIEW:`, `MANUAL:`.

### 2. Check criteria quality (3-part standard)
Every criterion MUST have:
1. **Action** — what to do
2. **Expected result** — what success looks like, specifically
3. **Failure signal** — how to know it truly succeeded (not a false positive)

```
❌ WEAK: VERIFY: /clients → click New → form appears
✅ STRONG: VERIFY: /clients → click "New Client" → form with fields name (required),
   phone (optional), email (required). Submit empty → validation errors on name+email.
   Submit valid → redirect to /clients/[id], client visible in list.
```

If any criterion is WEAK: rewrite to STRONG before proceeding. Log: `"Upgraded criteria for [task]"`

### 3. Specificity inheritance
Every criterion must be at least as precise as its source (PRD, design system, rules file, migration schema). If the source defines exact values, the criterion must contain those values. A criterion vaguer than its source is WEAK regardless of having 3 parts.

### 4. Adversarial Review (run on EACH criterion)

| Test | Question | Action if fails |
|------|----------|----------------|
| **Sabotage test** | How could a wrong implementation still pass this criterion? | Strengthen — add specific values, edge cases, or complementary QUERY: |
| **Transformation test** | Am I checking a snapshot or a transformation? | If snapshot only, add before/after comparison |
| **Empty/boundary test** | What if 0 items, 1 item, negative, null? | Add edge case criteria |
| **Data origin test** | Could this pass with hardcoded data? | Add complementary QUERY: to verify dynamic data |

### 5. Log result
Log which criteria were upgraded and why. If all criteria were already STRONG: log "Criteria verified — all STRONG".
