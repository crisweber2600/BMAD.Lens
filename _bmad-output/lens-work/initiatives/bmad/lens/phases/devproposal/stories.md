---
artifact: stories
phase: devproposal
initiative: bmad-lens-repodiscovery
author: John (PM)
agent: john
created: "2026-03-10"
source_artifacts:
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/devproposal/epics.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/techplan/architecture.md
adversarial_review_notes: [AR-1, AR-2, AR-3, AR-4, AR-5]
---

# Stories — Repo Discovery (`/discover`)

**Author:** John (PM)  
**Phase:** DevProposal  
**Initiative:** bmad-lens-repodiscovery  
**Date:** 2026-03-10

---

## Epic E1 — Discovery Pipeline & Pre-flight

### S1.1 — InitiativeContextResolver

**As a** `@lens` agent executing `/discover`,  
**I need** to resolve the active initiative's domain and service to determine the scan path,  
**So that** the discovery pipeline knows exactly where to look for cloned repos.

**Acceptance Criteria:**
- [ ] Reads `_bmad-output/lens-work/initiatives/{id}.yaml` for `domain` and `service`
- [ ] Constructs `scan_path = TargetProjects/{domain}/{service}/`
- [ ] If initiative config is missing or malformed → fail with: "❌ No active initiative found. Run `/new-service` first."
- [ ] Governance repo path loaded from `governance-setup.yaml`
- [ ] If governance repo path is missing or directory does not exist → fail with: "❌ Governance repo not found. Run `/onboard` to configure the governance path."

**Size:** XS  
**Depends on:** None

---

### S1.2 — FileSystemScanner

**As a** `@lens` agent executing `/discover`,  
**I need** to enumerate all direct child directories of the scan path that contain a `.git/` directory,  
**So that** the pipeline has an accurate list of cloned repos to process.

**Acceptance Criteria:**
- [ ] Scans `TargetProjects/{domain}/{service}/*/` for `.git/` presence
- [ ] Returns list of absolute directory paths (one per discovered repo)
- [ ] If zero repos found on first scan: outputs "Clone your repos to `{scan_path}` and reply **done** when ready." and waits
- [ ] On "done" signal: re-scans; if still zero → outputs "No repos found. Did you clone them to the right folder? Expected: {scan_path}" and exits cleanly (exit 0)
- [ ] Outputs "✓ discovered: {repo_name}" for each found repo **as it is discovered** (incremental, not batched) (AR-3)
- [ ] Non-git subdirectories in the scan path are silently skipped

**Size:** S  
**Depends on:** S1.1

---

### S1.3 — RepoInspector

**As a** `@lens` agent executing `/discover`,  
**I need** to inspect each discovered repo for BMAD configuration presence,  
**So that** the discovery report accurately reflects which repos are BMAD-configured.

**Acceptance Criteria:**
- [ ] For each repo_dir in discovered list: checks for presence of `.bmad/` directory
- [ ] Returns `has_bmad: true` if `.bmad/` directory exists, `has_bmad: false` otherwise
- [ ] Error accessing repo_dir (e.g., permissions): logs error to RepoResult, continues pipeline for remaining repos (NFR-4)
- [ ] Per-repo result object: `{ repo_name, path, has_bmad, error? }`
- [ ] Pipeline continues for all repos regardless of individual inspection failures

**Size:** XS  
**Depends on:** S1.2

---

## Epic E2 — Governance Integration

### S2.1 — GovernanceWriter: Pull Gate

**As a** `@lens` agent executing `/discover`,  
**I need** to pull the governance repo before performing any writes,  
**So that** governance inventory updates are never applied to a stale state (zero data loss, NFR-3).

**Acceptance Criteria:**
- [ ] `git pull` executes on governance repo before any inventory read or write
- [ ] If `git pull` fails → abort ALL governance writes for this run; report "❌ Governance pull failed — inventory not updated. Fix connectivity and retry."
- [ ] Pull success confirmed before proceeding to S2.2
- [ ] DoD: "governance pull occurs before any write attempt, every run" (AR-2)

**Size:** XS  
**Depends on:** S1.1

---

### S2.2 — GovernanceWriter: Schema Validation

**As a** `@lens` agent executing `/discover`,  
**I need** to validate the `repo-inventory.yaml` schema before writing,  
**So that** inventory corruption from schema drift is prevented (AR-5).

**Acceptance Criteria:**
- [ ] Reads current `repo-inventory.yaml` from governance repo
- [ ] Validates against expected schema (fields: repo_name, domain, service, language, has_bmad, discovered_at)
- [ ] If schema is invalid: fail with diff message showing expected vs actual structure; abort writes
- [ ] If file does not exist: initialize with empty valid schema (bootstrapping case)
- [ ] Schema source: defined in governance repo README (confirmed) or lifecycle.yaml schema block

**Size:** S  
**Depends on:** S2.1

---

### S2.3 — GovernanceWriter: Idempotent Upsert

