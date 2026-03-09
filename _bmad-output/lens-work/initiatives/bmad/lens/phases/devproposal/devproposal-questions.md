---
artifact: devproposal-questions
phase: devproposal
initiative: bmad-lens-repodiscovery
scope: "Epics + Stories + Readiness"
mode: batch
created: "2026-03-09"
status: pending
inputDocuments:
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/businessplan/prd.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/techplan/architecture.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/techplan/tech-decisions.md
---

# DevProposal — Batch Questionnaire
## Initiative: Repo Discovery (`/discover` command)

> **Instructions:** Answer each question below your answer marker (`→`). Leave any question blank to skip (optional questions are marked `[optional]`). When complete, reply "done" and I will process your answers into the Epics, Stories, and Readiness Checklist documents.
>
> **Context carried forward from TechPlan:** Architecture is fully defined with 7 components (PreFlight, FileSystemScanner, RepoInspector, GovernanceWriter, GitOrchestrator, ContextGenerator, StateManager, ReportRenderer). MVP components are FR-1, FR-2, FR-4, FR-5. NTH components are FR-3, FR-6, FR-7, FR-8.

---

## SECTION 1 — Epic Structure

This section determines how to group work into epics. The architecture has 7 components across 4 MVP and 4 NTH features.

**1.1** The architecture identifies a natural MVP boundary: `PreFlight + Scanner + Inspector + GovernanceWriter + GitOrchestrator` (FR-1, FR-2, FR-4, FR-5). Should this be a **single epic** ("Core Discovery") or **split into multiple epics** (e.g., "Scanning & Inspection" / "Governance & Branching")?

→ 

---

**1.2** The NTH features are: LanguageDetector (FR-3), ContextGenerator (FR-6), StateManager (FR-7), ReportRenderer (FR-8). Should these be:
- (A) One "Enhancements" epic
- (B) Grouped into "Detection & Reporting" (FR-3, FR-8) + "Context Generation" (FR-6, FR-7)
- (C) Each its own epic
- (D) Deferred entirely to a future initiative — not included in devproposal

→ 

---

**1.3** The workflow currently has stub files at `bmad.lens.release/_bmad/lens-work/workflows/router/discover/workflow.md` and `bmad.lens.release/_bmad/lens-work/prompts/lens-work.discover.prompt.md`. Should there be a dedicated epic for **wiring the command route** (updating module.yaml, creating the full prompt, creating the workflow), separate from the functional implementation?

→ 

---

**1.4** Should the readiness checklist and epic adversarial review be tracked as explicit stories within an epic, or handled outside the epic structure? `[optional]`

→ 

---

## SECTION 2 — Story Breakdown (MVP: Core Discovery)

The MVP pipeline is: user runs `/discover` → scan → inspect → governance update → branch creation → report.

**2.1** For **PreFlight + InitiativeContextResolver**: What is the acceptance criterion for a passing preflight? (e.g., "governance repo present and reachable, initiative config loaded with domain+service, scan path exists")

→ 

---

**2.2** For **FileSystemScanner** (FR-1): What is the definition of "done" for this story?
- Suggested: "Given a scan path, enumerate all subdirectories containing a `.git/` directory, return list of repo objects with path and name, return empty list (not error) when no repos found"

→ 

---

**2.3** For **RepoInspector** (FR-2): What is the definition of "done"?
- Suggested: "Given a repo path, detect `.bmad/` presence (true/false), attempt language detection (FR-3) if implementation available, else return `unknown`"

→ 

---

**2.4** For **GovernanceWriter** (FR-4): What is the definition of "done"?
- Must include: pull-before-push, idempotency check (warn+prompt on existing entry), upsert, commit+push
- On push failure: report error but do NOT mark repo as "complete" in the discovery report

→ 

---

**2.5** For **GitOrchestrator** (FR-5): What is the definition of "done"?
- Suggested: "Create a branch in the control repo named `{initiative_root}-{domain}-{service}-{repo_name}` for each discovered repo, skip if branch already exists"

→ 

---

**2.6** For the **discovery report output**: The architecture defines ReportRenderer as NTH (FR-8), but the MVP still needs some output. What is the minimum acceptable output for the MVP?
- (A) One-line status per repo ("✓ discovered: {repo-name}")
- (B) A structured table at the end of execution
- (C) Silent — only errors printed

→ 

---

## SECTION 3 — Story Breakdown (NTH Features)

Skip this section entirely by writing `skip` on the first `→` if you chose D in question 1.2.

**3.1** For **LanguageDetector** (FR-3): What is the priority detection order in `lifecycle.yaml`? (e.g., build file → file extension → `unknown`)

→ 

---

**3.2** For **ContextGenerator** (FR-6): The architecture delegates to `bmad-bmm-generate-project-context` workflow. What inputs does that workflow need? Is it acceptable to call it via `invoke` in the discover workflow, or does it need a separate story to integrate it?

→ 

---

**3.3** For **StateManager** (FR-7): When the initiative config `language` field gets updated from `unknown` to the detected language, should this only happen if **all repos in the service** agree on one language, or should it update with the most common language, or should it remain `unknown` if any conflict exists?

→ 

---

**3.4** For **ReportRenderer** (FR-8): The PRD defines the report as a table. Columns suggested: `Repo | Language | BMAD | Governance | Branch | Context | Status`. Confirm or modify these columns. `[optional]`

→ 

---

## SECTION 4 — Story Sequencing & Dependencies

**4.1** The architecture specifies a sequential per-repo pipeline. Should the epic stories also be sequenced strictly (one story done before next starts), or can stories for different components run in parallel by different contributors?

→ 

---

**4.2** Is there any story that **cannot start** until a specific external dependency is resolved? (e.g., "GovernanceWriter story requires governance repo to be wired in setup-control-repo.ps1 first")

→ 

---

**4.3** Should there be a **smoke-test story** at the end of the MVP epic that validates end-to-end flow with a known fixture? If yes: what is the fixture? (e.g., "a test folder with 2 fake `.git/` directories")

→ 

---

## SECTION 5 — Story Boundaries & Exclusions

**5.1** The PRD sets idempotency behavior as: if `/discover` is run twice, prompt user to confirm overwrite. Should the interaction design for this prompt be part of the GovernanceWriter story, or a separate "Idempotency" story?

→ 

---

**5.2** The architecture excludes branches in TargetProjects repos (only control repo branching). Is this exclusion a hard constraint that should be in every story's DoD, or documented once in the epic overview?

→ 

---

**5.3** Error recovery: the architecture specifies per-repo error isolation. Should there be explicit test scenarios for each failure mode (governance push fail, branch creation fail, scan path not found) as acceptance criteria, or as a separate test story?

→ 

---

## SECTION 6 — Implementation Readiness

**6.1** List any **infrastructure** that must be in place before a developer (or AI dev agent) can start the first story. (e.g., "governance repo must be cloned and in setup-control-repo.ps1", "TargetProjects/{domain}/{service}/ must exist")

→ 

---

**6.2** Are there any **open architectural decisions** that would block story execution? Check the tech-decisions.md for any Decision Needed items.

→ 

---

**6.3** What is the **dev environment** for implementation? (e.g., "VS Code + Copilot, AI agent will implement as prompt/workflow files in bmad.lens.release")

→ 

---

**6.4** Who is the **reviewer** for the devproposal PR? (e.g., CrisWeber, auto-merge OK if adversarial passes)

→ 

---

**6.5** Is there a **target sprint** or time constraint for completing the first MVP epic? `[optional]`

→ 

---
