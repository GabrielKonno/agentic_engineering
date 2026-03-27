---
domain: multi-tenancy
applies_to: all modules with organization-scoped data
---

# Multi-Tenancy Rules

## Inviolable Rules

1. **Every business table MUST have `organization_id`** — exceptions only for identity tables (users, organizations themselves).
2. **Every business table MUST have Row-Level Security enabled** — no exceptions.
3. **RLS policies MUST use a trusted function** (e.g., `get_current_org_id()`) — never `USING(true)`, never hardcoded values, never user-supplied parameters.
4. **`organization_id` MUST come from the authenticated session** — never from request body, URL params, or client-side state.
5. **Unique constraints MUST include `organization_id` in scope** — email is unique per org, not globally (unless cross-org uniqueness is a business requirement).

## Query Rules

- **SELECT**: Never filter by `organization_id` manually in application code — RLS handles it. Manual filtering is redundant and risks using the wrong value.
- **INSERT**: Always include `organization_id` from the session/middleware. Never trust client-provided org_id.
- **UPDATE/DELETE**: RLS ensures only current tenant's records are affected. Application code should still verify ownership for defense-in-depth.
- **JOIN**: Be cautious with joins to unscoped tables (e.g., `profiles`) — they may bypass RLS and leak data from other tenants. Test cross-tenant joins explicitly.
- **Aggregations**: `COUNT`, `SUM`, `AVG` are automatically scoped by RLS if policies are correct. Verify with cross-tenant test.

## New Table Checklist

```sql
-- 1. Column
ALTER TABLE new_table ADD COLUMN organization_id UUID NOT NULL
  REFERENCES organizations(id) ON DELETE CASCADE;

-- 2. RLS
ALTER TABLE new_table ENABLE ROW LEVEL SECURITY;

-- 3. Policies (adapt to access level)
CREATE POLICY new_table_select ON new_table FOR SELECT
  USING (organization_id = get_current_org_id());
CREATE POLICY new_table_insert ON new_table FOR INSERT
  WITH CHECK (organization_id = get_current_org_id());
CREATE POLICY new_table_update ON new_table FOR UPDATE
  USING (organization_id = get_current_org_id());
CREATE POLICY new_table_delete ON new_table FOR DELETE
  USING (organization_id = get_current_org_id() AND is_org_manager());

-- 4. Indexes
CREATE INDEX new_table_org_idx ON new_table(organization_id);

-- 5. Unique constraints (scoped)
ALTER TABLE new_table ADD CONSTRAINT new_table_name_unique
  UNIQUE (organization_id, name);
```

## Cache Rules

- Cache key format: `{org_id}:{resource}:{identifier}` — never cache without tenant prefix.
- Cache invalidation: scoped to tenant — clearing org A's cache must not affect org B.
- Shared cache (cross-tenant): only for truly global data (feature flags, pricing plans). Explicitly documented as shared.

## Background Jobs

- Job payload MUST include `organization_id`.
- Job handler MUST set tenant context before processing (RLS context, middleware, etc.).
- Job logs MUST include `organization_id` for debugging.
- Failed jobs: retry with same tenant context. Don't fall back to "no tenant" mode.

## File Storage

- File path: `/{organization_id}/uploads/{filename}` — tenant-scoped paths.
- Storage bucket policies: mirror RLS (only current tenant can access their files).
- Signed URLs: include tenant verification (user requesting URL belongs to same org as file owner).

## Testing

```
QUERY: As user in org_A, SELECT * FROM [any_table] WHERE organization_id = 'org_B_id'
  → 0 rows returned (RLS blocks access)

QUERY: INSERT INTO [any_table] (organization_id, ...) VALUES ('org_B_id', ...)
  → As user in org_A: rejected by RLS WITH CHECK policy

QUERY: SELECT COUNT(*) FROM [any_table] (no org filter)
  → Returns count of CURRENT tenant's records only, not all tenants
```