**As a** `@lens` agent executing `/discover`,  
**I need** to upsert each discovered repo's entry in `repo-inventory.yaml` with explicit user confirmation for conflicts,  
**So that** the inventory is complete and the user retains control over existing entries (SC-4, NFR-2).

**Acceptance Criteria:**
- [ ] For each discovered repo: check if `repo_name` already exists in inventory
- [ ] If existing: prompt "Repo {repo_name} already in inventory. Update? [Y/N]"
  - Y → overwrite entry with discovered data
  - N → skip; mark as "skipped" in discovery report
- [ ] If new: insert entry without prompt
- [ ] Committed fields: `repo_name`, `domain`, `service`, `language` (`unknown` at MVP), `has_bmad`, `discovered_at` (ISO timestamp)
- [ ] All upserts are batched into a single commit (not one commit per repo)
- [ ] Commit message: `[{initiative_id}] /discover: update repo-inventory ({N} entries) — {timestamp}`
- [ ] DoD: Running `/discover` twice with same repos → identical inventory state (SC-4)

**Size:** M  
**Depends on:** S2.2

---

### S2.4 — GovernanceWriter: Push & Error Isolation

**As a** `@lens` agent executing `/discover`,  
**I need** to push governance updates non-fatally and isolate per-repo failures,  
**So that** a single repo failure or push failure does not prevent discovery from completing for other repos.

**Acceptance Criteria:**
- [ ] Commits inventory changes, then pushes to governance repo remote
- [ ] Push failure is non-fatal: reports "❌ Push failed — governance inventory updated locally but not pushed. Run `/discover` again to retry push."
- [ ] Per-repo GovernanceWriter failure → logged to RepoResult.error; pipeline continues for remaining repos
- [ ] Final discovery report reflects governance_status per repo: `updated` / `skipped` / `failed`

**Size:** S  
**Depends on:** S2.3

---

## Epic E3 — Control Repo Branch Management

### S3.1 — GitOrchestrator: Create `/switch` Branches

**As a** `@lens` agent executing `/discover`,  
**I need** to create a control-repo branch for each discovered repo using the standard naming schema,  
**So that** the user can navigate to any discovered repo using `/switch`.

**Acceptance Criteria:**
- [ ] Branch name: `{initiative_root}-{domain}-{service}-{repo_name}`
- [ ] Branch created from current initiative root branch (`bmad-lens-repodiscovery` in this case)
- [ ] Idempotent: if branch already exists → skip with "Branch already exists: {branch_name}" notice, no error
- [ ] Branch pushed to remote
- [ ] Push failure → non-fatal; reported in discovery table as branch_created: "push failed"
- [ ] Per-repo: branch creation failure does not abort remaining repos
- [ ] SC-3: After completion, `/switch` successfully resolves all repos with created branches

**Size:** S  
**Depends on:** S1.3

---

## Epic E4 — Workflow Completion & Module Integration

### S4.1 — Complete `discover/workflow.md`

**As a** developer implementing `/discover`,  
**I need** to complete the `workflows/router/discover/workflow.md` file with full executable step content,  
**So that** the `/discover` command is a complete, runnable workflow with no stubs or TODOs.

**Acceptance Criteria:**
- [ ] All steps (Pre-flight, Scan & Inspect, Governance Integration, Branch Management, Report) are fully specified
- [ ] No `TODO`, `TBD`, `[placeholder]`, or stub placeholder text in the workflow file
- [ ] Sequential processing decision documented inline with rationale: "Sequential chosen over parallel: ≤10 repos at agent pace never approaches 1-hour budget (NFR-1); simpler error isolation" (AR-4 advisory — TD-006 note)
- [ ] Workflow integrates E1, E2, E3 steps in correct dependency order
- [ ] Error paths (empty scan, pull failure, push failure, per-repo error) all have explicit handling

**Size:** L  
**Depends on:** S1.1–S1.3, S2.1–S2.4, S3.1

---

### S4.2 — Discovery Report Output

**As a** user running `/discover`,  
**I need** a human-readable summary table at the end of the discovery run,  
**So that** I can see exactly what was discovered, what governance changes were made, and what branches were created.

**Acceptance Criteria:**
- [ ] Report table columns: `Repo | Language | BMAD | Governance | Branch`
- [ ] Language column shows `unknown` at MVP (enriched by E5 LanguageDetector when enabled)
- [ ] BMAD column: ✅ or ❌
- [ ] Governance column: `updated` / `skipped (user)` / `failed` / `push failed`
- [ ] Branch column: branch name or `failed`
- [ ] Any row with an error includes a ⚠️ prefix
- [ ] Report is displayed after all repos are processed (summary, not inline)
- [ ] A final "What next?" nudge: "You can now use `/switch` to navigate to any discovered repo."

**Size:** S  
**Depends on:** S1.3, S2.4, S3.1

---

### S4.3 — Module Registration Validation

**As a** developer integrating `/discover`,  
**I need** to validate that the `/discover` command is correctly registered in the lens-work module and the prompt file is complete,  
**So that** `@lens /discover` routes to the correct workflow in all environments.

