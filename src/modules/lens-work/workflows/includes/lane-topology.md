---
name: lane-topology
description: Branch hierarchy, lane definitions, and merge strategies for lens-work
type: include
---

# Lane Topology Reference

This document defines the 4-level branch hierarchy used by lens-work to manage initiative lifecycle branches. All branch operations are orchestrated by Casey and triggered through Compass phase commands.

---

## Branch Hierarchy (4 Levels)

```
Level 1: Initiative Base
└── Level 2: Lanes
    └── Level 3: Phases
        └── Level 4: Workflows
```

### Level 1: Initiative Base

```
lens/{initiative_id}/base
```

Root branch for the initiative. Created at init via `init-initiative` workflow. All work merges here eventually through the lane → base PR flow. This branch represents the "done" state of the initiative.

**Rules:**
- Created from `main` (or current HEAD) at initiative start
- Never worked on directly — only receives merges from lanes
- Protected: requires PR review for final PBR merge
- One base branch per initiative

---

### Level 2: Lanes

```
lens/{initiative_id}/small     # Small team (planning + implementation)
lens/{initiative_id}/medium    # Medium team (future)
lens/{initiative_id}/lead      # Lead review (gate reviews)
```

Lanes represent team-size-based workflow paths. Each lane has its own lifecycle and phase progression.

#### Lane Definitions

| Lane | Purpose | Typical Team Size | Phases | Created At |
|------|---------|-------------------|--------|------------|
| `small` | Single developer or small team doing end-to-end work | 1–3 | P0–P4 | `init-initiative` |
| `medium` | Medium team with parallel streams (reserved) | 4–8 | P0–P4 | Future |
| `lead` | Lead/architect review lane for gate reviews | 1–2 | Review gates only | `init-initiative` |

#### Lane Behaviors

**small lane:**
- Primary working lane for most initiatives
- Phases P1–P4 branch from and merge back to this lane
- All planning and implementation happens here
- After P2 complete → opens PR to `lead` for review

**lead lane:**
- Receives PR from `small` after architecture review gate
- Lead reviews and approves the planning artifacts
- After approval → opens PR to `base` for final PBR

**medium lane (future):**
- Reserved for multi-team initiatives
- Will support parallel phase execution
- Not yet implemented — Compass will reject medium lane requests

---

### Level 3: Phases

```
lens/{initiative_id}/{lane}/p0    # Pre-Plan (optional prep)
lens/{initiative_id}/{lane}/p1    # Analysis
lens/{initiative_id}/{lane}/p2    # Planning
lens/{initiative_id}/{lane}/p3    # Solutioning
lens/{initiative_id}/{lane}/p4    # Implementation
```

Phases are sequential workflow stages within a lane. Each phase branch is created from the lane branch when its first workflow begins.

#### Phase Definitions

| Phase | Name | Purpose | Key Artifacts | Trigger Command |
|-------|------|---------|---------------|-----------------|
| P0 | Pre-Plan | Constitution, discovery prep | `constitution.md` | `/pre-plan` |
| P1 | Analysis | Brainstorm, research, product brief | `p1-product-brief.md`, `p1-research-notes.md` | `/pre-plan` |
| P2 | Planning | PRD, UX design, architecture | `p2-prd.md`, `p2-ux-design.md`, `p2-architecture.md` | `/spec` |
| P3 | Solutioning | Epics, stories, readiness check | `p3-epics.md`, `p3-stories/`, `p3-readiness-checklist.md` | `/plan` |
| P4 | Implementation | Dev stories, code review, retro | `p4-story-impl/`, `p4-review-notes.md`, `p4-retro.md` | `/dev` |

#### Phase Progression Rules

1. **Sequential only:** P{N} must complete before P{N+1} can start
2. **Completion = merged:** A phase is complete when its branch is merged into the lane
3. **Ancestry check:** `git merge-base --is-ancestor origin/{phase_branch} origin/{lane_branch}`
4. **P1 auto-created:** `init-initiative` creates P1 branch automatically
5. **P2–P4 lazy-created:** Created by router workflows on first access

---

### Level 4: Workflows

```
lens/{initiative_id}/{lane}/p{N}/w/{workflow_name}
```

Workflow branches represent individual units of work within a phase. They are created by `start-workflow` and merged back to the phase branch by `finish-workflow`.

#### Workflow Naming

