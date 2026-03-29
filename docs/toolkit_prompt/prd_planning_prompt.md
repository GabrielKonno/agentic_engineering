# PRD Planning Prompt

Use this prompt with any AI assistant (chat or planning mode) BEFORE the session 0 bootstrap.
The output is the PRD that feeds the entire project structure.

---

## Prompt

```
We are creating a PRD (Product Requirements Document) for a new project. This document will be the central product reference — everything built must align with it.

I will describe the project. You will act as a product co-creator — not just an interviewer filling out a form. Your role is to:
- Extract maximum detail from my answers (dig deeper, ask follow-ups, challenge vague statements)
- Proactively suggest ideas, features, modules, architectural patterns, and edge cases based on what you learn
- Build the document incrementally as sections are confirmed — never accumulate everything for the end

DO NOT write the full PRD at the end. Build it progressively as each phase completes.

---

### How to Ask Questions

1. Ask 3-5 questions per round. Wait for my answers before continuing.
2. After each round, analyze the answers for:
   - Ambiguities (words like "maybe", "probably", "something like")
   - Implicit assumptions (things I assumed you know but did not state)
   - Missing details (features mentioned but not described)
   - Contradictions with earlier answers
3. Build the next round on what was just learned. Drill into ambiguities first — depth over breadth.
4. If I give a vague answer, say: "Can you be more specific about [aspect]? For example, [concrete example of what you need]."
5. Never ask a question whose answer is already implied by a previous answer.
6. For each business rule I state, immediately propose a verifiable criterion: "So the acceptance criterion would be: VERIFY: [specific test]. Correct?"

---

### Proactive Suggestions

You are a product co-creator, not just a scribe. Throughout the process:

1. **After Phase 1** (Discovery): suggest at least one competitive opportunity or differentiator I have not mentioned.
2. **After Phase 2** (Architecture): suggest at least one architectural pattern or technical approach that fits the product characteristics (caching, event-driven, background jobs, multi-tenancy, etc.).
3. **During Phase 3** (Deep Dive): for each module, suggest at least one feature, edge case, or business rule improvement.
4. **Before Phase 5** (Finalization): review the complete document and suggest cross-cutting concerns that may be missing (logging, audit trail, notification system, analytics, rate limiting, etc.).

For each suggestion: explain WHY you think it adds value, then ask "Would you like to include this?" If yes, ask the follow-up questions needed to define it fully. If no, move on.

---

### Session Recovery

If a partial PRD already exists (from a previous session or context break):
1. Read the existing document
2. Identify which sections are complete and which are still skeleton/empty
3. Summarize what exists: "I see sections 1, 2, 5, 7, 9 are complete. Modules A and B in section 3 are detailed, but modules C and D are still skeleton. I will continue with the Deep Dive for module C."
4. Resume from where the document left off — do not re-ask questions about completed sections.

---

### Phase 1 — Discovery (broad product understanding)

Understand the problem space, users, market, and constraints. This is the broadest phase.

Ask about (adapt order based on the conversation — follow what is most interesting):
- The problem the product solves and who has it
- Who the users are (initial persona sketches with pain points)
- What they do today without the product (workarounds, competitors)
- Differentiators vs alternatives
- Business model direction (SaaS, internal tool, marketplace, etc.)
- Hard constraints (deadline, budget, compliance, platform)
- What is explicitly out of scope for the MVP

**Mirror Technique:** After 2-3 rounds, summarize your understanding back to me in 3-5 sentences: "Here is what I understand so far: [summary]. Is this correct? What am I missing?" This forces alignment and reveals implicit assumptions.

**Exit:** You can articulate the product vision, who it serves, why it is different, and what the boundaries are. I confirm the summary.

**Incremental write:** After I confirm, write the PRD file with:
- Document header (product name, version 1.0.0, date, author, status)
- Section 1 (Product Vision — Problem, Solution, Target Audience, Differentiator)
- Section 2 (Scope — In Scope MVP, Out of Scope, Constraints)
- Section 7 (Business Model — Monetization, Plans, Success Metrics)
- Section 9 (Risks and Dependencies)

Present what you wrote and proceed to Phase 2.

---

### Phase 2 — Architecture (structural skeleton)

Define the product's structural skeleton: modules, dependencies, stack, integrations.

Ask about:
- Functional modules / areas of the product
- **Module dependencies:** "Which modules depend on which? What must exist before another can work?"
- Preferred stack (or ask me if I want a suggestion — if suggesting, explain WHY for each choice based on the product)
- External integrations mapped to specific modules (not just a global list: "Which module calls Stripe? What data does it send?")
- High-level data model: main entities and key relationships across modules
- Non-functional requirements: performance targets, security needs, availability, scalability expectations
- Design/UX direction: platform (web, mobile, PWA), visual style, accessibility requirements

**Build order proposal:** After understanding dependencies, propose an implementation build order and confirm it with me.

**Exit:** Module list, dependency graph, stack decision, integration points per module, and build order confirmed.

**Incremental write:** After I confirm, update the PRD file with:
- Section 4 (Non-Functional Requirements)
- Section 5 (Architecture and Stack — including 5.4 Build Order)
- Section 6 (Design and UX)
- Section 8 (High-Level Roadmap — MVP phases derived from build order)
- Section 3 skeleton (module headers with objectives only — details come in Phase 3)

Present what you wrote and proceed to Phase 3.

---

### Phase 3 — Deep Dive (per-module detail extraction)

This is the most critical phase. For each module (in build order), conduct a focused deep dive.

**Per-module interview cycle:**

Pick one module. Ask about:
1. **Features** and their priorities (High = MVP mandatory, Medium = MVP desired, Low = future)
2. **Business rules** — explicit rules the system must enforce. For every rule, immediately propose a verifiable acceptance criterion and confirm.
3. **Main flow** — step-by-step of the most common user journey in this module
4. **Edge cases** — after the happy path, systematically ask:
   - "What happens when there is no data yet?" (empty state)
   - "What happens if the operation fails?" (error handling)
   - "What are the limits?" (boundary values, maximums, rate limits)
   - "What if two users do the same thing at the same time?" (concurrency)
   - "What if an external service is unavailable?" (integration failures)
5. **Data model** — "What data does this module create, read, update, delete? Key fields and types? Status/state fields? Relationships to other modules' data?"
6. **Integration points** — which external APIs or other modules it interacts with, what data is exchanged, what happens if unavailable
7. **Module constraints** — specific performance targets, authorization rules (who can do what), expected data volume

After completing a module's interview, present a summary:
"**Module [X] summary:** [features], [N business rules], [main flow], [N edge cases], [data entities], [integration points]. Correct?"

**Incremental write:** After I confirm each module, immediately write its complete Section 3.X into the document. Do this BEFORE moving to the next module — each module must be persisted so no information is lost if the session breaks.

Continue until all modules are complete.

**Exit:** Every module has full detail; I confirmed each; all Section 3.X written to the document.

---

### Phase 4 — Review & Consolidation

The document already exists from phases 1-3. This phase is a polish pass, not a rewrite.

1. Re-read the complete document
2. **Quality gate:** Every module must have at least:
   - 1 `BUILD:` criterion
   - 1 `VERIFY:` criterion with specific page/command, action, and expected result
   - 1 `QUERY:` criterion if the module touches persistent data
3. **Consistency check:**
   - All module dependencies reference modules that exist in the document
   - All integration points reference real services
   - Build order matches the dependency graph
   - Roadmap phases align with build order
   - Data model entities are consistent across modules (no conflicting field definitions)
4. Fix any inconsistencies found
5. Add the Changelog section

Present the consolidated document for review.

---

### Phase 5 — Finalization

Guide my review with specific checkpoints:
1. Are all modules accounted for? Any missing?
2. Are business rules correct and complete?
3. Are edge cases realistic and well-covered?
4. Is the build order feasible? Dependencies make sense?
5. Are acceptance criteria specific enough to validate automatically?

**Final suggestions:** Before finalizing, review the complete document and suggest any cross-cutting concerns that may be missing (logging, audit trail, notification system, analytics, etc.).

**Bootstrap readiness statement:** After my final approval, confirm: "This PRD has [N] modules, [N] business rules, [N] acceptance criteria ([N] BUILD, [N] VERIFY, [N] QUERY, [N] MANUAL). Every module has dependencies, data model, and edge cases defined. It is ready for bootstrap."

Generate the final version with the Changelog entry.

---

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

**Dependencies:** [which modules must exist before this one can work | "none"]

**Features:**
- [F1] [description] — Priority: High/Medium/Low
- [F2] [description] — Priority: High/Medium/Low

**Business rules:**
- [BR1] [specific rule the system must follow]
- [BR2] [rule]

**Data model (module-owned entities):**
- [Entity]: [key fields, types, constraints] — [relationships to other entities]
- Status/state fields: [if applicable, with valid transitions]

**Main flow:**
[Step-by-step of the most common user flow in this module]

**Edge cases:**
- Empty state: [what happens when no data exists yet]
- Error state: [what happens on failure — validation, server error, timeout]
- Boundary: [limits, maximums, what happens at the boundary]
- Concurrent: [what if two users do the same thing simultaneously]

**Integration points:** (omit if none)
- [Service/Module]: [data exchanged, direction, fallback if unavailable]

**Module constraints:** (omit if no specific constraints beyond project-wide)
- Performance: [specific targets for this module]
- Authorization: [who can do what — roles, permissions]
- Volume: [expected data scale]

**Acceptance criteria:**
Verifiable criteria that the AI agent will use to validate the implementation automatically.
Every criterion must have 3 parts: **action** (what to do), **expected result** (what success looks like), and **failure signal** (how to know it truly passed — not a false positive).

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
[Same structure: Objective, Dependencies, Features, Business rules, Data model, Main flow, Edge cases, Integration points, Module constraints, Acceptance criteria]

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

**Note:** This section defines high-level choices and justifications (the WHY of the stack). Implementation details (specific patterns, code conventions, technical decisions during development) go in project.md and CLAUDE.md, not here.

### 5.1 Suggested Stack
[Frontend, backend, database, auth, deploy, CI/CD — with justification for each choice]

### 5.2 External Integrations
[APIs, third-party services, webhooks — consolidated view; per-module detail is in Section 3]

### 5.3 Data Model (high level)
[Consolidated entity-relationship overview — how entities from different modules relate to each other. Not detailed schema, but macro view.]

### 5.4 Build Order
[Ordered implementation sequence derived from Section 3 module dependencies]

1. [Module] — depends on: none
2. [Module] — depends on: [1]
3. [Module] — depends on: [1, 2]
[Continue for all modules]

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
[Minimum features to launch — aligned with Build Order]

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

**During Phase 1 (Discovery):**
- Be specific about business rules (e.g., "commission is fixed per service, not percentage" saves hours of rework)
- Say what is OUT of scope — as important as what is in scope
- If unsure about the stack, ask for a suggestion based on the product type
- If you have visual references (sites, apps), mention them

**During Phase 2 (Architecture):**
- Think about module dependencies — which parts of the product can only work after others exist
- If you have preferences about tech choices, state them with reasons
- Mention any external services you already have accounts/contracts with

**During Phase 3 (Deep Dive):**
- For each module, think about the "first use" experience — what does the user see when there is no data yet?
- Think about error scenarios — what can go wrong? How should the system respond?
- When the AI proposes acceptance criteria, evaluate honestly: is the criterion specific enough that someone could verify it with no ambiguity?

**About proactive suggestions:**
- The AI will suggest ideas, features, and patterns — evaluate them honestly. Good suggestions can save significant design time later. But say "no" without hesitation to anything that doesn't fit.
- Pay special attention to edge case suggestions — these often catch issues that would only surface during implementation.

**When reviewing the draft (Phase 4-5):**
- Check that each module has clear business rules (not just vague features)
- Check that flows make sense from the user's perspective
- Check that priorities are correct (High = MVP mandatory)
- Verify acceptance criteria have all 3 parts (action + expected result + failure signal)
- Add constraints you forgot to mention

**About incremental writing:**
- The AI writes sections as they are confirmed — do not wait until the end
- This protects against session breaks and context limitations
- Review each section when presented; it is easier to fix early than to review a massive document at the end
- If a session breaks, start a new one and point the AI to the partial PRD — it will resume where it left off

**After approval:**
- Save as `assets/docs/prd.md` in the project
- This document will be read by the AI agent in session 0
- Update the changelog whenever scope changes

---

## When to Update the PRD

The PRD is a **living document** that changes when the PRODUCT changes:

| Event | PRD action |
|-------|-----------|
| New feature requested | Add to Functional Requirements + update Roadmap + Build Order + changelog |
| Feature removed | Move to "Out of scope" + update dependency graph + changelog |
| Business rule changed | Update in module rules + update acceptance criteria + changelog |
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
