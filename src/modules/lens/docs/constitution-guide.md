# Constitution Guide

## Overview

Lens enforces governance through the **constitution skill** — inline checks that run at every workflow step automatically. Unlike lens-work's separate governance workflows, constitution checks in Lens are invisible skills that validate compliance without requiring user action.

## How It Works

At every workflow step:
1. Constitution skill reads governance rules
2. Rules are checked against current state and artifacts
3. Results are logged to event-log.jsonl
4. Violations are surfaced (or blocked, depending on mode)

## Governance Rules

### Initiative Structure
- Required fields present (id, type, name)
- Valid initiative type (domain, service, feature)
- Parent hierarchy is consistent

### Phase Progression
- Phases advance in order (no skipping)
- Required gate must pass before next phase
- Gate conditions are met (artifacts exist, checklist complete)

### Branch Topology
- Branches match expected naming patterns
- All configured audiences have branches
- Phase branches are created from correct parent

### Artifact Completeness
- Required artifacts exist for current phase
- Artifacts are non-empty
- Artifacts were modified in current phase (not stale)

## Modes

### Advisory (Default)
Violations are logged as warnings. Progress is not blocked. Users see warnings in `/status` output.

### Enforced
Critical violations block progress. The constitution skill cites the specific rule and provides a remediation path.

## Configuration

Set per-initiative in `initiative.yaml`:

```yaml
constitution_mode: advisory  # advisory | enforced
```

## Viewing Constitution Results

- `/status` — Shows critical violations
- `/lens` — Shows all violations and warnings
- Event log — Full history of all checks
