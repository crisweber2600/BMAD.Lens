# Workflow Specification: bootstrap

**Module:** lens
**Status:** Placeholder — To be created via create-workflow workflow
**Created:** 2026-01-31

---

## Workflow Overview

**Goal:** Bootstrap target project structure from the lens domain map.

**Description:** Sync TargetProject folder hierarchy and clone repositories based on lens domain map, then report status.

**Workflow Type:** Core

---

## Workflow Structure

### Entry Point

```yaml
---
name: bootstrap
description: Sync TargetProject folder structure with the lens domain map
web_bundle: true
installed_path: '{project-root}/_bmad/lens/workflows/bootstrap'
---
```

### Mode

- [x] Create-only (steps-c/)
- [ ] Tri-modal (steps-c/, steps-e/, steps-v/)

---

## Planned Steps

| Step | Name | Goal |
|------|------|------|
| 1 | Load lens domain map | Load domain-map.yaml and service definitions |
| 2 | Scan target project | Inventory current folder structure |
| 3 | Compare and analyze gaps | Identify missing repos and mismatches |
| 4 | Execute sync | Create folders and clone repositories with approval |
| 5 | Validate and report | Confirm sync completion and write report |

---

## Workflow Inputs

### Required Inputs

- `domain-map.yaml`
- `service.yaml`
- `target_project_root`

### Optional Inputs

- Target domain/service/microservice filters
- Git credentials

---

## Workflow Outputs

### Output Format

- [x] Document-producing
- [ ] Non-document

### Output Files

- `{project-root}/_bmad-output/bootstrap-report.md`

---

## Agent Integration

### Primary Agent

Bridge

### Other Agents

Link (integrity checks)

---

## Implementation Notes

**Use the create-workflow workflow to build this workflow.**

---

_Spec created on 2026-01-31 via BMAD Module workflow_
