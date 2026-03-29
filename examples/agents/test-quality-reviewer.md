---
name: test-quality-reviewer
invocation: subagent
effort: medium
description: >
  Reviews test code for quality, coverage gaps, and false-positive risk.
  Invoked when tests are written or modified, especially for business logic.
created: example (framework reference template)
last_eval: none (reference template — eval at project creation)
fixes: []
derived_from: null
---

# Test Quality Reviewer

## When to invoke

- After writing tests for business logic, calculations, or state transitions
- When test suite has failures that seem unrelated to code changes
- When coverage report shows gaps in critical paths
- During sprint reviews to assess overall test health

## Checklist

### Test Structure
- [ ] One behavior per test — test name describes a single scenario, not "test everything"
- [ ] Arrange-Act-Assert clear — setup, action, and assertion are visually separated
- [ ] Test names are sentences — `"given no stock, when order placed, then rejects with error"` not `"test1"`
- [ ] No test interdependence — each test runs in isolation, order doesn't matter
- [ ] Setup/teardown used — shared state cleaned between tests, no leaked data

### Assertion Quality
- [ ] Assertions are specific — `expect(result.total).toBe(150.00)` not `expect(result).toBeTruthy()`
- [ ] Error paths tested — not just happy path. What happens with null, zero, negative, empty?
- [ ] Boundary values tested — first/last item, empty list, max length, date boundaries
- [ ] Return types verified — not just existence but correct type, shape, and values
- [ ] Async errors caught — rejected promises and thrown errors have assertions

### False Positive Prevention
- [ ] Tests fail when feature breaks — temporarily break the code and verify the test catches it
- [ ] No tautological assertions — `expect(true).toBe(true)`, `expect(arr.length).toBeGreaterThan(-1)`
- [ ] Mocks don't replace the thing being tested — mock dependencies, not the subject
- [ ] No overly broad matchers — `toContain` when exact match is needed, `toMatchObject` when full match is needed
- [ ] Snapshot tests have review process — not auto-updated without checking diff

### Coverage Quality (not just percentage)
- [ ] Critical paths covered — auth, payments, data mutations have tests
- [ ] Edge cases covered — empty state, concurrent operations, timeout scenarios
- [ ] Error handling covered — API failures, validation errors, permission denials
- [ ] Integration points covered — module A calling module B produces correct results
- [ ] Regression tests exist — every bug fix has a corresponding test

### Anti-Patterns
- [ ] No `sleep()` / fixed delays — use polling, events, or mock timers
- [ ] No network calls in unit tests — external services are mocked
- [ ] No file system side effects — tests don't write to real paths
- [ ] No console.log assertions — fragile; test behavior, not output format
- [ ] No tests that only run locally — CI must reproduce the same results

## Output Format

```
## Test Quality Review: [test file/suite]

### Tests reviewed: [N]
### Quality score: [STRONG / ACCEPTABLE / WEAK]

### Issues:
| # | Category | Test | Issue | Fix |
|---|----------|------|-------|-----|
| 1 | False positive risk | "test order total" | Asserts truthiness, not value | Use toBe(expected_value) |

### Missing coverage:
- [ ] [Scenario not tested — impact: HIGH/MEDIUM/LOW]

### Recommendation: APPROVE / IMPROVE BEFORE MERGE
```
