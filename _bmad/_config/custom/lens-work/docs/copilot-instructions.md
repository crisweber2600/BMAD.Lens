# Copilot Instructions — BMAD Control Repos with LENS Workbench

This document provides comprehensive guidance for using Copilot in BMAD control repositories that leverage the LENS Workbench module.

---

## 👥 Audience & Prerequisites

**Who should read this?**

This guide is written for:
- **BMAD newcomers** — New to the framework, want to understand the big picture
- **Control repo maintainers** — Setting up or managing a BMAD control repo
- **Feature developers** — Building code within a BMAD-orchestrated initiative
- **Copilot users** — Want to work effectively with Copilot Chat agents in BMAD repos

**What prior knowledge is helpful?**

- **None required** — This guide is self-contained
- **Helpful but optional:**
  - Understanding of git workflows (branches, commits, PRs)
  - Familiarity with CI/CD and lifecycle phases (planning → implementation)
  - Basic knowledge of markdown and YAML formats

**How to use this guide:**

1. **Quick start:** Read "LENS Workbench Commands" and "Using Copilot Effectively" sections
2. **Deep dive:** Work through "Repository Architecture" and "File Conventions" for full context
3. **Reference:** Jump to specific sections as needed when questions arise

---

## Repository Architecture

A BMAD control repo orchestrates planning, discovery, and lifecycle management for multiple target projects using the BMAD Method v6 framework. The control repo dogfoods its own tooling through the lens-work module.

**Typical structure:**

```
{control-repo-name}/
├── _bmad/                    ← BMAD framework: modules, agents, workflows
│   ├── _config/              ← Installation manifest, agent/workflow/file manifests
│   ├── _memory/              ← Agent memory (tech-writer sidecar, storyteller, etc.)
│   ├── core/                 ← Core platform (bmad-master, tasks, resources)
│   ├── bmm/                  ← BMAD Method Module (planning → implementation)
│   ├── bmb/                  ← BMAD Builder Module (create agents, modules)
│   ├── cis/                  ← Creative Intelligence Suite
│   ├── gds/                  ← Game Dev Studio
│   ├── tea/                  ← Test Engineering Academy
│   └── lens-work/            ← LENS Workbench (INSTALLED from source)
├── _bmad-output/             ← Runtime state, logs, planning artifacts
├── .github/agents/           ← Copilot Chat agent stubs
├── .github/prompts/          ← Reusable prompt files
├── TargetProjects/           ← Cloned repos managed by lens-work
│   ├── {DOMAIN}/{SERVICE}/   ← Domain-organized projects
│   └── ...
└── docs/                     ← Discovery scans and documentation
```

## Critical Operating Rules

### Control-Plane Separation

**All BMAD commands execute from the control repo root.** Never `cd` into TargetProjects repos to run BMAD operations. Repository operations use programmatic paths from `_bmad/lens-work/service-map.yaml`.

**Commands originate from:** The control repo's `_bmad-output/lens-work/` context.
**Operations affect:** Target repos listed in service-map.yaml, but are orchestrated from the control plane.

### Dogfooding Discipline

The `lens-work` module follows a strict dogfooding pattern:

1. **Source:** `TargetProjects/{DOMAIN}/{SERVICE}/BMAD.{MODULE}/src/modules/lens-work/`
2. **Installed copy:** `_bmad/lens-work/` (DO NOT edit directly)
3. **Changes flow:** Through **module-builder agent** in the source repo
4. **Reinstall:** After source changes, run installer to sync into control repo

**Never edit the installed copy directly** — changes will be overwritten on reinstall.

## BMAD Agent System

Agents are persona-driven AI assistants with command menus, custom behaviors, and contextual expertise.

### Agent Activation Pattern

GitHub Copilot Chat agent stubs in `.github/agents/` use this pattern:

