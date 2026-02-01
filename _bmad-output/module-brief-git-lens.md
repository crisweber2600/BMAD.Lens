# Module Brief: git-lens

**Date:** 2026-02-01
**Author:** User
**Module Code:** git-lens
**Module Type:** Extension (extends LENS)
**Status:** Ready for Development

---

## Executive Summary

**Git-Lens** is a LENS extension module that automates git branching, PR gating, and workflow enforcement for BMAD planning phases. It transforms ad-hoc planning sessions into a predictable, auditable PBR (Product Backlog Refinement) pipeline by creating structured branch topologies that match BMAD phases and enforcing "one workflow at a time until merged" discipline.

**Module Category:** Developer Workflow / Git Automation
**Target Users:** Engineers running LENS workflows, Tech leads, Architects, Reviewers
**Complexity Level:** Medium-High (git operations + state management + workflow gating)

---

## Module Identity

### Module Code & Name

- **Code:** `git-lens`
- **Name:** `Git-Lens`

### Core Concept

Git-Lens bridges the gap between BMAD/LENS planning workflows and git-based collaboration. It automatically creates the right branches at the right time, enforces sequential workflow completion via merge validation, and produces PR links that route artifacts to the correct reviewers at each phase of the planning process.

**The core insight:** BMAD phases and workflows should map directly to git branches. A workflow isn't "done" until it's merged. The next workflow can't start until the previous one is merged. This creates natural checkpoints, prevents context drift, and makes reviews predictable.

### Personality Theme

**"The Branch Conductor"** — Git-Lens orchestrates your planning work into clean, reviewable streams. It's methodical, reliable, and keeps everyone on the right track. Think of it as a disciplined conductor ensuring each section of the orchestra plays at the right time.

---

## Module Type

**Type:** Extension Module (extends LENS)

This is an **extension** because:
- It extends LENS's existing workflow triggers (`#file:new-service`, `#file:new-microservice`, `#file:new-feature`)
- It adds git orchestration capabilities to LENS without replacing any core functionality
- It integrates with existing LENS patterns (Compass for reviewers, output folders for state)
- It's tightly coupled to LENS's workflow execution model

**Location:** `_bmad/lens/extensions/git-lens/` (alongside LENS in `_bmad/lens/`)

**Note:** LENS lives in `_bmad/lens/`, not `src/modules/`. Git-Lens extends LENS where it lives.

---

## Unique Value Proposition

**What makes this module special:**

1. **Branch topology matches your process** — The branch structure (`base → lanes → phases → workflows`) mirrors BMAD's planning model, making git history a readable record of your planning journey.

2. **Enforced sequential discipline** — No more parallel unmerged workflows causing context drift. Git-Lens validates merge ancestry before allowing the next workflow to start.

3. **Predictable PR routing** — Each PR type has a clear target and audience. Workflow PRs go to the phase branch, phase PRs go to the lane, lane PRs escalate to broader review audiences.

4. **Pause/resume with full context** — State persistence means you can stop mid-workflow and resume later with Git-Lens telling you exactly where you are and what's blocked.

5. **Git-only validation** — No GitHub/GitLab API dependencies. Validation uses git ancestry checks (`git merge-base --is-ancestor`), making it portable across platforms.

**Why users would choose this module:**

- Teams struggling with ad-hoc planning artifact management
- Organizations wanting auditable planning pipelines with clear review gates
- Engineers tired of manually managing branches for each planning phase
- Teams wanting to enforce "finish what you started" discipline in planning workflows

---

## User Scenarios

### Target Users

| User | Pain Point | Git-Lens Solution |
|------|------------|-------------------|
| **Engineer** | "Which branch should I be on? Did I push?" | Automatic branch creation/checkout, clear status |
| **Tech Lead** | "Is Phase 1 actually done? Can we start Phase 2?" | Enforced merge gates, clear phase completion |
| **Architect** | "When do I review? What's the scope?" | Structured `small → lead` PR for architecture review |
| **PO/PM** | "Where's the final PBR artifact?" | Clear `lead → base` PR representing endorsed plan |

### Primary Use Case

**Scenario:** Engineer starts `#file:new-service "payment-gateway"`

