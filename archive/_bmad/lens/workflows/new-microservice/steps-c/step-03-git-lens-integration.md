---
name: 'step-03-git-lens-integration'
description: 'Integrate with git-lens state management and workflow context'
nextStepFile: './step-01-collect-metadata.md'
---

# Step 3: Git-Lens Integration

## Goal
Ensure this new-microservice workflow integrates with git-lens state management, workflow tracking, and phase transitions.

---

## Git-Lens Context Check

### What is git-lens?

**git-lens** is the LENS module's integration layer with BMAD phase/workflow state management:

- **Casey (Agent):** Git state analyzer — detects branches, phases, initiatives
- **Tracey (Agent):** Workflow orchestrator — manages workflow lifecycle events
- **Hooks:** before-phase, before-workflow, after-phase, after-workflow

---

## Pre-Workflow Validation (git-lens before-workflow hook)

Git-lens automatically runs `before-workflow` hook before this workflow continues.

### What it validates:

✓ **Repo state:** Git is clean or changes are committed  
✓ **Branch context:** Current branch matches expected phase/initiative  
✓ **Permissions:** User can create microservice structures  
✓ **Setup:** Service registry and domain map exist  
✓ **Parent service:** Parent service exists in domain map  

### If validation fails:

```
⚠️  Git-Lens Validation Failed

Reason: {validation_error}

Actions:
  1. Run: git-lens status
     → See current phase/workflow state
     
  2. Run: git-lens fix-state
     → Auto-correct branch/state issues
     
  3. Manually fix:
     → Commit pending changes: git add . && git commit
     → Checkout correct branch: git checkout {branch}
```

---

## Workflow Tracking in git-lens

### This workflow creates a tracked workflow instance

When you proceed beyond this point, git-lens creates:

```
Workflow Instance:
  - workflow: new-microservice
  - phase: {detected_phase}
  - initiative: {current_initiative}
  - parent_service: {service}
  - timestamp: {now}
  - status: in-progress
```

### Workflow lifecycle events:

| Event | When | Action |
|-------|------|--------|
| **start-workflow** | Now → Next step | Initialize tracking |
| **during-workflow** | Each step completion | Update progress |
| **finish-workflow** | Final step | Mark complete, link to microservice |
| **after-workflow** | Completion | Trigger phase/initiative checks |

---

## Phase Integration

### This workflow respects phase boundaries

If your current phase is transitioning:

```
If transitioning: Planning → Implementation
  ✓ This workflow can create the implementation structure
  ✓ Microservice created will be marked for Implementation phase
  ✓ After-workflow hook will advance phase if all workflows complete

If transitioning: Analysis → Planning
  ✓ This workflow defines microservice structure
  ✓ Microservice created will be marked for Planning phase
```

---

## Branch Management

### Automatic branch tracking

This workflow is aware of your git branch:

```
Your branch: feature/new-microservice-{service}-{microservice}
  → Tracked by git-lens
  → Linked to initiative/phase
  → Parent branch context available

Your branch: phase/{phase}/initiative/{id}
  → Phase branch (git-lens managed)
  → All microservices created here are phase-scoped
```

### What happens at completion:

✓ Microservice creation committed to current branch  
✓ Commit linked to workflow instance  
✓ git-lens records microservice metadata  
✓ Phase transition checked (if applicable)

---

## State Files Created/Updated

This workflow will create/update:

```
Microservice State Files:
  .lens/domain-map.yaml
    → Microservice entry added under parent service
    → Links to service → domain
    
  .lens/services/{service}/microservices/{microservice}/metadata.yaml
    → Microservice definition
    → Created timestamp
    → Phase context
    → Parent service link
    
  .git-lens/workflow-state.yaml
    → Workflow instance logged
    → Timestamps + status
    
  .git-lens/initiatives/{init-id}/microservices.yaml
    → Microservice linked to initiative
```

---

## Next Actions: Manual Intervention Points

### If you need to align with git-lens workflows:

**Option A: Continue with metadata collection**
- → Proceed to Step 4 (Metadata Collection)
- ✓ Git-lens will track automatically

**Option B: Consult git-lens agents first**
- Use Casey to review current state: `git-lens status`
- Use git-lens workflows to adjust context: `git-lens start-phase` or `git-lens start-workflow`
- Then return and continue

**Option C: Override git-lens constraints (not recommended)**
- Proceed anyway with override flag
- May cause state misalignment

---

## Store Integration Context

After this step, set:

```
git_lens_validated: true
workflow_instance_id: {generated}
phase_integration: active
tracking_enabled: true
parent_service_confirmed: true
```

---

## Next Step

→ Proceed to **Step 4: Collect Microservice Metadata** (original step-01-collect-metadata.md)
