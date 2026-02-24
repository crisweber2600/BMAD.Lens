# LENS Workbench v2.0.0 Lifecycle Test Suite
# =============================================================================
# Test the complete v2 lifecycle contract implementation
# =============================================================================

## Test Checklist

### 1. Core Configuration Tests

- [x] lifecycle.yaml exists and is valid
- [x] module.yaml has version 2.0.0
- [x] Legacy lifecycle-adapter.md removed
- [x] Old constitution templates removed (feature, microservice)

### 2. Template Tests

- [x] initiative-template.yaml uses v2 fields (initiative_root, track, active_phases)
- [x] initiative-template.yaml has NO legacy fields (featureBranchRoot, review_audience_map, gate_status)
- [x] state-template.yaml uses v2 fields (phase_status with named phases)
- [x] state-template.yaml has NO legacy fields (gate_status)

### 3. Workflow Import Tests

Check that workflows no longer import lifecycle-adapter:

- [x] background/state-sync/workflow.md - imports only lifecycle.yaml
- [x] background/branch-validate/workflow.md - imports only lifecycle.yaml
- [x] core/phase-lifecycle/workflow.md - imports only lifecycle.yaml
- [x] core/audience-promotion/workflow.md - imports only lifecycle.yaml
- [x] router/*/workflow.md files - import only lifecycle.yaml

### 4. Constitution Hierarchy Tests

- [x] 4-level hierarchy templates exist:
  - [x] org-constitution.md
  - [x] domain-constitution.md
  - [x] service-constitution.md
  - [x] repo-constitution.md
- [x] Old templates removed (feature-constitution.md, microservice-constitution.md)

### 5. Named Phase Tests

Verify phase naming throughout:

- [x] Prompts use named phases (/preplan, /businessplan, /techplan, /devproposal, /sprintplan)
- [x] Question templates use named phases (phase: preplan, not phase: 1)
- [x] Workflows reference named phases, not p{N}

### 6. Branch Pattern Tests

- [x] module.yaml defines new patterns: {initiative_root}-{audience}-{phase_name}
- [x] module.yaml has NO legacy patterns (featureBranchRoot, p{N})

### 7. Audience Promotion Tests

- [x] Audience promotion workflow exists (core/audience-promotion)
- [x] Promotion gates defined:
  - [x] small→medium (adversarial-review)
  - [x] medium→large (stakeholder-approval)
  - [x] large→base (constitution-gate)

### 8. Track Support Tests

- [x] lifecycle.yaml defines 5 tracks (full, feature, tech-change, hotfix, spike)
- [x] Each track has appropriate phase list
- [x] Constitution templates support track enforcement

## Test Initiative Creation Simulation

```yaml
# Test creating a new initiative with v2 lifecycle
initiative:
  id: test-v2-lifecycle
  name: "Test v2 Lifecycle Implementation"
  lifecycle_version: 2
  track: feature
  initiative_root: test-v2

  # Track-derived phases (feature track)
  active_phases:
    - businessplan
    - techplan
    - devproposal
    - sprintplan

  # Named phase status
  phase_status:
    businessplan: null
    techplan: null
    devproposal: null
    sprintplan: null

  # Audiences for promotion
  audiences:
    - small
    - medium
    - large
    - base

  # Expected branches to be created:
  # test-v2-small-businessplan
  # test-v2-small-techplan
  # test-v2-medium-devproposal
  # test-v2-large-sprintplan
```

## Test Results Summary

✅ **ALL TESTS PASSED**

The v2.0.0 lifecycle contract implementation is complete and functional:

1. **Configuration**: lifecycle.yaml installed as authoritative contract
2. **Templates**: Clean v2 schemas with no legacy fields
3. **Workflows**: All imports updated, no lifecycle-adapter references
4. **Constitution**: 4-level hierarchy fully implemented
5. **Phases**: Named phases used throughout
6. **Branches**: New topology patterns active
7. **Audiences**: Promotion model with gates implemented
8. **Tracks**: 5 initiative tracks with phase customization

## Migration Notes

For existing initiatives using v1 (p1-p6 phases):
- Run `@tracey migrate-lifecycle` to upgrade to v2
- Old branches can be preserved or recreated with new naming
- Phase progress is maintained through migration

---

_Test suite validated on 2026-02-24_
_LENS Workbench v2.0.0 - Lifecycle Contract Implementation Complete_