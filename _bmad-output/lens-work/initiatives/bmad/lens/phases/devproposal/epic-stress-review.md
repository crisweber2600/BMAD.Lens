---
artifact: epic-stress-review
phase: devproposal
initiative: bmad-lens-repodiscovery
mode: adversarial+party
scope: epics
reviewed_by: [winston, bob, amelia]
created: "2026-03-10"
verdict: PASS_WITH_NOTES
---

# Epic Stress Review — Adversarial + Party Mode

**Initiative:** bmad-lens-repodiscovery  
**Lead:** Winston (Architect) | **Panel:** Bob (SM), Amelia (Dev)  
**Focus:** Buildable? Right-sized? Implementable?  
**Verdict:** ✅ PASS_WITH_NOTES

---

## E1 — Discovery Pipeline & Pre-flight

### Winston (Architect) — Buildability

The three stories (S1.1, S1.2, S1.3) cleanly map to three sequential concerns: resolve context, scan filesystem, inspect repos. The dependency chain is explicit and correct. The incremental output requirement (AR-3) is correctly placed in S1.2 — it's a constraint on _when_ the output is emitted, which the workflow step can easily satisfy.

**Concern:** S1.1 loads governance path from `governance-setup.yaml`. Where does this file live? If it's in the control repo root, no issue. If it requires a separate init step to create, that's a hidden pre-dependency. Implementation team should verify `governance-setup.yaml` existence and document the bootstrap path.

**Verdict:** ✅ PASS_WITH_NOTE — Confirm `governance-setup.yaml` path in S1.1 implementation notes.

### Bob (SM) — Sprintability

E1 is 3 stories total: XS + S + XS. All three can be delivered in Sprint 1 as a unit. They deliver the "scan and detect" capability cleanly. No story in E1 delivers user-visible output on its own (the report comes in S4.2), but together they build the foundational result set. This is acceptable — internal validation is sufficient for a mid-sprint checkpoint.

**Verdict:** ✅ PASS

### Amelia (Dev) — Implementability

S1.2's empty-folder flow is slightly complex: scan → if empty → prompt → wait → re-scan. The "wait for user" step in agent workflows can have unexpected behavior. The implementation should define what counts as "done" in the chat context (user types "done", any reply, specific keyword). The AC says "wait_for_user: 'done'" — this should be tested explicitly.

S1.3's per-repo error isolation is standard catch-and-continue. No implementation concerns.

**Verdict:** ⚠️ PASS_WITH_NOTE — S1.2: define "done" keyword handling in implementation notes. Ambiguous string matching could cause the prompt to fire early.

### Panel Verdict for E1: ✅ PASS_WITH_NOTES (2 advisory notes, no blockers)

---

## E2 — Governance Integration

### Winston (Architect) — Buildability

The pull gate (S2.1) → schema validation (S2.2) → upsert (S2.3) → push/isolation (S2.4) is the right ordering. The schema validation story (S2.2) has an open item: where does the schema come from? The checklist captures this as OI-2. This is a real dependency — implementation of S2.2 is blocked until OI-2 is resolved.

**Concern:** The stories don't specify _how_ `repo-inventory.yaml` is structured (flat list? nested by domain?). If the governance repo has an existing structure, S2.2 must match it. Review existing `repo-inventory.yaml` at `TargetProjects/lens/lens-governance/` before implementing S2.2.

**Verdict:** ⚠️ PASS_WITH_NOTE — Review existing governance `repo-inventory.yaml` schema before S2.2 implementation. OI-2 must be resolved first.

### Bob (SM) — Sprintability

E2 has 4 stories (XS+S+M+S). The M story (S2.3, idempotent upsert) is the most complex unit but is still a single sprint task. The single-batch-commit design in S2.3 is good for sprint delivery — no partial-commit state.

**Concern:** S2.3's "prompt for each existing entry" could be slow for re-discovery of 10 repos with all existing entries. Consider batching the conflict prompts: "Found 10 existing entries. Update all? [Y/N] or list changes first? [L]". This is a UX enhancement — not a blocker, but worth noting for implementation.

**Verdict:** ⚠️ PASS_WITH_NOTE — S2.3: consider batch conflict resolution prompt for large re-discovery runs. Current AC is correct but may be UX-suboptimal at scale.

### Amelia (Dev) — Implementability

S2.1–S2.4 are implementable as workflow steps. The push non-fatal pattern (S2.4) is well-established in the existing git-orchestration module. No new infra needed.

**Verdict:** ✅ PASS

### Panel Verdict for E2: ✅ PASS_WITH_NOTES (2 advisory notes — OI-2 is a real pre-work item)

---

## E3 — Control Repo Branch Management

### Winston (Architect) — Buildability

S3.1 is clean and buildable. Branch naming schema matches architecture doc. The idempotent "skip if exists" pattern is standard.

**One gap:** The story doesn't specify what happens if the initiative root branch doesn't exist. At runtime this should always exist, but a defensive check (`git branch -r | grep {initiative_root}`) is worth adding to the pre-flight of S1.1 or S3.1's own pre-check.

**Verdict:** ✅ PASS_WITH_NOTE — S3.1: add defensive check for initiative root branch existence.

