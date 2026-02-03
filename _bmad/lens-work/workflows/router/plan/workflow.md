---
name: plan
description: Complete Solutioning (Epics/Stories/Readiness)
agent: compass
trigger: /plan command
category: router
phase: 3
phase_name: Solutioning
---

# /plan — Solutioning Phase Router

**Purpose:** Complete the Solutioning phase with Epics, Stories, and Readiness checklist.

---

## Role Authorization

**Authorized:** PO, Architect, Tech Lead

---

## Prerequisites

- [x] `/spec` complete (Phase 2 merged)
- [x] Lead review approved (small → lead merged)

---

## Execution Sequence

### 1. Validate Prerequisites

```yaml
if not phase_complete("p2"):
  error: "Phase 2 (Planning) not complete. Run /spec first."

if not lead_review_merged():
  warning: "Lead review PR not merged. Proceeding but architecture may change."
```

### 2. Start Phase 3

```yaml
invoke: casey.start-phase
params:
  phase_number: 3
  phase_name: "Solutioning"
```

### 3. Execute Workflows

#### Epics:
```yaml
invoke: casey.start-workflow
params:
  workflow_name: epics

invoke: bmm.create-epics
params:
  architecture: "_bmad-output/planning-artifacts/architecture.md"

invoke: casey.finish-workflow
```

#### Stories:
```yaml
invoke: casey.start-workflow
params:
  workflow_name: stories

invoke: bmm.create-stories
params:
  epics: "_bmad-output/planning-artifacts/epics.md"

invoke: casey.finish-workflow
```

#### Readiness Checklist:
```yaml
invoke: casey.start-workflow
params:
  workflow_name: readiness

invoke: bmm.readiness-checklist
params:
  artifacts:
    - product-brief.md
    - prd.md
    - architecture.md
    - epics.md
    - stories.md

invoke: casey.finish-workflow
```

### 4. Phase Completion

```yaml
if all_workflows_complete("p3"):
  invoke: casey.finish-phase
  invoke: casey.open-final-pbr  # PR: lead → base
  
  output: |
    ✅ /plan complete
    ├── Phase 3 (Solutioning) finished
    ├── Final PBR PR opened
    ├── Stories ready for sprint planning
    └── Next: Run /review for implementation gate
```

---

## Output Artifacts

| Artifact | Location |
|----------|----------|
| Epics | `_bmad-output/planning-artifacts/epics.md` |
| Stories | `_bmad-output/planning-artifacts/stories.md` |
| Readiness | `_bmad-output/planning-artifacts/readiness-checklist.md` |
