---
artifact: product-brief
phase: preplan
initiative: bmad-lens-repodiscovery
author: Mary (Analyst)
created: "2026-03-09"
---

# Product Brief — Repo Discovery

## Problem Statement

The `@lens` agent operates in a multi-repository control workspace where actual code repositories live under `TargetProjects/`. Today, initiative configs are created with `language: unknown` as a default, and the connection between a planning initiative and its target repository is implicit at best. This creates three compounding problems:

1. **Language-specific constitutions cannot be enforced** — without knowing a repo's language, `@lens` cannot apply the right constitution subset, leaving language-scoped governance rules effectively dead.
2. **Initiative configs are incomplete at creation** — the `language: unknown` default is a known gap that is never automatically resolved, leaving artifact quality checks ungrounded in the actual technology stack.
3. **No structural awareness of TargetProjects** — `@lens` cannot answer "which repos are cloned, which are missing, which have drifted from their expected configuration" without manual inspection.

## Opportunity

`lifecycle.yaml` already defines a complete 6-step language detection priority list (`language_detection_priority`) including build-file heuristics and file extension analysis. This logic exists as specification but has no runtime implementation. Repo Discovery converts this specification into an automated capability.

## Proposed Solution

A `/discover` command and companion `repo-discovery` capability for the `@lens` agent that:

1. **Scans `TargetProjects/`** for checked-out repositories (directories containing `.git/`)
2. **Applies `language_detection_priority`** to auto-detect each repo's primary language from build files and source patterns
3. **Detects BMAD config presence** — checks for `.bmad/` directory and `bmad.config.yaml`
4. **Updates initiative configs** — writes the detected `language` field back to `initiative.yaml`, replacing `unknown`
5. **Produces a discovery report** — summary of all repos found, their detected languages, and any detection failures

## User Value

| User | Value |
|------|-------|
| Individual developer | No longer needs to manually set `language` on every new feature initiative |
| Team lead | Can run `/discover` to get a health snapshot of all service repos in TargetProjects |
| Governance admin | Language-specific constitutions automatically activate once language is resolved |

## Scope Boundaries

**In scope:**
- Detection from local TargetProjects checkout only (no GitHub API calls)
- Language detection for all `supported_languages` in lifecycle.yaml
- BMAD config presence detection
- Initiative config update (language field only)
- On-demand `/discover` command trigger
- Automatic trigger at `/new-feature` creation (populates `language` before first phase)

**Out of scope:**
- Repository cloning or remote sync (separate concern)
- Framework detection beyond language-level
- Dependency graph analysis
- Cross-repo impact analysis (belongs to sensing/constitution)

## Success Criteria

1. `language: unknown` in initiative configs is replaced with a detected value on first `/discover` run
2. Language detection accuracy ≥ 90% for the 6 build-file heuristic cases
3. Detection completes in < 2 seconds for a TargetProjects tree with 20 repos
4. A repo with no detectable language falls through to `unknown` gracefully (no crash)
5. `/discover` produces a human-readable report with counts and any failures flagged

## Assumptions

- Repos are already cloned into `TargetProjects/` before discovery runs
- Each repo is a standard git repository (`.git/` directory present)
- One primary language per repo is sufficient for constitution enforcement
- Detection runs locally — no network access required

## Risks

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Monorepos with multiple languages | Medium | Detect by highest file-count language; document limitation |
| Build files absent (generated/embedded repos) | Low | Fall through to `unknown` gracefully |
| TargetProjects path varies by user profile | Low | Read `target_projects_path` from `bmadconfig.yaml` or profile |
