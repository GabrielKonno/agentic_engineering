# Framework Audit

This is a **read-only audit session** for the agentic_engineering framework repository. No files will be modified.

**Authorized operations:**
- Read any file in the repository
- List directory contents
- Launch parallel audit agents
- No file creation, modification, or deletion

**Rules:**
- Every check is mechanical: compare claim against fact, report mismatch
- Do not fix anything — report only
- Do not suggest improvements beyond identifying the mismatch
- Each agent produces a structured report with PASS/FAIL per dimension

---

## Phase 1 — Dispatch Audit Agents

Launch ALL 5 agents below **in a single message** using 5 parallel Agent tool calls.
Do NOT wait for one to finish before launching the next.

Each agent receives its full contract as the prompt. Use `subagent_type: "general-purpose"` for all.

---

### Agent 1: Structural Sync (Dimensions A, D4, D9, D16)

```
You are a structural sync auditor for the Agentic Engineering Framework.
Your job is purely mechanical: read files, compare claims against disk, report mismatches.
Do NOT fix anything. Do NOT suggest improvements.

FILES TO READ:
1. docs/modules/skills/README.md
2. CLAUDE.md (the "Repository Structure" section with ASCII diagram)
3. List contents of .claude/skills/ (folders only)
4. List contents of docs/modules/skills/ (folders only, exclude README.md)

CHECKS:

[A] Dual placement compliance
  A.1. List every folder in docs/modules/skills/
  A.2. List every folder in .claude/skills/
  A.3. For each skill in .claude/skills/: verify it also exists in docs/modules/skills/
  A.4. Note: most skills belong in docs/modules/skills/ ONLY. Only runtime skills
       needed by framework commands belong in .claude/skills/ (currently only
       cross-cutting-analysis qualifies — used by /prd_planning and /prd_change).

[D4] Skills README list vs disk
  D4.1. Parse the skills table in docs/modules/skills/README.md — extract every skill name
  D4.2. List every folder in docs/modules/skills/ (exclude README.md)
  D4.3. Which folders exist on disk but are NOT listed in the README table?
  D4.4. Which names are listed in the README but have NO folder on disk?
  D4.5. Check any count claims in the README (e.g., "10 skills") against actual folder count

[D9] CLAUDE.md ASCII diagram vs actual file structure
  D9.1. Extract the ASCII tree from CLAUDE.md "Repository Structure" section
  D9.2. List actual file/folder structure (top 3 levels, excluding .git/ and projects/)
  D9.3. For each entry in the diagram: verify it exists on disk
  D9.4. For each significant file/folder on disk (top 3 levels): verify it appears in the diagram
  D9.5. Check count comments in the diagram (e.g., "5 slash commands", "11 process skills")
        against actual counts on disk

[D16] Project-information isolation (privacy)
  D16.1. Build the blocklist DYNAMICALLY: list the folder names under projects/ (each name
         plus obvious variants — hyphen/underscore forms, with and without suffixes).
  D16.2. From each project's own CLAUDE.md / project.md (read-only), harvest additional
         identifiers: client/person names, deployment domains (*.vercel.app, custom
         domains), repo URLs, infra refs (e.g. Supabase project ids).
  D16.3. Grep every framework-layer file for every blocklist entry, case-insensitive:
         all TRACKED files AND `.claude/docs/` (gitignored agent notes — the isolation
         principle covers the agent's own documents too). Exclude only projects/ and .git/.
         The agent's persistent memory lives outside the repo — flag in the report that it
         is governed by the same principle (convention, not mechanically scanned here).
  D16.4. Templates get DOUBLE scrutiny (docs/modules/**, examples/**): they are copied into
         every bootstrapped project — a project identifier inside a template broadcasts one
         client's information to all future clients.
  D16.5. Report every hit with file, line, and identifier class. Zero hits = PASS.
         Lineage/history docs are NOT exempt — they must use anonymized placeholders
         (e.g. "projeto-fonte", "a prior project").

REPORT FORMAT:

## Agent 1: Structural Sync

### [A] Dual Placement
- Status: PASS / FAIL
- Findings: [list of mismatches, or "none"]

### [D4] Skills README vs Disk
- Status: PASS / FAIL
- README lists: [count] skills
- Disk has: [count] folders
- Missing from README: [list]
- Missing from disk: [list]
- Count claim accuracy: [correct / incorrect — says N, actually M]

### [D9] CLAUDE.md Diagram vs Disk
- Status: PASS / FAIL
- In diagram but not on disk: [list]
- On disk but not in diagram: [list]
- Count mismatches: [list]

### [D16] Project-Information Isolation
- Status: PASS / FAIL
- Blocklist derived: [N project names + M harvested identifiers]
- Hits: [file:line — identifier (class), or "none"]
```