1. Git-Lens creates initiative branches: `lens/payment-gateway/base`, `lens/payment-gateway/small`, `lens/payment-gateway/lead`, `lens/payment-gateway/small/p1`
2. Engineer runs Phase 1 analysis workflows on `small/p1` branch
3. Each workflow creates a `small/p1/w/<workflow-name>` branch
4. Finishing a workflow prints PR link → phase branch
5. Starting next workflow is blocked until previous workflow HEAD is ancestor of phase HEAD
6. Phase completion → PR to `small` lane
7. After Phase 2 + architecture → PR `small → lead` for architect/lead review
8. After lead approval → PR `lead → base` for final PBR

### User Journey (Fully Automated)

```
[User: #file:new-service "payment-gateway"]
        ↓
[AUTO: init-initiative]
   Creates & pushes: base, small, lead, p1
        ↓
[AUTO: start-workflow "discovery"]
   Creates: small/p1/w/discovery, checks out
        ↓
[User works on discovery artifacts...]
        ↓
[AUTO: finish-workflow on workflow complete]
   Pushes, prints: PR link → small/p1
        ↓
[User attempts next workflow]
   ⚠️ AUTO-BLOCKED until discovery merged
        ↓
[User merges discovery PR externally]
        ↓
[AUTO: start-workflow "requirements"]
   Validates merge, creates: small/p1/w/requirements
        ↓
... continues through phases (all auto) ...
        ↓
[AUTO: finish-phase on phase complete]
   Prints: PR link → small lane
        ↓
[Phase 2 + architecture merged]
        ↓
[AUTO: open-lead-review]
   Prints: PR link small → lead
        ↓
[Leads/architects review & merge externally]
        ↓
[AUTO: open-final-pbr]
   Prints: PR link lead → base
```

**User only merges PRs externally** — Git-Lens handles all branch creation, checkout, push, and gating automatically.

---

## Agent Architecture

### Agent Count Strategy

**Single Agent** — Git-Lens is a focused automation module. One agent ("Conductor") handles all git orchestration. The complexity is in the workflow logic, not in needing multiple expert perspectives.

**Rationale:** The domain is narrow (git branch management + PR gating). All commands serve the same purpose: moving artifacts through a structured git pipeline. A single agent with clear commands is simpler and more predictable.

### Agent Roster

| Agent | Name | Role | Expertise |
|-------|------|------|-----------|
| **Conductor** | Casey | Git Branch Orchestrator | Git operations, branch topology, merge validation, state management |

### Agent Interaction Model

Casey (Conductor) operates **automatically** — commands run at the right time without user invocation:

- **Auto on LENS trigger** → `init-initiative` creates branch structure
- **Auto on workflow start** → `start-workflow` creates/checks out workflow branch (with gating)
- **Auto on workflow complete** → `finish-workflow` pushes + prints PR link
- **Auto on phase complete** → `finish-phase` pushes + prints phase PR link
- **Auto on review gates** → `open-lead-review`, `open-final-pbr` print PR links at appropriate times
- **Manual only** → `status` (on-demand) and `checkpoint` (optional mid-workflow commit)

**The user doesn't orchestrate Git-Lens — Git-Lens orchestrates itself based on LENS workflow events.**

### Hook/Trigger Mechanism

**How Git-Lens intercepts LENS workflows:**

Git-Lens uses a **wrapper workflow pattern**:

1. **Installation modifies LENS entry points** — The `#file:new-service` (etc.) workflows are updated to include Git-Lens hooks at start/end
2. **Hook injection points:**
   - `@git-lens:before-initiative` — Called before LENS workflow begins (triggers `init-initiative`)
   - `@git-lens:before-workflow` — Called at workflow step entry (triggers `start-workflow`)
   - `@git-lens:after-workflow` — Called at workflow step completion (triggers `finish-workflow`)
   - `@git-lens:before-phase` — Called at phase boundary (triggers `start-phase`/`finish-phase`)
3. **Mechanism:** LENS workflow files include conditional hook calls that execute if Git-Lens is installed

**Alternative (if hook injection not feasible):** Git-Lens provides a **launcher workflow** that wraps LENS workflows:
- User calls `#file:git-lens:new-service` instead of `#file:new-service`
- Git-Lens launcher executes git operations, then delegates to LENS workflow, then executes git operations on return

### Agent Menu (for manual commands)

Casey responds to these **manual** menu commands:

| Cmd | Trigger | Action |
|-----|---------|--------|
| `ST` | "status", "where am I" | Show current state, blocks, next steps |
| `CP` | "checkpoint", "save" | Commit current changes with template message |
| `RS` | "resume", "continue" | Rehydrate from state.yaml, explain context |
| `SY` | "sync", "fetch" | Run `git fetch` and re-validate state |

