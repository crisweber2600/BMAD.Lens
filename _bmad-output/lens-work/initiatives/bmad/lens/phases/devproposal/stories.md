---
artifact: stories
phase: devproposal
initiative: bmad-lens-repodiscovery
author: John (PM)
created: "2026-03-09"
inputDocuments:
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/devproposal/epics.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/businessplan/prd.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/techplan/architecture.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/techplan/tech-decisions.md
---

# Stories — Repo Discovery (`/discover` command)

**Author:** John (PM)
**Date:** 2026-03-09
**Initiative:** bmad-lens-repodiscovery

---

## Story Index

| ID | Title | Epic | Priority |
|---|---|---|---|
| S-001 | Register /discover in module.yaml | E-001 | P0 |
| S-002 | Author lens-work.discover.prompt.md | E-001 | P0 |
| S-003 | Author discover/workflow.md router | E-001 | P0 |
| S-004 | Adversarial review: E-001 Command Wiring | E-001 | P0 |
| S-005 | PreFlight + InitiativeContextResolver | E-002 | P0 |
| S-006 | FileSystemScanner (FR-1) | E-002 | P0 |
| S-007 | RepoInspector (FR-2) | E-002 | P0 |
| S-008 | GovernanceWriter (FR-4) + Idempotency | E-002 | P0 |
| S-009 | GitOrchestrator (FR-5) | E-002 | P0 |
| S-010 | MVP Progress Output | E-002 | P0 |
| S-011 | Smoke Test — End-to-End MVP | E-002 | P0 |
| S-012 | Adversarial review: E-002 Core Discovery | E-002 | P0 |
| S-013 | LanguageDetector (FR-3) | E-003 | P1 |
| S-014 | ContextGenerator (FR-6) | E-003 | P1 |
| S-015 | StateManager (FR-7) | E-003 | P1 |
| S-016 | ReportRenderer (FR-8) | E-003 | P1 |
| S-017 | Adversarial review: E-003 Enhancements | E-003 | P1 |

---

## E-001: Command Wiring

---

### S-001 — Register /discover in module.yaml

**Epic:** E-001
**Priority:** P0
**Depends on:** None

**As a** developer implementing the `/discover` command,
**I want** the command registered in `module.yaml` with correct aliases, agent, and description,
**so that** the lens-work module routes `/discover` correctly and it appears in `/help` output.

**Implementation target:** `bmad.lens.release/_bmad/lens-work/module.yaml`

**Acceptance Criteria:**
- [ ] `module.yaml` contains a `/discover` entry under `commands`
- [ ] Entry includes: `name: discover`, `aliases: [/discover]`, `description`, `agent: "@lens"`, `workflow: router/discover/workflow.md`
- [ ] Entry is consistent in structure with existing command entries (e.g., `/preplan`, `/businessplan`)
- [ ] `/help` output includes `/discover` when module.yaml is loaded
- [ ] No other commands are modified

**Notes:** The stub entry added during the TechPlan YOLO edit should be reviewed and formalised to match the full command registration pattern.

---

### S-002 — Author lens-work.discover.prompt.md

**Epic:** E-001
**Priority:** P0
**Depends on:** S-001

**As a** user invoking `@lens /discover` in VS Code Copilot Chat,
**I want** a complete instruction file that loads context and delegates to the discover workflow,
**so that** the agent has unambiguous instructions for executing the discovery process.

**Implementation target:** `bmad.lens.release/_bmad/lens-work/prompts/lens-work.discover.prompt.md`

**Acceptance Criteria:**
- [ ] Prompt file loads `_bmad/lens-work/bmadconfig.yaml` and `lifecycle.yaml`
- [ ] Prompt instructs the agent to adopt the `@lens` persona
- [ ] Prompt delegates to `_bmad/lens-work/workflows/router/discover/workflow.md`
- [ ] Prompt includes a model declaration (`model: claude-sonnet-4-6` or project standard)
- [ ] Prompt is consistent in structure with `lens-work.techplan.prompt.md` or equivalent sibling
- [ ] Stub content from the TechPlan YOLO edit is replaced (not appended to)

---

### S-003 — Author discover/workflow.md router

**Epic:** E-001
**Priority:** P0
**Depends on:** S-001, S-002

