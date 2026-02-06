---
name: spec
description: Launch Planning phase (PRD/UX/Architecture)
agent: compass
trigger: /spec command
category: router
phase: 2
phase_name: Planning
---

# /spec — Planning Phase Router

**Purpose:** Guide users through the Planning phase, invoking PRD, UX, and Architecture workflows.

---

## Role Authorization

**Authorized:** PO, Architect, Tech Lead

---

## Prerequisites

- [x] `/pre-plan` complete (Phase 1 merged)
- [x] Product Brief exists

---

## Execution Sequence

### 1. Validate Prerequisites

```yaml
if not phase_complete("p1"):
  error: "Phase 1 (Analysis) not complete. Run /pre-plan first or merge pending PRs."

if not file_exists("_bmad-output/planning-artifacts/product-brief.md"):
  warning: "Product brief not found. Proceeding anyway."
```

### 2. Start Phase 2

```yaml
invoke: casey.start-phase
params:
  phase_number: 2
  phase_name: "Planning"
```

### 3. Offer Workflow Options

```
🧭 /spec — Planning Phase

You're starting the Planning phase. Workflows:

**[1] PRD** (required) — Product Requirements Document
**[2] UX Design** (if UI involved) — User experience design
**[3] Architecture** (required) — Technical architecture design

Select workflow(s): [1] [2] [3] [A]ll
```

### 4. Execute Workflows

#### PRD:
```yaml
invoke: casey.start-workflow
params:
  workflow_name: prd

invoke: bmm.create-prd
params:
  product_brief: "_bmad-output/planning-artifacts/product-brief.md"
  output_path: "_bmad-output/planning-artifacts/"

invoke: casey.finish-workflow
```

#### UX (if selected):
```yaml
invoke: casey.start-workflow
params:
  workflow_name: ux-design

invoke: bmm.create-ux-design

invoke: casey.finish-workflow
```

#### Architecture:
```yaml
invoke: casey.start-workflow
params:
  workflow_name: architecture

invoke: bmm.create-architecture
params:
  prd: "_bmad-output/planning-artifacts/prd.md"

invoke: casey.finish-workflow
```

### 5. Phase Completion + Lead Review

```yaml
if all_workflows_complete("p2"):
  invoke: casey.finish-phase
  invoke: casey.open-large-review  # PR: small → large
  
  output: |
    ✅ /spec complete
    ├── Phase 2 (Planning) finished
    ├── Lead Review PR opened
    └── Next: Get lead approval, then run /plan
```

---

## Output Artifacts

| Artifact | Location |
|----------|----------|
| PRD | `_bmad-output/planning-artifacts/prd.md` |
| UX Design | `_bmad-output/planning-artifacts/ux-design.md` |
| Architecture | `_bmad-output/planning-artifacts/architecture.md` |
