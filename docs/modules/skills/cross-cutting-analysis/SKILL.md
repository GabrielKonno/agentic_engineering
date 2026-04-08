---
name: cross-cutting-analysis
invocation: inline
effort: medium
description: >
  Identifies and maintains cross-cutting concerns in PRDs — themes that span
  multiple sections and require consistency when changed. Uses heuristic detection
  (repeated terms, implicit dependencies, architectural decisions, transversal NFRs)
  followed by human curation. Generates a dedicated "Cross-cutting Concerns" section
  in the PRD with affected-section checklists. Called from prd_planning (after module
  deep dives) and prd_change (before applying modifications). Without this, changes
  to transversal themes leave residues in unchecked sections.
created: framework-v2.1.0 (pre-validated)
derived_from: null
---

# Cross-cutting Analysis

## When to run

This skill operates in two modes depending on the caller:

- **Generation mode** (called from `prd_planning` Phase 4): Scan the full PRD after all modules are defined. Detect cross-cutting concern candidates, curate with the human, and write the dedicated section into the PRD.
- **Consultation mode** (called from `prd_change` Phase 3): Read the existing Cross-cutting Concerns section. Check if the proposed change touches any listed concern. Report which additional sections must be reviewed.

---

## Generation Mode

### 1. Scan the PRD for candidates

Read the complete PRD and identify cross-cutting concern candidates using these heuristics:

**Heuristic A — Repeated technical terms:**
Scan for technical terms, tool names, library names, or domain concepts that appear in 3 or more distinct sections of the PRD. Examples: a CSS animation library referenced in multiple module features, a video embedding strategy mentioned in content, SEO, and performance sections.

**Heuristic B — Implicit consistency dependencies:**
Identify data or decisions that must be identical across different locations in the PRD. Examples: business name/address/phone (NAP) that appears in visible content AND in structured data (Schema.org); pricing values that appear in both UI descriptions and business rules.

**Heuristic C — Architectural decisions with multi-module impact:**
Flag decisions in Section 5 (Architecture and Stack) that affect the implementation of 2 or more modules. Examples: choice of CSS framework, deploy strategy (SSG vs SSR vs ISR), state management library, API design pattern.

**Heuristic D — Transversal non-functional requirements:**
Identify NFRs from Section 4 that must be applied consistently across all or most modules. Examples: accessibility standards (WCAG level), performance budgets (LCP target), security policies (CSP headers), internationalization requirements.

**Heuristic E — Process meta-decisions:**
Detect decisions about the development/deployment process that affect how multiple modules are built or delivered. Examples: phased deploy strategy (which modules go live first), preview vs production environment rules, feature flag conventions.

For each candidate, record:
- **Name:** Short descriptive label (e.g., "Video embedding strategy", "NAP consistency", "Animation stack")
- **Description:** One sentence explaining what the concern is in this project's context
- **Affected sections:** List of specific PRD section numbers where this concern appears or applies
- **Consistency rules:** Any specific rules beyond "keep synchronized" (e.g., "NAP must be character-identical between visible text and Schema.org JSON-LD")

### 2. Present candidates for human curation

Present ALL detected candidates to the human in a structured format:

```
## Cross-cutting Concern Candidates

I identified [N] potential cross-cutting concerns in the PRD:

### 1. [Name]
**What:** [description]
**Appears in:** Section X.Y, Section X.Y, Section X.Y
**Consistency rule:** [specific rule, or "keep synchronized across all listed sections"]

### 2. [Name]
...

---

**For each candidate, please tell me:**
- ✅ Approve — include as-is
- ❌ Reject — not a real cross-cutting concern for this project
- ✏️ Refine — adjust name, description, sections, or rules
- ➕ Add — any cross-cutting concerns I missed?
```

**Do not proceed until the human confirms the final list.** If the human adds new concerns, validate that they reference real sections in the PRD.

### 3. Generate the Cross-cutting Concerns section

Write the section into the PRD using the template below. Position it **after the document header** (Version, Date, Author, Status) and **before Section 1 (Product Vision)**.

**Template:**

```markdown
## Cross-cutting Concerns

> This section lists the transversal themes of this document. Any modification that
> touches one of these themes requires reviewing ALL affected sections listed below.
> Use these checklists as a mandatory consistency guide during edits.

### [Theme Name]

**Description:** [One sentence explaining the theme in this project's context]

**Affected sections:**
- Section X.Y — [How the theme manifests here, one line]
- Section X.Y — [How the theme manifests here, one line]
- Section X.Y — [How the theme manifests here, one line]

**Consistency rules:**
- [Specific rule, e.g., "NAP must be character-identical in visible content and Schema.org JSON-LD"]
- [Additional rules if applicable]

---

[Repeat for each confirmed concern]
```

**Rules for the generated section:**
- Omit the "Consistency rules" subsection if the only rule is "keep synchronized" — the section header already conveys that
- Each affected section entry must reference a real section number from the PRD
- The one-line description of how the theme manifests must be specific to that section, not generic

### 4. Present the generated section

Show the complete section to the human for final review before writing it to the PRD. This is the last chance to adjust before the section becomes part of the document.

---

## Consultation Mode

Used by `prd_change` to check if a proposed change touches cross-cutting concerns.

### 1. Read the Cross-cutting Concerns section

If the PRD contains a "Cross-cutting Concerns" section, parse it to extract:
- Each concern's name
- Each concern's affected sections list
- Each concern's consistency rules (if any)

If the PRD does **not** contain this section:
- Warn the human: "This PRD has no Cross-cutting Concerns section. Transversal themes may exist but are not tracked. Consider running the cross-cutting-analysis skill to add one."
- Allow the human to continue without it — do not block the change process

### 2. Match the proposed change against concerns

For each cross-cutting concern, check if the proposed change touches:
- Any section listed in the concern's affected sections
- Any keyword or concept that matches the concern's name or description

### 3. Report matches

If the change touches one or more concerns, report:

```
## Cross-cutting Concerns Affected

This change touches [N] cross-cutting concern(s):

### [Concern Name]
The change affects Section X.Y, which is part of this concern.
**All sections that must also be reviewed:**
- Section X.Y — [manifestation]
- Section X.Y — [manifestation]
- Section X.Y — [manifestation]
**Consistency rules to enforce:**
- [rule]
```

This report feeds into the Impact Analysis of `prd_change`, expanding the list of sections that must be checked and potentially modified.

### 4. Detect new concerns

If the proposed change introduces a new theme that appears in 3+ sections but is not listed as a cross-cutting concern, flag it:

"This change introduces '[theme]' which now appears in sections X, Y, and Z. Consider re-running the cross-cutting-analysis skill (generation mode) to update the Cross-cutting Concerns section."