**As a** `@lens` agent executing `/discover`,
**I want** a complete workflow router file that sequences the discovery pipeline steps,
**so that** execution is deterministic, repeatable, and testable.

**Implementation target:** `bmad.lens.release/_bmad/lens-work/workflows/router/discover/workflow.md`

**Acceptance Criteria:**
- [ ] Workflow file has YAML frontmatter with `name`, `description`, `agent`, `trigger`, `category`, `phase_name`
- [ ] Workflow sequences: PreFlight → FileSystemScanner → RepoInspector → GovernanceWriter → GitOrchestrator → Output
- [ ] Each step references the corresponding architecture component (FR-1 through FR-5)
- [ ] Error handling: empty scan result displays "No repos found" message and exits cleanly
- [ ] Per-repo loop implements error isolation (continue on single-repo failure)
- [ ] NTH feature hooks (FR-3, FR-6, FR-7, FR-8) included as conditional blocks (off by default until E-003)
- [ ] Workflow includes a Phase Completion block (commit, push, final output)
- [ ] Stub content from the TechPlan YOLO edit is replaced

---

### S-004 — Adversarial Review: E-001 Command Wiring

**Epic:** E-001
**Priority:** P0
**Depends on:** S-001, S-002, S-003
**Gate:** E-001 must pass this before E-002 begins

**As a** reviewer,
**I want** the command wiring files adversarially reviewed for correctness, consistency, and completeness,
**so that** the foundation for E-002 implementation is solid.

**Acceptance Criteria:**
- [ ] All three files (module.yaml entry, prompt.md, workflow.md) reviewed as a unit
- [ ] Command registration is consistent: aliases match, workflow path resolves
- [ ] Prompt file correctly delegates without ambiguity
- [ ] Workflow router correctly sequences all pipeline stages
- [ ] No orphaned stubs, no TODO markers, no placeholder text
- [ ] Adversarial checklist: at least 3 failure modes identified and addressed in the workflow

---

## E-002: Core Discovery (MVP)

---

### S-005 — PreFlight + InitiativeContextResolver

**Epic:** E-002
**Priority:** P0
**Depends on:** S-003 (workflow router exists)

**As a** `@lens` agent starting `/discover`,
**I want** a pre-flight check that resolves initiative context and validates prerequisites before any scan or write,
**so that** discovery never starts in an invalid or unconfigured environment.

**Acceptance Criteria:**
- [ ] Loads `_bmad-output/lens-work/state.yaml` and active initiative config
- [ ] Resolves `domain`, `service`, and `scan_path = TargetProjects/{domain}/{service}/` from initiative config
- [ ] Validates `scan_path` exists as a directory; exits with error "Run /new-service first" if not
- [ ] Validates governance repo is present (path from governance-setup or initiative config); exits with "Run /onboard to configure" if missing
- [ ] Confirms working directory is clean (or stashes cleanly)
- [ ] Outputs: "Pre-flight ✅ — scanning `{scan_path}`" before proceeding
- [ ] All preflight failures are hard exits with user-visible error messages (no silent failures)

---

### S-006 — FileSystemScanner (FR-1)

**Epic:** E-002
**Priority:** P0
**Depends on:** S-005

**As a** `/discover` workflow,
**I want** to enumerate all immediate child directories of `scan_path` that contain a `.git/` subdirectory,
**so that** the discovery pipeline has a precise list of locally cloned repos.

**Acceptance Criteria:**
- [ ] Scans only immediate children of `scan_path` (not recursive)
- [ ] A directory qualifies as a repo if and only if it contains a `.git/` subdirectory
- [ ] Returns a list of repo objects: `{ name: string, path: string }`
- [ ] If zero repos found: displays "No repos found in {scan_path}. Did you clone them to the right folder?" and exits cleanly with no side effects (no governance writes, no branch creation)
- [ ] Does not throw on empty result — empty list is a valid return value
- [ ] Outputs one progress line per discovered repo: "Found: {repo_name}"

---

### S-007 — RepoInspector (FR-2)

**Epic:** E-002
**Priority:** P0
**Depends on:** S-006

**As a** `/discover` workflow,
**I want** each discovered repo inspected for BMAD configuration presence,
**so that** the governance inventory accurately reflects which repos have BMAD configured.

