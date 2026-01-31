# Workflows Reference

lens includes 14 workflows:

---

## Core (MVP1)

### lens-detect
**Purpose:** Detect current architectural lens and load summary.
**When to Use:** Anytime you need to know where you are architecturally.
**Key Steps:** Collect signals → Resolve lens → Present summary.
**Agent(s):** Navigator

### lens-switch
**Purpose:** Switch to a target lens and reload context.
**When to Use:** When you need to move between Domain, Service, Microservice, or Feature views.
**Key Steps:** Validate target → Load context → Confirm switch.
**Agent(s):** Navigator

### context-load
**Purpose:** Load detailed context for the active lens.
**When to Use:** When you need deeper details in the current lens.
**Key Steps:** Gather context → Format output → Present details.
**Agent(s):** Navigator

---

## Utility (MVP1)

### lens-restore
**Purpose:** Restore a previous lens session.
**When to Use:** When returning to work after a break.
**Key Steps:** Load session → Validate state → Rehydrate context.
**Agent(s):** Navigator

### lens-configure
**Purpose:** Configure detection rules and branch patterns.
**When to Use:** When default detection needs adjustments.
**Key Steps:** Gather settings → Validate config → Write config.
**Agent(s):** Navigator

### workflow-guide
**Purpose:** Recommend next workflows based on current lens and phase.
**When to Use:** When you want guidance on what to do next.
**Key Steps:** Detect context → Map recommendations → Present guidance.
**Agent(s):** Navigator

---

## Post-MVP1

### domain-map
**Purpose:** View and edit domain architecture map.
**When to Use:** When mapping or updating domain structures.
**Key Steps:** Load map → Edit map → Save map.
**Agent(s):** Navigator

### impact-analysis
**Purpose:** Analyze cross-boundary impacts of changes.
**When to Use:** When changes may affect multiple services.
**Key Steps:** Capture scope → Compute impact → Present report.
**Agent(s):** Navigator

### new-service
**Purpose:** Create a new logical service in the domain map.
**When to Use:** When adding a new service to the architecture.
**Key Steps:** Collect metadata → Update map → Scaffold.
**Agent(s):** Navigator

### new-microservice
**Purpose:** Create a new microservice within a service.
**When to Use:** When adding a new microservice.
**Key Steps:** Collect metadata → Scaffold → Update map.
**Agent(s):** Navigator

### new-feature
**Purpose:** Create a new feature branch with BMAD context.
**When to Use:** When starting a new feature.
**Key Steps:** Collect metadata → Create branch → Initialize context.
**Agent(s):** Navigator

### lens-sync
**Purpose:** Reconcile drift between discovered and documented architecture.
**When to Use:** When the map and codebase diverge.
**Key Steps:** Discover structure → Compare maps → Apply updates.
**Agent(s):** Navigator

### service-registry
**Purpose:** Manage service registry mappings.
**When to Use:** When updating service identifiers and aliases.
**Key Steps:** Load registry → Edit entries → Save registry.
**Agent(s):** Navigator

### onboarding
**Purpose:** First-time onboarding and starter configuration.
**When to Use:** When introducing LENS to a new project.
**Key Steps:** Detect structure → Explain lenses → Create starter config.
**Agent(s):** Navigator

---
