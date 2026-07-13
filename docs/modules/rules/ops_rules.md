# Template: Ops Rules (lifecycle dimension)

> Create at `.claude/rules/ops-rules.md` during bootstrap — **production+ profiles only**.
> The CATEGORIES below are universal; the CONTENT in each is filled by the stack module
> (e.g., managed-Postgres → PITR/advisors; serverless → cron/connection-pooler). A category
> with no stack content yet stays as an explicit `TODO` — never silently dropped.
> Consumed by `codebase-audit` (NOT the per-diff review — ops is not a diff concern).

````markdown
---
domain: ops
applies_to: "**/*"
---

# Ops Rules (the Operate dimension)

The per-diff reviewers and validation cover everything BEFORE deploy. This file covers
everything AFTER: the runtime health of the deployed system. Walked category-by-category by
`codebase-audit`; each is PASS or a GAP → task.

## 1. Backups & recovery
- [ ] Automated backups enabled and their restore actually TESTED (an untested backup is a hope)?
- [ ] Point-in-time recovery configured where the data warrants it?
- [ ] Recovery procedure documented (who, what command, expected RTO/RPO)?
- Stack content: [fill — e.g., DB provider's PITR setting, backup cron, restore runbook]

## 2. Observability & alerting
- [ ] Errors surfaced to a tracker (not just logs no one reads)?
- [ ] Alerts on the few signals that matter (error rate, latency, failed jobs, money anomalies)?
- [ ] Structured logs with correlation IDs (user/request/tenant) — no PII in logs?
- Stack content: [fill — error tracker, dashboards, alert channels]

## 3. CI / deploy safety
- [ ] CI runs lint + build + test as a hard gate on every change (the t=0 floor)?
- [ ] Deploys are reversible (rollback path) and migrations are backward-safe?
- [ ] Environment parity: staging/prod config differs only by secrets, not behavior?
- Stack content: [fill — CI provider, deploy target, migration runner]

## 4. Secrets & access
- [ ] Secrets in a manager / env, never in code or logs?
- [ ] Rotation policy for credentials and tokens?
- [ ] Least-privilege on service accounts and DB roles?
- Stack content: [fill — secret store, rotation cadence]

## 5. Connection & resource management
- [ ] Connection pooling correct for the runtime (esp. serverless → pooler, not direct)?
- [ ] Rate limits / quotas on external calls handled with backoff?
- [ ] Background jobs / cron idempotent and monitored?
- Stack content: [fill — pooler, queue, cron platform]

## 6. Data reconciliation (production-financial)
- [ ] Periodic SELECT-only checks that derived/aggregate data matches source of truth?
- [ ] Anomaly count expected = 0; any nonzero is a high-priority finding?
- Stack content: [fill — the actual reconciliation queries, schema-specific]
````
