---
name: multi-tenancy-patterns
invocation: inline
effort: high
description: >
  Architecture and security patterns for multi-tenant SaaS — isolation strategy
  selection (row-level vs schema vs database), tenant-scoped data model with
  RLS, application-layer tenant resolution, and cross-tenant leak prevention.
  Consult when designing tenant isolation, adding new tables to a multi-tenant
  schema, or reviewing queries that touch tenant-scoped data. Includes 8
  pitfalls and 3 STRONG criteria for cross-tenant leak detection.
created: example (framework reference template)
derived_from: null
fixes: []
---

# Multi-Tenancy Patterns

## Isolation Strategies

| Strategy | Isolation | Complexity | When to use |
|----------|-----------|------------|-------------|
| Shared DB, shared schema (row-level) | Column-based (`org_id`) | Low | Most SaaS MVPs, <1000 tenants |
| Shared DB, separate schemas | Schema-based | Medium | Regulated industries needing logical separation |
| Separate databases | Full isolation | High | Enterprise with compliance requirements (HIPAA, SOC2) |

**Most common (and recommended for MVPs):** Shared DB + shared schema + Row-Level Security.

## Data Model Pattern

```sql
-- Every business table has organization_id
CREATE TABLE items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS policy
ALTER TABLE items ENABLE ROW LEVEL SECURITY;
CREATE POLICY items_org_isolation ON items
  USING (organization_id = get_current_org_id())
  WITH CHECK (organization_id = get_current_org_id());

-- Unique constraints include org scope
ALTER TABLE items ADD CONSTRAINT items_name_unique
  UNIQUE (organization_id, name);

-- Indexes include org_id
CREATE INDEX items_org_idx ON items(organization_id);
CREATE INDEX items_org_name_idx ON items(organization_id, name);
```

## Application Layer Pattern

```
Request → Auth Middleware → Tenant Resolution → Controller → Tenant-Scoped Query → Response

Tenant resolution sources (in order of preference):
1. JWT claims (org_id embedded in token at login)
2. Database lookup (user → organization_members → organization)
3. Subdomain (tenant1.app.com → resolve tenant1)
4. Header (X-Tenant-ID — only for server-to-server)
```

## Common Pitfalls

| Pitfall | Impact | Prevention |
|---------|--------|------------|
| Missing `org_id` on new table | Cross-tenant data leak | DB checklist: every table needs org_id + RLS |
| Filtering by org_id in app code | Inconsistent, forgettable | Use RLS (DB level) or middleware (app level) |
| Org_id from request body | Tenant spoofing | Always derive from session, never from user input |
| Global search without scoping | Data leak via search | Search queries must include tenant filter |
| Aggregations without scoping | Metrics include other tenants' data | All COUNT/SUM/AVG queries scoped |
| Shared cache without tenant key | Cache poisoning across tenants | Cache key = `{tenant_id}:{resource}:{id}` |
| File uploads without tenant path | File access across tenants | Store in `/{tenant_id}/uploads/` path |
| Background jobs without tenant context | Job runs with wrong or no tenant | Pass `org_id` to job payload, set context at start |

## STRONG Criteria Examples

```
QUERY: As user in org_A, SELECT * FROM items WHERE organization_id = 'org_B_id'
  → Returns 0 rows (RLS blocks cross-org access)
  SUCCESS: 0 rows. FAILURE: any rows returned = CRITICAL security issue

QUERY: Create item via API with org_id = 'org_B_id' in request body (user is in org_A)
  → Item created with org_A (from session), NOT org_B (from body)
  → SELECT organization_id FROM items WHERE id = [new_item_id] → org_A
  SUCCESS: session org used. FAILURE: body org used = tenant spoofing vulnerability

VERIFY: User in org_A searches for "test" → results only from org_A
  → User in org_B searches for "test" → results only from org_B
  → Same search term, different results based on tenant
  SUCCESS: results isolated. FAILURE: cross-tenant results visible
```
