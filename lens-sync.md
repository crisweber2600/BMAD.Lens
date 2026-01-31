````markdown
# Module Brief: LENS Sync & Discovery

```yaml
title: "Module Brief: LENS Sync & Discovery"
module_code: lens
extension_code: lens-sync
module_type: extension
extends: lens
version: 1.0.0
created: 2026-01-30
status: production
````

---

## Executive Summary

**LENS: Sync & Discovery** is a BMAD extension module that bridges the gap between architectural knowledge (what LENS knows) and physical reality (what actually exists in repositories and folders). It transforms legacy brownfield microservices into BMAD-ready projects through automated discovery, intelligent documentation generation, and bi-directional synchronization between the LENS domain map and actual project structure.

---

## The Core Problem

Modern enterprise development teams face:

* **Context Switching Overhead**: 20–30 minutes loading context when switching between services
* **Architectural Drift**: Documentation becomes stale as reality diverges from design
* **Brownfield Blindness**: Legacy services become black boxes that developers fear changing
* **Onboarding Friction**: New team members take weeks to understand the landscape
* **Lost Business Context**: The “why” behind features gets lost as teams rotate

---

## The Solution

LENS-Sync provides three specialized agents that work together to keep your architectural model and physical codebase in perfect alignment:

| Agent         | Role                 | Key Capability                                                   |
| ------------- | -------------------- | ---------------------------------------------------------------- |
| 🧱 **Bridge** | The Synchronizer     | Bootstrap environments, sync folder structures with domain map   |
| 🔍 **Scout**  | Discovery Specialist | Analyze brownfield code, extract business context, generate docs |
| 🔗 **Link**   | Lens Guardian        | Maintain lens data integrity, propagate changes hierarchically   |

---

## Module Identity

### Classification

* **Base Module Code**: `lens`
* **Extension Folder**: `lens-sync` (under `src/modules/lens/extensions/`)
* **Global Scope**: No (project-specific)
* **Default Selected**: No (opt-in for teams that need sync capabilities)

---

## Purpose Statement

> Bridge architectural knowledge with physical reality through automated synchronization and intelligent brownfield discovery for BMAD-ready microservices.

---

## Value Proposition

Transform any existing microservice into a BMAD-ready state in under an hour.
Eliminate environment setup friction.
Keep architectural truth in sync with reality.
Never be blindsided by undocumented legacy code again.

---

## User Scenarios

### Target Users

* Platform/Enablement teams managing multi-service estates
* Architects and tech leads responsible for domain integrity
* Developers onboarding to legacy services
* Documentation and governance owners

### Primary Use Case

Bootstrapping a brownfield microservice into a BMAD-ready, fully documented, and synchronized state within a single work session.

### User Journey

1. Run `Bridge, bootstrap` to align folder structure with the lens domain map.
2. Run `Scout, discover` to extract architecture, APIs, data models, and business context.
3. Run `Link, update-lens` to propagate documentation changes up the hierarchy.
4. Re-run `Bridge, sync-status` to verify ongoing alignment.

---

## Agents

### 1. Bridge Agent — The Synchronizer 🧱

**Persona**
Structural engineer personality who thinks in terms of foundations, load-bearing structures, and solid construction.

**Responsibilities**

* Bootstrap new development environments
* Synchronize folder structures with lens domain map
* Clone repositories into correct domain/service/microservice hierarchy
* Detect and report drift between lens and reality
* Resolve conflicts between architectural model and physical structure

**Communication Style**

Uses construction metaphors —
“Building connections…”,
“Bridge complete. You can cross safely now.”,
“Some gaps to fill, let’s build together.”

**Core Workflows**

* `bootstrap` — Sync TargetProject folder structure with lens domain map
* `sync-status` — Check drift between lens and reality
* `reconcile` — Resolve lens/reality conflicts

**Sidecar Memory**

```
.bmad/_memory/lens-sync/bridge-state.md
```

---

### 2. Scout Agent — The Discovery Specialist 🔍

**Persona**
Detective / archaeologist personality who reveals hidden knowledge through investigative analysis.

**Responsibilities**

* Analyze brownfield microservices through codebase examination
* Parse git history for JIRA keys and business context
* Discover architecture patterns, tech stacks, API surfaces
* Generate BMAD-ready documentation from code analysis
* Integrate with JIRA to understand the “why” behind features

**Communication Style**

Narrates discoveries like uncovering treasure —
“Let’s see what secrets this codebase holds…”,
“The git logs tell a story. Listen…”,
“Fascinating! Look what I found…”

**Core Workflows**

* `discover` — Full brownfield discovery and documentation pipeline
* `analyze-codebase` — Deep technical analysis of existing code
* `generate-docs` — Create BMAD-ready documentation from findings

**Sidecar Memory**

```
.bmad/_memory/lens-sync/scout-discoveries.md
```

Tracks:

* discovered_microservices
* jira_keys_found
* analysis_results

---

### 3. Link Agent — The Lens Guardian 🔗

**Persona**
Librarian / curator who maintains the integrity and organization of lens knowledge.

**Responsibilities**

* Validate lens data against schemas
* Propagate documentation changes hierarchically (microservice → service → domain)
* Auto-shard large aggregated documents (>500 lines)
* Maintain traceability between layers
* Backup and rollback lens data
* Detect changes using git diffs

**Communication Style**

Precise, methodical, and protective of data integrity —
“Validating schema…”,
“Propagating changes upward…”,
“Sharding large document for clarity.”

---

## Workflows

### Core Workflows

#### 1. Bootstrap Workflow (Bridge)

**Purpose**
Set up development environment from scratch based on lens domain map.

**Flow**

1. Load lens domain map (`domain-map.yaml`)
2. Scan TargetProject folder structure
3. Compare lens model vs. physical structure
4. Show gap analysis (missing repos, misaligned folders)
5. Execute sync with user approval

   * Create folder hierarchy (Domain / Service / Microservice)
   * Clone repositories from `git_repo` URLs in `service.yaml`
   * Report sync status
6. Validate sync completion

**Impact**
Environment setup from hours to minutes.

**Invocation**

```
> Bridge, bootstrap
```

or

```
/bootstrap
```

---

#### 2. Discover Workflow (Scout)

**Purpose**
Transform brownfield microservices into BMAD-ready documented projects.

**Flow**

1. Select target (domain / service / microservice) from lens
2. Clone / locate repository
3. Extract JIRA keys from git history
4. Fetch JIRA context (if MCP available)
5. Analyze codebase:

   * Tech stack detection
   * Architecture pattern identification
   * API surface mapping
   * Data layer discovery
   * Integration dependencies
   * Key business logic extraction
6. Generate docs:

   * `architecture.md` — System design and patterns
   * `api-surface.md` — Endpoints, contracts, protocols
   * `data-model.md` — Entities, schemas, storage
   * `integration-map.md` — Dependencies and connections
   * `onboarding.md` — Developer quick-start guide
7. Update lens metadata
8. Complete session with report

**Impact**
Any microservice becomes BMAD-ready in under an hour.

**Invocation**

```
> Scout, discover
```

or

```
/discover
```

---

#### 3. Sync Status Workflow (Bridge)

**Purpose**
Check alignment between lens and physical reality.

**Flow**

1. Load lens domain map
2. Scan TargetProject folders
3. Compare structures
4. Report:

   * ✅ Synced services
   * ⚠️ Drift detected (lens ≠ reality)
   * ❌ Conflicts (contradictions)
5. Offer reconciliation if needed

**Invocation**

```
> Bridge, sync-status
```

or

```
/sync-status
```

---

#### 4. Reconcile Workflow (Bridge)

**Purpose**
Resolve conflicts between lens and reality.

**Flow**

1. Detect conflicts from sync-status
2. Present resolution options:

   * Update lens to match reality
   * Update reality to match lens
   * Manual conflict resolution
3. Execute user choice
4. Validate resolution

**Invocation**

```
> Bridge, reconcile
```

or

```
/reconcile
```

---

#### 5. Update Lens Workflow (Link)

**Purpose**
Propagate documentation changes hierarchically with auto-sharding.

**Flow**

1. Identify changed microservices
2. Aggregate microservice docs into service-level summaries
3. Check document size thresholds
4. Auto-shard if >500 lines:

   * Split on level-2 headings (`##`)
   * Create section files in subfolder
   * Generate index file with navigation
   * Archive original large file
