---
artifact: adversarial-review-report
phase: audience-gate
audience: small-to-medium
initiative: bmad-lens-repodiscovery
mode: party
reviewed_by: [john, winston, mary, sally, bob]
created: "2026-03-09"
verdict: PASS_WITH_NOTES
---

# Adversarial Review Report — Repo Discovery (`/discover`)

**Initiative:** bmad-lens-repodiscovery  
**Gate:** small → medium audience promotion  
**Mode:** Party (multi-agent adversarial review)  
**Verdict:** ✅ PASS_WITH_NOTES

---

## Review Scope

| Artifact | Lead Reviewer | Participants | Focus |
|---|---|---|---|
| product-brief.md | John (PM) | Winston, Sally | Actionable? Buildable? User-centered? |
| prd.md | Winston (Architect) | Mary, Sally | Buildable? Well-researched? UX-aligned? |
| ux-design-specification.md | John (PM) | Winston, Mary | Serves requirements? Technically feasible? Grounded? |
| architecture.md | John (PM) | Mary, Bob | Meets spec? Practical? Sprintable? |

---

## Review 1 — Product Brief

**Lead:** John (PM) | **Panel:** Winston, Sally

### John (PM) — Actionability Check

The product brief is unusually well-scoped for a tooling initiative. The problem statement is concrete, the proposed solution maps 1:1 to the problem steps, and the in/out-of-scope boundaries are crisp. The four user personas have differentiated value statements — not the usual cookie-cutter rows.

**Notes:**
- The "Suggested as next step after `/new-service` (not automatic, not after `/new-feature`)" scoping note is critical. This needs to survive into the PRD and architecture — I see it reflected in FR-9 (passive sensor, deferred), which is correct.
- Success criterion SC-5 ("graceful language fallback") is a non-functional guarantee presented as a success criterion. Accept it — but the story team should make it explicit in DoD, not just in the brief.

**Verdict:** ✅ PASS

### Winston (Architect) — Buildability Check

The brief correctly identifies the six distinct operations (`scan`, `inspect`, `write-governance`, `generate-context`, `create-branches`, `report`) without conflating them. This maps naturally to isolated components. No architectural concerns at this stage.

**Minor gap:** The brief mentions "create switchable branches" but doesn't specify the branch naming schema. This was deferred correctly to architecture — confirmed in `arch.md` as `{initiative_root}-{domain}-{service}-{repo_name}`. Traceable. ✅

**Verdict:** ✅ PASS

### Sally (UX) — User-Centered Check

The journey mapping (4 journeys: standard, re-discovery, empty folder, forgotten discovery) is strong. Journey 3 (empty folder) and Journey 4 (proactive nudge) demonstrate real empathy for failure modes users encounter.

**Note:**
- Journey 4 (forgotten discovery) is marked as "Enhancement — deferred." This is the most failure-prone user state. The UX Design should at least define what the nudge message looks like, even if it's a V2 feature. I see this partially addressed in the UX spec's "Nudge Patterns" section.

**Verdict:** ✅ PASS

### Panel Verdict

> ✅ **PASS** — Product brief is clear, actionable, and user-centered. One advisory: ensure SC-5 (language fallback) DoD is explicit in stories.

---

## Review 2 — PRD

**Lead:** Winston (Architect) | **Panel:** Mary, Sally

### Winston (Architect) — Buildability Check

The PRD's FR table correctly separates MVP (FR-1, FR-2, FR-4, FR-5) from NTH (FR-3, FR-6, FR-7, FR-8) and deferred enhancement (FR-9). This is implementable in a single sprint for MVP. The NFR table (NFR-1 through NFR-5) is specific and measurable — NFR-2 (idempotent) and NFR-3 (pull-before-push) are particularly well-defined.

**Concern flagged:** The PRD defines SC-6 as "Discovery of 10 repos completes within 1 hour." This is a loose constraint for tooling. The architecture correctly identifies sequential scan as sufficient, but the story DoD should capture this as a soft time budget, not a hard gate.

**Verdict:** ✅ PASS

### Mary (Analyst) — Research Quality Check

The PRD's competitive landscape is accurately described as "no alternative exists — greenfield tooling." This is correctly positioned. The user persona table (Admin, Team Lead, Architect, PO) maps to the brief's table consistently — no gaps introduced.

**Note:** The PRD's open question "How should `/discover` interact with `repo-inventory.yaml` if the governance repo is behind?" is a real edge case. The architecture's pull-before-push gate (NFR-3) addresses it. Ensure this flows into stories as an explicit DoD statement for GovernanceWriter.

**Verdict:** ✅ PASS

### Sally (UX) — UX Alignment Check

The PRD user journeys (4 journeys) match the UX Design's flow states. The acceptance criteria do not contradict UX decisions. The PRD's SC-4 ("idempotent re-runs") is reflected in the UX spec's conflict resolution pattern (user prompted on duplicates).

**Minor gap:** The PRD does not specify progress feedback granularity during a 10-repo scan. The UX spec fills this with per-repo progress lines ("✓ discovered: {repo-name}") — but implementers reading only the PRD wouldn't know this. Recommend a cross-reference or inline note.

**Verdict:** ⚠️ PASS_WITH_NOTE — Add a note in the PRD Acceptance Criteria referencing the UX spec for progress feedback design.

### Panel Verdict

> ✅ **PASS_WITH_NOTE** — PRD is well-structured and buildable. Two notes for stories: (1) document pull-before-push DoD for GovernanceWriter; (2) cross-reference UX spec for progress feedback requirements.

---

## Review 3 — UX Design Specification

**Lead:** John (PM) | **Panel:** Winston, Mary