**Acceptance Criteria:**
- [ ] `_bmad/lens-work/module.yaml` has a `/discover` command entry pointing to `workflows/router/discover/workflow.md`
- [ ] `prompts/lens-work.discover.prompt.md` has complete preflight instructions (pull authority repos, load lifecycle.yaml, resolve initiative context)
- [ ] Module entry tested by running `/discover` in VS Code Copilot Chat and verifying correct workflow file is loaded
- [ ] No duplicate command registrations in module.yaml

**Size:** XS  
**Depends on:** S4.1

---

## Epic E5 — NTH Enhancements

### S5.1 — LanguageDetector

**As a** `@lens` agent executing `/discover`,  
**I need** to detect the primary programming language of each discovered repo,  
**So that** language-specific constitutions activate and the initiative config is updated with an accurate language value.

**Acceptance Criteria:**
- [ ] Language detection follows `lifecycle.yaml.language_detection_priority` order:
  1. `.bmad/language` file (explicit override)
  2. Build files (package.json → JavaScript/TypeScript, *.csproj → C#, pom.xml → Java, go.mod → Go, Cargo.toml → Rust, requirements.txt/pyproject.toml → Python, *.gemspec → Ruby)
  3. File extension frequency analysis (top extension → language mapping)
  4. Fallback: `unknown`
- [ ] SC-5 + AR-1 DoD: Detection failure (no matching files) returns `unknown`, never throws
- [ ] Result stored as `language` in RepoResult
- [ ] Multiple languages detected by extension analysis: pick highest file-count language; note "multi-language repo" in report

**Size:** M  
**Depends on:** S1.3

---

### S5.2 — ContextGenerator

**As a** `@lens` agent executing `/discover`,  
**I need** to delegate `project-context.md` generation to the `bmad-bmm-generate-project-context` workflow for each discovered repo,  
**So that** AI agents working in the repo have the context they need from day one.

**Acceptance Criteria:**
- [ ] Delegates to `bmad-bmm-generate-project-context` per discovered repo
- [ ] Failure for one repo → non-fatal; logged in RepoResult; other repos continue
- [ ] `project-context.md` produced in `TargetProjects/{domain}/{service}/{repo_name}/` (or `.bmad/` subdirectory per workflow contract)
- [ ] Report column updated: `context_generated: yes/no/failed`

**Size:** M  
**Depends on:** S1.3, S5.1

---

### S5.3 — StateManager: Language Update

**As a** `@lens` agent executing `/discover`,  
**I need** to update the initiative config's `language` field from `unknown` to the detected language,  
**So that** language-specific constitutions and governance rules activate correctly for the initiative.

**Acceptance Criteria:**
- [ ] After LanguageDetector completes for all repos: determine consensus language
  - All repos same language → update initiative config `language` to detected value
  - Mixed languages → prompt user: "Multiple languages detected ({list}). Update initiative language to the most common ({top})? [Y/N]"
  - All `unknown` → leave as `unknown`
- [ ] Initiative config updated at `_bmad-output/lens-work/initiatives/{id}.yaml`
- [ ] Change committed to devproposal branch

**Size:** S  
**Depends on:** S5.1

---

## Story Summary

| Story | Epic | Title | Size | Priority |
|---|---|---|---|---|
| S1.1 | E1 | InitiativeContextResolver | XS | P0 |
| S1.2 | E1 | FileSystemScanner | S | P0 |
| S1.3 | E1 | RepoInspector | XS | P0 |
| S2.1 | E2 | GovernanceWriter: Pull Gate | XS | P0 |
| S2.2 | E2 | GovernanceWriter: Schema Validation | S | P0 |
| S2.3 | E2 | GovernanceWriter: Idempotent Upsert | M | P0 |
| S2.4 | E2 | GovernanceWriter: Push & Error Isolation | S | P0 |
| S3.1 | E3 | GitOrchestrator: Create /switch Branches | S | P0 |
| S4.1 | E4 | Complete `discover/workflow.md` | L | P0 |
| S4.2 | E4 | Discovery Report Output | S | P0 |
| S4.3 | E4 | Module Registration Validation | XS | P0 |
| S5.1 | E5 | LanguageDetector | M | P1 |
| S5.2 | E5 | ContextGenerator | M | P1 |
| S5.3 | E5 | StateManager: Language Update | S | P1 |

**Total MVP stories:** 11 (S1.1–S4.3)  
**Total NTH stories:** 3 (S5.1–S5.3)

---

## Definition of Done (All Stories)

- [ ] Workflow step/instruction is fully specified with no stubs, placeholders, or TODOs
- [ ] Acceptance criteria are specific and testable
- [ ] Error paths have explicit handling (no silent failures)
- [ ] AR-1: Language fallback returns `unknown`, no exception (E5 stories)
- [ ] AR-2: Governance pull-before-write is documented and enforced in GovernanceWriter stories
- [ ] AR-3: Progress output is incremental per-repo, not batched (E1 stories)
- [ ] SC-4: Idempotency verified — running twice with same repos produces the same state