### Agent Communication Style

**Casey (Conductor):**
- **Tone:** Methodical, clear, reliable — like a seasoned release engineer
- **Style:** Short status updates, clear instructions, no fluff
- **Blocking:** Direct about what's blocked and why, with exact steps to unblock
- **Guidance:** Suggests next actions, explains branch topology when helpful

**Example interactions:**
- "✅ Created workflow branch `lens/payment-gateway/small/p1/w/discovery`. You're ready to work."
- "⛔ BLOCKED: Previous workflow `requirements` not merged into phase branch. PR: https://... — merge it first."
- "📋 Status: Initiative `payment-gateway`, Phase 1, Workflow `discovery` (in progress). Next: finish-workflow when ready."

---

## Workflow Ecosystem

### Core Workflows (Essential — Auto-Triggered)

| Workflow | Trigger | Description |
|----------|---------|-------------|
| **init-initiative** | Auto on `#file:new-*` LENS trigger | Create full branch topology for new initiative |
| **start-workflow** | Auto when LENS workflow begins | Create workflow branch with merge-gate validation |
| **finish-workflow** | Auto when LENS workflow completes | Push workflow branch, print PR link to phase |
| **start-phase** | Auto on first workflow of phase | Create/checkout phase branch (p1, p2, etc.) |
| **finish-phase** | Auto when phase workflows complete | Push phase branch, print PR link to lane |
| **open-lead-review** | Auto after Phase 2 + architecture merged | Print PR link for small → lead |
| **open-final-pbr** | Auto after lead review merged | Print PR link for lead → base |

### Utility Workflows (Manual)

| Workflow | Trigger | Description |
|----------|---------|-------------|
| **status** | `ST` command (on-demand) | Display current state, what's blocked, next steps |
| **checkpoint** | `CP` command (optional) | Commit with standard message template mid-workflow |

### Utility Workflows (Support)

| Workflow | Trigger | Description |
|----------|---------|-------------|
| **resume** | `RS` command | Rehydrate state from state.yaml, explain context |
| **reviewer-suggest** | Internal | Query Compass for reviewer suggestions |

---

## Tools & Integrations

### MCP Tools

| Tool | Purpose |
|------|---------|
| **git-mcp-server** (if available) | Branch operations, commit, push |
| **filesystem** | State file read/write (`_bmad-output/git-lens/state.yaml`) |

### External Services

**Git CLI** (required):
- `git checkout -b` — Create branches
- `git push -u origin` — Push branches
- `git merge-base --is-ancestor` — Validate merge ancestry
- `git rev-parse HEAD` — Get current commit SHA
- `git fetch origin` — **CRITICAL: Always fetch before ancestry validation to ensure local refs are current**
- `git rev-parse --verify` — Check if branch exists locally/remotely

**No GitHub/GitLab API required** — All validation is git-only. PR links are printed for manual creation or use platform CLI (`gh pr create`, `glab mr create`).

### Git Fetch Requirement

**CRITICAL:** Before any ancestry validation, Git-Lens MUST run `git fetch origin` to ensure local refs reflect remote state. This prevents false "not merged" blocks when user merged PR via GitHub/GitLab UI but local repo is stale.

### Integrations with Other Modules

| Module | Integration |
|--------|-------------|
| **LENS Core** | Triggered by `#file:new-service`, `#file:new-microservice`, `#file:new-feature` via hook injection or launcher wrapper |
| **Lens Compass** | Query reviewer roster file, filter by role (implementer/lead/architect), output suggested reviewers + rationale per PR type |
| **BMAD Core** | Respects `_bmad-output/` conventions, uses config.yaml |

### Compass Integration Details

**Mechanism:** Git-Lens reads Compass roster data (CSV or YAML) and filters by role:

| PR Type | Reviewer Roles | Rationale |
|---------|----------------|-----------|
| Workflow PR | implementers, workflow-owner | "Close to the work, can validate details" |
| Phase PR | tech-lead, pm | "Phase completion = milestone, needs lead sign-off" |
| Lead Review PR | architects, senior-leads | "Architecture review gate, broad perspective needed" |
| Final PBR PR | full-pbr-distribution | "Final endorsement, all stakeholders" |

**Output format:**
```
📋 Suggested reviewers for workflow PR (discovery → p1):
  - @alice (implementer) — assigned to payment-gateway
  - @bob (tech-lead) — oversight for Phase 1
```

