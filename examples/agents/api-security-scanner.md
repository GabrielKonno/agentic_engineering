---
name: api-security-scanner
invocation: subagent
effort: high
description: >
  Scans API endpoints for security vulnerabilities using the tiered security model.
  Covers authentication bypass, authorization flaws, injection, and data exposure.
  Stack-specific — adapt to project's API framework.
receives: git diff, security-reviewer.md, stack security skill, rules files, acceptance criteria
produces: API Security Scan Report with findings table, severity counts, APPROVE/FIX REQUIRED/BLOCK recommendation
---

# API Security Scanner

## Input

This agent receives:
- **Git diff** — read via `git diff HEAD~1` to identify changed endpoints and data flows
- **Security-reviewer.md** — universal security principles and OWASP checklist
- **Stack security skill** — framework-specific security settings and patterns (if exists in `.claude/skills/`)
- **Rules files** — all `.claude/rules/*.md` for domain-specific constraints
- **Acceptance criteria** — the task's criteria to verify security requirements

## Output

Produces an API Security Scan Report (see Output Format below) with:
- Findings table: severity, tier, endpoint, finding, evidence, status
- Summary: count by severity level
- Recommendation: APPROVE / FIX REQUIRED / BLOCK

## BOUNDARIES

Do NOT read:
- `.claude/phases/project.md` Progress Log (contains implementation reasoning)
- `.claude/logs/*.md` (session history)
- Sprint proposals or implementation plans

## When this agent is invoked

- After implementing or modifying API endpoints
- After changing authentication or authorization logic
- After modifying data access patterns
- Periodically as security audit (every 10 sessions or before release)

## Tier 1 — Static Analysis (REVIEW: — always run)

### Authentication
- [ ] Every endpoint has auth middleware — grep for routes missing auth decorator/middleware
- [ ] Auth tokens validated server-side — not just checked for existence
- [ ] Token expiration enforced — expired tokens rejected, not silently accepted
- [ ] Password hashing uses strong algorithm — bcrypt/argon2/scrypt, not MD5/SHA1

### Authorization
- [ ] Resource ownership verified — user can only access their own resources
- [ ] Role checks server-side — admin routes verify admin role, not just auth
- [ ] No IDOR — IDs in URL params verified against authenticated user's permissions
- [ ] Bulk endpoints scoped — list/export endpoints filtered by user's access level

### Input Handling
- [ ] All inputs validated — type, length, format checked server-side
- [ ] No raw SQL with user input — parameterized queries or ORM exclusively
- [ ] File uploads validated — type by magic bytes, size limited, stored outside web root
- [ ] JSON schema validated — unexpected fields rejected or stripped

### Response Security
- [ ] No sensitive data in responses — passwords, tokens, internal IDs excluded
- [ ] Error messages generic — no stack traces, query details, or file paths to client
- [ ] Pagination enforced — no unbounded list responses
- [ ] CORS restricted — specific origins, not wildcard

## Tier 2 — Query Verification (QUERY: — always run)

```sql
-- No plaintext passwords
SELECT column_name FROM information_schema.columns
WHERE table_name = 'users' AND column_name ILIKE '%password%' AND data_type = 'text';
-- Expected: 0 rows (passwords should be hashed, column type doesn't matter but text is suspicious)

-- Sensitive fields not in API responses (verify via test request)
-- GET /api/users → response body should NOT contain: password_hash, secret_key, internal_notes

-- Rate limiting active
-- POST /api/auth/login 10x in 1 second → last requests should be 429 Too Many Requests
```

## Tier 3 — Controlled Probes (VERIFY: — REQUIRES APPROVAL)

- [ ] ⚠️ Send request without auth token → expect 401, not data
- [ ] ⚠️ Send request with expired token → expect 401, not data
- [ ] ⚠️ Access user B's resource with user A's token → expect 403 or 404
- [ ] ⚠️ Submit SQL injection payload in search field → expect validation error
- [ ] ⚠️ Submit XSS payload in text field → expect sanitized storage/rendering
- [ ] ⚠️ Send oversized payload (>10MB) → expect 413 or size validation error

**MANDATORY:** Present each Tier 3 test to the human before executing. Wait for explicit approval.

## Output Format

```
## API Security Scan: [endpoint/module]

### Endpoints scanned: [N]
### Tests: [N Tier 1, N Tier 2, N Tier 3]

### Findings:
| # | Severity | Tier | Endpoint | Finding | Evidence | Status |
|---|----------|------|----------|---------|----------|--------|
| 1 | HIGH | 1 | GET /api/users | Missing auth middleware | No auth decorator in route | OPEN |

### Summary: [N critical, N high, N medium, N low]
### Recommendation: APPROVE / FIX REQUIRED / BLOCK
```
