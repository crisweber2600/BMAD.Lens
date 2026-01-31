# LENS: Layered Enterprise Navigation System

Git-aware architectural navigation for large interconnected projects.

Automatically detects and switches between Domain, Service, Microservice, and Feature lenses.

---

## Overview

LENS is a meta-navigation module that gives BMAD a multi-layered understanding of complex systems. It detects architectural context from git state and project structure, then loads the right level of context automatically to reduce cognitive overhead.

---

## Installation

```bash
bmad install lens
```

---

## Quick Start

1. Run `navigator` to detect your current lens.
2. Use `guide` to get lens-aware workflow recommendations.
3. Use `switch lens` to change zoom levels.
4. Use `context load` to pull deeper details for the current lens.

**For detailed documentation, see [docs/](docs/).**

---

## Components

### Agents

- Navigator — Architectural context navigation and guidance

### Workflows

**Core (MVP1)**
- lens-detect
- lens-switch
- context-load

**Utility (MVP1)**
- lens-restore
- lens-configure
- workflow-guide

**Post-MVP1**
- domain-map
- impact-analysis
- new-service
- new-microservice
- new-feature
- lens-sync
- service-registry
- onboarding

---

## Configuration

This module uses only core BMAD configuration by default. Optional configuration can be created with `lens-configure`, which writes `.lens/lens-config.yaml` in the target project.

---

## Module Structure

```
lens/
├── module.yaml
├── README.md
├── TODO.md
├── docs/
│   ├── getting-started.md
│   ├── agents.md
│   ├── workflows.md
│   └── examples.md
├── prompts/
├── agents/
├── workflows/
└── _module-installer/
```

---

## Documentation

For detailed user guides and documentation, see the **[docs/](docs/)** folder:
- [Getting Started](docs/getting-started.md)
- [Agents Reference](docs/agents.md)
- [Workflows Reference](docs/workflows.md)
- [Examples](docs/examples.md)

---

## Development Status

This module is currently in development. The following components are planned:

- [ ] Agents: 1 agent
- [ ] Workflows: 14 workflows

See TODO.md for detailed status.

---

## Author

Created via BMAD Module workflow

---

## License

Part of the BMAD framework.
