```prompt
---
description: Launch DevProposal phase with Epics, Stories, and Readiness checklists
---

Activate Compass agent and execute /devproposal:

1. Load agent: `_bmad/lens-work/agents/compass.agent.yaml`
2. Execute `/devproposal` command to launch DevProposal phase
3. Offer workflow options: Epics → Stories → Readiness Checklist

Use `#think` before story breakdown or acceptance criteria definition.

**Phase:** devproposal (audience: medium, agent: John/PM)

**Prerequisites:**
- Small → Medium audience promotion complete (adversarial review gate passed)
- `/techplan` complete (all small-audience phases merged)
- Architecture approved

**Authorized Roles:** PO, Architect, Tech Lead

**Next:** Run `/promote` (medium → large), then `/sprintplan`

```
