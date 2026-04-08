# PRD Change Session

This is a **PRD change session** for project **$ARGUMENTS**.

**Project path:** `projects/$ARGUMENTS/`
**PRD path:** `projects/$ARGUMENTS/assets/docs/prd.md`

## Authorized Operations

- Modify `projects/$ARGUMENTS/assets/docs/prd.md`
- Modify engineering documents inside `projects/$ARGUMENTS/` (project.md, pendencias.md, CLAUDE.md, rules)
- No other files outside `projects/$ARGUMENTS/` should be modified

## Rules

- All documents are written in English for consistency
- Conversational output (reports, questions, summaries) should be in Brazilian Portuguese
- Never modify files in `docs/` or `examples/` (framework read-only references)
- Never create application code — this is a change planning session only
- **Collect MAXIMUM detail** during Phase 2 (Investigation) — dig deeper, ask follow-ups, challenge vague statements. The quality of the PRD change depends on the depth of information gathered.

## Setup

Before starting the process:

1. Verify `projects/$ARGUMENTS/` exists. If not, stop and tell the user: "Project '$ARGUMENTS' not found in projects/. Create it first with `/prd_planning $ARGUMENTS`."
2. Verify `projects/$ARGUMENTS/assets/docs/prd.md` exists. If not, stop and tell the user: "No PRD found for project '$ARGUMENTS'. Create one first with `/prd_planning $ARGUMENTS`."
3. Read `projects/$ARGUMENTS/assets/docs/prd.md` completely before starting Phase 1.

---

## Process

I want to propose a change to the product. Before modifying any document, follow this process:

### Phase 1 — Classification

Analyze my proposal and classify it into ONE of these categories:

| Category | Goes in PRD? | Goes in project.md? | Examples |
|----------|-------------|---------------------|----------|
| **New feature** | ✅ Yes | ✅ Yes (backlog) | "I want to add PDF reports" |
| **Feature removed** | ✅ Yes | ✅ Yes (backlog) | "We are dropping module X" |
| **Business rule changed** | ✅ Yes | ✅ Yes (if affects implementation) | "Commission is now percentage, not fixed" |
| **Target audience changed** | ✅ Yes | Maybe (if affects priorities) | "Focusing on clinics, not automotive" |
| **Stack changed** | ✅ Yes | ✅ Yes (architectural decision) | "Switching from Supabase to Firebase" |
| **Product pivot** | ✅ PRD v2.0 | ✅ Yes (new phase) | "Becoming marketplace instead of SaaS" |
| **Bug fixed** | ❌ No | ✅ Yes | "The date filter was wrong" |
| **Technical decision** | ❌ No | ✅ Yes | "Using parseLocal() instead of toISOString()" |
| **Module implemented** | ❌ No | ✅ Yes | "Login + Auth completed" |
| **UX/UI improvement** | Depends | Depends | See below |
| **Performance optimization** | ❌ No | ✅ Yes | "Lazy loading charts" |

**For "UX/UI improvement":**
- Changes WHAT the user can do (new interaction, new flow) → PRD
- Changes HOW something looks (colors, layout, animation) → project.md or design system
- Changes WHERE something is in the interface (reorganize navigation) → PRD if macro navigation, project.md if fine-tuning

Tell me:
1. Which category my proposal falls into
2. Which documents will be affected
3. If ambiguous, ask before proceeding

If the proposal does NOT go in the PRD: explain where to register it (`projects/$ARGUMENTS/.claude/phases/project.md`, `projects/$ARGUMENTS/.claude/phases/pendencias.md`, rules) and help draft the entry. Do not proceed to Phase 2.

If the proposal DOES go in the PRD: proceed to Phase 2.

---

### Phase 2 — Investigation

Before drafting any changes, ask me questions to fully understand the impact. Adapt questions to the category:

**If NEW FEATURE:**
1. What problem does this feature solve? Who requested it?
2. Is it mandatory for MVP or can it be Phase 2/3?
3. Which existing modules does it affect?
4. Which modules does this feature depend on? Does it depend on modules not yet built?
5. Does it introduce new database entities? Which fields, types, constraints? Does it modify existing entities?
6. Does it have business rules? Which? (For each rule, propose a verifiable acceptance criterion.)
7. What is the main user flow?
8. What are the edge cases? (Empty state, error handling, boundary values, concurrency, integration failures)
9. What are the verifiable acceptance criteria? (Must have 3 parts: action, expected result, failure signal)
10. Does it impact existing features? How?
11. Which external services or other modules does it integrate with? What data is exchanged?
12. Are there specific performance, authorization, or volume constraints for this feature?
13. What is its priority vs what is already planned?
14. Where does it fit in the build order? Does it shift existing module priorities?

**If FEATURE REMOVED:**
1. Why is it being removed?
2. Has it been partially implemented? What happens to existing code?
3. Do other modules depend on it? Does removing it break the dependency graph?
4. Goes to "Out of scope" permanently or to "Future phase"?
5. Should associated data/tables be removed or kept?
6. Does the build order need resequencing after removal?

**If BUSINESS RULE CHANGED:**
1. What was the old rule and what is the new one?
2. What motivated the change?
3. Does it affect existing data? How to migrate?
4. Does it affect the module's data model (field types, constraints, status fields, state transitions)?
5. Does it affect flows in other modules?
6. Does it affect financial calculations, permissions, or status logic?
7. Does it introduce or invalidate edge cases?
8. What is the transition period?
9. Are existing acceptance criteria still valid with the new rule? (Review each criterion against the change.)

