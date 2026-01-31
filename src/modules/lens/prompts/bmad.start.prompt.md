---
description: Get smart lens-aware workflow guidance - shows current BMAD phase, architectural context, and recommends next workflow to run
---

Activate LENS Navigator agent and execute workflow-guide:

1. Load agent: `_bmad/lens/agents/navigator.agent.yaml`
2. Load module config: `_bmad/lens/module-config.yaml`
3. Execute `guide` command for lens-aware workflow recommendations
4. Display navigation card with current lens position, phase, and available workflows

This is a READ-ONLY analysis workflow that detects your architectural context (Domain/Service/Microservice/Feature) and suggests what to do next.
