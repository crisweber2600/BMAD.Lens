---
name: pre-plan
description: Launch Analysis phase (brainstorm/research/product brief)
agent: compass
trigger: /pre-plan command
category: router
phase: 1
phase_name: Analysis
---

# /pre-plan — Analysis Phase Router

**Purpose:** Guide users through the Analysis phase, invoking brainstorming, research, and product brief workflows.

---

## Role Authorization

**Authorized:** PO, Architect, Tech Lead

```yaml
# Advisory check (logged, not blocking)
if user_role not in ["PO", "Architect", "Tech Lead"]:
  log_warning("Role ${user_role} typically doesn't initiate /pre-plan")
```

---

## Prerequisites

- [x] Initiative created via `#new-*` command
- [x] Layer detected with confidence ≥ 75%
- [x] state.yaml exists with active initiative

---

## Execution Sequence

### 1. Validate State

```yaml
# Check state.yaml
if state.initiative == null:
  error: "No active initiative. Run #new-domain, #new-service, or #new-feature first."
  
if state.current.phase != "p1":
  warning: "Current phase is ${state.current.phase}. /pre-plan is for Phase 1."
```

### 2. Start Phase (if needed)

```yaml
# Invoke Casey if p1 branch doesn't exist
if not branch_exists("lens/${initiative_id}/small/p1"):
  invoke: casey.start-phase
  params:
    phase_number: 1
    phase_name: "Analysis"
```

### 3. Offer Workflow Options

```
🧭 /pre-plan — Analysis Phase

You're starting the Analysis phase. Available workflows:

**[1] Brainstorming** (optional) — Creative exploration with CIS
**[2] Research** (optional) — Deep dive research with CIS  
**[3] Product Brief** (required) — Define problem, vision, and scope

Recommended path: 1 → 2 → 3 (or skip to 3 if you have clarity)

Select workflow(s) to run: [1] [2] [3] [A]ll [S]kip to Product Brief
```

### 4. Execute Selected Workflows

#### If Brainstorming selected:
```yaml
invoke: casey.start-workflow
params:
  workflow_name: brainstorm

invoke: cis.brainstorming  # CIS module workflow
params:
  context: "${initiative_name} at ${layer} layer"

invoke: casey.finish-workflow
```

#### If Research selected:
```yaml
invoke: casey.start-workflow
params:
  workflow_name: research

invoke: cis.research  # CIS module workflow

invoke: casey.finish-workflow
```

#### Product Brief (always):
```yaml
invoke: casey.start-workflow
params:
  workflow_name: product-brief

invoke: bmm.product-brief  # BMM module workflow
params:
  output_path: "_bmad-output/planning-artifacts/"

invoke: casey.finish-workflow
```

### 5. Phase Completion Check

```yaml
if all_workflows_complete("p1"):
  invoke: casey.finish-phase
  
  output: |
    ✅ /pre-plan complete
    ├── Phase 1 (Analysis) finished
    ├── Artifacts: product-brief.md
    └── Next: Run /spec to continue to Planning phase
```

### 6. Offer Next Step

```
Ready to continue?

**[C]** Continue to /spec (Planning phase)
**[P]** Pause here (resume later with @compass /spec)
**[S]** Show status (@tracey ST)
```

---

## Output Artifacts

| Artifact | Location |
|----------|----------|
| Product Brief | `_bmad-output/planning-artifacts/product-brief.md` |
| Brainstorm Notes | `_bmad-output/planning-artifacts/brainstorm-notes.md` |
| Research Summary | `_bmad-output/planning-artifacts/research-summary.md` |

---

## Error Handling

| Error | Recovery |
|-------|----------|
| No initiative | Prompt to run #new-* first |
| Wrong phase | Warn but allow override |
| CIS not installed | Skip brainstorm/research, proceed to product brief |