---

### Agent 2: Bootstrap Integrity (Dimensions D5, D11, D13, D14)

```
You are a bootstrap integrity auditor for the Agentic Engineering Framework.
Your job is purely mechanical: read bootstrap.md and verify its internal consistency
and external references. Do NOT fix anything.

FILES TO READ:
1. .claude/commands/bootstrap.md (entire file — primary source)
2. List files in docs/modules/templates/
3. List files in docs/modules/agents/
4. List files in docs/modules/rules/
5. List folders in docs/modules/skills/
6. docs/modules/templates/claude_md.md
7. .claude/commands/prd_planning.md (the PRD Structure template section near the end)

CHECKS:

[D5] Bootstrap file references resolve
  D5.1. Extract every file path referenced in bootstrap.md (cp commands, Read references,
        template paths like docs/modules/templates/claude_md.md, agent paths, etc.)
  D5.2. For each path: verify the file exists on disk
  D5.3. Report any path that does NOT resolve
  D5.4. Check naming convention consistency (bootstrap references underscore-named sources
        in docs/modules/agents/ and copies to hyphen-named targets in .claude/agents/)

[D11] Bootstrap step sequencing
  D11.1. List every Step number with a 1-line summary of what it does
  D11.2. For each step, identify what it PRODUCES (files created, directories made)
  D11.3. For each step, identify what it CONSUMES (files it reads that were created by earlier steps)
  D11.4. Check: does any step reference a file or output created by a LATER step?
  D11.5. Count: how many primary steps (1, 2, 3...) and sub-steps (1.5, 5.7, 14.5...)?
  D11.6. Total discrete steps = primary + sub-steps
  D11.7. Compare total against any "N-step pipeline" claims in this file or in
         docs/agentic_engineering_framework.md

[D13] PRD template ↔ bootstrap reader compatibility
  D13.1. Read the PRD Structure template at the end of prd_planning.md — extract every
         section number and heading (e.g., "Section 1: Product Vision", "Section 5: Architecture")
  D13.2. Read bootstrap.md Steps 1-3 — what PRD section numbers/headings does it reference?
  D13.3. Compare: does bootstrap reference any PRD section that the PRD template does NOT define?
  D13.4. Compare: does the PRD template define sections that bootstrap never reads?
         (This is INFO, not a failure — some sections may only be for human reference)

[D14] Bootstrap output completeness
  D14.1. Read docs/modules/templates/claude_md.md — list every reference to a skill, agent,
         rule, or file that the generated CLAUDE.md will point to
  D14.2. For each reference: trace it to a bootstrap step that creates or copies that file
  D14.3. Flag any reference in the template that has NO corresponding bootstrap step
  D14.4. If bootstrap has a final report step: verify it lists every file created in prior steps

REPORT FORMAT:

## Agent 2: Bootstrap Integrity

### [D5] File References
- Status: PASS / FAIL
- Total paths found: [N]
- Resolved: [N]
- Unresolved: [list with line numbers]

### [D11] Step Sequencing
- Status: PASS / FAIL
- Primary steps: [N], Sub-steps: [N], Total: [N]
- Claimed: "[N]-step pipeline" — Actual: [M] discrete steps
- Forward references: [list, or "none"]

### [D13] PRD ↔ Bootstrap Compatibility
- Status: PASS / FAIL
- PRD sections defined: [list]
- Bootstrap reads sections: [list]
- Bootstrap reads but PRD lacks: [list, or "none"]
- PRD defines but bootstrap ignores: [list — INFO only]

### [D14] Output Completeness
- Status: PASS / FAIL
- Template references: [count]
- Traced to bootstrap steps: [count]
- Untraced: [list, or "none"]
```

---

### Agent 3: Activation Chain (Dimensions D6, D7)

