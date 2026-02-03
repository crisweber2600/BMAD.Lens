---
name: 'step-01-lens-check'
description: 'Verify Service lens context and load phase guidance'
nextStepFile: './step-02-phase-loading.md'
---

# Step 1: Lens Validation & Context Check

## Goal
Verify the user is operating at **Service lens** (Domain-level work). If not, provide navigation suggestions.

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
   
3. Scan folder structure for domain/service nesting
   - TargetProjects/{domain}/{service}/ → Service lens
   - TargetProjects/{domain}/ → Domain lens

4. Fallback: Query git-lens Casey agent for state
   - Casey can detect phase and initiative context
```

---

## Validation: Are We At Service Lens?

**Service Lens Indicators:**
- ✓ Inside a service repository
- ✓ Git branch contains domain + service segments
- ✓ `.lens/context.yaml` shows `lens: service`
- ✓ Folder structure: `TargetProjects/{domain}/{service}/`

**If Service Lens is Detected:**
- ✓ PASS — Continue to Phase Loading (Step 2)

---

## If NOT At Service Lens

### Current Lens is: Domain
```
❌ You're at DOMAIN lens (too high level)

This workflow creates Services, which requires Service-level context.

SUGGESTION: Navigate to a Service Repository
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Option 1: Use lens-compass to navigate
  Workflow: lens-compass navigate
  
Option 2: Clone/enter service repo manually
  cd TargetProjects/{domain}/{service}
  
Option 3: Start with new-service first
  To CREATE a new service at domain level, use:
  Workflow: new-service → adjust this workflow

Would you like to:
  A) Navigate to an existing service?
  B) Create a new service first (at domain level)?
  C) Continue anyway (not recommended)?
```

### Current Lens is: Microservice
```
❌ You're at MICROSERVICE lens (too low level)

This workflow creates Services at Domain level. You're nested too deep.

SUGGESTION: Navigate to Service Root
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Option 1: Go to service root
  cd ../  (up one level from microservice)
  
Option 2: Use git-lens to checkout service branch
  Workflow: git-lens status → find service branch
  
Option 3: Use lens-compass
  Workflow: lens-compass navigate → select service level

Would you like to:
  A) Navigate up to service level?
  B) Switch to microservice-level workflow (new-microservice)?
  C) Continue anyway (not recommended)?
```

### Current Lens is: Feature
```
❌ You're at FEATURE lens (too low level)

This workflow is for Service-level work. You're at feature branch level.

SUGGESTION: Return to Service Branch
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Option 1: Checkout service branch
  git checkout {service-branch}
  
Option 2: Use git-lens resume
  Workflow: git-lens resume → back to service context
  
Option 3: Use lens-compass
  Workflow: lens-compass navigate → service level

Would you like to:
  A) Navigate back to service level?
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
   Check: TargetProjects/{domain}/{service}/
   
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
lens_detected: "service"
lens_validated: true
service_level_confirmed: true
```

If validation fails but user overrides:

```
lens_detected: {actual_lens}
lens_override: true
warnings: ["Proceeding at {actual_lens} lens, not service"]
```
