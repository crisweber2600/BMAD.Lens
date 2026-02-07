---
name: plan
description: Complete Solutioning (Epics/Stories/Readiness)
agent: compass
trigger: /plan command
category: router
phase: 3
phase_name: Solutioning
---

# /plan — Solutioning Phase Router

**Purpose:** Complete the Solutioning phase with Epics, Stories, and Readiness checklist.

---

## Role Authorization

**Authorized:** PO, Architect, Tech Lead

---

## Prerequisites

- [x] `/spec` complete (Phase 2 merged)
- [x] Large review approved (small → large merged)
- [x] state.yaml + initiatives/{id}.yaml exist
- [x] P2 gate passed (Planning artifacts committed)

---

## Execution Sequence

### 0. Git Discipline — Verify Clean State

```yaml
# Verify working directory is clean
invoke: casey.verify-clean-state

# Load two-file state
state = load("_bmad-output/lens-work/state.yaml")
initiative = load("_bmad-output/lens-work/initiatives/${state.active_initiative}.yaml")

# Read size from initiative config (shared, canonical)
size = initiative.size
domain_prefix = initiative.domain_prefix

# Validate we're on the correct branch (or can switch)
# Branch pattern: {Domain}/{InitiativeId}/{size}-{phaseNumber}
expected_branch: "${domain_prefix}/${initiative.id}/${size}-3"
current_branch = casey.get-current-branch()

if current_branch != expected_branch:
  if branch_exists(expected_branch):
    invoke: casey.checkout-branch
    params:
      branch: ${expected_branch}
    invoke: casey.pull-latest
  # else: branch will be created in Step 2
```

### 1. Validate Prerequisites & Gate Check

```yaml
# Gate check — verify P2 (Spec/Planning) is complete
# Branch pattern: {Domain}/{InitiativeId}/{size}-{phaseNumber}
p2_branch = "${domain_prefix}/${initiative.id}/${size}-2"
size_branch = "${domain_prefix}/${initiative.id}/${size}"

# Ancestry check: P2 must be merged into size branch
result = casey.exec("git merge-base --is-ancestor origin/${p2_branch} origin/${size_branch}")

if result.exit_code != 0:
  error: "Phase 2 (Planning) not complete. Run /spec first or merge pending PRs."

# Verify large review is merged (if applicable)
if not large_review_merged():
  warning: "Large review PR not merged. Proceeding but architecture may change."

# Verify P2 artifacts exist
required_artifacts:
  - "_bmad-output/planning-artifacts/prd.md"
  - "_bmad-output/planning-artifacts/architecture.md"

for artifact in required_artifacts:
  if not file_exists(artifact):
    warning: "Required artifact not found: ${artifact}."
```

### 2. Start Phase 3 — Auto-Branch Creation

```yaml
# Casey creates P3 branch if it doesn't exist
# Branch pattern: {Domain}/{InitiativeId}/{size}-{phaseNumber}
if not branch_exists("${domain_prefix}/${initiative.id}/${size}-3"):
  invoke: casey.start-phase
  params:
    phase_number: 3
    phase_name: "Solutioning"
    initiative_id: ${initiative.id}
    size: ${size}
    domain_prefix: ${domain_prefix}
  # Casey creates: ${domain_prefix}/{initiative_id}/{size}-3 and pushes to remote

  invoke: casey.pull-latest
else:
  # Branch exists, ensure we're on it
  invoke: casey.checkout-branch
  params:
    branch: "${domain_prefix}/${initiative.id}/${size}-3"
  invoke: casey.pull-latest
```

### 2a. Batch Mode (Single-File Questions)

```yaml
if initiative.question_mode == "batch":
  invoke: lens-work.batch-process
  params:
    phase_number: "3"
    phase_name: "Solutioning"
    template_path: "templates/phase-3-solutioning-questions.template.md"
    output_filename: "phase-3-solutioning-questions.md"
  exit: 0
```

### 3. Execute Workflows

#### Epics — Story Breakdown Integration:
```yaml
invoke: casey.start-workflow
params:
  workflow_name: epics

# Reference Epic generation workflow from BMM module
invoke: bmm.create-epics
params:
  architecture: "_bmad-output/planning-artifacts/architecture.md"
  prd: "_bmad-output/planning-artifacts/prd.md"
  output_path: "_bmad-output/planning-artifacts/"

invoke: casey.finish-workflow
```