### John (PM) — Requirements Coverage Check

The UX spec covers the full set of user journeys from the brief and PRD. All four journeys (standard, re-discovery, empty folder, forgotten discovery) are reflected. The spec defines the exact output format (table, per-repo progress lines, nudge messages) with sufficient detail for implementation.

**Verdict:** ✅ PASS

### Winston (Architect) — Technical Feasibility Check

The UX spec's interaction model (agent chat, no traditional UI) is consistent with architectural constraints (VS Code Copilot Chat, no separate UI). The conflict resolution dialog ("Repo X already in inventory. Update? [Y/N]") is implementable as a simple `ask` step in the workflow.

**Note:** The "✓ discovered: {repo-name}" per-repo progress output requires sequential per-repo streaming rather than a single final-table output. This is feasible but the stories must explicitly call out that output is incremental, not batched.

**Verdict:** ⚠️ PASS_WITH_NOTE — Stories must specify incremental progress output (not batched) for ReportRenderer.

### Mary (Analyst) — User Research Grounding

The spec is grounded in the well-defined persona set. The empty-folder error message ("No repos found. Did you clone them to the right folder?") is appropriately actionable — not just an error code.

**Verdict:** ✅ PASS

### Panel Verdict

> ✅ **PASS_WITH_NOTE** — UX spec is technically feasible and requirements-aligned. One note: stories must specify incremental output streaming for progress feedback, not a batched final report.

---

## Review 4 — Architecture

**Lead:** John (PM) | **Panel:** Mary, Bob

### John (PM) — Spec Alignment Check

The architecture's component map (8 components: PreFlight, FileSystemScanner, RepoInspector, GovernanceWriter, GitOrchestrator, ContextGenerator, StateManager, ReportRenderer) maps cleanly to the PRD's FR table. MVP components (PreFlight, FileSystemScanner, RepoInspector, GovernanceWriter, GitOrchestrator) are clearly separated from NTH (ContextGenerator, StateManager, ReportRenderer).

The data flow (6-step sequential pipeline with per-repo isolation) is sprintable. The architecture makes a correct call to delegate `project-context.md` generation to `bmad-bmm-generate-project-context` — no re-invention.

**Verdict:** ✅ PASS

### Mary (Analyst) — Practical Implementation Viability

The architecture correctly identifies three risks (monorepo multi-language, empty config repos, governance repo absent) and provides concrete mitigations. The governance pull-before-push pattern is well-specified. The branch naming schema is unambiguous.

**Concern:** The architecture's tech-decisions.md should explicitly record the decision to use sequential (not parallel) per-repo processing. This is mentioned in NFR-1 but should be a named decision (TD-xxx) with explicit rationale — "sequential chosen over parallel because 10 repos at human-agent pace never hits time budget."

**Verdict:** ⚠️ PASS_WITH_NOTE — Add TD-xxx to tech-decisions.md for sequential processing rationale.

### Bob (SM) — Sprintability Check

The architecture is sprint-ready. The MVP/NTH split is clean — MVP fits a single sprint without NTH features. Per-repo error isolation (NFR-4) is explicit, which means story DoD can include isolation without architectural ambiguity.

**One gap:** The architecture does not call out that the `GovernanceWriter` must validate the `repo-inventory.yaml` schema before writing. The PRD mentions schema drift as a risk. This should become an explicit story task or acceptance criterion.

**Verdict:** ⚠️ PASS_WITH_NOTE — Add schema validation story (or AC) for GovernanceWriter; confirm schema source (lifecycle.yaml or governance README).

### Panel Verdict

> ✅ **PASS_WITH_NOTES** — Architecture is solid and sprintable. Three implementation notes for stories: (1) add TD for sequential processing; (2) add GovernanceWriter schema validation AC; (3) confirm NFR-3 pull-before-push as explicit DoD for governance story.

---

## Cross-Cutting Findings

| ID | Finding | Severity | Affects | Resolution |
|---|---|---|---|---|
| AR-1 | SC-5 (language fallback) DoD must be in stories | Advisory | Stories | Explicit DoD: "LanguageDetector returns `unknown`, no exception thrown" |
| AR-2 | Pull-before-push must be explicit DoD for GovernanceWriter story | Advisory | Stories | AC: "governance pull occurs before any write attempt" |
| AR-3 | Progress output is incremental (per-repo), not batched | Advisory | Stories | AC: "one output line per repo as discovered, not summary-only" |
| AR-4 | Add TD for sequential-vs-parallel processing decision | Advisory | tech-decisions.md | Add TD-006 in devproposal phase |
| AR-5 | GovernanceWriter schema validation | Advisory | Stories | Story or AC: validate `repo-inventory.yaml` schema before writing |

---

## Verdict Summary

| Artifact | Verdict | Notes |
|---|---|---|
| product-brief.md | ✅ PASS | SC-5 DoD in stories |
| prd.md | ✅ PASS_WITH_NOTES | Pull-before-push DoD + progress feedback cross-ref |
| ux-design-specification.md | ✅ PASS_WITH_NOTES | Incremental output streaming in stories |
| architecture.md | ✅ PASS_WITH_NOTES | TD for sequential; GovernanceWriter schema validation |

**Overall Gate Verdict:** ✅ **PASS_WITH_NOTES**

> All four planning artifacts are coherent, well-scoped, and implementation-ready. No blockers.  
> Five advisory notes (AR-1 through AR-5) are carried forward as story acceptance criteria or tech-decisions additions in the DevProposal phase. None of these findings require rework of existing artifacts.

**Authorization:** DevProposal phase (medium audience) may proceed.
