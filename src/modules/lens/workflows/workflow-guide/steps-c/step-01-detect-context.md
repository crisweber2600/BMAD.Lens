---
name: 'step-01-detect-context'
description: 'Detect lens and phase'
nextStepFile: './step-02-map-recommendations.md'
---

# Step 1: Detect Context

## Goal
Resolve the active lens and current BMAD phase.

## Instructions
- Call lens-detect if current lens is unknown.
- Infer BMAD phase from branch or directory cues if possible.

## Output
- `current_lens`
- `current_phase`
