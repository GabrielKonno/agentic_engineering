# Template: settings.json

> Create at `.claude/settings.json`

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions",
    "allow": [
      "Edit(CLAUDE.md)",
      "Edit(.claude/**)",
      "Write(.claude/**)",
      "Read",
      "Bash(git *)",
      "Bash(npm *)",
      "Bash(npx *)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "if [[ \"$CLAUDE_TOOL_FILE_PATH\" == *.js || \"$CLAUDE_TOOL_FILE_PATH\" == *.ts || \"$CLAUDE_TOOL_FILE_PATH\" == *.jsx || \"$CLAUDE_TOOL_FILE_PATH\" == *.tsx || \"$CLAUDE_TOOL_FILE_PATH\" == *.json || \"$CLAUDE_TOOL_FILE_PATH\" == *.css || \"$CLAUDE_TOOL_FILE_PATH\" == *.md ]]; then npx prettier --write \"$CLAUDE_TOOL_FILE_PATH\" 2>/dev/null || true; fi",
            "timeout": 30
          },
          {
            "type": "command",
            "command": "if [ -f .claude/skills/skill-gate/scripts/skill_gate_hook.sh ]; then bash .claude/skills/skill-gate/scripts/skill_gate_hook.sh; fi",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

## Notes

**What this does:** After every file write/edit, if the file is `.ts`, `.tsx`, `.js`, `.jsx`, `.json`, `.css`, or `.md`, Prettier runs automatically. Uses `$CLAUDE_TOOL_FILE_PATH` (native Claude Code environment variable). Diffs stay clean without consuming context.

**Skill-gate hook (second entry):** enforces the component creation gate — when a draft in `.claude/drafts/` is marked `status: ready-for-review`, it blocks (exit 2) with an instruction to spawn the skill-reviewer. Safe to register on ALL tiers: the `[ -f ... ]` guard makes it a silent no-op when the skill-gate skill is not installed (prototype), so tier-gating stays file-presence-based. Exit 2 is required — exit 1 does NOT block.

**Permissions:** The `allow` rules grant automatic approval for editing framework files (`CLAUDE.md`, `.claude/**`), reading files, and running common commands (`git`, `npm`, `npx`). Prevents permission prompts during end-of-session documentation updates. `bypassPermissions` is the fallback.

**Prerequisite:** Prettier must be installed (`npm install -D prettier`). If the project does not use Prettier, skip the hooks section.

**Merge rule:** If `.claude/settings.json` or `.claude/settings.local.json` already exists, merge the `hooks` key into the existing file rather than overwriting.
