# Pre-built Process Skills

Framework workflow skills — copied to projects during bootstrap Step 5.7.

> **Note:** 3 process components that produce decisions or analyses are proper agents:
> `prd-sync-checker`, `criteria-enforcer`, `diff-pattern-extractor`.
> They live in `docs/modules/agents/` and are copied to `.claude/agents/` during bootstrap.
> This directory contains the 10 **inline** skills (7 implementation + 3 session lifecycle).

## What these are

These 10 skills implement steps of the Session Protocol and Execution Protocol. The main agent reads the SKILL.md and follows the steps in its own context. In v1.7.0, protocol logic moved from CLAUDE.md into skills — CLAUDE.md retains only pointers. Skills are:

1. **Copied** to each project's `.claude/skills/` at bootstrap
2. **Triggered** by convention (session-start/session-end are user-invoked; others are called by orchestrating skills)
3. **Evolvable** via the standard evolution mechanisms (FIX/DERIVED/CAPTURED — see `.claude/rules/evolution-policy.md`)

## Skills list

| # | Skill | Type | When triggered |
|---|-------|------|---------------|
| 1 | session-start | Process + judgment | Start of session (user-triggered) |
| 2 | session-end | Process + judgment | End of session (user-triggered) |
| 3 | context-recovery | Process pure | Mid-session emergency (user-triggered) |
| 4 | sprint-proposer | Process + judgment | Start of session (called by session-start, step 5) |
| 5 | validation-orchestrator | Process + judgment | Before + during implementation |
| 6 | project-md-updater | Process + judgment | End of session (called by session-end, item 2) |
| 7 | pendencias-updater | Process + judgment | End of session (called by session-end, item 3) |
| 8 | config-file-updater | Process + judgment | End of session (called by session-end, item 4) |
| 9 | rules-agents-updater | Process + judgment | End of session (called by session-end, item 5) |
| 10 | session-log-creator | Process pure | End of session (called by session-end, with item 2) |

## Skill Creator usage

**Framework level:** Skills were developed using the Skill Creator plugin for eval. Process-pure skills verified by dry-run walkthrough. Process+judgment skills verified with 2 test scenarios.

**Project level:** The Skill Creator is used for on-demand skill creation and eval during development sessions.

## Scripts

Skills with `scripts/` subdirectories contain bash helper scripts for deterministic operations. These scripts require bash (already a Claude Code requirement). The SKILL.md contains the full process — scripts are optional automation, not dependencies.

## Bootstrap copy command

```bash
cp -r docs/modules/skills/* projects/[project-name]/.claude/skills/
```