#### Stories — Story Breakdown Integration:
```yaml
invoke: casey.start-workflow
params:
  workflow_name: stories

# Reference Story generation workflow from BMM module
invoke: bmm.create-stories
params:
  epics: "_bmad-output/planning-artifacts/epics.md"
  architecture: "_bmad-output/planning-artifacts/architecture.md"
  output_path: "_bmad-output/planning-artifacts/"

invoke: casey.finish-workflow
```

#### Readiness Checklist:
```yaml
invoke: casey.start-workflow
params:
  workflow_name: readiness

invoke: bmm.readiness-checklist
params:
  artifacts:
    - product-brief.md
    - prd.md
    - architecture.md
    - epics.md
    - stories.md
  output_path: "_bmad-output/planning-artifacts/"

invoke: casey.finish-workflow
```

### 4. Phase Completion

```yaml
if all_workflows_complete("p3"):
  invoke: casey.finish-phase
  invoke: casey.open-final-pbr  # PR: large → base
  
  output: |
    ✅ /plan complete
    ├── Phase 3 (Solutioning) finished
    ├── Final PBR PR opened (large → base)
    ├── Stories ready for sprint planning
    └── Next: Run /review for implementation gate
```

### 5. Update State Files

```yaml
# Update initiative file: _bmad-output/lens-work/initiatives/${initiative.id}.yaml
invoke: tracey.update-initiative
params:
  initiative_id: ${initiative.id}
  updates:
    current_phase: "p3"
    current_phase_name: "Solutioning"
    phases:
      p3:
        status: "in_progress"
        started_at: "${ISO_TIMESTAMP}"
    gates:
      p2_complete:
        status: "passed"
        verified_at: "${ISO_TIMESTAMP}"
      large_review:
        status: "passed"
        verified_at: "${ISO_TIMESTAMP}"

# Update state.yaml
invoke: tracey.update-state
params:
  updates:
    current_phase: "p3"
    current_phase_name: "Solutioning"
    active_branch: "${domain_prefix}/${initiative.id}/${size}-3"
```

### 6. Commit State Changes

```yaml
# Casey commits all state and artifact changes
invoke: casey.commit-and-push
params:
  paths:
    - "_bmad-output/lens-work/state.yaml"
    - "_bmad-output/lens-work/initiatives/${initiative.id}.yaml"
    - "_bmad-output/lens-work/event-log.jsonl"
    - "_bmad-output/planning-artifacts/"
  message: "[lens-work] /plan: Phase 3 Solutioning — ${initiative.id}"
  branch: "${domain_prefix}/${initiative.id}/${size}-3"
```

### 7. Log Event

```json
{"ts":"${ISO_TIMESTAMP}","event":"plan","id":"${initiative.id}","phase":"p3","workflow":"plan","status":"complete"}
```

---

## Output Artifacts

| Artifact | Location |
|----------|----------|
| Epics | `_bmad-output/planning-artifacts/epics.md` |
| Stories | `_bmad-output/planning-artifacts/stories.md` |
| Readiness | `_bmad-output/planning-artifacts/readiness-checklist.md` |
| Initiative State | `_bmad-output/lens-work/initiatives/${id}.yaml` |

---

## Error Handling

| Error | Recovery |
|-------|----------|
| P2 not complete | Error with merge instructions |
| Lead review not merged | Warn but allow proceeding |
| PRD/Architecture missing | Warn, proceeding may produce incomplete epics |
| Dirty working directory | Prompt to stash or commit changes first |
| Branch creation failed | Check remote connectivity, retry with backoff |
| P2 ancestry check failed | Prompt to merge P2 PR before continuing |
| Epic/Story generation failed | Retry or allow manual creation |
| State file write failed | Retry (max 3 attempts), then fail with save instructions |

---

## Post-Conditions

- [ ] Working directory clean (all changes committed)
- [ ] On correct branch: `{domain_prefix}/{initiative_id}/{size}-3`
- [ ] state.yaml updated with phase p3
- [ ] initiatives/{id}.yaml updated with p3 status and p2 gate passed
- [ ] event-log.jsonl entry appended
- [ ] Planning artifacts written (epics, stories, readiness-checklist)
- [ ] Final PBR PR opened (large → base)
- [ ] All changes pushed to origin