```markdown
---
name: '{agent-name}'
disable-model-invocation: true
---
<agent-activation CRITICAL="TRUE">
1. LOAD the FULL agent file from {project-root}/_bmad/{module}/agents/{agent}.md
2. READ its entire contents
3. FOLLOW every step in the <activation> section precisely
</agent-activation>
```

Agent definition files are loaded **at runtime, never pre-loaded**. This enables:
- Dynamic context resolution
- Lazy loading of resources from manifests
- Per-session customization via `_config/agents/{module}-{agent}.customize.yaml`

### Key Agents by Module

**Core Platform:**
- `bmad-master` — Master executor, runtime resource management

**BMAD Method Module (bmm):**
- `analyst` — Research and discovery
- `architect` — Solution design
- `pm` — Program management
- `dev` — Feature development
- `sm` — Scrum/sprint master
- `quinn` — QA and testing
- `quick-flow-solo-dev` — Single-person workflow acceleration
- `tech-writer` — Documentation specialist
- `ux-designer` — User experience design

**BMAD Builder Module (bmb):**
- `agent-builder` — Create new agents
- `module-builder` — Create/edit BMAD modules
- `workflow-builder` — Create/edit workflows

**LENS Workbench (v2.0.0 — Lifecycle Contract):**
- `compass` — Phase router for `/preplan`, `/spec`, `/techplan`, `/plan`, `/review`, `/dev`
- `casey` — Git branch orchestration
- `tracey` — State management and recovery
- `scout` — Bootstrap and discovery
- `scribe` — Constitutional governance guardian

## BMAD Lifecycle Phases (v2 — Lifecycle Contract)

The planning-to-implementation lifecycle uses named phases with agent ownership and audience-based promotion gates:

### Phases (within small audience)

| Phase | Agent | Description |
|-------|-------|-------------|
| **PrePlan** | Mary (Analyst) | Brainstorm, research, product brief |
| **BusinessPlan** | John (PM) + Sally (UX) | PRD creation, UX design |
| **TechPlan** | Winston (Architect) | Architecture document, technical decisions |

### Promotion Gates

| Gate | From → To | Type |
|------|-----------|------|
| Adversarial Review | small → medium | Party mode multi-agent review |
| Stakeholder Approval | medium → large | Stakeholder sign-off |
| Constitution Gate | large → base | Scribe validates governance |

### Post-Promotion Phases

| Phase | Agent | Audience | Description |
|-------|-------|----------|-------------|
| **DevProposal** | John (PM) | medium | Epics, stories, readiness check |
| **SprintPlan** | Bob (SM) | large | Sprint planning, story files |
| **Dev** | Amelia (Dev) + Quinn (QA) | TargetProjects | Implementation loop |

### Initiative Tracks

| Track | Phases | Use Case |
|-------|--------|----------|
| full | All phases | Complete lifecycle |
| feature | BusinessPlan → Dev | Known business context |
| tech-change | TechPlan → Dev | Pure technical change |
| hotfix | TechPlan only | Urgent fix, fast to execution |
| spike | PrePlan only | Research only, no implementation |

**Artifacts flow to:** `_bmad-output/lens-work/initiatives/`

## LENS Workbench Commands

### Phase Router Commands (via Compass)

LENS Workbench v2 provides guided phase navigation through Compass using named phases:

| Command | Phase | Agent | Audience | Function |
|---------|-------|-------|----------|----------|
| `/preplan` | PrePlan | Mary | small | Analysis — brainstorm, research, product brief |
| `/spec` | BusinessPlan | John + Sally | small | Business planning — PRD, UX design |
| `/techplan` | TechPlan | Winston | small | Technical design — architecture document |
| `/plan` | DevProposal | John | medium | Solutioning — epics, stories, readiness |
| `/review` | SprintPlan | Bob | large | Sprint planning — sprint status, story files |
| `/dev` | Dev | Amelia + Quinn | target | Implementation loop |

### Initiative Commands

Create and manage initiatives:

