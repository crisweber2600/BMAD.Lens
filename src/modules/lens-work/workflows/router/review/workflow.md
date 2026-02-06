---
name: review
description: Implementation gate (readiness/sprint planning)
agent: compass
trigger: /review command
category: router
phase: gate
phase_name: Implementation Gate
---

# /review — Implementation Gate Router

**Purpose:** Validate readiness, run sprint planning, create dev-ready story, and hand off to developers.

---

## Role Authorization

**Authorized:** Scrum Master (gate owner)

```yaml
# This is the SM's gate
if user_role != "Scrum Master":
  advisory: "Typically SM owns /review. Proceeding with ${user_role}."
```

---

## Prerequisites

- [x] `/plan` complete (Phase 3 merged)
- [x] Final PBR approved (lead → base merged)
- [x] Stories exist
- [x] state.yaml + initiatives/{id}.yaml exist
- [x] P3 gate passed (Solutioning artifacts committed)

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

# Validate we're on the correct branch
# /review operates on the current phase branch (typically small-3 or base)
current_branch = casey.get-current-branch()
invoke: casey.pull-latest
```

### 1. Validate Prerequisites & Gate Check

```yaml
# Gate check — verify P3 (Solutioning) is complete
# Branch pattern: {Domain}/{InitiativeId}/{size}-{phaseNumber}
p3_branch = "${domain_prefix}/${initiative.id}/${lane}-3"
lane_branch = "${domain_prefix}/${initiative.id}/${lane}"

# Ancestry check: P3 must be merged into lane
result = casey.exec("git merge-base --is-ancestor origin/${p3_branch} origin/${lane_branch}")

if result.exit_code != 0:
  error: "Phase 3 (Solutioning) not complete. Run /plan first or merge pending PRs."

# Verify final PBR is merged
if not final_pbr_merged():
  error: "Final PBR not approved. Merge large → base PR first."
```

### 1a. Checklist Enforcement — Verify Required Artifacts

```yaml
# Verify all required artifacts exist for current phase
required_artifacts:
  - path: "_bmad-output/planning-artifacts/product-brief.md"
    phase: "p1"
    name: "Product Brief"
  - path: "_bmad-output/planning-artifacts/prd.md"
    phase: "p2"
    name: "PRD"
  - path: "_bmad-output/planning-artifacts/architecture.md"
    phase: "p2"
    name: "Architecture"
  - path: "_bmad-output/planning-artifacts/epics.md"
    phase: "p3"
    name: "Epics"
  - path: "_bmad-output/planning-artifacts/stories.md"
    phase: "p3"
    name: "Stories"
  - path: "_bmad-output/planning-artifacts/readiness-checklist.md"
    phase: "p3"
    name: "Readiness Checklist"

missing = []
for artifact in required_artifacts:
  if not file_exists(artifact.path):
    missing.append("${artifact.name} (${artifact.phase}): ${artifact.path}")

if missing.length > 0:
  output: |
    ⚠️ Missing required artifacts:
    ${missing.join("\n")}
    
    These must exist before passing the implementation gate.
  
  offer: "Continue anyway? [Y]es / [N]o — (choosing Yes will mark gate as 'passed_with_warnings')"
```

### 2. Re-run Readiness Checklist

```yaml
invoke: bmm.readiness-checklist
params:
  mode: "validate"  # Check, don't create
  
if readiness.blockers > 0:
  output: |
    ⚠️ Readiness blockers found:
    ${readiness.blockers}
    
    Resolve blockers before proceeding to implementation.
  exit: 1
```

### 3. Sprint Planning (if Scrum)

```yaml
invoke: bmm.sprint-planning
params:
  stories: "_bmad-output/planning-artifacts/stories.md"
  
output: |
  📋 Sprint Planning
  ├── Stories prioritized
  ├── Capacity allocated
  └── Sprint backlog created
```

### 4. Create Dev-Ready Story

```yaml
invoke: bmm.create-dev-story
params:
  story_id: "${selected_story}"
  output_path: "_bmad-output/implementation-artifacts/"
  
output: |
  📝 Dev Story Created
  ├── Story: ${story_id}
  ├── Acceptance Criteria: ✅
  ├── Technical Notes: ✅
  └── Ready for developer pickup
```

### 5. PR Validation — Generate PR Link

```yaml
# Casey generates PR link for current phase branch → lane branch
invoke: casey.generate-pr-link
params:
  source_branch: "${domain_prefix}/${initiative.id}/${lane}-3"
  target_branch: "${domain_prefix}/${initiative.id}/${lane}"
  title: "[Review] Implementation Gate — ${initiative.name}"
  
