---
name: skill-gate
invocation: inline
effort: medium
description: >
  Closed-loop gate for CREATING new skills and rules: draft in .claude/drafts/ →
  blind review by the skill-reviewer subagent → autonomous correction → conditional
  promotion. MUST be followed whenever a NEW skill or rules file is created and this
  skill is installed (tier-gated: internal-tool+). NOT for in-place updates to
  existing components (those follow evolution-policy). Without this, the session
  that wrote a component also approves it — correlated errors pass, and unverified
  empirical claims enter the library as fact.
created: framework-v2.4.0 (pre-validated)
derived_from: skill-gate-spec v1.1 (.claude/docs/skill-gate-spec.md in the framework repo)
---

# Skill Gate — creation, blind review, promotion

New components must survive review by an agent that never saw the session that
produced them — the same condition they face when reused months later. This skill
owns the full lifecycle for NEW skills and rules. In-place updates to existing
components are out of scope (see `.claude/rules/evolution-policy.md`).

## Scope check (run first)

- Creating a NEW skill or rules file → this skill applies.
- Updating an EXISTING component → STOP, follow evolution-policy instead. If the
  update ADDS an empirical claim, ALWAYS mark that claim `verified: false` inline.

## 1. Draft

NEVER write a new component directly into `.claude/skills/` or `.claude/rules/`.

- New skill → `.claude/drafts/skills/[name]/SKILL.md` (folder mirrors official layout)
- New rules file → `.claude/drafts/rules/[name].md`

Iterate freely — the gate stays silent while you draft. When the draft is complete,
ALWAYS add this line to its frontmatter as the FINAL edit:

```
status: ready-for-review
```

The PostToolUse hook detects the marker and blocks further work until the review
runs. If hooks are unavailable (no bash), the marker still applies — proceed to
Step 2 manually; the process is identical, only unenforced.

## 2. Spawn the blind reviewer

When the marker is set (hook fired or manual), ALWAYS spawn the `skill-reviewer`
subagent with EXACTLY this input:

- **Draft:** path to the draft file
- **Rubric:** `.claude/skills/skill-gate/rubric.md`
- **Component index:** name + `description:` frontmatter of every file in
  `.claude/skills/*/SKILL.md`, `.claude/rules/*.md`, `.claude/agents/*.md`
  (names and descriptions ONLY — never full bodies)
- **Review cycle number:** 1 on first review, incremented on each re-review

NEVER include: session history, sprint context, what you were trying to do, or any
explanation of the draft. If the draft needs explaining, it fails the gate by design.

**Sensitive routing:** if the draft touches credentials/secrets, deploy/infra,
client data, external messaging/automation, financial operations, or permissions —
or declares `category: sensitive` — spawn `red-team` INSTEAD of skill-reviewer,
with the same input plus its own security lens. Fallback if no red-team exists:
`security-reviewer`. If neither exists: register a human pendency in
`pendencias.md` and do NOT promote.

## 3. Act on the verdict

The reviewer archives its JSON verdict in `.claude/skill-gate/review_reports/`.

| Verdict | Action |
|---|---|
| `approved: false` | Fix the draft using `problems[]`. Re-set the marker → new cycle. **Max 3 cycles** — on the 3rd failure, STOP: remove the marker, register a pendency in `pendencias.md` ("draft [name] failed 3 review cycles: [summary]"), leave the draft in place. |
| `overlaps[]` contains `"degree": "duplicate"` | Do NOT promote. Register a consolidation proposal as a pendency — consolidation of existing components is always a human decision. |
| `approved: true` + `empirical_claims` non-empty | Apply flags (Step 4), then promote (Step 5). |
| `approved: true` + `empirical_claims` empty | Promote (Step 5). |

## 4. Flag empirical claims (before promoting)

If the verdict's `empirical_claims[]` is non-empty, ALWAYS edit the draft frontmatter with:

```
verified: false
unverified_claims:
  - claim: "[excerpt]"
    verify_by: "[how_to_verify from the verdict]"
```

The promotion script REFUSES drafts with empirical claims and no `verified: false`.
Removing the flag later is exclusively a human or real-data decision — never yours
(see evolution-policy).

## 5. Promote

```bash
bash .claude/skills/skill-gate/scripts/promote_skill.sh .claude/drafts/skills/[name]/SKILL.md
```

The script refuses without a fresh (<60 min) approving verdict for that exact path —
promoting by hand-moving files bypasses the gate and is forbidden. It strips the
marker, moves the draft to the official directory, and appends to
`.claude/skill-gate/promotion.log`.

**Observation mode:** while `rubric.md` frontmatter contains `mode: observation`
(the default for a new project's first 2 weeks / 5 promotions), promotion requires
explicit owner confirmation. When asking, ALWAYS present:
- **Component:** name and one-line purpose
- **Verdict summary:** the reviewer's `summary` field
- **Cycles used:** N/3, with each earlier reproval's problem types
- **Empirical claims:** count + excerpts (these will carry `verified: false`)

Then re-run the script with `--confirmed`. Exiting observation mode (deleting the
line) is the owner's decision.

**In sprint-approved mode, NEVER pause the sprint to ask for promotion
confirmation** — the exception-stops list in sprint-proposer is closed and the
gate is not on it. Defer instead: leave the draft in place (the approving verdict
stays archived), register a pendency ("draft [name] approved — awaiting owner
confirmation to promote"), report it in the sprint report, and continue with the
next task. When the owner later confirms: if the verdict is older than 60 minutes
the promotion script will refuse it — re-run the skill-reviewer (one quick cycle
on an already-approved draft) and promote with the fresh verdict.

**Observation-mode session report:** while in observation mode, at the end of ANY
session where the gate ran, ALWAYS report to the owner:
- **Gate activity:** drafts reviewed, cycles per draft, reprovals by problem type
- **Calibration signal:** any reproval you judged to be a false positive (rubric
  too strict), stated plainly — this is the data the owner needs to decide when
  to exit observation mode; reports rotting unread in `review_reports/` defeat
  the mode's purpose.

**Proposing the exit:** when `promotion.log` shows 5+ promotions AND ~2 weeks
have passed since the gate was installed AND recent sessions raised no
false-positive calibration signals, ALWAYS propose exiting observation mode in
the same report, citing those numbers. NEVER remove the `mode: observation`
line yourself — per evolution-policy this is a BEHAVIOR change: the owner
deletes it (or tells you to). Until then, keep proposing at most once per
session — never silently give up on the proposal.

**After promotion** — for `invocation: subagent` agents only: run the standard
creation eval (2 test scenarios) per rules-agents-updater Step 4. The gate replaces
self-approval, not the behavioral eval.

## Consuming components with `verified: false`

When a loaded skill carries `verified: false`, ALWAYS treat each listed claim as a
hypothesis, not fact — and flag it to the user whenever a decision depends on it.

## Orphaned drafts

`session-end` sweeps `.claude/drafts/` — drafts without the marker or with
unresolved review cycles become pendencies, so nothing rots silently in drafts/.
