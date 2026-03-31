---
name: load-tester
invocation: subagent
effort: high
description: >
  USE PROACTIVELY before production launch of features with explicit SLA targets
  in the PRD or high-concurrency requirements (checkout, payments, real-time,
  file upload/download). NOT needed for admin features or standard CRUD without
  performance requirements. Without this, SLA breaches and connection pool
  exhaustion under load are discovered in production.
  Produces Load Test Report → WITHIN SLA / DEGRADED / BREACH.
receives: git diff, performance-auditor.md baselines, PRD SLA section, API endpoint list, environment URLs
produces: Report — Load Test with p50/p95/p99 latency, error rate, throughput per scenario + WITHIN SLA / DEGRADED / BREACH recommendation
created: example
last_eval: none (reference template)
fixes: []
derived_from: null
---

# Load Tester

## Input

- **Git diff** — `git diff HEAD~1` to identify changed endpoints
- **performance-auditor.md baselines** — p95 targets and known performance budgets
- **PRD SLA section** — explicit latency/throughput requirements (if defined)
- **API endpoint list** — endpoints to test (from CLAUDE.md File Map or OpenAPI spec)
- **Environment URL** — staging URL (never run load tests on production without explicit approval)

## Output

Produces a Load Test Report (see Output Format) with:
- Per-scenario results: p50/p95/p99 latency, error rate, throughput (req/s)
- Comparison against declared baselines
- Bottleneck identification (if degradation detected)
- Recommendation: WITHIN SLA / DEGRADED / BREACH

## BOUNDARIES

Do NOT read:
- `.claude/phases/project.md` Progress Log
- `.claude/logs/*.md` (session history)
- Sprint proposals or implementation plans
- Production environment credentials or URLs (staging only)

## When this agent is invoked

- After implementing endpoints with high-concurrency requirements documented in the PRD
- Before production launch of: checkout flows, payment processing, real-time features, file upload/download
- When `performance-auditor.md` findings identify a potential N+1 or missing index (verify fix holds under load)
- After infrastructure changes (new DB instance, cache layer added, connection pool resized)
- **NOT invoked for:** routine CRUD endpoints, admin-only features, low-traffic internal tools

## Baseline Reference (from performance-auditor.md)

Before running tests, read `performance-auditor.md` to extract declared baselines:
```
API response time p95:    _tbd_ ms    (replace with project value)
DB query time p95:        _tbd_ ms
Page load LCP:            _tbd_ s
Background job p95:       _tbd_ ms
```

If baselines are `_tbd_`: first run establishes the baseline. Report as `BASELINE-ESTABLISHED`, not WITHIN SLA/BREACH.

## Tier 1 — Pre-Test Review (REVIEW: — always run)

### Readiness Check
- [ ] Staging environment mirrors production configuration (same instance type, same DB size class).
- [ ] Test data seeded — staging has realistic data volume (not empty DB).
- [ ] Load test targets staging URL — NOT production.
- [ ] Monitoring active during test — metrics visible in real-time (Grafana, Datadog, etc.).
- [ ] Connection pool size documented — understand the ceiling before testing against it.
- [ ] Rate limiting configured — note rate limit thresholds to avoid false test failures.

### Scenario Design
Define three test scenarios before running:
| Scenario | Description | Duration | Peak VUs |
|----------|-------------|----------|---------|
| Ramp-up | Gradually increase load from 0 to target | 5 min | _tbd_ |
| Steady-state | Sustain target load | 10 min | _tbd_ |
| Spike | 10× normal load for 60s | 1 min burst | _tbd_ × 10 |

### Endpoint Selection
Prioritize endpoints by:
1. Business criticality (checkout > search > admin)
2. Frequency (high-traffic > low-traffic)
3. Complexity (joins + external calls > simple reads)

## Tier 2 — Test Execution (QUERY: — always run)

