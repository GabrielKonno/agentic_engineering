---
name: ci-cd-pipeline
effort: medium
description: >
  CI/CD pipeline patterns for automated testing, building, and deployment.
  Covers GitHub Actions, environment management, and deployment strategies.
---

# CI/CD Pipeline Patterns

## Pipeline Stages

```
Push/PR → Lint → Type Check → Unit Tests → Build → Integration Tests → Deploy Preview → Deploy Production
         ↓ fail: block PR    ↓ fail: block   ↓ fail: block    ↓ optional       ↓ manual approval
```

## GitHub Actions Template

```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: "npm"
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check  # tsc --noEmit
      - run: npm test -- --coverage
      - run: npm run build

  deploy-preview:
    needs: quality
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # Deploy to preview URL (Vercel, Netlify, etc.)
      # Comment preview URL on PR

  deploy-production:
    needs: quality
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    environment: production  # Requires manual approval in GitHub settings
    steps:
      - uses: actions/checkout@v4
      # Deploy to production
```

## Environment Management

| Environment | Branch | Auto-deploy? | Database | Purpose |
|-------------|--------|-------------|----------|---------|
| Development | feature/* | No | Local/dev DB | Individual developer testing |
| Preview | PR branches | Yes (per PR) | Shared staging DB | PR review with preview URL |
| Staging | main | Yes | Staging DB (copy of prod schema) | Final validation before prod |
| Production | main (with approval) | Manual trigger | Production DB | Live users |

## Deployment Strategies

| Strategy | Downtime | Rollback speed | When to use |
|----------|----------|----------------|-------------|
| Direct deploy | Brief | Slow (redeploy) | Small apps, low traffic |
| Blue-green | Zero | Instant (switch) | Critical apps needing zero downtime |
| Rolling | Zero | Moderate | Container orchestration (K8s) |
| Canary | Zero | Fast (route 0%) | High-traffic apps, gradual rollout |

## Pre-Deploy Checklist (automated)

```yaml
# In pipeline, before deploy step:
- name: Security audit
  run: npm audit --production --audit-level=high

- name: Bundle size check
  run: |
    npm run build
    MAX_SIZE=500  # KB
    ACTUAL=$(du -sk .next/static | cut -f1)
    if [ $ACTUAL -gt $MAX_SIZE ]; then
      echo "Bundle too large: ${ACTUAL}KB > ${MAX_SIZE}KB"
      exit 1
    fi

- name: Migration check
  run: |
    # Verify pending migrations are committed
    npx prisma migrate status  # or equivalent
```

## Secrets Management

- **Never in code** — all secrets in GitHub Secrets or environment variables
- **Per-environment** — different API keys for staging vs production
- **Rotation plan** — secrets rotated on schedule, not just when compromised
- **Least privilege** — CI token has minimum permissions needed (read repo, deploy)

## Common Pitfalls

| Pitfall | Impact | Fix |
|---------|--------|-----|
| No caching in CI | Slow builds (5-10 min) | Cache node_modules, .next, pip cache |
| Tests on push only, not PR | Broken code merged | Run on `pull_request` event |
| No deploy preview | Reviewers can't test | Auto-deploy preview per PR |
| Secrets in build logs | Credential leak | Mask secrets, use `::add-mask::` |
| No rollback procedure | Stuck with broken deploy | Document and test rollback before first deploy |
| Deploy without migration | Schema mismatch, crashes | Run migrations as deploy step, before app restart |
