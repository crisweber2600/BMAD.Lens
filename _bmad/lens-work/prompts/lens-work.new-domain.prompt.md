```prompt
---
description: Create new domain-level initiative with domain-only branch and folder scaffolding
---

Activate Compass agent and execute /new-domain:

1. Load agent: `_bmad/lens-work/agents/compass.agent.yaml`
2. Execute `/new-domain` command to create domain initiative
3. Router dispatches to `workflows/router/init-initiative/` workflow
4. Casey creates domain branch ONLY (no base/size/phase branches)
5. Scaffold domain folders and Domain.yaml
6. Route to `/new-service` or `/new-feature` within this domain

Use `#think` before defining domain boundaries or scope.

**Creates:**
- Initiative ID: `{sanitized_name}-{random}`
- Branch: `{domain_prefix}` (single organizational branch — no audience/phase topology)
- Domain folders:
  - `_bmad-output/lens-work/initiatives/{domain_prefix}/` (initiative configs)
  - `TargetProjects/{domain_prefix}/` (target project repos)
  - `Docs/{domain_prefix}/` (domain documentation)
- Domain.yaml: `_bmad-output/lens-work/initiatives/{domain_prefix}/Domain.yaml` (folder locations)
- State files:
  - `_bmad-output/lens-work/state.yaml` (active initiative pointer)
  - `_bmad-output/lens-work/initiatives/{domain_prefix}/{initiative_id}.yaml` (initiative config)

**In-Scope Repos:** All repos in domain (or prompt "all vs subset")

**Note:** Domain-layer does NOT create base/small/medium/large/p1 branches.
Service and feature initiatives within this domain will create their own branch topology.

```
