---
initiative: upgrade-cjki9q
initiative_name: "Lens-Work Module Architecture Upgrade"
domain: Lens
service: lens-work
phase: devproposal
agent: John (PM)
date: "2026-02-25"
inputDocuments:
  - Docs/lens/lens-work/feature/upgrade/product-brief.md
  - Docs/lens/lens-work/feature/upgrade/prd.md
  - Docs/lens/lens-work/feature/upgrade/architecture.md
  - Docs/lens/lens-work/feature/upgrade/tech-decisions.md
---

# Epics — Lens-Work Module Architecture Upgrade

**Author:** John (PM)
**Date:** 2026-02-25
**Initiative:** upgrade-cjki9q
**Phase:** DevProposal

---

## Epic Summary

| Epic | Title | Priority | Component(s) | Stories | Est. (SP) |
|------|-------|----------|-------------- |---------|-----------|
| E-001 | Safety Gate (P0) | P0 | All workflows | 2 | 5 |
| E-002 | State Machine Foundation | P1 | State Machine | 5 | 21 |
| E-003 | Git Engine | P1 | Git Engine | 5 | 21 |
| E-004 | Constitution Engine | P1 | Constitution Engine | 4 | 13 |
| E-005 | Discovery Engine | P2 | Discovery Engine | 4 | 13 |
| E-006 | Checklist Engine | P2 | Checklist Engine | 3 | 8 |
| E-007 | Router Engine & Agent Integration | P1 | Router Engine | 5 | 21 |
| E-008 | Phase Workflows | P1 | Router + All | 6 | 21 |
| E-009 | Recovery & Sync | P2 | State Machine + Git | 3 | 8 |
| E-010 | Validation & Dogfood | P2 | All | 3 | 8 |
| **Total** | | | | **40** | **139** |

---

## E-001: Safety Gate (P0 — Gap G)

**Priority:** P0 — Safety-critical
**Gap:** G (Dangerous Auto-Advance)
**Components:** All phase workflows
**FRs:** FR22
**FT:** FT1 (Planning artifacts must exist and be reviewed before code is written)

### Description

Remove all auto-advance patterns from existing phase workflows. This is the highest-priority work because auto-advance directly violates FT1 — the system's fundamental guarantee.

### Acceptance Criteria

- Every phase transition requires an explicit PR merge — zero auto-advance paths remain
- Audit of all existing workflow files confirms no automatic phase progression
- Phase completion detection is passive (user-triggered, per §8.4)

### Stories

| Story | Title | SP |
|-------|-------|----|
| S-001 | Audit and remove auto-advance patterns | 3 |
| S-002 | Add PR-gate enforcement to all phase exits | 2 |

---

## E-002: State Machine Foundation

**Priority:** P1 — Foundation
**Gap:** A (Competing Lifecycles), D (State Drift)
**Components:** State Machine (§3.2.2)
**FRs:** FR12, FR13, FR14, FR15, FR16
**NFRs:** NFR1, NFR2, NFR3
**Build Order:** 1 (no dependencies)

### Description

Implement the two-file state system with enforced dual-write contract and append-only event log. This is the foundational component — all other components depend on reliable state management.

### Acceptance Criteria

- state.yaml and initiative config schemas are aligned per §4.2
- Every state mutation updates both files (dual-write contract enforced)
- Event log appends structured JSONL entries per §4.3 schema
- State reconstruction from event-log + git is possible per NFR2
- Divergence detection works (state vs. initiative config mismatch detected)

### Stories

| Story | Title | SP |
|-------|-------|----|
| S-003 | Implement state.yaml read/write with v2 schema | 5 |
| S-004 | Implement initiative config CRUD | 5 |
| S-005 | Implement dual-write contract enforcement | 3 |
| S-006 | Implement event log append (JSONL) | 3 |
| S-007 | Implement state divergence detection | 5 |

---

## E-003: Git Engine

**Priority:** P1 — Foundation
**Gap:** A (Competing Lifecycles), B (Muddled Size/Audience)
**Components:** Git Engine (§3.2.3)
**FRs:** FR6, FR7, FR8, FR9, FR10, FR11
**NFRs:** NFR5, NFR8
**Build Order:** 2 (depends on State Machine)

### Description

Implement all branch creation, commit, push, and PR operations following the two-tier branch model (audience branches + phase branches) with flat hyphen-separated naming.

### Acceptance Criteria

- Can create audience branches (small/medium/large) at initiative initialization
- Can create phase branches from audience branches when a phase starts
- Can create PRs: phase→audience (phase completion) and audience→audience (promotion)
- Branch naming follows flat hyphen pattern per TD-003
- PR creation works via GitHub MCP; manual fallback on failure per §8.1
- Branch name validated against platform MAX_PATH limits