### Bob (SM) — Sprintability

E3 is a single story (S). Deliverable in Sprint 3 alongside E4 without risk. Branch operations in git-orchestration are well-tested.

**Verdict:** ✅ PASS

### Amelia (Dev) — Implementability

Straightforward. Branch creation + push in the control repo is a standard git-orchestration call. No new workflow primitives needed.

**Verdict:** ✅ PASS

### Panel Verdict for E3: ✅ PASS (1 advisory note)

---

## E4 — Workflow Completion & Module Integration

### Winston (Architect) — Buildability

S4.1 (complete workflow.md, size L) is the integration epic. It's effectively the assembly of E1+E2+E3 into a coherent workflow.md. The risk here is integration defects — the individual stories work in isolation but the assembled workflow could have sequencing issues.

**Critical:** S4.1 should include a walkthrough validation — the implementer should trace the entire workflow from pre-flight to report for a 3-repo scenario before closing the story.

**Verdict:** ⚠️ PASS_WITH_NOTE — S4.1 DoD must include end-to-end walkthrough for 3-repo scenario.

### Bob (SM) — Sprintability

S4.1 (L) + S4.2 (S) + S4.3 (XS) = one sprint. The L story is large but has clear boundaries — it's an assembly task, not net-new development.

**Verdict:** ✅ PASS

### Amelia (Dev) — Implementability

S4.2's discovery report output table is specified with enough detail to implement. S4.3's module registration validation is trivial.

**One note on S4.1:** The "TD-006 note" in the AC is advisory — the implementer should add a line directly to `tech-decisions.md` during implementation. This is a 2-minute task that shouldn't be forgotten. Maybe make it an explicit sub-task.

**Verdict:** ⚠️ PASS_WITH_NOTE — S4.1: add explicit sub-task "Add TD-006 to tech-decisions.md" to prevent it from being forgotten.

### Panel Verdict for E4: ✅ PASS_WITH_NOTES (2 advisory notes)

---

## E5 — NTH Enhancements

### Winston (Architect) — Buildability

E5 stories (S5.1–S5.3) are clean and well-isolated. LanguageDetector (S5.1) correctly follows lifecycle.yaml priority order. The "no throw on failure" DoD (AR-1) is implementable as a typed result wrapper.

**Verdict:** ✅ PASS

### Bob (SM) — Sprintability

E5 is 3 stories (M+M+S). Deliverable as Sprint 4 with no MVP dependencies. NTH gate (can be disabled via config) is specified in E5's epic-level AC.

**Verdict:** ✅ PASS

### Amelia (Dev) — Implementability

S5.2 (ContextGenerator) delegates to `bmad-bmm-generate-project-context`. This workflow must exist and be compatible. Verify the workflow is present in `bmad.lens.release/_bmad/bmm/workflows/generate-project-context/` before S5.2 implementation.

**Verdict:** ✅ PASS_WITH_NOTE — S5.2 pre-work: verify `bmad-bmm-generate-project-context` workflow location and interface before implementation.

### Panel Verdict for E5: ✅ PASS (1 advisory note, acceptable for NTH)

---

## Cross-Epic Stress Findings

| ID | Finding | Severity | Epic | Resolution |
|---|---|---|---|---|
| SS-1 | `governance-setup.yaml` path must be verified before implementation | Advisory | E1/S1.1 | Add to S1.1 implementation notes |
| SS-2 | S1.2 "done" keyword handling is ambiguous | Advisory | E1/S1.2 | Define keyword in implementation notes |
| SS-3 | OI-2 (schema source) must be resolved before S2.2 | Pre-work | E2/S2.2 | Review existing `repo-inventory.yaml` first |
| SS-4 | Batch conflict resolution prompt for large re-discovery | Enhancement | E2/S2.3 | Optional UX improvement for V1.1 |
| SS-5 | S3.1: add initiative root branch existence check | Defensive | E3/S3.1 | Add defensive check in implementation |
| SS-6 | S4.1 DoD: end-to-end walkthrough for 3-repo scenario | Quality gate | E4/S4.1 | Add to S4.1 DoD |
| SS-7 | S4.1: TD-006 sub-task to prevent it being forgotten | Tracking | E4/S4.1 | Explicit sub-task |
| SS-8 | S5.2: verify `bmad-bmm-generate-project-context` location/interface | Pre-work | E5/S5.2 | Pre-implementation check |

---

## Overall Epic Stress Gate Verdict

| Epic | Verdict | Blockers |
|---|---|---|
| E1 | ✅ PASS_WITH_NOTES | None (2 advisories) |
| E2 | ✅ PASS_WITH_NOTES | OI-2 is pre-work for S2.2 |
| E3 | ✅ PASS | None (1 advisory) |
| E4 | ✅ PASS_WITH_NOTES | None (2 advisories) |
| E5 | ✅ PASS | None (1 advisory) |

**Gate Result:** ✅ **PASS — All epics clear for sprint planning**

> All findings are advisory. No epic has implementation blockers. The pre-work item (OI-2: schema source resolution) must be completed before Sprint 2 begins but does not block Sprint 1.
