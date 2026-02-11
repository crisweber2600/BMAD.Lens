```prompt
---
description: Create new service-level initiative with service-only branch and folder scaffolding
---

Activate Compass agent and execute /new-service:

1. Load agent: `_bmad/lens-work/agents/compass.agent.yaml`
2. Execute `/new-service` command to create service initiative
3. Router dispatches to `workflows/router/init-initiative/` workflow
4. Casey creates service branch ONLY (no base/size/phase branches)
5. Scaffold service folders and Service.yaml
6. Route to `/new-feature` within this service

Use `#think` before defining service boundaries or naming.

**Creates:**
- Branch: `{domain_prefix}/{service_prefix}` (single organizational branch — no audience/phase topology)
- Service folders (nested under domain):
  - `_bmad-output/lens-work/initiatives/{domain_prefix}/{service_prefix}/` (initiative configs)
  - `TargetProjects/{domain_prefix}/{service_prefix}/` (target project repos)
  - `Docs/{domain_prefix}/{service_prefix}/` (service documentation)
- Service.yaml: `_bmad-output/lens-work/initiatives/{domain_prefix}/{service_prefix}/Service.yaml`
  - Serves as BOTH service descriptor AND initiative config (single source of truth)
  - Contains: folder locations, target_repos, docs, gates, blocks
- State file: `_bmad-output/lens-work/state.yaml` (active initiative = {domain_prefix}/{service_prefix})

**Service-layer identity:**
- `initiative_id` = `{domain_prefix}/{service_prefix}` (no random suffix generated)
- No separate `{initiative_id}.yaml` file — Service.yaml IS the initiative config

**In-Scope Repos:** All repos in service

**Note:** Service-layer does NOT create base/small/medium/large/p1 branches.
Feature initiatives within this service will create their own branch topology.

```
