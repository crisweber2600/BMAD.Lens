# Skill: state-management

**Module:** lens-work
**Owner:** Tracey agent (delegated via Compass)
**Type:** Internal delegation skill

---

## Purpose

Manages the two-file state system (state.yaml + event-log.jsonl). Handles all reads, writes, and validations of initiative state. Formalizes the Tracey agent's API contract.

## Responsibilities

1. **State reads** — Load current initiative state at workflow start
2. **State writes** — Update state at workflow end
3. **Dual-write sync** — When `phase_status`, `current_phase`, or `audience_status` changes, update BOTH state.yaml AND the initiative config (`initiatives/{id}.yaml` or `initiatives/{id}/Domain.yaml` etc.) to keep them in sync
4. **Event logging** — Append to event-log.jsonl on every state mutation
5. **Status display** — Format and present state for /status and /lens commands
6. **State validation** — Verify state consistency with git reality
7. **Error tracking** — Maintain background_errors array in state

## State Schema (v2 — Lifecycle Contract)

```yaml
# state.yaml — runtime state (committed)
lifecycle_version: 2
lens_contract_version: "2.0"

# Active context
active_initiative: "{initiative_id}"
current_phase: "{preplan|businessplan|techplan|devproposal|sprintplan}"
active_track: "{full|feature|tech-change|hotfix|spike}"
workflow_status: "{idle|running|error}"

# Phase status (v2: named phases, dual-written to initiative config)
phase_status:
  preplan: "{null|passed|blocked}"
  businessplan: "{null|passed|blocked}"
  techplan: "{null|passed|blocked}"
  devproposal: "{null|passed|blocked}"
  sprintplan: "{null|passed|blocked}"

# Audience promotion status (v2)
audience_status:
  small_to_medium: "{null|passed|blocked}"
  medium_to_large: "{null|passed|blocked}"
  large_to_base: "{null|passed|blocked}"

# Checklist tracking
checklist:
  current_gate: null
  items: []
  gate_ready: false
  gate_ready_pct: 0

# Error accumulator
background_errors: []

# Timestamps
created_at: "{ISO8601}"
last_activity: "{ISO8601}"

# User context
user:
  name: "{git_user_name}"
  email: "{git_user_email}"
```

## Initiative Config Schema (v2)

```yaml
# initiatives/{id}.yaml — shared initiative config (committed)
lifecycle_version: 2

id: "{initiative_id}"
name: "{initiative_name}"
layer: "{domain|service|repo}"
track: "{full|feature|tech-change|hotfix|spike}"
initiative_root: "{initiative_root}"

# Track-derived fields
active_phases: [preplan, businessplan, ...]  # From lifecycle.yaml tracks[track].phases
audiences: [small, medium, large, base]      # From lifecycle.yaml tracks[track].audiences

# Phase status (dual-written from state.yaml)
phase_status:
  preplan: "{null|passed|blocked}"
  businessplan: "{null|passed|blocked}"
  techplan: "{null|passed|blocked}"
  devproposal: "{null|passed|blocked}"
  sprintplan: "{null|passed|blocked}"

current_phase: "{named_phase}"
```

## Event Log Schema (event-log.jsonl)

```jsonl
{"ts":"ISO8601","event":"event_type","initiative":"id","user":"name","details":{}}
```

## Event Types

| Event | When |
|-------|------|
| `initiative_created` | /new-* completes |
| `phase_transition` | Phase advances (v2: named phase) |
| `audience_promotion` | Audience promotion gate passes (v2) |
| `workflow_start` | Any workflow begins |
| `workflow_end` | Any workflow completes |
| `gate_opened` | Phase gate passes |
| `gate_blocked` | Phase gate fails |
| `state_synced` | /sync runs |
| `state_fixed` | /fix runs |
| `state_overridden` | /override runs |
| `error` | Any error occurs |
| `initiative_archived` | /archive runs |
| `constitution_violation` | Governance check fails |
| `constitution_passed` | Governance check passes |
| `migrate_lifecycle` | v1→v2 lifecycle migration completes |

## Dual-Write Contract

When `phase_status`, `current_phase`, or `audience_status` changes in state.yaml:
1. Write to `_bmad-output/lens-work/state.yaml`
2. Also write to the initiative config file:
   - Domain: `initiatives/{id}/Domain.yaml`
   - Service: `initiatives/{id}/Service.yaml`
   - Feature/Repo: `initiatives/{id}.yaml`
3. When switching initiatives (`/switch`), load phase_status from the initiative config into state.yaml

## Lifecycle Version Detection

```yaml
# Determine which schema to use:
# v2.0.0: All initiatives must have lifecycle_version: 2
# Use named phases, tracks, audience promotions
current_phase = state.current_phase    # "preplan", "businessplan", etc.
audience = lifecycle.phases[current_phase].audience
```

## Trigger Conditions

- Every workflow start (read state)
- Every workflow end (write state + append event)
- /status command (read + format)
- /sync command (validate + repair)
- /fix command (rebuild from event log)
- /override command (manual write)

## Error Handling

| Error | Recovery |
|-------|----------|
| State file missing | Initialize from template (lifecycle_version: 2) |
| State corrupted | Rebuild from event-log.jsonl |
| Event log missing | Initialize empty, warn user |
| Version mismatch | Run migration (migrate-state → migrate-lifecycle) |
| Legacy state detected | Block operation, require v2 migration |

---

_Skill spec backported from lens module on 2026-02-17. Updated for v2 lifecycle contract 2026-02-23._
