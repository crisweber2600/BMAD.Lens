---
artifact: epics
phase: devproposal
initiative: bmad-lens-repodiscovery
author: John (PM)
created: "2026-03-09"
inputDocuments:
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/businessplan/prd.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/techplan/architecture.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/techplan/tech-decisions.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/devproposal/devproposal-questions.md
---

# Epics — Repo Discovery (`/discover` command)

**Author:** John (PM)
**Date:** 2026-03-09
**Initiative:** bmad-lens-repodiscovery

---

## Epic Overview

| ID | Epic | Stories | Priority | Audience |
|---|---|---|---|---|
| E-001 | Command Wiring | S-001 – S-004 | P0 | medium |
| E-002 | Core Discovery (MVP) | S-005 – S-012 | P0 | medium |
| E-003 | Discovery Enhancements (NTH) | S-013 – S-017 | P1 | medium |

**Execution order:** E-001 → E-002 → E-003 (sequential; each epic unblocks the next).

---

## E-001 — Command Wiring

**Summary:** Wire the `/discover` command route into the lens-work module by replacing stub files with complete implementations.

**Why first:** The functional implementation (E-002/E-003) depends on working prompt and workflow entry points. Wiring the command first means E-002 stories can be validated through the actual command flow, not just unit-level tests.

**Scope:**
- Update `module.yaml` to formally register `/discover`
- Replace the stub `lens-work.discover.prompt.md` with a complete agent instruction file
- Replace the stub `discover/workflow.md` with the full phase-router workflow
- Validate that `@lens /discover` routes correctly in VS Code Copilot Chat

**Out of scope:** Actual discovery logic (E-002), NTH features (E-003).

**Hard constraint:** No branches created in TargetProjects repos. Control repo only. (Applies to all epics — documented here once.)

**Definition of Done (Epic):**
- [ ] `module.yaml` registers `/discover` with correct aliases and agent
- [ ] `lens-work.discover.prompt.md` fully authored (not a stub)
- [ ] `discover/workflow.md` router complete and consistent with phase-router pattern
- [ ] `/discover` command resolves without 404 or missing-file errors in VS Code
- [ ] Adversarial review passes (S-004)

**Stories:** S-001, S-002, S-003, S-004

---

## E-002 — Core Discovery (MVP)

**Summary:** Implement the full MVP pipeline: PreFlight, FileSystemScanner, RepoInspector, GovernanceWriter (with idempotency), GitOrchestrator, and MVP progress output.

**Depends on:** E-001 complete (working command entry point).

**MVP pipeline:**
```
/discover
  → [0] PreFlight + InitiativeContextResolver
  → [1] FileSystemScanner (FR-1)
  → [2] RepoInspector (FR-2)
  → [3] GovernanceWriter (FR-4) + idempotency prompt
  → [4] GitOrchestrator (FR-5)
  → minimal one-line-per-repo progress output
```

**Scope:**
- All FR-1, FR-2, FR-4, FR-5 as defined in architecture.md
- Per-repo error isolation (TD-005): single-repo failure does not abort remaining repos
- Pull-before-push hard gate on governance writes (TD-003)
- Idempotency: prompt user `[Y/N]` when existing inventory entry found (TD-007)
- One-line progress output per repo during execution
- Smoke test: end-to-end validation with 2 synthetic `.git/` directories
- Adversarial review gate before epic closure

**Out of scope:** Language detection (FR-3), context generation (FR-6), state management (FR-7), formatted report table (FR-8) — all deferred to E-003.

**Definition of Done (Epic):**
- [ ] `/discover` on a service folder with 2 cloned repos produces correct `repo-inventory.yaml` and control-repo branches
- [ ] Governance pull-before-push enforced; push failure marks entry as failed without false success
- [ ] Idempotency: re-run on same repos prompts user, no silent overwrites
- [ ] Per-repo error isolation: one bad repo does not abort remaining repos
- [ ] Control-repo branches created with `{initiative_root}-{domain}-{service}-{repo_name}` convention
- [ ] Smoke test passes (S-011)
- [ ] Adversarial review passes (S-012)

**Stories:** S-005, S-006, S-007, S-008, S-009, S-010, S-011, S-012

---

## E-003 — Discovery Enhancements (NTH)

**Summary:** Implement the four NTH features: LanguageDetector, ContextGenerator, StateManager, and ReportRenderer.

**Depends on:** E-002 complete (MVP pipeline operational).

**Scope:**
- LanguageDetector (FR-3): build-file-first detection with `lifecycle.yaml` priority order
- ContextGenerator (FR-6): delegate to `bmad-bmm-generate-project-context` per repo
- StateManager (FR-7): update initiative config `language` field when all repos agree
- ReportRenderer (FR-8): replace per-line progress output with a formatted table at end of execution
- Adversarial review gate before epic closure

**Definition of Done (Epic):**
- [ ] Language detection runs for all repos; `unknown` returned gracefully (never throws)
- [ ] `project-context.md` generated per repo via delegated workflow
- [ ] Initiative config `language` updated only when all repos share the same language
- [ ] Final report table rendered with columns: `Repo | Language | BMAD | Governance | Branch | Context | Status`
- [ ] Adversarial review passes (S-017)

**Stories:** S-013, S-014, S-015, S-016, S-017
