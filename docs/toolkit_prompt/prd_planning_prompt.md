# PRD Planning Prompt

Use this prompt with any AI assistant (chat or planning mode) BEFORE the session 0 bootstrap.
The output is the PRD that feeds the entire project structure.

---

## Prompt

```
We are creating a PRD (Product Requirements Document) for a new project. This document will be the central product reference — everything built must align with it.

I will describe the project and you will ask questions to understand it completely before writing. DO NOT write the PRD until you have asked all questions and I have answered.

### Process:

**Phase 1 — Understanding (you ask, I answer):**
Ask questions about:
- The problem the product solves
- Who the users are (personas)
- What they do today without the product
- Differentiators vs alternatives
- Modules/functional areas
- Constraints (deadline, budget, compliance, platform)
- Preferred stack (or if you should suggest one)
- Business model (SaaS, internal tool, marketplace, etc.)
- External integrations needed
- What is out of scope for the MVP

Ask in blocks of 3-5 questions. Wait for my answers before proceeding.

**Phase 2 — Draft (you write, I review):**
After understanding everything, write the PRD following the structure below. I will review and request adjustments.

**Phase 3 — Finalization:**
After my approval, generate the final document in markdown.

### PRD Structure:

# [Product Name] — Product Requirements Document

**Version:** 1.0.0
**Date:** [date]
**Author:** [name]
**Status:** Draft → Under Review → Approved

---

## 1. Product Vision

### 1.1 Problem
[What pain/problem does this product solve? For whom?]

### 1.2 Solution
[How does the product solve the problem? What is the value proposition?]

### 1.3 Target Audience
[Personas with: fictional name, profile, pain points, how they would use the product]

### 1.4 Competitive Differentiator
[What exists today? Why is this product better/different?]

---

## 2. Scope

### 2.1 In Scope (MVP)
[List of modules/features that WILL be built in the first version]

### 2.2 Out of Scope (future)
[Features NOT in the MVP but planned for later]

### 2.3 Constraints
[Deadline, budget, compliance (GDPR, etc.), platform (web, mobile, both), performance]

---

## 3. Functional Requirements

### 3.1 [Module A]

**Objective:** [what this module does]

**Features:**
- [F1] [description] — Priority: High/Medium/Low
- [F2] [description] — Priority: High/Medium/Low

**Business rules:**
- [BR1] [specific rule the system must follow]
- [BR2] [rule]

**Main flow:**
[Step-by-step of the most common user flow in this module]

**Acceptance criteria:**
Verifiable criteria that the AI agent will use to validate the implementation automatically.
In session 0, these criteria will propagate to the backlog with executable tags.

Guide: focus on WHAT to verify (expected result), not HOW to implement.
Every criterion must have 3 parts: **action** (what to do), **expected result** (what success looks like), and **failure signal** (how to know it truly passed).

- `BUILD:` The module compiles with zero errors
- `VERIFY:` [page/command] → [user action] → [expected visible result with specifics]
- `QUERY:` [exact query or description] → [exact expected value]
- `MANUAL:` [specific aspect requiring human judgment]

Note: The `REVIEW:` tag (code pattern checks) is NOT used in the PRD. It is added automatically in the backlog as an engineering concern, not a product concern.

Good examples (STRONG — action + result + failure signal):
- `VERIFY:` /clients → click "New Client" → form renders with fields: name (required), phone (optional), email (required). Submit empty → validation errors on name and email. Submit with valid data → redirect to /clients/[id], new client visible in list.
- `QUERY:` After creating client with name='Test', email='t@t.com' → `SELECT name, email FROM clients ORDER BY created_at DESC LIMIT 1` → ('Test', 't@t.com')
- `VERIFY:` /clients with no data → shows empty state message "No clients registered" (not a blank page, not a loading spinner)
- `VERIFY:` (API) POST /api/users with {"name":"Test","email":"t@t.com"} → 201 Created, body has "id" (UUID). GET /api/users → array with 1 item, name === "Test". POST with empty body → 422 with validation errors.
- `VERIFY:` (CLI) Run `tool process --input data.csv` → exit code 0, stdout contains "Processed 100 records". Run with missing file → exit code 1, stderr contains "File not found".

Bad examples (WEAK — vague, no failure signal):
- "Works correctly" (what is correctly? how to know?)
- "Data saves to database" (which data? which table? which value?)
- "Nice looking screen" (subjective — use MANUAL with specific visual criteria)
- "Form appears" (which fields? what states? what happens on submit?)

### 3.2 [Module B]
[Same structure: Objective, Features, Business rules, Main flow, Acceptance criteria]

### 3.3 [Module C]
[Same structure]

[Repeat for each module]

---

## 4. Non-Functional Requirements

### 4.1 Performance
[Acceptable response times, capacity, concurrency]

### 4.2 Security
[Authentication, authorization, data protection, compliance]

### 4.3 Availability
[Expected uptime, backup strategy, disaster recovery]

### 4.4 Scalability
[Growth expectations, MVP limits, when to scale]

---

## 5. Architecture and Stack

**Note:** This section defines high-level choices and justifications (the WHY of the stack). Implementation details (specific patterns, code conventions, technical decisions during development) go in project.md and the main config file (CLAUDE.md / GEMINI.md), not here.

### 5.1 Suggested Stack
[Frontend, backend, database, auth, deploy, CI/CD — with justification]

### 5.2 External Integrations
[APIs, third-party services, webhooks]

### 5.3 Data Model (high level)
[Main entities and relationships — not detailed schema, but macro view]

---

## 6. Design and UX

### 6.1 Platform
[Responsive web, native mobile, PWA, desktop?]

### 6.2 Visual Direction
[Dark/light, style (minimalist, colorful, corporate), visual references]

### 6.3 Accessibility
[Accessibility requirements (WCAG level, contrast, screen readers)]

---

## 7. Business Model

### 7.1 Monetization
[SaaS with plans, internal tool, freemium, marketplace, etc.]

### 7.2 Plans (if SaaS)
[Free, Pro, Enterprise — what each includes]

### 7.3 Success Metrics
[KPIs: MAU, MRR, churn, NPS, etc.]

---

## 8. High-Level Roadmap

### MVP (Phase 1)
[Minimum features to launch]

### Phase 2
[Post-launch expansion features]

### Phase 3
[Advanced features / integrations / scale]

---

## 9. Risks and Dependencies

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| [risk 1] | High/Medium/Low | High/Medium/Low | [how to mitigate] |

---

## Changelog

**IMPORTANT:** The AI agent uses TWO checks to detect PRD changes automatically:
1. **Changelog version** (fast, reliable) — always increment when editing
2. **Content comparison** (fallback) — compares PRD structure vs project docs

The version check is primary. Content check is a safety net for structural changes (modules added/removed) but may miss subtle changes (internal business rules). **Always update the changelog.**

To modify this PRD after approval, use the `prd_change_prompt.md` which guides the full process of classification → investigation → impact → drafting → validation.

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0.0 | [date] | Initial version | [name] |
```

