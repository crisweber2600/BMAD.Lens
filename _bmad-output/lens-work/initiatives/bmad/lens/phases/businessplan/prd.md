---
stepsCompleted:
  - step-01-init
  - step-02-discovery
  - step-02b-vision
  - step-02c-executive-summary
  - step-03-success
  - step-04-journeys
  - step-05-domain
  - step-06-innovation
  - step-07-project-type
  - step-08-scoping
  - step-09-functional
  - step-10-nonfunctional
  - step-11-polish
  - step-12-complete
inputDocuments:
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/preplan/product-brief.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/businessplan/businessplan-questions.md
workflowType: prd
mode: batch
initiative: bmad-lens-repodiscovery
---

# Product Requirements Document — Repo Discovery

**Author:** CrisWeber (facilitated by John, PM)
**Date:** 2026-03-09
**Initiative:** bmad-lens-repodiscovery

---

## Executive Summary

The `/discover` command completes the post-clone lifecycle after `/new-service`, detecting cloned repositories within `TargetProjects/{domain}/{service}/`, updating the governance inventory (`repo-inventory.yaml`), generating `project-context.md` for AI agents, creating initiative-aware branches for `/switch` navigation, and reporting results. There is no alternative tooling — without `/discover`, the workflow stalls after cloning: governance is out of date, project context is missing, and branch navigation is broken.

**North-Star Vision:** After running `/new-service` and cloning repos, `/discover` seamlessly completes the service setup — governance inventory is current, project context is generated, and branches are navigable — all in one command.

**Primary Differentiator:** No alternative exists. Manual post-clone setup requires separate governance updates, project-context generation, and branch creation across multiple tools and workflows. `/discover` consolidates this into a single automated step.

---

## Success Criteria

| ID | Metric | Target | Measurement |
|----|--------|--------|-------------|
| SC-1 | Governance integrity | Zero data loss — if governance push fails, discovery must not report success | Pull-then-push strategy; failure halts execution |
| SC-2 | Inventory completeness | After `/discover`, `repo-inventory.yaml` contains entries for all repos found in the service folder | Diff inventory before/after |
| SC-3 | Project context generation | Each discovered repo has `project-context.md` generated via standard workflow | File existence check per repo |
| SC-4 | Branch navigation | `/switch` can navigate to any discovered repo | Navigation test per discovered repo |
| SC-5 | Language detection | Initiative configs have `language` updated from `unknown` to detected value (when detectable) | Config field check |
| SC-6 | Graceful fallback | Repos with no detectable language fall through to `unknown` without crash | No-language repo included in test |
| SC-7 | Discovery report | Human-readable summary displayed showing repos found, languages detected, and any failures | Report output verification |

---

## User Personas

| Persona | Role | Primary Value from `/discover` |
|---------|------|-------------------------------|
| Admin | Governance maintainer | Inventory stays current — `repo-inventory.yaml` reflects what's cloned |
| Team Lead | Service health overview | Health snapshot — what's present, configured, and what language each uses |
| Architect | Constitution enforcement | Language-specific constitutions activate once language is resolved |
| Product Owner | End-to-end flow | Complete service setup in one flow — clone, discover, document, navigate |

No additional personas required.

---

## User Journeys

### Journey 1: Admin — Post-Service Discovery

**Trigger:** Admin has just run `/new-service` and cloned repositories into `TargetProjects/{domain}/{service}/`.

1. Admin runs `/discover`
2. Agent scans the service folder for `.git/` directories
3. For each discovered repo: detects language, checks BMAD config presence
4. Agent updates `repo-inventory.yaml` in the governance repo (pull, merge, commit, push)
5. Agent generates `project-context.md` per repo
6. Agent creates initiative-aware branches in the control repo
7. Agent displays discovery report table
8. Agent nudges: "All done! You can now use `/switch` to navigate to any discovered repo."

**Post-condition:** Governance is current, branches are navigable, AI agents have project context.

### Journey 2: Architect — Language Resolution

**Trigger:** Architect clones repos after `/new-service` to begin technical planning.

1. Architect runs `/discover`
2. Discovery detects primary language per repo (build files → file extensions → `unknown`)
3. Initiative config `language` field updated from `unknown` to detected value
4. Language-specific constitutions now activate for those repos
5. Discovery report confirms: languages detected, BMAD configs found/absent

