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
- [x] Final PBR approved (large → base merged)
- [x] Stories exist

---

## Execution Sequence

### 1. Validate Prerequisites

```yaml
if not phase_complete("p3"):
  error: "Phase 3 (Solutioning) not complete. Run /plan first."

if not final_pbr_merged():
  error: "Final PBR not approved. Merge large → base PR first."
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
  
output: |
  📝 Dev Story Created
  ├── Story: ${story_id}
  ├── Acceptance Criteria: ✅
  ├── Technical Notes: ✅
  └── Ready for developer pickup
```

### 5. Hand Off to Developer

```
✅ /review complete — Implementation Gate Passed

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
