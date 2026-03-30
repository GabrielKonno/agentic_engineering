# Pre-built Process Skills

Framework workflow skills (inline) — copied to projects during bootstrap Step 5.7.

> **Note:** 3 process components that produce decisions or analyses were converted to proper agents:
> `prd-sync-checker`, `criteria-enforcer`, `diff-pattern-extractor`.
> They live in `docs/modules/templates/` and are copied to `.claude/agents/` during bootstrap.
> This directory contains the 7 **inline** skills only.

## What these are

These 7 skills implement inline steps of the Session Protocol and Execution Protocol. The main agent reads the SKILL.md and follows the steps in its own context. They were inline instructions in v1.5.0 (hardcoded in CLAUDE.md templates). In v1.6.0, they are pre-built skills that are:

1. **Copied** to each project's `.claude/skills/` at bootstrap
2. **Triggered** explicitly by the Session Protocol in CLAUDE.md
3. **Evolvable** via the standard evolution mechanisms (FIX/DERIVED/CAPTURED)

## Skills list

| # | Skill | Type | When triggered |
|---|-------|------|---------------|
| 1 | sprint-proposer | Process + judgment | Start of session (item 6) |
| 2 | validation-orchestrator | Process + judgment | During implementation |
| 3 | project-md-updater | Process + judgment | End of session (item 2) |
| 4 | pendencias-updater | Process + judgment | End of session (item 3) |
| 5 | config-file-updater | Process + judgment | End of session (item 4) |
| 6 | rules-agents-updater | Process + judgment | End of session (item 5) |
| 7 | session-log-creator | Process pure | End of session (with item 2) |

## Skill Creator usage

**Framework level:** Skills were developed using the Skill Creator plugin for eval. Process-pure skills verified by dry-run walkthrough. Process+judgment skills verified with 2 test scenarios.

**Project level:** The Skill Creator is used for on-demand skill creation and eval during development sessions.

## Scripts

Skills with `scripts/` subdirectories contain bash helper scripts for deterministic operations. These scripts require bash (already a Claude Code requirement). The SKILL.md contains the full process — scripts are optional automation, not dependencies.

## Bootstrap copy command

```bash
cp -r docs/modules/skills/* projects/[project-name]/.claude/skills/
```
