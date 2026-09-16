# Template: metrics.md (code health time series)

> Create at `.claude/phases/metrics.md` during bootstrap — **internal-tool+ profiles only**.
> Append-only time series, one row per `codebase-audit`. Harvested from artifacts that already
> exist — NOT a continuous instrument. Compared against `.claude/rules/quality-budgets.md`.
> The `Status` column is the CADENCE ANCHOR (session-rules → "Cadence integrity"): the
> cadence reader counts from the last `COMPLETE` row and SKIPS partial ones.
> (The PROCESS health series lives separately in `framework-metrics.md`, written by
> `framework-audit` — production+ only. Do not conflate the two.)

````markdown
# [Project] — Code Health Metrics

> One row per codebase-audit. Append-only. Compared against quality-budgets.md.
> `Status` = `IN PROGRESS` (written before the fan-out, replaced when the run ends), `COMPLETE` or
> `INCOMPLETE (steps N,M not run — reason)`, followed by the per-step
> line (`steps: 1 ✅ · 2 ✅ · … · 6 ⏭️ (structural reason)`). An INCOMPLETE row records valid data
> but does NOT satisfy the audit cadence — the reader anchors on the last COMPLETE.

| Session | Date | Status | Largest file (lines) | Type escapes | Fragile tests % | Test coverage (logic) | Open LOW debt | Budgets breached |
|---------|------|--------|----------------------|--------------|-----------------|-----------------------|---------------|------------------|
| 0 | [date] | COMPLETE | — | 0 | — | — | 0 | none (baseline) |
````
