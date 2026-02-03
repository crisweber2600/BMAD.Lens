---
stepsCompleted: [1, 2, 3, 4, 5, 6]
inputDocuments:
  - src/modules/lens/module.yaml
  - src/modules/lens/module-config.yaml
  - src/modules/lens/README.md
  - src/modules/lens/TODO.md
  - src/modules/lens/docs/architecture.md
  - src/modules/lens/docs/agents.md
  - src/modules/lens/docs/workflows.md
  - src/modules/lens/docs/configuration.md
  - src/modules/lens/docs/session-store.md
  - src/modules/lens/docs/getting-started.md
  - src/modules/lens/docs/operations.md
  - src/modules/lens/docs/scope.md
  - src/modules/lens/agents/navigator.spec.md
  - src/modules/lens/agents/bridge.spec.md
  - src/modules/lens/agents/scout.spec.md
  - src/modules/lens/agents/link.spec.md
  - src/modules/lens/agents/navigator.agent.yaml
  - src/modules/lens/agents/bridge/bridge.agent.yaml
  - src/modules/lens/agents/scout/scout.agent.yaml
  - src/modules/lens/agents/link/link.agent.yaml
  - src/modules/lens/prompts/bmad.start.prompt.md
  - src/modules/lens/extensions/git-lens/module.yaml
  - src/modules/lens/extensions/git-lens/README.md
  - src/modules/lens/extensions/git-lens/agents/tracey.agent.yaml
  - src/modules/lens/extensions/git-lens/agents/casey.agent.yaml
  - src/modules/lens/extensions/lens-compass/module.yaml
  - src/modules/lens/extensions/lens-compass/README.md
  - src/modules/lens/extensions/lens-compass/agents/navigator.agent.yaml
  - src/modules/lens/extensions/spec/module.yaml
  - src/modules/lens/extensions/spec/README.md
  - src/modules/lens/extensions/spec/agents/scribe/scribe.agent.yaml
  - src/modules/lens/extensions/lens-sync/module.yaml
date: 2026-02-03
author: CrisWeber
status: complete
---

# Product Brief: LENS — Layered Enterprise Navigation System

## Executive Summary

**LENS (Layered Enterprise Navigation System)** is a sophisticated meta-navigation module for the BMAD framework that provides git-aware architectural navigation with automated discovery and synchronization for large, interconnected enterprise projects.

LENS addresses the critical challenge of **cognitive overload** in complex multi-service architectures by automatically detecting and switching between hierarchical architectural contexts (Domain → Service → Microservice → Feature), syncing architectural knowledge with physical codebase reality through automated brownfield discovery, and maintaining bi-directional lens synchronization as systems evolve.

**Key Value Proposition:** LENS acts as the "GPS for your codebase" — understanding architecture from satellite view (Domain) down to indoor navigation (Feature), eliminating context-switching friction and maintaining alignment between architectural intent and physical implementation.

---

## Core Vision

### Problem Statement

Enterprise development teams working with complex, multi-repository architectures face significant challenges:

1. **Context Disorientation** — Developers lose track of where they are in large systems spanning dozens of repositories, services, and microservices
2. **Architectural Drift** — Documentation and architectural models diverge from physical codebase reality over time
3. **Onboarding Friction** — New team members struggle to build mental models of complex systems
4. **Cross-Boundary Blindness** — Impact analysis across service boundaries requires extensive manual investigation
5. **Legacy System Opacity** — Brownfield codebases lack BMAD-ready documentation, blocking modern workflow adoption

### Problem Impact

- **Productivity Loss**: Teams waste 20-30% of time navigating and context-switching
- **Quality Degradation**: Cross-boundary changes introduce bugs due to incomplete understanding
- **Onboarding Delay**: New developers take months to become productive in complex systems
- **Technical Debt Accumulation**: Architectural drift compounds when reality diverges from intent
- **Knowledge Silos**: Undocumented legacy systems create dangerous single points of failure

### Why Existing Solutions Fall Short

| Solution | Limitation |
|----------|------------|
| **IDE Navigation** | File-level only; no architectural context awareness |
| **Documentation** | Static; drifts from reality; requires manual updates |
| **Architecture Diagrams** | Don't sync with code; become stale quickly |
| **Wiki Systems** | No integration with development workflow; manual maintenance |
| **Code Search** | No hierarchical understanding; returns flat results |

### Proposed Solution

LENS provides a **four-layer hierarchical navigation system** that:

1. **Auto-detects architectural context** from git branch names, directory structure, and session state
2. **Bootstraps project structures** from domain maps, cloning and organizing repositories automatically
3. **Discovers brownfield systems** using AI-powered codebase analysis to generate BMAD-ready documentation
4. **Maintains synchronization** between architectural models and physical codebases
5. **Guides workflow selection** based on current lens and user role

### Key Differentiators

