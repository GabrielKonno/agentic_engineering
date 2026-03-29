# Pre-built Process Skills

Framework workflow skills — copied to projects during bootstrap Step 5.7.

## What these are

These 10 skills implement the framework's Session Protocol and Execution Protocol as reusable, evolvable components. They were inline instructions in v1.5.0 (hardcoded in CLAUDE.md templates). In v1.6.0, they are pre-built skills that are:

1. **Copied** to each project's `.claude/skills/` (or `.antigravity/skills/`) at bootstrap
2. **Triggered** explicitly by the Session Protocol in CLAUDE.md/GEMINI.md
3. **Evolvable** via the standard evolution mechanisms (FIX/DERIVED/CAPTURED)

## Skills list

| # | Skill | Type | When triggered |
|---|-------|------|---------------|
| 1 | prd-sync-checker | Process pure | Start of session (item 4) |
| 2 | sprint-proposer | Process + judgment | Start of session (item 6) |
| 3 | criteria-enforcer | Process + judgment | Before implementing |
| 4 | validation-orchestrator | Process + judgment | During implementation |
| 5 | diff-pattern-extractor | Process + judgment | End of session (item 1) |
| 6 | project-md-updater | Process + judgment | End of session (item 2) |
| 7 | pendencias-updater | Process + judgment | End of session (item 3) |
| 8 | claude-md-updater | Process + judgment | End of session (item 4) |
| 9 | rules-agents-updater | Process + judgment | End of session (item 5) |
| 10 | session-log-creator | Process pure | End of session (with item 2) |

## Skill Creator usage

**Framework level:** Skills were developed using the Skill Creator plugin for eval. Process-pure skills verified by dry-run walkthrough. Process+judgment skills verified with 2 test scenarios.

**Project level:** The Skill Creator is used for on-demand skill creation and eval during development sessions.

## Scripts

Skills with `scripts/` subdirectories contain bash helper scripts for deterministic operations. These scripts require bash (already a Claude Code requirement; Antigravity uses terminal). The SKILL.md contains the full process — scripts are optional automation, not dependencies.

## Bootstrap copy command

```bash
cp -r docs/modules/skills/* projects/[project-name]/.claude/skills/
```
