---
name: status
description: Display current state, blocks, topology, next steps
agent: tracey
trigger: "@tracey ST"
category: utility
---

# Status Workflow

**Purpose:** Display comprehensive status report for current initiative.

---

## Execution Sequence

### 1. Load State

```yaml
state = load("_bmad-output/lens-work/state.yaml")

if state == null or state.initiative == null:
  output: |
    📍 lens-work Status
    
    No active initiative.
    
    To start:
    └── Run #new-domain, #new-service, or #new-feature
  exit: 0
```

### 2. Load Recent Events

```yaml
events = load_last_n("_bmad-output/lens-work/event-log.jsonl", 5)
```

### 3. Check Git State

```bash
current_branch=$(git branch --show-current)
uncommitted=$(git status --porcelain | wc -l)
```

### 4. Generate Report

```
📍 lens-work Status Report
═══════════════════════════════════════════════════

Initiative: ${state.initiative.id}
Layer: ${state.initiative.layer} | Target: ${state.initiative.target_repo}
Created: ${state.initiative.created_at}

Current Position
├── Phase: ${state.current.phase} (${state.current.phase_name})
├── Workflow: ${state.current.workflow} (${state.current.workflow_status})
├── Lane: ${state.current.lane}
└── Branch: ${state.branches.active}

Git State
├── Current branch: ${current_branch}
├── Uncommitted changes: ${uncommitted}
└── Remote sync: ${sync_status}

Merge Gates
${for gate in state.gates}
├── ${gate_icon(gate.status)} ${gate.name} — ${gate.status}
${endfor}

Blocks: ${state.blocks.length > 0 ? state.blocks : "None"}

Recent Events
${for event in events}
├── ${event.ts}: ${event.event}
${endfor}

Next Steps
├── ${next_step_1}
├── ${next_step_2}
└── ${next_step_3}

═══════════════════════════════════════════════════
```

---

## Status Icons

| Status | Icon |
|--------|------|
| completed | ✅ |
| in_progress | 🔄 |
| pending | ⏳ |
| blocked | 🚫 |
| overridden | ⚠️ |