**Post-condition:** Constitutional enforcement is language-aware.

### Journey 3: Failure — Discovery Before Cloning

**Trigger:** User runs `/discover` before cloning any repos.

1. User runs `/discover`
2. Agent scans service folder — finds zero `.git/` directories
3. Agent displays: "No repos found. Did you clone them to the right folder?"
4. User clones repos, then runs `/discover` again

**Post-condition:** Graceful handling, no crash, clear guidance.

### Journey 4: Failure — Undiscovered Repos

**Trigger:** User clones repos but forgets to run `/discover`.

This is the most common failure scenario. Detection of undiscovered repos should be integrated into other lifecycle gates (e.g., preflight checks in phase workflows could warn: "Found cloned repos not in governance inventory — run `/discover`").

---

## Scope & MVP Prioritization

### Must Have (MVP)

| ID | Feature | Description |
|----|---------|-------------|
| F-1 | Repo scanning | Scan `TargetProjects/{domain}/{service}/` for directories containing `.git/` |
| F-2 | BMAD config detection | Check for `.bmad/` directory presence in each discovered repo |
| F-3 | Governance inventory update | Write discovered repos to `repo-inventory.yaml`, commit, and push (pull-first strategy) |
| F-4 | Initiative branch creation | Create branches in the control repo for `/switch` navigation |

### Nice to Have (v1)

| ID | Feature | Description |
|----|---------|-------------|
| F-5 | Language detection | Detect primary language using build files → file extensions → `unknown` fallback |
| F-6 | Project context generation | Invoke `bmad-bmm-generate-project-context` per discovered repo |
| F-7 | Language field update | Update initiative config `language` field from `unknown` to detected value |
| F-8 | Discovery report | Display human-readable table of discovery results |

### Out of Scope

- Repository cloning (user clones manually)
- GitHub API calls (filesystem-only detection — firm constraint, not a preference)
- Framework detection beyond language-level
- Dependency graph or cross-repo impact analysis
- Monorepo sub-project decomposition
- Remote sync or repository state reconciliation
- Phased rollout — all features ship together

---

## Functional Requirements

### FR-1: Repo Scanning

**Trigger:** User runs `/discover` after `/new-service` and cloning.

**Behavior:**
1. Resolve service folder path from initiative config: `TargetProjects/{domain}/{service}/`
2. Walk directory tree (depth 1) looking for subdirectories containing `.git/`
3. Each directory with `.git/` is a discovered repository
4. If zero repos found: display "No repos found. Did you clone them to the right folder?" and exit

**Constraints:**
- Filesystem-only — no GitHub API calls
- Scan only the service folder, not recursive submodules

### FR-2: BMAD Config Detection

For each discovered repo:
1. Check for `.bmad/` directory existence
2. Record `bmad_configured: true|false` in discovery results

### FR-3: Language Detection (Nice to Have)

For each discovered repo, detect primary language using this priority:
1. Explicit `{language}` field in initiative config (if already set, skip detection)
2. `.bmad/language` file in target repository
3. Build file heuristics: `package.json` → typescript, `pyproject.toml`/`setup.py` → python, `go.mod` → go, `pom.xml`/`build.gradle` → java, `*.csproj`/`*.sln` → csharp, `Cargo.toml` → rust, `composer.json` → php, `build.gradle.kts` → kotlin, `Package.swift` → swift, `CMakeLists.txt`/`Makefile` → cpp
4. Source code file extension distribution (highest count wins)
5. Fallback to `unknown`

**Supported languages:** typescript, python, go, java, csharp, rust, php, kotlin, swift, cpp (per `lifecycle.yaml`).

### FR-4: Governance Inventory Update

**Schema** (per `repo-inventory.yaml` existing format):

```yaml
- name: {repo-directory-name}
  domain: {initiative-domain}
  layer: service
  local_path: TargetProjects/{domain}/{service}/{repo-name}
  remote_url: {detected-from-git-config}
  default_branch: {detected-from-git}
  role: target
  status: active
  notes: "Discovered by /discover on {date}"
```

Required fields: `name`, `domain`, `layer`, `local_path`, `remote_url`, `default_branch`, `role`, `status`, `notes`.

Optional fields (if language detection enabled): `language`, `bmad_configured`.

