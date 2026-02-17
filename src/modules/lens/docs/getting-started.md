# Getting Started with Lens

## Overview

Lens is the unified lifecycle router for BMAD — one agent, one interface, every phase. It replaces lens-work's five-agent architecture with a single `@lens` agent that delegates internally through skills.

## First Steps

### 1. Onboard

```
@lens /onboard
```

This detects your git identity, creates a profile, and scans your workspace for repos.

### 2. Create an Initiative

```
@lens /new
```

Lens will ask for:
- **Type:** Domain, Service, or Feature
- **Name:** A descriptive identifier
- **Audiences:** Which sizes to create (default: small, medium, large)

### 3. Start Pre-Planning

```
@lens /pre-plan
```

This launches the brainstorming and discovery phase, routing into CIS and BMM workflows.

### 4. Progress Through Phases

```
@lens /plan         # Product requirements
@lens /tech-plan    # Architecture design
@lens /Story-Gen    # Generate implementation stories
@lens /Review       # Implementation readiness checks
@lens /Dev          # Implementation loop
```

### 5. Check Status

```
@lens /status       # Compact view
@lens /lens         # Full expanded view
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/onboard` | First-time setup |
| `/new` | Create initiative |
| `/switch` | Switch initiative |
| `/pre-plan` | Brainstorming & discovery |
| `/plan` | Product requirements |
| `/tech-plan` | Architecture design |
| `/Story-Gen` | Story generation |
| `/Review` | Readiness checks |
| `/Dev` | Implementation |
| `/status` | Quick status |
| `/lens` | Full context |
| `/sync` | Reconcile state |
| `/fix` | Repair state |

## Next Steps

- Read [Architecture](architecture.md) for how Lens works internally
- Read [Configuration](configuration.md) for customization options
- Read [Branch Topology](branch-topology.md) for git strategy