**Fallback:** If Compass not configured, skip reviewer suggestions and print: "Configure Compass for reviewer suggestions."

---

## Branch Model Specification

### Branch Naming Convention

```
lens/<initiative>/<lane>/<phase>/w/<workflow>

Examples:
- lens/payment-gateway/base                    # Initiative base
- lens/payment-gateway/small                   # Small-table review lane
- lens/payment-gateway/lead                    # Lead/architect review lane
- lens/payment-gateway/small/p1                # Phase 1 branch
- lens/payment-gateway/small/p2                # Phase 2 branch
- lens/payment-gateway/small/p1/w/discovery    # Workflow branch
```

### Branch Creation Order

1. **Base branch** — `lens/<initiative>/base` (from configurable `base_ref`, default: `main`)
2. **Audience lanes** — `small` and `lead` (from base)
3. **Phase branches** — `small/p1`, `small/p2` (from small lane, created lazily)
4. **Workflow branches** — `small/pN/w/<name>` (from active phase, with gating)

### Initiative Slug Generation

**Algorithm:**
```
slug = kebab-case(initiative_name) + "-" + YYYYMMDD

Examples:
- #file:new-service "Payment Gateway" → payment-gateway-20260201
- #file:new-feature "User Auth"       → user-auth-20260201
```

**Rules:**
- Convert to lowercase
- Replace spaces/underscores with hyphens
- Remove special characters except hyphens
- Append date suffix (YYYYMMDD) for uniqueness
- Max length: 50 characters (truncate name portion if needed)

### Branch Collision Handling (Idempotency)

**If branch already exists:**

| Scenario | Action |
|----------|--------|
| Base branch exists, state.yaml matches | Resume existing initiative (idempotent) |
| Base branch exists, no state.yaml | **ERROR:** "Initiative branch exists but no state found. Run `status` to diagnose or manually clean up." |
| Base branch exists, state.yaml doesn't match | **ERROR:** "Initiative branch exists but belongs to different initiative. Choose a different name." |
| Workflow branch exists for current workflow | Resume on that branch (idempotent) |
| Workflow branch exists for different workflow | Create new branch with `-2` suffix (e.g., `w/discovery-2`) |

**Principle:** Prefer resumption over failure. Only error when state is truly inconsistent.

### PR Merge Topology

```
w/<workflow>  →  small/p{N}     (workflow PR)
small/p{N}    →  small          (phase PR)
small         →  lead           (lead review PR)
lead          →  base           (final PBR PR)
```

---

## State Persistence

### State File Location

`_bmad-output/git-lens/state.yaml`

### State Schema

```yaml
version: 1  # Schema version for future migrations

initiative:
  slug: payment-gateway-20260201
  name: "Payment Gateway"
  base_ref: main
  created_at: 2026-02-01T19:00:00Z

branches:
  base: lens/payment-gateway-20260201/base
  small: lens/payment-gateway-20260201/small
  lead: lens/payment-gateway-20260201/lead

current:
  lane: small
  phase: p1
  workflow: discovery
  branch: lens/payment-gateway-20260201/small/p1/w/discovery
  status: in_progress  # in_progress | blocked | completed

shas:
  # Track SHAs for validation (updated on each operation)
  workflow_head: abc123...
  phase_head: def456...
  last_fetch: 2026-02-01T19:30:00Z

history:
  - workflow: discovery
    branch: lens/payment-gateway-20260201/small/p1/w/discovery
    status: merged
    pr_url: https://github.com/org/repo/pull/123
    merged_at: 2026-02-01T20:00:00Z
    sha_at_merge: abc123...

blocked:
  is_blocked: true
  reason: "Workflow 'requirements' HEAD not ancestor of phase branch"
  blocking_branch: lens/payment-gateway-20260201/small/p1/w/requirements
  target_branch: lens/payment-gateway-20260201/small/p1
  pr_url: https://github.com/org/repo/pull/124
  blocked_since: 2026-02-01T20:15:00Z
```

### State Reconstruction (Recovery)

If `state.yaml` is missing or corrupted, Git-Lens can reconstruct state from git:

1. **Scan for branches** matching `lens/*/base` pattern
2. **Identify initiative** from branch naming
3. **Find current phase** by checking which `small/pN` branches exist
4. **Find current workflow** by checking `small/pN/w/*` branches
5. **Determine status** by running ancestry checks
6. **Rebuild state.yaml** with reconstructed data
7. **WARN user:** "State reconstructed from git. History (PR URLs, timestamps) not recoverable."

