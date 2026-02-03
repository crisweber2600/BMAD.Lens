---
name: 'step-01-lens-check'
description: 'Verify Feature lens context and load phase guidance'
nextStepFile: './step-02-phase-loading.md'
---

# Step 1: Lens Validation & Context Check

## Goal
Verify the user is operating at **Feature lens** (Microservice-level work). If not, provide navigation suggestions.

---

## Lens Detection Logic

### Current Lens Resolution

Detect current lens from git context:

```
Resolution Order:
1. Parse git branch naming pattern
   - Pattern: {domain}/{service}/{microservice}/{feature}
   - Count path segments to determine lens level

2. Check .lens/context.yaml for explicit lens
   - If lens is explicitly set, use it
   
3. Scan folder structure for domain/service/microservice nesting
   - Inside feature branch context → Feature lens
   - TargetProjects/{domain}/{service}/{microservice}/ → Microservice lens (parent)

4. Fallback: Query git-lens Casey agent for state
   - Casey can detect phase, initiative, and feature branch context
```

---

## Validation: Are We At Feature or Service Lens?

**Feature Lens Indicators (Single Microservice):**
- ✓ On a feature branch (off microservice/service/phase branch)
- ✓ Git branch contains feature segment
- ✓ `.lens/context.yaml` shows `lens: feature`
- ✓ Folder structure: Working within microservice context

**Service Lens Indicators (Cross-Microservice):**
- ✓ On a service branch (at service level, not microservice)
- ✓ Git branch contains service segment
- ✓ `.lens/context.yaml` shows `lens: service`
- ✓ Folder structure: Working at service root with access to multiple microservices
- ✓ Intent: Feature spans multiple microservices/projects within service

**If Feature or Service Lens is Detected:**
- ✓ PASS — Continue to Phase Loading (Step 2)
- Note: Will determine scope (single vs. multi-microservice) in later steps

---

## If NOT At Feature Lens

### Current Lens is: Service
```
✓ You're at SERVICE lens

This is valid for cross-microservice features that span multiple microservices within a service.

FEATURE SCOPE CLARIFICATION:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This could be:
  A) A service-level feature touching multiple microservices
  B) An initiative/epic that impacts the service across several microservices
  C) A refactoring or infrastructure change affecting multiple areas

Proceed with this workflow:
  ✓ You'll specify which microservices are affected
  ✓ Feature branch will reflect multi-microservice scope
  ✓ git-lens will track impact across microservices

Continue to proceed with metadata collection (Step 4).
```

This workflow creates Features within Microservices, which requires Feature-level context.

SUGGESTION: Navigate to a Feature Branch or Microservice
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Option 1: Use lens-compass to navigate
  Workflow: lens-compass navigate
  
Option 2: Create service/microservice structure first
  Workflow: new-service → new-microservice → then new-feature

Would you like to:
  A) Navigate to feature context?
  B) Create microservice structure first?
  C) Continue anyway (not recommended)?
```

### Current Lens is: Service
```
❌ You're at SERVICE lens (too high level)

This workflow creates Features within Microservices. You're nested too high.

SUGGESTION: Navigate into Microservice, Then Create Feature
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Option 1: Navigate to microservice
  Use: lens-compass navigate → select microservice level
  Then: Create feature branch
  
Option 2: Create microservice first
  Workflow: new-microservice
  Then: new-feature within that microservice

Would you like to:
  A) Navigate to microservice level?
  B) Create microservice first?
  C) Continue anyway (not recommended)?
```

### Current Lens is: Microservice
```
❌ You're at MICROSERVICE lens (one level too high)

This workflow creates Features within Microservices. You need to be ON a feature branch.

SUGGESTION: Create/Checkout Feature Branch
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Option 1: Create feature branch now (this workflow will do it)
  ✓ Proceed with this workflow
  ✓ Metadata collection will ask for feature name
  ✓ Workflow will generate branch name and checkout

Option 2: Check existing feature branches
  git branch -a | grep feature
  Then: git checkout {existing-feature}

Would you like to:
  A) Create a new feature branch (proceed)?
  B) Checkout existing feature branch manually?
  C) Continue anyway?
```

### Current Lens is: Unknown
```
⚠️  Lens Detection Failed

Could not determine current lens from git context or folder structure.

SUGGESTIONS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Verify you're in a git repository
   cd {project-root}
   
2. Ensure TargetProjects/ structure exists
   Check: TargetProjects/{domain}/{service}/{microservice}/
   
3. Verify you're in a microservice folder
   pwd should show: .../TargetProjects/{domain}/{service}/{microservice}
   
4. Run workflow-guide to establish context
   Workflow: workflow-guide
   
5. Use git-lens status
   Workflow: git-lens status

Would you like to:
  A) Run workflow-guide first?
  B) Run git-lens status for diagnostics?
  C) Continue anyway?
```

---

## User Response Handling

**IF User Selects: Continue At Wrong Lens**
- ⚠️  Display warning: "Proceeding may create features at wrong hierarchy level"
- Store override flag: `lens_override: true`
- Proceed to Step 2 (Phase Loading)

**IF User Selects: Navigate**
- Load [lens-compass navigate workflow](../../lens-compass/workflows/navigate/)
- After completion, return and re-run this step

**IF User Selects: Run workflow-guide**
- Load [workflow-guide workflow](../workflow-guide/)
- After completion, return and re-run this step

---

## Context Variables Set

If validation passes, set:

```
lens_detected: "feature"
lens_validated: true
feature_level_confirmed: true
```

If validation passes at Service lens, set:

```
lens_detected: "service"
lens_validated: true
cross_microservice_capable: true
```

If validation fails but user overrides:

```
lens_detected: {actual_lens}
lens_override: true
warnings: ["Proceeding at {actual_lens} lens, not feature"]
```
