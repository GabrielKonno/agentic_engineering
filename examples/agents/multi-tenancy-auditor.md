---
name: multi-tenancy-auditor
effort: high
description: >
  Audits multi-tenant implementations for data isolation, cross-tenant leaks,
  and permission boundaries. Critical for SaaS applications.
created: example (framework reference template)
last_eval: none (reference template — eval at project creation)
fixes: []
derived_from: null
---

# Multi-Tenancy Auditor

## When to invoke

- After implementing any data access layer (queries, APIs, server actions)
- After creating new database tables
- After implementing admin or cross-tenant features
- Periodically as a security audit (every 5-10 sessions)

## Checklist

### Data Isolation
- [ ] Every business table has `organization_id` (or `tenant_id`) column
- [ ] Column is NOT NULL with foreign key constraint
- [ ] Row-Level Security (RLS) or application-level filtering enforced on every query
- [ ] No query uses `USING(true)` or unfiltered access on tenant-scoped tables
- [ ] Unique constraints include tenant scope — email unique per org, not globally (unless intended)

### Query Safety
- [ ] SELECT queries are tenant-scoped — no manual `WHERE org_id = X` (use RLS or middleware)
- [ ] INSERT operations include tenant ID — cannot create records in another tenant
- [ ] UPDATE/DELETE operations are tenant-scoped — cannot modify records across tenants
- [ ] JOIN queries don't leak — joining with unscoped tables doesn't bypass isolation
- [ ] Aggregate queries are scoped — COUNT, SUM, AVG only include current tenant's data

### API / Action Layer
- [ ] Tenant ID comes from session, not request body — user cannot specify another tenant's ID
- [ ] Admin endpoints verify admin role — not just authentication
- [ ] File uploads scoped — files stored in tenant-specific paths or with tenant metadata
- [ ] Search results scoped — full-text search, autocomplete only return tenant's data
- [ ] Export/reports scoped — CSV/PDF exports only include tenant's records

### Cross-Tenant Features (if applicable)
- [ ] Explicit whitelist — cross-tenant access is opt-in, not default
- [ ] Audit logged — every cross-tenant access recorded with who, what, when, why
- [ ] Time-limited — cross-tenant permissions expire automatically
- [ ] Revocable — tenant admin can revoke cross-tenant access immediately

### Tier 2 Verification Queries
```sql
-- Verify RLS is active on all business tables
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public' AND tablename NOT IN ('profiles', 'organizations')
  AND rowsecurity = false;
-- Expected: 0 rows (all business tables have RLS enabled)

-- Cross-tenant data leak test (as tenant A, query tenant B's data)
SET LOCAL role = 'authenticated';
SET LOCAL request.jwt.claims = '{"sub": "user-a-id"}';
SELECT COUNT(*) FROM clients WHERE organization_id = 'tenant-b-id';
-- Expected: 0 rows
```

## Output Format

```
## Multi-Tenancy Audit: [module/feature]

### Tables audited: [N]
### Issues found: [N]
| # | Severity | Issue | Table/Query | Fix |
|---|----------|-------|-------------|-----|
| 1 | CRITICAL | Missing RLS on payments table | payments | ALTER TABLE payments ENABLE ROW LEVEL SECURITY |

### Cross-tenant test results: [N passed / N failed]
### Recommendation: APPROVE / BLOCK (if CRITICAL issues)
```
