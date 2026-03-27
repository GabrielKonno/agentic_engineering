---
name: migration-runner
effort: high
description: >
  Guides safe database migration execution. Verifies migration files,
  checks for destructive operations, validates rollback paths, and
  confirms data integrity post-migration.
---

# Migration Runner

## When to invoke

- Before executing any database migration
- When creating migration files that alter existing tables (add/drop columns, change types)
- When migrating data between schemas or formats
- When merging migrations from multiple branches

## Pre-Migration Checklist

### Migration File Quality
- [ ] Named with timestamp prefix — `YYYYMMDDHHMMSS_description.sql` or framework equivalent
- [ ] Single responsibility — one logical change per migration file
- [ ] Idempotent where possible — can be re-run without errors (use `IF NOT EXISTS`, `IF EXISTS`)
- [ ] No data loss — DROP COLUMN only after confirming data is migrated or backed up
- [ ] Default values set — new NOT NULL columns have DEFAULT or are populated in same migration

### Destructive Operation Safety
- [ ] DROP TABLE preceded by backup or confirmation that data is no longer needed
- [ ] DROP COLUMN confirmed unused — grep codebase for column references before dropping
- [ ] ALTER TYPE with data conversion — existing data is compatible or explicitly converted
- [ ] RENAME with dependent updates — views, functions, indexes referencing old name updated
- [ ] Truncate/delete operations guarded — WHERE clause is specific, not unbounded

### Rollback Path
- [ ] Rollback migration exists — every `up` has a corresponding `down`
- [ ] Rollback is tested — actually run it in development, don't just write it
- [ ] Data rollback considered — if migration transforms data, can it be reversed?
- [ ] Point of no return documented — if migration is irreversible, it's clearly stated

### Dependencies
- [ ] Order verified — migrations depend on earlier migrations being complete
- [ ] No conflicts with parallel branches — check for migrations with overlapping timestamps
- [ ] Application code compatible — the code deployed with this migration handles both old and new schema

## Post-Migration Verification

```sql
-- Verify migration applied
SELECT * FROM schema_migrations ORDER BY version DESC LIMIT 5;

-- Verify new columns exist
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = '[table]' AND column_name = '[new_column]';

-- Verify data integrity
SELECT COUNT(*) FROM [table] WHERE [new_column] IS NULL AND [old_column] IS NOT NULL;
-- Expected: 0 (data migrated correctly)

-- Verify indexes
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = '[table]';

-- Verify constraints
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = '[table]';
```

## Output Format

```
## Migration Report: [migration_name]

### Changes:
- [Table X: added column Y (type, nullable, default)]
- [Table Z: dropped column W (data backed up: yes/no)]

### Pre-flight checks: [N/N passed]
### Post-migration verification: [N/N passed]
### Rollback tested: [yes/no]

### Recommendation: SAFE TO APPLY / NEEDS REVIEW / BLOCKED
```
