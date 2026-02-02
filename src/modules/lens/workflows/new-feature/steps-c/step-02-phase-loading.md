---
name: 'step-02-phase-loading'
description: 'Load workflow-guide to establish BMAD phase context'
nextStepFile: './step-03-git-lens-integration.md'
---

# Step 2: Phase Loading via Workflow-Guide

## Goal
Establish the current BMAD phase (Analysis, Planning, Implementation, QA) via the workflow-guide, then map it to this feature creation workflow.

---

## Why Phase Context Matters

**Phase** determines:
- What type of feature is being created (discovery, implementation, testing, etc.)
- Which documentation/artifacts are required
- How this workflow integrates with phase transitions (git-lens)
- Which subsequent workflows are available
- Feature branch naming conventions and tracking

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
     → Detect active lens (should be Feature)
     → Resolve current BMAD phase
     → Detect parent microservice/service/domain
     
  2. Run step-02-map-recommendations
     → Map feature-lens + detected-phase to workflows
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
lens: "feature" | "service"
parent_microservice: {microservice_name} (if Feature lens)
parent_service: {service_name}
parent_domain: {domain_name}
recommendations: [...]
```

---

## Mapping Phase to Feature Creation

### Phase-Specific Behavior

| Phase | Feature Type | Actions | Next |
|-------|--------------|---------|------|
| **Analysis** | Research/discovery | Explore requirements, prototype | Move to Planning |
| **Planning** | Epic/story definition | Design, architecture, specs | Move to Implementation |
| **Implementation** | Active feature coding | Build, test, commit code | Move to QA |
| **QA** | Testing/validation | Run tests, validate contracts | Finish or return to Implementation |

---

## Workflow Recommendation

**For new-feature workflow:**

- **If Analysis phase:**  
  → This is the right time to create discovery features  
  → Focus on prototype branches and exploration  
  → Proceed with metadata collection (Step 4)

- **If Planning phase:**  
  → This is the right time to create feature branches  
  → Focus on architectural features and specs  
  → For service-level features: identify all affected microservices  
  → Proceed with metadata collection (Step 4)

- **If Implementation phase:**  
  → This is the optimal time to create development features  
  → Focus on implementation tasks and code work  
  → For service-level features: ensure microservices are coordinated  
  → Proceed with metadata collection (Step 4)

- **If QA phase:**  
  → Creating new features during QA is less common  
  → May indicate bug fixes or refinement features  
  → Proceed with metadata collection (Step 4) or consult Casey (git-lens agent)

---

## Store Phase Context

After workflow-guide completes, store:

```
current_phase: {detected_phase}
phase_validated: true
phase_timestamp: {now}
phase_lens: feature | service
parent_microservice: {microservice} (if Feature lens)
parent_service: {service}
parent_domain: {domain}
```

---

## Next Step

→ Proceed to **Step 3: Git-Lens Integration** (or Step 3.5: Multi-Microservice Detection if at Service lens)
