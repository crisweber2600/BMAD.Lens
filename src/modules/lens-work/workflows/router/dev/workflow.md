---
name: dev
description: Implementation loop (dev-story/code-review/retro)
agent: compass
trigger: /dev command
category: router
phase: 4
phase_name: Implementation
---

# /dev — Implementation Phase Router

**Purpose:** Guide developers through implementation, code review, and retrospective.

---

## Role Authorization

**Authorized:** Developer (post-review only)

```yaml
# Dev story check deferred to Step 0 for batch mode support
```

---

## Prerequisites

- [x] `/review` complete
- [x] Dev story exists (interactive mode)
- [x] Developer assigned (or self-assigned)
- [x] state.yaml + initiatives/{id}.yaml exist
- [x] Implementation gate passed (P3 Solutioning complete)

---

## Execution Sequence

### 0. Git Discipline — Verify Clean State

```yaml
# Verify working directory is clean
invoke: casey.verify-clean-state

# Load two-file state
state = load("_bmad-output/lens-work/state.yaml")
initiative = load("_bmad-output/lens-work/initiatives/${state.active_initiative}.yaml")

# Read lane from initiative config (shared, canonical)
lane = initiative.lane
domain_prefix = initiative.domain_prefix

# Require dev story for interactive mode
if initiative.question_mode != "batch" and not dev_story_exists():
  error: "/review has not produced a dev-ready story. Run /review first."

# Lane validation — verify current lane allows dev phase
# Dev (P4) must be on small lane
if lane != "small":
  error: |
    ❌ Lane validation failed
    ├── Current lane: ${lane}
    ├── Required: small
    └── Dev phase (P4) only runs on the small lane.

# Validate we're on the correct branch (or can switch)
# Branch pattern: {Domain}/{InitiativeId}/{size}-{phaseNumber}
expected_branch: "${domain_prefix}/${initiative.id}/${lane}-4"
current_branch = casey.get-current-branch()

if current_branch != expected_branch:
  if branch_exists(expected_branch):
    invoke: casey.checkout-branch
    params:
      branch: ${expected_branch}
    invoke: casey.pull-latest
  # else: branch will be created in Step 1a
```

### 1. Merge Gate Check — P3 Complete

```yaml
# Merge gate checking — verify P3 (Solutioning) is complete before allowing dev
# Branch pattern: {Domain}/{InitiativeId}/{size}-{phaseNumber}
p3_branch = "${domain_prefix}/${initiative.id}/${lane}-3"
lane_branch = "${domain_prefix}/${initiative.id}/${lane}"

# Ancestry check: P3 must be merged into lane (or base)
result = casey.exec("git merge-base --is-ancestor origin/${p3_branch} origin/${lane_branch}")

if result.exit_code != 0:
  error: |
    ❌ Merge gate blocked
    ├── P3 (Solutioning) not merged into lane
    ├── Expected: ${p3_branch} is ancestor of ${lane_branch}
    └── Action: Complete /plan and merge P3 PR first

# Verify implementation gate passed
if initiative.gates.implementation_gate.status not in ["passed", "passed_with_warnings"]:
  error: "Implementation gate not passed. Run /review first."
```

### 1a. Auto-Branch Creation — P4

```yaml
# Casey creates P4 branch if it doesn't exist
# Branch pattern: {Domain}/{InitiativeId}/{size}-{phaseNumber}
if not branch_exists("${domain_prefix}/${initiative.id}/${lane}-4"):
  invoke: casey.start-phase
  params:
    phase_number: 4
    phase_name: "Implementation"
    initiative_id: ${initiative.id}
    lane: ${lane}
    domain_prefix: ${domain_prefix}
  # Casey creates: ${domain_prefix}/{initiative_id}/{lane}-4 and pushes to remote

  invoke: casey.pull-latest
else:
  invoke: casey.checkout-branch
  params:
    branch: "${domain_prefix}/${initiative.id}/${lane}-4"
  invoke: casey.pull-latest
```

### 1b. Batch Mode (Single-File Questions)

```yaml
if initiative.question_mode == "batch":
  invoke: lens-work.batch-process
  params:
    phase_number: "4"
    phase_name: "Implementation"
    template_path: "templates/phase-4-implementation-questions.template.md"
    output_filename: "phase-4-implementation-questions.md"
  exit: 0
```

### 2. Load Dev Story

```yaml
dev_story = load("_bmad-output/implementation-artifacts/dev-story-${id}.md")

output: |
  🚀 /dev — Implementation Phase
  
  **Story:** ${dev_story.title}
  **Acceptance Criteria:**
  ${dev_story.acceptance_criteria}
  
  **Technical Notes:**
  ${dev_story.technical_notes}
  
  **Branch:** ${domain_prefix}/${initiative.id}/${lane}-4
```

### 3. Checkout Target Repo

**IMPORTANT:** This is where we switch from BMAD control repo to TargetProjects.

```yaml
# Casey checks out the feature branch in the actual repo
invoke: casey.checkout-target
params:
  target_repo: "${initiative.target_repos[0]}"
  target_path: "TargetProjects/${domain}/${service}/${repo}"
  branch: "feature/${story_id}"

output: |
  📂 Target Repo Ready
  ├── Repo: ${target_repo}
  ├── Path: ${target_path}
  ├── Branch: feature/${story_id}
  └── You can now implement in the target repo
```

