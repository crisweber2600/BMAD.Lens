---
repo: BMAD.Lens
remote: https://github.com/crisweber2600/BMAD.Lens.git
default_branch: main
generated_at: 2026-02-10T15:30:00Z
layer: control-repo
domain: BMAD
service: LENS
generator: onboarding
---

# BMAD.Lens Control Repository

**BMAD LENS Workbench** - AI-powered development lifecycle management

## Overview

This is the BMAD control repository that manages itself via the lens-work module. The lens-work module provides AI-powered lifecycle management for multi-repo initiatives.

## Documentation

Comprehensive documentation is available in the repository:

- **[INDEX.md](../../../../INDEX.md)** - Complete documentation index
- **[EXECUTIVE-SUMMARY.md](../../../../EXECUTIVE-SUMMARY.md)** - High-level overview
- **[QUICK-REFERENCE.md](../../../../QUICK-REFERENCE.md)** - Command reference
- **[Copilot Instructions](../../../../src/modules/lens-work/docs/copilot-instructions.md)** - Using Copilot with LENS

## Module Documentation

- **[lens-work README](../../../../src/modules/lens-work/README.md)** - Module overview
- **[API Reference](../../../../src/modules/lens-work/docs/api-reference.md)** - Complete API documentation
- **[Workflows](../../../../src/modules/lens-work/workflows/)** - Workflow specifications

## Getting Started

Run `@scout H` to see all available Scout commands for discovery and documentation.

## Deep Documentation

To generate comprehensive architectural documentation, run:
```
@scout document
```

This will invoke the full documentation pipeline (document-project + quick-spec).
