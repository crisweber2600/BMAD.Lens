# Core Workflows — Init Initiative

**Module:** lens-work
**Category:** core (auto-triggered)
**Agent:** Casey
**Status:** Specification

---

## Workflow: init-initiative

### Trigger

`#new-domain`, `#new-service`, `#new-feature` commands via Compass

### Purpose

Create the full branch topology for a new initiative in the BMAD control repo.

### Input

```yaml
initiative_name: "Rate Limiting Feature"
layer: microservice  # domain/service/microservice/feature
target_repo: api-gateway  # resolved from service map
```

### Branch Topology Created

```
{featureBranchRoot}                              # Initiative root
├── {featureBranchRoot}-small                   # Audience: small
├── {featureBranchRoot}-medium                  # Audience: medium
└── {featureBranchRoot}-large                   # Audience: large
```

### Sequence

1. Generate initiative ID (e.g., `rate-limit-x7k2m9`)
2. Create root branch from current HEAD
3. Create small audience from root
4. Create medium audience from root
5. Create large audience from root
6. Checkout to `small` (first phase branch created by router)
7. Initialize state.yaml
8. Log to event-log.jsonl
9. Return control to Compass

### Output

```
✅ Initiative created: rate-limit-x7k2m9
├── Root: lens-rate-limit-x7k2m9
├── Small: lens-rate-limit-x7k2m9-small
├── Medium: lens-rate-limit-x7k2m9-medium
├── Large: lens-rate-limit-x7k2m9-large
└── Ready for /pre-plan
```

---

## Related Workflows

| Workflow | Purpose |
|----------|---------|
| `start-workflow` | Create workflow branch within phase |
| `finish-workflow` | Commit and push workflow branch |
| `start-phase` | Create next phase branch |
| `finish-phase` | Push phase branch to size |

---

_Workflow spec created on 2026-02-03 via BMAD Module workflow_
