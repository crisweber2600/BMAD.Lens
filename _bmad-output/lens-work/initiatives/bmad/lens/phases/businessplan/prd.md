---
stepsCompleted: [step-01-init, step-02-discovery, step-02b-vision, step-02c-executive-summary, step-03-success, step-04-journeys, step-05-domain, step-06-innovation, step-07-project-type, step-08-scoping, step-09-functional, step-10-nonfunctional, step-11-polish, step-12-complete]
inputDocuments:
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/preplan/product-brief.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/businessplan/businessplan-questions.md
workflowType: 'prd'
mode: batch
initiative: bmad-lens-repodiscovery
phase: businessplan
author: John (PM)
created: "2026-03-09"
---

# Product Requirements Document — Repo Discovery

**Author:** CrisWeber
**Date:** 2026-03-09

---

## Executive Summary

### Product Definition

A `/discover` command that completes the post-clone lifecycle after `/new-service`, detecting cloned repos, updating governance inventory, generating `project-context.md`, creating initiative branches, and reporting results.

### Problem

The `@lens` agent scaffolds `TargetProjects/{domain}/{service}/` via `/new-service` but stops there. After the user clones repositories into that folder, nothing detects what was cloned. Governance inventory (`repo-inventory.yaml`) stays stale, `project-context.md` is missing, and `/switch` cannot navigate to any discovered repo. The user's workflow stalls.

### Solution

`/discover` scans `TargetProjects/{domain}/{service}/` for `.git/` directories, detects primary language and BMAD configuration, updates `repo-inventory.yaml` in the governance repo, generates `project-context.md` per repo, creates initiative-aware branches in the control repo for `/switch` navigation, and displays a table-formatted discovery report.

### North-Star Vision

Repos are discovered seamlessly after `/new-service` runs — post-clone detection is a natural, expected step in the service creation lifecycle, not a separate tool the user must remember.

### Primary Differentiator

No alternative exists. This is greenfield tooling addressing a gap in the lens-work lifecycle.

---

## Success Criteria

| ID | Criterion | Measurement |
|---|---|---|
| SC-1 | Governance inventory is complete after discovery | `repo-inventory.yaml` contains entries for 100% of repos with `.git/` directories in the scanned folder |
| SC-2 | Zero data loss on governance updates | If governance push fails, `/discover` does not report success for that operation. Pull-before-push pattern enforced. |
| SC-3 | `/switch` navigates to discovered repos | All discovered repos have corresponding branches in the control repo; `/switch` resolves them correctly |
| SC-4 | Idempotent re-runs produce no corruption | Running `/discover` twice on the same service with identical repos produces identical governance state (after user confirms overwrites) |
| SC-5 | Graceful language fallback | Repos with no detectable language fall through to `unknown` without errors |
| SC-6 | Runtime within budget | Discovery of 10 repos completes within 1 hour |

---

## User Personas

| Persona | Role | Primary Value from `/discover` |
|---|---|---|
| Admin | System administration | Governance inventory stays current — `repo-inventory.yaml` reflects what's cloned |
| Team Lead | Team oversight | Health snapshot of service repos — presence, configuration, language |
| Architect | Technical leadership | Language-specific constitutions activate once language is resolved |
| Product Owner | Product management | Complete service setup in one flow — clone, discover, document, navigate |

---

## User Journeys

### Journey 1: Standard Post-Service Discovery (Admin / PO)

**Trigger:** User has just run `/new-service` and cloned repos into the scaffolded folder.

1. User runs `/new-service` → folder `TargetProjects/{domain}/{service}/` created
2. User clones repos into the folder manually (e.g., `git clone ...`)
3. User replies "done" or runs `/discover`
4. `/discover` scans the folder, detects repos
5. Progress: one line per repo ("✓ discovered: {repo-name}")
6. Governance `repo-inventory.yaml` updated, committed, pushed
7. `project-context.md` generated per repo (nice-to-have)
8. Branches created in control repo for `/switch`
9. Table-formatted report displayed
10. "What next" nudge: "You can now use `/switch` to navigate to any discovered repo."

**Success:** User's workflow continues without manual governance updates.

### Journey 2: Re-Discovery (Admin)

**Trigger:** User adds a new repo to an existing service folder and re-runs `/discover`.

1. User clones another repo into `TargetProjects/{domain}/{service}/`
2. User runs `/discover`
3. `/discover` detects repos, finds some already in `repo-inventory.yaml`
4. For existing repos: warns and asks "Repo X already in inventory. Update? [Y/N]"
5. For new repos: proceeds normally
6. Report shows both updated and newly added entries

**Success:** No data loss, user has explicit control over overwrites.

### Journey 3: Empty Folder (Error Case)

**Trigger:** User runs `/discover` before cloning any repos.

1. User runs `/discover`
2. Scan finds zero `.git/` directories
3. Agent responds: "No repos found. Did you clone them to the right folder?"
4. No governance updates, no branches created

**Success:** Clear error message, no side effects.

### Journey 4: Forgotten Discovery (Failure Detection)

**Trigger:** User clones repos but never runs `/discover`. Another workflow (e.g., `/switch`, `/status`) detects undiscovered repos.

1. User clones repos, forgets to run `/discover`
2. Later workflow detects repos in `TargetProjects/` not in `repo-inventory.yaml`
3. Nudge: "Undiscovered repos detected in {service}. Run `/discover` to complete setup."

**Success:** User is reminded proactively. *(Enhancement — flagged as open question for implementation.)*

---

## Scope

### Must-Have (MVP)

