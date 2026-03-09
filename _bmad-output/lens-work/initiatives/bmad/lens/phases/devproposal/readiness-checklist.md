---
artifact: readiness-checklist
phase: devproposal
initiative: bmad-lens-repodiscovery
author: John (PM)
created: "2026-03-09"
inputDocuments:
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/devproposal/epics.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/devproposal/stories.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/techplan/architecture.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/techplan/tech-decisions.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/businessplan/prd.md
---

# Implementation Readiness Checklist — Repo Discovery (`/discover`)

**Author:** John (PM)
**Date:** 2026-03-09
**Initiative:** bmad-lens-repodiscovery

---

## Summary

| Category | Status | Notes |
|---|---|---|
| Architecture | ✅ Complete | All components specified in architecture.md |
| Technology Decisions | ✅ Complete | All 7 TDs accepted, no Decision Needed items |
| Epic Structure | ✅ Defined | 3 epics, 17 stories |
| Prerequisites | ✅ Met | Governance repo wired; control repo configured |
| Dev Environment | ✅ Ready | VS Code + Copilot, AI dev agent |
| Open Blockers | ✅ None | No unresolved architectural decisions |
| PRD Coverage | ✅ Complete | All FR-1 to FR-8 mapped to stories |

**Readiness verdict:** ✅ READY — DevProposal approved for SprintPlan.

---

## 1. Architecture Completeness

### 1.1 Component Coverage

| Component | Architecture Spec | Story Coverage | Status |
|---|---|---|---|
| PreFlight + InitiativeContextResolver | ✅ Specified | S-005 | ✅ |
| FileSystemScanner | ✅ Specified (interface + rules) | S-006 | ✅ |
| RepoInspector | ✅ Specified | S-007 | ✅ |
| LanguageDetector | ✅ Specified (priority order) | S-013 | ✅ |
| GovernanceWriter | ✅ Specified (schema + rules) | S-008 | ✅ |
| GitOrchestrator | ✅ Specified (branch convention) | S-009 | ✅ |
| ContextGenerator | ✅ Specified (delegated) | S-014 | ✅ |
| StateManager | ✅ Specified (consensus rule) | S-015 | ✅ |
| ReportRenderer | ✅ Specified (columns + format) | S-016 | ✅ |
| Command Wiring | Implied (stubs exist) | S-001 – S-003 | ✅ |

### 1.2 Integration Contracts Verified

| Integration | Contract Defined | Story | Status |
|---|---|---|---|
| governance repo (git operations) | ✅ Pull-before-push, commit message | S-008 | ✅ |
| `bmad-bmm-generate-project-context` | ✅ Inputs: `repo_path`, `language` | S-014 | ✅ |
| `/switch` | ✅ Branch naming convention stable | S-009 | ✅ |
| control repo branching | ✅ No TargetProjects writes | S-009, all stories | ✅ |

### 1.3 Open Architectural Decisions

| TD | Status | Blocking? |
|---|---|---|
| TD-001: Filesystem-only detection | Accepted | No |
| TD-002: Sequential processing | Accepted | No |
| TD-003: Pull-before-push hard gate | Accepted | No |
| TD-004: Control repo branching only | Accepted | No |
| TD-005: Per-repo error isolation | Accepted | No |
| TD-006: Language detection priority | Accepted | No |
| TD-007: Name-keyed upsert with prompt | Accepted | No |

**Result: Zero unresolved TDs. No architectural decisions block story execution.**

---

## 2. PRD → Story Mapping

| PRD Requirement | Story | Covered |
|---|---|---|
| MVP-1: Scan for `.git/` directories | S-006 | ✅ |
| MVP-2: Detect `.bmad/` presence | S-007 | ✅ |
| MVP-3: Update `repo-inventory.yaml` | S-008 | ✅ |
| MVP-4: Control-repo branches for `/switch` | S-009 | ✅ |
| NTH-1: Language detection | S-013 | ✅ |
| NTH-2: `project-context.md` generation | S-014 | ✅ |
| NTH-3: Initiative `language` field update | S-015 | ✅ |
| NTH-4: Table-formatted report | S-016 | ✅ |
| SC-1: Governance completeness | S-008 | ✅ |
| SC-2: Zero data loss (pull-before-push) | S-008 | ✅ |
| SC-3: `/switch` navigability | S-009 | ✅ |
| SC-4: Idempotent re-runs | S-008 | ✅ |
| SC-5: Graceful language fallback | S-013 | ✅ |
| SC-6: Runtime within budget | TD-002 + S-006 | ✅ |
| Journey 1: Standard discovery | S-005 to S-010 | ✅ |
| Journey 2: Re-discovery | S-008 (idempotency) | ✅ |
| Journey 3: Empty folder | S-006 | ✅ |
| Journey 4: Forgotten discovery nudge | Deferred (FR-9 Enhancement) | ⏭️ |

