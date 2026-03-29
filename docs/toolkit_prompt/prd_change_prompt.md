# PRD Change Prompt

Use this prompt with any AI assistant whenever you want to propose a change to an existing PRD.
The AI will classify, investigate, and register the change in the correct place.

---

## Prompt

```
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

If the proposal does NOT go in the PRD: explain where to register it (project.md, pendencias.md, rules) and help draft the entry. Do not proceed to Phase 2.

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

### Risks:
- [risk and mitigation]

### PRD version: [current] → [new]
```

Present this analysis and ask for confirmation before drafting.

---

### Phase 4 — Drafting

After confirmation, draft changes for each affected document:

**In the PRD (`assets/docs/prd.md`):**
1. Modify ONLY the sections listed in the impact analysis
2. Keep the rest of the document intact
3. Update the Changelog:
   ```
   | [new version] | [date] | [concise description] | [author] |
   ```
4. Increment version: patch for clarifications, minor for features/rules, major for pivots

**In engineering documents (if affected):**
- project.md: update phases, decisions, module relationships
- pendencias.md: add/remove/reprioritize tasks with acceptance criteria
- CLAUDE.md: update Build Order, Architecture, Key Patterns if needed
- rules/*.md: update domain rules if needed

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
```

Summarize: "PRD updated from vX.X.X to vY.Y.Y. In the next AI agent session, the PRD sync check will detect and propagate automatically."
```

---

## Shortcuts for Common Changes

### Quick new feature:
```
I want to add [feature] to the product.
Context: [why, who asked, what problem it solves]
Priority: [MVP / Phase 2 / Phase 3]
Dependencies: [which modules must exist first | "none"]
Data entities: [new tables/fields introduced, or "uses existing"]
Integration: [external APIs or modules it calls | "none"]
```

### Remove feature:
```
I want to remove [feature] from scope.
Reason: [why]
Existing code for [feature] should: [keep / remove / move to separate branch]
```

### Change business rule:
```
The rule for [module/feature] needs to change.
Before: [old rule]
Now: [new rule]
Reason: [why]
```

### Change stack:
```
I want to switch [current technology] for [new technology].
Reason: [why]
What has been implemented with [current]: [list]
```

Even with shortcuts, the AI will follow the full process (classify → investigate → impact → draft → validate). The shortcut saves time on the initial description, not on the rigor.

---

## Versioning Reference

| Change type | Increment | Example |
|------------|-----------|---------|
| Typo, clarification | Patch: 1.0.0 → 1.0.1 | Fix spelling |
| New feature, removed feature, rule changed | Minor: 1.0.0 → 1.1.0 | Add reports module |
| Audience or stack changed | Minor: 1.1.0 → 1.2.0 | Switch database |
| Product pivot | Major: 1.x.x → 2.0.0 | From SaaS to marketplace |

### Automation flow

```
You change PRD (via this prompt or manually)
  ↓
Changelog updated with new version (REQUIRED)
  ↓
Next AI agent session starts
  ↓
PRD sync check: reads Changelog → detects new version
  ↓
Agent reads full PRD → identifies changes
  ↓
Propagates to: project.md, pendencias.md, CLAUDE.md (Build Order, Architecture), rules
  ↓
Logs in session: "PRD vX.X.X → vY.Y.Y — propagated: [list]"
```

### If you edit the PRD manually (without this prompt)

Update the changelog. The agent has a fallback content-based check that catches structural changes (modules added/removed, stack changed) but may miss subtle rule changes within existing modules. The changelog is the reliable path.