**Acceptance Criteria:**
- [ ] For each repo in the scanner output, checks for presence of `.bmad/` directory at repo root (top-level only, not recursive)
- [ ] Returns `bmad_configured: true` if `.bmad/` directory exists, `false` otherwise
- [ ] Failure to inspect a single repo (e.g., permission error) is caught and recorded as an error for that repo; processing continues for remaining repos (per-repo error isolation)
- [ ] Does not modify any files — read-only operation
- [ ] Language detection is NOT performed in this story (deferred to S-013 in E-003); `language` field defaults to `"unknown"` for all repos in this story

---

### S-008 — GovernanceWriter (FR-4) + Idempotency

**Epic:** E-002
**Priority:** P0
**Depends on:** S-007

**As a** `/discover` workflow,
**I want** each discovered repo's record written to `repo-inventory.yaml` in the governance repo,
**so that** the governance registry is accurate and up to date.

**Acceptance Criteria:**

**Pull gate:**
- [ ] `git pull` executed on the governance repo before any read or write (hard gate — NFR-3)
- [ ] If `git pull` fails: exit entire `/discover` workflow with error message; no partial writes

**Idempotency:**
- [ ] Before writing, reads current `repo-inventory.yaml`; if file absent, treats as empty `repos: []`
- [ ] For each repo: checks if `name` already exists in inventory
- [ ] If exists: asks user `[Y/N] Repo "{name}" already in inventory. Update? Skip to use [N].`
  - `Y` → overwrites entry
  - `N` → logs "Skipped: {name}" and continues
- [ ] Silent overwrite is NOT permitted (no `--force` flag at this time)

**Write schema:**
- [ ] Each entry written with: `name`, `path`, `language`, `bmad_configured`, `domain`, `service`, `discovered_at: ISO8601`

**Commit + push:**
- [ ] After all entries processed: `git add repo-inventory.yaml`, `git commit -m "[discover] Add/update repos for {domain}/{service}"`, `git push`
- [ ] If `git push` fails: mark all batch entries as `governance_status: "❌ Failed"` in the report — do NOT report success
- [ ] Push failure is non-fatal to the overall workflow — processing continues to GitOrchestrator

---

### S-009 — GitOrchestrator (FR-5)

**Epic:** E-002
**Priority:** P0
**Depends on:** S-005 (initiative context available)

**As a** `/discover` workflow,
**I want** a branch created in the control repo for each discovered repo,
**so that** `/switch` can navigate the user to any discovered repo's working context.

**Acceptance Criteria:**
- [ ] For each discovered repo, creates a branch in the control repo (BMAD.Lens) named `{initiative_root}-{domain}-{service}-{repo_name}`
- [ ] Uses `git checkout -b {branch_name}` and then returns to the original branch; does NOT leave the user on the new branch
- [ ] If branch already exists: records `branch_status: "Exists"` — NOT an error, processing continues
- [ ] If branch creation fails (other than "already exists"): records `branch_status: "❌ Failed"` — non-fatal, continues to next repo
- [ ] Pushes each newly created branch to origin
- [ ] **HARD CONSTRAINT:** No branches are created inside `TargetProjects/{domain}/{service}/**` repos — control repo only
- [ ] Returns to original branch after all branch operations complete

---

### S-010 — MVP Progress Output

**Epic:** E-002
**Priority:** P0
**Depends on:** S-005 (for scan path), S-006, S-007, S-008, S-009

**As a** user running `/discover`,
**I want** real-time one-line progress status per repo as the pipeline runs,
**so that** I know the command is working and can see which repos succeeded or failed.

**Acceptance Criteria:**
- [ ] For each repo, the following output is emitted inline (during processing, not at end):
  ```
  ✓ {repo_name} — BMAD: {✓/✗} | Governance: {Updated/Skipped/❌ Failed} | Branch: {Created/Exists/❌ Failed}
  ```
- [ ] Summary line at end of execution: `{n} repo(s) discovered and registered.`
- [ ] Follow-up nudge: `You can now use /switch to navigate to any discovered repo.`
- [ ] If any repo has an error, a final warning is included: `⚠️ {m} repo(s) had errors — review the lines above.`
- [ ] Output is consistent whether or not NTH features (E-003) are active

