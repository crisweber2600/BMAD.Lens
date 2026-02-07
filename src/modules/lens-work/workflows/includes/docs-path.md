---
name: docs-path
description: Canonical documentation paths, naming conventions, and version control rules for lens-work artifacts
type: include
---

# Documentation Paths Reference

This document defines the canonical directory structure, file naming conventions, and version control rules for all artifacts produced by lens-work workflows.

---

## Directory Structure

```
{project-root}/
├── _bmad-output/
│   ├── lens-work/
│   │   ├── state.yaml                          # Active initiative state
│   │   ├── event-log.jsonl                      # Lifecycle event log
│   │   ├── repo-inventory.yaml                  # Discovered repo metadata
│   │   ├── bootstrap-report.md                  # Bootstrap output
│   │   ├── initiatives/                         # Per-initiative state (future)
│   │   │   └── {initiative_id}.yaml
│   │   └── docs/                                # Canonical generated docs
│   │       └── {repo_name}/
│   │           ├── api-reference.md
│   │           ├── architecture-overview.md
│   │           └── component-map.md
│   ├── planning-artifacts/                      # Planning phase outputs
│   │   └── {initiative_id}/
│   │       ├── p1-product-brief.md
│   │       ├── p1-research-notes.md
│   │       ├── p1-brainstorm-notes.md
│   │       ├── p2-prd.md
│   │       ├── p2-ux-design.md
│   │       ├── p2-architecture.md
│   │       ├── p3-epics.md
│   │       ├── p3-readiness-checklist.md
│   │       ├── p3-stories/
│   │       │   ├── story-001.md
│   │       │   ├── story-002.md
│   │       │   └── ...
│   │       ├── stories.csv
│   │       └── epics.csv
│   └── implementation-artifacts/                # Implementation phase outputs
│       └── {initiative_id}/
│           ├── p4-sprint-plan.md
│           ├── p4-dev-stories/
│           │   ├── dev-story-001.md
│           │   ├── dev-story-002.md
│           │   └── ...
│           ├── p4-review-notes.md
│           └── p4-retro.md
├── docs/
│   ├── discovery/                               # Discovery scan outputs
│   │   ├── initial-discovery-report.md
│   │   ├── deep-scan-{repo_name}.md
│   │   └── deep-scan-summary.md
│   ├── {domain}/                                 # Batch-mode phase docs
│   │   └── {service}/
│   │       └── {repo}/
│   │           └── {initiative_id}/
│   │               ├── phase-1-analysis-questions.md
│   │               ├── phase-1-review.md
│   │               ├── phase-2-planning-questions.md
│   │               ├── phase-2-review.md
│   │               ├── phase-3-solutioning-questions.md
│   │               ├── phase-3-review.md
│   │               ├── phase-4-implementation-questions.md
│   │               └── phase-4-review.md
│   └── lens-sync/                               # Synced repo documentation
│       └── {repo_name}/
│           └── ...
```

---

## Path Patterns

### Planning Artifacts

```
_bmad-output/planning-artifacts/{initiative_id}/
```

All planning artifacts (P1–P3) are stored here. Files are prefixed with the phase number.

| Phase | File | Path |
|-------|------|------|
| P1 | Product Brief | `_bmad-output/planning-artifacts/{id}/p1-product-brief.md` |
| P1 | Research Notes | `_bmad-output/planning-artifacts/{id}/p1-research-notes.md` |
| P1 | Brainstorm Notes | `_bmad-output/planning-artifacts/{id}/p1-brainstorm-notes.md` |
| P2 | PRD | `_bmad-output/planning-artifacts/{id}/p2-prd.md` |
| P2 | UX Design | `_bmad-output/planning-artifacts/{id}/p2-ux-design.md` |
| P2 | Architecture | `_bmad-output/planning-artifacts/{id}/p2-architecture.md` |
| P3 | Epics | `_bmad-output/planning-artifacts/{id}/p3-epics.md` |
| P3 | Stories (dir) | `_bmad-output/planning-artifacts/{id}/p3-stories/` |
| P3 | Readiness Checklist | `_bmad-output/planning-artifacts/{id}/p3-readiness-checklist.md` |
| P3 | Stories CSV | `_bmad-output/planning-artifacts/{id}/stories.csv` |
| P3 | Epics CSV | `_bmad-output/planning-artifacts/{id}/epics.csv` |

### Implementation Artifacts

```
_bmad-output/implementation-artifacts/{initiative_id}/
```

All implementation artifacts (P4) are stored here.

