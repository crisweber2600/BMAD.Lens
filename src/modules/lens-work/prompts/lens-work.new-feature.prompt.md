```prompt
---
description: Create new feature-level initiative with full branch topology
---

Activate Compass agent and execute /new-feature:

1. Load agent: `_bmad/lens-work/agents/compass.agent.yaml`
2. Execute `/new-feature` command to create feature initiative
3. The argument IS the feature name (e.g., `/new-feature Rate Limiting` → feature = "Rate Limiting")
4. Router dispatches to `workflows/router/init-initiative/` workflow

**Context inheritance — feature inherits from active parent (service OR domain):**
- Load `_bmad-output/lens-work/state.yaml` → `active_initiative`
- If `active_initiative` is set → check for `Service.yaml` first, then `Domain.yaml`
- If `active_initiative` is null or doesn't point to a valid parent → **auto-discover:**
  - Scan `initiatives/*/*/Service.yaml` and `initiatives/*/Domain.yaml`
  - If exactly 1 parent found → auto-select and update `state.yaml`
  - If multiple parents found → prompt user to choose (shows [service] and [domain] options)
  - If zero parents found → error: "Create a domain (/new-domain) or service (/new-service) first"
- Inherit: `domain`, `domain_prefix`, `target_repos`, `question_mode`
- If parent is service: also inherit `service`, `service_prefix`
- If parent is domain (repo-level): `service` = null

**Feature can run at two levels:**
- **Service-level:** Parent is a service → inherits service context + domain context
- **Repo-level:** Parent is a domain → inherits domain context only, no service

**Minimal user input required:**
- Feature name (the command argument)
- Confirm target repos (default: inherit all from parent)
- That's it — everything else is derived

**Creates:**
- Initiative ID: `{sanitized_name}-{random_6char}` (always random suffix)
- Branch topology (full 5 branches):
  - `{domain_prefix}/{id}/base`
  - `{domain_prefix}/{id}-small` (review audience: small)
  - `{domain_prefix}/{id}-medium` (review audience: medium)
  - `{domain_prefix}/{id}-large` (review audience: large)
  - `{domain_prefix}/{id}-small-p1` (phase 1, first working branch)
- Two-file state:
  - `_bmad-output/lens-work/state.yaml` (active initiative = initiative_id)
  - `_bmad-output/lens-work/initiatives/{initiative_id}.yaml` (initiative config with parent lineage)

**Feature-layer identity:**
- `initiative_id` = `{sanitized_name}-{random_6char}` (always generated)
- Initiative config records `domain`, `domain_prefix`, `service`, `service_prefix` from parent
- `service` is null for repo-level features (domain parent)

**In-Scope Repos:** Inherited from parent (service or domain)

**Review audience progression:**
- p1 (Analysis) → small | p2 (Planning) → medium | p3/p4 (Solutioning/Implementation) → large

Use `#think` before defining feature scope or dependencies.

```
