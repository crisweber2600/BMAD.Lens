---
name: new-feature
description: Create feature branch and context
nextStep: './steps-c/step-01-lens-check.md'
web_bundle: true
requires_git_lens: true
required_lens: "feature|service"
phase_context: implementation
feature_scope_awareness: true
---

# New Feature Workflow (Create-Only)

**Goal:** Create a new feature branch and initialize context.

**Role:** Navigator — verify lens context, establish phase, then collect metadata and prepare branch + context.

**Scope:** Supports both single-microservice features and cross-microservice features.

## Prerequisites

✓ **Lens Detection:** Must be at **Feature lens** (single-microservice) OR **Service lens** (cross-microservice)  
✓ **Git-Lens Integration:** Requires active git-lens workflow context  
✓ **Phase Context:** Establishes **Implementation phase** via workflow-guide  
✓ **Multi-Microservice Awareness:** Detects and handles features spanning multiple microservices

## Workflow Flow

1. **Lens Validation** → Verify you're at Feature or Service lens; suggest navigation if needed
2. **Phase Loading** → Load workflow-guide to establish current BMAD phase
3. **Git-Lens Context** → Integrate with git-lens state management
4. **Scope Detection** → (If Service lens) Identify affected microservices
5. **Core Steps** → Proceed with metadata collection and branch/context initialization

Follow the steps in order. When a step is complete, load the next step file.