### Stories

| Story | Title | SP |
|-------|-------|----|
| S-008 | Implement audience branch creation | 3 |
| S-009 | Implement phase branch lifecycle | 5 |
| S-010 | Implement PR creation (GitHub MCP + fallback) | 5 |
| S-011 | Implement branch naming validation | 3 |
| S-012 | Implement cascade merge for audience promotion | 5 |

---

## E-004: Constitution Engine

**Priority:** P1 — Foundation
**Gap:** None (new capability)
**Components:** Constitution Engine (§3.2.4)
**FRs:** FR17, FR18, FR19, FR20, FR21, FR21b, FR21c
**NFRs:** NFR7
**Build Order:** 2 (parallel with Git Engine; depends on State Machine)

### Description

Implement constitution loading from the four-level LENS hierarchy, additive merge with set-union semantics, and gate validation at all transition points.

### Acceptance Criteria

- Can load constitutions from org/domain/service/repo hierarchy
- Additive merge produces deterministic results per FR18
- Can validate track permissions, required artifacts, and required reviewers
- `/constitution` command displays resolved constitution per FR21b
- Default behavior: missing levels contribute empty set; no constitution = all gates pass

### Stories

| Story | Title | SP |
|-------|-------|----|
| S-013 | Implement constitution file loading (4-level) | 3 |
| S-014 | Implement additive merge algorithm (set-union) | 5 |
| S-015 | Implement gate validation (tracks, artifacts, reviewers) | 3 |
| S-016 | Implement /constitution display command | 2 |

---

## E-005: Discovery Engine

**Priority:** P2 — Structural
**Gap:** C (Path Inconsistencies)
**Components:** Discovery Engine (§3.2.5)
**FRs:** FR30, FR31, FR32, FR33, FR38, FR39, FR40
**NFRs:** NFR6, NFR12
**Build Order:** 3 (depends on State Machine + Constitution Engine)

### Description

Implement initiative discovery, artifact path resolution from initiative config, and onboarding flow. Ensures all artifact paths are consistent and resolvable.

### Acceptance Criteria

- All artifact paths resolve from `initiative.docs.path` per §3.2.5
- Can discover existing initiatives by scanning `initiatives/` directory
- Can switch between multiple active initiatives (FR40)
- Onboarding flow completes in ≤5 interactions (NFR12)
- Path normalization follows `Docs/{domain}/{service}/feature/{feature}/` pattern

### Stories

| Story | Title | SP |
|-------|-------|----|
| S-017 | Implement artifact path resolution | 3 |
| S-018 | Implement initiative discovery (scan) | 3 |
| S-019 | Implement /switch command | 3 |
| S-020 | Implement /onboard flow (4-step) | 4 |

---

## E-006: Checklist Engine

**Priority:** P2 — Structural
**Gap:** None (new capability)
**Components:** Checklist Engine (§3.2.6)
**FRs:** FR20, FR22, FR23, FR24, FR25
**Build Order:** 3 (depends on State Machine + Constitution Engine)

### Description

Implement progressive gate readiness checklists that track artifact existence, review status, and constitution compliance for each phase completion and audience promotion.

### Acceptance Criteria

- Checklist items are generated from resolved constitution's `required_artifacts`
- Gate readiness percentage calculated correctly
- Gate blocks when any `required: true` item is not `passed`
- Gate decisions recorded in event log (FR24)

### Stories

| Story | Title | SP |
|-------|-------|----|
| S-021 | Implement checklist schema and gate logic | 3 |
| S-022 | Implement artifact existence checks | 2 |
| S-023 | Implement gate decision recording | 3 |

---

## E-007: Router Engine & Agent Integration

**Priority:** P1 — Foundation
**Gap:** A (Competing Lifecycles), F (Skeleton Phases)
**Components:** Router Engine (§3.2.1)
**FRs:** FR2, FR3, FR4, FR26, FR27, FR28, FR29
**NFRs:** NFR9, NFR10, NFR11
**Build Order:** 4 (depends on all other components)

### Description

Implement the command router that maps slash commands to workflow files, validates preconditions, and activates the correct BMM phase agent with injected context. This is the user-facing entry point for all @lens interactions.

### Acceptance Criteria

- All phase commands route to correct workflow files
- Router validates preconditions before dispatching (previous phase complete)
- Phase agent receives full context injection (prior artifacts, constitution, initiative config)
- `/status` shows structured 3-line output per NFR10
- Error messages follow gate feedback contract per UX Design §2

### Stories

| Story | Title | SP |
|-------|-------|----|
| S-024 | Implement command→workflow routing table | 3 |
| S-025 | Implement precondition validation chain | 5 |
| S-026 | Implement agent context injection | 5 |
| S-027 | Implement /status command (3-line + verbose) | 3 |
| S-028 | Implement gate feedback error messages | 5 |

