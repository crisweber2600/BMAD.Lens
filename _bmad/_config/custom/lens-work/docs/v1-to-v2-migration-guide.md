# LENS Workbench v1 to v2 Migration Guide

## Overview

LENS Workbench v2.0.0 introduces the **Lifecycle Contract** — a fundamental redesign of how phases, audiences, and governance work. This guide helps you migrate existing v1 initiatives to v2.

---

## What's Changed

### 1. Phase Naming

| v1 Numbered | v2 Named | Description | Agent |
|------------|----------|-------------|-------|
| p1 | preplan | Discovery & brainstorming | Mary (Analyst) |
| p2 | businessplan | Requirements & PRD | John (PM) + Sally (UX) |
| p3 | techplan | Architecture & technical design | Winston (Architect) |
| p4 | devproposal | Epics, stories & readiness | John (PM) |
| p5 | sprintplan | Sprint planning & handoff | Bob (SM) |
| p6 | dev | Implementation | Dev Team |

### 2. Command Changes

| v1 Command | v2 Command | Notes |
|------------|------------|--------|
| `/pre-plan` | `/preplan` | Alias still works |
| `/spec` | `/businessplan` | `/spec` is alias |
| `/tech-plan` | `/techplan` | Alias still works |
| `/plan` | `/devproposal` | `/plan` is alias |
| `/story-gen` | (part of `/devproposal`) | Integrated into devproposal |
| `/review` | `/sprintplan` | `/review` is alias |

### 3. Audience Model

**v1 Model:** Phases owned audiences
- p1 → small
- p2 → medium
- p3 → large
- p4 → large
- p5 → large
- p6 → target projects

**v2 Model:** Audiences own phases
- **small** → preplan, businessplan, techplan (all IC creation)
- **medium** → devproposal (lead review)
- **large** → sprintplan (stakeholder approval)
- **base** → dev (execution)

### 4. Promotion Gates

v2 introduces explicit audience promotion gates:

| Promotion | Gate | Command |
|-----------|------|---------|
| small → medium | Adversarial review (party mode) | `/promote` |
| medium → large | Stakeholder approval | `/promote` |
| large → base | Constitution gate | `/promote` |

### 5. Branch Naming

| v1 Pattern | v2 Pattern |
|------------|------------|
| `{featureBranchRoot}-{audience}-p{N}` | `{initiative_root}-{audience}-{phase_name}` |
| `feature-small-p1` | `initiative-small-preplan` |
| `feature-medium-p2-workflow` | `initiative-small-businessplan-workflow` |

### 6. Initiative Tracks

v2 introduces **tracks** that determine which phases are active:

| Track | Phases | Use Case |
|-------|--------|----------|
| full | All 5 phases | Complete feature development |
| feature | Skip preplan | Known requirements |
| tech-change | techplan + sprintplan only | Technical debt/refactoring |
| hotfix | techplan only | Emergency fixes |
| spike | preplan only | Research/POC |

### 7. Constitution Hierarchy

| v1 Levels | v2 Levels |
|-----------|-----------|
| domain | org (new) |
| service | domain |
| microservice | service |
| feature | repo |

---

## Migration Steps

### For Existing Initiatives

#### Option 1: Automated Migration (Recommended)

```bash
# Run the migration command
@tracey migrate-lifecycle

# This will:
# 1. Update initiative config to v2 format
# 2. Translate phase names
# 3. Update branch references
# 4. Preserve phase progress
```

#### Option 2: Manual Migration

1. **Update Initiative Config** (`_bmad-output/lens-work/initiatives/{id}.yaml`):

```yaml
# Add v2 fields
lifecycle_version: 2
track: full  # or appropriate track
initiative_root: "your-initiative-name"  # was: featureBranchRoot

# Add named phase status
phase_status:
  preplan: passed      # if p1 was complete
  businessplan: passed # if p2 was complete
  techplan: passed     # if p3 was complete
  devproposal: null    # if p4 not started
  sprintplan: null     # if p5 not started

# Remove legacy fields
# DELETE: featureBranchRoot
# DELETE: review_audience_map
# DELETE: gate_status
```

2. **Update State File** (`_bmad-output/lens-work/state.yaml`):

```yaml
lifecycle_version: 2
current_phase: techplan  # was: current_phase: p3
active_track: full

# Update phase_status (same as above)
```

3. **Recreate Branches** (Optional):

```bash
# To update branch names to v2 format
@casey recreate-branches

# This creates new branches with v2 naming
# Old: feature-small-p1
# New: initiative-small-preplan
```

---

## Common Migration Scenarios

### Scenario 1: Mid-Phase Initiative

**Situation:** You're in the middle of v1 `p3` (tech-plan)

**Migration:**
1. Complete current phase work
2. Merge the v1 `p3` PR
3. Run `@tracey migrate-lifecycle`
4. Continue with `/devproposal` (was v1 `p4`)

### Scenario 2: Between Phases

**Situation:** Just finished v1 `p2`, about to start v1 `p3`

**Migration:**
1. Run `@tracey migrate-lifecycle` immediately
2. Use `/techplan` to start next phase
3. New branch: `{root}-small-techplan`

### Scenario 3: Multi-Repo Initiative

**Situation:** Initiative spans multiple repos

**Migration:**
1. Migrate initiative config once (it's shared)
2. Each repo will use new branch names going forward
3. Old branches can coexist during transition

---

## Breaking Changes

### Removed Features

1. **No backward compatibility** - v2.0.0 requires migration
2. **No `lifecycle-adapter.md`** - Translation layer removed
3. **No legacy branch patterns** - Must use named phases
4. **No p{N} references** - All commands use phase names

### Required Changes

1. **All new initiatives** must use `lifecycle_version: 2`
2. **Branch names** must follow v2 patterns
3. **Commands** should use v2 names (aliases work but deprecated)
4. **Constitutions** use 4-level hierarchy

---

## Troubleshooting

### Issue: "Legacy state detected"

**Solution:** Run `@tracey migrate-lifecycle`

### Issue: Branch name validation fails

**Solution:** Ensure branches follow pattern: `{initiative_root}-{audience}-{phase_name}`

### Issue: Phase not found

**Solution:** Check your track - not all tracks have all phases

### Issue: Promotion blocked

**Solution:** Ensure all phases in current audience are complete before promoting

---

## Quick Reference Card

```yaml
# v2 Lifecycle at a Glance

Phases: preplan → businessplan → techplan → devproposal → sprintplan → dev

Audiences: small → [promote] → medium → [promote] → large → [promote] → base

Tracks:
  full: all phases
  feature: skip preplan
  tech-change: techplan + sprintplan
  hotfix: techplan only
  spike: preplan only

Commands:
  /preplan      # Discovery (was /pre-plan)
  /businessplan # Requirements (was /spec)
  /techplan     # Architecture (was /tech-plan)
  /devproposal  # Epics/Stories (was /plan + /story-gen)
  /sprintplan   # Sprint planning (was /review)
  /promote      # Audience promotion gates
  /dev          # Implementation

Branch: {initiative_root}-{audience}-{phase_name}
Example: myfeature-small-techplan
```

---

## Need Help?

- Run `@tracey status` to see current state
- Run `@compass help` for v2 command reference
- Check `lifecycle.yaml` for authoritative phase definitions

---

_Migration guide for LENS Workbench v2.0.0 - Lifecycle Contract_
_Last updated: 2026-02-24_