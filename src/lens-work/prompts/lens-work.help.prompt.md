```prompt
---
description: Display command menu with current context and suggested next step
---

Activate Compass agent and execute /help:

1. Load agent: `_bmad/lens-work/agents/compass.agent.yaml`
2. Execute help command
3. Display available commands grouped by category:

**Phase Commands (lifecycle v2 — named phases):**
- `/preplan` (alias: `/pre-plan`) — PrePlan: brainstorm/research/product brief (Mary/Analyst, small)
- `/businessplan` (alias: `/spec`) — BusinessPlan: PRD/UX Design (John/PM + Sally/UX, small)
- `/techplan` (alias: `/tech-plan`) — TechPlan: architecture/technical design (Winston/Architect, small)
- `/devproposal` (alias: `/plan`) — DevProposal: epics/stories/readiness (John/PM, medium)
- `/sprintplan` (alias: `/review`) — SprintPlan: sprint planning/dev handoff (Bob/SM, large)
- `/dev` — Implementation loop (dev-story/code-review/retro)

**Audience Promotion:**
- `/promote` — Audience promotion gates (small→medium→large→base)

**Initiative Commands:**
- `/new-domain` — Create domain-level initiative
- `/new-service` — Create service-level initiative
- `/new-feature` — Create feature-level initiative

**Context Commands:**
- `/switch` — Switch active initiative, lens, phase, or size
- `/context` — Display current context
- `/lens` — Show/change lens focus (org/domain/service/repo)
- `?` or `/status` — Quick status check

**Recovery Commands:**
- `/sync` — Sync state with git reality
- `/fix` — Fix state inconsistencies
- `/override` — Override state fields (requires reason)
- `/resume` — Resume interrupted workflow

**Governance:**
- `/constitution` — View/edit constitutions (4-level: org/domain/service/repo)
- `/compliance` — Check artifact compliance (includes track/gate validation)
- `/ancestry` — View constitution inheritance chain
- `/resolve` — Resolve effective constitution

**Discovery:**
- `/onboard` — Full onboarding (profile + credentials + repo setup)
- `/discover` — Run repo discovery
- `/domain-map` — View domain architecture map

4. Show current context summary (active initiative, phase, track, audience, branch)
5. Suggest next step based on current state
```