```
You are an activation chain auditor for the Agentic Engineering Framework.
Your job is purely mechanical: read agent files and verify vocabulary alignment
and description pattern compliance. Do NOT fix anything.

FILES TO READ:
1. docs/modules/agents/code_reviewer.md
2. docs/modules/agents/security_reviewer.md
3. All other files in docs/modules/agents/ (validator, arbitrator, red_team, blue_team,
   criteria_enforcer, prd_sync_checker, diff_pattern_extractor)
4. examples/agents/ — list all files, read those that match gap-declaration domains
   (e.g., concurrency, performance, accessibility, data-integrity, secrets, compliance, etc.)
5. .claude/rules/component-design.md (sections 1-3: Gap-Declaration, Pushy Description,
   Vocabulary Alignment)

CHECKS:

[D6] Gap-declaration vocabulary alignment
  D6.1. Read code_reviewer.md — find the "Coverage Gap Declaration" section. Extract every
        gap domain and its key phrase (e.g., "concurrency gap", "performance gap",
        "accessibility gap", "data integrity gap")
  D6.2. Read security_reviewer.md — same extraction (e.g., "static analysis gap",
        "secrets coverage gap", "federation protocol gap", "compliance gap",
        "infrastructure security gap")
  D6.3. For each gap phrase: search ALL agent descriptions in docs/modules/agents/ AND
        examples/agents/ for matching vocabulary in the description: field
  D6.4. The match must be exact or near-exact (per component-design.md §3 vocabulary alignment)
  D6.5. Report broken links: gap declared by reviewer but NO specialist agent has matching
        description (= specialist will never be activated)
  D6.6. Report orphaned specialists: agent description references a gap phrase that no
        reviewer declares (= agent exists but can never be triggered)

[D7] Pushy Description pattern compliance
  D7.1. From component-design.md §2, the required pattern is:
        [Core function line — MANDATORY] +
        USE PROACTIVELY when [triggers] +
        NOT needed for [exclusions] +
        Without this, [consequence] +
        Produces [Report] → [OUTCOME]
  D7.2. For each agent in docs/modules/agents/ with invocation: subagent:
        check which elements of the pattern are present in its description: field
  D7.3. For each agent in examples/agents/ with invocation: subagent: same check
  D7.4. Flag the anti-pattern: descriptions that are ONLY triggers ("USE PROACTIVELY when X.
        NOT needed for Y. Without this Z.") with NO core function statement
  D7.5. Note: process agents (prd-sync-checker, criteria-enforcer, diff-pattern-extractor)
        use "MUST run" style — acceptable per their protocol role. Validator and arbitrator
        are spawned by protocol, not gap declaration. The Pushy Description pattern is most
        critical for specialist agents in examples/agents/.

REPORT FORMAT:

## Agent 3: Activation Chain

### [D6] Vocabulary Alignment
- Status: PASS / FAIL
- Gap declarations found:
  - code-reviewer: [list of gap names]
  - security-reviewer: [list of gap names]
- Specialist matches:
  | Gap | Reviewer | Specialist file | Phrase match | Status |
  |-----|----------|----------------|--------------|--------|
  [one row per gap]
- Broken links (gap → no specialist): [list, or "none"]
- Orphaned specialists (specialist → no gap): [list, or "none"]

### [D7] Pushy Description Compliance
- Status: PASS / FAIL
- Agents checked: [count]
  | Agent | Core function | Triggers | Exclusions | Consequence | Output | Status |
  |-------|--------------|----------|------------|-------------|--------|--------|
  [one row per agent — COMPLIANT / PARTIAL / NON-COMPLIANT]
- Anti-pattern instances: [list, or "none"]
```

---

### Agent 4: Orchestration & Commands (Dimensions D8, D10)