**If TARGET AUDIENCE CHANGED:**
1. Who was the old audience and who is the new one?
2. Which features gain/lose priority?
3. Does the interface language need to change?
4. Does the business model change too?
5. Do existing features become irrelevant?
6. Are new features needed?

**If STACK CHANGED:**
1. What changes and why?
2. Impact on existing code?
3. Does the data model structure change (e.g., different DB paradigm, ORM vs raw SQL)?
4. Are architectural decisions in project.md affected?
5. Do installed tools need to change?
6. Do installed skills still apply?
7. Does the build order need adjustment?
8. Is the timeline affected?

**If PRODUCT PIVOT:**
1. What was the old vision and what is the new one?
2. What is kept from the current PRD?
3. Which sections need rewriting?
4. Do audience, business model, and metrics change together?
5. Is existing implementation reusable or disposable?
6. Does the roadmap need to be redone?

Ask in blocks of 3-5. Wait for my answers before proceeding. DO NOT draft anything until you have all answers.

---

### Phase 3 — Impact Analysis

**Cross-cutting check (before analysis):** Read the PRD's "Cross-cutting Concerns" section if it exists. Follow the **consultation mode** process from the `cross-cutting-analysis` skill (`.claude/skills/cross-cutting-analysis/SKILL.md`):
- If the section exists: check if the proposed change touches any listed concern. If it does, expand the impact analysis to include ALL sections listed under that concern — even if the change was only requested for one section.
- If the section does not exist: warn the human — "This PRD has no Cross-cutting Concerns section. Transversal themes are not tracked. Consider running the cross-cutting-analysis skill before continuing." Allow continuing without it if the human chooses.

Based on the answers, present an impact analysis BEFORE drafting:

```
## Impact Analysis: [title of change]

### Classification: [category]

### Summary:
[1-2 sentences]

### PRD sections affected:
- Section X.X — [what changes]
- Section Y.Y — [what changes]
- Section 3.X Dependencies — [if dependency graph changes]
- Section 3.X Data model — [if entities/fields change]
- Section 3.X Edge cases — [if new edge cases or invalidated ones]
- Section 3.X Integration points — [if integrations change]
- Section 5.4 Build Order — [if implementation sequence changes]
[Remove lines that don't apply]

### Impact on engineering documents:
- project.md: [what to update — phases, decisions, module relationships]
- pendencias.md: [tasks to add/remove/reprioritize]
- CLAUDE.md: [Build Order, Architecture, Key Patterns — if affected]
- rules/*.md: [domain rules affected]

### Impact on existing code:
- [module/file affected — what changes]
- Breaking changes: [yes/no — detail if yes]
- Migration needed: [yes/no — detail if yes]

### Cross-cutting concerns touched:
- [Concern name] — affects sections X.Y, X.Y, X.Y
- [Concern name] — affects sections X.Y, X.Y
[Remove this subsection if PRD has no Cross-cutting Concerns section or no concerns are touched]

### Risks:
- [risk and mitigation]

### PRD version: [current] → [new]
```

Present this analysis and ask for confirmation before drafting.

---

### Phase 4 — Drafting

After confirmation, draft changes for each affected document:

**In the PRD (`projects/$ARGUMENTS/assets/docs/prd.md`):**
1. Modify ONLY the sections listed in the impact analysis
2. If the change touches a cross-cutting concern: propagate modifications to ALL sections listed under that concern, not just the section where the change was requested. Apply the concern's consistency rules if defined.
3. If the change alters a cross-cutting theme's scope (adds/removes affected sections, changes consistency rules): update the Cross-cutting Concerns section itself
4. Keep the rest of the document intact
3. Update the Changelog:
   ```
   | [new version] | [date] | [concise description] | [author] |
   ```
4. Increment version: patch for clarifications, minor for features/rules, major for pivots

**In engineering documents (if affected):**
- `projects/$ARGUMENTS/.claude/phases/project.md`: update phases, decisions, module relationships
- `projects/$ARGUMENTS/.claude/phases/pendencias.md`: add/remove/reprioritize tasks with acceptance criteria
- `projects/$ARGUMENTS/CLAUDE.md`: update Build Order, Architecture, Key Patterns if needed
- `projects/$ARGUMENTS/.claude/rules/*.md`: update domain rules if needed

**For each change, show:**
```
### [File]: [section]
BEFORE:
[original text]

AFTER:
[changed text]
```

This allows reviewing each change individually before applying.

---

### Phase 5 — Validation

After approval, run this checklist:

```
## Consistency Checklist
- [ ] PRD internal consistency: change does not contradict other sections
- [ ] Changelog updated with new version
- [ ] All affected engineering documents updated
- [ ] Acceptance criteria of affected tasks updated (3-part standard: action + expected result + failure signal)
- [ ] Removed features not referenced elsewhere in PRD
- [ ] New features have acceptance criteria
- [ ] Module dependencies still form a valid DAG (no circular dependencies)
- [ ] Data model changes consistent across related modules
- [ ] Build order (Section 5.4) reflects current dependency graph
- [ ] Edge cases updated for affected modules
- [ ] Integration points updated if external services changed
- [ ] Module relationships still accurate
- [ ] Cross-cutting concerns: all sections listed for touched themes were reviewed and updated
- [ ] Cross-cutting Concerns section itself updated if the change altered a theme's scope
- [ ] If change introduces a new transversal theme (appears in 3+ sections), suggest re-running cross-cutting-analysis
```

Summarize: "PRD updated from vX.X.X to vY.Y.Y. In the next AI agent session, the PRD sync check will detect and propagate automatically."
