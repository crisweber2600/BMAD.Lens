---
artifact: epics
phase: devproposal
initiative: bmad-lens-repodiscovery
author: John (PM)
agent: john
created: "2026-03-10"
source_artifacts:
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/preplan/product-brief.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/businessplan/prd.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/techplan/architecture.md
adversarial_review_notes: [AR-1, AR-2, AR-3, AR-4, AR-5]
---

# Epics — Repo Discovery (`/discover`)

**Author:** John (PM)  
**Phase:** DevProposal  
**Initiative:** bmad-lens-repodiscovery  
**Date:** 2026-03-10

---

## Epic Overview

| Epic | Title | Audience | Track | PRD FRs | Priority |
|---|---|---|---|---|---|
| E1 | Discovery Pipeline & Pre-flight | Dev | MVP | FR-1, FR-2 | P0 |
| E2 | Governance Integration | Dev | MVP | FR-4 | P0 |
| E3 | Control Repo Branch Management | Dev | MVP | FR-5 | P0 |
| E4 | Workflow Completion & Module Integration | Dev | MVP | (all) | P0 |
| E5 | NTH Enhancements | Dev | NTH | FR-3, FR-6, FR-7, FR-8 | P1 |

> **MVP epics:** E1–E4 form the complete, shippable `/discover` command.  
> **NTH epic:** E5 contains opt-in enhancements enabled by architecture but deferred from initial sprint.

---

## E1 — Discovery Pipeline & Pre-flight

**Goal:** Given an active initiative (domain + service), scan the expected TargetProjects folder for git repos, inspect each for BMAD configuration presence, and yield a per-repo result set for downstream processing.

**Scope:**
- InitiativeContextResolver: read domain + service from active initiative config
- Verify scan path exists (`TargetProjects/{domain}/{service}/`)
- Verify governance repo present (preflight gate)
- FileSystemScanner: enumerate immediate child directories containing `.git/`
- Handle empty-folder case: prompt user to clone repos, re-scan
- RepoInspector: detect `.bmad/` presence per discovered repo
- Per-repo error isolation: continue pipeline on single-repo failures (NFR-4)
- Output incremental progress: one "✓ discovered: {repo-name}" line per repo as discovered, not batched (AR-3 ← UX requirement)

**Outcome:** A list of `RepoResult` objects (repo_name, path, has_bmad, error?) delivered to E2 and E3.

**Acceptance Criteria:**
- [ ] Scan path is resolved from active initiative config (domain + service)
- [ ] Governance repo path is verified in preflight; fails with actionable message if absent
- [ ] Zero `.git/` dirs → prompt for clone, re-scan, exit 0 with "No repos found" message
- [ ] Each discovered repo emits "✓ discovered: {repo_name}" immediately (incremental, not batched)
- [ ] Repo with filesystem error → logged to result record; pipeline continues for remaining repos
- [ ] BMAD presence detected as `has_bmad: true/false` per repo

**Adversarial review traceability:** AR-3 (incremental output)

---

## E2 — Governance Integration

**Goal:** For each discovered repo in the result set from E1, update `repo-inventory.yaml` in the governance repo with idempotency and zero-data-loss guarantees.

**Scope:**
- GovernanceWriter: pull governance repo before any write (NFR-3 — mandatory gate)
- Read existing `repo-inventory.yaml` and check for existing entries (NFR-2)
- Conflict resolution: if entry already exists, prompt "Repo X already in inventory. Update? [Y/N]" — user explicit control (UX Journey 2, SC-4)
- Schema validation: validate `repo-inventory.yaml` structure before writing (AR-5)
- Upsert discovered repo entries (committed fields: repo_name, domain, service, language, has_bmad, discovered_at)
- Commit + push governance repo update; non-fatal on push failure (reports ❌ but does not abort)
- Per-repo error isolation: GovernanceWriter failure for one repo does not abort remaining repos

**Outcome:** Governance `repo-inventory.yaml` contains entries for all discovered repos respecting user decisions on conflicts.

**Acceptance Criteria:**
- [ ] `git pull` on governance repo succeeds before any write attempt (AC: "governance pull occurs before any write attempt") (AR-2)
- [ ] If governance pull fails → abort governance writes; report error; continue with E3 (branch creation)
- [ ] Schema validation: validate `repo-inventory.yaml` before writing; fail with schema diff if invalid (AR-5)
- [ ] Idempotent: running `/discover` twice with same repos → same inventory state (after conflict prompts) (SC-4)
- [ ] User explicitly prompted for each existing entry ("Update? [Y/N]"); no silent overwrites
- [ ] Commit message includes initiative ID and timestamp
- [ ] Push failure: non-fatal; reports ❌ "Failed to push governance update — run `/discover` again to retry"
- [ ] Per-repo: GovernanceWriter failure on repo N does not block processing of repo N+1

**Adversarial review traceability:** AR-2 (pull-before-push DoD), AR-5 (schema validation)

---

## E3 — Control Repo Branch Management

**Goal:** For each discovered repo, create a branch in the control repo (BMAD.Lens) that enables `/switch` navigation to that repo.