| Differentiator | Description |
|----------------|-------------|
| **Hierarchical Zoom** | Four-level lens system (Domain/Service/Microservice/Feature) with seamless transitions |
| **Git-Native Detection** | Infers context from branch names and git state without configuration |
| **AI-Powered Discovery** | Scout agent analyzes brownfield codebases to extract architecture, APIs, data models |
| **Bi-Directional Sync** | Detects and reconciles drift between lens models and physical reality |
| **Extension Architecture** | Modular capabilities via 4 bundled extensions (git-lens, lens-compass, spec, lens-sync) |
| **Session Continuity** | Restores previous context across sessions for seamless continuation |

---

## Target Users

### Primary Users

#### 1. Product Owner / Domain Architect
**Role:** Strategic decision-maker defining features, priorities, and domain architecture

**Pain Points:**
- Difficulty maintaining system-wide perspective
- Can't easily trace impact of domain decisions to implementation
- Struggles to communicate architecture to stakeholders

**Value from LENS:**
- Domain-level lens for strategic overview
- Impact analysis across service boundaries
- Domain maps for architectural communication

#### 2. Tech Lead / Architect
**Role:** Technical leader designing solutions, reviewing code, coordinating implementation

**Pain Points:**
- Context-switching between different service areas
- Ensuring architectural consistency across teams
- Onboarding new team members efficiently

**Value from LENS:**
- Service-level lens for technical coordination
- Constitutional governance via SPEC extension
- Discovery workflows for documentation generation

#### 3. Developer
**Role:** Implementation specialist building features and maintaining code quality

**Pain Points:**
- Understanding legacy systems without documentation
- Finding the right place to make changes
- Understanding cross-service dependencies

**Value from LENS:**
- Microservice/Feature lens for focused work
- Scout-generated documentation for brownfield systems
- Git-lens orchestration for workflow enforcement

### Secondary Users

#### 4. QA Engineer
**Value:** Understands service boundaries for test planning; uses discovery outputs for test documentation

#### 5. DevOps Engineer
**Value:** Domain maps inform deployment topology; sync-status identifies infrastructure drift

#### 6. New Team Member
**Value:** Onboarding workflow provides guided introduction; discovery generates learning materials

---

## Success Metrics

### Adoption Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Module Installation | 100+ active installations | Download/activation count |
| Daily Active Users | 50%+ of installed base | Session tracking |
| Extension Adoption | 75%+ enable all extensions | Installation telemetry |

### Efficiency Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Context Detection Accuracy | >95% correct lens | User corrections logged |
| Onboarding Time Reduction | 50% faster | Time-to-first-PR |
| Documentation Generation | <30 min/service | Workflow timing |

### Quality Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Drift Detection Rate | >90% drift surfaced | Sync-status findings |
| Documentation Coverage | 100% BMAD-ready | Scout completion rate |
| Constitution Compliance | >95% passing | Compliance check results |

---

## Scope Definition

### In Scope (MVP)

#### Core Navigation (MVP1)
- [x] Navigator agent with 11 workflows
- [x] Four-level lens detection (Domain/Service/Microservice/Feature)
- [x] Git branch pattern matching for context inference
- [x] Session persistence and restoration
- [x] Workflow guide for lens-aware recommendations

#### Discovery & Synchronization (MVP2-3)
- [x] Bridge agent: Bootstrap, sync-status, reconcile workflows
- [x] Scout agent: Discover, analyze-codebase, generate-docs workflows
- [x] Link agent: Update-lens, validate-schema, rollback workflows
- [x] Domain map and service registry management

#### Extensions
- [x] git-lens: Git workflow orchestration (branching, PR gating)
- [x] lens-compass: Role-based navigation and guidance
- [x] spec: Constitutional governance for workflows
- [x] lens-sync: Bi-directional synchronization (merged into core)

### Out of Scope

- Large-scale code refactoring or migrations
- Automated commits, pushes, or PR creation without user approval
- Runtime deployment changes (K8s, CI/CD modifications)
- Continuous background scanning (scheduled daemons)
- Cross-organization repository management
- Real-time collaboration features

### Future Considerations

- **Phase 2**: Enhanced JIRA integration for contextual enrichment
- **Phase 2**: GitHub/GitLab API integration for PR validation
- **Phase 3**: Machine learning for pattern recognition and recommendation
- **Phase 3**: Distributed team coordination features
- **Phase 4**: Visual architecture diagramming

---

## Architecture Overview

### Module Structure

```
lens/
├── module.yaml                 # Module identity and prompts
├── module-config.yaml          # Default configuration
├── README.md / TODO.md         # Documentation
├── _module-installer/          # Installation logic
│   └── installer.js
├── agents/                     # Core agents
│   ├── navigator.agent.yaml    # Primary navigation agent
│   ├── bridge/                 # Synchronization agent
│   ├── scout/                  # Discovery agent
│   └── link/                   # Integrity agent
├── docs/                       # User documentation
├── prompts/                    # Copilot prompts (.github/prompts)
├── workflows/                  # 22 workflows
│   ├── lens-detect/
│   ├── lens-switch/
│   ├── context-load/
│   ├── bootstrap/
│   ├── discover/
│   ├── generate-docs/
│   └── [17 more workflows]
└── extensions/                 # Bundled extensions
    ├── git-lens/               # Git workflow orchestration
    ├── lens-compass/           # Role-based navigation
    ├── lens-sync/              # Discovery (merged into core)
    └── spec/                   # Constitutional governance
```

