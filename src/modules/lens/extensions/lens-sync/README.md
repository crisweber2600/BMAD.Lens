# LENS Sync & Discovery (Extension)

Sync architectural knowledge with physical reality through automated brownfield discovery and bi-directional lens synchronization.

---

## Overview

LENS Sync & Discovery bridges the gap between architectural intent and the real codebase. It bootstraps legacy microservices into BMAD-ready projects, generates documentation from code analysis, and keeps lens metadata synchronized as systems evolve.

---

## Installation

Install the base LENS module, then enable the extension:

```bash
bmad install lens
```

For local development or manual install, you can also run:

```bash
node src/modules/lens/extensions/lens-sync/_module-installer/installer.js
```

---

## Quick Start

1. Run `Bridge, bootstrap` to align folder structure with the lens domain map.
2. Run `Scout, discover` to generate BMAD-ready documentation.
3. Run `Link, update-lens` to propagate documentation changes.

**For detailed documentation, see [docs/](docs/).**

---

## Components

### Agents

- Bridge — The Synchronizer
- Scout — Discovery Specialist
- Link — Lens Guardian

### Workflows

- bootstrap
- sync-status
- reconcile
- discover
- analyze-codebase
- generate-docs
- update-lens
- validate-schema
- rollback

---

## Configuration

The module supports these configuration options (set during installation):

- `target_project_root` — Target project root to scan and sync.
- `enable_jira_integration` — Enable JIRA context discovery.
- `discovery_depth` — Depth of analysis (shallow/standard/deep).
- `docs_output_folder` — Output folder for generated documentation.

---

## Module Structure

```
src/modules/lens/extensions/lens-sync/
├─ module.yaml
├─ README.md
├─ TODO.md
├─ docs/
│  ├─ getting-started.md
│  ├─ agents.md
│  ├─ workflows.md
│  └─ examples.md
├─ agents/
├─ workflows/
└─ _module-installer/
```

---

## Documentation

For detailed user guides and documentation, see the docs/ folder:

- Getting Started
- Agents Reference
- Workflows Reference
- Examples
- Prerequisites & Environment Setup
- Scope & MVP Plan
- Architecture & Integration
- Testing & QA Plan
- Release & Operations
- Spec-to-Docs Traceability

---

## Development Status

Core agents and workflows are implemented. Remaining work is primarily testing, operational validation, and governance reviews.

- [x] Agents: 3 agents
- [x] Workflows: 9 workflows

See TODO.md for detailed status.

---

## Author

Created via BMAD Module workflow

---

## License

Part of the BMAD framework.
