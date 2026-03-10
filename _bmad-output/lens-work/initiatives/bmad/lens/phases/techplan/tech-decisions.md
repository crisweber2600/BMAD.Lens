---
stepsCompleted: [1, 2]
inputDocuments:
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/preplan/product-brief.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/businessplan/prd.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/techplan/architecture.md
workflowType: 'tech-decisions'
project_name: 'Repo Discovery'
user_name: 'CrisWeber'
date: '2026-03-09'
initiative: bmad-lens-repodiscovery
phase: techplan
author: Winston (Architect)
---

# Technology Decisions — Repo Discovery (`/discover`)

**Author:** CrisWeber
**Date:** 2026-03-09

---

## TD-001 — Filesystem-only detection (no GitHub API)

**Status:** Accepted

**Decision:** All repository detection, presence checks, and language detection are performed by reading the local filesystem only. No GitHub API calls are made during `/discover`.

**Context:** The repo-inventory.yaml approach requires accurate reflection of what is actually cloned locally. GitHub API would answer "what repos exist in the org" — which is a different and broader question. Repos that exist on GitHub but are not yet cloned should not appear in the inventory. Additionally, the tool must work offline, in air-gapped environments, and without requiring a GitHub token with sufficient scope to list org repos.

**Consequences:**
- (+) Works without network connectivity or GitHub API token
- (+) Reflects ground truth: only repos present locally are discoverable
- (+) Simpler implementation — no pagination, no rate limiting, no auth handling
- (-) Does not detect repos that should be cloned but haven't been yet
- (-) Must rely on directory structure conventions

**Alternatives considered:**
- GitHub API (`/orgs/{org}/repos`): Rejected — answers wrong question (what exists in org vs. what is cloned locally); requires additional auth scope; adds network dependency
- Hybrid (local + API diff): Rejected for MVP scope — adds complexity without MVP requirement coverage

---

## TD-002 — Sequential per-repo processing (no parallelism)

**Status:** Accepted

**Decision:** Repos are processed one at a time, in filesystem order. No concurrent operations.

**Context:** NFR-1 allows ≤1hr for 10 repos. Context generation (the most expensive NTH operation) involves delegated AI workflow calls which are not reliably parallelizable in the Copilot Chat environment. GovernanceWriter requires sequential git pull → write → push, which structurally prevents parallel processing of the governance step. Error isolation is simpler with sequential processing.

**Consequences:**
- (+) Simple, deterministic execution model
- (+) Pull-before-push governance constraint naturally satisfied
- (+) Easy to implement per-repo error isolation (loop with try/catch per iteration)
- (-) Slower than parallel for large repo sets (>10 repos)
- Recovery path: If scale grows beyond 10 repos, parallelism can be added for the detection phase (scan + inspect) while keeping governance writes sequential

**Alternatives considered:**
- Parallel scan + sequential write: Premature optimization for current scale; increases complexity without measurable benefit for ≤10 repos
- Full parallel with governance locking: Rejected — lock semantics in git-based governance are complex and fragile

---

## TD-003 — Pull-before-push as hard gate for governance writes

**Status:** Accepted

**Decision:** `git pull` is executed on the governance repo before any read or write to `repo-inventory.yaml`. A pull failure is a hard exit condition — the entire `/discover` workflow aborts if the governance pull fails.

**Context:** `repo-inventory.yaml` is a shared, multi-user-editable file. Any write without a prior pull could overwrite concurrent changes made by other `@lens` users or CI automation. The governance repo is authoritative — local state must be current before being written to. This is NFR-3.

**Consequences:**
- (+) Prevents accidental clobber of concurrent governance writes
- (+) Aligns with standard git workflow for shared config files
- (-) Requires network access at write time (not fully offline-capable for governance writes)
- (-) A governance repo with a dirty working tree or merge conflict will abort the workflow
- Recovery path: If governance pull fails, user is instructed to run `git pull` manually in the governance repo and re-run `/discover`

**Alternatives considered:**
- Optimistic write (no pull): Rejected — creates divergent inventory state, merge conflicts on next push
- Pull-after-scan: Some implementations pull only right before writing; accepted equivalent here since scanning is fast and pull happens before all writes
- Skip governance write if pull fails: Rejected — silent skip violates the no-silent-failures principle (NFR-4)

---

## TD-004 — Branch creation in control repo only

**Status:** Accepted

**Decision:** The `/switch` navigation branches (format: `{initiative_root}-{domain}-{service}-{repo_name}`) are created in the control repo (BMAD.Lens), not inside any TargetProjects repository.