### Agent Architecture

| Agent | Icon | Role | Key Principle |
|-------|------|------|---------------|
| **Navigator** | 🧭 | GPS for your codebase | Auto-detect over manual config |
| **Bridge** | 🧱 | Structural engineer | Verify before building |
| **Scout** | 🔍 | Detective-archaeologist | Evidence over assumptions |
| **Link** | 🔗 | Librarian-curator | Preserve traceability |

### Data Flow

```
                    ┌─────────────────┐
                    │  domain-map.yaml │
                    │  service.yaml    │
                    └────────┬────────┘
                             │
              ┌──────────────▼──────────────┐
              │         BRIDGE              │
              │  (Bootstrap & Sync Status)  │
              └──────────────┬──────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  SCOUT        │   │  NAVIGATOR    │   │  LINK         │
│  (Discovery)  │   │  (Navigation) │   │  (Integrity)  │
└───────┬───────┘   └───────────────┘   └───────┬───────┘
        │                                       │
        ▼                                       ▼
┌───────────────┐                       ┌───────────────┐
│  Doc Bundle   │ ──────────────────▶   │  Lens Updates │
│  (Generated)  │                       │  (Propagated) │
└───────────────┘                       └───────────────┘
```

### State Management

| Store | Location | Purpose |
|-------|----------|---------|
| **Session Store** | `_bmad/lens/lens-session.yaml` | Current lens position and git state |
| **Navigator Sidecar** | `_bmad/_memory/navigator-sidecar/` | Navigation context persistence |
| **Bridge Sidecar** | `_bmad/_memory/bridge-sidecar/` | Sync state and snapshots |
| **Scout Sidecar** | `_bmad/_memory/scout-sidecar/` | Discovery index |
| **Link Sidecar** | `_bmad/_memory/link-sidecar/` | Cross-lens linking state |

---

## Extension Deep Dive

### Extension 1: git-lens (Git Workflow Orchestration)

#### Purpose
Automates git branching, merge gating, and PR routing for LENS planning workflows. Creates predictable branch topology, enforces sequential workflow completion, and provides PR links with reviewer suggestions.

#### Agents

| Agent | Icon | Role | Sidecar |
|-------|------|------|---------|
| **Casey** | 🏗️ | Git Branch Orchestrator | No |
| **Tracey** | 🧭 | State & Diagnostics Specialist | Yes (`tracey-sidecar`) |

**Casey** (Conductor):
- Executes branch creation, validation, and PR link generation
- Enforces workflow sequence (never allows out-of-order)
- Explicit about every branch change and validation
- Fails safe: defers to Tracey when state is uncertain

**Tracey** (State Manager):
- Owns state persistence and recovery
- Provides status reports and diagnostics
- Manages safe escape hatches (overrides)
- Maintains audit trail in `event-log.jsonl`

#### Workflows (15 total)

**Core (Auto-Triggered):**
| Workflow | Purpose |
|----------|---------|
| `init-initiative` | Create branch topology and initialize state |
| `start-workflow` | Create workflow branch with validation |
| `finish-workflow` | Smart commit, push, and PR link output |
| `start-phase` | Create/checkout phase branch |
| `finish-phase` | Push phase branch and output PR link |
| `open-lead-review` | PR link for small → lead review |
| `open-final-pbr` | PR link for lead → base final PBR |

**Diagnostics (Tracey Commands):**
| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `status` | ST | Display state + topology |
| `resume` | RS | Rehydrate session and checkout branch |
| `sync` | SY | Fetch + re-validate + update state |
| `fix-state` | FIX | Recovery cascade (event log → git scan → user-guided) |
| `override` | OVERRIDE | Force-continue with logged reason |
| `reviewers` | REVIEWERS | Suggest reviewers from Compass integration |
| `recreate-branches` | RECREATE | Recreate missing branches from state |
| `archive` | ARCHIVE | Archive completed initiative |

#### Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `base_ref` | `main` | Default base branch for initiatives |
| `auto_push` | `true` | Auto-push branches on creation |
| `remote_name` | `origin` | Git remote name |
| `fetch_strategy` | `background` | background/sync/manual |
| `fetch_ttl` | `60` | Fetch cache TTL (seconds) |
| `commit_strategy` | `prompt` | prompt/always/never |
| `validation_cascade` | `ancestry_only` | ancestry_only/with_pr_api/with_override |
| `pr_api_enabled` | `false` | Enable GitHub/GitLab API for PR validation |
| `compass_enabled` | `true` | Enable Compass reviewer suggestions |
| `event_log_enabled` | `true` | Enable event log for state recovery |

#### Hooks

git-lens uses hooks to intercept workflow lifecycle events:

