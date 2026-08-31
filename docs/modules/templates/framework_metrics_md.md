# Template: framework-metrics.md (process health time series)

> Create at `.claude/phases/framework-metrics.md` during bootstrap — **production+ profiles only**
> (the tier that installs `framework-audit`). Append-only, one row per `framework-audit`.
> Harvested from artifacts that already exist — NOT a continuous instrument.
>
> This is the PROCESS series, the sibling of `metrics.md` (the CODE series written by
> `codebase-audit`). Do not conflate them: one asks "is the code healthy?", the other asks
> "is my process catching what it should?".
>
> The `Status` column is the CADENCE ANCHOR (session-rules → "Cadence integrity"): the cadence
> reader counts from the last `COMPLETE` row and SKIPS partial ones. The six audit questions are
> the expensive half and die first under an interrupt; this rollup is the cheap half that
> survives — so `Status` is derived from WHICH QUESTIONS RAN, never from the rollup succeeding.

````markdown
# [Project] — Process Health Metrics

> One row per framework-audit. Append-only. The detail behind each row lives in the session's
> Framework Audit Report and in `.claude/docs/framework-evolution-*.md`.
>
> `Status` = `COMPLETE` or `INCOMPLETE (questions N,M not answered — reason)`. An INCOMPLETE row
> records valid data but does NOT satisfy `FRAMEWORK_AUDIT_CADENCE`.

| Session | Date | Status | Escape rate | Reviewer false-positives | Dead KBPs (never triggered) | Mechanisms never fired | Drift incidents | Oldest open debt | Evolutions pending upstream |
|---------|------|--------|-------------|--------------------------|-----------------------------|------------------------|-----------------|------------------|-----------------------------|
| 0 | [date] | COMPLETE | — | 0 | 0 | — | 0 | — | 0 (baseline) |

**Column sources (all harvested, none measured live):**

| Column | Source that already exists | Healthy direction |
|--------|---------------------------|-------------------|
| Escape rate | Post-Mortem Ledger rows ÷ tasks shipped this window | low and falling |
| Reviewer false-positives | KBP `false-positive:` counters | low (high = cry-wolf) |
| Dead KBPs | KBP `triggered:` counters — patterns never fired | none dead 20+ sessions |
| Mechanisms never fired | validation reports / Progress Log — routes, specialists, gates | none never-spawned |
| Drift incidents | prd-sync-checker reports | falling |
| Oldest open debt | `[added sN]` stamps under Future Improvements | not growing unbounded |
| Evolutions pending upstream | `.claude/docs/framework-evolution-*.md` not yet marked `upstreamed` | trending to 0 |
````
