# Template: metrics.md (code health time series)

> Create at `.claude/phases/metrics.md` during bootstrap — **internal-tool+ profiles only**.
> Append-only time series, one row per `codebase-audit`. Harvested from artifacts that already
> exist — NOT a continuous instrument. Compared against `.claude/rules/quality-budgets.md`.
> (The PROCESS health series lives separately in `framework-metrics.md`, written by
> `framework-audit` — production+ only. Do not conflate the two.)

```markdown
# [Project] — Code Health Metrics

> One row per codebase-audit. Append-only. Compared against quality-budgets.md.

| Session | Date | Largest file (lines) | Type escapes | Fragile tests % | Test coverage (logic) | Open LOW debt | Budgets breached |
|---------|------|----------------------|--------------|-----------------|-----------------------|---------------|------------------|
| 0 | [date] | — | 0 | — | — | 0 | none (baseline) |
```