---

### S-011 — Smoke Test: End-to-End MVP

**Epic:** E-002
**Priority:** P0
**Depends on:** S-005 – S-010 all complete

**As a** developer validating the MVP implementation,
**I want** an end-to-end smoke test using a synthetic fixture,
**so that** the full pipeline is validated before shipping.

**Test Fixture:**
- A temporary folder `TargetProjects/test-domain/test-service/` containing two subdirectories, each with an empty `.git/` directory:
  - `test-repo-alpha/.git/`
  - `test-repo-beta/.git/` (with a `.bmad/` directory present)

**Acceptance Criteria:**
- [ ] `/discover` on the fixture resolves `scan_path` to the fixture folder
- [ ] FileSystemScanner finds exactly 2 repos
- [ ] RepoInspector detects `test-repo-beta` has BMAD configured, `test-repo-alpha` does not
- [ ] GovernanceWriter writes 2 entries to `repo-inventory.yaml` with correct fields
- [ ] GitOrchestrator creates 2 control-repo branches following the naming convention
- [ ] MVP output displays correct per-repo status for both repos
- [ ] Second run on same fixture triggers idempotency prompt for both existing entries
- [ ] Fixture is cleaned up after test (temp dirs removed, test branches deleted, inventory entries removed)

---

### S-012 — Adversarial Review: E-002 Core Discovery

**Epic:** E-002
**Priority:** P0
**Depends on:** S-005 – S-011
**Gate:** E-002 complete; required before E-003 begins

**Acceptance Criteria:**
- [ ] All MVP stories (S-005 to S-011) reviewed as a unit
- [ ] Pull-before-push gate validated: impossible to write without prior pull
- [ ] Idempotency validated: no scenario produces silent overwrite
- [ ] Per-repo error isolation validated: at least 3 failure injection tests pass
- [ ] Hard constraint validated: no TargetProjects branch creation paths exist in workflow
- [ ] No silent failures in any pipeline step
- [ ] Adversarial checklist produces zero unresolved blockers

---

## E-003: Discovery Enhancements (NTH)

---

### S-013 — LanguageDetector (FR-3)

**Epic:** E-003
**Priority:** P1
**Depends on:** E-002 complete (RepoInspector story S-007 in particular)

**As a** `/discover` workflow,
**I want** to detect the primary programming language of each repo using a priority-ordered heuristic,
**so that** governance inventory and initiative config have accurate language metadata.

**Detection priority order (from `lifecycle.yaml` `language_detection_priority`):**
1. `.bmad/language` override file (content read verbatim)
2. Build file heuristics:
   - `package.json` → `typescript` (if `.ts` files present) else `javascript`
   - `*.csproj` or `*.sln` → `csharp`
   - `pyproject.toml`, `setup.py`, or `requirements.txt` → `python`
   - `go.mod` → `go`
   - `pom.xml` or `build.gradle` → `java`
   - `Cargo.toml` → `rust`
3. File extension frequency (top extension by count): `.ts` → `typescript`, `.cs` → `csharp`, `.py` → `python`, etc.
4. Fallback: `"unknown"`

**Acceptance Criteria:**
- [ ] Language detection is integrated into the RepoInspector pipeline step (replaces the `"unknown"` default set in S-007)
- [ ] Priority order above is followed strictly; step 2 is not reached if step 1 produces a result
- [ ] Never throws — all exceptions caught and result defaults to `"unknown"`
- [ ] Language identifier returned matches values in `lifecycle.yaml` `supported_languages` list
- [ ] `"unknown"` is a valid, non-error return value
- [ ] Result is passed to GovernanceWriter's entry schema (updates `language` field from `"unknown"`)

---

### S-014 — ContextGenerator (FR-6)

**Epic:** E-003
**Priority:** P1
**Depends on:** S-013 (language detection feeds context generation inputs)

**As a** `/discover` workflow,
**I want** `project-context.md` generated for each discovered repo via the `bmad-bmm-generate-project-context` workflow,
**so that** each repo has the required context file for subsequent AI-assisted development workflows.

