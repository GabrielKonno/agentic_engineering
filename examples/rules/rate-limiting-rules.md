---
domain: rate-limiting-abuse-prevention
applies_to: public API endpoints, authentication endpoints, webhook receivers, payment endpoints
---

# Rate Limiting & Abuse Prevention Rules

## Inviolable Rules

1. **Every public endpoint MUST have rate limiting** — no exceptions for "internal" endpoints exposed publicly.
2. **Authentication endpoints MUST have stricter limits than general API endpoints.**
3. **Rate limit state MUST be shared across instances** (Redis, distributed counter) — not per-instance in-memory counters that reset on deploy.
4. **Rate limit responses MUST include `Retry-After` header** with seconds until reset.

## Rate Limit Strategy Patterns

| Strategy | Mechanism | Pros | Cons | Best for |
|----------|-----------|------|------|----------|
| Fixed window | Count requests per fixed time window (e.g., per minute) | Simple to implement | Burst at window edges | Low-risk general endpoints |
| Sliding window log | Log each request timestamp, count within sliding window | Precise, no edge burst | Higher memory per user | Auth endpoints |
| Token bucket | Tokens replenish at fixed rate, each request consumes one | Smooth, configurable burst | Slightly more complex | APIs with burst requirements |

**Decision guide:** Use sliding window for auth/payment endpoints (precision matters). Use token bucket for general API (burst tolerance). Use fixed window only as fallback when simpler options unavailable.

## Endpoint-Specific Defaults

| Endpoint Type | Default Limit | Window | Key |
|---------------|---------------|--------|-----|
| Login / authentication | 5 attempts | 15 minutes | IP + account |
| Password reset | 3 requests | 1 hour | email |
| API general (authenticated) | 100 requests | 1 minute | user ID |
| API general (unauthenticated) | 20 requests | 1 minute | IP |
| File upload | 10 uploads | 1 hour | user ID |
| Webhook receiver | 1000 requests | 1 minute | sender ID / IP |
| Account creation / registration | 3 accounts | 1 hour | IP |

These are STARTING POINTS. Adjust based on actual usage patterns after deployment.

## Abuse Pattern Taxonomy

| Pattern | Detection Signal | Response | Logging |
|---------|-----------------|----------|---------|
| Account enumeration | High rate on forgot-password or registration for different emails from same IP | Rate limit + CAPTCHA after threshold | WARN: enumerate attempt, IP, count |
| Credential stuffing | High rate of failed logins across different accounts from same IP range | Rate limit + block IP range + notify security | ERROR: stuffing detected, IP range, account count |
| Card testing | Multiple small charges from same user or session in short window | Block after 3 failed charges + flag account | ERROR: card testing, user_id, charge count |
| Content scraping | High rate of GET requests following predictable patterns (pagination, sequential IDs) | Rate limit + require auth + add delay | WARN: scraping pattern, IP, endpoint pattern |
| Denial of wallet | Triggering expensive operations (AI inference, file processing, email sends) at high rate | Rate limit expensive operations independently + queue | WARN: expensive op rate, user_id, operation type |

## Response Headers

Rate-limited responses (HTTP 429) MUST include:
```
Retry-After: <seconds>
X-RateLimit-Limit: <max requests>
X-RateLimit-Remaining: <requests left>
X-RateLimit-Reset: <UTC epoch seconds>
```

## Testing Criteria

### REVIEW:
- [ ] Rate limiting middleware applied to all public routes — not just auth
- [ ] Rate limit keys include both user identifier AND IP where applicable
- [ ] Rate limit storage is shared across instances (not in-memory default)
- [ ] 429 response includes `Retry-After` header

### QUERY:
- QUERY: Are rate limit rules configured for auth endpoints? → expect: yes, stricter than general
- QUERY: What storage backend is used for rate limit state? → expect: Redis or equivalent, not in-memory
