---
domain: resilience-error-handling
applies_to: services with external dependencies, microservices, API consumers, background job processors
---

# Resilience & Error Handling Rules

## Inviolable Rules

1. **Every external service call MUST have an explicit timeout** — never rely on the HTTP client or library default (which may be infinite or minutes-long).
2. **Error handling MUST NOT swallow exceptions silently** — at minimum: log the error with context AND return a meaningful error to the caller.
3. **Retry logic MUST use exponential backoff with jitter** — never fixed-interval or immediate retries.
4. **Non-retryable errors (4xx except 429) MUST NOT be retried** — only transient failures (5xx, timeout, connection error) trigger retry.

## Timeout Rules

| Call Type | Default Timeout | Rationale |
|-----------|----------------|-----------|
| Database query | 5-10 seconds | Queries taking longer indicate missing index or lock contention |
| External API call | 10-30 seconds | Varies by provider SLA — set per service |
| Internal service call | 3-5 seconds | Internal network should be fast — long times indicate problem |
| Health check dependency | 2-3 seconds | Health check must be fast — slow dependency = unhealthy |
| Background job step | 30-60 seconds | Document max expected duration — alert if exceeded |

## Retry Patterns

### Exponential Backoff with Jitter
```
delay = min(base_delay * 2^attempt + random_jitter, max_delay)
```
- **Base delay:** 1 second
- **Max delay:** 30 seconds (configurable per service)
- **Max retries:** 3-5 (configurable)
- **Jitter:** random 0-1 second added to prevent thundering herd

### What to Retry
| Error Type | Retry? | Reason |
|------------|--------|--------|
| 5xx (server error) | YES | Server may recover |
| Timeout | YES | Transient network or load issue |
| Connection refused | YES (limited) | Service may be restarting |
| 429 (rate limited) | YES | Honor `Retry-After` header |
| 4xx (client error) | NO | Request is wrong — retrying won't help |
| Auth error (401/403) | NO | Credentials are wrong — retrying wastes quota |

## Circuit Breaker Patterns

### States
- **CLOSED** (normal): requests pass through. Track failure count.
- **OPEN** (failing): requests immediately fail with fallback. No calls to downstream.
- **HALF-OPEN** (probing): allow 1 request through. If success → CLOSED. If failure → OPEN.

### Configuration
- **Failure threshold:** 5 consecutive failures OR >50% failure rate in 60-second window → trip to OPEN
- **Open duration:** 30 seconds before transitioning to HALF-OPEN
- **Fallback:** each service must define fallback behavior (cached data, default response, graceful error)

## Error Boundary Patterns

### Frontend
- Wrap each major UI section in an error boundary (React ErrorBoundary or framework equivalent)
- Error boundary shows user-friendly message — not stack trace
- Error boundary reports to error tracking service

### Backend
- Global error handler catches uncaught exceptions — returns structured error response, not raw exception
- Per-handler try/catch includes operation context in error log (user_id, entity_id, operation name)
- Background jobs: failed job does NOT crash the worker process — log, move to dead-letter, continue processing next

### Message Consumers
- Malformed message: reject to dead-letter queue — do NOT block the queue
- Processing failure after max retries: move to dead-letter queue with error context
- Dead-letter queue monitored with alerts (DLQ depth > 0 for > 10 minutes = alert)

## Health Check Patterns
- `/health` or `/healthz` endpoint verifies ALL critical dependencies (database, cache, message broker)
- Health check has its own timeout per dependency (2-3 seconds) — does not hang if a dependency is down
- Distinguish liveness (process is running) from readiness (process can serve traffic) if platform supports it
- Health check response includes dependency status for debugging: `{ "db": "ok", "redis": "ok", "queue": "degraded" }`

## Graceful Degradation
- Non-critical features degrade without blocking core user flow (e.g., recommendations unavailable → show nothing, not error)
- Feature flags exist for disabling non-essential integrations under load or during incidents
- Timeout on every external call — no unbounded waits that cascade into upstream timeouts
- Partial failure handling: if 1 of 5 parallel calls fails, return partial results with indication — not full error

## Testing Criteria

### REVIEW:
- [ ] All external calls have explicit timeout configured?
- [ ] Error handlers log with context and return meaningful responses?
- [ ] Retry logic uses exponential backoff, not fixed interval?
- [ ] Circuit breaker or equivalent resilience pattern for critical dependencies?
- [ ] Health check endpoint exists and verifies dependencies?

### QUERY:
- QUERY: Does the health endpoint return 200 and check critical dependencies? → verify by reading implementation
- QUERY: Are there catch blocks that swallow errors without logging? → expect: 0
