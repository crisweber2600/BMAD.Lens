---
initiative: upgrade-cjki9q
initiative_name: "Lens-Work Module Architecture Upgrade"
domain: Lens
service: lens-work
phase: sprintplan
agent: Bob (SM)
date: "2026-02-25"
inputDocuments:
  - Docs/lens/lens-work/feature/upgrade/epics.md
  - Docs/lens/lens-work/feature/upgrade/dependency-map.md
  - Docs/lens/lens-work/feature/upgrade/architecture.md
  - Docs/lens/lens-work/feature/upgrade/prd.md
  - Docs/lens/lens-work/feature/upgrade/stories/S-001.md through S-040.md
---

# Sprint Plan — Lens-Work Module Architecture Upgrade

**Scrum Master:** Bob (SM)
**Initiative:** upgrade-cjki9q
**Date:** 2026-02-25
**Total Scope:** 10 epics, 40 stories, 139 story points
**Sprint Model:** 4 sprints (AI-speed — each sprint ≈ hours, not weeks)
**Execution Context:** TargetProjects (GitFlow branch model)

---

## Sprint Overview

| Sprint | Theme | Stories | SP | Focus |
|--------|-------|---------|-----|-------|
| Sprint 1 | Foundation | 12 | 37 | Safety gate + State Machine + early engines |
| Sprint 2 | Core Engines | 12 | 38 | Git Engine + Constitution + Discovery start |
| Sprint 3 | Integration | 11 | 39 | Router + Discovery + Checklist + Recovery |
| Sprint 4 | Workflows & Validation | 5 | 25 | Phase workflows + Dogfood + Validation |
| **Total** | | **40** | **139** | |

---

## Sprint 1 — Foundation (37 SP)

**Sprint Goal:** Establish safety baseline and state management foundation. Remove dangerous auto-advance. Stand up state machine with dual-write contract, begin constitution loading and audience branch creation.

