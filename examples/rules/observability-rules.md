---
domain: observability
applies_to: all backend services, API handlers, background jobs, message consumers, infrastructure
---

# Observability Rules

## Inviolable Rules

1. **Every unhandled exception MUST be captured with context**: operation name, entity IDs involved, `user_id` (if authenticated), and the original error message. Silent swallowing is forbidden.
2. **Every structured log entry MUST include**: `timestamp` (ISO 8601 UTC), `level`, `service`, `trace_id`. Auth-context operations also include `user_id`.
3. **Sensitive data MUST never appear in logs**: passwords, tokens, API keys, and PII (email, CPF, phone, card numbers) at any log level including DEBUG.
4. **Every API endpoint MUST emit a request log entry** containing: method, path template (not the full URL with values), response status code, and duration in milliseconds.
5. **Alerting thresholds MUST be defined before a service reaches production** — not after the first incident.
6. **Distributed traces MUST be propagated across service boundaries** via W3C `traceparent` header — trace IDs must not be regenerated at each service hop.

## Structured Logging

### Log Format
- Production: JSON — never unstructured text.
- Development: human-readable OK; structured JSON still preferred.
- Log to stdout/stderr — never to files on disk in containerized environments.

### Log Levels
| Level | When to use | Stack trace? |
|-------|-------------|-------------|
| `ERROR` | Unexpected failure requiring human attention | Yes |
| `WARN` | Expected degradation (rate limit, retry success, circuit breaker trip) | No |
| `INFO` | Significant business event (user created, order placed, payment confirmed) | No |
| `DEBUG` | Detailed execution trace for troubleshooting — disabled in production | No |

### Required Log Fields per Context
```json
// All backend operations
{ "timestamp": "2025-01-15T14:32:01.123Z", "level": "info", "service": "api", "trace_id": "abc123" }

// Authenticated operations — add user_id
{ ..., "user_id": "usr_456" }

// Multi-tenant services — add organization_id
{ ..., "user_id": "usr_456", "organization_id": "org_789" }

// Error captures — add operation and entity context
{ ..., "level": "error", "operation": "order.charge", "order_id": "ord_123", "error": "stripe timeout" }

// Request log — add HTTP fields
{ ..., "method": "POST", "path": "/api/orders", "status": 201, "duration_ms": 145 }
```

### PII Sanitization
- Mask before logging: `email → "us***@example.com"`, `phone → "(**) *****-1234"`.
- Never log: full credit card numbers, CVV, passwords, tokens (log type and expiry only).
- Prefer logging entity IDs over entity values: `user_id: "usr_456"` not `email: "user@example.com"`.

## Metrics

### Metric Naming Convention
```
{service}.{resource}.{operation}.{unit}
Examples:
  api.orders.create.duration_ms
  api.auth.login.count
  worker.emails.send.error_count
  db.queries.slow.count
```

### Required Application Metrics
| Metric | Type | Description |
|--------|------|-------------|
| Request rate | Counter | Requests per second per endpoint |
| Error rate | Counter | 4xx/5xx responses per endpoint |
| Latency percentiles | Histogram | p50/p95/p99 per endpoint |
| Queue depth | Gauge | Messages pending per queue |
| Active connections | Gauge | DB connection pool usage |

### Cardinality Rule
- Do NOT use unbounded values as metric labels: no `user_id`, `order_id`, `request_id` as labels.
- Use categorical labels: `endpoint`, `status_class` (2xx/4xx/5xx), `region`, `version`.

## Distributed Tracing

### Trace Propagation
- Every inbound request without `traceparent` header gets a new trace ID generated at the entry point.
- `traceparent` passed downstream to all service calls, queue messages, and async operations.
- Async operations: carry trace context in the message envelope, not just HTTP headers.

### Span Naming
```
✅ Correct:  "POST /api/orders/{id}"  (route template)
❌ Wrong:    "POST /api/orders/ord_123"  (cardinality explosion)
```

### Span Attributes
Record as span attributes (not log lines):
- HTTP status code
- Database operation type (`SELECT`, `INSERT`, `UPDATE`)
- External service name called
- Entity IDs relevant to the operation

## Alerting

### Alert Design Rules
- Alert on **symptoms**, not causes: `"p95 latency > 2s for 5 minutes"` not `"CPU > 80%"`.
- Every alert has a linked runbook — no naked alerts without diagnosis steps.
- Alert fatigue prevention: alerts firing > 3 times/week without action → recalibrate threshold or suppress.
- On-call routing: alerts route to a specific team rotation, not a shared inbox.

### Minimum Alert Coverage
| Signal | Threshold | Severity |
|--------|-----------|----------|
| Error rate | > 1% for 5 min | HIGH |
| p95 latency | > baseline × 3 for 5 min | HIGH |
| Service down | Health check fails 3× in 1 min | CRITICAL |
| DLQ depth | > 0 for 10 min | MEDIUM |
| Disk usage | > 80% | MEDIUM |

### Thresholds
- `_tbd_` values are placeholders — replace with project-specific baselines from `performance-auditor.md`.
- Staging thresholds can be 2× looser than production thresholds.

## Health Checks

- Every service exposes `/health` (or `/_health`): returns `200 OK` when ready to receive traffic.
- **Liveness** (process alive) vs **Readiness** (dependencies available) — separate endpoints if platform requires.
- Health check response body:
  ```json
  { "status": "ok", "version": "1.2.3", "checks": { "database": "ok", "redis": "degraded" } }
  ```
- Authentication: none required — callable by load balancers without credentials.
- Dependency checks: include database, cache, message broker — not just the process itself.

## Testing

```
QUERY: Trigger an error path in [service]. Inspect log output.
  → Verify: log entry at ERROR level contains: operation, error message, user_id (if auth), entity_id.
  → Verify: no password, token, email, CPF, or card number appears in the log entry.
  SUCCESS: all required fields present, zero PII. FAILURE: PII found or context fields missing.

QUERY: Make 3 consecutive API requests with the same session. Check logs for trace_id consistency.
  → All log entries for a single request share the same trace_id.
  → Different requests have different trace_ids.
  FAILURE: trace_id changes within a single request lifecycle (broken propagation).

VERIFY: Shut down the database. Call /health.
  → Expected: 503 Service Unavailable with body: { "status": "degraded", "checks": { "database": "error" } }
  FAILURE: 200 OK returned (health check does not verify dependency availability).

QUERY: Verify alert configuration exists before production deploy.
  → Check monitoring platform: at minimum ERROR rate and p95 latency alerts configured.
  → Each alert has a runbook link.
  FAILURE: no alerts configured (blind production service).
```