| ID | Requirement |
|---|---|
| MVP-1 | Scan `TargetProjects/{domain}/{service}/` for directories containing `.git/` |
| MVP-2 | Detect `.bmad/` directory presence in each discovered repo |
| MVP-3 | Update `repo-inventory.yaml` with discovered repos (pull → update → commit → push) |
| MVP-4 | Create initiative-aware branches in the control repo for `/switch` navigation |

### Nice-to-Have

| ID | Requirement |
|---|---|
| NTH-1 | Language detection (build files → extensions → `unknown` fallback) |
| NTH-2 | `project-context.md` generation per repo via `bmad-bmm-generate-project-context` |
| NTH-3 | Initiative config `language` field update (replacing `unknown`) |
| NTH-4 | Human-readable discovery report (table format) |

### Out of Scope

- Repository cloning (user clones manually)
- GitHub API calls (detection is filesystem-only — firm constraint)
- Framework detection beyond language-level
- Dependency graph or cross-repo impact analysis
- Monorepo sub-project decomposition
- Remote sync or repository state reconciliation
- Multi-user / concurrent discovery scenarios

---

## Functional Requirements

### FR-1: Repo Scanning

`/discover` scans `TargetProjects/{domain}/{service}/` for immediate child directories containing a `.git/` subdirectory.

- **Input:** domain and service derived from active initiative context
- **Output:** list of discovered repo paths
- **Edge case:** Zero repos found → display "No repos found. Did you clone them to the right folder?" and exit without side effects

### FR-2: BMAD Configuration Detection

For each discovered repo, check for the presence of a `.bmad/` directory.

- **Output per repo:** `bmad_configured: true | false`

### FR-3: Language Detection (Nice-to-Have)

For each discovered repo, detect primary language using `lifecycle.yaml`'s `language_detection_priority`:
1. Check `.bmad/language` file
2. Build file heuristics (e.g., `package.json` → JavaScript/TypeScript, `*.csproj` → C#)
3. File extension frequency analysis
4. Fallback to `unknown`

- **Output per repo:** `language: {detected_language}`
- **Accuracy:** Best-effort; repos without build files fall through to `unknown` gracefully

### FR-4: Governance Inventory Update

Update `repo-inventory.yaml` in the governance repo (`TargetProjects/lens/lens-governance/`).

- **Pull-before-push:** Always `git pull` the governance repo before writing. If pull fails, report error and continue with remaining repos.
- **Schema fields per entry:** `name`, `path`, `language`, `bmad_configured`, `domain`, `service`
- **Idempotency:** If a repo already exists in inventory, warn and ask before overwriting
- **Commit message:** `[discover] Add/update repos for {domain}/{service}`
- **Push failure:** Continue with remaining repos and report partial success. Do not report governance update as successful if push fails.

### FR-5: Initiative Branch Creation

Create branches in the **control repo** for each discovered repo so `/switch` can navigate to them.

- **Branch naming:** Same convention as control repo branches (not in target project repos)
- **Scope:** Control repo only — no branches created inside `TargetProjects/` repos

### FR-6: Project Context Generation (Nice-to-Have)

For each discovered repo, invoke `bmad-bmm-generate-project-context` workflow.

- **Inputs:** repo path, detected language
- **Output:** `project-context.md` created in the repo

### FR-7: Initiative Config Update (Nice-to-Have)

Update the initiative config's `language` field from `unknown` to the detected value.

### FR-8: Discovery Report (Nice-to-Have)

Display a table-formatted summary report after discovery completes.

- **Columns:** repo name, language (if detected), BMAD configured (Y/N), governance status, branch status, any warnings
- **Zero repos:** Display error message instead of empty table

### FR-9: Proactive Discovery Nudge (Enhancement — Open Question)

When other workflows detect repos in `TargetProjects/` not present in `repo-inventory.yaml`, nudge the user to run `/discover`.

- **Scope:** Design-only in this PRD; implementation deferred pending architecture review

---

## Non-Functional Requirements

### NFR-1: Performance

Discovery of a service folder containing up to 10 repos completes within 1 hour. No per-repo SLA required.

### NFR-2: Reliability

`/discover` is idempotent: running it multiple times on the same service with identical repos produces identical governance state (after user confirms overwrites). No data corruption on re-runs.

### NFR-3: Data Integrity

Zero data loss on governance updates. If governance push fails, the governance update is not reported as successful. Pull-before-push pattern is mandatory.

### NFR-4: Error Recovery

On push failure mid-discovery, proceed with remaining repos and report partial success. The report clearly indicates which operations succeeded and which failed.

### NFR-5: Graceful Degradation

Repos with no detectable language fall through to `unknown` without errors. Missing build files or empty repos do not crash the workflow.

---

## Open Questions

| ID | Question | Context |
|---|---|---|
| OQ-1 | Should `/new-service` automatically suggest `/discover` after completion? | User's primary failure case is forgetting to run `/discover`. Proactive nudge reduces this risk. |
| OQ-2 | Should proactive detection of undiscovered repos be built into `/status` or `/switch`? | Journey 4 describes this, but implementation approach needs architecture review. |
| OQ-3 | What is the exact `repo-inventory.yaml` schema and validation? | User confirmed all fields but schema definition lives in governance repo — needs cross-reference. |

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Monorepos with multiple languages | Medium | Low | Detect by highest file-count language; document limitation |
| Build files absent (config/doc repos) | Medium | Low | Fall through to `unknown`; flag in report |
| Governance repo not cloned | Low | High | Preflight checks verify governance repo presence |
| `repo-inventory.yaml` schema drift | Low | Medium | Define schema in governance README; validate on write |
| User clones repos to wrong folder | Low | Medium | Validate against `target_projects_path` from `bmadconfig.yaml` |
| User forgets to run `/discover` | Medium | Medium | Proactive nudge from downstream workflows (OQ-1, OQ-2) |
