---
name: performance-auditor
invocation: subagent
effort: medium
description: >
  Reviews code for performance issues. Invoked after implementing features
  that involve data fetching, rendering, or heavy computation.
  Adapts checks to the project's stack.
created: example (framework reference template)
last_eval: none (reference template — eval at project creation)
fixes: []
derived_from: null
---

# Performance Auditor

## When to invoke

After implementing or modifying:
- Data fetching (API calls, database queries, external services)
- List rendering (tables, grids, infinite scroll, virtualization)
- File processing (uploads, parsing, transformations)
- Real-time features (WebSockets, SSE, polling)
- Search or filtering with large datasets

## Baselines

Default thresholds — customize at project creation. Replace `_tbd_` with measured values
from the first staging deploy or load test. Update this file or reference CLAUDE.md.

| Metric | Default | Project baseline | Note |
|--------|---------|------------------|------|
| API response p50 | < 200ms | _tbd_ | Server-side, excludes network |
| API response p95 | < 800ms | _tbd_ | Flag if p95 > 3× p50 (high variance) |
| Database query p95 | < 100ms | _tbd_ | Single query; joins counted as one |
| Page load LCP (3G) | < 3s | _tbd_ | Lighthouse / WebPageTest |
| Initial JS bundle (gzip) | < 150KB | _tbd_ | Excludes lazy-loaded chunks |
| Background job duration | < 30s | _tbd_ | Per job; flag if near queue timeout |

**During audit:** compare against project baseline if available. If baseline is still `_tbd_`:
note "baseline not yet established" in the Metrics section — do not block on absent baseline.
Exceeds threshold by > 2×: HIGH. Between 1×–2×: MEDIUM.

## Checklist

### Data Fetching
- [ ] No N+1 queries — verify loops don't trigger individual queries per item
- [ ] Parallel fetching — independent data sources use `Promise.all()` or equivalent, not sequential `await`
- [ ] Pagination enforced — list endpoints return bounded results, never unbounded `SELECT *`
- [ ] Caching strategy — frequently accessed, rarely changed data has appropriate caching (in-memory, Redis, HTTP cache headers)
- [ ] No duplicate fetches — same data is not fetched multiple times in the same request/render cycle

### Rendering (Web)
- [ ] Heavy components lazy-loaded — components >50KB or rarely visible use dynamic imports
- [ ] Lists virtualized — lists >50 items use virtual scrolling (react-window, tanstack-virtual, etc.)
- [ ] Images optimized — responsive sizes, lazy loading, modern formats (WebP/AVIF)
- [ ] No layout thrashing — DOM reads and writes are batched, not interleaved
- [ ] Animations use GPU — `transform` and `opacity` instead of `top`/`left`/`width`/`height`

### Rendering (Mobile)
- [ ] FlatList for long lists — not ScrollView with mapped items
- [ ] Memoized list items — `React.memo` or equivalent prevents re-render of unchanged items
- [ ] No inline styles in loops — styles defined outside render function
- [ ] Heavy computation off main thread — use workers or background tasks

### Database
- [ ] Indexes exist — columns used in WHERE, JOIN, ORDER BY have appropriate indexes
- [ ] Query explains acceptable — no full table scans on tables >10K rows
- [ ] Connection pooling — not opening new connections per request
- [ ] Bulk operations — batch inserts/updates instead of individual statements in loops

### Bundle / Payload
- [ ] No barrel imports — import from specific files, not index re-exports
- [ ] Tree-shakeable — unused code is eliminated (ESM imports, no side-effect imports)
- [ ] API responses minimal — only necessary fields returned, not entire database rows
- [ ] Compression enabled — gzip/brotli on responses >1KB

## Output Format

```
## Performance Audit: [feature/module]

### Issues found: [N]
| # | Severity | Category | Issue | Location | Fix |
|---|----------|----------|-------|----------|-----|
| 1 | HIGH/MEDIUM/LOW | [Data/Render/DB/Bundle] | [what] | [file:line] | [how to fix] |

### Metrics (if measurable):
- Bundle impact: [+/- KB]
- Query count: [N queries for this operation]
- Estimated load time impact: [faster/slower/neutral]

### Recommendation: APPROVE / FIX REQUIRED
```
