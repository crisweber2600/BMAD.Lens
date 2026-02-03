# Lens Module Edit Summary

**Module:** lens  
**Date:** 2026-02-02  
**Edit Scope:** new-service, new-microservice, new-feature workflows

---

## Changes Implemented

### 1. ✅ Added Lens Detection & Validation

All three workflows now include **Step 1: Lens Validation** (`step-01-lens-check.md`) that:

- **Detects current lens** from git branch patterns, folder structure, and git-lens context
- **Validates correct lens** before proceeding:
  - `new-service` → requires **Service lens**
  - `new-microservice` → requires **Microservice lens**
  - `new-feature` → requires **Feature lens**
- **Offers navigation suggestions** if wrong lens detected
  - Suggests lens-compass navigation
  - Suggests prerequisite workflows (e.g., create service before microservice)
  - Allows override with warning flag

### 2. ✅ Added Phase Loading via workflow-guide

All three workflows now include **Step 2: Phase Loading** (`step-02-phase-loading.md`) that:

- **Invokes workflow-guide workflow** to establish current BMAD phase
- **Maps phase to workflow recommendations**:
  - Analysis → Research/discovery focus
  - Planning → Architecture/specs focus
  - Implementation → Active coding focus
  - QA → Testing/validation focus
- **Stores phase context** for subsequent steps
- **Links to workflow-map reference** per https://docs.bmad-method.org/reference/workflow-map/

### 3. ✅ Added git-lens Integration

All three workflows now include **Step 3: Git-Lens Integration** (`step-03-git-lens-integration.md`) that:

- **Pre-workflow validation** via Casey (git-lens agent)
  - Validates repo state, branch context, permissions, setup
- **Workflow instance tracking** via Tracey
  - Creates tracked workflow instance with phase/initiative context
  - Registers lifecycle events (start, during, finish, after)
- **State management** via git-lens hooks
  - before-workflow hook: Pre-flight validation
  - after-workflow hook: Phase transition checks
- **Feature-specific integrations**:
  - new-feature: Creates feature branch with Casey tracking
  - new-microservice: Validates parent service exists
  - new-service: Validates domain context

### 4. ✅ Updated Workflow Metadata

All three `workflow.md` files updated with:

```yaml
nextStep: './steps-c/step-01-lens-check.md'  # Changed from step-01-collect-metadata
requires_git_lens: true                       # New flag
required_lens: {service|microservice|feature} # New metadata
phase_context: {planning|implementation}      # New metadata
```

---

## Workflow Flow (Updated)

### Before
```
workflow.md → step-01-collect-metadata → step-02 → step-03
```

### After
```
workflow.md 
  → step-01-lens-check (NEW: validate correct lens)
    → step-02-phase-loading (NEW: establish phase via workflow-guide)
      → step-03-git-lens-integration (NEW: git-lens state management)
        → step-01-collect-metadata (RENAMED to step-04 logically)
          → step-02-* → step-03-*
```

---

## Integration Points with git-lens

| Component | Integration |
|-----------|-------------|
| **Casey (Agent)** | Detects lens, validates branch context, provides state queries |
| **Tracey (Agent)** | Tracks workflow instances, manages lifecycle events |
| **before-workflow hook** | Validates repo state before workflow proceeds |
| **after-workflow hook** | Checks phase transitions after workflow completes |
| **feature branches** | new-feature registers branches with Casey for lifecycle tracking |
| **state files** | .git-lens/workflow-state.yaml, feature-state.yaml, etc. |

---

## Files Created

```
new-service/steps-c/
  ✓ step-01-lens-check.md
  ✓ step-02-phase-loading.md
  ✓ step-03-git-lens-integration.md

new-microservice/steps-c/
  ✓ step-01-lens-check.md
  ✓ step-02-phase-loading.md
  ✓ step-03-git-lens-integration.md

new-feature/steps-c/
  ✓ step-01-lens-check.md
  ✓ step-02-phase-loading.md
  ✓ step-03-git-lens-integration.md
```

## Files Modified

```
✓ new-service/workflow.md
  - Updated frontmatter with git-lens metadata
  - Updated description and prerequisites
  - Updated nextStep path

✓ new-microservice/workflow.md
  - Updated frontmatter with git-lens metadata
  - Updated description and prerequisites
  - Updated nextStep path

✓ new-feature/workflow.md
  - Updated frontmatter with git-lens metadata
  - Updated description and prerequisites
  - Updated nextStep path
```

---

## Behavior Changes

### User Experience

1. **First run of workflow:** User is now prompted to validate lens before proceeding
2. **Lens mismatch:** User receives contextual suggestions for navigation
3. **Phase awareness:** Workflow loads workflow-guide to establish current phase
4. **git-lens awareness:** Workflow validates and integrates with git-lens state
5. **Transparent tracking:** All workflow instances are tracked by Tracey

### Error Handling

- ✅ Lens validation failures with recovery suggestions
- ✅ Phase detection failures graceful fallback
- ✅ git-lens validation failures with diagnostics
- ✅ Override flags for advanced users

---

## Testing Recommendations

1. **Test lens detection** at different branch/folder contexts
2. **Test navigation suggestions** when at wrong lens
3. **Test workflow-guide integration** and phase detection
4. **Test git-lens validation** and state file creation
5. **Test feature branch creation** for new-feature workflow
6. **Test phase transitions** with git-lens hooks

---

## Documentation References

- **Workflow Map:** https://docs.bmad-method.org/reference/workflow-map/
- **Git-Lens Workflows:** src/modules/lens/extensions/git-lens/workflows/
- **Workflow-Guide:** src/modules/lens/workflows/workflow-guide/

---

## Next Steps

1. ✅ Implementation complete
2. ⏳ Testing required
3. ⏳ User feedback collection
4. ⏳ Integration testing with full lens ecosystem
