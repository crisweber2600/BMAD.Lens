# LENS Workbench (lens-work)

**Guided lifecycle router with git-orchestrated discipline for BMAD workflows.**

---

## Overview

LENS Workbench transforms BMAD from a "large framework you must learn" into a **guided system people can use immediately**. It acts as the front door to BMAD by providing:

- **Phase Router Commands** — `/pre-plan`, `/spec`, `/plan`, `/review`, `/dev`
- **Automated Git Orchestration** — Branch topology mirrors BMAD phases
- **Layer-Aware Context** — Auto-detects domain/service/microservice/feature layers
- **Repo Discovery & Documentation** — Inventories and documents repos before planning
- **Lifecycle Telemetry** — Tracks phase progress with dashboard visibility

**The architectural differentiator:** Git history becomes the process tracker—branch topology mirrors BMAD phases, so you can see where you are just by looking at branches.

---

## Installation

```bash
bmad install lens-work
```

### Configuration

During installation, you'll be prompted for:

| Setting | Description | Default |
|---------|-------------|---------|
| `target_projects_path` | Path to TargetProjects folder | `../TargetProjects` |
| `docs_output_path` | Path for canonical docs | `Docs` |
| `enable_telemetry` | Enable dashboards | `true` |
| `default_git_remote` | Git remote type | `github` |

---

## Components

### Agents

| Agent | Role | Description |
|-------|------|-------------|
| **Compass** | Router | Phase-aware lifecycle navigation and layer detection |
| **Casey** | Conductor | Git branch orchestration (auto-triggered only) |
| **Tracey** | Diagnostics | State management and recovery |
| **Scout** | Pathfinder | Repo discovery, documentation, and bootstrap |

### Discovery (Deep)

The lens-work module now embeds the LENS discovery stack:

- **discover** (preflight → select target → extract context → analyze-codebase → generate-docs → deep-scan handoff)
- **analyze-codebase** (static analysis: stack, API surface, data models, integrations, architecture patterns, security signals)
- **generate-docs** (writes architecture/api/data-model/integration/onboarding docs to `{docs_output_path}/{domain}/{service}/`)
- **lens-sync** (discovers structure, compares to `.lens/domain-map.yaml`, applies approved updates)

Config knobs (set at install):
- `discovery_depth` (`shallow|standard|deep`)
- `enable_jira_integration` (bool)
- `lens_data_folder`, `metadata_output_folder`, `docs_output_path`

### Phase Router Commands

| Command | Phase | Owner |
|---------|-------|-------|
| `/pre-plan` | Analysis | PO/Architect/Tech Lead |
| `/spec` | Planning | PO/Architect/Tech Lead |
| `/plan` | Solutioning | PO/Architect/Tech Lead |
| `/review` | Readiness | Scrum Master |
| `/dev` | Implementation | Developer |

### Initiative Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `#new-domain` | Start domain initiative | `#new-domain "payment-platform"` |
| `#new-service` | Start service initiative | `#new-service "api-gateway"` |
| `#new-feature` | Start feature initiative | `#new-feature "rate-limiting"` |
| `#fix-story` | Correction loop | `#fix-story rate-limit-x7k2m9` |

---

## Operating Rules

### Control-Plane Rule

**All lens-work commands execute from the BMAD directory (control repo).**

- Users never `cd` into TargetProjects repos
- Repo operations run against TargetProjects paths programmatically
- Planning artifacts remain in the BMAD control repo

### Role Gating

| Phase | Authorized Roles |
|-------|------------------|
| `#new-*` through `/plan` | PO, Architect, Tech Lead |
| `/review` | Scrum Master (gate owner) |
| `/dev` | Developer (post-review only) |

---

## Quick Start

### 1. Onboarding (First Time)

```
@lens-work onboard
```

Scout creates your profile and bootstraps TargetProjects.

### 2. Start New Feature

```
#new-feature "rate-limiting"
```

Compass detects layer, Casey creates branches, you're guided through `/pre-plan`.

### 3. Continue Through Phases

```
/spec    # Planning phase
/plan    # Solutioning phase
/review  # Readiness gate (SM approval)
/dev     # Implementation
```

### 4. Check Status

```
@tracey ST
```

---

## Module Structure

```
lens-work/
├── module.yaml              # Module configuration
├── README.md                # This file
├── agents/
│   ├── compass.agent.yaml   # Phase router
│   ├── casey.agent.yaml     # Git conductor
│   ├── tracey.agent.yaml    # State manager
│   └── scout.agent.yaml     # Bootstrap specialist
├── workflows/
│   ├── core/                # Auto-triggered operations
│   ├── router/              # Phase commands
│   ├── discovery/           # Repo discovery
│   └── utility/             # Manual workflows
└── _module-installer/
    └── installer.js
```

---

## Outputs

### State & Logs

- `_bmad-output/lens-work/state.yaml` — Current initiative state
- `_bmad-output/lens-work/event-log.jsonl` — Operation log
- `_bmad-output/lens-work/repo-inventory.yaml` — Discovered repos

### Canonical Docs

```
Docs/{domain}/{service}/{repo}/
├── project-context.md
└── current-state.tech-spec.md
```

---

## Dependencies

**Required:**
- BMM (workflow execution)
- BMAD Core (infrastructure)

**Optional:**
- CIS (brainstorming/research)
- TEA (test planning)

---

## Author

Created via BMAD Module workflow on 2026-02-03.

---

_lens-work — Guided lifecycle orchestration for BMAD_
