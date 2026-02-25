```prompt
---
description: Migrate initiatives from legacy p1-p6 phases to v2 named phases (lifecycle contract v2)
---

Activate Tracey agent and execute lifecycle migration:

1. Load agent: `_bmad/lens-work/agents/tracey.agent.yaml`
2. Execute workflow: `_bmad/lens-work/workflows/utility/migrate-lifecycle/workflow.md`
3. Follow the three migration stages:

**Stage 1 — Config Migration (Required):**
- Transform state.yaml and initiative configs from lifecycle_version 1 to 2
- Map numbered phases: p1→preplan, p2→businessplan, p3→techplan, p4→devproposal, p5→sprintplan, p6→dev
- Update schema fields to v2 format

**Stage 2 — Branch Rename (Optional):**
- Rename `p{N}` branches to named phase branches
- Example: `init-svc-foo-small-p1` → `init-svc-foo-small-preplan`

**Stage 3 — PR Retarget (Optional):**
- Update open PRs to reference renamed branches

> Run `/status` first to see current initiative state before migrating.
```