---

## Enforcement Rules

### Hard Blocks

| Trigger | Condition | Block Message |
|---------|-----------|---------------|
| `start-workflow` | Previous workflow HEAD not ancestor of phase HEAD | "⛔ BLOCKED: Workflow `X` not merged. PR: [url]. Merge before starting new workflow." |
| `start-phase` (p2+) | Previous phase HEAD not ancestor of small lane HEAD | "⛔ BLOCKED: Phase `p{N-1}` not merged into small lane. Complete phase PR first." |

### Validation Method

```bash
# ALWAYS fetch first to ensure refs are current
git fetch origin

# Check if workflow is merged into phase
git merge-base --is-ancestor <workflow-head> origin/<phase-branch>

# Exit code 0 = merged (ancestor), non-zero = not merged
```

### Error Handling & Recovery

| Error Condition | Detection | Recovery Action |
|-----------------|-----------|-----------------|
| **No git remote** | `git remote -v` returns empty | WARN: "No remote configured. Branches created locally only. Push manually when ready." |
| **Push fails (auth)** | `git push` exit code non-zero | ERROR: "Push failed. Check credentials. Branch created locally: `<branch>`" |
| **Push fails (network)** | `git push` timeout | WARN: "Push failed (network). Branch created locally. Retry with `SY` (sync)." |
| **state.yaml missing** | File not found on resume | WARN: "No state file. Scanning git branches to reconstruct state..." then rebuild from branch names |
| **state.yaml corrupted** | YAML parse error | ERROR: "State file corrupted. Backup at `state.yaml.bak`. Attempting reconstruction from git..." |
| **State/git mismatch** | Branch in state doesn't exist | WARN: "State references branch `X` which doesn't exist. Updating state to match git reality." |

### Blocked UX Flow

When a block is detected:

1. **HALT** the current operation (do not proceed)
2. **DISPLAY** block message with:
   - What is blocked (e.g., "Cannot start workflow 'requirements'")
   - Why it's blocked (e.g., "Previous workflow 'discovery' not merged")
   - The blocking branch and target branch
   - PR URL if known (from state.yaml history)
   - Exact command to create PR if URL not known
3. **PROMPT** user: "Merge the PR, then run `SY` (sync) to continue."
4. **DO NOT** automatically retry — wait for explicit user action

---

## Creative Features

### Personality & Theming

**Casey the Conductor** — Named for the famous railroad engineer Casey Jones. Casey keeps your work on track, on schedule, and headed to the right destination.

**Communication flavor:**
- Uses railroad/conductor metaphors sparingly
- "All aboard for Phase 2!" (on phase completion)
- "🚂 Next stop: Lead Review" (on opening lead review)
- Keeps it professional but with personality

### Easter Eggs & Delighters

- **"Full Steam"** — If all workflows in a phase complete without any blocks, Casey says "Full steam ahead! 🚂"
- **"Golden Spike"** — When final PBR PR is opened, references the golden spike that completed the transcontinental railroad
- **Status art** — ASCII art branch diagram when showing status

### Module Lore

Git-Lens was born from the chaos of unstructured planning sessions. Too many times, architects reviewed stale artifacts, POs approved docs that had already changed, and engineers started Phase 2 while Phase 1 PRs languished. Casey was brought in to run a tighter operation — every artifact has a track, every change has a checkpoint, every review has its time.

---

## Acceptance Criteria

### Must Have (v1) — Given/When/Then Format

**AC-1: Initiative Creation**
```
GIVEN user triggers #file:new-service "Payment Gateway"
AND no existing initiative branch for this slug
WHEN Git-Lens init-initiative runs
THEN branches base, small, lead, small/p1 are created and pushed
AND state.yaml is created with initiative metadata
AND user sees: "✅ Initiative 'payment-gateway-20260201' created. Ready for Phase 1."
```

**AC-2: Workflow Branch Creation**
```
GIVEN an active initiative with no previous workflows OR previous workflow merged
WHEN LENS workflow begins (e.g., discovery)
THEN Git-Lens creates branch small/p1/w/discovery from phase branch
AND checks out the new branch
AND state.yaml current.workflow is updated
AND user sees: "✅ Workflow branch created. You're on small/p1/w/discovery"
```