---

## E-008: Phase Workflows

**Priority:** P1 — Foundation
**Gap:** E (Stub Prompts), F (Skeleton Phases)
**Components:** Router Engine + All, Phase Lifecycle (§5)
**FRs:** FR1-FR5, FR26-FR29, FR34-FR37
**Build Order:** 4+ (depends on Router Engine and all supporting components)

### Description

Implement all five planning phase workflows (PrePlan, BusinessPlan, TechPlan, DevProposal, SprintPlan) following the consistent phase workflow pattern defined in §5.2. Each phase: pre-flight → context load → agent activation → artifact generation → commit → PR.

### Acceptance Criteria

- All 5 phase commands produce at least one artifact file at the expected path (FR43)
- Every phase follows the pre-flight pattern (§9.2): clean state, validate previous phase, create/checkout branch
- Every phase follows the commit & gate pattern: targeted commit, PR creation, state update, event log
- Phase agents receive full cross-phase context (§5.4)
- No skeleton phases — each phase produces real artifacts

### Stories

| Story | Title | SP |
|-------|-------|----|
| S-029 | Implement /preplan workflow (Mary → product-brief) | 3 |
| S-030 | Implement /businessplan workflow (John+Sally → PRD) | 3 |
| S-031 | Implement /techplan workflow (Winston → architecture) | 3 |
| S-032 | Implement /devproposal workflow (John → epics+stories) | 5 |
| S-033 | Implement /sprintplan workflow (Bob → sprint-status) | 3 |
| S-034 | Implement /new (initiative creation) | 4 |

---

## E-009: Recovery & Sync

**Priority:** P2 — Structural
**Gap:** D (State Drift)
**Components:** State Machine + Git Engine
**FRs:** FR15, FR41, FR41b, FR41c, FR41d
**NFRs:** NFR1, NFR2, NFR3, NFR4
**Build Order:** 3+ (depends on State Machine + Git Engine)

### Description

Implement the `/sync` (remote-wins reconciliation) and `/fix` (three-category repair) commands that detect and resolve state drift, orphan branches, and orphan state entries.

### Acceptance Criteria

- `/sync` reconstructs state from git branch existence + PR merge status + event log
- `/sync` shows diff of proposed changes before applying
- `/fix` detects and offers repair for: state drift, orphan branches, orphan state
- `/fix` previews changes before applying — never modifies without confirmation
- All recovery operations are logged in event log

### Stories

| Story | Title | SP |
|-------|-------|----|
| S-035 | Implement /sync (remote-wins reconciliation) | 3 |
| S-036 | Implement /fix (3-category repair) | 3 |
| S-037 | Implement state reconstruction from event log + git | 2 |

---

## E-010: Validation & Dogfood

**Priority:** P2
**Components:** All
**Build Order:** 5 (after all implementation)

### Description

Validate the complete system through dogfood usage (this initiative continues through SprintPlan and Dev), constitution stress testing, and gate enforcement testing as defined in §13.

### Acceptance Criteria

- Dogfood initiative `upgrade-cjki9q` completes through Dev phase
- Constitution stress test passes (overlapping domain+service constitutions merge correctly)
- Gate enforcement test passes (out-of-order phase commands blocked with correct error messages)
- Idempotency test passes (re-run of every command produces same result)

### Stories

| Story | Title | SP |
|-------|-------|----|
| S-038 | Dogfood: complete initiative through all phases | 3 |
| S-039 | Constitution stress test (multi-level merge) | 3 |
| S-040 | Gate enforcement + idempotency tests | 2 |

---

## Priority & Build Sequence

```
Sprint 1 (P0):
  E-001 Safety Gate                    [5 SP]

Sprint 2 (P1 Foundation):
  E-002 State Machine Foundation       [21 SP]

Sprint 3 (P1 Foundation, parallel):
  E-003 Git Engine                     [21 SP]
  E-004 Constitution Engine            [13 SP]

Sprint 4 (P1):
  E-007 Router Engine & Agent Int.     [21 SP]

Sprint 5 (P1+P2):
  E-008 Phase Workflows                [21 SP]
  E-005 Discovery Engine               [13 SP] (parallel)

Sprint 6 (P2):
  E-006 Checklist Engine               [8 SP]
  E-009 Recovery & Sync                [8 SP]
  E-010 Validation & Dogfood           [8 SP]
```

**Total: 139 story points across 40 stories in 10 epics.**

---

*Generated during DevProposal phase by John (PM) for initiative upgrade-cjki9q.*
*Source: Architecture Document (TechPlan), PRD (BusinessPlan), Product Brief (PrePlan), Tech Decisions.*
