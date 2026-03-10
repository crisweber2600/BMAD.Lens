---
artifact: readiness-checklist
phase: devproposal
initiative: bmad-lens-repodiscovery
author: John (PM)
agent: john
created: "2026-03-10"
source_artifacts:
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/preplan/product-brief.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/businessplan/prd.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/techplan/architecture.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/devproposal/epics.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/devproposal/stories.md
status: READY
---

# Implementation Readiness Checklist — Repo Discovery (`/discover`)

**Author:** John (PM)  
**Phase:** DevProposal  
**Initiative:** bmad-lens-repodiscovery  
**Date:** 2026-03-10  
**Overall Status:** ✅ READY

---

## Section 1 — Requirements Completeness

| # | Criterion | Status | Notes |
|---|---|---|---|
| RC-1 | All FR-1 through FR-9 traced to epics/stories | ✅ | FR-1→S1.2, FR-2→S1.3, FR-3→S5.1, FR-4→S2.1–S2.4, FR-5→S3.1, FR-6→S5.2, FR-7→S5.3, FR-8→S4.2, FR-9→deferred |
| RC-2 | MVP scope clearly separated from NTH | ✅ | E1–E4 = MVP; E5 = NTH |
| RC-3 | All success criteria (SC-1 through SC-6) covered | ✅ | SC-1→S2.3, SC-2→S2.1/S2.4, SC-3→S3.1, SC-4→S2.3, SC-5→S5.1+AR-1, SC-6→NFR-1 (no blocking story needed) |
| RC-4 | All NFRs traced to stories or accepted constraints | ✅ | NFR-1→workflow design, NFR-2→S2.3, NFR-3→S2.1/AR-2, NFR-4→S1.3/S2.4/S3.1, NFR-5→S5.1/AR-1 |
| RC-5 | All adversarial review notes (AR-1 to AR-5) resolved | ✅ | AR-1→S5.1 DoD, AR-2→S2.1 AC, AR-3→S1.2 AC, AR-4→S4.1 TD-006 note, AR-5→S2.2 story |

---

## Section 2 — Architecture Alignment

| # | Criterion | Status | Notes |
|---|---|---|---|
| AA-1 | All architecture components have corresponding stories | ✅ | FileSystemScanner→S1.2, RepoInspector→S1.3, GovernanceWriter→S2.1–S2.4, GitOrchestrator→S3.1, LanguageDetector→S5.1, ContextGenerator→S5.2, StateManager→S5.3, ReportRenderer→S4.2 |
| AA-2 | Data flow (6-step sequential pipeline) reflected in story dependencies | ✅ | S1.1→S1.2→S1.3→{S2.1, S3.1}→S4.1 |
| AA-3 | No GitHub API calls introduced in stories | ✅ | All detection is local filesystem |
| AA-4 | Per-repo error isolation covered in all persistence stories | ✅ | S1.3, S2.4, S3.1 all have explicit error isolation ACs |
| AA-5 | pull-before-push constraint preserved | ✅ | S2.1 enforces pull gate; S2.1 AC: "governance pull occurs before any write attempt" |
| AA-6 | Branch naming schema matches architecture decision | ✅ | `{initiative_root}-{domain}-{service}-{repo_name}` confirmed in S3.1 |
| AA-7 | Sequential processing rationale documented | ✅ | AR-4 addressed in S4.1 AC — TD-006 note inline |

---

## Section 3 — Sprint Readiness

| # | Criterion | Status | Notes |
|---|---|---|---|
| SR-1 | All MVP stories (S1.1–S4.3) are independently deliverable within budget (XS–L) | ✅ | Largest story: S4.1 (L) = complete workflow.md, suitable for a single sprint task |
| SR-2 | Story dependencies are acyclic | ✅ | E1→E2, E1→E3, {E2,E3}→E4; E5 parallel |
| SR-3 | No story requires simultaneous multi-repo infra changes | ✅ | All changes are to lens-work module (single repo: bmad.lens.release) |
| SR-4 | All stories have testable acceptance criteria | ✅ | ACs use specific, verifiable language ("does not throw", "outputs { }", "exit 0") |
| SR-5 | NTH stories (E5) are strictly isolated from MVP | ✅ | E5 stories have no MVP story depending on them |
| SR-6 | Partial delivery (MVP without NTH) is coherent and shippable | ✅ | MVP provides complete /discover capability without language detection or context generation |

---

## Section 4 — UX & Interaction Completeness

| # | Criterion | Status | Notes |
|---|---|---|---|
| UX-1 | All UX journeys (Journey 1–4) covered | ✅ | Journey 1→S1.2/S4.2, Journey 2→S2.3, Journey 3→S1.2 (empty folder), Journey 4→deferred (FR-9 enhancement) |
| UX-2 | Incremental progress output specified | ✅ | S1.2 AC: "Outputs '✓ discovered: {repo_name}' as discovered (incremental, not batched)" (AR-3) |
| UX-3 | Error messages are actionable | ✅ | S1.1, S2.1, S2.4, S3.1 all have specific, actionable error message text |
| UX-4 | End-of-run summary table specified | ✅ | S4.2: Columns Repo, Language, BMAD, Governance, Branch |
| UX-5 | "What next?" nudge included | ✅ | S4.2: "You can now use `/switch` to navigate to any discovered repo." |
| UX-6 | Conflict resolution dialog specified | ✅ | S2.3: "Repo {X} already in inventory. Update? [Y/N]" with explicit Y→overwrite, N→skip |

---

## Section 5 — Risk Coverage

| Risk | From Product Brief | Mitigation in Stories | Status |
|---|---|---|---|
| Monorepo multi-language | Multiple languages per repo | S5.1: pick highest file-count language; note "multi-language repo" | ✅ |
| Build files absent | Config/doc repos with no build files | S5.1: falls through to extension analysis → `unknown` (no crash) | ✅ |
| Governance repo not cloned | Preflight gate fails | S1.1: fail with actionable message "Run `/onboard`" | ✅ |
| `repo-inventory.yaml` schema drift | Schema mismatch on write | S2.2: validate before any write; fail with diff | ✅ |
| User clones repos to wrong folder | Zero repos found | S1.2: empty-folder prompt + re-scan flow | ✅ |

---

## Section 6 — Open Items

| ID | Item | Type | Owner | Resolution |
|---|---|---|---|---|
| OI-1 | TD-006: Sequential processing decision must be added to tech-decisions.md | Advisory (AR-4) | Dev (S4.1) | Inline note in S4.1 AC; add TD-006 during implementation |
| OI-2 | Schema source for `repo-inventory.yaml` validation | Decision needed | PM/Architect | Options: (a) lifecycle.yaml schema block, (b) governance README. Confirm before S2.2 implementation. |
| OI-3 | Journey 4 (proactive nudge from downstream workflows) remains deferred | Deferred FR-9 | PM | Enhancement scope; acceptable for V2 |

---

## Overall Assessment

**Verdict:** ✅ **READY FOR SPRINT PLANNING**

The `/discover` initiative has:
- Complete requirements coverage (FR-1–FR-9, SC-1–SC-6, NFR-1–NFR-5)
- Architecture-aligned component breakdown (8 components → 14 stories)
- Clear MVP/NTH separation (11 MVP stories, 3 NTH stories)
- All adversarial review findings (AR-1–AR-5) resolved in story ACs
- Actionable acceptance criteria for all stories
- No unresolved blockers; 2 advisory open items (OI-1, OI-2) resolvable during implementation

**Recommended sprint sequence:** E1 → E2 → E3+E4 → (E5 optional)
