# Lens Architecture

## Design Principles

1. **One interface, zero confusion** — Users never need to know about internal delegation
2. **Constitution at every step** — Governance is invisible but always present
3. **State is sacred** — Every mutation is logged, every transition is validated
4. **Git discipline** — Clean working directory, targeted commits, push at boundaries
5. **Progressive disclosure** — Show only what's relevant right now

## Single Agent Architecture

Lens uses ONE agent (`@lens`) that delegates to internal skills:

```
User → @lens → Skills → Module Workflows
                ↓
          ┌─────────────────────┐
          │  git-orchestration  │ → Branch/commit/push
          │  state-management   │ → state.yaml + event-log
          │  discovery          │ → Repo scanning/onboarding
          │  constitution       │ → Inline governance
          │  checklist          │ → Progressive phase gates
          └─────────────────────┘
```

### Why Single Agent?

lens-work used 5 agents (Compass, Casey, Tracey, Scout, Scribe). This caused:
- User confusion about which agent to invoke
- Context switching overhead
- Inconsistent state handling across agents

Lens collapses them into one agent with internal skill delegation.

## Two-File State System

### state.yaml (Mutable)

Current initiative state, updated atomically at workflow boundaries.

### event-log.jsonl (Immutable)

Append-only audit trail. Used by `/fix` to reconstruct corrupted state.

## Background Workflows

Auto-triggered at workflow boundaries. Never user-invoked.

| Trigger | Workflows |
|---------|-----------|
| workflow_start | state-sync, constitution-check |
| workflow_end | state-sync, event-log, checklist-update |
| phase_transition | branch-validate, state-sync, event-log, constitution-check, checklist-update |
| initiative_create | branch-validate, state-sync, event-log |
| error | event-log, state-sync |

## Module Integration

Lens routes into other BMAD modules:
- **BMM** — Planning, architecture, stories, development
- **CIS** — Brainstorming, creative workshops
- **TEA** — Test planning, quality gates
- **BMB** — Module/workflow building (meta)
