---
name: data-integrity-checker
effort: high
description: >
  Verifies data integrity across related tables and operations.
  Use when implementing features that create, update, or delete data
  across multiple tables (cascades, transactions, denormalized data).
created: example (framework reference template)
last_eval: none (reference template — eval at project creation)
fixes: []
derived_from: null
---

# Data Integrity Checker

## When to invoke

- After implementing multi-table operations (order creates items, payments, stock movements)
- After implementing delete operations (cascade effects, orphaned records)
- After implementing data migration or bulk operations
- When a bug report suggests data inconsistency (totals don't match, missing records)

## Checklist

### Referential Integrity
- [ ] Foreign keys exist — all relationships enforced at database level, not just application
- [ ] ON DELETE behavior defined — CASCADE, SET NULL, or RESTRICT chosen intentionally per relationship
- [ ] No orphaned records possible — child records can't exist without parent
- [ ] Self-referencing handled — recursive relationships (categories, comments) have depth limits or cycle prevention

### Transactional Consistency
- [ ] Multi-table writes are atomic — all succeed or all fail (database transaction or equivalent)
- [ ] Partial failure handled — if step 3 of 5 fails, steps 1-2 are rolled back
- [ ] Concurrent modifications safe — optimistic locking or serializable isolation where needed
- [ ] Idempotent operations — retrying a failed operation doesn't create duplicates

### Denormalized Data
- [ ] Computed values stay consistent — if order_total is stored, it updates when items change
- [ ] Counters are accurate — if user has `post_count`, it matches actual post count
- [ ] Cache invalidation exists — denormalized data refreshes when source changes
- [ ] Reconciliation possible — a query can verify denormalized values match computed values

### Soft Deletes (if applicable)
- [ ] Queries filter deleted records — `WHERE deleted_at IS NULL` everywhere
- [ ] Unique constraints account for soft deletes — email unique only among non-deleted
- [ ] Related records handled — soft-deleting parent doesn't orphan children
- [ ] Hard delete exists for compliance — GDPR/LGPD right to erasure path

### Audit Trail
- [ ] Created/updated timestamps exist — `created_at`, `updated_at` on all business tables
- [ ] Sensitive operations logged — who changed what, when (especially financial, permissions)
- [ ] Audit records are immutable — no UPDATE or DELETE on audit log table

## Verification Queries

```sql
-- Orphaned records (child without parent)
SELECT c.id FROM child_table c
LEFT JOIN parent_table p ON c.parent_id = p.id
WHERE p.id IS NULL;

-- Denormalized total mismatch
SELECT o.id, o.total, SUM(i.price * i.quantity) as computed
FROM orders o
JOIN order_items i ON i.order_id = o.id
GROUP BY o.id
HAVING o.total != SUM(i.price * i.quantity);

-- Counter drift
SELECT u.id, u.post_count, COUNT(p.id) as actual
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
GROUP BY u.id
HAVING u.post_count != COUNT(p.id);
```

## Output Format

```
## Data Integrity Check: [module/operation]

### Tables involved: [list]
### Issues found: [N]
| # | Type | Issue | Affected records | Fix |
|---|------|-------|-----------------|-----|
| 1 | Orphaned data | order_items without order | 3 records | Add FK constraint + clean orphans |

### Verification queries run: [N passed / N failed]
### Recommendation: APPROVE / FIX + MIGRATE
```