**Journey 4 note:** FR-9 (proactive nudge from downstream workflows) is marked as a deferred Enhancement in the architecture. It is not included in this devproposal scope.

---

## 3. Infrastructure Prerequisites

| Prerequisite | Required by | Status | Action if Missing |
|---|---|---|---|
| `TargetProjects/{domain}/{service}/` exists | S-005, S-006 | ✅ Exists for `bmad/lens/` | Run `/new-service` for new domains |
| governance repo (`lens-governance`) cloned in working directory | S-008 | ✅ Configured in `setup-control-repo.ps1` | Run `/onboard` |
| Control repo (BMAD.Lens) has remote `origin` with push access | S-009 | ✅ Verified in active session | N/A |
| `_bmad-output/lens-work/state.yaml` and initiative config exist | S-005 | ✅ Present for `bmad-lens-repodiscovery` | Run `/init` or restore from branch |
| `lifecycle.yaml` with `language_detection_priority` populated | S-013 | ✅ Present in `bmad.lens.release` | Extend `lifecycle.yaml` |
| `bmad-bmm-generate-project-context` workflow available | S-014 | ✅ Exists in `bmm/workflows/3-solutioning/` | N/A |

---

## 4. Dev Environment

| Item | Value |
|---|---|
| IDE | VS Code with GitHub Copilot |
| Agent | `@lens` (bmad-lens-work module) |
| Implementation target | `bmad.lens.release/_bmad/lens-work/` |
| Dev agent | AI dev agent (Amelia — `bmad-agent-bmm-dev`) |
| Languages/formats | YAML workflow files, Markdown prompt files |
| Testing approach | Smoke test with synthetic fixture (S-011) + adversarial reviews (S-004, S-012, S-017) |
| Reviewer | CrisWeber |
| Branch | `bmad-lens-repodiscovery-medium-devproposal` → `bmad-lens-repodiscovery-medium` |

---

## 5. Story Readiness — Pre-Conditions

| Story | Pre-condition | Met? |
|---|---|---|
| S-001 | module.yaml pattern reviewed | ✅ |
| S-002 | S-001 complete; sibling prompt reviewed | After S-001 |
| S-003 | S-001, S-002 complete; sibling workflow reviewed | After S-001/S-002 |
| S-004 | S-001, S-002, S-003 complete | After S-001–S-003 |
| S-005 | S-003 complete | After S-003 |
| S-006 | S-005 complete | Sequential |
| S-007 | S-006 complete | Sequential |
| S-008 | S-007 complete; governance repo accessible | Sequential |
| S-009 | S-005 (initiative context); parallel with S-008 possible | Semi-parallel |
| S-010 | S-005–S-009 complete | After MVP pipeline |
| S-011 | S-005–S-010 complete; test fixture created | After S-010 |
| S-012 | S-005–S-011 complete | After S-011 |
| S-013 | E-002 complete (S-012 gate passed) | After E-002 |
| S-014 | S-013 complete | Sequential |
| S-015 | S-013 complete | After S-013 |
| S-016 | S-013, S-014, S-015 complete | After all NTH |
| S-017 | S-013–S-016 complete | After E-003 |

---

## 6. Risk Register

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| Governance `git push` fails during smoke test | Low | Medium | S-008 handles push failure gracefully; test explicitly validates error path |
| `bmad-bmm-generate-project-context` workflow API changes | Low | Low | S-014 wraps call in error isolation; NTH so non-blocking |
| Language detection returns wrong language for mixed repos | Medium | Low | `"unknown"` fallback always reachable; TD-006 priority is deterministic |
| Control-repo branch creation race between stories | Low | Low | TD-002: sequential execution; no concurrency |
| Stub files from YOLO edit contain conflicting logic | Medium | Medium | S-002, S-003 explicitly replace (not append) stub content |
| Idempotency prompt blocks batch re-discovery | Medium | Low | Deferred `--force` mode noted in TD-007; not a blocker for MVP |

---

## 7. Definition of Done — DevProposal Phase

- [x] `devproposal-questions.md` completed and committed
- [x] `epics.md` authored with 3 epics (E-001, E-002, E-003)
- [x] `stories.md` authored with 17 stories covering all FRs
- [x] `readiness-checklist.md` authored and all blockers resolved
- [ ] Adversarial review of all three artifacts
- [ ] PR created: `bmad-lens-repodiscovery-medium-devproposal` → `bmad-lens-repodiscovery-medium`
- [ ] PR reviewed by CrisWeber
- [ ] PR merged
- [ ] Initiative config updated: `devproposal.status = pr_pending`