| Phase | Workflow Name | Full Branch |
|-------|---------------|-------------|
| P1 | `brainstorm` | `lens/{id}/small/p1/w/brainstorm` |
| P1 | `research` | `lens/{id}/small/p1/w/research` |
| P1 | `product-brief` | `lens/{id}/small/p1/w/product-brief` |
| P2 | `prd` | `lens/{id}/small/p2/w/prd` |
| P2 | `ux-design` | `lens/{id}/small/p2/w/ux-design` |
| P2 | `architecture` | `lens/{id}/small/p2/w/architecture` |
| P3 | `epics` | `lens/{id}/small/p3/w/epics` |
| P3 | `stories` | `lens/{id}/small/p3/w/stories` |
| P3 | `readiness-check` | `lens/{id}/small/p3/w/readiness-check` |
| P4 | `dev-story` | `lens/{id}/small/p4/w/dev-story` |
| P4 | `code-review` | `lens/{id}/small/p4/w/code-review` |
| P4 | `retro` | `lens/{id}/small/p4/w/retro` |

#### Workflow Rules

- Created from phase branch via `start-workflow`
- Only one active workflow per phase at a time
- Previous workflow must be merged (ancestry check) before next starts
- Committed and pushed via `finish-workflow`
- PR opened: workflow branch → phase branch

---

## Merge Strategies

### Merge Flow Diagram

```
Workflow ──squash──► Phase ──merge──► Lane ──PR──► Lane ──PR──► Base
  (w/*)              (p{N})          (small)       (lead)       (base)
```

### Detailed Merge Table

| From → To | Branch Pattern | Strategy | Gate Required | Automation |
|-----------|----------------|----------|---------------|------------|
| workflow → phase | `p{N}/w/{name}` → `p{N}` | Squash merge | No (auto) | `finish-workflow` |
| phase → lane | `p{N}` → `{lane}` | Merge commit | Phase gate | `finish-phase` PR |
| small → lead | `small` → `lead` | PR merge | Review gate | `open-lead-review` |
| lead → base | `lead` → `base` | PR merge | Final PBR | `open-final-pbr` |

### Phase Transition Flow

```
┌─────────┐    merge     ┌─────────┐    merge     ┌─────────┐    merge     ┌─────────┐
│  P1     │ ──────────► │  P2     │ ──────────► │  P3     │ ──────────► │  P4     │
│Analysis │  gate:p1    │Planning │  gate:p2    │Solution │  gate:p3    │  Impl   │
└─────────┘             └─────────┘             └─────────┘             └─────────┘
                                                      │
                                                      │ PR: small → lead
                                                      ▼
                                                ┌─────────┐
                                                │  Lead   │
                                                │ Review  │
                                                └────┬────┘
                                                     │ PR: lead → base
                                                     ▼
                                                ┌─────────┐
                                                │  Base   │
                                                │ (Done)  │
                                                └─────────┘
```

### Merge Validation

Before any merge, Casey validates:

1. **Clean state:** No uncommitted changes in working tree
2. **Ancestry:** Source branch is ahead of target (has commits to merge)
3. **Gate passed:** Required gate status is `passed` or `passed_with_warnings`
4. **No conflicts:** Merge preview is clean (or flagged for manual resolution)

```bash
# Ancestry check pattern
git merge-base --is-ancestor origin/${target_branch} origin/${source_branch}

# Conflict preview
git merge --no-commit --no-ff ${source_branch} && git merge --abort
```

---

## Branch Naming Validation

Casey validates all branch names against this regex:

```regex
^lens/[a-z0-9-]+/(base|small|medium|lead)(/p[0-4](/w/[a-z0-9-]+)?)?$
```

### Parsing Branch Components

```bash
# Extract components from branch name
branch="lens/rate-limit-x7k2m9/small/p2/w/prd"

initiative_id=$(echo "$branch" | cut -d'/' -f2)   # rate-limit-x7k2m9
lane=$(echo "$branch" | cut -d'/' -f3)             # small
phase=$(echo "$branch" | cut -d'/' -f4)            # p2
workflow=$(echo "$branch" | cut -d'/' -f6)          # prd
```

---

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| Initiative ID collision | Regenerate random suffix, prompt user |
| Branch already exists | Skip creation, checkout existing |
| Orphaned workflow branch | Detected by `fix-state`, prompted for cleanup |
| Phase skipped | Blocked — sequential enforcement is strict |
| Multiple active workflows | Blocked — one workflow per phase at a time |
| Medium lane requested | Rejected with "not yet implemented" message |

---

## Related Workflows

- **init-initiative:** Creates Level 1 (base) and Level 2 (lanes) branches
- **phase-lifecycle:** Creates Level 3 (phase) branches
- **start-workflow / finish-workflow:** Creates and closes Level 4 (workflow) branches
- **fix-state:** Detects and repairs topology drift
