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
- Track selection (default: full — options: full, feature, tech-change, hotfix, spike)
- Confirm target repos (default: inherit all from parent)
- That's it — everything else is derived

**Creates:**
- Initiative ID: `{sanitized_name}-{random_6char}` (always random suffix)
- Initiative root (`{initiative_root}`) computed from parent context:
  - Service parent: `{domain_prefix}-{service_prefix}-{initiative_id}`
  - Service parent + multi-repo: `{domain_prefix}-{service_prefix}-{repo}-{initiative_id}`
  - Domain parent: `{domain_prefix}-{initiative_id}`
- Branch topology (audience branches per track, ALL pushed immediately):
  - `{initiative_root}` (initiative root)
  - `{initiative_root}-small` (IC creation work)
  - `{initiative_root}-medium` (lead review — if track includes medium audience)
  - `{initiative_root}-large` (stakeholder approval — if track includes large audience)
- NOTE: No phase branches at init. Phase branches (e.g., `-small-preplan`) created by phase routers.
- Two-file state:
  - `_bmad-output/lens-work/state.yaml` (active initiative = initiative_id)
  - `_bmad-output/lens-work/initiatives/{initiative_id}.yaml` (initiative config with parent lineage)

**Feature-layer identity:**
- `initiative_id` = `{sanitized_name}-{random_6char}` (always generated)
- Initiative config records `domain`, `domain_prefix`, `service`, `service_prefix` from parent
- `service` is null for repo-level features (domain parent)

**In-Scope Repos:** Inherited from parent (service or domain)

**Audience progression (per lifecycle.yaml):**
- small: preplan, businessplan, techplan
- medium: devproposal (entry gate: adversarial-review)
- large: sprintplan (entry gate: stakeholder-approval)
- base: ready for execution (entry gate: constitution-gate)

Use `#think` before defining feature scope or dependencies.

**CRITICAL — User Input Anchoring:**
If the user provided text alongside this prompt invocation, that text IS the
feature name. Use it exactly as given. Do NOT invent, substitute, or hallucinate
a different name. Example: `/new-feature Rate Limiting` → feature name = "Rate Limiting".

```
