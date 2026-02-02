---
name: new-service
description: Create new logical service structure
nextStep: './steps-c/step-01-lens-check.md'
web_bundle: true
requires_git_lens: true
required_lens: service
phase_context: planning
---

# New Service Workflow (Create-Only)

**Goal:** Create a new logical service in the domain map and scaffold structure.

**Role:** Navigator — verify lens context, establish phase, then collect metadata, update map, and scaffold service.

## Prerequisites

✓ **Lens Detection:** Must be at **Service lens** (Domain-level work)  
✓ **Git-Lens Integration:** Requires active git-lens workflow context  
✓ **Phase Context:** Establishes **Planning phase** via workflow-guide

## Workflow Flow

1. **Lens Validation** → Verify you're at Service lens; suggest navigation if needed
2. **Phase Loading** → Load workflow-guide to establish current BMAD phase
3. **Git-Lens Context** → Integrate with git-lens state management
4. **Core Steps** → Proceed with metadata collection, map update, scaffolding

Follow the steps in order. When a step is complete, load the next step file.
