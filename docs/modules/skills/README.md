# Pre-built Process Skills

Framework workflow skills — copied to projects during bootstrap Step 5.7.

> **Note:** 3 process components that produce decisions or analyses are proper agents:
> `prd-sync-checker`, `criteria-enforcer`, `diff-pattern-extractor`.
> They live in `docs/modules/agents/` and are copied to `.claude/agents/` during bootstrap.
> This directory contains 13 skills: 11 **inline** (6 implementation + 3 session lifecycle + 1 PRD process + 1 commit workflow) + 2 **tier-gated audit** skills (codebase-audit, framework-audit) copied only when the project's risk profile warrants them.

## What these are

These skills implement steps of the Session Protocol, Execution Protocol, PRD workflows, commit hygiene, and the periodic MACRO/meta audits. The main agent reads the SKILL.md and follows the steps in its own context. In v2.1.0, protocol logic moved from CLAUDE.md into skills — CLAUDE.md retains only pointers. Skills are:

1. **Copied** to each project's `.claude/skills/` at bootstrap
2. **Triggered** by convention (sprint-proposer/session-end are user-invoked; others are called by orchestrating skills)
3. **Evolvable** via the standard evolution mechanisms (FIX/DERIVED/CAPTURED — see `.claude/rules/evolution-policy.md`)

## Skills list

| # | Skill | Type | When triggered |
|---|-------|------|---------------|
| 1 | sprint-proposer | Process + judgment | Start of session (user-triggered) — loads context, proposes sprint, manages sprint-approved mode |
| 2 | session-end | Process + judgment | End of session (user-triggered) |
| 3 | context-recovery | Process pure | Mid-session emergency (user-triggered) |
| 4 | validation-orchestrator | Process + judgment | Before + during implementation |
| 5 | project-md-updater | Process + judgment | End of session (called by session-end, item 2) |
| 6 | pendencias-updater | Process + judgment | End of session (called by session-end, item 3) |
| 7 | config-file-updater | Process + judgment | End of session (called by session-end, item 4) |
| 8 | rules-agents-updater | Process + judgment | End of session (called by session-end, item 5) |
| 9 | session-log-creator | Process pure | End of session (called by session-end, with item 2) |
| 10 | cross-cutting-analysis | Process + judgment | During PRD planning (Phase 4) and PRD change (Phase 3) — identifies and maintains transversal themes |
| 11 | commit | Process pure | Before any non-trivial commit (user-triggered) — staging verification, intent matching, conventional messages |
| 12 | codebase-audit | Process + judgment (tier-gated: internal-tool+) | Periodic MACRO health audit (user-triggered; proposed by sprint-proposer at AUDIT_CADENCE / phase boundary) |
| 13 | framework-audit | Process + judgment (tier-gated: production+) | Periodic meta-audit of the project's own process (user-triggered; proposed at FRAMEWORK_AUDIT_CADENCE / phase boundary) |

## Skill Creator usage

**Framework level:** Skills were developed using the Skill Creator plugin for eval. Process-pure skills verified by dry-run walkthrough. Process+judgment skills verified with 2 test scenarios.

**Project level:** The Skill Creator is used for on-demand skill creation and eval during development sessions.

## Scripts

Skills with `scripts/` subdirectories contain bash helper scripts for deterministic operations. These scripts require bash (already a Claude Code requirement). The SKILL.md contains the full process — scripts are optional automation, not dependencies.

## Bootstrap copy command

```bash
cp -r docs/modules/skills/* projects/[project-name]/.claude/skills/
```