output: |
  🔗 Review PR
  ├── Source: ${source_branch}
  ├── Target: ${target_branch}
  └── PR: ${pr_link}
```

### 6. Gate Updates — Mark Pass/Block

```yaml
# Update gate status in initiatives/{id}.yaml
gate_status = missing.length > 0 ? "passed_with_warnings" : "passed"

invoke: tracey.update-initiative
params:
  initiative_id: ${initiative.id}
  updates:
    gates:
      p3_complete:
        status: "passed"
        verified_at: "${ISO_TIMESTAMP}"
      implementation_gate:
        status: ${gate_status}
        verified_at: "${ISO_TIMESTAMP}"
        reviewer: "${user_role}"
        warnings: ${missing.length > 0 ? missing : null}
        readiness_blockers: ${readiness.blockers || 0}
```

### 7. Update State Files

```yaml
# Update initiative file
invoke: tracey.update-initiative
params:
  initiative_id: ${initiative.id}
  updates:
    current_phase_name: "Implementation Gate"
    workflow_status: "review_complete"

# Update state.yaml
invoke: tracey.update-state
params:
  updates:
    workflow_status: "review_complete"
    last_review_at: "${ISO_TIMESTAMP}"
```

### 8. Review Event Logging

```yaml
# Log review actions to event-log.jsonl
events:
  - {"ts":"${ISO_TIMESTAMP}","event":"review-start","id":"${initiative.id}","phase":"gate","workflow":"review"}
  - {"ts":"${ISO_TIMESTAMP}","event":"review-checklist","id":"${initiative.id}","phase":"gate","missing_artifacts":${missing.length},"readiness_blockers":${readiness.blockers || 0}}
  - {"ts":"${ISO_TIMESTAMP}","event":"review-complete","id":"${initiative.id}","phase":"gate","workflow":"review","status":"${gate_status}"}

invoke: tracey.append-events
params:
  events: ${events}
```

### 9. Commit State Changes

```yaml
# Casey commits all state and artifact changes
invoke: casey.commit-and-push
params:
  paths:
    - "_bmad-output/lens-work/state.yaml"
    - "_bmad-output/lens-work/initiatives/${initiative.id}.yaml"
    - "_bmad-output/lens-work/event-log.jsonl"
    - "_bmad-output/implementation-artifacts/"
    - "_bmad-output/planning-artifacts/"
  message: "[lens-work] /review: Implementation Gate ${gate_status} — ${initiative.id}"
  branch: ${current_branch}
```

### 10. Hand Off to Developer

```
✅ /review complete — Implementation Gate ${gate_status}

The following story is ready for development:

**Story:** ${story_title}
**ID:** ${story_id}
**Assigned:** ${developer_name} (or unassigned)

**Developer Instructions:**
1. Run `/dev` to start implementation
2. Casey will checkout the feature branch in TargetProjects
3. Implement the story
4. Return to BMAD directory for code review

Hand off to developer? [Y]es / [N]o
```

---

## Output Artifacts

| Artifact | Location |
|----------|----------|
| Dev Story | `_bmad-output/implementation-artifacts/dev-story-${id}.md` |
| Sprint Backlog | `_bmad-output/planning-artifacts/sprint-backlog.md` |
| Initiative State | `_bmad-output/lens-work/initiatives/${id}.yaml` |
| Event Log | `_bmad-output/lens-work/event-log.jsonl` |

---

## Error Handling

| Error | Recovery |
|-------|----------|
| P3 not complete | Error with merge instructions |
| Final PBR not merged | Error — must merge lead → base PR first |
| Missing artifacts | Warn with list, offer override (passed_with_warnings) |
| Readiness blockers | Block — must resolve before proceeding |
| Dirty working directory | Prompt to stash or commit changes first |
| State file write failed | Retry (max 3 attempts), then fail with save instructions |
| PR link generation failed | Output manual PR instructions |
| Sprint planning failed | Allow manual story selection |

---

## Post-Conditions

- [ ] Working directory clean (all changes committed)
- [ ] All required artifacts verified (or warnings acknowledged)
- [ ] Readiness checklist passed (zero blockers)
- [ ] Dev story created in implementation-artifacts/
- [ ] Gate status recorded in initiatives/{id}.yaml
- [ ] Review events logged to event-log.jsonl
- [ ] state.yaml workflow_status updated to review_complete
- [ ] All changes pushed to origin
- [ ] Developer handoff ready (story + PR link)
