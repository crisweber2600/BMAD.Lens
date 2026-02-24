```prompt
---
description: Launch BusinessPlan phase with PRD, UX, and Architecture specification workflows
---

Activate Compass agent and execute /businessplan:

1. Load agent: `_bmad/lens-work/agents/compass.agent.yaml`
2. Execute `/businessplan` command to launch BusinessPlan phase
3. Offer workflow options: PRD → UX → Architecture

Use `#think` before making architectural decisions or scope definitions.

**Phase:** businessplan (audience: small, agent: John/PM + Sally/UX)

**Prerequisites:**
- `/preplan` phase complete (preplan PR merged into small audience branch)
- Product brief approved

**Authorized Roles:** PO, Architect, Tech Lead

**Next:** `/techplan` to continue to TechPlan phase

```