**Context:** TargetProjects repos are not owned by the lens-work lifecycle — they are the subject of the work, not the workspace for it. Creating branches in them would require write access to those repos, pollute their branch lists, and couple the lens-work tooling to their branching policies. The `/switch` command operates on the control repo context, so the branches need to exist in the control repo for `/switch` to navigate to them.

**Consequences:**
- (+) No write operations on TargetProjects repos — safer, no coupling to their policies
- (+) Control repo branches are self-documenting: branch list shows all discovered repos for an initiative
- (+) `/switch` implementation is simple: `git checkout {branch}` in control repo
- (-) Developers must remember that "being on a switch branch" means targeting that TargetProjects repo contextually, not that the TargetProjects repo itself was modified

**Alternatives considered:**
- Branch per repo in TargetProjects: Rejected — requires write access, pollutes subject repo history, couples tooling
- Symlinks or workspace files only: Rejected — not durable, no git history, `/switch` can't use them

---

## TD-005 — Per-repo error isolation with continue-on-failure

**Status:** Accepted

**Decision:** Failures in any single-repo operation (inspect, governance write, branch creation, context generation) are caught, recorded in the result record for that repo, and the pipeline continues to the next repo.

**Context:** NFR-4 requires partial failure recovery. With ≤10 repos, it is unacceptable for a single bad repo (e.g., corrupted `.git/` directory, missing remote) to abort discovery of all remaining repos. The final report surfaces all per-repo failures, so nothing is silently skipped.

**Consequences:**
- (+) Resilient to single-repo anomalies without aborting the full discovery
- (+) All failures are visible in the final report table
- (-) Discovery may complete with partial results — user must inspect the report
- Recovery path: User reruns `/discover` for affected repos only (not yet a feature, but the report identifies which repos failed)

**Alternatives considered:**
- Fail-fast (first error aborts): Rejected — too fragile for multi-repo operations; forces user to fix one repo at a time
- Retry logic per repo: Deferred — adds complexity; transient errors in this domain are rare

---

## TD-006 — Language detection priority: build-file-first, extension-fallback

**Status:** Accepted

**Decision:** Language detection follows a strict priority: (1) `.bmad/language` override file, (2) canonical build file presence, (3) source file extension frequency, (4) `"unknown"`. The priority list is sourced from `lifecycle.yaml` `language_detection_priority` to allow future configuration without code changes.

**Context:** Build files are more reliable language indicators than extension counts (a TypeScript project will have `.js` alongside `.ts` from compiled output). An explicit `.bmad/language` override allows repo owners to override detection for unusual project structures. `"unknown"` as a typed fallback avoids null handling throughout the pipeline.

**Consequences:**
- (+) Reliable detection for standard project types
- (+) Extensible — priority order is config-driven, not hardcoded
- (+) Never throws — all detection exceptions result in `"unknown"` graceful fallback
- (-) Cannot detect polyglot repos (returns primary language only)
- (-) Repos without standard build files and few source files will return `"unknown"` more often

**Alternatives considered:**
- GitHub Linguist API: Rejected — requires GitHub API call (rejected in TD-001); also requires push state
- Only extension-based detection: Rejected — unreliable for TypeScript/JavaScript mixed repos; less precise for .NET
- Skip language detection entirely: Deferred to NTH — required for NTH FR-3 but not MVP

---

## TD-007 — Governance inventory idempotency via name-keyed upsert

**Status:** Accepted

**Decision:** `repo-inventory.yaml` entries are keyed by `name` (repo directory name). On re-run, if an entry with the same name exists, the user is prompted `[Y/N]` before overwriting. Silent update is not performed.

**Context:** NFR-2 requires idempotent runs. However, a completely silent overwrite would mask cases where a user has manually edited an entry (e.g., corrected a language classification). Prompting on conflict preserves intentional manual edits while still enabling update of stale entries.

**Consequences:**
- (+) Preserves intentional manual inventory edits
- (+) Users understand what will change before it changes
- (-) Interactive prompt can slow down batch re-discovery of many repos
- Recovery path: A `--force` flag or batch-accept mode is a reasonable NTH enhancement if batch re-discovery becomes a common pattern

**Alternatives considered:**
- Fully idempotent silent overwrite: Rejected — could silently discard intentional manual edits
- Error on conflict (no overwrite): Too rigid — outdated entries should be updatable
- Version-based merge: Premature for the current use case and inventory structure
