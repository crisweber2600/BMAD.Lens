```prompt
---
description: Activate Compass agent for phase-aware lifecycle navigation
---

Load and activate the Compass agent:

1. Load agent: `_bmad/lens-work/agents/compass.agent.yaml`
2. Load module config: `_bmad/lens-work/module.yaml`
3. Follow activation steps in the agent file
4. Display Compass menu with all available commands

If the user requests a multi-step plan, create and maintain a task list with `manage_todo_list`.

**Available Commands:**
- `/preplan` — PrePlan phase (brainstorm/research/product brief)
- `/businessplan` — BusinessPlan phase (PRD/UX Design)
- `/techplan` — TechPlan phase (architecture/technical design)
- `/devproposal` — DevProposal phase (epics/stories/readiness)
- `/sprintplan` — SprintPlan phase (sprint planning/dev handoff)
- `/promote` — Audience promotion (small→medium→large→base gates)
- `/dev` — Implementation loop
- `/new-domain`, `/new-service`, `/new-feature` — Create initiatives
- `?` — Status check

```
