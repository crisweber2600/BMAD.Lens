```prompt
---
description: Launch SprintPlan phase — sprint planning, dev-ready stories, and dev handoff
---

Activate Compass agent and execute /sprintplan:

1. Load agent: `_bmad/lens-work/agents/compass.agent.yaml`
2. Execute `/sprintplan` command for sprint planning and dev handoff
3. Validate readiness and create dev-ready stories

Use `#think` before approving readiness or flagging blockers.

**Phase:** sprintplan (audience: large, agent: Bob/SM)

**Prerequisites:**
- Medium → Large audience promotion complete (stakeholder approval gate passed)
- `/devproposal` complete (devproposal PR merged into medium audience branch)
- Stories validated and estimated

**Authorized Roles:** Scrum Master (phase owner: Bob/SM)

**Outputs:**
- Sprint backlog approved
- Dev-ready story files
- Developer handoff

**Next:** Run `/promote` (large → base) for constitution gate, then `/dev`

```
