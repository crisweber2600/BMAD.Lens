# LENS: Comprehensive Guide to Layered Enterprise Navigation System

## Table of Contents

1. [What is LENS?](#what-is-lens)
2. [Core Problems LENS Solves](#core-problems-lens-solves)
3. [LENS Architecture](#lens-architecture)
4. [Core Agents](#core-agents)
5. [Extensions Overview](#extensions-overview)
6. [Getting Started](#getting-started)
7. [Workflows By Category](#workflows-by-category)
8. [Extension Details](#extension-details)

---

## What is LENS?

**LENS** (Layered Enterprise Navigation System) is a meta-navigation module for BMAD that provides multi-layered understanding of complex systems through architectural context detection, automated discovery, and bi-directional synchronization between architectural intent and physical code.

### Key Capabilities

- **Automatic Context Detection:** Detects whether you're working at Domain, Service, Microservice, or Feature level
- **Git-Aware Navigation:** Integrates with git to provide workflow-aware guidance
- **Brownfield Discovery:** Analyzes existing codebases and auto-generates BMAD-ready documentation
- **Bidirectional Sync:** Keeps architectural metadata synchronized with physical code reality
- **Role-Based Guidance:** Learns user roles and suggests contextual next steps
- **Constitutional Governance:** Applies enterprise rules and constraints to workflows

### The Problem LENS Solves

In large, interconnected enterprise systems:

- **Cognitive Overload:** Developers waste time understanding architectural context at the wrong zoom level
- **Architecture Drift:** Documented architecture doesn't match actual code structure
- **Bootstrap Pain:** Legacy systems are difficult to onboard into modern frameworks
- **Fragmented Knowledge:** Design intent lives in documentation, but implementation lives in code
- **Scale Complexity:** Managing multiple services, microservices, and features across domains requires constant context switching

LENS reduces this friction by automatically detecting your current architectural context and keeping documentation synchronized with reality.

---

## Core Problems LENS Solves

### 1. **Context Switching Overhead**
   - **Problem:** Developers manually track whether they're working at domain, service, or feature level
   - **Solution:** LENS automatically detects architectural context from git branches and folder structure
   - **Result:** Right context, right time; reduced cognitive load

### 2. **Architecture-Code Misalignment**
   - **Problem:** Architecture documents say one thing; code says another
   - **Solution:** LENS performs automated brownfield discovery and bi-directional synchronization
   - **Result:** Single source of truth between design and implementation

### 3. **Brownfield Legacy System Bootstrap**
   - **Problem:** Onboarding existing systems into BMAD requires manual analysis and documentation
   - **Solution:** Scout discovers code patterns; Bridge aligns folder structure; Scout generates BMAD metadata
   - **Result:** Legacy systems BMAD-ready in minutes

### 4. **Workflow Complexity at Scale**
   - **Problem:** Which workflows apply at which architectural level? When should I use git-lens vs. compass?
   - **Solution:** LENS routes workflows through the appropriate agents based on context
   - **Result:** Developers follow natural workflows without learning tool topology

### 5. **Role and Responsibility Fragmentation**
   - **Problem:** Large teams don't know each other's expertise or track contribution patterns
   - **Solution:** Lens Compass learns roles, tracks contributions, and suggests next steps
   - **Result:** Better role alignment and improved team coordination

### 6. **Governance and Compliance at Scale**
   - **Problem:** Enterprise policies aren't enforced; developers learn constraints through code review
   - **Solution:** SPEC provides constitutional governance applied automatically to all workflows
   - **Result:** Consistent, auditable application of enterprise rules

---

## LENS Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   LENS Core Module                           │
│  (Layered Enterprise Navigation System)                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │   Navigator    │  │     Bridge     │  │     Scout      │ │
│  │ (Navigation)   │  │ (Synchronizer) │  │ (Discovery)    │ │
│  └────────────────┘  └────────────────┘  └────────────────┘ │
│                                                              │
│  ┌────────────────┐                                          │
│  │      Link      │                                          │
│  │ (Lens Guardian)│                                          │
│  └────────────────┘                                          │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│  Extensions Layer                                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────┐ ┌──────────────────┐ ┌──────────────┐ │
│  │   Git-Lens      │ │  Lens Compass    │ │    SPEC      │ │
│  │ (Workflow Git   │ │ (Role Guidance)  │ │ (Governance) │ │
│  │  Orchestration) │ │                  │ │              │ │
│  └─────────────────┘ └──────────────────┘ └──────────────┘ │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Architectural Layers

**Level 1: Navigation Context**
- Domain → Service → Microservice → Feature
- Automatic detection from git branch + folder structure
- Session persistence (restore last context)

**Level 2: Discovery & Sync**
- Analyze existing codebases
- Generate BMAD-ready documentation
- Propagate changes bidirectionally

**Level 3: Workflow Orchestration**
- Git-lens: Automated branch management and PR gating
- Lens Compass: Role-aware guidance and roster tracking
- SPEC: Constitutional governance and compliance

---

## Core Agents

### 1. **Navigator** — Architectural Context Navigation
**What it does:** Detects where you are in the architecture and guides you to relevant workflows

**Key workflows:**
- `lens-detect` — Automatically determine current architectural level
- `lens-switch` — Change between Domain/Service/Microservice/Feature views
- `context-load` — Pull deeper details for current lens
- `workflow-guide` — Get recommendations for next steps based on context

**Problems solved:**
- Reduces manual context tracking
- Provides always-on guidance
- Enables context-aware workflow routing

### 2. **Bridge** — The Synchronizer (Folder Structure Alignment)
**What it does:** Aligns physical folder structure with architectural domain map

**Key workflows:**
- `bootstrap` — Initialize folder structure from domain map
- `domain-map` — Create or update domain architecture definition
- `service-registry` — Register services in the system

**Problems solved:**
- Legacy brownfield system onboarding
- Consistent folder structure across projects
- Clear separation of concerns (domain/service/microservice)

### 3. **Scout** — Discovery Specialist (Code Analysis & Documentation)
**What it does:** Analyzes existing code and auto-generates BMAD-ready documentation

**Key workflows:**
- `discover` — Scan codebase for architectural patterns
- `analyze-codebase` — Deep analysis of code structure
- `generate-docs` — Auto-generate documentation from code
- `onboarding` — Full discovery and documentation for new systems

**Problems solved:**
- Manual documentation effort eliminated
- Bootstrap legacy systems into BMAD quickly
- Up-to-date documentation from actual code

### 4. **Link** — Lens Guardian (Metadata Propagation)
**What it does:** Synchronizes documentation changes with code and maintains consistency

**Key workflows:**
- `update-lens` — Propagate documentation changes
- `sync-status` — Check alignment between architecture and code
- `reconcile` — Resolve conflicts between versions
- `validate-schema` — Ensure all metadata is valid
- `rollback` — Revert to previous documented state

**Problems solved:**
- Bidirectional sync between architecture and code
- Conflict detection and resolution
- Audit trail of changes
- Point-in-time recovery

---

## Extensions Overview

LENS provides three powerful extensions that layer additional capabilities on top of the core system:

| Extension | Purpose | Primary Agent | Key Benefit |
|-----------|---------|---------------|------------|
| **Git-Lens** | Git workflow orchestration | Casey, Tracey | Automated branching, PR management, workflow enforcement |
| **Lens Compass** | Role-aware guidance | Navigator (Compass) | Roster tracking, suggestion engine, preference learning |
| **SPEC** | Constitutional governance | Scribe (Cornelius) | Enterprise rules, compliance checking, auditable decisions |

---

## Getting Started

### Quick Start (5 minutes)

1. **Install LENS:**
   ```bash
   bmad install lens
   ```

2. **Run First-Time Setup:**
   ```bash
   bmad.start
   ```
   This automatically initializes all extensions and detects your current context.

3. **Detect Your Context:**
   ```bash
   navigator
   ```

4. **Get Guidance:**
   ```bash
   guide
   ```

### Full Installation & Configuration

See [Getting Started Guide](docs/getting-started.md) for:
- Prerequisites and dependencies
- Configuration options
- Bootstrap setup (if using domain maps)
- Troubleshooting

---

## Workflows By Category

### **Navigation & Context (MVP1)**

| Workflow | Agent | Purpose |
|----------|-------|---------|
| `lens-detect` | Navigator | Automatically detect current architectural level |
| `lens-switch` | Navigator | Switch between Domain/Service/Microservice/Feature views |
| `context-load` | Navigator | Load deeper context details for current level |
| `lens-restore` | Navigator | Restore previous session context |
| `lens-configure` | Navigator | Configure branch patterns and context detection |
| `workflow-guide` | Navigator | Get guided recommendations for next steps |

### **Discovery & Synchronization**

| Workflow | Agent | Purpose |
|----------|-------|---------|
| `bootstrap` | Bridge | Initialize folder structure from domain map |
| `discover` | Scout | Scan codebase and identify patterns |
| `analyze-codebase` | Scout | Deep code analysis |
| `generate-docs` | Scout | Auto-generate documentation |
| `sync-status` | Link | Check alignment between architecture and code |
| `reconcile` | Link | Resolve conflicts between versions |
| `update-lens` | Link | Propagate documentation changes |
| `validate-schema` | Link | Validate all metadata |
| `rollback` | Link | Restore from snapshot |

### **Advanced Features**

| Workflow | Agent | Purpose |
|----------|-------|---------|
| `new-service` | Navigator | Create new service with full scaffolding |
| `new-microservice` | Navigator | Create new microservice |
| `new-feature` | Navigator | Create new feature |
| `domain-map` | Bridge | Define enterprise domain structure |
| `service-registry` | Bridge | Register services in the system |
| `impact-analysis` | Scout | Analyze changes across architecture |
| `lens-sync` | Link | Full system synchronization |
| `onboarding` | Scout | Complete new project onboarding |

### **Git-Lens Workflows** (Automated Git Management)

| Workflow | Agent | Purpose |
|----------|-------|---------|
| `init-initiative` | Casey/Tracey | Initialize branch structure for new initiative |
| `start-workflow` | Casey/Tracey | Create workflow branches with naming |
| `finish-workflow` | Casey/Tracey | Complete workflow and prepare PR |
| `start-phase` | Casey/Tracey | Begin phase within workflow |
| `finish-phase` | Casey/Tracey | Complete phase and update state |
| `open-lead-review` | Casey/Tracey | Create lead review PR |
| `open-final-pbr` | Casey/Tracey | Create final peer review |

**Diagnostics:**
- `status` — Show current git state
- `resume` — Resume interrupted workflow
- `sync` — Synchronize local branches
- `fix-state` — Repair corrupted state
- `override` — Force state override

### **Lens Compass Workflows** (Role-Based Guidance)

| Workflow | Agent | Purpose |
|----------|-------|---------|
| `onboarding` | Navigator (Compass) | Create personal profile |
| `next-step-router` | Navigator (Compass) | Get role-aware next step |
| `roster-tracker` | Navigator (Compass) | Track team contributions |
| `profile-manager` | Navigator (Compass) | Manage user profiles |
| `roster-query` | Navigator (Compass) | Query roster data |
| `preference-learner` | Navigator (Compass) | Learn user preferences |
| `context-analyzer` | Navigator (Compass) | Analyze workflow context |

### **SPEC Workflows** (Constitutional Governance)

| Workflow | Agent | Purpose |
|----------|-------|---------|
| `constitution` | Scribe (Cornelius) | Create or amend constitution |
| `resolve-constitution` | Scribe (Cornelius) | Display all applicable rules |
| `compliance-check` | Scribe (Cornelius) | Validate artifacts against rules |
| `ancestry` | Scribe (Cornelius) | Show constitution inheritance chain |

**Command Routing (familiar Spec-Kit commands):**
- `/specify` → Create PRD
- `/plan` → Create architecture
- `/tasks` → Create epics and stories
- `/implement` → Develop story
- `/review` → Code review

---

## Extension Details

### **Git-Lens: Git Workflow Orchestration**

**What it solves:**
- Manual branch creation and naming
- PR routing and reviewer assignment
- Workflow state tracking across git
- Sequential workflow enforcement

**How it works:**
1. Hooks into LENS initiative workflows
2. Automatically creates initiative branches from domain-service-feature naming
3. Creates workflow branches as phases complete
4. Manages PR creation with gating and reviewer suggestions
5. Maintains state through git metadata

**Key features:**
- Predictable branch topology
- Automatic PR creation and linking
- Reviewer suggestions based on code ownership
- Sequential workflow gating
- State recovery and diagnostics

**Configuration:**
```yaml
base_ref: main              # Default base branch
auto_push: true             # Push branches automatically
remote_name: origin         # Git remote to use
fetch_strategy: background  # How to sync with remote
commit_strategy: squash     # Commit strategy for merges
pr_api_enabled: true        # Enable GitHub/Azure PR API
```

---

### **Lens Compass: Role-Based Navigation & Guidance**

**What it solves:**
- User role fragmentation in large teams
- Lack of contribution tracking
- Decision fatigue ("which workflow applies to me?")
- Roster and expertise discovery

**How it works:**
1. Creates personal profiles on first use (from git identity)
2. Learns user role from workflow patterns
3. Tracks contributions and expertise
4. Suggests next steps based on role and phase
5. Maintains shared roster for team visibility

**Key features:**
- Automatic role detection
- Contribution tracking
- Smart suggestion engine
- Team roster management
- Preference learning
- Expertise discovery

**Configuration:**
```yaml
personal_profiles_folder: _bmad-output/personal
roster_file: _bmad-output/.bmad-roster.yaml
use_git_identity: true           # Initialize from git config
suggestion_mode: smart           # When to suggest next steps
preference_learning: true        # Learn from user actions
```

**Suggestion Modes:**
- `smart` — Suggest only when contextually relevant
- `always` — Always suggest next step
- `quiet` — Only on explicit request

---

### **SPEC: Constitutional Governance**

**What it solves:**
- Enterprise policy enforcement at scale
- Governance auditing and compliance
- Distributed decision-making without losing coherence
- Constitution versioning and inheritance

**How it works:**
1. Define constitutions at multiple levels (Domain → Service → Microservice → Feature)
2. SPEC automatically inherits and validates across levels
3. Routes `/specify`, `/plan`, `/tasks`, `/implement` commands through constitution validation
4. Blocks or warns on non-compliance
5. Maintains audit trail of all decisions

**Constitution Hierarchy:**
```
Domain Constitution (enterprise-wide rules)
    ↓ inherits and specializes
Service Constitution (service-specific rules)
    ↓ inherits and specializes
Microservice Constitution (bounded context rules)
    ↓ inherits and specializes
Feature Constitution (feature-level discipline)
```

**Key principles:**
- Inheritance is automatic
- Additions are allowed
- Contradictions are forbidden
- Specialization is encouraged

**Configuration:**
```yaml
constitution_root: lens/constitutions    # Where constitutions live
auto_compliance_check: true               # Check before workflow
strict_mode: false                        # Block if no constitution
```

**Example Commands:**
- `/specify` — Create PRD (runs compliance check)
- `/plan` — Create architecture (applies constitution rules)
- `/tasks` → `/implement` — Full compliance-checked implementation

---

## Architecture Decision Records

### Why Layered Navigation?

Modern enterprise systems aren't uniform. A developer might work on a small feature within a service within a domain. Context switches between these levels are expensive. LENS detects context automatically so tools can present the right abstractions at the right time.

### Why Bidirectional Sync?

Architecture documentation becomes stale because it's disconnected from implementation. LENS treats documentation as a first-class citizen: Scout generates it from code, Link keeps it synchronized, and Bridge uses it to structure new work. Single source of truth.

### Why Extensions?

LENS core handles context detection and discovery. Extensions layer on specialized capabilities:
- **Git-Lens** specializes in git workflow orchestration
- **Lens Compass** specializes in team coordination and guidance
- **SPEC** specializes in governance and compliance

This separation maintains focus while enabling composition.

---

## Integration with BMAD

LENS is a BMAD module that integrates with:

- **Core BMAD Agents:** Bridge, Scout, Link, Navigator are BMAD agents
- **BMAD Workflows:** All LENS workflows are BMAD workflows with specs and tests
- **BMAD Modules:** Extensions (Git-Lens, Compass, SPEC) are BMAD modules
- **BMAD Context:** LENS extends BMAD context with architectural layer
- **BMAD Events:** LENS hooks into BMAD initialization and workflow lifecycle

### How LENS Fits in BMAD's Architecture

```
BMAD Framework
    ├── Core Agents (native BMAD agents)
    ├── Modules
    │   ├── LENS (Multi-layered navigation)
    │   │   ├── Core Agents: Navigator, Bridge, Scout, Link
    │   │   ├── Extensions
    │   │   │   ├── Git-Lens (Casey, Tracey)
    │   │   │   ├── Lens Compass (Navigator variant)
    │   │   │   └── SPEC (Scribe)
    │   │   └── Workflows (22 core + 20+ extension)
    │   └── Other modules...
    └── Orchestration Layer
```

---

## Common Use Cases

### 1. **Onboarding New Developer**
```
Developer starts → Navigator detects context → Compass suggests onboarding
→ Scout discovers patterns → Navigation workflow shows available tasks
```

### 2. **Bringing Legacy System into BMAD**
```
Run scout discover → analyze-codebase → generate-docs
→ Bridge bootstrap aligns folders → LENS ready to use
```

### 3. **Starting New Service**
```
Run new-service → Git-Lens initializes branches → Constitutional validation
→ Compass learns role → Links tracked for future navigation
```

### 4. **Enterprise-Wide Policy Enforcement**
```
Define domain constitution → Services inherit and specialize
→ SPEC validates all workflows → Audit trail maintained
```

### 5. **Team Coordination at Scale**
```
Compass learns team roles → Roster tracks expertise
→ Role-aware suggestions → Automatic next-step routing
```

---

## Documentation Structure

- **[Getting Started](docs/getting-started.md)** — Quick start and setup
- **[Prerequisites](docs/prerequisites.md)** — Requirements and dependencies
- **[Architecture](docs/architecture.md)** — Deep dive into LENS design
- **[Configuration](docs/configuration.md)** — All configuration options
- **[Workflows](docs/workflows.md)** — Detailed workflow reference
- **[Agents](docs/agents.md)** — Agent specifications and behavior
- **[Operations](docs/operations.md)** — Running and troubleshooting LENS
- **[Examples](docs/examples.md)** — Real-world usage examples
- **[Traceability](docs/traceability.md)** — How to trace execution

---

## Support & Contribution

For issues, feature requests, or contributions:
- See [TODO.md](TODO.md) for roadmap
- Review [Architecture](docs/architecture.md) for design decisions
- Check [Troubleshooting](docs/troubleshooting.md) for common issues

---

**LENS: Making architectural navigation automatic, documentation synchronized, and governance auditable.**
