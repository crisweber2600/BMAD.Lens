---
stepsCompleted: [step-01-init, step-02-context, step-03-starter, step-04-decisions, step-05-patterns, step-06-structure, step-07-validation, step-08-complete]
inputDocuments:
  - docs/lens/lens-work/feature/upgrade/product-brief.md
  - docs/lens/lens-work/feature/upgrade/prd.md
  - _bmad-output/brainstorming/brainstorming-session-2026-02-23.md
  - _bmad-output/brainstorming/lifecycle.yaml
  - _bmad/_config/custom/lens-work/lifecycle.yaml
  - _bmad/_config/custom/lens-work/module.yaml
  - _bmad/_config/custom/lens-work/skills/*.md
  - _bmad/_config/custom/lens-work/templates/*.yaml
  - _bmad-output/lens-work/constitutions/domain/lens/constitution.md
workflowType: 'architecture'
initiative: upgrade-cjki9q
initiative_name: "Lens-Work Module Architecture Upgrade"
domain: Lens
service: lens-work
phase: techplan
agent: Winston (Architect)
classification:
  projectType: developer_tool
  domain: developer-tooling
  complexity: medium
  projectContext: brownfield
---

# Architecture Document — Lens-Work Module Architecture Upgrade

**Author:** Winston (Architect)
**Date:** 2026-02-25
**Initiative:** upgrade-cjki9q
**Phase:** TechPlan

---

## 1. Executive Architecture Summary

The lens-work module upgrade transforms a loosely-coupled collection of phase scripts into a structurally-enforced lifecycle engine. The architecture is **entirely file-based** — no runtime server, no database, no API. All orchestration is mediated through YAML configuration, Markdown workflows, Git CLI operations, and the AI agent execution environment (VS Code + GitHub Copilot Chat).

### Core Architectural Insight

The system operates as a **state machine with git-backed persistence**. Every state transition (phase start, phase complete, audience promotion) corresponds to a git operation (branch creation, PR merge, branch merge). The git repository *is* the state store — `state.yaml` and `event-log.jsonl` are convenience caches that can be reconstructed from git history.

### Architecture Type

**Event-driven agent orchestration framework** with:
- **File-based state machine** — YAML state files + JSONL event log
- **Git-backed persistence** — branch topology encodes lifecycle position
- **Constitution-governed gates** — additive inheritance validates at every transition
- **Two-repo separation** — planning artifacts (BMAD.Lens) vs. executable code (TargetProjects)

---

## 2. System Context

### 2.1 System Boundary

```
┌──────────────────────────────────────────────────────────────┐
│                    BMAD.Lens Repository                       │
│                   (Planning & Governance)                     │
│                                                              │
│  ┌──────────┐   ┌──────────┐   ┌──────────────────────┐     │
│  │ _bmad/   │   │ _bmad-   │   │ Docs/                │     │
│  │ config/  │   │ output/  │   │ {domain}/{service}/  │     │
│  │          │   │ lens-    │   │ feature/{feature}/   │     │
│  │ modules  │   │ work/    │   │                      │     │
│  │ agents   │   │          │   │ product-brief.md     │     │
│  │ workflows│   │ state    │   │ prd.md               │     │
│  │ skills   │   │ events   │   │ architecture.md      │     │
│  │ lifecycle│   │ constit. │   │ tech-decisions.md    │     │
│  └──────────┘   └──────────┘   └──────────────────────┘     │
│                                                              │
│                  ┌───────────────────────┐                   │
│                  │   @lens Agent         │                   │
│                  │   (Compass router)    │                   │
│                  │                       │                   │
│                  │  Skills:              │                   │
│                  │  - git-orchestration  │                   │
│                  │  - state-management   │                   │
│                  │  - discovery          │                   │
│                  │  - constitution       │                   │
│                  │  - checklist          │                   │
│                  └───────────┬───────────┘                   │
│                              │ delegates                     │
│                  ┌───────────▼───────────┐                   │
│                  │  BMM Phase Agents     │                   │
│                  │  Mary, John, Winston  │                   │
│                  │  Bob, Sally, Quinn    │                   │
│                  └───────────────────────┘                   │
└──────────────────────┬───────────────────────────────────────┘
                       │ planning-context.yaml
                       │ (cross-repo handoff)
┌──────────────────────▼───────────────────────────────────────┐
│               TargetProjects Repository                      │
│                  (Code Execution)                             │
│                                                              │
│  ┌──────────────────────────────────────────────┐            │
│  │  GitFlow Branches                            │            │
│  │  feature/{story} → feature/{epic}            │            │
│  │  → develop → release/{ver} → main            │            │
│  │                                              │            │
│  │  .planning-context.yaml                      │            │
│  │  (links back to BMAD.Lens planning)          │            │
│  └──────────────────────────────────────────────┘            │
│                                                              │
│  Agents: Amelia (Dev), Quinn (QA)                            │
└──────────────────────────────────────────────────────────────┘
```

### 2.2 External Dependencies

| Dependency | Type | Interface | Risk |
|------------|------|-----------|------|
| Git CLI | Runtime | Shell commands via terminal | Low — ubiquitous |
| GitHub API (MCP) | Optional | PR creation, merge, status | Medium — rate limits |
| VS Code | Runtime | Chat interface, terminal, file system | Low — required env |
| GitHub Copilot | Runtime | AI agent execution environment | Low — required env |
| BMAD Core module | Framework | Agent loading, workflow engine | Low — internal |
| BMM module | Framework | Phase agent definitions | Low — internal |

---

## 3. Component Architecture

### 3.1 Component Overview

The system decomposes into **six architectural components**, each with clear boundaries and responsibilities:

```
┌─────────────────────────────────────────────────────────────────┐
│                        @lens Agent (Compass)                     │
│                   Entry point: slash commands                    │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐     │
│  │   Router      │  │   State      │  │   Constitution    │     │
│  │   Engine      │  │   Machine    │  │   Engine          │     │
│  │               │  │              │  │                   │     │
│  │ command →     │  │ state.yaml   │  │ hierarchy load    │     │
│  │ workflow      │  │ event log    │  │ additive merge    │     │
│  │ dispatch      │  │ dual-write   │  │ gate validation   │     │
│  └──────┬───────┘  └──────┬───────┘  └────────┬──────────┘     │
│         │                 │                    │                 │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌────────▼──────────┐     │
│  │   Git        │  │   Discovery  │  │   Checklist       │     │
│  │   Engine     │  │   Engine     │  │   Engine          │     │
│  │              │  │              │  │                   │     │
│  │ branch ops   │  │ repo scan    │  │ gate readiness    │     │
│  │ PR creation  │  │ artifact     │  │ artifact checks   │     │
│  │ topology     │  │ resolution   │  │ progressive       │     │
│  └──────────────┘  └──────────────┘  └───────────────────┘     │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Component Specifications

#### 3.2.1 Router Engine

**Responsibility:** Maps user commands to workflow files and delegates execution to the appropriate phase agent.

**Inputs:**
- Slash command from user (e.g., `/techplan`)
- Current state context (active initiative, current phase)

**Outputs:**
- Workflow file path loaded and executed
- Phase agent activated with injected context

**Key design decisions:**
- Fuzzy matching on commands (e.g., "architecture" matches `/techplan`)
- Command groups: Core (3), Phase (6), Recovery (2), Governance (4)
- Router validates preconditions before dispatching (previous phase complete, artifacts exist)

**Implementation:** `compass.agent.yaml` menu section with trigger → workflow mappings.

#### 3.2.2 State Machine

**Responsibility:** Manages the two-file state system and enforces lifecycle state transitions.

**State files:**
- `_bmad-output/lens-work/state.yaml` — personal runtime state (active initiative pointer, current phase, workflow status)
- `_bmad-output/lens-work/initiatives/{id}.yaml` — per-initiative configuration (phase status, track, audiences, docs path)
- `_bmad-output/lens-work/event-log.jsonl` — append-only audit trail

**State transitions (valid):**
```
                  ┌─────────────────────────────────────────┐
                  │         Phase State Machine              │
                  │                                         │
   /new           │   null ──► in_progress ──► pr_pending   │
    │             │                              │          │
    ▼             │                   PR merge ──┘          │
 initiative       │                              │          │
 created          │                    complete ◄─┘         │
                  │                                         │
                  └─────────────────────────────────────────┘

  Phase ordering (full track):
  preplan → businessplan → techplan → devproposal → sprintplan → dev

  Audience promotions (discrete user-triggered events):
  small ──► medium ──► large ──► base
         (after         (after        (after
         techplan)      sprintplan)    dev)
```

**Dual-write contract:**
Every mutation to `current_phase`, `phase_status`, or `audience_status` updates BOTH `state.yaml` AND `initiatives/{id}.yaml`. The source of truth hierarchy is:
1. Git branch state (ground truth — branches exist or don't)
2. Event log (append-only audit trail — chronological record)
3. state.yaml + initiative config (convenience cache — reconstructable)

**Recovery:** `/sync` reconstructs state from git + event log using remote-wins strategy.

#### 3.2.3 Git Engine

**Responsibility:** All branch creation, commit, push, and PR operations.

**Branch topology:**
```
{initiative_root}                              # base (= initiative root)
{initiative_root}-small                        # audience: IC work
{initiative_root}-small-{phase}                # phase work branch
{initiative_root}-medium                       # audience: lead review
{initiative_root}-large                        # audience: stakeholder
```

**Branch naming rules:**
- Flat hyphen-separated (no nested `/`)
- Initiative root: `{domain}-{service}-{feature}-{6char_id}` (e.g., `lens-lens-work-upgrade-cjki9q`)
- Audience suffix: `-small`, `-medium`, `-large` (initiative root = base)
- Phase suffix: `-preplan`, `-businessplan`, `-techplan`, `-devproposal`, `-sprintplan`
- Maximum branch name length: validated against platform limits (Windows `MAX_PATH`)

**Merge flow (MVP — two-tier model):**
```
Phase branch ──PR──► Audience branch ──PR──► Next audience branch
     │                     │                        │
  (phase work)        (phase complete)        (audience promotion)
  
Example:
  *-small-preplan     ──PR──► *-small
  *-small-businessplan ──PR──► *-small
  *-small-techplan    ──PR──► *-small
  *-small             ──PR──► *-medium  (promotion: adversarial review)
  *-medium            ──PR──► *-large   (promotion: stakeholder approval)
  *-large             ──PR──► {root}    (promotion: constitution gate)
```

**Git operations are never auto-merged.** Every merge requires a PR review. The @lens agent creates PRs but never merges them — the user reviews and merges.

**Growth (P4):** Third-tier workflow branches (`*-small-{phase}-{workflow}`) for fine-grained artifact isolation within phases.

#### 3.2.4 Constitution Engine

**Responsibility:** Loads, merges, and validates governance rules from the four-level LENS hierarchy.

**Hierarchy resolution:**
```
org/constitution.md          (if exists)
  └─► domain/{domain}/constitution.md
        └─► service/{domain}/{service}/constitution.md  (if exists)
              └─► repo/{domain}/{service}/{repo}/constitution.md  (if exists)
```

**Merge algorithm (set-union):**

```python
def resolve_constitution(org, domain, service, repo):
    """Additive merge — lower levels can only ADD, never remove."""
    resolved = {}
    for level in [org, domain, service, repo]:
        if level is None:
            continue  # Empty set contribution
        for field, value in level.items():
            if isinstance(value, list):
                resolved[field] = deduplicate(resolved.get(field, []) + value)
            elif isinstance(value, dict):
                for subfield, subvalue in value.items():
                    if isinstance(subvalue, list):
                        existing = resolved.get(field, {}).get(subfield, [])
                        resolved.setdefault(field, {})[subfield] = deduplicate(existing + subvalue)
                    else:
                        resolved.setdefault(field, {})[subfield] = subvalue
            else:
                resolved[field] = value  # Scalar: most specific wins
    return resolved
```

**Validation points:**
- Initiative creation: validate `track` against `permitted_tracks`
- Phase completion: validate `required_artifacts` exist
- Audience promotion: validate `required_reviewers` present
- Every workflow step: inline constitution check (advisory or enforced mode)

**File locations:**
```
_bmad-output/lens-work/constitutions/
├── org/
│   └── constitution.md              # Org-level (if defined)
├── domain/
│   └── lens/
│       └── constitution.md          # Domain-level ✅ (exists)
├── service/
│   └── lens/
│       └── lens-work/
│           └── constitution.md      # Service-level (if defined)
└── repo/
    └── lens/
        └── lens-work/
            └── bmad.lens.src/
                └── constitution.md  # Repo-level (if defined)
```

**Default behavior:** If no constitution exists at a given LENS level, that level contributes an empty set. If no constitution exists at any level, all gates pass with zero additional requirements — lifecycle.yaml defaults apply.

#### 3.2.5 Discovery Engine

**Responsibility:** Scans repositories, discovers initiatives, resolves artifact paths, and provides onboarding.

**Artifact path resolution:**
```
docs_path = initiative.docs.path
           = "Docs/{domain}/{service}/feature/{feature}"
           = "Docs/lens/lens-work/feature/upgrade"

Artifact resolution:
  product-brief → {docs_path}/product-brief.md
  prd           → {docs_path}/prd.md
  architecture  → {docs_path}/architecture.md
  tech-decisions→ {docs_path}/tech-decisions.md
  epics         → {docs_path}/epics.md
  stories       → {docs_path}/stories/
  sprint-status → {docs_path}/sprint-status.md
```

**Initiative discovery:**
- Scan `_bmad-output/lens-work/initiatives/` for initiative configs
- Cross-reference with `state.yaml` for active initiative
- Reconcile with git branches for consistency

**Onboarding flow (4 steps, NFR12):**
1. Detect existing initiatives → returning vs. new user path
2. Teach three concepts: phases, tracks, audiences
3. Show Tier 1 commands: `/new`, `/status`, `/switch`
4. Offer: create initiative (`/new`) or switch to existing (`/switch`)

#### 3.2.6 Checklist Engine

**Responsibility:** Tracks gate readiness through progressive checklists that expand as workflow steps complete.

**Checklist schema:**
```yaml
checklist:
  current_gate: "techplan"
  items:
    - item: "Architecture document exists"
      status: "passed"      # passed | pending | failed
      required: true
      detected_at: "2026-02-25T15:00:00Z"
    - item: "Tech decisions documented"
      status: "pending"
      required: true
      detected_at: null
  gate_ready: false
  gate_ready_pct: 50
```

**Gate readiness logic:**
- Gate is ready when all `required: true` items have `status: passed`
- `gate_ready_pct` = (passed required items / total required items) * 100
- Non-required items are informational and don't block

---

## 4. Data Architecture

### 4.1 Data Model

The system has **no database**. All data is stored in files within the repository:

| Data Entity | Format | Location | Persistence |
|-------------|--------|----------|-------------|
| Lifecycle contract | YAML | `_bmad/_config/custom/lens-work/lifecycle.yaml` | Git-committed (module config) |
| Initiative config | YAML | `_bmad-output/lens-work/initiatives/{id}.yaml` | Git-committed (per-initiative) |
| Runtime state | YAML | `_bmad-output/lens-work/state.yaml` | Git-committed (personal) |
| Event log | JSONL | `_bmad-output/lens-work/event-log.jsonl` | Git-committed (append-only) |
| Constitutions | Markdown | `_bmad-output/lens-work/constitutions/` | Git-committed (governance) |
| Planning artifacts | Markdown | `Docs/{domain}/{service}/feature/{feature}/` | Git-committed (deliverables) |
| Planning context | YAML | `.planning-context.yaml` (TargetProjects root) | Git-committed (cross-repo) |

### 4.2 State Schema Alignment

The dual-write contract ensures that `state.yaml` and `initiatives/{id}.yaml` share these aligned fields:

| Field | state.yaml | initiatives/{id}.yaml | Source of Truth |
|-------|-----------|----------------------|----------------|
| `current_phase` | ✅ | ✅ | state.yaml (personal position) |
| `phase_status` | ✅ (full map) | ✅ (full map) | Identical — dual-written |
| `audience_status` | ✅ | ❌ (derived from track) | state.yaml |
| `active_track` | ✅ | `track` field | initiative config |
| `workflow_status` | ✅ | ❌ | state.yaml only |

**Divergence detection:** If `state.phase_status[X] != initiative.phase_status[X]`, `/sync` or `/fix` reconciles using git branch + PR state as ground truth.

### 4.3 Event Log Schema

```jsonl
{"ts":"ISO8601","event":"phase_start","initiative":"id","phase":"techplan","agent":"winston","branch":"*-small-techplan","audience":"small"}
{"ts":"ISO8601","event":"phase_pr_created","initiative":"id","phase":"techplan","pr":"url","artifact":"architecture.md"}
{"ts":"ISO8601","event":"phase_complete","initiative":"id","phase":"techplan","pr":"url","merge_sha":"abc123","next_phase":"devproposal"}
{"ts":"ISO8601","event":"party_mode_review","initiative":"id","artifact":"architecture.md","reviewers":["john","mary","bob"],"verdicts":{}}
{"ts":"ISO8601","event":"audience_promotion","initiative":"id","from":"small","to":"medium","pr":"url","gate":"adversarial-review"}
{"ts":"ISO8601","event":"constitution_check","initiative":"id","level":"domain","result":"pass","violations":0}
```

**Event types (exhaustive):**

| Event | Trigger | Key Fields |
|-------|---------|------------|
| `init_initiative` | `/new` | id, layer, track, branches_created |
| `phase_start` | Phase command | phase, agent, branch, audience |
| `phase_pr_created` | Artifact committed | phase, pr, artifact |
| `phase_complete` | PR merged | phase, merge_sha, next_phase |
| `party_mode_review` | Adversarial review | artifact, reviewers, verdicts |
| `audience_promotion` | Promotion PR merged | from, to, gate |
| `constitution_check` | Every workflow step | level, result, violations |
| `constitution_ratified` | `/constitution create` | layer, name, articles |
| `state_sync` | `/sync` | changes_applied |
| `state_fix` | `/fix` | category, fix_applied |
| `bootstrap` | `/onboard` | repos_found, cached |

---

## 5. Workflow Architecture

### 5.1 Workflow Execution Model

```
User types command ──► Compass (Router) 
                          │
                          ├─ Validate preconditions
                          ├─ Load state
                          ├─ Check constitution
                          │
                          ▼
                    Route to workflow.md
                          │
                          ├─ Pre-flight (branch checkout, state load)
                          ├─ Workflow steps (step-01, step-02, ...)
                          ├─ Artifact generation
                          ├─ Commit & push
                          ├─ Create PR
                          │
                          ▼
                    Update state (dual-write)
                          │
                          ├─ state.yaml
                          ├─ initiatives/{id}.yaml
                          └─ event-log.jsonl
```

### 5.2 Phase Workflow Pattern

Every phase workflow follows a consistent pattern:

```yaml
# Phase workflow template (pseudocode)
pre_flight:
  - verify_clean_working_directory
  - load_two_file_state
  - validate_previous_phase_complete
  - determine_phase_branch_name
  - create_or_checkout_phase_branch
  - confirm_to_user

execute:
  - load_prior_phase_artifacts_as_context
  - activate_phase_agent (inject context)
  - run_bmm_workflow (step-by-step artifact creation)
  - validate_artifacts_created

commit_and_gate:
  - targeted_commit (only phase artifacts)
  - push_branch
  - create_pr (phase_branch → audience_branch)
  - update_state (phase_status = pr_pending)
  - dual_write_initiative_config
  - append_event_log
```

### 5.3 Phase → Agent → BMM Workflow Mapping

| Phase | Agent | BMM Workflow Used | Artifact(s) |
|-------|-------|-------------------|-------------|
| PrePlan | Mary (Analyst) | `1-analysis/create-product-brief/` | product-brief.md |
| BusinessPlan | John (PM) | `2-plan-workflows/create-prd/` | prd.md |
| TechPlan | Winston (Architect) | `3-solutioning/create-architecture/` | architecture.md, tech-decisions.md |
| DevProposal | John (PM) | `3-solutioning/create-epics-and-stories/` | epics.md, stories/ |
| SprintPlan | Bob (SM) | `4-implementation/sprint-planning/` | sprint-status.md, story files |
| Dev | Amelia (Dev) | (TargetProjects execution) | Code, tests |

### 5.4 Cross-Phase Context Flow

```
PrePlan ─────────────► BusinessPlan ─────────► TechPlan
  │                       │                       │
  product-brief.md        prd.md                  architecture.md
  (loaded by next ──►)    (loaded by next ──►)    tech-decisions.md
                                                  │
                          ◄──────────────────────┘
                          
TechPlan ──────────────► DevProposal ─────────► SprintPlan
  │                       │                       │
  architecture.md         epics.md                sprint-status.md
  tech-decisions.md       stories/                story files
  (loaded by next ──►)    (loaded by next ──►)    │
                                                  │
                          ◄──────────────────────┘
                          
SprintPlan ─────────────► Dev (TargetProjects)
  │                        │
  planning-context.yaml    .planning-context.yaml
  (injected into target)   (at repo root)
```

Each phase workflow loads artifacts from all prior phases as context for the phase agent. The phase agent doesn't need to know where artifacts are — the @lens router resolves paths from `initiative.docs.path` and passes them as context.

---

## 6. Branch Topology Architecture

### 6.1 Initiative Lifecycle Branch Flow

```
main
  │
  └── lens-lens-work-upgrade-cjki9q (initiative root = base)
        │
        ├── *-small (audience: IC work)
        │     │
        │     ├── *-small-preplan ──PR──► *-small
        │     ├── *-small-businessplan ──PR──► *-small
        │     ├── *-small-techplan ──PR──► *-small
        │     ├── *-small-devproposal ──PR──► *-small
        │     └── *-small-sprintplan ──PR──► *-small
        │     │
        │     └──PR──► *-medium (promotion: adversarial review)
        │
        ├── *-medium (audience: lead review)
        │     │
        │     └──PR──► *-large (promotion: stakeholder approval)
        │
        ├── *-large (audience: stakeholder)
        │     │
        │     └──PR──► initiative root (promotion: constitution gate)
        │
        └── (initiative root merges to main when fully complete)
```

### 6.2 Phase Branch Lifecycle

```
                              create
audience branch ──────────────────────► phase branch
      ▲                                    │
      │                                    │ agent works here
      │                                    │ (artifact creation)
      │                                    │
      │          PR (review gate)          │
      └────────────────────────────────────┘
                                        │
                          delete after merge (optional)
```

**Phase branches are ephemeral.** They are created when a phase starts and deleted (optionally) after their PR is merged to the audience branch. The audience branch is long-lived.

### 6.3 Two-Repo Handoff

When SprintPlan completes and Dev begins:

```
BMAD.Lens (planning repo)              TargetProjects (code repo)
                                        
*-small-sprintplan                      
  ├── sprint-status.md                  
  ├── stories/story-001.md              
  └── stories/story-002.md              
                                        
        │ @lens generates                
        │ planning-context.yaml          
        │                               
        └─────────────────────────────► .planning-context.yaml
                                          │
                                          ├── initiative_id
                                          ├── planning_repo URL
                                          ├── planning_branch
                                          ├── artifact_paths (all)
                                          └── resolved_constitution (snapshot)
                                        
                                        feature/{story-id}
                                          │ (GitFlow feature branch)
                                          │ Amelia works here
                                          └──► feature/{epic-id} ──► develop
```

---

## 7. Constitution Architecture

### 7.1 Inheritance Model

```
Org Constitution (global defaults)
  │
  │ additive inheritance (set-union)
  │
  ▼
Domain Constitution (e.g., Lens)
  │ + permitted_tracks, required_gates,
  │   additional_review_participants
  │
  ▼
Service Constitution (e.g., lens-work)
  │ + service-specific additions
  │
  ▼
Repo Constitution (e.g., bmad.lens.src)
  │ + repo-specific additions
  │
  ▼
Resolved Constitution (merged result)
  → Used by gate validation at every step
```

### 7.2 Constitution Schema (Enforceable Fields)

```yaml
# Minimum enforceable constitution schema
constitution:
  # Which lifecycle tracks are allowed
  permitted_tracks: [full, feature, tech-change, hotfix, spike]
  
  # Gates that must be passed regardless of track
  required_gates: [constitution-check]
  
  # Artifacts required before phase can complete
  required_artifacts:
    preplan: [product-brief]
    businessplan: [prd]
    techplan: [architecture]
    devproposal: [epics, stories, implementation-readiness]
    sprintplan: [sprint-status]
  
  # Minimum reviewers for audience promotions
  required_reviewers:
    small_to_medium: [pm, architect]
    medium_to_large: [po, architect]
    large_to_base: [po]
  
  # Additional party mode participants (additive per level)
  additional_review_participants:
    product_brief: [pm, architect, ux-designer]
    prd: [architect, analyst, ux-designer]
    architecture: [pm, analyst, sm]
    epics_stories: [architect, sm, dev]
  
  # Governance mode
  constitution_mode: advisory  # advisory | enforced
  
  # Override policy (Growth P4)
  override_allowed: false
```

### 7.3 Gate Validation Sequence

```
Gate triggered (phase complete / audience promotion)
  │
  ├── 1. Load resolved constitution
  │     └── merge(org, domain, service, repo)
  │
  ├── 2. Validate required artifacts
  │     └── for each artifact in required_artifacts[phase]:
  │           file_exists(docs_path / artifact)?
  │
  ├── 3. Validate reviewers (promotion only)
  │     └── PR reviewers ⊇ required_reviewers[promotion]?
  │
  ├── 4. Record gate result
  │     └── event_log.append({event: "gate_check", ...})
  │
  └── 5. Return result
        ├── PASS → allow transition
        └── BLOCK → show specific failure + remediation
```

---

## 8. Error Handling & Recovery Architecture

### 8.1 Error Categories

| Category | Detection | Recovery | Command |
|----------|-----------|----------|---------|
| **State drift** | PR merged but phase_status not updated | Reconstruct from git + events | `/sync` |
| **Orphan branches** | Branch exists without state entry | Offer deletion | `/fix` |
| **Orphan state** | State references non-existent branch | Clear stale entries | `/fix` |
| **Dirty working directory** | Uncommitted changes at phase start | Prompt commit or stash | Pre-flight |
| **Constitution violation** | Track not permitted, artifact missing | Show specific rule + remediation | Inline |
| **PR creation failure** | GitHub API unavailable | Manual PR creation instructions | Graceful fallback |

### 8.2 Recovery Architecture

```
/sync (remote-wins strategy):
  1. Fetch all remote branches
  2. For each initiative in state:
     a. Check if phase branches exist
     b. Check if phase PRs are merged (merge-base --is-ancestor)
     c. Compare phase_status with git reality
  3. Show diff of proposed changes
  4. Apply with user confirmation
  5. Log sync event

/fix (three-category repair):
  1. Detect state drift → update phase_status from git
  2. Detect orphan branches → offer deletion
  3. Detect orphan state → clear stale entries
  4. Preview all changes before applying
  5. Apply with user confirmation
  6. Log fix event
```

### 8.3 Idempotency Guarantee

Every @lens command is idempotent:
- Re-running a phase command when the phase is already complete → shows status, suggests next action
- Re-running a phase command when the phase is in progress → resumes from current position
- Re-running `/new` with same initiative → detects existing, shows status
- State reconstruction from event log + git → same state regardless of starting point

---

## 9. Implementation Patterns

### 9.1 File-Based State Machine Pattern

```yaml
# Pattern: Every state mutation follows this sequence
mutation_sequence:
  1_read:
    - state = load("state.yaml")
    - initiative = load("initiatives/{state.active_initiative}.yaml")
  
  2_validate:
    - assert state.current_phase == expected_phase
    - assert preconditions_met(state, initiative)
  
  3_mutate:
    - state.current_phase = new_phase
    - state.phase_status[new_phase] = "in_progress"
    - initiative.current_phase = new_phase
    - initiative.phase_status[new_phase] = "in_progress"
  
  4_persist:
    - save(state, "state.yaml")           # Dual-write 1
    - save(initiative, "initiatives/{id}.yaml")  # Dual-write 2
    - event_log.append({
        ts: now(),
        event: "phase_start",
        phase: new_phase,
        initiative: id
      })                                  # Event log 3
  
  5_verify:
    - assert state == reload("state.yaml")
```

### 9.2 Pre-Flight Pattern

Every phase workflow starts with a pre-flight check:

```yaml
pre_flight:
  - step: "verify clean working directory"
    command: "git status --porcelain"
    expect: empty
    on_fail: "Uncommitted changes detected. Commit or stash before proceeding."
  
  - step: "load two-file state"
    load: [state.yaml, initiatives/{id}.yaml]
    validate: schemas match
  
  - step: "check previous phase"
    assert: state.phase_status[previous_phase] == "complete"
    on_fail: "Previous phase {name} not complete. Run /{cmd} first."
  
  - step: "determine phase branch"
    compute: "{initiative_root}-{audience}-{phase_name}"
  
  - step: "create or checkout branch"
    if_not_exists: "git checkout -b {branch} {audience_branch}"
    if_exists: "git checkout {branch}"
  
  - step: "confirm to user"
    output: "Pre-flight complete. Branch: {branch}. Phase: {phase}."
```

### 9.3 Targeted Commit Pattern

Only commit files relevant to the current workflow:

```yaml
targeted_commit:
  files:
    - "{docs_path}/{artifact}.md"
    - "_bmad-output/lens-work/state.yaml"
    - "_bmad-output/lens-work/event-log.jsonl"
  
  message: "[lens-work] {phase}: {description}"
  
  # NEVER commit:
  exclude:
    - "_bmad/_config/**"    # Module config (not per-initiative)
    - "TargetProjects/**"   # Code repo (separate git)
    - "node_modules/**"     # Dependencies
```

### 9.4 Agent Activation Pattern

```yaml
agent_activation:
  1_context_injection:
    - Load all prior phase artifacts into context
    - Resolve docs_path from initiative config
    - Load resolved constitution
  
  2_agent_invocation:
    - Activate phase agent (e.g., Winston for TechPlan)
    - Agent inherits injected context
    - Agent executes BMM workflow (e.g., create-architecture)
  
  3_artifact_capture:
    - Agent produces artifacts at expected paths
    - @lens validates artifacts exist
    - @lens commits and creates PR
```

---

## 10. Project Structure

### 10.1 Module File Organization

```
_bmad/_config/custom/lens-work/
├── module.yaml                     # Module metadata, skills, install questions
├── lifecycle.yaml                  # Canonical lifecycle contract (v2)
├── package.json                    # Node.js package info
├── index.js                        # Module entry point
├── README.md                       # Module documentation
│
├── agents/
│   ├── compass.agent.yaml          # Main router agent definition
│   └── compass.md                  # Sidecar agent instructions
│
├── skills/
│   ├── git-orchestration.md        # Branch, commit, push operations
│   ├── state-management.md         # state.yaml, event-log, dual-write
│   ├── discovery.md                # Repo scanning, artifact resolution
│   ├── constitution.md             # Governance validation
│   └── checklist.md                # Gate readiness tracking
│
├── workflows/
│   ├── router/                     # Phase command routers
│   │   ├── pre-plan/workflow.md
│   │   ├── spec/workflow.md        # (legacy name → routes to businessplan)
│   │   ├── tech-plan/workflow.md
│   │   ├── plan/workflow.md        # (legacy name → routes to devproposal)
│   │   ├── story-gen/workflow.md
│   │   ├── review/workflow.md
│   │   ├── sprintplan/workflow.md
│   │   ├── dev/workflow.md
│   │   └── init-initiative/workflow.md
│   │
│   ├── governance/
│   │   ├── constitution/workflow.md
│   │   ├── compliance-check/workflow.md
│   │   ├── resolve-constitution/workflow.md
│   │   └── ancestry/workflow.md
│   │
│   ├── utility/
│   │   ├── switch/workflow.md
│   │   ├── fix-story/workflow.md
│   │   ├── sync-and-select-branch/workflow.md
│   │   ├── onboarding/workflow.md
│   │   ├── manage-credentials/workflow.md
│   │   └── recreate-branches/workflow.md
│   │
│   ├── discovery/
│   │   ├── domain-map/workflow.md
│   │   └── impact-analysis/workflow.md
│   │
│   ├── core/
│   │   └── phase-lifecycle/workflow.md
│   │
│   ├── includes/
│   │   └── (shared workflow fragments)
│   │
│   └── background/
│       └── (triggered workflows)
│
├── templates/
│   ├── initiative-template.yaml    # Per-initiative config template
│   ├── state-template.yaml         # Personal state template
│   └── constitutions/              # Constitution templates per level
│
├── data/
│   └── (lookup data for workflows)
│
├── docs/
│   └── (module documentation)
│
├── prompts/
│   └── (slash command prompt files)
│
├── scripts/
│   └── (utility scripts)
│
├── tests/
│   └── (test specs)
│
└── _module-installer/
    └── installer.js                # Module installation logic
```

### 10.2 Output File Organization

```
_bmad-output/lens-work/
├── state.yaml                      # Personal runtime state
├── event-log.jsonl                 # Append-only audit trail
├── settings.json                   # Module settings
├── bootstrap-report.md             # Bootstrap discovery output
├── repo-inventory.yaml             # Discovered repos
│
├── initiatives/
│   ├── upgrade-cjki9q.yaml         # Feature-level initiative
│   ├── lens/
│   │   ├── Domain.yaml             # Domain-level initiative
│   │   └── lens-work/
│   │       ├── Service.yaml        # Service-level initiative
│   │       └── .gitkeep
│   └── .gitkeep
│
├── constitutions/
│   ├── org/
│   │   └── constitution.md
│   ├── domain/
│   │   └── lens/
│   │       └── constitution.md     # ✅ Exists
│   ├── service/
│   │   └── lens/
│   │       └── lens-work/
│   │           └── constitution.md
│   └── repo/
│       └── (per-repo constitutions)
│
└── personal/
    └── profile.yaml
```

### 10.3 Planning Artifact Organization

```
Docs/
└── lens/
    └── lens-work/
        └── feature/
            └── upgrade/
                ├── product-brief.md     # PrePlan artifact
                ├── prd.md               # BusinessPlan artifact
                ├── architecture.md      # TechPlan artifact (this file)
                ├── tech-decisions.md    # TechPlan artifact
                ├── epics.md             # DevProposal artifact
                ├── stories/             # DevProposal artifact
                │   ├── story-001.md
                │   └── story-002.md
                └── sprint-status.md     # SprintPlan artifact
```

---

## 11. Technology Decisions Summary

See companion document [tech-decisions.md](tech-decisions.md) for the full technology decisions log with rationale and alternatives considered.

**Key decisions:**

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State storage | YAML files (no database) | Zero dependencies; git-backed; reconstructable |
| Event log format | JSONL (append-only) | One event per line; git-friendly diffs; grep-able |
| Branch naming | Flat hyphens (no `/`) | Cross-platform; no escaping; simple parsing |
| Constitution format | Markdown with YAML code blocks | Human-readable + machine-parseable |
| Orchestration | Single @lens agent (5 skills) | Unified entry point; no inter-agent coordination overhead |
| Phase agents | BMM module agents (Mary, John, etc.) | Reuse existing workflow capability; separation of concerns |
| Cross-repo link | `.planning-context.yaml` | File-based; no shared state; snapshot-at-creation |
| Merge strategy | PR-only (never auto-merge) | FT1 enforcement; human review at every gate |

---

## 12. Security Considerations

### 12.1 Separation of Concerns

- **Planning repo** (BMAD.Lens): No executable code. Only YAML, Markdown, JSONL. No security scan false positives.
- **Code repo** (TargetProjects): Standard code with standard security scanning. Clean signal.
- **Constitution enforcement**: Governance rules are additive-only — lower levels cannot weaken upper-level security requirements.

### 12.2 Agent Boundaries

- Agents cannot self-promote their work (FT2 enforcement)
- Phase agents work only in their assigned phase branches
- @lens agent enforces branch topology — agents can't create arbitrary branches
- Constitution mode (`enforced`) blocks progress on critical violations

### 12.3 Credential Management

- Git PATs stored via `/credentials` workflow (not in repo)
- GitHub API access via MCP (Model Context Protocol) — credentials managed by VS Code
- No secrets in planning artifacts or state files

---

## 13. Validation & Testing Strategy

### 13.1 Dogfood Validation

This initiative (`upgrade-cjki9q`) serves as the primary validation vehicle. If the system can manage its own development lifecycle end-to-end, the architecture is validated.

**Validation checkpoints:**
- [x] PrePlan: product-brief created, reviewed (party mode), PR merged ✅
- [x] BusinessPlan: PRD created, reviewed (party mode), PR merged ✅
- [x] TechPlan: architecture created (this document) — in progress
- [ ] DevProposal: epics and stories created from architecture
- [ ] SprintPlan: sprint planned from stories
- [ ] Dev: implementation in TargetProjects

### 13.2 Constitution Stress Testing

Create constitutions at domain and service levels with overlapping constraints:
- Domain: `permitted_tracks: [full, feature, tech-change]`
- Service: `required_gates: [adversarial-review]`, `additional_review_participants.prd: [security-reviewer]`
- Verify resolved constitution = union of both levels
- Verify `hotfix` and `spike` tracks are blocked

### 13.3 Gate Enforcement Testing

| Test | Expected Result |
|------|-----------------|
| `/businessplan` before PrePlan PR merged | Blocked: "PrePlan not complete" |
| `/techplan` before BusinessPlan PR merged | Blocked: "BusinessPlan not complete" |
| `/devproposal` with architecture.md missing | Blocked: "Required artifact not found" |
| `/sync` after manual PR merge | State updated to reflect merge |
| `/fix` with orphan branch | Branch deletion offered with preview |

### 13.4 Idempotency Testing

| Operation | First Run | Re-run |
|-----------|-----------|--------|
| `/new` initiative | Creates branches + config | "Initiative already exists" |
| Phase command (complete) | "Phase already complete. Next: /X" | Same |
| Phase command (in progress) | Resumes from current state | Same |
| `/sync` (no drift) | "No changes needed" | Same |

---

## 14. Migration Path

### 14.1 v1 → v2 Transition

The upgrade is executed in the dependency order established in the product brief:

```
P0 (Safety)     → Remove auto-advance patterns
P1 (Foundation) → lifecycle.yaml v2 + named phases + audience model
P2 (Structural) → State schema alignment + path normalization
P3 (Content)    → Prompt updates + skeleton phase completion
```

**Parallel operation:** During migration, v1 workflows continue to function. The lifecycle.yaml includes `legacy_phase_number` and `legacy_gate_key` mappings for backward compatibility. Once all workflows reference named phases, legacy mappings can be removed.

### 14.2 No State Migration Required

New initiatives start with v2 schemas. Existing initiatives (if any) can remain on v1 schemas — the system detects `lifecycle_version` in state and initiative configs and routes accordingly. No migration tooling is needed for MVP.

---

## 15. Architecture Validation Checklist

| Requirement | Architecture Component | Coverage |
|-------------|----------------------|----------|
| FR1-FR5 (Lifecycle) | State Machine + Router Engine | ✅ Full |
| FR6-FR11 (Branches) | Git Engine | ✅ Full |
| FR12-FR16 (State) | State Machine (dual-write) | ✅ Full |
| FR17-FR21c (Constitution) | Constitution Engine | ✅ Full |
| FR22-FR25 (Gates) | Constitution Engine + Checklist | ✅ Full |
| FR26-FR29 (Agent Coordination) | Router Engine + Agent Activation | ✅ Full |
| FR30-FR33 (Artifacts) | Discovery Engine | ✅ Full |
| FR34-FR37 (Events) | State Machine (event log) | ✅ Full |
| FR38-FR41d (Discovery) | Discovery Engine + Recovery | ✅ Full |
| FR42-FR43 (Content — Growth) | Deferred to P3 | Deferred |
| FR44-FR47 (Workflow branches — Growth) | Deferred to P4 | Deferred |
| FR48 (Multi-service — Vision) | Deferred to Vision | Deferred |
| NFR1-NFR4 (Reliability) | Idempotency + Recovery arch | ✅ Full |
| NFR5-NFR8 (Consistency) | Canonical naming + append-only log | ✅ Full |
| NFR9-NFR12 (Usability) | Gate feedback + progressive disclosure | ✅ Full |
| NFR13-NFR16 (Maintainability) | Modular skills + lifecycle config | ✅ Full |
| NFR17-NFR20 (Auditability) | Event log + git history + transparency | ✅ Full |

---

*Generated during TechPlan phase by Winston (Architect) for initiative upgrade-cjki9q.*
*Source: Product Brief (PrePlan), PRD (BusinessPlan), Lifecycle Contract v2, Module Configuration, Existing Skills & Templates.*
