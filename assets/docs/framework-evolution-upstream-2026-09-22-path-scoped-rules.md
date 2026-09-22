# Framework evolution upstream — path-scoped rules (2026-09-22, v2.32.0)

**Source doc (projeto-fonte, a production project):**
`framework-evolution-2026-09-21-path-scoped-rules.md` — its Part C is the upstream list; Part D is the
project's own pending adaptation and is NOT absorbed here (it is executed by a later
`/existing_project_adaptation` session, in the order the doc requires: this upstream first).

**Disposition of record:** this file plus the v2.32.0 commit that adds it.

## The lesson

Scope declared ≠ scope applied. Every rule template declared its scope in `applies_to:`, a key the
harness ignores; only `paths:` makes a rule load lazily (when a matching file is READ). So every rule
loaded in every session AND every subagent. Measured in the projeto-fonte: ~52% of a 1M window taken
by rules before any work, and a 200k-window subagent could not start. After `paths:`: ~5% always
loaded, and a subagent started at ~63k tokens (a control/test agent pair, the token counter as judge —
not a self-report). `component-design` §7 already listed `paths:` as the native mechanism; no template
followed it. The "route ALL rules to every subagent — cost is low" advice in the concepts doc was the
other half: harmless while everything was loaded anyway, and it would cancel the gain exactly in the
subagents once scoping exists.

## Per evolution (Part C items)

| # | Evolution | Verdict | Where it landed |
|---|-----------|---------|-----------------|
| C1 | `applies_to:` → `paths:` in the rule templates | **graduated** | 5 `docs/modules/rules/*.md` (session-rules and evolution-policy stay unscoped by design; component-design gets its already-declared globs; ops-rules gets the audit skill's path + "add infra globs"; quality-budgets gets a `src/**` placeholder to replace) · 11 `examples/rules/*.md` (prose kept as a `# Scope:` comment, globs marked ILLUSTRATIVE) · this repo's own `.claude/rules/component-design.md` |
| C2 | Replace "read all `.claude/rules/*.md`" with path routing | **graduated** | 4 agent templates, 10 agent examples, `validation-orchestrator` context routing, `autonomous-loop` implementer input, concepts doc (routing block + failure-table row, SUBSTITUTE with the superseded remedy kept in the row) |
| C3a | The scope guard | **adapted** | NEW `docs/modules/templates/check_rules_paths.md` → `scripts/check-rules-paths.mjs`, all tiers; invoked by `rules-agents-updater` whenever it creates or rescopes a rule (every tier) and by the CI `guards` stage (bootstrap Step 14.2, `internal-tool`+); adaptation Step 2.9 copy + helper + report slot. Adapted: `picomatch` replaced by git's `:(glob)` pathspec (dependency-free, Node-version-free); **a dead glob is REPORTED, never failed** — the source failed on it, but in a framework project a glob over a module the PRD declares and nobody has built yet is normal, and failing it turns a build order into a red CI (a pre-code exception was drafted and cut in this batch by the pre-commit verifier); `ALWAYS_LOADED` ships with the two framework rules instead of empty. NOT upstreamed: the informational "cited-but-uncovered files" report (it matched stack-specific source extensions) and the `--for` mode (its only consumer is the hook below). |
| C3b / C7 | The write-time rules gate hook (+ shell-write tokenizer, worktree-delta net, behavioural test, 4 settings entries, review-receipt item 0) | **kept project-local — documented, not shipped** (owner decision, this session) | This section. Reasons: ~2.2k lines of Node; six independent review rounds, the last diff never reviewed and merged WITHOUT an APPROVE by the projeto-fonte owner's own decision; the review series showed the text-parser half cannot close a behaviour-defined class; the test fixture is project-specific. The harness already guarantees the common path (Edit refuses a file not Read, and the Read injects the rule). **What it would close, stated so a later session can re-decide:** L1 (writes via shell skip the Read), L2 (a NEW file written without reading a domain neighbour), L3 (a reviewer that never Read the diff's files — verifiable only from a hook's per-agent load log), L5 (compaction drops the rule). **What re-opens it:** evidence from a second project of a defect whose rule existed but was not loaded, or the projeto-fonte's gate reaching an APPROVE and a quiet backlog. |
| C4 | New rules are born with `paths:`; orchestrator warning for planning without code | **graduated** | `rules-agents-updater` (born scoped + extend globs when a section cites an uncovered file — the source doc's L6); `claude_md` template Session Protocol line (L4) |
| C5 | Make `component-design` §7 imperative | **graduated** | Both copies: `ALWAYS scope with paths:` / `NEVER instruct an agent to read all rules`, with the evidence block |
| C6 | Isolation | honoured | Nothing naming the projeto-fonte's files, domains, commits or hook file names travels; counts only |

## Reconciliation with the autonomous modes (the source doc predates them in the projeto-fonte)

The source doc was written against a project copy that had not yet received the Level 5
continuous mode. Checked against the current `autonomous-loop`:
- **Implementer input** already said "the relevant rules files"; it now says to pass their NAMES and
  never paste them — the implementer's Read loads them.
- **Autocompact discipline** ("re-anchor from the DISK") gains one bullet: re-Read the in-flight
  task's target files before its next edit, because path-scoped rules are attachments to earlier
  Reads and a compact can drop them — the source doc's L5, closed by prose instead of the hook.
- **Continuous mode admits DISCOVERED tasks without the owner**, which is exactly the source doc's L4
  moment (planning before any code is opened). The `claude_md` line names "admitting a task" for
  that reason — it is the orchestrator's text, and the orchestrator owns that moment (component-design §9).
- **Mechanism 4** (`model:` descending to a small-window agent, v2.29.0) was unusable in the
  projeto-fonte because a 200k agent could not start; it becomes viable once rules are scoped. No
  edit needed — recorded as a consequence.
- No conflict with the continuous-mode contention rules, the marker, or `/loop` re-entry.

## Efficacy anchors and their measurers

| Anchor | Measurer | Status |
|--------|----------|--------|
| The always-loaded share stays near the ~5% measured at the source | `scripts/check-rules-paths.mjs` prints `always loaded: X of Y chars (P%)` in every CI `guards` run, at every tier | named |
| No new `ALWAYS_LOADED` entry without a reason | the same guard lists every `ALWAYS` line with its reason | named |
| A subagent's starting context stays in the tens of thousands of tokens | nothing installed reads `/context` | unmeasured — no measurer at any tier |
| No defect whose rule existed but was not loaded (shell writes, new files) | nothing counts it; the hook that would is project-local | unmeasured — no measurer at any tier |

## Dischargeable

The source doc is now **dischargeable**: the projeto-fonte's own next session marks its header
`upstreamed`, citing this file. Its Part D (adaptation to v2.32.0) may run from now on — the order it
requires is satisfied. The adaptation MUST preserve the project's existing `paths:` blocks and its
guard (it will read `DIFFERS from framework` on `check-rules-paths.mjs`; keep the project's copy,
which carries its own matcher and the hook's `--for` mode).