**Entry Criteria:** Architecture approved (PR #15), epics/stories approved (PR #16), all planning artifacts cascade-merged to large audience.

### Stories

| # | Story | Epic | SP | Dependencies | Dev Notes |
|---|-------|------|----|-------------|-----------|
| 1 | S-001 | E-001 | 3 | — | P0 Safety. Audit all workflows for auto-advance patterns |
| 2 | S-002 | E-001 | 2 | S-001 | Add PR-gate enforcement to all phase exits |
| 3 | S-003 | E-002 | 5 | — | state.yaml read/write with v2 schema |
| 4 | S-004 | E-002 | 5 | — | Initiative config CRUD |
| 5 | S-006 | E-002 | 3 | — | Event log append (JSONL) |
| 6 | S-005 | E-002 | 3 | S-003, S-004 | Dual-write contract enforcement |
| 7 | S-007 | E-002 | 5 | S-003, S-004, S-005 | State divergence detection |
| 8 | S-013 | E-004 | 3 | — | Constitution file loading (4-level) |
| 9 | S-008 | E-003 | 3 | S-003 | Audience branch creation |
| 10 | S-024 | E-007 | 3 | S-003 | Command→workflow routing table |
| 11 | S-017 | E-005 | 3 | S-004 | Artifact path resolution |
| 12 | S-018 | E-005 | 3 | S-004 | Initiative discovery (scan) | ??? - stretch goal

### Execution Order

```
Parallel Group A (no deps):
  S-001 (P0), S-003, S-004, S-006, S-013

Sequential after Group A:
  S-002 → after S-001
  S-005 → after S-003 + S-004
  S-008 → after S-003
  S-024 → after S-003
  S-017 → after S-004
  S-018 → after S-004

Sequential after above:
  S-007 → after S-003 + S-004 + S-005
```

### Sprint 1 Exit Criteria

- [ ] Zero auto-advance patterns in any workflow (S-001, S-002)
- [ ] state.yaml v2 schema read/write works (S-003)
- [ ] Initiative config CRUD works (S-004)
- [ ] Dual-write contract enforced (S-005)
- [ ] State divergence detection works (S-007)
- [ ] Event log append works (S-006)
- [ ] Constitution files can be loaded from 4 levels (S-013)
- [ ] Audience branches can be created (S-008)
- [ ] Routing table maps commands to workflows (S-024)
- [ ] Artifact paths resolve correctly (S-017)

### Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| State Machine delays | Blocks 6 downstream epics | Start first, no dependencies — maximize parallelism |
| Auto-advance patterns deeply embedded | Safety gate takes longer | Time-box audit; accept partial removal with documented debt |

---

## Sprint 2 — Core Engines (38 SP)

**Sprint Goal:** Complete Git Engine, Constitution Engine, and begin Discovery + Checklist engines. All foundational skills operational.

**Entry Criteria:** Sprint 1 complete. State Machine + Constitution loading operational.

### Stories

| # | Story | Epic | SP | Dependencies | Dev Notes |
|---|-------|------|----|-------------|-----------|
| 1 | S-009 | E-003 | 5 | S-008 | Phase branch lifecycle |
| 2 | S-011 | E-003 | 3 | S-008 | Branch naming validation |
| 3 | S-010 | E-003 | 5 | S-009 | PR creation (GitHub MCP + fallback) |
| 4 | S-012 | E-003 | 5 | S-008, S-009, S-010 | Cascade merge for audience promotion |
| 5 | S-014 | E-004 | 5 | S-013 | Additive merge algorithm (set-union) |
| 6 | S-015 | E-004 | 3 | S-014 | Gate validation (tracks, artifacts, reviewers) |
| 7 | S-016 | E-004 | 2 | S-013, S-014 | /constitution display command |
| 8 | S-019 | E-005 | 3 | S-018, S-003 | /switch command |
| 9 | S-020 | E-005 | 4 | S-018 | /onboard flow (4-step) |
| 10 | S-021 | E-006 | 3 | S-015 | Checklist schema and gate logic |
| 11 | S-025 | E-007 | 5 | S-003, S-004, S-015 | Precondition validation chain |
| 12 | S-034 | E-008 | 4 | S-003, S-004, S-006, S-008 | /new (initiative creation) | ??? - stretch goal if capacity allows

### Execution Order

```
Parallel Group A (Sprint 1 deps met):
  S-009, S-011, S-014, S-019, S-020, S-034

Sequential after Group A:
  S-010 → after S-009
  S-015 → after S-014
  S-016 → after S-013 + S-014
  S-021 → after S-015
  S-025 → after S-003 + S-004 + S-015

Sequential after above:
  S-012 → after S-008 + S-009 + S-010
```

### Sprint 2 Exit Criteria

- [ ] Phase branches can be created and managed (S-009)
- [ ] Branch names validated against patterns (S-011)
- [ ] PRs created via GitHub MCP with manual fallback (S-010)
- [ ] Cascade merge for audience promotions works (S-012)
- [ ] Constitution additive merge produces deterministic results (S-014)
- [ ] Gate validation blocks on missing artifacts/reviewers (S-015)
- [ ] /constitution command displays resolved constitution (S-016)
- [ ] /switch command works across initiatives (S-019)
- [ ] /onboard flow completes in ≤5 interactions (S-020)
- [ ] Checklist schema and gate logic operational (S-021)
- [ ] Precondition validation chain works (S-025)

### Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Git MCP PR creation fragility | PR creation fails | Manual fallback implemented from day 1 (S-010) |
| Cascade merge conflicts | Block audience promotions | Test early with real branches from Sprint 1 |

---

## Sprint 3 — Integration (39 SP)

**Sprint Goal:** Complete Router Engine integration, finish Discovery and Checklist engines, implement Recovery & Sync. All components are integrated — system is feature-complete except phase workflows.

**Entry Criteria:** Sprint 2 complete. All foundational engines operational.

### Stories

| # | Story | Epic | SP | Dependencies | Dev Notes |
|---|-------|------|----|-------------|-----------|
| 1 | S-022 | E-006 | 2 | S-017, S-021 | Artifact existence checks |
| 2 | S-023 | E-006 | 3 | S-006, S-021 | Gate decision recording |
| 3 | S-026 | E-007 | 5 | S-017, S-004 | Agent context injection |
| 4 | S-027 | E-007 | 3 | S-003, S-004, S-018 | /status command (3-line + verbose) |
| 5 | S-028 | E-007 | 5 | S-025 | Gate feedback error messages |
| 6 | S-035 | E-009 | 3 | S-003, S-007, S-009 | /sync (remote-wins reconciliation) |
| 7 | S-036 | E-009 | 3 | S-035 | /fix (3-category repair) |
| 8 | S-037 | E-009 | 2 | S-006, S-009 | State reconstruction from event log + git |
| 9 | S-029 | E-008 | 3 | S-009, S-024, S-025, S-026 | /preplan workflow (Mary → product-brief) |
| 10 | S-030 | E-008 | 3 | S-029 | /businessplan workflow (John+Sally → PRD) |
| 11 | S-031 | E-008 | 3 | S-030 | /techplan workflow (Winston → architecture) |

### Execution Order

```
Parallel Group A (Sprint 2 deps met):
  S-022, S-023, S-026, S-027, S-035, S-037

Sequential after Group A:
  S-028 → after S-025
  S-036 → after S-035
  S-029 → after S-009 + S-024 + S-025 + S-026

Sequential after above:
  S-030 → after S-029
  S-031 → after S-030
```

### Sprint 3 Exit Criteria

- [ ] Artifact existence checks operational (S-022)
- [ ] Gate decisions recorded in event log (S-023)
- [ ] Agent context injection works (S-026)
- [ ] /status command shows structured output (S-027)
- [ ] Gate feedback error messages follow UX contract (S-028)
- [ ] /sync command works (remote-wins reconciliation) (S-035)
- [ ] /fix command detects and repairs 3 categories (S-036)
- [ ] State reconstruction from event log + git works (S-037)
- [ ] /preplan workflow end-to-end (S-029)
- [ ] /businessplan workflow end-to-end (S-030)
- [ ] /techplan workflow end-to-end (S-031)

### Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Router integration complexity | Delays phase workflows | Early skeleton from Sprint 2 (S-024+S-025), incremental integration |
| Phase workflow chaining | Tight coupling between workflows | Each workflow is independently testable |

---

## Sprint 4 — Workflows & Validation (25 SP)

**Sprint Goal:** Complete remaining phase workflows (/devproposal, /sprintplan), validate entire system through dogfood usage, constitution stress testing, and gate enforcement testing.

**Entry Criteria:** Sprint 3 complete. First 3 phase workflows operational, all engines integrated.

### Stories

| # | Story | Epic | SP | Dependencies | Dev Notes |
|---|-------|------|----|-------------|-----------|
| 1 | S-032 | E-008 | 5 | S-031, S-012 | /devproposal workflow (John → epics+stories) |
| 2 | S-033 | E-008 | 3 | S-032 | /sprintplan workflow (Bob → sprint-status) |
| 3 | S-038 | E-010 | 3 | S-029→S-033 | Dogfood: complete initiative through all phases |
| 4 | S-039 | E-010 | 3 | S-013, S-014, S-015 | Constitution stress test (multi-level merge) |
| 5 | S-040 | E-010 | 2 | S-025, S-028 | Gate enforcement + idempotency tests |
| | | | **(9)** | | Buffer for carry-over from Sprint 3 |

### Execution Order

```
Sequential:
  S-032 → after S-031 + S-012
  S-033 → after S-032

Parallel after S-033:
  S-038 (dogfood — requires all phase workflows)
  S-039 (constitution stress test — deps already met)
  S-040 (gate enforcement — deps already met)
```

### Sprint 4 Exit Criteria

- [ ] /devproposal workflow end-to-end (S-032)
- [ ] /sprintplan workflow end-to-end (S-033)
- [ ] Dogfood initiative completes through all phases (S-038)
- [ ] Constitution stress test passes (S-039)
- [ ] Gate enforcement + idempotency tests pass (S-040)
- [ ] All 40 stories completed or documented as carry-over

### Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Sprint 3 carry-over | Less capacity for validation | 9 SP buffer allocated |
| Dogfood reveals structural issues | Rework required | This is expected — dogfood IS the test |

---

## Story Assignment Summary

| Story | Sprint | Epic | SP | Status |
|-------|--------|------|----|--------|
| S-001 | 1 | E-001 | 3 | ready |
| S-002 | 1 | E-001 | 2 | ready |
| S-003 | 1 | E-002 | 5 | ready |
| S-004 | 1 | E-002 | 5 | ready |
| S-005 | 1 | E-002 | 3 | ready |
| S-006 | 1 | E-002 | 3 | ready |
| S-007 | 1 | E-002 | 5 | ready |
| S-008 | 1 | E-003 | 3 | ready |
| S-013 | 1 | E-004 | 3 | ready |
| S-017 | 1 | E-005 | 3 | ready |
| S-018 | 1 | E-005 | 3 | ??? - stretch |
| S-024 | 1 | E-007 | 3 | ready |
| S-009 | 2 | E-003 | 5 | ready |
| S-010 | 2 | E-003 | 5 | ready |
| S-011 | 2 | E-003 | 3 | ready |
| S-012 | 2 | E-003 | 5 | ready |
| S-014 | 2 | E-004 | 5 | ready |
| S-015 | 2 | E-004 | 3 | ready |
| S-016 | 2 | E-004 | 2 | ready |
| S-019 | 2 | E-005 | 3 | ready |
| S-020 | 2 | E-005 | 4 | ready |
| S-021 | 2 | E-006 | 3 | ready |
| S-025 | 2 | E-007 | 5 | ready |
| S-034 | 2 | E-008 | 4 | ??? - stretch |
| S-022 | 3 | E-006 | 2 | ready |
| S-023 | 3 | E-006 | 3 | ready |
| S-026 | 3 | E-007 | 5 | ready |
| S-027 | 3 | E-007 | 3 | ready |
| S-028 | 3 | E-007 | 5 | ready |
| S-029 | 3 | E-008 | 3 | ready |
| S-030 | 3 | E-008 | 3 | ready |
| S-031 | 3 | E-008 | 3 | ready |
| S-035 | 3 | E-009 | 3 | ready |
| S-036 | 3 | E-009 | 3 | ready |
| S-037 | 3 | E-009 | 2 | ready |
| S-032 | 4 | E-008 | 5 | ready |
| S-033 | 4 | E-008 | 3 | ready |
| S-038 | 4 | E-010 | 3 | ready |
| S-039 | 4 | E-010 | 3 | ready |
| S-040 | 4 | E-010 | 2 | ready |

---

## Definition of Done (All Stories)

1. **Code complete** — implementation matches acceptance criteria
2. **Tests pass** — unit tests for the story's scope
3. **No regressions** — existing tests still pass
4. **Story file updated** — status changed from `ready` → `done`, actual SP recorded
5. **PR merged** — code reviewed and merged to epic branch
6. **Event logged** — story completion recorded in event-log.jsonl

## Sprint Ceremonies (AI-Speed)

Since this is AI-speed development (sprints in hours, not weeks), ceremonies are lightweight:

| Ceremony | Timing | Duration | Notes |
|----------|--------|----------|-------|
| Sprint Planning | Sprint start | ~5 min | Review stories, confirm priority, identify blockers |
| Story Kickoff | Per story | ~1 min | Load story file, confirm AC, check dependencies |
| Story Review | Per story | ~2 min | Verify AC, update status, PR |
| Sprint Review | Sprint end | ~5 min | Demo completed stories, update sprint-status |
| Retro | Sprint end | ~3 min | What worked, what didn't, adjustments |

## Cross-Phase Artifact Flow

```
PrePlan (Mary)           → product-brief.md
  ↓ context
BusinessPlan (John+Sally) → prd.md
  ↓ context
TechPlan (Winston)       → architecture.md, tech-decisions.md
  ↓ context
DevProposal (John)       → epics.md, stories/, dependency-map.md
  ↓ context
SprintPlan (Bob)         → sprint-status.md (THIS DOCUMENT)
  ↓ context
Dev (Amelia)             → feature branches in TargetProjects
```

## Target Project Setup

**Repository:** TargetProjects/lens/lens-work/bmad.lens.src
**Branching Model:** GitFlow
**Main Branch:** main
**Integration Branch:** develop
**Branch Pattern:** feature/{story-id} → feature/{epic-id} → develop

### Pre-Dev Checklist

- [ ] `develop` branch exists and is clean
- [ ] Epic feature branches created (feature/E-001 through feature/E-010)
- [ ] CI/CD pipeline configured (if applicable)
- [ ] Dev environment setup documented

---

## Notes from Bob (SM)

### Sprint Allocation Rationale

1. **Sprint 1 maximizes parallelism** — 5 foundation stories have zero dependencies and can execute concurrently. The Safety Gate (P0) runs in parallel since it has no dependency on anything else.

2. **Sprint 2 is engine-heavy** — Git Engine and Constitution Engine are the two pillars that everything else rests on. Getting cascade merge (S-012) done here de-risks Sprint 3.

3. **Sprint 3 is the integration sprint** — Router + first 3 phase workflows prove the system works end-to-end. Recovery/sync is also here because it depends on state + git engines being complete.

4. **Sprint 4 is deliberately light** — only 16 SP of new work + 9 SP buffer. The remaining 2 phase workflows + validation stories are straightforward given all infrastructure is done. Buffer absorbs Sprint 3 carry-over.

### Key Dependencies to Watch

- **S-003 (state.yaml)** is the most-depended-on story — 8 downstream stories need it. Prioritize this.
- **S-025 (precondition validation)** is the Router Engine bottleneck — it needs state + config + gates.
- **S-012 (cascade merge)** is complex and blocks nothing in Sprint 2, but validates a critical architectural choice.

### Velocity Expectation

At AI-speed with Amelia (Developer), expect ~35 SP per sprint. Sprint 1 (37 SP) and Sprint 3 (39 SP) are slightly above, but parallelism allows it. Sprint 4 (25 SP) is intentionally low for validation focus.

---

*Generated during SprintPlan phase by Bob (SM) for initiative upgrade-cjki9q.*
*Source: epics.md, dependency-map.md, architecture.md (TechPlan), all 40 story files.*
