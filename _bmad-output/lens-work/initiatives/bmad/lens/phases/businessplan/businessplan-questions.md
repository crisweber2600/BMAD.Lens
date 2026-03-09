---
artifact: businessplan-questions
phase: businessplan
initiative: bmad-lens-repodiscovery
scope: "PRD + UX Design"
mode: batch
created: "2026-03-09"
status: processed
processed_at: "2026-03-09"
outputs:
  - prd.md
  - ux-design-specification.md
---

# BusinessPlan — Batch Questionnaire
## Initiative: Repo Discovery (`/discover` command)

> **Instructions:** Answer each question below your answer marker (`→`). Leave any question blank to skip (optional questions are marked `[optional]`). When complete, reply "done" and I will process your answers into the PRD and UX Design documents.
>
> **Context carried forward from PrePlan:**  The product-brief is fully approved. Many questions below reference it. You only need to confirm, refine, or expand — not re-explain what is already clearly defined.

---

## SECTION 1 — PRD: Vision & Executive Summary

**1.1** The product-brief defines the product as: *"A `/discover` command that completes the post-clone lifecycle after `/new-service`, detecting cloned repos, updating governance inventory, generating `project-context.md`, creating initiative branches, and reporting results."*

Does this remain the correct one-sentence product definition, or would you like to refine it?

→ yes

---

**1.2** What is the **north-star vision** for `/discover`? (The ideal end state — what does success look like in 6–12 months?)

→ repos are discovered after new service is run.

---

**1.3** What is the **primary differentiator** of `/discover` compared to alternatives (e.g., manual processes, other tooling)?

→ there isn't an alternative.

---

## SECTION 2 — PRD: Success Metrics

The product-brief lists acceptance criteria. This section defines **measurable quality gates**.

**2.1** What is an acceptable **execution time** for `/discover` on a typical service folder (e.g., 1–5 repos)?

→ 

---

**2.2** What **language detection accuracy** is acceptable? (e.g., "must correctly detect language for ≥90% of repos that have build files")

→ 

---

**2.3** What **governance update reliability** is required? (e.g., "zero data loss — if governance push fails, discovery must not report success")

→ zero data loss. pull then push if needed. 

---

**2.4** Are there any **adoption or usage metrics** to track after release? (e.g., "used by ≥80% of new-service flows within 30 days") `[optional]`

→ 

---

## SECTION 3 — PRD: User Personas & Journeys

**3.1** The product-brief identifies 4 user types: Admin, Team Lead, Architect, Product Owner. Are there any **additional personas** or **edge-case users** to add? (e.g., solo developer, CI/CD pipeline, new team member first time setup)

→ nope

---

**3.2** For the **Admin persona**: Walk through the ideal `/discover` journey. What do they do before the command? What do they see during execution? What do they verify after?

→ after the service is created. when repos are cloned they can be discovered.

---

**3.3** For the **Architect persona**: What specific information in the discovery report matters most to them? What would make them trust the output?

→ after the service is created. when repos are cloned they can be discovered.

---

**3.4** What is the most common **failure scenario** a user will hit? How should they recover? (e.g., "ran `/discover` before cloning — what happens?")

→ they don't run discover after cloning repos. this should be looked for. 

---

**3.5** Is there a **multi-user / team scenario** where two people run `/discover` on the same service simultaneously? How should conflicts be handled? `[optional]`

→ no

---

## SECTION 4 — PRD: Domain & Compliance

**4.1** This tool operates in the **developer-tooling / workflow-automation** domain. Are there any **compliance or security constraints** that apply? (e.g., no secrets in outputs, no writing outside workspace boundaries, audit logging)

→ no

---

**4.2** The product-brief states detection is filesystem-only with no GitHub API calls. Is this a **firm constraint** or a preference that could change? (e.g., "could we add optional GitHub API enrichment in v2?")

→ correct there's no need for api calls.

---

## SECTION 5 — PRD: Scoping & MVP

**5.1** The product-brief defines a clear in/out-of-scope boundary. For the **MVP**, which of these in-scope items are **must-have** vs **nice-to-have**?

Rate each: **M** = Must Have | **N** = Nice to Have | **D** = Defer

| Feature | Priority |
|---|---|
| Scan `TargetProjects/{domain}/{service}/` for `.git/` directories | M|
| Language detection (build files → extensions → `unknown`) | N|
| BMAD config presence detection (`.bmad/` dir) |M |
| `repo-inventory.yaml` update + commit + push | M|
| `project-context.md` generation per repo |N |
| Initiative branch creation for `/switch` | M|
| Initiative config `language` field update | N|
| Human-readable discovery report | N|

→ 

---

**5.2** Is there a **phased rollout** plan? (e.g., "v1: detect + report only; v2: add governance update; v3: add project-context generation")

→ no

---

**5.3** What is the **minimum viable output** a user must see for `/discover` to be considered "done"? (e.g., "at minimum, show what was found — even if governance update fails")

→ not an option.

---

## SECTION 6 — PRD: Functional Requirements

**6.1** **Language detection specifics:** The product-brief references `lifecycle.yaml`'s `language_detection_priority` (steps 2–4). What are those priority steps? List the exact build-file heuristics or confirm where to find them.

→ no

---

**6.2** **Governance update schema:** What fields does each entry in `repo-inventory.yaml` require? (e.g., `name`, `path`, `language`, `bmad_configured`, `domain`, `service`)