| Hook | Trigger | File |
|------|---------|------|
| `before-initiative` | new-service, new-microservice, new-feature | `hooks/before-initiative.md` |
| `before-workflow` | workflow-start | `hooks/before-workflow.md` |
| `after-workflow` | workflow-complete | `hooks/after-workflow.md` |
| `before-phase` | phase-start | `hooks/before-phase.md` |
| `after-phase` | phase-complete | `hooks/after-phase.md` |

#### Platform Support

Includes platform-specific installers:
- `claude-code.js`
- `cursor.js`
- `github-copilot.js`
- `windsurf.js`

---

### Extension 2: lens-compass (Role-Based Navigation)

#### Purpose
Extends LENS with persona-aware guidance, automatic roster tracking, and context-driven next-step recommendations. Reduces decision fatigue by pointing users to the right workflows based on role and current phase.

#### Agent

| Agent | Icon | Role | Sidecar |
|-------|------|------|---------|
| **Compass (Navigator)** | 🧭 | Lens Navigator | Yes (`navigator-sidecar`) |

**Compass** Persona:
- Guide first, never overwhelm
- Uses role context to narrow choices
- Prefers explicit user intent over assumptions
- Learns preferences from repeated behavior
- Respects privacy (keeps personal data local)

#### Workflows (9 total)

**Core:**
| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `onboarding` | ON | Capture identity, roles, and initial preferences |
| `next-step-router` | NX | Suggest most relevant next workflow |
| `roster-tracker` | RT | Auto-log contribution depth to roster |

**Feature:**
| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `profile-manager` | PR | View or edit personal profile |
| `roster-query` | RQ | Find who worked on domain/service/microservice |
| `preference-learner` | PL | Persist learned preferences |
| `context-analyzer` | CA | Determine current phase and context |

**Utility:**
| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `data-cleanup` | DC | Reset personal or roster data |
| `roster-export` | RE | Generate roster reports |

#### Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `personal_profiles_folder` | `{output_folder}/personal` | Profile storage location |
| `roster_file` | `{output_folder}/.bmad-roster.yaml` | Project roster location |
| `use_git_identity` | `true` | Auto-detect user from git config |
| `suggestion_mode` | `smart` | smart/always/quiet |
| `preference_learning` | `true` | Allow automatic preference learning |

#### Role Types

| Role | Description | Typical Workflows |
|------|-------------|-------------------|
| **Product Owner (PO)** | Strategic decision-maker | new-service, new-domain, lens-switch |
| **Architect/Lead Dev** | Technical leader | solutioning, architecture review |
| **Developer** | Implementation specialist | dev-story, code-review |
| **Power User** | Multi-role contributor | All workflows |

---

### Extension 3: spec (Constitutional Governance)

#### Purpose
Bridges Spec-Kit's specification-driven workflow with BMAD's enterprise-scale orchestration. Provides familiar commands (`/specify`, `/plan`, `/tasks`, `/implement`) that route to BMAD workflows while adding **always-on constitutional governance** via LENS.

**Key Principle:** SPEC does not replace BMAD — it injects context, resolves governance, and delegates execution.

#### Agent

| Agent | Icon | Role | Sidecar |
|-------|------|------|---------|
| **Cornelius (Scribe)** | 📜 | Constitutional Guardian | Yes (`scribe-sidecar`) |

**Cornelius** Persona:
- Constitutional scholar with gravitas but no bureaucratic overhead
- Thinks in precedent, inheritance, and ratification
- Uses constitutional metaphors ("We the engineers...")
- Explains *why* rules exist, not just what they are

**Principles:**
- Governance serves the work, not the other way around
- Every rule must have a rationale
- Contradictions are crises — surface immediately
- Preserve the audit trail

#### Constitution Hierarchy

```
Domain Constitution (enterprise-wide)
    ↓ inherits
Service Constitution (service-specific)
    ↓ inherits
Microservice Constitution (bounded context)
    ↓ inherits
Feature Constitution (implementation discipline)
```

**Inheritance Rules:**
- Inheritance is automatic (child inherits all parent rules)
- Additions are allowed (extend parent rules)
- Contradictions are forbidden (must resolve conflicts)
- Specialization is encouraged (refine for context)

#### Workflows (5 total)

**Native:**
| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `constitution` | CN | Create or amend constitutions |
| `resolve-constitution` | RS | Display accumulated rules for current context |
| `compliance-check` | CC | Validate artifacts against constitution |
| `ancestry` | AN | Show constitution inheritance chain |
| `resolve-context` | — | Internal: resolve context extension variables |

**Command Routing:**
| Command | Routes To |
|---------|-----------|
| `/specify` | `create-prd` |
| `/plan` | `create-architecture` |
| `/tasks` | `create-epics-stories` → `create-story × N` |
| `/implement` | `dev-story` |
| `/review` | `code-review` |

#### Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `constitution_root` | `lens/constitutions` | Constitution storage path |
| `auto_compliance_check` | `true` | Check compliance before workflows |
| `strict_mode` | `false` | Block execution if no constitution |