```
You are an orchestration auditor for the Agentic Engineering Framework.
Your job is purely mechanical: trace skill and agent name references from
orchestrating files and verify they resolve to existing folders/files on disk.
Do NOT fix anything.

FILES TO READ:
1. docs/modules/skills/session-end/SKILL.md
2. docs/modules/skills/validation-orchestrator/SKILL.md
3. docs/modules/skills/sprint-proposer/SKILL.md
4. docs/modules/skills/cross-cutting-analysis/SKILL.md
5. .claude/commands/prd_planning.md
6. .claude/commands/prd_change.md
7. List folders in docs/modules/skills/
8. List files in docs/modules/agents/

CHECKS:

[D8] Skill/agent names in orchestrators resolve
  D8.1. Read session-end/SKILL.md — extract every reference to another skill by name or path
        (e.g., "project-md-updater", "pendencias-updater", "config-file-updater",
        "rules-agents-updater", "session-log-creator", "diff-pattern-extractor")
  D8.2. Read validation-orchestrator/SKILL.md — extract every skill or agent name referenced
  D8.3. Read sprint-proposer/SKILL.md — extract every skill or agent name referenced
  D8.4. For each referenced skill name: verify a folder with that name exists in
        docs/modules/skills/
        (Note: orchestrators use project paths like ".claude/skills/X" but the framework
         source is "docs/modules/skills/X" — map the name, not the full path)
  D8.5. For each referenced agent name: verify a file exists in docs/modules/agents/
        (Note: agent file names use underscores — map hyphenated references like
        "diff-pattern-extractor" to "diff_pattern_extractor.md")
  D8.6. Report any reference that does NOT resolve

[D10] Command → skill invocation paths
  D10.1. Read prd_planning.md — extract every reference to a skill
         (e.g., "cross-cutting-analysis", ".claude/skills/cross-cutting-analysis/SKILL.md")
  D10.2. Read prd_change.md — extract every reference to a skill
  D10.3. For each referenced skill: verify the folder exists in docs/modules/skills/
  D10.4. For skills that the framework uses at runtime (cross-cutting-analysis):
         verify it ALSO exists in .claude/skills/
  D10.5. Report any reference that does NOT resolve

REPORT FORMAT:

## Agent 4: Orchestration & Commands

### [D8] Orchestrator References
- Status: PASS / FAIL
- References found:
  | Source file | Referenced name | Expected path | Exists? |
  |-------------|----------------|---------------|---------|
  [one row per reference]
- Unresolved: [list, or "none"]

### [D10] Command → Skill Paths
- Status: PASS / FAIL
- References found:
  | Command file | Referenced skill | Expected location | Exists? |
  |-------------|-----------------|-------------------|---------|
  [one row per reference]
- Unresolved: [list, or "none"]
```

---

### Agent 5: Document Accuracy (Dimensions C, E, D12, D15)

```
You are a document accuracy auditor for the Agentic Engineering Framework.
Your job is purely mechanical: read documents, check claims against facts,
check instruction style, and verify examples follow conventions. Do NOT fix anything.

FILES TO READ:
1. README.md
2. docs/agentic_engineering_framework.md (large file — focus on: line 47 area for component
   counts, the Repository Components table, the Bootstrap Pipeline section, the Project Structure
   section, and any numeric claims)
3. docs/modules/README.md
4. docs/modules/skills/README.md
5. CLAUDE.md (for count claims)
6. .claude/rules/component-design.md (section 6 — imperative vs descriptive instruction rules)
7. examples/README.md (conventions for agents/skills/rules)
8. docs/modules/skills/commit/SKILL.md (version string)
9. 3 skill files: docs/modules/skills/session-end/SKILL.md,
   docs/modules/skills/sprint-proposer/SKILL.md,
   docs/modules/skills/validation-orchestrator/SKILL.md
10. 2 agent files: docs/modules/agents/code_reviewer.md,
    docs/modules/agents/validator.md
11. Sample from examples/: 3 agents, 2 skills, 2 rules (pick representative files)

CHECKS:

[C] Imperative vs descriptive instruction style (sampling)
  C.1. From component-design.md §6: the three properties of a reliable behavioral instruction:
       (1) imperative verb in CAPS, (2) dedicated section, (3) explicit output format
  C.2. Read the 3 skill files listed above. Identify behavioral instructions
       (steps the AI must execute every time)
  C.3. Check: are behavioral instructions written in imperative style with CAPS verbs?
  C.4. Check: are any behavioral requirements buried inside descriptive/rationale paragraphs?
  C.5. Read the 2 agent files. Apply the same checks to checklist items and process steps.
  C.6. Report specific instances of the anti-pattern (requirement buried in description)

[E] Version string consistency
  E.1. Extract the canonical framework version from README.md (title or first heading)
  E.2. Search for version patterns (v2.X.X, framework-vX.X.X) in: README.md, CLAUDE.md,
       docs/agentic_engineering_framework.md, docs/modules/skills/README.md,
       docs/modules/skills/commit/SKILL.md, and any other files where versions appear
  E.3. List every occurrence with file, line, and the version string
  E.4. Report any version string that does NOT match the canonical version
  E.5. Specifically flag: commit/SKILL.md "created: framework-v2.2.1" vs README canonical version

[D12] Examples follow conventions in examples/README.md
  D12.1. Read examples/README.md — extract required frontmatter fields and structural conventions
  D12.2. Sample 3 agent examples, 2 skill examples, 2 rule examples
  D12.3. For each: verify all required frontmatter fields are present
  D12.4. For agents with invocation: subagent: verify they have description with core function
  D12.5. For skills: verify they use the folder/SKILL.md format
  D12.6. Report any convention violations

[D15] Framework concept doc + READMEs factual accuracy
  D15.1. From docs/agentic_engineering_framework.md — extract ALL numeric claims:
         - Skill counts (look for "14 pre-built", "11 inline", "14 skills", "3 tier-gated")
         - Agent counts (look for "10 agent", "3 process agents")
         - Step counts (look for "15-step")
         - Example counts (look for "20", "9", "11" for agents/skills/rules)
  D15.2. From README.md — extract all numeric claims about components
  D15.3. From docs/modules/README.md — extract any count claims
  D15.4. For each claim: compare against actual count on disk
  D15.5. List all skills folders in docs/modules/skills/ and count them
  D15.6. List all agent files in docs/modules/agents/ and count them
  D15.7. List all example files in examples/agents/, examples/skills/, examples/rules/ and count
  D15.8. Report every factual inaccuracy: file, line (approximate), claim, actual value

REPORT FORMAT:

## Agent 5: Document Accuracy

### [C] Instruction Style
- Status: PASS / FAIL
- Files sampled: [list]
- Anti-pattern instances: [count]
- Details:
  | File | Line area | Issue | Current text (excerpt) |
  |------|-----------|-------|----------------------|
  [one row per finding, or "none"]

### [E] Version Consistency
- Status: PASS / FAIL
- Canonical version: [from README.md]
- All occurrences:
  | File | Line | Version string | Matches? |
  |------|------|---------------|----------|
  [one row per occurrence]
- Mismatches: [count]

### [D12] Examples Convention Compliance
- Status: PASS / FAIL
- Files sampled: [list]
- Violations:
  | File | Missing field/issue | Convention reference |
  |------|-------------------|---------------------|
  [one row per violation, or "none"]

### [D15] Factual Accuracy
- Status: PASS / FAIL
- Claims checked:
  | File | Claim | Actual | Accurate? |
  |------|-------|--------|-----------|
  [one row per claim]
- Inaccuracies: [count]
```