### 4. Implementation Guidance

```
🔧 Implementation Mode

You're now working in: ${target_path}

**Remember:**
- Implement the story in the target repo
- Commit frequently with meaningful messages
- Return to BMAD directory when ready for code review

**Commands available:**
- `@compass done` — Signal implementation complete, start code review
- `@tracey ST` — Check status
- `@compass help` — Show available commands
```

### 5. Code Review (when signaled)

```yaml
# User signals: @compass done
invoke: casey.start-workflow
params:
  workflow_name: code-review

invoke: bmm.code-review
params:
  target_repo: "${target_path}"
  branch: "feature/${story_id}"

invoke: casey.finish-workflow
```

### 6. Retrospective (optional)

```yaml
offer: "Run retrospective? [Y]es / [N]o"

if yes:
  invoke: casey.start-workflow
  params:
    workflow_name: retro
    
  invoke: bmm.retrospective
  
  invoke: casey.finish-workflow
```

### 7. Update State Files & Initiative Config

```yaml
# Update initiative file: _bmad-output/lens-work/initiatives/${initiative.id}.yaml
invoke: tracey.update-initiative
params:
  initiative_id: ${initiative.id}
  updates:
    current_phase: "p4"
    current_phase_name: "Implementation"
    phases:
      p4:
        status: "in_progress"
        started_at: "${ISO_TIMESTAMP}"
    gates:
      p3_complete:
        status: "passed"
        verified_at: "${ISO_TIMESTAMP}"
      dev_started:
        status: "in_progress"
        started_at: "${ISO_TIMESTAMP}"
        story_id: "${story_id}"

# Update state.yaml current phase to p4
invoke: tracey.update-state
params:
  updates:
    current_phase: "p4"
    current_phase_name: "Implementation"
    active_branch: "${domain_prefix}/${initiative.id}/${lane}-4"
    workflow_status: "in_progress"
```

### 8. Commit State Changes

```yaml
# Casey commits all state and artifact changes
invoke: casey.commit-and-push
params:
  paths:
    - "_bmad-output/lens-work/state.yaml"
    - "_bmad-output/lens-work/initiatives/${initiative.id}.yaml"
    - "_bmad-output/lens-work/event-log.jsonl"
    - "_bmad-output/implementation-artifacts/"
  message: "[lens-work] /dev: Phase 4 Implementation — ${initiative.id} — ${story_id}"
  branch: "${domain_prefix}/${initiative.id}/${lane}-4"
```

### 9. Log Event

```json
{"ts":"${ISO_TIMESTAMP}","event":"dev","id":"${initiative.id}","phase":"p4","workflow":"dev","story":"${story_id}","status":"in_progress"}
```

### 10. Complete Initiative (when all done)

```yaml
if all_phases_complete():
  invoke: tracey.update-initiative
  params:
    initiative_id: ${initiative.id}
    updates:
      status: "complete"
      completed_at: "${ISO_TIMESTAMP}"
      phases:
        p4:
          status: "complete"
          completed_at: "${ISO_TIMESTAMP}"

  invoke: tracey.archive
  
  # Final commit
  invoke: casey.commit-and-push
  params:
    paths:
      - "_bmad-output/lens-work/"
    message: "[lens-work] Initiative complete — ${initiative.id}"
  
  output: |
    🎉 Initiative Complete!
    ├── All phases finished
    ├── Code merged to main
    ├── Initiative archived
    └── Great work, team!
```

---

## Control-Plane Rule Reminder

Throughout `/dev`, the user may work in TargetProjects for actual coding, but all lens-work commands continue to execute from the BMAD directory:

| Action | Location |
|--------|----------|
| Write code | TargetProjects/${repo} |
| Run /dev commands | BMAD directory |
| Code review | BMAD directory |
| Status checks | BMAD directory |

---

## Output Artifacts

| Artifact | Location |
|----------|----------|
| Code Review Report | `_bmad-output/implementation-artifacts/code-review-${id}.md` |
| Retro Notes | `_bmad-output/implementation-artifacts/retro-${id}.md` |
| Initiative State | `_bmad-output/lens-work/initiatives/${id}.yaml` |
| Event Log | `_bmad-output/lens-work/event-log.jsonl` |

---

## Error Handling

| Error | Recovery |
|-------|----------|
| No dev story | Prompt to run /review first |
| P3 not merged | Error with merge gate blocked message |
| Implementation gate not passed | Error — run /review first |
| Lane validation failed | Error — must be on small lane for P4 |
| Dirty working directory | Prompt to stash or commit changes first |
| Target repo checkout failed | Check target_repos config, retry |
| Branch creation failed | Check remote connectivity, retry with backoff |
| Code review failed | Allow retry or manual review |
| State file write failed | Retry (max 3 attempts), then fail with save instructions |

---

## Post-Conditions

- [ ] Working directory clean (all changes committed)
- [ ] On correct branch: `{domain_prefix}/{initiative_id}/{lane}-4`
- [ ] Lane validated as "small" for dev phase
- [ ] state.yaml updated with phase p4
- [ ] initiatives/{id}.yaml updated with p4 status and gate entries
- [ ] event-log.jsonl entries appended
- [ ] Dev story loaded and implementation started
- [ ] Target repo feature branch checked out
- [ ] All state changes pushed to origin
