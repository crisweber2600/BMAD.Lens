# Workflow Specification: generate-docs

**Module:** lens-work
**Status:** Implemented
**Created:** 2026-01-31

---

## Workflow Overview

**Goal:** Generate documentation from analysis findings.

**Description:** Transform analysis results into BMAD-ready documentation artifacts.

**Workflow Type:** Core

---

## Workflow Structure

### Entry Point

```yaml
---
name: generate-docs
description: Generate BMAD-ready documentation from analysis
web_bundle: true
installed_path: '{project-root}/_bmad/lens-work/workflows/generate-docs'
---
```

### Mode

- [x] Create-only (steps-c/)
- [ ] Tri-modal (steps-c/, steps-e/, steps-v/)

---

## Planned Steps

| Step | File | Goal |
|------|------|------|
| 0 | step-00-preflight | Validate inputs and prerequisites |
| 1 | step-01-load-analysis | Read analysis results and context |
| 2 | step-02-generate | Create architecture, API, data, integration, migration docs |
| 3 | step-03-report | Write docs to output folder and generate completion report |

---

## Workflow Inputs

### Required Inputs

- Analysis results from analyze-codebase
- `docs_output_path`

### Optional Inputs

- Target selection (domain/service/microservice)

---

## Workflow Outputs

### Output Format

- [x] Document-producing
- [ ] Non-document

### Output Structure

**IMPORTANT:** Documentation is written to `lens-sync/{target.name}/` under the configured `docs_output_path`.

```
{docs_output_path}/
└── lens-sync/
    └── {target.name}/
        ├── architecture.md
        ├── api-surface.md
        ├── data-model.md
        ├── integration-map.md
        ├── onboarding.md
        └── migration-map.md
```

### Output Files

- `{docs_output_path}/lens-sync/{target.name}/architecture.md`
- `{docs_output_path}/lens-sync/{target.name}/api-surface.md`
- `{docs_output_path}/lens-sync/{target.name}/data-model.md`
- `{docs_output_path}/lens-sync/{target.name}/integration-map.md`
- `{docs_output_path}/lens-sync/{target.name}/onboarding.md`
- `{docs_output_path}/lens-sync/{target.name}/migration-map.md`

---

## Agent Integration

### Primary Agent

Scout

### Other Agents

Link (propagation)

---

## Implementation Notes

**Use the create-workflow workflow to build this workflow.**

---

_Spec created on 2026-01-31 via BMAD Module workflow_