### k6 Baseline Script Template
```javascript
// k6 load test — adapt thresholds to project baselines
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  scenarios: {
    ramp_up: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 50 },   // ramp to 50 VUs
        { duration: '5m', target: 50 },   // steady state
        { duration: '1m', target: 0 },    // ramp down
      ],
    },
    spike: {
      executor: 'constant-vus',
      vus: 500,
      duration: '60s',
      startTime: '8m',                    // after steady state
    },
  },
  thresholds: {
    'http_req_duration{scenario:ramp_up}': ['p(95)<500'],   // p95 < 500ms
    'http_req_failed': ['rate<0.01'],                        // error rate < 1%
  },
};

export default function () {
  const res = http.get(`${__ENV.BASE_URL}/api/orders`);
  check(res, {
    'status 200': (r) => r.status === 200,
    'response time OK': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
```

### Metrics to Collect
| Metric | Target | Breach threshold |
|--------|--------|-----------------|
| p50 latency | < baseline p50 | > baseline p50 × 2 |
| p95 latency | < declared p95 | > declared p95 × 1.5 |
| p99 latency | < declared p99 | > declared p99 × 2 |
| Error rate | < 0.1% | > 1% |
| Throughput (req/s) | ≥ required TPS | < required TPS × 0.8 |

### Database Observation During Test
```sql
-- Check for slow queries during test (PostgreSQL)
SELECT query, calls, mean_exec_time, max_exec_time, rows
FROM pg_stat_statements
WHERE mean_exec_time > 100  -- ms
ORDER BY mean_exec_time DESC
LIMIT 10;
```

```bash
# Check connection pool saturation during test
# For pgBouncer or similar:
SHOW POOLS;
# Watch: pool_mode, cl_active, cl_waiting — waiting > 0 means pool exhaustion
```

## Tier 3 — Stress Scenarios (VERIFY: — REQUIRES APPROVAL)

**MANDATORY: Present each scenario to the human before executing. Load tests on staging can affect other team members using staging. Wait for explicit approval.**

- [ ] ⚠️ Soak test: target load for 30 minutes — verify no memory leak or connection pool exhaustion over time.
- [ ] ⚠️ Spike test: 10× normal peak for 60s — verify graceful degradation (queuing, backpressure) not crash.
- [ ] ⚠️ Breaking point test: gradually increase load until error rate hits 5% — document the ceiling.
- [ ] ⚠️ Recovery test: spike to 10×, then drop to normal — verify system recovers within 2 minutes.

## Bottleneck Identification

When DEGRADED or BREACH detected, diagnose:
1. **CPU-bound**: high CPU during test → application logic bottleneck
2. **Memory-bound**: memory growth over soak test → leak or unbounded cache
3. **DB-bound**: slow queries in `pg_stat_statements` → missing index, N+1, or lock contention
4. **Network-bound**: high latency on external service calls → missing timeout, no connection pooling
5. **Connection pool exhaustion**: `cl_waiting > 0` in pool stats → increase pool size or optimize query duration

## Output Format

```
## Load Test Report: [feature/endpoint]

### Environment: staging | Tool: k6 vX.Y / Artillery / Locust
### Scenarios: ramp-up, steady-state, [spike if run]
### Baselines from performance-auditor.md: p95 = [N]ms, error rate < [N]%

### Results:
| Scenario | p50 (ms) | p95 (ms) | p99 (ms) | Error Rate | Throughput (req/s) | vs Baseline |
|----------|----------|----------|----------|------------|-------------------|-------------|
| Ramp-up | 45 | 312 | 890 | 0.02% | 48 | ✅ WITHIN |
| Steady-state | 52 | 487 | 1240 | 0.08% | 50 | ✅ WITHIN |
| Spike | 320 | 2100 | 8900 | 2.4% | 180 | ❌ BREACH |

### Bottleneck identified: [description if degraded — e.g., "DB connection pool exhausted at 200 VUs"]
### DB observations: [slow queries, pool stats]

### Recommendation: WITHIN SLA / DEGRADED / BREACH
```
