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
if not dev_story_exists():
  error: "/review has not produced a dev-ready story. Run /review first."
```

---

## Prerequisites

- [x] `/review` complete
- [x] Dev story exists
- [x] Developer assigned (or self-assigned)

---

## Execution Sequence

### 1. Load Dev Story

```yaml
dev_story = load("_bmad-output/implementation-artifacts/dev-story-${id}.md")

output: |
  🚀 /dev — Implementation Phase
  
  **Story:** ${dev_story.title}
  **Acceptance Criteria:**
  ${dev_story.acceptance_criteria}
  
  **Technical Notes:**
  ${dev_story.technical_notes}
```

### 2. Checkout Target Repo

**IMPORTANT:** This is where we switch from BMAD control repo to TargetProjects.

```yaml
# Casey checks out the feature branch in the actual repo
invoke: casey.checkout-target
params:
  target_repo: "${state.initiative.target_repo}"
  target_path: "TargetProjects/${domain}/${service}/${repo}"
  branch: "feature/${story_id}"

output: |
  📂 Target Repo Ready
  ├── Repo: ${target_repo}
  ├── Path: ${target_path}
  ├── Branch: feature/${story_id}
  └── You can now implement in the target repo
```

### 3. Implementation Guidance

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

### 4. Code Review (when signaled)

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

### 5. Retrospective (optional)

```yaml
offer: "Run retrospective? [Y]es / [N]o"

if yes:
  invoke: casey.start-workflow
  params:
    workflow_name: retro
    
  invoke: bmm.retrospective
  
  invoke: casey.finish-workflow
```

### 6. Complete Initiative

```yaml
if all_phases_complete():
  invoke: tracey.archive
  
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
