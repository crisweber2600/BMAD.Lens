---
name: resume
description: Rehydrate from state.yaml, explain context
agent: tracey
trigger: "@tracey RS"
category: utility
---

# Resume Workflow

**Purpose:** Rehydrate session from state.yaml and explain current context.

---

## Execution Sequence

### 1. Load State

```yaml
state = load("_bmad-output/lens-work/state.yaml")

if state == null:
  output: "No state found. Nothing to resume."
  exit: 0
```

### 2. Load Event History

```yaml
events = load_last_n("_bmad-output/lens-work/event-log.jsonl", 10)
last_event = events[0]
```

### 3. Analyze Context

```yaml
context:
  initiative: state.initiative.name
  layer: state.initiative.layer
  current_phase: state.current.phase_name
  current_workflow: state.current.workflow
  last_action: last_event.event
  last_action_time: last_event.ts
  time_since: calculate_duration(last_event.ts, now())
```

### 4. Output Context Summary

```
🔄 Resuming lens-work Session

**Initiative:** ${context.initiative}
**Layer:** ${context.layer}

**Where you left off:**
├── Phase: ${context.current_phase}
├── Workflow: ${context.current_workflow}
├── Last action: ${context.last_action}
└── Time since: ${context.time_since}

**What was happening:**
${describe_last_action(last_event)}

**What you can do now:**
${if state.current.workflow_status == "in_progress"}
├── Continue working on ${state.current.workflow}
├── Or finish with: @compass done
${else}
├── Continue to next phase with: @compass /${next_phase_command}
├── Check full status with: @tracey ST
${endif}
└── Get help with: @compass H

Ready to continue?
```

---

## Time-Based Context

| Time Since | Message |
|------------|---------|
| < 1 hour | "Picking up where you left off..." |
| 1-24 hours | "Welcome back! Here's where you were..." |
| > 24 hours | "It's been a while. Let me remind you..." |
| > 7 days | "Resuming after extended break. Full context below..." |
