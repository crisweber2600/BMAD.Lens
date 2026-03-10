---
artifact: dev-story
story_id: 1-1
title: InitiativeContextResolver
epic: E1 — Discovery Pipeline & Pre-flight
initiative: bmad-lens-repodiscovery
project: bmad-lens
phase: dev
status: ready-for-dev
priority: P0
size: XS
dependencies: []
created: "2026-03-09"
author: Bob (SM)
---

# Story: S1.1 — InitiativeContextResolver

## User Story

**As a** `@lens` agent executing `/discover`,  
**I need** to resolve the active initiative's domain and service to determine the scan path,  
**So that** the discovery pipeline knows exactly where to look for cloned repos.

---

## Context & Background

This is the **first story** in the discovery pipeline. The `/discover` command stub was registered in `module.yaml` during the TechPlan phase. This story creates the foundational resolver that all subsequent E1 stories depend on.

**Target files to create/modify:**
- `bmad.lens.release/_bmad/lens-work/workflows/router/discover/workflow.md` — primary implementation target
- Governance config path loaded from: `_bmad-output/lens-work/governance-setup.yaml` (or equivalent config)
- Active initiative config: `_bmad-output/lens-work/initiatives/{domain}/{service}/{initiative_slug}.yaml`

**Architecture reference:** `_bmad-output/lens-work/initiatives/bmad/lens/phases/techplan/architecture.md` §2.1 (InitiativeContextResolver sub-component)

---

## Acceptance Criteria

- [ ] Reads `_bmad-output/lens-work/initiatives/{domain}/{service}/{id}.yaml` for `domain` and `service` fields
- [ ] Constructs `scan_path = TargetProjects/{domain}/{service}/`
- [ ] If initiative config is missing or malformed → fail with clear message:  
  `❌ No active initiative found. Run /new-service first.`
- [ ] Governance repo path loaded from `governance-setup.yaml` (path field)
- [ ] If governance repo path is missing or the directory does not exist → fail with:  
  `❌ Governance repo not found. Run /onboard to configure the governance path.`
- [ ] Returns structured resolver output: `{ domain, service, scan_path, governance_repo_path }`

---

## Implementation Notes

### Workflow Step Placement
This resolver runs as **Step 0 / Pre-flight** in `discover/workflow.md`, before any scan or governance operation.

### Config Resolution Logic
```
1. Determine active initiative:
   - Read initiative slug from current lens-work state (e.g. active branch name or explicit config)
   - Load: _bmad-output/lens-work/initiatives/{domain}/{service}/{slug}.yaml
   
2. Extract fields:
   domain:  config.domain
   service: config.service
   
3. Construct scan_path:
   scan_path = TargetProjects/{domain}/{service}/

4. Load governance path:
   - Check _bmad-output/lens-work/governance-setup.yaml (or equivalent)
   - governance_repo_path = config.governance_repo_path
   - Validate: directory exists at governance_repo_path
```

### Error Handling
- Missing initiative config → hard stop, clear user-facing message (no stack trace)
- Malformed YAML (parse error) → hard stop, include filename in message
- Governance path missing/directory not found → hard stop, suggest `/onboard`
- All errors exit before any scan or gov write is attempted

### What NOT to Build (XS scope guard)
- Do **not** implement language detection (S5.1, NTH)
- Do **not** traverse the scan_path (S1.2)
- Do **not** access governance repo contents (S2.x)
- Do **not** mutate any files

---

## Dev Notes (pre-populated by SM)

- The initiative config YAML schema is defined in `_bmad/lens-work/lifecycle.yaml` — reference for required fields.
- `governance-setup.yaml` path convention: look at existing onboarding artifacts in `_bmad-output/lens-work/` if the file exists; otherwise note the expected path for the dev team.
- This story is XS because it is **read-only resolution only** — no writes, no scanning, no git ops.
- The `scan_path` value flows downstream as the primary input to S1.2 (FileSystemScanner).

---

## Definition of Done

- [ ] All acceptance criteria above are checked off
- [ ] Workflow step for InitiativeContextResolver written in `discover/workflow.md` (at minimum as a named preflight step referencing this logic)
- [ ] Error paths manually tested against: (a) missing config, (b) malformed YAML, (c) missing governance dir
- [ ] No TODOs or stubs left in implemented step
- [ ] SM notified for status update → move to `review` in sprint-status.yaml

---

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-03-09 | Bob (SM) | Story file created, ready-for-dev |