| Command | Function |
|---------|----------|
| `/new-domain` | Create domain-scoped initiative |
| `/new-service` | Create service within domain |
| `/new-feature` | Create feature initiative |
| `/fix-story` | Create hotfix or bug story |
| `/migrate` | Migrate v1 initiatives to v2 lifecycle |

### Supporting Files

Command guidance and templates:
- Location: `.github/prompts/`
- Format: `lens-work.{command}.prompt.md`
- Updated by: lens-work module installer

## File and Resource Conventions

### Agent Definitions
- Format: Markdown (`.md`) with YAML frontmatter or `.agent.yaml` files
- Location: `_bmad/{module}/agents/`
- Customization: `_bmad/_config/agents/{module}-{agent}.customize.yaml`

### Workflows
- Format: Markdown (`.md` with step guidance) or YAML (`.yaml` structured config)
- Location: `_bmad/{module}/workflows/`
- Pattern: Lazy load from manifests at runtime

### Manifests
- Format: CSV for flat registries
- Files: `agent-manifest.csv`, `workflow-manifest.csv`, `files-manifest.csv`, `task-manifest.csv`, `tool-manifest.csv`
- Location: `_bmad/_config/`
- Use: Fast lookup, dependency validation, installation

### Runtime State (LENS Workbench)
- Location: `_bmad-output/lens-work/`
- Files:
  - `state.yaml` — Current initiative, phase, size, gate status
  - `event-log.jsonl` — Append-only audit trail
- Management: Read by Tracey (state manager), written by all workflows

### Module Configuration
- Format: YAML
- Location: `_bmad/{module}/config.yaml`
- Content: User settings, output paths, language, features

### Path Tokens
- Format: `{project-root}` for absolute paths in configs and files
- Resolution: At runtime by the BMAD framework
- Use: Enable cross-platform, portable configurations

## Key Architectural Patterns

### Lazy Loading
- Agents, workflows, and resources are loaded **at runtime, not pre-loaded**
- Enables dynamic context resolution and per-session customization
- Improves startup performance and flexibility

### Numbered Menus
- All agent interactions present **numbered option lists** for user selection
- Supports fuzzy matching and command abbreviations
- Consistent UX across all agents

### CSV Registries
- `_config/*.csv` files are the **authoritative index** of agents, workflows, tasks, and files
- Used by installer, manifest validation, and dependency checks
- Single source of truth for system composition

### Module Independence
- Each module (`bmm`, `bmb`, `cis`, `tea`, `gds`, `lens-work`) is **self-contained**
- Own `config.yaml`, `agents/`, `workflows/`, `data/`, `teams/` directories
- Can be installed, updated, or removed independently

### Custom Layer
- User overrides: `_bmad/_config/custom/`
- Agent customization: `_bmad/_config/agents/*.customize.yaml`
- Extends behavior without modifying source, enabling clean upgrades

## Working with Target Projects

### Service Map

The `_bmad/lens-work/service-map.yaml` maintains the canonical registry of target repos:

```yaml
domains:
  {DOMAIN}:
    services:
      {SERVICE}:
        repos:
          - name: {REPO_NAME}
            path: TargetProjects/{DOMAIN}/{SERVICE}/{REPO_NAME}
            type: application|framework|module
```

Each repo operation is programmatically resolved using this map.

### Repository Organization

**Recommended structure:**

```
TargetProjects/
├── {DOMAIN_1}/
│   ├── {SERVICE_A}/
│   │   ├── app-name/
│   │   └── BMAD.module-name/  (if module source)
│   └── {SERVICE_B}/
└── {DOMAIN_2}/
    └── {SERVICE}/
```

Enables:
- Domain-scoped initiatives via lens-work
- Service-oriented organization
- Clear ownership and boundaries
- Multi-tenant planning discipline

### Documentation Output

Generated canonical documentation:
- **Source:** Discovery scans from target repos
- **Processing:** By Scout (discovery agent)
- **Output location:** `_bmad-output/lens-work/docs/`
- **Sync location:** `docs/lens-sync/` (reference copies)

