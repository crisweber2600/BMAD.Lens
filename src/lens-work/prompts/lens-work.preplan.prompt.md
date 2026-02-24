```prompt
---
description: Launch PrePlan phase with brainstorming, research, and product brief workflows
---

Activate Compass agent and execute /preplan:

1. Load agent: `_bmad/lens-work/agents/compass.agent.yaml`
2. Execute `/preplan` command to launch PrePlan phase
3. At phase start: create and push `{initiative_root}-small-preplan` from `{initiative_root}-small`
4. Offer workflow options: Brainstorming → Research → Product Brief
5. At phase end: create PR from `{initiative_root}-small-preplan` into `{initiative_root}-small`

Use `#think` before selecting workflows or defining the problem scope.

**Branch lifecycle:**
- START: `{initiative_root}-small-preplan` branch created from `-small` and pushed immediately
- WORK: All preplan workflow branches created from `-small-preplan` (e.g., `-small-preplan-brainstorm`)
- END: PR from `-small-preplan` → `-small`, phase enters pr_pending

**Phase:** preplan (audience: small, agent: Mary/Analyst)

**Prerequisites:**
- Initiative created via `/new-*` command
- Layer detected with confidence >= 75%

**Authorized Roles:** PO, Architect, Tech Lead

```