---

## Phase 2 — Merge Reports

After ALL 5 agents return, consolidate their reports into a single audit report.

### Consolidated Report Format

```markdown
# Framework Audit Report

**Date:** [today's date]
**Framework version:** [from README.md]
**Dimensions checked:** 16
**Agents dispatched:** 5

## Summary

| # | Dimension | Category | Agent | Status | Finding |
|---|-----------|----------|-------|--------|---------|
| A | Dual placement | Structural | 1 | PASS/FAIL | [1-line summary] |
| C | Instruction style | Quality | 5 | PASS/FAIL | [1-line summary] |
| E | Version consistency | Currency | 5 | PASS/FAIL | [1-line summary] |
| D4 | Skills README vs disk | Currency | 1 | PASS/FAIL | [1-line summary] |
| D5 | Bootstrap file refs | References | 2 | PASS/FAIL | [1-line summary] |
| D6 | Gap vocabulary | References | 3 | PASS/FAIL | [1-line summary] |
| D7 | Pushy Description | Quality | 3 | PASS/FAIL | [1-line summary] |
| D8 | Orchestrator refs | Process | 4 | PASS/FAIL | [1-line summary] |
| D9 | CLAUDE.md diagram | Currency | 1 | PASS/FAIL | [1-line summary] |
| D10 | Command → skill paths | References | 4 | PASS/FAIL | [1-line summary] |
| D11 | Bootstrap sequencing | Process | 2 | PASS/FAIL | [1-line summary] |
| D12 | Examples conventions | Currency | 5 | PASS/FAIL | [1-line summary] |
| D13 | PRD ↔ bootstrap compat | Process | 2 | PASS/FAIL | [1-line summary] |
| D14 | Bootstrap output | Process | 2 | PASS/FAIL | [1-line summary] |
| D15 | Doc factual accuracy | Currency | 5 | PASS/FAIL | [1-line summary] |
| D16 | Project-info isolation | Privacy | 1 | PASS/FAIL | [1-line summary] |
```

### Detailed Findings

Paste each agent's full report in order (Agent 1 through Agent 5).

### Recommended Fixes

Group FAIL items by priority:
1. **Quick fixes** — version mismatches, count corrections (single-line edits)
2. **Structural fixes** — missing references, broken activation chains
3. **Quality improvements** — instruction style, description compliance

End with: **Suggestion:** Run `/maintenance` to apply fixes, using this report as the correction plan.
