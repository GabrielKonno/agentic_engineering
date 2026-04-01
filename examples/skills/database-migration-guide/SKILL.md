---
name: database-migration-guide
invocation: inline
effort: high
description: >
  Safe database migration patterns — operation risk classification, zero-downtime
  schema changes, batched data migration, rollback procedures, and post-migration
  verification queries. Consult before writing any migration that adds constraints,
  renames columns, changes types, or touches large tables. Stack-agnostic with
  framework-specific rollback examples (Django, Prisma, Supabase).
created: example (framework reference template)
derived_from: null
fixes: []
---

# Database Migration Guide

## Migration File Conventions

- Name: `YYYYMMDDHHMMSS_description.sql` (or framework equivalent)
- One logical change per file (don't mix "add column" with "create table")
- Idempotent where possible (`IF NOT EXISTS`, `IF EXISTS`)
- Include both UP and DOWN migrations

## Safe Operations (no downtime)

| Operation | Safe? | Notes |
|-----------|-------|-------|
| Add table | ✅ | No impact on existing data |
| Add nullable column | ✅ | Existing rows get NULL |
| Add column with DEFAULT | ✅ | PostgreSQL 11+ handles instantly |
| Add index CONCURRENTLY | ✅ | Does not lock table (PostgreSQL) |
| Drop unused index | ✅ | Verify no queries depend on it |
| Add CHECK constraint (NOT VALID) | ✅ | Validates new rows only |

## Dangerous Operations (require planning)

| Operation | Risk | Safe approach |
|-----------|------|---------------|
| Add NOT NULL column without default | Breaks existing rows | Add nullable → backfill → add NOT NULL |
| Drop column | Application may reference it | Remove code references first → deploy → drop column |
| Rename column | Breaks existing queries | Add new column → copy data → update code → drop old |
| Change column type | Data conversion may fail | Add new column → convert → swap → drop old |
| Drop table | Data loss | Verify no references, backup, then drop |
| Add unique constraint | Existing duplicates block it | Clean duplicates first, then add constraint |
| Add foreign key | Orphaned rows block it | Clean orphans first, add with NOT VALID, then validate |

## Data Migration Pattern

```sql
-- Step 1: Add new column (nullable)
ALTER TABLE orders ADD COLUMN status_v2 TEXT;

-- Step 2: Backfill in batches (not all at once)
UPDATE orders SET status_v2 = CASE
  WHEN status = 0 THEN 'draft'
  WHEN status = 1 THEN 'confirmed'
  WHEN status = 2 THEN 'shipped'
  ELSE 'unknown'
END
WHERE status_v2 IS NULL
LIMIT 1000; -- Repeat until all rows migrated

-- Step 3: Verify data
SELECT status, status_v2, COUNT(*) FROM orders GROUP BY status, status_v2;
-- All combinations should be expected mappings

-- Step 4: Make NOT NULL (after all rows backfilled)
ALTER TABLE orders ALTER COLUMN status_v2 SET NOT NULL;

-- Step 5: Drop old column (after code no longer references it)
ALTER TABLE orders DROP COLUMN status;

-- Step 6: Rename (optional)
ALTER TABLE orders RENAME COLUMN status_v2 TO status;
```

## Rollback Procedures

### Before migration
```bash
# Create checkpoint
pg_dump -Fc mydb > backup_before_migration_YYYYMMDD.dump
# Or for specific tables
pg_dump -Fc -t orders mydb > backup_orders_YYYYMMDD.dump
```

### After failed migration
```bash
# Option 1: Run DOWN migration
python manage.py migrate app_name 0042  # Django
npx prisma migrate rollback             # Prisma
supabase migration repair --status reverted YYYYMMDDHHMMSS  # Supabase

# Option 2: Restore from backup (nuclear option)
pg_restore -d mydb backup_before_migration.dump
```

## Verification Queries

```sql
-- Verify column exists and has correct type
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'target_table' AND column_name = 'new_column';

-- Verify no NULL values in NOT NULL column
SELECT COUNT(*) FROM target_table WHERE new_column IS NULL;

-- Verify constraint exists
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'target_table';

-- Verify index exists
SELECT indexname, indexdef FROM pg_indexes
WHERE tablename = 'target_table' AND indexname = 'expected_index';
```

## STRONG Criteria Examples

```
REVIEW: Migration adds NOT NULL column to existing table.
  → Verify: migration is multi-step (add nullable → backfill → set NOT NULL)
  → Verify: backfill uses batched UPDATE (LIMIT/batch size), not single UPDATE on all rows
  SUCCESS: safe multi-step approach. FAILURE: single ALTER TABLE ADD COLUMN ... NOT NULL

REVIEW: Migration renames or drops column.
  → Verify: code references to old column name already removed in a prior deploy
  → Verify: DOWN migration can restore the column (or explicit "irreversible" acknowledgement)
  SUCCESS: deploy-order safe. FAILURE: column dropped while code still references it

REVIEW: Migration adds index to large table.
  → Verify: uses CONCURRENTLY option (PostgreSQL) or equivalent non-locking strategy
  → Verify: estimated table size considered (comment or documentation)
  SUCCESS: non-blocking index creation. FAILURE: standard CREATE INDEX on >100k row table
```
