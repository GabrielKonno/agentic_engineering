---
name: deploy-validator
effort: medium
description: >
  Pre-deployment checklist ensuring the application is ready for production.
  Run before every deployment to staging or production.
---

# Deploy Validator

## When to invoke

- Before deploying to staging or production
- After significant changes (new modules, dependency updates, infrastructure changes)
- When switching deploy targets (new provider, new region, new domain)

## Checklist

### Build
- [ ] Build succeeds — `npm run build` / `python -m build` / equivalent exits with 0
- [ ] No TypeScript errors — `tsc --noEmit` clean (or equivalent type check)
- [ ] No linting errors — linter exits clean on production code
- [ ] All tests pass — full test suite green
- [ ] Build output size acceptable — no unexpected increase (>20% growth warrants investigation)

### Environment
- [ ] All required env vars documented — `.env.example` lists every variable the app needs
- [ ] No secrets in code — grep for API keys, passwords, tokens in source files
- [ ] Environment-specific config correct — database URLs, API endpoints point to right environment
- [ ] Feature flags set — experimental features disabled in production (unless intentional)
- [ ] Debug mode off — `DEBUG=false`, `NODE_ENV=production`, framework-specific debug settings

### Database
- [ ] Migrations applied — target database schema matches code expectations
- [ ] Seed data present — required configuration data exists (categories, roles, settings)
- [ ] Connection limits configured — pool size appropriate for expected load
- [ ] Backup verified — recent backup exists before deploying destructive changes

### Security
- [ ] HTTPS enforced — HTTP redirects to HTTPS, HSTS configured
- [ ] CORS configured — allowed origins are specific, not `*`
- [ ] Rate limiting active — auth endpoints and public APIs have limits
- [ ] Security headers present — CSP, X-Frame-Options, X-Content-Type-Options
- [ ] Dependencies audited — no known critical vulnerabilities

### Monitoring
- [ ] Error tracking configured — uncaught exceptions are captured (Sentry, etc.)
- [ ] Health check endpoint exists — `/health` or `/api/health` returns 200
- [ ] Logging appropriate — no sensitive data in logs, structured format
- [ ] Alerts configured — team notified on deploy failure or error spike

### Rollback Plan
- [ ] Previous version identified — know exactly what to revert to
- [ ] Rollback tested — process documented and verified
- [ ] Database rollback considered — if migration is destructive, rollback plan exists
- [ ] Communication plan — who to notify if rollback is needed

## Output Format

```
## Deploy Validation: [environment]

### Checks: [N/N passed]
### Blockers: [N critical issues]
| # | Category | Issue | Impact | Resolution |
|---|----------|-------|--------|------------|
| 1 | Security | CORS set to * | Data leak risk | Restrict to production domain |

### Environment: [staging/production]
### Build hash: [commit SHA]
### Previous version: [commit SHA for rollback]

### Recommendation: DEPLOY / FIX FIRST / ABORT
```
