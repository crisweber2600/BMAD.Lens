# Migration from lens-work

## Overview

Lens is the successor to lens-work. This guide covers how to migrate an existing lens-work installation to Lens.

## Breaking Changes

| lens-work | Lens | Change |
|-----------|------|--------|
| 5 agents (Compass, Casey, Tracey, Scout, Scribe) | 1 agent (@lens) | Skills replace agents |
| 30+ commands/shortcodes | 12 core commands | Simplified |
| `/spec` command | `/plan` | Renamed |
| Separate governance workflows | Constitution-as-skill | Inline at every step |
| Global audience config | Per-initiative audiences | More flexible |
| `lens-work.*` prompt prefix | `lens.*` prompt prefix | Shorter |
| `_bmad-output/lens-work/` | `_bmad-output/lens/` | New output path |
| `_bmad/lens-work/` | `_bmad/lens/` | New install path |

## Command Mapping

| lens-work | Lens | Notes |
|-----------|------|-------|
| `/pre-plan` | `/pre-plan` | Same |
| `/spec` | `/plan` | Renamed |
| `/arch` | `/tech-plan` | Renamed |
| `/stories` | `/Story-Gen` | Renamed |
| — | `/Review` | New (readiness checks) |
| `/dev` | `/Dev` | Same |
| `/new-domain`, `/new-service`, `/new-feature` | `/new` | Unified |
| `/switch` | `/switch` | Same |
| `/status` | `/status` | Same |
| `/sync` | `/sync` | Same |
| `/fix` | `/fix` | Same |
| `/onboard` | `/onboard` | Same |

## Migration Steps

1. **Install Lens** alongside lens-work (they use different paths)
2. **Run `/onboard`** — Lens discovers existing repos
3. **Migrate state** — Lens reads lens-work state and migrates schema
4. **Verify with `/status`** — Confirm initiative state is correct
5. **Uninstall lens-work** — Remove `_bmad/lens-work/` directory

## State Migration

Lens reads lens-work's `state.yaml` and converts:
- `smallGroupBranchRoot` → `feature_branch_root` + audiences
- Old phase names → new gate_status keys
- Event log format preserved (compatible)

## Known Differences

- Lens does not support the old slash-based branch naming
- Background workflows no longer silent-fail; errors tracked in state
- Constitution checks are automatic; no manual `/audit` command