#### Context Extension

SPEC extends LENS context with constitutional data:

| Variable | Description |
|----------|-------------|
| `resolved_constitution` | Full accumulated constitution text |
| `constitution_chain` | List of constitutions in inheritance chain |
| `constitution_article_count` | Total number of articles |
| `constitution_last_amended` | Last amendment timestamp |
| `constitution_depth` | Number of inheritance levels |

---

### Extension 4: lens-sync (Discovery & Synchronization)

#### Purpose
Provides automated brownfield discovery and bi-directional lens synchronization. **Note: This extension has been merged into the core LENS module.**

#### Current Status

The lens-sync functionality is now part of core LENS:
- Scout agent handles discovery workflows
- Bridge agent handles synchronization workflows
- Link agent handles propagation workflows

The `extensions/lens-sync/` directory contains:
- Minimal module.yaml
- Scout agent stub
- Discover workflow stub

These are retained for backward compatibility but the actual implementation lives in the core module.

#### Key Merged Functionality

| Capability | Now In | Agent |
|------------|--------|-------|
| Target discovery | Core workflows | Scout |
| Analyze codebase | Core workflows | Scout |
| Generate docs | Core workflows | Scout |
| Bootstrap | Core workflows | Bridge |
| Sync status | Core workflows | Bridge |
| Reconcile | Core workflows | Bridge |
| Update lens | Core workflows | Link |
| Validate schema | Core workflows | Link |
| Rollback | Core workflows | Link |

---

## Technical Specifications

### Dependencies

| Dependency | Version | Required | Purpose |
|------------|---------|----------|---------|
| Git | 2.30+ | **Yes** | Clone, status, history, branch operations |
| Node.js | 18+ | **Yes** | Installer execution |
| JIRA API | — | No | Context enrichment |
| GitHub/GitLab API | — | No | PR validation |

### Configuration Schema

```yaml
# module-config.yaml
branch_patterns:
  domain:
    - "main"
    - "develop"
    - "release/*"
    - "hotfix/*"
  service:
    - "service/{name}"
  microservice:
    - "service/{service}/{name}"
  feature:
    - "feature/{service}/{microservice}/{name}"

notification_level: smart  # silent | smart | verbose
session_store: "_bmad/lens/lens-session.yaml"
domain_map: "_bmad/lens/domain-map.yaml"
service_registry: "_bmad/lens/service-registry.yaml"
lens_config: "_bmad/lens/lens-config.yaml"
constitution_root: "_bmad/lens/constitutions"
docs_output_folder: "docs"
```

### Session Store Schema

```yaml
# lens-session.yaml
version: 1
updated_at: "<ISO-8601 timestamp>"
lens: domain | service | microservice | feature
context:
  domain: "<string or null>"
  service: "<string or null>"
  microservice: "<string or null>"
  feature: "<string or null>"
git:
  branch: "<string or null>"
  commit: "<string or null>"
signals:
  paths: ["<path hints>"]
  config_loaded: true | false
summary: "<short summary>"
```

### Domain Map Schema

```yaml
# domain-map.yaml
domains:
  - name: string (required)
    path: string (required, relative)
    service_file: string (optional, defaults to 'service.yaml')

# service.yaml (per domain)
services:
  - name: string (required)
    path: string (required, relative)
    git_repo: string (required for clone operations)
```

---

## Risk Assessment

### Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Git credential failures | Medium | High | Pre-validate credentials in preflight |
| YAML parsing errors | Low | Medium | Schema validation with clear errors |
| Symlink traversal attacks | Low | High | Path resolution with security checks |
| Large repo clone timeouts | Medium | Medium | Progress indicators, resume capability |
| State corruption | Low | High | Event log for recovery, rollback workflow |

### Adoption Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Learning curve | Medium | Medium | Comprehensive getting-started guide |
| Configuration complexity | Medium | Medium | Zero-config defaults |
| Extension conflicts | Low | Medium | Careful namespace isolation |
| Workflow sequence confusion | Medium | Low | Clear workflow guide recommendations |

---

## Implementation Status

### Completed

- [x] **4 Core Agents**: Navigator, Bridge, Scout, Link
- [x] **22 Core Workflows**: All navigation, discovery, sync workflows
- [x] **4 Extensions**: git-lens, lens-compass, spec, lens-sync
- [x] **Module Installer**: Full installation with extension support
- [x] **Documentation**: Getting started, agents, workflows, configuration
- [x] **Session Persistence**: Full session store implementation
- [x] **Sidecar System**: Memory persistence for all agents

### In Progress

- [ ] Update all internal path references (post-merge cleanup)
- [ ] Verify all workflow handoffs work correctly
- [ ] Run full regression test suite
- [ ] Create fixture repository for testing
- [ ] Execute manual installation testing

### Planned

- [ ] Enhanced JIRA integration
- [ ] GitHub/GitLab API integration for PR validation
- [ ] Visual architecture diagramming
- [ ] Distributed team coordination