5. Propagate to domain level
6. Repeat sharding if needed
7. Update lens metadata

**Invocation**

```
> Link, update-lens
```

or

```
/update-lens
```

---

#### 6. Analyze Codebase Workflow (Scout)

**Purpose**
Deep technical analysis of existing codebase without full discovery.

---

#### 7. Generate Docs Workflow (Scout)

**Purpose**
Generate documentation from analysis findings.

**Invocation**

```
> Scout, generate-docs
```

or

```
/generate-docs
```

---

#### 8. Validate Schema Workflow (Link)

**Purpose**
Ensure lens data conforms to expected schemas.

**Invocation**

```
> Link, validate-schema
```

or

```
/validate-schema
```

---

#### 9. Rollback Workflow (Link)

**Purpose**
Revert lens changes safely to previous state.

**Invocation**

```
> Link, rollback
```

or

```
/rollback
```

---

## Integration Points

### 1. Extends: LENS Base Module

Inherits all LENS capabilities:

* Domain / Service / Microservice / Feature navigation
* Context detection from git branch and working directory
* Lens data access and manipulation
* Session continuity

---

### 2. Integrates: BMM Document-Project Workflow

Scout’s `discover` workflow leverages BMM’s `document-project` for comprehensive documentation generation, passing analysis results as context.

