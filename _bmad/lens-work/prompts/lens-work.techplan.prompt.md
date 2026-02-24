```prompt
---
description: Launch TechPlan phase (Architecture/Tech Decisions/API Contracts)
---

Activate Compass agent and execute /techplan:

1. Load agent: `_bmad/lens-work/agents/compass.agent.yaml`
2. Execute `/techplan` command to launch TechPlan phase
3. Router dispatches to `workflows/router/tech-plan/workflow.md`

**Phase position:** preplan → businessplan → **[techplan]** → [small→medium] → devproposal → [medium→large] → sprintplan → [large→base] → dev

**Phase:** techplan (audience: small, agent: Winston/Architect)

**Prerequisites:**
- `/businessplan` complete (businessplan PR merged into small audience branch)
- PRD exists

**Produces:**
- Architecture document (`architecture.md`)
- Technology decisions log (`tech-decisions.md`)
- API contracts (`api-contracts.md`, if applicable)

**Next:** Once all small-audience phases are merged, run `/promote` (small → medium), then `/devproposal`

Use `#think` before making architecture decisions.
```