**Update strategy:**
1. Pull latest governance repo before any writes
2. Read existing `repo-inventory.yaml`
3. For each discovered repo, check if entry already exists (match by `name` + `local_path`)
4. If exists: warn and ask user whether to update or skip (idempotency behavior: warn-and-ask)
5. If new: add to `repos.matched` array
6. Write updated file
7. Commit and push
8. If push fails: stop immediately and report failure (zero data loss — never report success on push failure)

### FR-5: Project Context Generation (Nice to Have)

For each discovered repo:
1. Invoke `bmad-bmm-generate-project-context` workflow
2. Inputs: repo path, detected language (no additional inputs required)
3. Output: `project-context.md` written into the repo

### FR-6: Initiative Branch Creation

Create branches in the **control repo** (not in target project repos) for `/switch` navigation:
- Branch naming follows existing control repo convention
- Branches reference discovered repos but do not modify target repo branches
- `/switch` can then navigate to discovered repo working directories

### FR-7: Initiative Config Update (Nice to Have)

Update the initiative config YAML:
- Set `language` field from `unknown` to detected language value
- Only update if language was successfully detected (not `unknown`)

### FR-8: Discovery Report (Nice to Have)

Display a summary table after all operations complete:

```
📋 Discovery Report — {domain}/{service}

| Repo | Language | BMAD Config | Inventory | Context | Branch |
|------|----------|-------------|-----------|---------|--------|
| RepoA | typescript | ✓ | ✓ added | ✓ generated | ✓ created |
| RepoB | unknown | ✗ | ✓ added | ✓ generated | ✓ created |

All done! You can now use /switch to navigate to any discovered repo.
```

### FR-9: Idempotency

When `/discover` is run on a service that was previously discovered:
- Warn the user that repos already exist in inventory
- Ask whether to update existing entries or skip
- Safe to run multiple times with identical outcomes when choosing skip

### FR-10: Error Recovery

If governance push fails mid-discovery:
- Continue processing remaining repos
- Report partial success with clear indication of what failed
- Never report full success when governance push failed (zero data loss contract)

### FR-11: Undiscovered Repo Detection

Lifecycle preflight checks (in phase workflows) should detect repos cloned into `TargetProjects/{domain}/{service}/` that are not yet in `repo-inventory.yaml` and warn: "Found cloned repos not in governance inventory — run `/discover`."

---

## Non-Functional Requirements

### NFR-1: Performance

- Maximum acceptable runtime for 10 repos: 1 hour
- No hard execution time constraint for typical usage (1–5 repos)
- Operations are sequential per repo (scan → detect → update → generate → branch)

### NFR-2: Reliability

- Fully idempotent: safe to run multiple times with identical outcomes
- Pull-before-push governance strategy prevents data loss
- Graceful degradation: repos with no detectable language fall to `unknown`

### NFR-3: Security

- No specific read/write restrictions beyond standard workspace boundaries
- No secrets emitted in output
- Filesystem-only detection — no network calls for repo analysis (firm constraint)

### NFR-4: Maintainability

- Language detection patterns are not externalized — they are inline in the implementation
- Supported languages list lives in `lifecycle.yaml` (already the case)

---

## Assumptions

1. Repos are cloned by the user into `TargetProjects/{domain}/{service}/` before `/discover` runs
2. Each repo is a standard git repository (`.git/` directory present)
3. One primary language per repo is sufficient for constitution enforcement
4. Detection runs locally — no network access required for repo analysis
5. The governance repo is cloned at `TargetProjects/lens/lens-governance/`
6. `repo-inventory.yaml` follows the existing schema (see FR-4)

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Monorepos with multiple languages | Medium | Low | Detect by highest file-count language; document limitation |
| Build files absent (config/doc repos) | Medium | Low | Fall through to `unknown` gracefully; flag in report |
| Governance repo not cloned | Low | High | Preflight checks verify governance repo presence |
| `repo-inventory.yaml` schema drift | Low | Medium | Validate on write against known schema |
| User clones repos to wrong folder | Low | Medium | Validate against `target_projects_path` from config |
| User forgets to run `/discover` | High | Medium | Preflight warning in phase workflows (FR-11) |

---

## Open Questions

None flagged by stakeholder. All decisions resolved in batch questionnaire.
