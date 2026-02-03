---
name: 'step-02-phase-loading'
description: 'Load workflow-guide to establish BMAD phase context'
nextStepFile: './step-03-git-lens-integration.md'
---

# Step 2: Phase Loading via Workflow-Guide

## Goal
Establish the current BMAD phase (Analysis, Planning, Implementation, QA) via the workflow-guide, then map it to this microservice creation workflow.

---

## Why Phase Context Matters

**Phase** determines:
- What type of microservice is being created (conceptual vs. implementation)
- Which documentation/artifacts are required
- How this workflow integrates with phase transitions (git-lens)
- Which subsequent workflows are available

---

## Loading Workflow-Guide

### Invoke workflow-guide

This workflow runs the [workflow-guide workflow](../workflow-guide/):

**Workflow:** `workflow-guide`  
**Goal:** Detect lens + phase, present navigation card

```
workflow-guide will:
  1. Run step-01-detect-context
     → Verify TargetProjects setup
     → Detect active lens (should be Microservice)
     → Resolve current BMAD phase
     
  2. Run step-02-map-recommendations
     → Map microservice-lens + detected-phase to workflows
     → Filter relevant workflows for this context
     
  3. Run step-03-present-guidance
     → Display navigation card
     → Show available next steps
```

**Load It Now:**

> Read and follow: `{project-root}/src/modules/lens/workflows/workflow-guide/workflow.md`

---

## After workflow-guide Completes

### Phase Detection Results

The workflow-guide will return:

```
detected_phase: "analysis" | "planning" | "implementation" | "qa"
lens: "microservice"
recommendations: [...]
```

---

## Mapping Phase to Microservice Creation

### Phase-Specific Behavior

| Phase | Microservice Type | Actions | Next |
|-------|-------------------|---------|------|
| **Analysis** | Conceptual research | Gather requirements, document discovery | Proceed to Planning |
| **Planning** | Planned microservice | Create product brief, architecture | Proceed to Implementation |
| **Implementation** | Active microservice | Scaffold code structure, init repo | Proceed to QA/Testing |
| **QA** | Microservice refinement | Validate contracts, test integrations | Back to Implementation or Finish |

---

## Workflow Recommendation

**For new-microservice workflow:**

- **If Analysis phase:**  
  → This is the right time to create microservice definitions  
  → Focus on discovery and requirements capture  
  → Proceed with metadata collection (Step 3)

- **If Planning phase:**  
  → This is the right time to scaffold microservice  
  → Focus on architecture and structure  
  → Proceed with metadata collection (Step 3)

- **If Implementation phase:**  
  → This is the right time to implement microservice  
  → Focus on code scaffolding and initialization  
  → Proceed with metadata collection (Step 3)

- **If QA phase:**  
  → Creating a new microservice during QA is unusual  
  → May indicate scope change or parallel work  
  → Consider: Should this be a refactoring or post-phase delivery?  
  → Recommend consulting git-lens for phase/initiative guidance

---

## Store Phase Context

After workflow-guide completes, store:

```
current_phase: {detected_phase}
phase_validated: true
phase_timestamp: {now}
phase_lens: microservice
```

---

## Next Step

→ Proceed to **Step 3: Git-Lens Integration**
