---
name: start-workflow
description: Create workflow branch with merge-gate validation
agent: casey
trigger: Compass invokes when user begins a workflow
category: core
auto_triggered: true
---

# Start Workflow

**Purpose:** Create a workflow branch with merge-gate validation.

---

## Input Parameters

```yaml
workflow_name: string      # e.g., "discovery", "brainstorm", "product-brief"
phase: string              # e.g., "p1", "p2", "p3"
lane: string               # e.g., "small", "large"
initiative_id: string      # From state.yaml
```

---

## Execution Sequence

### 1. Load Current State

```yaml
# Read from _bmad-output/lens-work/state.yaml
initiative_id: ${state.initiative.id}
current_phase: ${state.current.phase}
current_lane: ${state.current.lane}
```

### 2. Validate Merge Gate

```bash
# Get previous workflow in this phase (if any)
previous_workflow=$(get_previous_workflow ${phase} ${workflow_name})

if [ -n "$previous_workflow" ]; then
  # Check if previous workflow is merged into phase branch
  phase_branch="lens/${initiative_id}/${lane}/${phase}"
  workflow_branch="lens/${initiative_id}/${lane}/${phase}/w/${previous_workflow}"
  
  git fetch origin ${phase_branch} ${workflow_branch}
  
  if ! git merge-base --is-ancestor origin/${workflow_branch} origin/${phase_branch}; then
    # GATE BLOCKED
    echo "⚠️ Merge gate blocked"
    echo "├── Expected: ${previous_workflow} merged to ${phase}"
    echo "├── Actual: ${previous_workflow} not found in ancestry"
    echo "└── Action: Complete and merge previous workflow first"
    exit 1
  fi
fi
```

### 3. Create Workflow Branch

```bash
# Branch from phase
git checkout "lens/${initiative_id}/${lane}/${phase}"
git pull origin "lens/${initiative_id}/${lane}/${phase}"
git checkout -b "lens/${initiative_id}/${lane}/${phase}/w/${workflow_name}"
```

### 4. Update State

```yaml
# Update _bmad-output/lens-work/state.yaml
current:
  workflow: ${workflow_name}
  workflow_status: in_progress

branches:
  active: "lens/${initiative_id}/${lane}/${phase}/w/${workflow_name}"

gates:
  - name: "${phase}/w/${workflow_name}"
    status: in_progress
    started_at: "${ISO_TIMESTAMP}"
```

### 5. Log Event

```json
{"ts":"${ISO_TIMESTAMP}","event":"start-workflow","workflow":"${workflow_name}","branch":"lens/${initiative_id}/${lane}/${phase}/w/${workflow_name}"}
```

### 6. Output

```
✅ Workflow branch created
├── Branch: lens/${initiative_id}/${lane}/${phase}/w/${workflow_name}
├── Phase: ${phase}
└── Status: in_progress
```

---

## Error Handling

| Error | Recovery |
|-------|----------|
| Gate blocked | Return block message, do not create branch |
| Branch exists | Checkout existing, warn user |
| Fetch failed | Retry with backoff, then fail gracefully |