---

## Tips for the Process

**When answering the AI's questions:**
- Be specific about business rules (e.g., "commission is fixed per service, not percentage" saves hours of rework)
- Say what is OUT of scope — as important as what is in scope
- If unsure about the stack, ask for a suggestion based on the product type
- If you have visual references (sites, apps), mention them

**When reviewing the draft:**
- Check that each module has clear business rules (not just vague features)
- Check that flows make sense from the user's perspective
- Check that priorities are correct (High = MVP mandatory)
- Add constraints you forgot to mention

**After approval:**
- Save as `assets/docs/prd.md` in the project
- This document will be read by the AI agent in session 0
- Update the changelog whenever scope changes

---

## When to Update the PRD

The PRD is a **living document** that changes when the PRODUCT changes:

| Event | PRD action |
|-------|-----------|
| New feature requested | Add to Functional Requirements + update Roadmap + changelog |
| Feature removed | Move to "Out of scope" + changelog |
| Business rule changed | Update in module rules + changelog |
| Target audience changed | Update Personas + review priorities + changelog |
| Stack changed | Update section 5 + changelog |
| Product pivot | PRD v2.0 — rewrite affected sections + changelog |
| Bug fixed | DO NOT update (goes in project.md) |
| Technical decision | DO NOT update (goes in project.md) |
| Module implemented | DO NOT update (goes in project.md) |

**Rule of thumb:** If the change affects WHAT to build → PRD. If it affects HOW to build → project.md.

### If you edit the PRD manually (without the change prompt)

Update the changelog. It is the fastest and most reliable way to ensure propagation.

If you forget, the AI agent has a fallback: it compares PRD structure vs project docs. This catches structural changes (modules added/removed) but may miss subtle ones (internal rule changes within an existing module).

**Rule:** After ANY manual edit, add a changelog line:
```
| [version] | [date] | [what changed] | [your name] |
```