Discovery docs:
- Location: `docs/discovery/`
- Content: Deep scans of repo structure, dependencies, architecture
- Owned by: Scout agent, manual updates

## LENS Workbench Git Discipline

The LENS Workbench enforces strict git-based workflow control:

### Branch Topology (v2 — Named Phases)

Branches mirror the lifecycle contract's named phases and audience levels:

**Domain-layer (single branch):**
```
main
└── {domain_prefix}                                        ← Domain organizational branch
```

**Service-layer (single branch):**
```
main
└── {domain_prefix}-{service_prefix}                       ← Service organizational branch
```

**Initiative layers (full topology with named phases):**
```
main
└── {initiative_root}                                      ← Initiative root
    ├── {initiative_root}-small                             ← Small audience (IC creation)
    │   ├── {initiative_root}-small-preplan                 ← PrePlan phase
    │   ├── {initiative_root}-small-businessplan            ← BusinessPlan phase
    │   └── {initiative_root}-small-techplan                ← TechPlan phase
    ├── {initiative_root}-medium                            ← Medium audience (lead review)
    │   └── {initiative_root}-medium-devproposal            ← DevProposal phase
    └── {initiative_root}-large                             ← Large audience (stakeholder)
        └── {initiative_root}-large-sprintplan              ← SprintPlan phase
```

**Promotion PRs (audience gates):**
```
{initiative_root}-small     → PR → {initiative_root}-medium   (adversarial review)
{initiative_root}-medium    → PR → {initiative_root}-large    (stakeholder approval)
{initiative_root}-large     → PR → base                       (constitution gate)
```

All branches use flat hyphen-separated naming (no `/` separators). All branches pushed to remote immediately on creation.

**Design principle:** The entire project lifecycle can be reconstructed from `git log` alone.

### Workflow Git Discipline

All lens-work workflows enforce:

1. **Start:** Verify clean state → checkout correct branch → pull latest
2. **End:** Stage changes → create targeted commit → push to origin

Example commit message:
```
{type}({initiative_id}): description of changes
```

## Using Copilot Effectively in BMAD Repos

### When to Ask Copilot

✅ **DO ask for:**
- BMAD architecture explanations
- Agent behavior clarification
- Workflow routing decisions
- File location and structure questions
- Module installation troubleshooting
- Git workflow discipline questions

❌ **DON'T ask for:**
- Edits to the installed `_bmad/` copy (route through module-builder instead)
- Target project operations (use lens-work agents from control repo)
- Removing or modifying manifests without understanding implications

### Effective Prompts

**Bad:** "How do I edit lens-work?"
**Good:** "I need to add a new workflow to lens-work. Should I edit the source in BMAD.Lens and then reinstall, or edit directly in _bmad/lens-work/?"

**Bad:** "Create a new feature in chatting."
**Good:** "I want to start a new feature initiative for real-time messaging in the chat service. Which Compass command should I use?"

### Copilot Agent Collaboration

Copilot works alongside BMAD agents:

- **You (Copilot):** Technical architecture, code explanations, refactoring
- **Compass:** Phase routing, workflow sequencing, initiative flow
- **Casey:** Git operations, branch orchestration, merge strategies
- **Scout:** Discovery, documentation, repo inventory
- **Tracey:** State recovery, audit trail analysis, gate progression

## Next Steps

To get started with a BMAD control repo using LENS Workbench:

1. **Load Compass agent:** `@compass` in GitHub Copilot Chat
2. **Run preflight:** `/preplan` to bootstrap and discover repos
3. **Start first initiative:** `/new-feature` or `/new-domain` via Compass
4. **Follow phase routing:** `/spec` → `/techplan` → `/plan` → `/review` → `/dev`
5. **Migrate existing initiatives:** `/migrate` to upgrade v1 initiatives to v2 lifecycle

For questions about specific agents or workflows, ask Copilot directly with context about what you're trying to accomplish.