→ all of them.

---

**6.3** **`project-context.md` generation:** The workflow `bmad-bmm-generate-project-context` is referenced. Does it need any inputs beyond the repo path and detected language for this feature?

→ no

---

**6.4** **Branch naming convention for `/switch`:** What branch name format should initiative-aware branches use in the discovered repos? (e.g., `{initiative-root}-{repo-name}`, or same branch as control repo)

→ it's going to be the same as the control repo. this will not impact target project repos. it references branches in the control repo.

---

**6.5** **Report format:** What sections should the discovery report display?
- Suggested: repos found, languages detected, BMAD config present/absent, governance update status, project-context status, branches created, any failures/warnings

→ 

---

**6.6** **Idempotency:** What happens if `/discover` is run twice on the same service? Should it:
- (a) Skip repos already in inventory
- (b) Update existing entries
- (c) Warn and ask

→ C

---

**6.7** **Error recovery:** If the governance push fails mid-discovery (e.g., network error), should `/discover`:
- (a) Roll back all changes locally
- (b) Continue with remaining repos and report partial success
- (c) Stop immediately and report failure

→ 2

---

## SECTION 7 — PRD: Non-Functional Requirements

**7.1** **Performance:** Is there a maximum acceptable runtime for discovery over a service with, say, 10 repos?

→ 1 hour

---

**7.2** **Reliability:** Should `/discover` be fully idempotent (safe to run multiple times with identical outcomes)?

→ yes

---

**7.3** **Security:** Any restrictions on what the tool can read/write? (e.g., must not access files outside `TargetProjects/` or the governance repo)

→ no

---

**7.4** **Maintainability:** Should language detection patterns be externalized (e.g., in `lifecycle.yaml` or a CSV) so new languages can be added without code changes?

→ no

---

**7.5** **Observability:** Should the command emit structured output that could be parsed by other tools or scripts? (e.g., JSON summary at end of output) `[optional]`

→ 

---

## SECTION 8 — UX: Command Interaction Design

> **Note:** `/discover` is an **agent command** (VS Code Copilot Chat), not a traditional web/mobile UI. UX questions here focus on the **command interaction experience** — output formatting, feedback patterns, error communication, and agent personality.

**8.1** What is the **single most important interaction** to get right in `/discover`? (e.g., "the moment when the user says 'done' and discovers wait → result hand-off must feel instant and clear")

→ 

---

**8.2** What should the command interaction feel like emotionally? (e.g., "confident and fast", "careful and transparent", "minimal and trustworthy")

→ 

---

**8.3** How verbose should the **progress output** be during discovery?
- (a) Silent until done (show only final report)
- (b) Minimal (one line per repo: "✓ discovered: repo-name")
- (c) Detailed (show each step: detecting language, updating inventory, etc.)
- (d) Configurable

→ b

---

**8.4** How should **errors and warnings** be visually differentiated in the output? (e.g., `❌ Error:`, `⚠️ Warning:` prefixes, or plain text, or color-coded)

→ 

---

## SECTION 9 — UX: Output & Report Design

**9.1** What format should the **discovery report summary** use? (e.g., a table, a list with icons, a tree view, plain prose)

→ a table

---

**9.2** Should the report be **conversational** (agent explains findings) or **structured** (data-first, concise)?

→ 

---

**9.3** If the discovery found **zero repos** (empty folder), what should the agent say? (e.g., "No repos found. Did you clone them to the right folder? Expected: TargetProjects/bmad/lens/")

→ No repos found. Did you clone them to the right folder?

---

**9.4** Should there be a **"what next" nudge** at the end of a successful discovery? (e.g., "All done! You can now use `/switch` to navigate to any discovered repo.")

→ correct

---

## SECTION 10 — UX: Agent Persona & Tone

**10.1** Which agent persona runs `/discover`? (The current @lens agent, or a sub-persona like the architect Winston for the technical analysis portion?)

→ 

---

**10.2** For the **waiting prompt** ("Clone your repos to `TargetProjects/bmad/lens/` and reply 'done' when ready") — what tone should this have? (e.g., helpful/instructive, brief/directive, friendly/encouraging)

→ helpful/instructive

---

**10.3** Should the agent ever **ask clarifying questions** mid-discovery, or should it always complete silently and report at the end?

→ complete silently

---

## SECTION 11 — UX: Accessibility & Constraints

**11.1** Are there any **terminal/chat rendering constraints** to be aware of? (e.g., avoid tables if they render poorly, prefer emoji over color for status)

→ no

---

**11.2** Should the command output be **screen-reader friendly**? (e.g., avoid pure icon/emoji indicators without text labels)

→ no

---

**11.3** Any **character or length constraints** on report output? (e.g., keep report under 20 lines for readability in chat) `[optional]`

→ no

---

## SECTION 12 — Additional Input

**12.1** Is there anything the product-brief **got wrong or is missing** that should be addressed in the PRD?

→ 

---

**12.2** Any **open questions or decisions** you'd like the PRD to flag as unresolved?

→ 

---

**12.3** Any **constraints from the lens-work architecture** (e.g., lifecycle.yaml schema, branch naming rules, governance repo structure) that will directly impact implementation? `[optional]`

→ 

---

*When you've answered the questions above, reply with "done" and I will generate the PRD and UX Design documents.*