---

## Appendix A: Complete Workflow Reference

### Navigation Workflows (6)

| Workflow | Agent | Purpose |
|----------|-------|---------|
| `lens-detect` | Navigator | Detect current lens from signals |
| `lens-switch` | Navigator | Switch to different lens level |
| `context-load` | Navigator | Load detailed context for current lens |
| `lens-restore` | Navigator | Restore previous session state |
| `lens-configure` | Navigator | Configure detection patterns |
| `workflow-guide` | Navigator | Recommend workflows based on lens |

### Discovery Workflows (3)

| Workflow | Agent | Purpose |
|----------|-------|---------|
| `discover` | Scout | Full brownfield discovery pipeline |
| `analyze-codebase` | Scout | Deep technical analysis |
| `generate-docs` | Scout | Generate BMAD-ready documentation |

### Synchronization Workflows (6)

| Workflow | Agent | Purpose |
|----------|-------|---------|
| `bootstrap` | Bridge | Bootstrap folder structure from domain map |
| `sync-status` | Bridge | Detect drift between lens and reality |
| `reconcile` | Bridge | Resolve lens/reality conflicts |
| `update-lens` | Link | Propagate documentation changes |
| `validate-schema` | Link | Validate lens data against schemas |
| `rollback` | Link | Revert lens changes safely |

### Advanced Workflows (7)

| Workflow | Agent | Purpose |
|----------|-------|---------|
| `domain-map` | Navigator | View/edit domain architecture |
| `impact-analysis` | Navigator | Analyze cross-boundary impacts |
| `new-service` | Navigator | Create service structure |
| `new-microservice` | Navigator | Create microservice structure |
| `new-feature` | Navigator | Create feature branch + context |
| `lens-sync` | Navigator | Bi-directional synchronization |
| `service-registry` | Navigator | Service registry management |
| `onboarding` | Navigator | User onboarding |

---

## Appendix B: Agent Command Reference

### Navigator Commands

| Command | Trigger | Description |
|---------|---------|-------------|
| Navigate | NAV | Detect current lens and show summary |
| Switch | SW | Switch to another lens level |
| Context Load | CL | Load detailed context for current lens |
| Restore | RS | Restore previous lens session |
| Configure | CFG | Configure detection rules |
| Guide | GUIDE | Recommend next workflow based on lens |
| Domain Map | MAP | View/edit domain architecture |
| Impact | IMP | Analyze cross-boundary impacts |
| New Service | NS | Create service structure |
| New Microservice | NM | Create microservice structure |
| New Feature | NF | Create feature branch + context |
| Bootstrap | BOOT | Bootstrap from domain map |
| Discover | DISC | Run SCOUT discovery |
| Party Mode | PM | Multi-agent collaboration |
| Menu Help | MH | Redisplay menu |
| Chat | CH | Chat with Navigator |
| Dismiss | DA | Dismiss agent |

### Bridge Commands

| Command | Trigger | Description |
|---------|---------|-------------|
| Bootstrap | BS | Bootstrap project structure from lens map |
| Sync Status | SS | Check drift between lens and reality |
| Reconcile | RC | Resolve lens/reality conflicts |

### Scout Commands

| Command | Trigger | Description |
|---------|---------|-------------|
| Discover | DS | Full brownfield discovery pipeline |
| Analyze Codebase | AC | Deep technical analysis |
| Generate Docs | GD | Generate BMAD-ready docs |
| Auto | AUTO | Full pipeline: DS → AC → GD |

### Link Commands

| Command | Trigger | Description |
|---------|---------|-------------|
| Update Lens | UL | Propagate documentation changes |
| Validate Schema | VS | Validate lens data against schemas |
| Rollback | RB | Revert lens changes safely |

---

## Appendix C: Configuration Quick Reference

### Module Prompts

| Prompt | Default | Description |
|--------|---------|-------------|
| `target_project_root` | `{project-root}` | Project to scan and sync |
| `enable_jira_integration` | `false` | JIRA integration |
| `discovery_depth` | `standard` | shallow/standard/deep |
| `docs_output_folder` | `{project-root}/docs` | Generated docs location |
| `lens_data_folder` | `{project-root}/_bmad/lens` | Lens data storage |
| `metadata_output_folder` | `{project-root}/_bmad-output` | BMAD metadata storage |

### Extension Prompts

**git-lens:**
- `base_ref`, `auto_push`, `remote_name`, `fetch_strategy`, `fetch_ttl`
- `commit_strategy`, `validation_cascade`, `pr_api_enabled`
- `compass_enabled`, `compass_roster_file`, `state_folder`, `event_log_enabled`

**lens-compass:**
- `personal_profiles_folder`, `roster_file`, `use_git_identity`
- `suggestion_mode`, `preference_learning`

**spec:**
- `constitution_root`, `auto_compliance_check`, `strict_mode`

---

## Appendix D: Party Mode Adversarial Review

