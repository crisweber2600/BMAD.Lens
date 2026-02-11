---
name: size-topology
description: Branch hierarchy, size definitions, and merge strategies for lens-work
type: include
---

# Size Topology Reference

This document defines the branch hierarchy used by lens-work to manage initiative lifecycle branches. All branch operations are orchestrated by Casey and triggered through Compass phase commands.

**Branch naming convention:** `{Domain}/{InitiativeId}/{size}-{phaseNumber}-{workflow}`

> **Note:** Domain-layer initiatives use a simplified topology with only the domain branch (`{Domain}`). No initiative ID suffix, no `/base`, no phase branches. The full size/phase hierarchy below applies to service, microservice, and feature layers only.

---

## Branch Hierarchy (4 Levels)

```
Level 0: Domain (domain-layer) {Domain}
Level 1: Initiative Base       {Domain}/{id}/base
Level 2: Sizes                 {Domain}/{id}/small, {Domain}/{id}/large
Level 3: Phases                {Domain}/{id}/{size}-{N}
Level 4: Workflows             {Domain}/{id}/{size}-{N}-{workflow}
```

> Level 0 is used only by domain-layer initiatives. Service/microservice/feature layers start at Level 1.

### Level 0: Domain Branch (Domain-Layer Only)

```
{Domain}
```

Single branch for the entire domain. Created at domain init via `init-initiative` workflow. Domain-layer initiatives hold domain config and folder structure only — actual work happens in service/feature initiatives within the domain.

**Rules:**
- Created from `main` (or current HEAD) at domain init
- No initiative ID suffix — just the domain name
- No phase branches, no audience branches
- Holds domain scaffolding: folders, Domain.yaml, initiative config
- Service/feature initiatives within this domain branch from `main`, not from this branch

---

### Level 1: Initiative Base

```
{Domain}/{initiative_id}/base
```

Root branch for the initiative. Created at init via `init-initiative` workflow. All work merges here eventually through the size → base PR flow. This branch represents the "done" state of the initiative.

**Rules:**
- Created from `main` (or current HEAD) at initiative start
- Never worked on directly — only receives merges from sizes
- Protected: requires PR review for final PBR merge
- One base branch per initiative
- Pushed to remote immediately on creation

---

### Level 2: Sizes

```
{Domain}/{initiative_id}/small     # Small team (planning + implementation)
{Domain}/{initiative_id}/medium    # Medium team (future)
{Domain}/{initiative_id}/large     # Large review (gate reviews)
```

Sizes represent team-size-based workflow paths. Each size has its own lifecycle and phase progression. **Size is stored in the shared initiative config** (`initiatives/{id}.yaml`) — never in personal state.

#### Size Definitions

| Size | Purpose | Typical Team Size | Phases | Created At |
|------|---------|-------------------|--------|------------|
| `small` | Single developer or small team doing end-to-end work | 1–3 | P0–P4 | `init-initiative` |
| `medium` | Medium team with parallel streams (reserved) | 4–8 | P0–P4 | Future |
| `large` | Large review size for gate reviews | 1–2 | Review gates only | `init-initiative` |

#### Size Behaviors

**small size:**
- Primary working size for most initiatives
- Phases P1–P4 branch from and merge back to this size
- All planning and implementation happens here
- After P2 complete → opens PR to `large` for review

**large size:**
- Receives PR from `small` after architecture review gate
- Large-size reviewers approve the planning artifacts
- After approval → opens PR to `base` for final PBR

**medium size (future):**
- Reserved for multi-team initiatives
- Will support parallel phase execution
- Not yet implemented — Compass will reject medium size requests

---

### Level 3: Phases

```
{Domain}/{initiative_id}/{size}-0    # Pre-Plan (optional prep)
{Domain}/{initiative_id}/{size}-1    # Analysis
{Domain}/{initiative_id}/{size}-2    # Planning
{Domain}/{initiative_id}/{size}-3    # Solutioning
{Domain}/{initiative_id}/{size}-4    # Implementation
```

Phases are sequential workflow stages within a size. Each phase branch is created from the size branch when its first workflow begins. **All phase branches are pushed to remote immediately on creation.**

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
2. **Completion = merged:** A phase is complete when its branch is merged into the size
3. **Ancestry check:** `git merge-base --is-ancestor origin/{phase_branch} origin/{size_branch}`
4. **P1 auto-created:** `init-initiative` creates P1 branch automatically
5. **P2–P4 lazy-created:** Created by router workflows on first access
6. **Immediate push:** All phase branches pushed to remote on creation

