---
name: 'step-01-lens-check'
description: 'Verify Microservice lens context and load phase guidance'
nextStepFile: './step-02-phase-loading.md'
---

# Step 1: Lens Validation & Context Check

## Goal
Verify the user is operating at **Microservice lens** (Service-level work). If not, provide navigation suggestions.

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
   - TargetProjects/{domain}/{service}/{microservice}/ → Microservice lens
   - TargetProjects/{domain}/{service}/ → Service lens

4. Fallback: Query git-lens Casey agent for state
   - Casey can detect phase and initiative context
```

---

## Validation: Are We At Microservice Lens?

**Microservice Lens Indicators:**
- ✓ Inside a microservice repository/folder
- ✓ Git branch contains domain + service + microservice segments
- ✓ `.lens/context.yaml` shows `lens: microservice`
- ✓ Folder structure: `TargetProjects/{domain}/{service}/{microservice}/`

**If Microservice Lens is Detected:**
- ✓ PASS — Continue to Phase Loading (Step 2)

---

## If NOT At Microservice Lens

### Current Lens is: Domain
```
❌ You're at DOMAIN lens (too high level)

This workflow creates Microservices within Services, which requires Microservice-level context.

SUGGESTION: Navigate to a Microservice
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Option 1: Use lens-compass to navigate
  Workflow: lens-compass navigate
  
Option 2: Navigate manually
  cd TargetProjects/{domain}/{service}/{microservice}
  
Option 3: Create service first, then microservice
  Workflow: new-service → then new-microservice

Would you like to:
  A) Navigate to an existing microservice?
  B) Create a new service first?
  C) Continue anyway (not recommended)?
```

### Current Lens is: Service
```
❌ You're at SERVICE lens (one level too high)

This workflow creates Microservices, which requires Microservice-level context.

SUGGESTION: Enter a Microservice Context
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Option 1: Navigate into microservice folder
  cd {microservice-name}
  
Option 2: Use git-lens to checkout microservice branch
  Workflow: git-lens status → find microservice branch
  
Option 3: Use lens-compass
  Workflow: lens-compass navigate → select microservice level

Would you like to:
  A) Navigate into a microservice?
  B) Create a new microservice first (at service level)?
  C) Continue anyway (not recommended)?
```

### Current Lens is: Feature
```
❌ You're at FEATURE lens (too low level)

This workflow is for Microservice-level work. You're at feature branch level.

SUGGESTION: Return to Microservice Branch
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Option 1: Checkout microservice branch
  git checkout {microservice-branch}
  
Option 2: Use git-lens resume
  Workflow: git-lens resume → back to microservice context
  
Option 3: Use lens-compass
  Workflow: lens-compass navigate → microservice level

Would you like to:
  A) Navigate back to microservice level?
  B) Switch to feature-level workflow (new-feature)?
  C) Continue anyway (not recommended)?
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
   
3. Run workflow-guide to establish context
   Workflow: workflow-guide
   
4. Use git-lens status
   Workflow: git-lens status

Would you like to:
  A) Run workflow-guide first?
  B) Run git-lens status for diagnostics?
  C) Continue anyway?
```

---

## User Response Handling

**IF User Selects: Continue At Wrong Lens**
- ⚠️  Display warning: "Proceeding may create structures at wrong hierarchy level"
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
lens_detected: "microservice"
lens_validated: true
microservice_level_confirmed: true
```

If validation fails but user overrides:

```
lens_detected: {actual_lens}
lens_override: true
warnings: ["Proceeding at {actual_lens} lens, not microservice"]
```