| Phase | File | Path |
|-------|------|------|
| P4 | Sprint Plan | `_bmad-output/implementation-artifacts/{id}/p4-sprint-plan.md` |
| P4 | Dev Stories (dir) | `_bmad-output/implementation-artifacts/{id}/p4-dev-stories/` |
| P4 | Review Notes | `_bmad-output/implementation-artifacts/{id}/p4-review-notes.md` |
| P4 | Retrospective | `_bmad-output/implementation-artifacts/{id}/p4-retro.md` |

### Canonical Docs

```
_bmad-output/lens-work/docs/{repo_name}/
```

Generated documentation for discovered repos. Produced by `repo-document` workflow.

### Discovery Docs

```
docs/discovery/
```

### Batch Question Docs

```
docs/{domain}/{service}/{repo}/{initiative_id}/
```

Batch question files and party-mode review outputs live here. The resolved path is stored in `initiatives/{id}.yaml` as `docs.path`.

Output from `repo-discover` and deep-scan workflows. Committed to main branch.

### Lens Sync

```
docs/lens-sync/{repo_name}/
```

Synced documentation from target repos via `sync` workflow.

---

## Naming Conventions

### File Names

- **Format:** `kebab-case` with phase prefix
- **Pattern:** `p{N}-{artifact-name}.md`
- **Examples:**
  - `p1-product-brief.md`
  - `p2-architecture.md`
  - `p3-readiness-checklist.md`
  - `p4-retro.md`

### Directory Names

- **Format:** `kebab-case` with phase prefix
- **Pattern:** `p{N}-{collection-name}/`
- **Examples:**
  - `p3-stories/`
  - `p4-dev-stories/`

### Story Files

- **Individual stories:** `story-{NNN}.md` (zero-padded 3 digits)
- **Dev stories:** `dev-story-{NNN}.md`
- **CSV tracking:** `stories.csv`, `epics.csv` (no phase prefix)

### Initiative ID in Paths

- Initiative IDs appear in directory names, not file names
- Pattern: `{sanitized_name}-{6char_hex}`
- Example: `rate-limit-x7k2m9`

---

## Version Control Rules

### Artifact Commit Rules

| File Type | Committed To | When |
|-----------|-------------|------|
| Planning artifacts | Initiative phase branch | During workflow execution |
| Implementation artifacts | Initiative phase branch | During workflow execution |
| `state.yaml` | Active branch | Every workflow start/finish |
| `event-log.jsonl` | Active branch | Every event |
| Discovery docs | `main` branch | After discovery workflow |
| Canonical docs | `main` branch | After repo-document workflow |
| Lens sync docs | `main` branch | After sync workflow |
| Batch question docs | Phase branch | During batch-mode processing |

### Git Add Patterns

```bash
# Planning artifacts for current initiative
git add "_bmad-output/planning-artifacts/${initiative_id}/"

# Implementation artifacts for current initiative
git add "_bmad-output/implementation-artifacts/${initiative_id}/"

# State and event log (always)
git add "_bmad-output/lens-work/state.yaml"
git add "_bmad-output/lens-work/event-log.jsonl"

# Discovery docs (main branch only)
git add "docs/discovery/"

# Canonical docs (main branch only)
git add "_bmad-output/lens-work/docs/"

# Batch question docs (phase branch)
git add "docs/${domain}/${service}/${repo}/${initiative_id}/"
```

### Commit Message Patterns

| Context | Message Format |
|---------|----------------|
| Workflow artifact | `workflow({workflow_name}): {description} ({initiative_id})` |
| Phase start | `phase(p{N}): Start {phase_name} ({initiative_id})` |
| Phase finish | `phase(p{N}): Finish {phase_name} ({initiative_id})` |
| Discovery | `discovery: {scan_type} for {repo_name}` |
| State update | `state: Update {field} ({initiative_id})` |

---

## Path Resolution

### Token Substitution

All path patterns use these tokens:

| Token | Resolves To | Source |
|-------|------------|--------|
| `{project-root}` | Absolute path to BMAD control repo | Runtime |
| `{initiative_id}` | Current initiative ID | `state.yaml` |
| `{repo_name}` | Target repository name | `service-map.yaml` |
| `{id}` | Shorthand for `{initiative_id}` | `state.yaml` |
| `{domain}` | Initiative domain segment | `initiatives/{id}.yaml` (`docs.domain`) |
| `{service}` | Initiative service segment | `initiatives/{id}.yaml` (`docs.service`) |
| `{repo}` | Initiative repo segment | `initiatives/{id}.yaml` (`docs.repo`) |

### Example Resolution

```
Template: _bmad-output/planning-artifacts/{initiative_id}/p2-prd.md
Resolved: _bmad-output/planning-artifacts/rate-limit-x7k2m9/p2-prd.md
```

---

## Related Includes

- **artifact-validator.md** — Validates artifacts at these paths
- **jira-integration.md** — CSV files stored in planning-artifacts
- **size-topology.md** — Branch structure artifacts are committed to