---

### Level 4: Workflows

```
{Domain}/{initiative_id}/{size}-{N}-{workflow_name}
```

Workflow branches represent individual units of work within a phase. They are created by `start-workflow` and merged back to the phase branch by `finish-workflow`. **All workflow branches are pushed to remote immediately on creation.**

#### Workflow Naming

| Phase | Workflow Name | Full Branch |
|-------|---------------|-------------|
| P1 | `brainstorm` | `{Domain}/{id}/small-1-brainstorm` |
| P1 | `research` | `{Domain}/{id}/small-1-research` |
| P1 | `product-brief` | `{Domain}/{id}/small-1-product-brief` |
| P2 | `prd` | `{Domain}/{id}/small-2-prd` |
| P2 | `ux-design` | `{Domain}/{id}/small-2-ux-design` |
| P2 | `architecture` | `{Domain}/{id}/small-2-architecture` |
| P3 | `epics` | `{Domain}/{id}/small-3-epics` |
| P3 | `stories` | `{Domain}/{id}/small-3-stories` |
| P3 | `readiness-check` | `{Domain}/{id}/small-3-readiness-check` |
| P4 | `dev-story` | `{Domain}/{id}/small-4-dev-story` |
| P4 | `code-review` | `{Domain}/{id}/small-4-code-review` |
| P4 | `retro` | `{Domain}/{id}/small-4-retro` |

#### Workflow Rules

- Created from phase branch via `start-workflow`
- Only one active workflow per phase at a time
- Previous workflow must be merged (ancestry check) before next starts
- Committed and pushed at creation via `start-workflow`
- PR opened: workflow branch → phase branch on `finish-workflow`

---

## Merge Strategies

### Merge Flow Diagram

```
Workflow ──squash──► Phase ──merge──► Size ──PR──► Size ──PR──► Base
 ({size}-{N}-{wf})  ({size}-{N})     (small)      (large)      (base)
```

### Detailed Merge Table

| From → To | Branch Pattern | Strategy | Gate Required | Automation |
|-----------|----------------|----------|---------------|------------|
| workflow → phase | `{size}-{N}-{wf}` → `{size}-{N}` | Squash merge | No (auto) | `finish-workflow` |
| phase → size | `{size}-{N}` → `{size}` | Merge commit | Phase gate | `finish-phase` PR |
| small → large | `small` → `large` | PR merge | Review gate | `open-large-review` |
| large → base | `large` → `base` | PR merge | Final PBR | `open-final-pbr` |

### Phase Transition Flow

```
┌─────────┐    merge     ┌─────────┐    merge     ┌─────────┐    merge     ┌─────────┐
│  P1     │ ──────────► │  P2     │ ──────────► │  P3     │ ──────────► │  P4     │
│Analysis │  gate:p1    │Planning │  gate:p2    │Solution │  gate:p3    │  Impl   │
└─────────┘             └─────────┘             └─────────┘             └─────────┘
                                                      │
                                                      │ PR: small → large
                                                      ▼
                                                ┌─────────┐
                                                │  Large  │
                                                │ Review  │
                                                └────┬────┘
                                                     │ PR: large → base
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
^[A-Za-z0-9_-]+/[a-z0-9-]+/(base|small|medium|large|[a-z]+-[0-9]+(-[a-z0-9-]+)?)$
```

### Parsing Branch Components

```bash
# Extract components from branch name
# Example: MyDomain/rate-limit-x7k2m9/small-2-prd
branch="MyDomain/rate-limit-x7k2m9/small-2-prd"

domain_prefix=$(echo "$branch" | cut -d'/' -f1)    # MyDomain
initiative_id=$(echo "$branch" | cut -d'/' -f2)     # rate-limit-x7k2m9
branch_segment=$(echo "$branch" | cut -d'/' -f3)    # small-2-prd

# Parse the branch segment
size=$(echo "$branch_segment" | cut -d'-' -f1)      # small
phase=$(echo "$branch_segment" | cut -d'-' -f2)     # 2
workflow=$(echo "$branch_segment" | cut -d'-' -f3-)  # prd

# For phase-only branches (e.g., "small-2"):
# workflow will be empty
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
| Medium size requested | Rejected with "not yet implemented" message |

---

## Related Workflows

- **init-initiative:** Creates Level 1 (base) and Level 2 (sizes) branches
- **phase-lifecycle:** Creates Level 3 (phase) branches
- **start-workflow / finish-workflow:** Creates and closes Level 4 (workflow) branches
- **fix-state:** Detects and repairs topology drift