### Review Metadata
- **Review Date:** 2026-02-03
- **Review Method:** Multi-agent adversarial analysis (Party Mode)
- **Reviewers:** 🏗️ Architect, 📋 PM, 🧪 QA, 📝 Tech Writer, 🔍 Adversarial Analyst

### Consolidated Findings Matrix

| Severity | Architect | PM | QA | Tech Writer | Adversarial | Total |
|----------|-----------|-----|-----|-------------|-------------|-------|
| **Critical** | 0 | 2 | 0 | 0 | 1 | **3** |
| **Major** | 5 | 3 | 5 | 4 | 5 | **22** |
| **Minor** | 2 | 2 | 3 | 5 | 5 | **17** |
| **Total** | **7** | **7** | **8** | **9** | **11** | **42** |

### 🚨 CRITICAL FINDINGS

#### Critical Finding 1: git-lens Implementation Status Mismatch
- **Source:** PM Review, Adversarial Analyst
- **Evidence:** [extensions/git-lens/TODO.md](src/modules/lens/extensions/git-lens/TODO.md) shows ALL 15 workflows and 2 agents unchecked (`- [ ]`)
- **Impact:** Product brief incorrectly claims git-lens is "complete"
- **Actual Status:** Specs complete, implementation 0%
- **Resolution:** ⚠️ **Mark git-lens as "Spec Complete, Implementation Pending"**

#### Critical Finding 2: SPEC Phase 2 Not Implemented
- **Source:** PM Review
- **Evidence:** [extensions/spec/TODO.md](src/modules/lens/extensions/spec/TODO.md) Phase 2 shows all command routing unchecked
- **Impact:** Product brief lists `/specify`, `/plan`, `/tasks`, `/implement` as features
- **Actual Status:** Phase 1 (Constitution + LENS Integration) ✅ complete; Phase 2 (Command Router) ❌ not started
- **Resolution:** ⚠️ **Mark SPEC command routing as "Planned (Phase 2)"**

#### Critical Finding 3: Implementation Status Section Contradicts TODO Files
- **Source:** Adversarial Analyst
- **Evidence:** Product brief "Implementation Status: Completed" section conflicts with extension TODO files
- **Resolution:** ⚠️ **Update Implementation Status with accurate per-extension breakdown**

### 🏗️ ARCHITECT Findings

| # | Finding | Severity | Evidence |
|---|---------|----------|----------|
| A1 | Agent files installed to core location, not extension folders | Major | Installer.js copies extension agents to `_bmad/lens/agents/` |
| A2 | Platform-specific installers undocumented | Minor | 4 IDE installers in `platform-specifics/` with no documentation |
| A3 | lens-compass uses core Navigator, no separate agent | Major | module.yaml has no agent definition; extends core Navigator |
| A4 | Sidecar paths incomplete | Minor | Missing `tracey-sidecar`, `scribe-sidecar` in sidecar table |
| A5 | Storyteller sidecar unexplained | Minor | `storyteller-sidecar/` exists but no agent documented |
| A6 | Installation chain undocumented | Major | Multiple installer.js files but no architecture diagram |
| A7 | Extension agent installation pattern unclear | Major | Specs say `_bmad/agents/` but installed to `_bmad/lens/agents/` |

### 📋 PM Findings

| # | Finding | Severity | Evidence |
|---|---------|----------|----------|
| P1 | Role configuration schema missing | Major | lens-compass has no role enumeration in module.yaml |
| P2 | "User corrections logged" metric unmeasurable | Major | No correction-logging workflow exists |
| P3 | User stories missing for SPEC | Minor | No "As a user..." format for governance workflows |
| P4 | Platform support matrix missing | Minor | 4 IDEs supported but no limitation documentation |
| P5 | Duplicate onboarding workflows | Major | Core and lens-compass both have onboarding |

### 🧪 QA Findings

| # | Finding | Severity | Evidence |
|---|---------|----------|----------|
| Q1 | Test fixtures only for git-lens | Major | Only mock-compass.csv exists; no other fixtures |
| Q2 | Event log recovery not tested | Major | Tracey mentions recovery but no test cases |
| Q3 | Cross-extension integration untested | Major | git-lens → lens-compass dependency not validated |
| Q4 | Hook trigger coverage unknown | Minor | 5 hooks but no trigger validation tests |
| Q5 | Constitution templates not validated | Minor | 4 templates exist but no validation workflow |
| Q6 | Empty/malformed config not tested | Minor | Missing edge cases for YAML parsing |
| Q7 | Troubleshooting incomplete | Major | Only 3 categories vs. 10+ risks documented |
| Q8 | Regression fixture missing | Major | TODO.md references fixture not created |

### 📝 TECH WRITER Findings

