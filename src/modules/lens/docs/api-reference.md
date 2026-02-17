# API Reference

## State Contract

### state.yaml Schema

```yaml
lens_contract_version: "2.0"     # Contract version for cross-module compatibility

active_initiative:
  id: string                     # Initiative identifier
  type: enum                     # domain | service | feature
  phase: enum                    # pre-plan | plan | tech-plan | story-gen | review | dev
  feature_branch_root: string    # Flat hyphen-separated root branch name
  audiences: string[]            # Active audiences for this initiative
  current_audience: string       # Currently active audience
  current_phase_branch: string   # Currently checked out branch
  gate_status:                   # Per-phase gate status
    pre-plan: enum               # passed | in-progress | not-started
    plan: enum
    tech-plan: enum
    story-gen: enum
    review: enum
    dev: enum
  checklist: object              # Per-phase checklist items

background_errors: object[]      # Accumulated background errors
workflow_status: enum            # idle | running | error
```

### Event Log Schema

```jsonl
{
  "ts": "ISO8601",               // Timestamp
  "event": "string",             // Event type
  "initiative": "string",        // Initiative ID
  "user": "string",              // Git user who triggered
  "details": {}                  // Event-specific payload
}
```

### Event Types

| Event | Trigger |
|-------|---------|
| `initiative_created` | /new |
| `phase_transition` | Phase advance |
| `workflow_start` | Any workflow begins |
| `workflow_end` | Any workflow completes |
| `gate_opened` | Phase gate passes |
| `gate_blocked` | Phase gate fails |
| `state_synced` | /sync |
| `state_fixed` | /fix |
| `state_overridden` | /override |
| `context_switch` | /switch |
| `initiative_archived` | /archive |
| `error` | Any error |

## Branch Patterns

```yaml
domain: "{domain_prefix}"
service: "{domain_prefix}-{service_prefix}"
root: "{featureBranchRoot}"
audience: "{featureBranchRoot}-{audience}"
phase: "{featureBranchRoot}-{audience}-p{N}"
workflow: "{featureBranchRoot}-{audience}-p{N}-{workflow}"
```

## Commands

| Command | Type | Workflow | Read/Write |
|---------|------|----------|------------|
| `/pre-plan` | Phase | phase/pre-plan | R/W |
| `/plan` | Phase | phase/plan | R/W |
| `/tech-plan` | Phase | phase/tech-plan | R/W |
| `/Story-Gen` | Phase | phase/story-gen | R/W |
| `/Review` | Phase | phase/review | R/W |
| `/Dev` | Phase | phase/dev | R/W |
| `/new` | Initiative | initiative/init-initiative | R/W |
| `/switch` | Initiative | initiative/switch-context | R/W |
| `/status` | Utility | utility/status | R |
| `/sync` | Utility | utility/sync-state | R/W |
| `/fix` | Utility | utility/fix-state | R/W |
| `/override` | Utility | utility/override-state | R/W |
| `/resume` | Utility | utility/resume | R/W |
| `/archive` | Utility | utility/archive | R/W |
| `/onboard` | Discovery | discovery/onboard | R/W |
| `/discover` | Discovery | discovery/discover | R/W |
| `/bootstrap` | Discovery | discovery/bootstrap | R/W |
| `/lens` | Context | (inline) | R |

## Skills

| Skill | Purpose |
|-------|---------|
| `git-orchestration` | Branch creation, commits, pushes, topology |
| `state-management` | state.yaml + event-log.jsonl management |
| `discovery` | Repo scanning, onboarding, bootstrapping |
| `constitution` | Inline governance at every step |
| `checklist` | Progressive phase gate checklists |

## Cross-Module Contract

Other modules can read Lens state by checking `lens_contract_version` in state.yaml. Lens passes to routed modules:
- Current phase and initiative context
- State reference
- Constitution check results
- Audience configuration