**Scope:**
- GitOrchestrator: create branch `{initiative_root}-{domain}-{service}-{repo_name}` per discovered repo
- Branch created from current initiative root branch
- Idempotent: if branch already exists, skip (no error)
- Push branches to remote

**Outcome:** `/switch` can navigate to any discovered repo via the created branches.

**Acceptance Criteria:**
- [ ] Branch name follows schema: `{initiative_root}-{domain}-{service}-{repo_name}` (from architecture)
- [ ] Branch created from initiative root; pushed to remote
- [ ] Idempotent: existing branch → skip with "branch already exists" notice, no error
- [ ] SC-3: After E3 completes, `/switch` successfully resolves all discovered repos
- [ ] Per-repo: branch creation failure for one repo does not abort remaining repos

---

## E4 — Workflow Completion & Module Integration

**Goal:** Complete the `/discover` workflow definition, integrating all component outputs into a unified, fully-specified workflow file with step-file architecture. Ensure the workflow is registered in the lens-work module.

**Scope:**
- Complete `workflows/router/discover/workflow.md` with full step-by-step content (E1 + E2 + E3 + discovery report output)
- Add or verify entry in `_bmad/lens-work/module.yaml` (already stub-added; validate final integration)
- Add `lens-work.discover.prompt.md` with final preflight and invocation instructions
- End-of-workflow summary output: table of discovered repos (repo_name, language, has_bmad, governance_status, branch_created)
- Workflow wiring: `/discover` prompt → workflow.md → step files

**Outcome:** `/discover` is a fully executable workflow in the lens-work module. A user running `/discover` receives a complete discovery pipeline execution.

**Acceptance Criteria:**
- [ ] `workflow.md` contains complete executable steps (no stubs, TODOs, or TBDs)
- [ ] Module entry in `module.yaml` resolves correctly to `discover/workflow.md`
- [ ] Prompt file `lens-work.discover.prompt.md` is complete with preflight instructions
- [ ] End-of-workflow output table includes: repo_name, language (or `unknown`), has_bmad, governance_status (updated/skipped/failed), branch_created (yes/no)
- [ ] Workflow is end-to-end executable in a VS Code Copilot Chat session
- [ ] Discovery report table is human-readable and formatted consistently with other lens-work reports

**Notes:** 
- TR-006 (sequential processing) should be documented in `tech-decisions.md` as part of this epic's implementation work (AR-4 advisory)

---

## E5 — NTH Enhancements

**Goal:** Implement the optional enhancements defined in the PRD as NTH features. These extend the MVP pipeline without blocking initial delivery.

**Scope:**
- LanguageDetector (FR-3): detect primary language from lifecycle.yaml's `language_detection_priority` (build files → extension → `unknown`). Typed result object, no throws (NFR-5)
- ContextGenerator (FR-6): delegate `project-context.md` generation per repo to `bmad-bmm-generate-project-context` workflow
- StateManager (FR-7): update initiative config `language` field from `unknown` to detected value
- ReportRenderer (FR-8): extend table-formatted discovery report with language and BMAD columns (already partially covered in MVP table — E5 extends with language column from LanguageDetector output)
- Graceful language fallback: LanguageDetector returns `unknown` without error (AR-1 DoD requirement)

**Outcome:** `/discover` optionally performs language detection, context generation, and state updates based on lifecycle.yaml config flags.

**Acceptance Criteria:**
- [ ] LanguageDetector runs after RepoInspector; result stored in RepoResult
- [ ] SC-5: Language detection failure (no build files, no recognized extension) → returns `unknown`, no exception (AR-1 DoD)
- [ ] Language priority order follows `lifecycle.yaml.language_detection_priority` exactly
- [ ] ContextGenerator: delegates to `bmad-bmm-generate-project-context`; per-repo failure is non-fatal
- [ ] StateManager: updates active initiative config `language` field if all discovered repos share one language; prompts if multiple languages found
- [ ] Discovery report table includes `language` column when LanguageDetector is enabled
- [ ] NTH features can be disabled via config flag without affecting MVP pipeline

**Adversarial review traceability:** AR-1 (language fallback DoD)

---

## Dependencies

```
E1 (Discovery Pipeline + Pre-flight)
    ↓
E2 (Governance Integration) ──────┐
E3 (Control Repo Branches) ────────┤
                                   ↓
                              E4 (Workflow + Module Integration)
                                   ↑
                         E5 (NTH Enhancements) [parallel, optional]
```

- E2 and E3 depend on E1 output (result set)
- E4 integrates work from E1 + E2 + E3
- E5 runs in parallel with E2/E3; integrates into E4 if enabled

---

## Sprint Assignment (Suggested)

| Sprint | Epics |
|---|---|
| Sprint 1 | E1: Discovery Pipeline + Pre-flight |
| Sprint 2 | E2: Governance Integration |
| Sprint 3 | E3: Branch Management + E4: Workflow Integration |
| Sprint 4 (optional) | E5: NTH Enhancements |
