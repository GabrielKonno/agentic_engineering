---
domain: distributed-systems
applies_to: event-driven modules, saga orchestrators, message queues, async processors, services making cross-service calls
---

# Distributed Systems Rules

## Inviolable Rules

1. **Every operation spanning more than one service or data store MUST use a compensating transaction or saga** — no unbounded partial states.
2. **All message/event handlers MUST be idempotent** — processing the same message twice produces the same outcome as processing it once.
3. **Every event published to a queue or event bus MUST carry a unique `event_id`** (UUID v4 or equivalent) — used by consumers for deduplication.
4. **Sagas MUST define a compensation action for every forward step** — if step N fails, steps 1…N-1 must be reversible.
5. **Eventual consistency windows MUST be documented per entity** — e.g., "payment confirmed, inventory decremented within 30s".
6. **No synchronous cross-service calls on the critical user-facing path** — use async messaging; synchronous calls permitted only for read-through lookups where stale data is acceptable and latency is bounded.

## Saga Pattern

### Choreography vs Orchestration
| Type | When to use | Trade-offs |
|------|-------------|-----------|
| Choreography | Simple, low-step workflows (≤3 steps) | Decoupled, but hard to trace |
| Orchestration | Complex multi-step with rollback | Visible state, single point of coordination |

### Saga Implementation Rules
- Saga state stored persistently — in-memory saga state is lost on crash.
- Saga step timeout and retry configured per step — default: 3 retries with exponential backoff, 30s step timeout.
- Saga completion (success or failure) emits a terminal event — downstream consumers react to the final state.
- Saga orchestrator is stateless — all state lives in the saga log table, not in orchestrator memory.

### Compensation Rules
- Compensation actions are idempotent — safe to retry on failure.
- Compensation order is reverse of execution order: if steps are A→B→C, compensation is C⁻¹→B⁻¹→A⁻¹.
- Non-reversible actions (e.g., sending email, charging a card) use notification-based compensation (email cancellation, refund) — not undo.
- Compensation failure is a critical alert — requires human intervention, not silent retry.

## Idempotency Patterns

### Idempotency Key Design
```
Key format: {service}:{entity_type}:{entity_id}:{operation}
Example:    "payments:order:ord_123:charge"
```
- Key stored with TTL matching the operation's max expected processing window × 2.
- Key stored in dedicated table or Redis — not inlined into the entity table.
- On duplicate key detection: return the original response, do NOT reprocess.

### Where to Apply
- All message handlers: deduplicate before processing.
- All mutation API endpoints: accept `Idempotency-Key` header (required for payment operations).
- Non-idempotent side effects (emails, push notifications): guard at the side-effect layer independently.

```sql
-- Idempotency key table
CREATE TABLE idempotency_keys (
  key           TEXT PRIMARY KEY,
  response_body JSONB,
  status_code   INT,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  expires_at    TIMESTAMPTZ NOT NULL
);
CREATE INDEX idempotency_keys_expires_idx ON idempotency_keys(expires_at);
```

## Eventual Consistency Rules

- **Read-your-writes** must be satisfied within the same service boundary — not across services.
- **UI displaying eventually consistent data** MUST show a staleness indicator or polling/refresh mechanism.
- **Cross-service aggregates**: maintain a local projection (read model) updated via events — never query peer services synchronously for aggregate data.
- **Compensating reads**: if eventual consistency produces a temporarily incorrect aggregate (e.g., count), provide a reconciliation query that can be triggered on demand.

## Event Sourcing (if applicable)

- Events are immutable once committed — no UPDATE or DELETE on the event store.
- Event schema versioning: events carry a `schema_version` field; consumers handle multiple versions via upcasting.
- Snapshot strategy: take aggregate snapshots every N events (configurable, default 50) to bound replay time.
- Projection rebuild: every projection can be rebuilt from the event store from scratch — no projection data is authoritative.
- Event naming convention: past tense, domain language — `OrderPlaced`, `PaymentFailed`, `InventoryReserved`.

## Message Queue Rules

- Dead-letter queue (DLQ) configured for every queue — messages that fail after max retries land in DLQ, not silently dropped.
- DLQ monitored with alerts — unprocessed DLQ messages are a production incident.
- Message schema validated at consumption — reject and DLQ malformed messages rather than crashing the consumer.
- Message ordering: if order matters, use FIFO queues or partition keys per entity (e.g., `order_id` as partition key).
- Consumer group isolation: separate consumer groups for separate business operations — no shared consumer state.

## Testing

```
QUERY: Trigger a saga failure at step N (block the N+1 step from completing).
  → Check saga_log: status = 'compensating' or 'compensated', all steps recorded.
  → Check target tables: no partial data from steps 1…N remains.
  SUCCESS: system returned to pre-saga consistent state.
  FAILURE: orphaned records, stuck saga in 'running' state, or unexecuted compensation.

QUERY: Publish the same event_id twice to the message handler.
  → SELECT COUNT(*) FROM [entity_table] WHERE source_event_id = '[id]'
  → Expected: 1 row (idempotent — second message was a no-op).
  FAILURE: 2 rows (duplicate processing — idempotency not implemented).

QUERY: Simulate consumer crash mid-processing. Restart consumer.
  → Message should be reprocessed from the queue.
  → Idempotency check prevents duplicate side effects.
  SUCCESS: end state identical to single successful processing.
  FAILURE: duplicate records or compensation triggered incorrectly.

VERIFY: Kill the saga orchestrator mid-saga. Restart it.
  → Saga resumes from last committed step — no duplicate side effects.
  FAILURE: saga stuck in 'running' or duplicate steps executed.
```