| # | Finding | Severity | Evidence |
|---|---------|----------|----------|
| T1 | Path inconsistency: `_bmad/lens` vs `src/modules/lens` | Major | Source vs. installed paths mixed throughout |
| T2 | Session store path mismatch | Major | `_bmad/lens/lens-session.yaml` vs `.lens/lens-session.yaml` |
| T3 | Agent ID format inconsistent | Minor | `_bmad/agents/` vs `_bmad/lens/agents/` |
| T4 | docs_output_folder casing inconsistent | Minor | `docs` (lowercase) vs `Docs` (capitalized) |
| T5 | context-extension.md not referenced | Minor | SPEC context variables undocumented in brief |
| T6 | Missing CHANGELOG for core module | Minor | Only SPEC has CHANGELOG.md |
| T7 | Extension docs not inventoried | Minor | lens-compass has 4 doc files not listed |
| T8 | Previous reviews not referenced | Minor | `docs/reviews/` folder exists but not mentioned |
| T9 | Prerequisites.md not referenced | Minor | Detailed prerequisites exist but not in brief |

### 🔍 ADVERSARIAL ANALYST Findings

| # | Finding | Severity | Evidence |
|---|---------|----------|----------|
| X1 | lens-sync folder status ambiguous | Major | Folder exists with files but marked "merged" |
| X2 | Git-less operation undefined | Minor | No graceful degradation documented |
| X3 | Constitution contradiction resolution undefined | Major | "Contradictions forbidden" but no resolution workflow |
| X4 | JIRA integration scope unclear | Minor | No API documentation or permissions listed |
| X5 | "Zero-config first" oversimplified | Minor | 30+ configuration prompts across modules |
| X6 | Rollback scope undefined | Major | No definition of what constitutes "lens change" |
| X7 | Party Mode undocumented | Major | PM command exists but no workflow/docs |
| X8 | Compass integration assumption | Minor | git-lens assumes lens-compass always installed |
| X9 | Scribe sidecar location | Minor | SPEC extension Scribe needs `scribe-sidecar` |
| X10 | Hook behavior specification incomplete | Minor | Hooks only have stub markdown files |

### Accurate Implementation Status (Corrected)

| Component | Status | Evidence |
|-----------|--------|----------|
| **Core LENS Module** | ✅ Complete | TODO.md shows all items checked |
| **Navigator Agent** | ✅ Built | navigator.agent.yaml exists |
| **Bridge Agent** | ✅ Built | bridge/bridge.agent.yaml exists |
| **Scout Agent** | ✅ Built | scout/scout.agent.yaml exists |
| **Link Agent** | ✅ Built | link/link.agent.yaml exists |
| **22 Core Workflows** | ✅ Built | All workflow directories populated |
| **git-lens Extension** | ⚠️ Specs Only | TODO.md: 0/15 workflows, 0/2 agents |
| **lens-compass Extension** | ✅ Complete | TODO.md: 9/9 workflows, 1/1 agent |
| **spec Extension (Phase 1)** | ✅ Complete | TODO.md: 4/4 workflows, 1/1 agent |
| **spec Extension (Phase 2)** | ❌ Not Started | TODO.md: 0/6 command routers |
| **lens-sync Extension** | ⚠️ Deprecated | Merged into core; stub folder remains |

### Missing Documentation Items

1. **context-extension.md** — SPEC context variable schema (143 lines not in brief)
2. **prerequisites.md** — Environment setup checklist (not referenced)
3. **constitution-templates/** — 4 templates exist (domain, service, microservice, feature)
4. **Previous reviews** — `docs/reviews/` contains 2 review artifacts
5. **Hook specifications** — 5 hook files with minimal documentation
6. **Platform installers** — 4 IDE-specific installer behaviors

### Recommended Priority Actions

#### Priority 1: Accuracy Corrections (Before Rewrite)
1. ✏️ Update git-lens status to "Spec Complete, Implementation Pending"
2. ✏️ Update SPEC status to show Phase 1 complete, Phase 2 pending
3. ✏️ Add accurate Implementation Status breakdown table
4. ✏️ Clarify lens-sync folder as "deprecated backward-compat stub"

#### Priority 2: Missing Architecture Documentation
5. ➕ Add Installation Architecture section with installer chain
6. ➕ Add complete sidecar path table (6 sidecars total)
7. ➕ Document agent installation pattern (extension → core location)
8. ➕ Add platform-specific installer documentation

#### Priority 3: Path Standardization
9. ✏️ Standardize session_store path
10. ✏️ Standardize docs_output_folder casing
11. ✏️ Standardize agent ID format

#### Priority 4: Missing Documentation References
12. ➕ Add context-extension.md content to SPEC section
13. ➕ Add prerequisites.md reference
14. ➕ Add constitution templates inventory
15. ➕ Reference previous review artifacts

#### Priority 5: Clarifications Needed
16. ➕ Document Party Mode (or mark as Planned)
17. ➕ Define constitution contradiction resolution
18. ➕ Define rollback scope and snapshot format
19. ➕ Document extension dependencies

---

*Product Brief Generated: 2026-02-03*
*Document Version: 1.1*
*Status: Reviewed — Accuracy Corrections Required Before Rewrite*
*Last Review: 2026-02-03 (Party Mode Adversarial)*
