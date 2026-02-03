---
name: 'step-03-git-lens-integration'
description: 'Integrate with git-lens state management and workflow context'
nextStepFile: './step-01-collect-metadata.md'
---

# Step 3: Git-Lens Integration

## Goal
Ensure this new-feature workflow integrates with git-lens state management, workflow tracking, and phase transitions.

---

## Git-Lens Context Check

### What is git-lens?

**git-lens** is the LENS module's integration layer with BMAD phase/workflow state management:

- **Casey (Agent):** Git state analyzer — detects branches, phases, initiatives, features
- **Tracey (Agent):** Workflow orchestrator — manages workflow lifecycle events
- **Hooks:** before-phase, before-workflow, after-phase, after-workflow

---

## Pre-Workflow Validation (git-lens before-workflow hook)

Git-lens automatically runs `before-workflow` hook before this workflow continues.

### What it validates:

✓ **Repo state:** Git is clean or changes are committed  
✓ **Branch context:** Current branch matches expected phase/initiative  
✓ **Permissions:** User can create feature branches  
✓ **Setup:** Domain/service/microservice structure exists  
✓ **Parent context:** Parent microservice/service/domain are valid (depends on lens)
✓ **Multi-microservice:** If Service lens, validate access to multiple microservices  

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
     → Navigate to microservice context: cd {microservice}
```

---

## Workflow Tracking in git-lens

### This workflow creates a tracked workflow instance

When you proceed beyond this point, git-lens creates:

```
Workflow Instance:
  - workflow: new-feature
  - phase: {detected_phase}
  - initiative: {current_initiative}
  - scope: "single-microservice" | "cross-microservice"
  - parent_microservice: {microservice} (if single-microservice)
  - affected_microservices: [{ms1}, {ms2}, ...] (if cross-microservice)
  - parent_service: {service}
  - parent_domain: {domain}
  - timestamp: {now}
  - status: in-progress
```

### Workflow lifecycle events:

| Event | When | Action |
|-------|------|--------|
| **start-workflow** | Now → Next step | Initialize tracking |
| **during-workflow** | Each step completion | Update progress |
| **finish-workflow** | Final step | Mark complete, link to feature branch |
| **after-workflow** | Completion | Trigger phase/initiative checks |

---

## Phase Integration

### This workflow respects phase boundaries

If your current phase is transitioning:

```
If transitioning: Planning → Implementation
  ✓ This workflow can create the implementation feature branch
  ✓ Feature created will be marked for Implementation phase
  ✓ After-workflow hook will advance phase if all workflows complete

If transitioning: Analysis → Planning
  ✓ This workflow defines feature branch structure
  ✓ Feature created will be marked for Planning phase
```

---

## Feature Branch Management (git-lens integration)

#### Single-Microservice Feature (Feature Lens)

```
1. Generate feature branch name from metadata
   Pattern: feature/{phase}/{microservice}/{feature-name}
   Example: feature/implementation/auth-service/add-oauth-2fa
   
2. Create and checkout feature branch
   git checkout -b {generated_branch_name}
```

#### Cross-Microservice Feature (Service Lens)

```
1. Generate feature branch name for service-level scope
   Pattern: feature/{phase}/{service}/{feature-name}
   Example: feature/planning/customer-api/multi-service-refactor
   
2. Create and checkout feature branch at service root
   git checkout -b {generated_branch_name}
   
3. Register affected microservices with git-lens
   - Casey records: "This feature affects: [auth-service, user-service, api-gateway]"
   - Tracey tracks interdependencies between affected microservices
   - State file: .git-lens/features/{feature-id}/affected-microservices.yaml
```

### What happens at completion:

✓ Feature branch created and checked out  
✓ Feature context committed to branch  
✓ Commit linked to workflow instance  
✓ git-lens registers feature with initiative  
✓ Phase transition checked (if applicable)

---

## State Files Created/Updated

This workflow will create/update:

```
Feature State Files:
  .lens/context.yaml
    → Updated to feature lens or service lens
    → Feature name and scope stored
    
  .git-lens/features/{feature-id}/metadata.yaml
    → Feature definition
    → Created timestamp
    → Phase context
    → Parent microservice link (single-ms features)
    → List of affected microservices (cross-ms features)
    → Parent service/domain links
    
  .git-lens/features/{feature-id}/affected-microservices.yaml (cross-microservice only)
    → Microservices impacted by this feature
    → Coordinates for testing, review, integration
    
  .git-lens/workflow-state.yaml
    → Workflow instance logged
    → Timestamps + status
    
  .git-lens/initiatives/{init-id}/features.yaml
    → Feature linked to initiative
    → Branch name registered
    → Scope metadata (single vs. cross)
```

---

## Feature Branch Lifecycle Integration

### Casey (git-lens) will track:

- ✓ Feature creation timestamp
- ✓ Parent initiative/phase
- ✓ Associated commits and PRs
- ✓ Phase transitions while feature is active
- ✓ Integration back to parent branch at workflow completion

### Available git-lens workflows while feature is active:

- `git-lens status` — View current feature state
- `git-lens start-workflow` — Track nested workflows
- `git-lens finish-workflow` — Mark feature workflow complete
- `git-lens resume` — Return to feature branch from elsewhere

---

## Next Actions: Manual Intervention Points

### If you need to align with git-lens workflows:

**Option A: Continue with metadata collection**
- → Proceed to Step 4 (Metadata Collection)
- ✓ Git-lens will track automatically
- ✓ Feature branch will be created in next step

**Option B: Consult git-lens agents first**
- Use Casey to review current state: `git-lens status`
- Use git-lens workflows to adjust context: `git-lens start-phase` or `git-lens start-workflow`
- Then return and continue

**Option C: Override git-lens constraints (not recommended)**
- Proceed anyway with override flag
- May cause state misalignment or branch conflicts

---

## Store Integration Context

After this step, set:

```
git_lens_validated: true
workflow_instance_id: {generated}
phase_integration: active
tracking_enabled: true
parent_hierarchy_confirmed: true
feature_branch_ready: true
feature_scope: "single-microservice" | "cross-microservice"
affected_microservices: [{ms1}, {ms2}, ...] (if cross-microservice)
```

---

## Next Step

→ Proceed to **Step 4: Collect Feature Metadata** (original step-01-collect-metadata.md)