---

### 3. MCP Tool Requirements

* **Git**: Clone repositories, parse commit logs, branch operations
* **JIRA**: Fetch issue context from commit references (optional)
* **Filesystem**: Folder creation, file operations

---

## Directory Structure

```
src/modules/lens/extensions/lens-sync/
├─ module.yaml
├─ module-config.yaml
├─ README.md
├─ TODO.md
├─ _module-installer/
│  ├─ installer.js
│  └─ README.md
├─ agents/
│  ├─ bridge.agent.yaml
│  ├─ scout.agent.yaml
│  └─ link.agent.yaml
├─ workflows/
│  ├─ shared/
│  ├─ bootstrap/
│  ├─ discover/
│  ├─ sync-status/
│  ├─ reconcile/
│  ├─ analyze-codebase/
│  ├─ generate-docs/
│  ├─ update-lens/
│  ├─ validate-schema/
│  └─ rollback/
├─ data/
│  └─ discovery-templates/
└─ docs/
```

---

## Key Innovations

### Hierarchical Document Propagation with Auto-Sharding

* Detects changes at microservice level using git diffs
* Aggregates content across services
* Auto-shards documents exceeding 500 lines
* Maintains traceability and preserves manual edits

---

## Usage Examples

### Example 1: New Team Member Joins

```
> Bridge, bootstrap
```

**Impact**
From zero to productive in under 5 minutes.

---

### Example 2: Legacy Microservice Needs Documentation

```
> Scout, discover
```

**Impact**
Complete BMAD-ready documentation in ~45 minutes.

---

### Example 3: Documentation Propagation After Change

```
> Link, update-lens
```

**Impact**
Docs stay synchronized across microservice, service, and domain layers.

---

## Success Metrics

### Quantitative

* Environment setup: Hours → Minutes
* Discovery: Days → <1 Hour
* Documentation staleness: Weeks → Real-time
* Onboarding: Weeks → Days

### Qualitative

* Developer confidence
* Architectural alignment
* Context availability
* Team autonomy

---

## Dependencies

### Required BMAD Modules

* `lens` — Domain map, navigation, context detection

### Optional Integrations

* `bmm` — Document-project workflow

---

## External MCP Tools

* **Git** (required)
* **JIRA** (optional)
* **Filesystem** (required)

---

## Creative Features

### Personality & Theming

* Bridge speaks in construction metaphors to reinforce structure and safety.
* Scout narrates discoveries like a detective uncovering evidence.
* Link maintains librarian-like precision with an emphasis on integrity.

### Easter Eggs & Delighters

* “Bridge complete” success banner after successful bootstrap.
* “Found artifacts” highlight when Scout extracts key legacy patterns.
* “Knowledge preserved” badge when Link finishes propagation and sharding.

### Module Lore

LENS Sync is the “living map” layer — a curator that keeps architectural truth and code reality aligned as systems evolve.

---

## Next Steps

1. Align extension configuration to base module `lens` and use folder `lens-sync`.
2. Run Create mode to generate module scaffolding and specs.
3. Build agent specs for Bridge, Scout, and Link.
4. Build workflow specs for the nine workflows listed.
5. Generate README, TODO, and docs/ content from this brief.
6. Re-run validation after scaffolding is complete.

---

## Future Enhancements

1. Real-time drift detection
2. Multi-repository discovery
3. Dependency graph generation
4. AI-powered architecture suggestions
5. Historical analysis
6. Automated testing recommendations

---

## Conclusion

**LENS: Sync & Discovery** closes the gap between architectural intent and real code.
It enables teams to bootstrap faster, understand legacy systems deeply, keep documentation current, and work with confidence — automatically.

---

**Framework**: BMAD Method
**Documentation**: `src/modules/lens/extensions/lens-sync/README.md`
**Installation**:

```
node src/modules/lens/extensions/lens-sync/_module-installer/installer.js
```

```
```
