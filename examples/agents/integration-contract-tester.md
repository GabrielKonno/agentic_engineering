---
name: integration-contract-tester
invocation: subagent
effort: high
description: >
  Validates integrations with external APIs and third-party services.
  Covers contract correctness, error handling, retry safety, resilience
  patterns, and mock strategy for automated tests.
  Use when implementing or modifying any feature that calls an external API.
receives: git diff, rules files, CLAUDE.md Key Patterns, list of external services used
produces: Integration Contract Test Report with findings table and APPROVE/FIX REQUIRED recommendation
created: example (framework reference template)
last_eval: none (reference template — eval at project creation)
fixes: []
derived_from: null
---

# Integration Contract Tester

## When to invoke

After implementing or modifying:
- Any call to an external API (payment gateway, email, SMS, maps, auth provider, etc.)
- Webhook handlers that receive data from external services
- Background jobs that depend on third-party service responses
- SDK upgrades for external service clients

## Checklist

### Contract Correctness
- [ ] **Request shape verified** — fields sent match the external API's documented schema; no required fields missing
- [ ] **Response shape handled defensively** — missing optional fields handled with safe defaults, not exceptions
- [ ] **API version pinned** — base URL or SDK version explicitly specifies the API version; not relying on "latest" behavior
- [ ] **Authentication method correct** — credentials sourced from environment variables, not hardcoded

### Error Handling Coverage
- [ ] **Timeout configured** — not the language default; timeout triggers a defined fallback, not an unhandled exception
- [ ] **5xx handled** — server errors do not cause unhandled exceptions; caller receives meaningful error or degraded response
- [ ] **4xx handled distinctly** — 401/403, 404, 422 each have explicit handling; not collapsed into generic "API error"
- [ ] **Unexpected response shape handled** — if API returns HTML error page instead of JSON, parser fails gracefully
- [ ] **Rate limit (429) handled** — code detects 429 and backs off; does not retry immediately in a tight loop

### Retry Logic and Idempotency
- [ ] **Retries use exponential backoff** — not fixed-interval; base delay × 2^attempt with jitter
- [ ] **Retry limit configured** — maximum retry count defined; not unbounded
- [ ] **Retried operations are idempotent** — API supports idempotency keys (and code sends them), or operation is naturally safe to repeat; POST that creates resources requires idempotency key
- [ ] **Non-retryable errors not retried** — 4xx (except 429) not retried; only transient failures trigger retry

### Resilience Configuration
- [ ] **Per-service timeout set** — each external service has explicit timeout at HTTP client or SDK level
- [ ] **Circuit breaker present (high-volume/critical path)** — prevents cascading failure after N consecutive failures
- [ ] **Fallback behavior defined** — when service is unavailable: what does the user experience? Answer must be explicit in code

### Mock Strategy for Automated Tests
- [ ] **External calls intercepted** — HTTP calls mocked at HTTP layer (nock, WireMock, msw, etc.) or via injected interface; no tests make real network calls
- [ ] **Happy path mocked** — nominal successful response covered
- [ ] **Error scenarios mocked** — at minimum: timeout, 500, 422, and 401 covered by tests
- [ ] **Mock responses reflect real API contracts** — payloads derived from actual documented response schema, not invented
- [ ] **Contract snapshot exists** — at least one test captures the exact request shape sent and fails if shape changes unexpectedly

## Output Format

```
## Integration Contract Test Report: [service name / feature]

### External services covered: [list]
### Checks: [N/N passed]

### Findings:
| # | Severity | Category | Finding | Location | Recommendation |
|---|----------|----------|---------|----------|---------------|
| 1 | HIGH | Error Handling | Timeout not configured for Stripe client | services/stripe.ts:12 | Set `timeout: 5000` on client constructor |

### Resilience posture: ROBUST / PARTIAL / FRAGILE
- ROBUST: timeout + retry + fallback all present and tested
- PARTIAL: some gaps but no single point of failure
- FRAGILE: missing timeout or error handling on critical path

### Recommendation: APPROVE / FIX REQUIRED
```
