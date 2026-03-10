---
artifact: product-brief
phase: preplan
initiative: bmad-lens-repodiscovery
author: Mary (Analyst)
created: "2026-03-09"
stepsCompleted: [1, 2, 3, 4, 5]
---

# Product Brief — Repo Discovery

## Problem Statement

The `@lens` agent operates in a multi-repository control workspace where target code repositories live under `TargetProjects/`. When a user runs `/new-service` to create a service-level initiative, the workflow scaffolds the `TargetProjects/{domain}/{service}/` folder but stops there. The user is expected to clone relevant repositories into that folder, but there is no automated follow-up to:

1. **Detect what repos were cloned** — after the user says "done," nothing inspects the folder to discover what landed there.
2. **Update the canonical repo inventory** — `repo-inventory.yaml` in the governance repo (`lens-governance`) is the single source of truth for known repositories, but it is never updated by the `/new-service` flow. New repos remain invisible to governance tooling.
3. **Generate project context documentation** — cloned repos have no `project-context.md` generated, so AI agents working in those repos lack the implementation rules and patterns they need.
4. **Create switchable branches** — the repos have no initiative-aware branches, so the user cannot use `/switch` to navigate to them.

Without discovery, the user's workflow stalls after cloning: governance is out of date, project context is missing, and branch navigation is broken.

## Proposed Solution

A `/discover` command that completes the post-clone lifecycle after `/new-service`:

1. **Post-clone detection:** After `/new-service` scaffolds the TargetProjects folder, prompt the user to clone relevant repos and reply "done" when finished.
2. **Scan cloned repos:** Walk the service folder in `TargetProjects/{domain}/{service}/` to find directories containing `.git/`. For each discovered repo:
   - Detect primary language using `lifecycle.yaml`'s `language_detection_priority` (build files → file extension analysis → fallback to `unknown`)
   - Check for `.bmad/` directory and BMAD configuration presence
3. **Update governance inventory:** Write discovered repos to `repo-inventory.yaml` in the governance repo (`TargetProjects/lens/lens-governance/`). Commit and push the update.
4. **Generate project context:** For each discovered repo, invoke the `bmad-bmm-generate-project-context` workflow to produce `project-context.md` with AI implementation rules.
5. **Create initiative-aware branches:** Create branches in the control repo so that `/switch` can navigate to the discovered repos.
6. **Report results:** Display a summary of discovered repos, detected languages, and updated inventory entries.

## User Value

| User | Value |
|------|-------|
| Admin | Governance inventory stays current — `repo-inventory.yaml` reflects what's actually cloned |
| Team Lead | Health snapshot of service repos — what's present, what's configured, what language each uses |
| Architect | Language-specific constitutions activate once language is resolved from `unknown` |
| Product Owner | Complete service setup in one flow — clone, discover, document, navigate |

## Scope Boundaries

**In scope:**
- Post-`/new-service` repo detection within `TargetProjects/{domain}/{service}/`
- Language detection using `lifecycle.yaml`'s `language_detection_priority` (steps 2–4: `.bmad/language` file, build file heuristics, file extension analysis)
- BMAD config presence detection (`.bmad/` directory)
- Governance `repo-inventory.yaml` update (new entries added, committed, pushed)
- `project-context.md` generation via `bmad-bmm-generate-project-context` workflow
- Branch creation for `/switch` navigation
- Initiative config `language` field update (replacing `unknown`)
- Both config update and separate discovery report output
- Suggested as next step after `/new-service` (not automatic, not after `/new-feature`)

**Out of scope:**
- Repository cloning (user clones manually; discovery detects what was cloned)
- GitHub API calls (detection is local filesystem only)
- Framework detection beyond language-level
- Dependency graph or cross-repo impact analysis (belongs to sensing/constitution)
- Monorepo sub-project decomposition
- Remote sync or repository state reconciliation

## Success Criteria

1. After `/discover`, `repo-inventory.yaml` contains entries for all repos found in the service folder
2. Each discovered repo has `project-context.md` generated via the standard workflow
3. `/switch` can navigate to any discovered repo
4. Initiative configs have `language` updated from `unknown` to the detected value
5. A human-readable discovery report is displayed showing repos found, languages detected, and any detection failures
6. Repos with no detectable language fall through to `unknown` gracefully (no crash)

## Assumptions

- Repos are cloned by the user into `TargetProjects/{domain}/{service}/` before `/discover` runs
- Each repo is a standard git repository (`.git/` directory present)
- One primary language per repo is sufficient for constitution enforcement
- Detection runs locally — no network access required
- The governance repo is cloned at `TargetProjects/lens/lens-governance/`
- `repo-inventory.yaml` follows a schema consumable by the `/onboard` workflow

## Risks

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Monorepos with multiple languages | Medium | Detect by highest file-count language; document limitation |
| Build files absent (config/doc repos) | Medium | Fall through to `unknown` gracefully; flag in report |
| Governance repo not cloned | Low | Preflight checks verify governance repo presence before running |
| `repo-inventory.yaml` schema drift | Low | Define schema in lifecycle.yaml or governance README; validate on write |
| User clones repos to wrong folder | Low | Validate against `target_projects_path` from `bmadconfig.yaml` |