**AC-3: Workflow Merge Gate (Block)**
```
GIVEN workflow 'discovery' exists but is NOT merged into phase branch
WHEN user attempts to start workflow 'requirements'
THEN operation is BLOCKED
AND user sees: "⛔ BLOCKED: Workflow 'discovery' not merged. PR: [url or command]. Merge it first."
AND state.yaml blocked section is populated
AND no new branch is created
```

**AC-4: Workflow Merge Gate (Pass)**
```
GIVEN workflow 'discovery' HEAD is ancestor of phase branch HEAD (merged)
WHEN user attempts to start workflow 'requirements'
THEN merge gate passes
AND new workflow branch is created normally
```

**AC-5: Finish Workflow**
```
GIVEN user is on workflow branch with uncommitted or committed changes
WHEN LENS workflow completes
THEN Git-Lens commits any uncommitted changes (with template message)
AND pushes the workflow branch
AND prints PR link/command targeting phase branch
AND state.yaml history is updated
```

**AC-6: Git Fetch Before Validation**
```
GIVEN user merged PR via GitHub UI (remote updated, local stale)
WHEN Git-Lens checks merge ancestry
THEN `git fetch origin` runs FIRST
THEN ancestry check uses `origin/<branch>` refs
AND validation reflects remote state, not stale local state
```

**AC-7: State Persistence**
```
GIVEN any Git-Lens operation completes
WHEN operation finishes (success or failure)
THEN state.yaml is updated atomically (write to temp, rename)
AND state reflects current reality
```

**AC-8: Resume from State**
```
GIVEN state.yaml exists with valid data
WHEN user runs `RS` (resume) command
THEN Git-Lens reads state.yaml
AND checks out the current.branch
AND displays status summary
AND indicates next action or current block
```

**AC-9: Error - No Remote**
```
GIVEN git repository has no remote configured
WHEN Git-Lens attempts to push
THEN operation continues (branch created locally)
AND user sees: "⚠️ No remote configured. Branch created locally. Push manually when ready."
```

**AC-10: Error - State Corrupted**
```
GIVEN state.yaml exists but is not valid YAML
WHEN Git-Lens attempts to read state
THEN original file is backed up to state.yaml.bak
AND Git-Lens attempts reconstruction from git branches
AND user sees: "⚠️ State file corrupted. Attempting reconstruction..."
```

### Should Have (v1)

- [ ] `checkpoint` commits with standard message template
- [ ] Reviewer suggestions via Compass integration (query roster, filter by role)
- [ ] Configurable `base_ref` (default: main)
- [ ] `SY` (sync) command to manually fetch and re-validate
- [ ] Branch collision detection with clear error messages

### Won't Have (v1 / Non-goals)

- GitHub/GitLab API integration (git-only)
- CI/CD integration
- Automatic PR creation (prints commands/links instead)
- Branch protection rule management
- Multi-initiative support (one active initiative at a time per repo)

---

## Configuration

### Module Configuration (module.yaml)

```yaml
code: git-lens
name: "Git-Lens"
header: "Git workflow orchestration for LENS"
subheader: "Automated branching, PR gating, and workflow enforcement"
default_selected: false
extends: lens  # Indicates this extends the LENS module

install_prompts:
  - id: base_ref
    text: "Default base branch for initiatives"
    type: text
    default: main
  
  - id: auto_push
    text: "Automatically push branches on creation?"
    type: boolean
    default: true
  
  - id: state_folder
    text: "State file location"
    type: text
    default: "_bmad-output/git-lens"
  
  - id: fetch_before_validate
    text: "Always fetch before merge validation?"
    type: boolean
    default: true
```

---

## Next Steps

1. **Review this brief** — Ensure the vision is clear and complete
2. **Run create-module workflow** — Build the module structure in `_bmad/lens/extensions/git-lens/`
3. **Create Conductor agent (Casey)** — Single agent with manual commands (ST, CP, RS, SY)
4. **Create hook injection mechanism** — Define how Git-Lens intercepts LENS workflows
5. **Create core workflows** — init-initiative, start-workflow, finish-workflow, status
6. **Create feature workflows** — start-phase, finish-phase, open-lead-review, open-final-pbr
7. **Implement state management** — YAML read/write with atomic writes and corruption recovery
8. **Implement error handling** — No remote, push failures, state/git mismatch
9. **Add Compass integration** — Reviewer suggestions per PR type
10. **Test end-to-end** — Full initiative lifecycle including error scenarios

---

_Brief created on 2026-02-01 using the BMAD Module workflow (YOLO mode)_
