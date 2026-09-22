# Template: Quality Budgets

> Create at `.claude/rules/quality-budgets.md` during bootstrap — **production+ profiles only**.
> Lives in `rules/` and is scoped with `paths:` over the project's source roots, so the code-reviewer
> loads it by READING the code under review — the delta gate needs zero extra context routing.
> Caps are DEFAULTS — tune per project. The point is a tripwire on slow erosion ("boiled frog"),
> not a hard blocker: the code-reviewer delta gate FLAGS a budget regression, it does not block.

````markdown
---
domain: quality-budgets
# REPLACE `src/**` with this project's real source roots at bootstrap — the reviewer loads this
# file by READING the code under review, so the globs must cover every source file.
paths:
  - "src/**"
---

# Quality Budgets

Caps that catch slow erosion no single diff is "guilty" of. The code-reviewer's **delta gate**
flags (does NOT block) any diff that pushes a metric in the wrong direction past its cap; the
periodic `codebase-audit` records the absolute values in `metrics.md`.

| Budget | Cap (default — tune) | Measured by |
|--------|----------------------|-------------|
| Max file size | ~300 lines (handlers/services ~30 fns) | line / function count |
| Type escapes (`as any`, `@ts-ignore`, equivalents) | does not increase | grep count |
| Fragile tests (snapshot-only / no value assertion) | < 20% of test files | review sampling |
| Largest module fan-in (cross-module imports) | does not increase | import graph |
| Client bundle size (if applicable) | budget per route | build stats |
| TODO/FIXME density | does not increase | grep count |

**Delta gate rule (code-reviewer):** when a diff worsens any budget above, add ONE finding:
`Budget delta: [metric] [old]→[new] (cap [cap]) — justified? ` — severity LOW unless it crosses
the cap, then MEDIUM. It is a flag for the author to justify or split, never an automatic block.
````