**Acceptance Criteria:**
- [ ] After GovernanceWriter + GitOrchestrator complete for a repo, the `bmad-bmm-generate-project-context` workflow is invoked with `{ repo_path, language }`
- [ ] Output `project-context.md` is created at `{repo_path}/project-context.md`
- [ ] If the delegated workflow fails for any reason: failure is caught, result recorded as `project_context: "⚠️ Failed"`, pipeline continues to next repo
- [ ] Does not block or slow the MVP pipeline (runs after per-repo MVP steps complete)
- [ ] Does not require network access (delegated workflow uses local tooling)

---

### S-015 — StateManager (FR-7)

**Epic:** E-003
**Priority:** P1
**Depends on:** S-013 (language detection results available)

**As a** `/discover` workflow,
**I want** the initiative config `language` field updated when all discovered repos share a consistent primary language,
**so that** the initiative's context reflects the correct language for constitution resolution and tooling.

**Update rule (conservative consensus):**
- Update only if ALL detected languages (non-`"unknown"`) are the same value
- Example: 3 repos all return `csharp` → update initiative config `language: csharp`
- Example: 2 repos return `csharp`, 1 returns `typescript` → NO update, `language` remains `unknown`
- Example: all repos return `"unknown"` → NO update

**Acceptance Criteria:**
- [ ] Runs after all per-repo language detection is complete
- [ ] Applies the conservative consensus rule above
- [ ] If update is triggered: modifies `language` field in `_bmad-output/lens-work/initiatives/{id}.yaml`
- [ ] Commits the config update to the current branch with message `[discover] Update initiative language: {language}`
- [ ] If no consensus: logs "Language consensus not reached — initiative language unchanged" and does not modify the config
- [ ] Does not error if initiative config is already set to the detected language (idempotent)

---

### S-016 — ReportRenderer (FR-8)

**Epic:** E-003
**Priority:** P1
**Depends on:** S-013, S-014, S-015 (all result data available)

**As a** user running `/discover`,
**I want** a formatted summary table at the end of execution showing the full results per repo,
**so that** I can verify what happened and identify any issues without reading individual log lines.

**Report format:**
```
📋 Discovery Report

| Repo | Language | BMAD | Governance | Branch | Context | Status |
|------|----------|------|------------|--------|---------|--------|
| {name} | {lang} | ✓/✗ | Updated/Skipped/❌ | Created/Exists/❌ | ✓/⚠️/— | ✅/⚠️ |

{n} repo(s) discovered. {m} succeeded, {k} had warnings.
You can now use /switch to navigate to any discovered repo.
```

**Column definitions:**
| Column | Values |
|---|---|
| `Language` | detected language or `unknown` |
| `BMAD` | `✓` (`.bmad/` exists) / `✗` |
| `Governance` | `Updated` / `Skipped` / `❌ Failed` |
| `Branch` | `Created` / `Exists` / `❌ Failed` |
| `Context` | `✓` (project-context.md created) / `⚠️ Failed` / `—` (not attempted) |
| `Status` | `✅` (all operations succeeded or skipped cleanly) / `⚠️` (at least one failure) |

**Acceptance Criteria:**
- [ ] Table is rendered after all repos have been processed (not inline)
- [ ] All columns populated per repo using the pipeline result records
- [ ] Summary counts are correct
- [ ] Follow-up nudge rendered: "You can now use `/switch` to navigate to any discovered repo."
- [ ] Replaces the per-line progress output from S-010 (or supplements it — one-line progress during processing, table at end)

---

### S-017 — Adversarial Review: E-003 Discovery Enhancements

**Epic:** E-003
**Priority:** P1
**Depends on:** S-013 – S-016
**Gate:** E-003 complete; closes the devproposal epic set

**Acceptance Criteria:**
- [ ] All NTH stories (S-013 to S-016) reviewed as a unit
- [ ] Language detection: no paths throw; `"unknown"` is always reachable as fallback
- [ ] StateManager: conservative consensus rule cannot silently corrupt an intentional language override
- [ ] ContextGenerator: no scenario blocks the MVP pipeline due to NTH failure
- [ ] ReportRenderer: table renders correctly for mixed success/failure results
- [ ] No regressions introduced to MVP pipeline (E-002) by NTH additions
- [ ] Adversarial checklist produces zero unresolved blockers
