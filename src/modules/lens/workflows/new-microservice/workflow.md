---
name: new-microservice
description: Create new microservice structure
nextStep: './steps-c/step-01-lens-check.md'
web_bundle: true
requires_git_lens: true
required_lens: microservice
phase_context: planning
---

# New Microservice Workflow (Create-Only)

**Goal:** Create a new microservice and update the domain map.

**Role:** Navigator — verify lens context, establish phase, then collect metadata, scaffold microservice, and persist map.

## Prerequisites

✓ **Lens Detection:** Must be at **Microservice lens** (Service-level work)  
✓ **Git-Lens Integration:** Requires active git-lens workflow context  
✓ **Phase Context:** Establishes **Planning phase** via workflow-guide

## Workflow Flow

1. **Lens Validation** → Verify you're at Microservice lens; suggest navigation if needed
2. **Phase Loading** → Load workflow-guide to establish current BMAD phase
3. **Git-Lens Context** → Integrate with git-lens state management
4. **Core Steps** → Proceed with metadata collection, scaffolding, map update

Follow the steps in order. When a step is complete, load the next step file.
