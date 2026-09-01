# Pre-built Process Skills

Framework workflow skills — copied to projects during bootstrap Step 5.7.

> **Note:** 3 process components that produce decisions or analyses are proper agents:
> `prd-sync-checker`, `criteria-enforcer`, `diff-pattern-extractor`.
> They live in `docs/modules/agents/` and are copied to `.claude/agents/` during bootstrap.
> This directory contains 15 skills: 12 **inline** (6 implementation + 3 session lifecycle + 1 whole-segment orchestration + 1 PRD process + 1 commit workflow) + 3 **tier-gated** skills (codebase-audit, framework-audit — audits; skill-gate — creation gate) copied only when the project's risk profile warrants them.

## Generality contract (inviolable)

Every skill in this directory is copied VERBATIM to projects of ANY type — SaaS, data
pipeline, CLI, static site. Therefore:

- **Process skills MUST be project-type-agnostic.** They speak in workflow concepts
  (tasks, criteria, diffs, commits, phases, persistence discipline) and framework files
  (`pendencias`, `project.md`) — never in the vocabulary of one project archetype.
- **Surface-specific behavior is CONDITIONALLY GATED**, never assumed: "if UI files
  modified", "if migration files in diff", "if `.claude/rules/X.md` exists". A project
  without that surface pays zero cost.
- **Examples must span archetypes or be archetype-neutral.** Examples are how the AI
  calibrates a check — a rubric whose examples all come from one business type biases
  the judgment on every other type.
- **Project specificity enters at BOOTSTRAP**, through the components built per-project:
  stack/domain skills (Step 12), domain rules (Step 13), adapted agents (Steps 7-11) —
  never by editing these process skills' logic.

## What these are

These skills implement steps of the Session Protocol, Execution Protocol, PRD workflows, commit hygiene, and the periodic MACRO/meta audits. The main agent reads the SKILL.md and follows the steps in its own context. In v2.1.0, protocol logic moved from CLAUDE.md into skills — CLAUDE.md retains only pointers. Skills are:

1. **Copied** to each project's `.claude/skills/` at bootstrap
2. **Triggered** by convention (sprint-proposer/session-end are user-invoked; others are called by orchestrating skills)
3. **Evolvable** via the standard evolution mechanisms (FIX/DERIVED/CAPTURED — see `.claude/rules/evolution-policy.md`)

## Skills list

| # | Skill | Type | When triggered |
|---|-------|------|---------------|
| 1 | sprint-proposer | Process + judgment | Start of session (user-triggered) — owns SESSION ENTRY for every mode, proposes sprint, manages sprint-approved mode, hands off to autonomous-loop |
| 2 | autonomous-loop | Process + judgment | Whole-segment execution (user-triggered, opt-in Level 5) — main agent orchestrates, one implementer subagent per medium task; entered after sprint-proposer or by LOOP CONTINUATION handoff |
| 3 | session-end | Process + judgment | End of session (user-triggered) |
| 4 | context-recovery | Process pure | Mid-session emergency (user-triggered) |
| 5 | validation-orchestrator | Process + judgment | Before + during implementation |
| 6 | project-md-updater | Process + judgment | End of session (called by session-end, item 2) |
| 7 | pendencias-updater | Process + judgment | End of session (called by session-end, item 3) |
| 8 | config-file-updater | Process + judgment | End of session (called by session-end, item 4) |
| 9 | rules-agents-updater | Process + judgment | End of session (called by session-end, item 5) |
| 10 | session-log-creator | Process pure | End of session (called by session-end, with item 2) |
| 11 | cross-cutting-analysis | Process + judgment | During PRD planning (Phase 4) and PRD change (Phase 3) — identifies and maintains transversal themes |
| 12 | commit | Process pure | Before any non-trivial commit (user-triggered) — staging verification, intent matching, conventional messages |
| 13 | codebase-audit | Process + judgment (tier-gated: internal-tool+) | Periodic MACRO health audit (user-triggered; proposed by sprint-proposer at AUDIT_CADENCE / phase boundary) |
| 14 | framework-audit | Process + judgment (tier-gated: production+) | Periodic meta-audit of the project's own process (user-triggered; proposed at FRAMEWORK_AUDIT_CADENCE / phase boundary) |
| 15 | skill-gate | Process + judgment (tier-gated: internal-tool+) | When a NEW skill or rules file is created — draft in `.claude/drafts/`, blind review by skill-reviewer, conditional promotion (enforced by PostToolUse hook) |

## Skill Creator usage

**Framework level:** Skills were developed using the Skill Creator plugin for eval. Process-pure skills verified by dry-run walkthrough. Process+judgment skills verified with 2 test scenarios.

**Project level:** The Skill Creator is used for on-demand skill creation and eval during development sessions.

## Scripts

Skills with `scripts/` subdirectories contain bash helper scripts for deterministic operations. These scripts require bash (already a Claude Code requirement). The SKILL.md contains the full process — scripts are optional automation, not dependencies.

## Bootstrap copy command

```bash
cp -r docs/modules/skills/* projects/[project-name]/.claude/skills/
# Tier-gated skills are re-added by Step 5.8 per risk profile (file presence = active ceremony)
rm -rf projects/[project-name]/.claude/skills/{codebase-audit,framework-audit,skill-gate} projects/[project-name]/.claude/skills/README.md
```
