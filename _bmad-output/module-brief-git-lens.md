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

**Two-Agent Architecture** — Git-Lens splits responsibilities between automation and diagnostics for clear separation of concerns and robust error handling.

**Rationale:** Separating git operations from state management provides:
- **Clear boundaries** — Casey handles git, Tracey handles state
- **Better error recovery** — State corruption doesn't tangle with git operations
- **User control** — Manual diagnostics/overrides separate from auto-triggers
- **Maintainability** — Two focused agents vs. one complex agent

### Agent Roster

| Agent | Name | Role | Expertise |
|-------|------|------|-----------|
| **Conductor** | Casey | Git Branch Orchestrator | Git operations, branch creation/push, PR link generation, workflow coordination |
| **State Manager** | Tracey | State & Diagnostics Specialist | State persistence, status reports, recovery, validation overrides, event log management |

### Agent Interaction Model

**Casey (Conductor)** operates **automatically** via LENS workflow hooks:
- **Auto on LENS trigger** → `init-initiative` creates branch structure
- **Auto on workflow start** → `start-workflow` creates/checks out workflow branch (with gating)
- **Auto on workflow complete** → `finish-workflow` handles commits + push + prints PR link
- **Auto on phase boundaries** → `start-phase`, `finish-phase` manage phase branches
- **Auto on review gates** → `open-lead-review`, `open-final-pbr` print PR links

**Tracey (State Manager)** is **user-activated** for diagnostics and control:
- `ST` — Status (current state, blocks, next steps)
- `RS` — Resume (rehydrate from state, explain context)
- `SY` — Sync (fetch + re-validate + update state)
- `FIX` — Fix state corruption (reconstruct from event log)
- `OVERRIDE` — Force-continue (escape hatch for false blocks)
- `REVIEWERS` — Show suggested reviewers (via Compass)
- `RECREATE` — Recreate missing branches from state

**User invocation:** `@tracey ST` or activate Tracey agent directly

**The user doesn't orchestrate Git-Lens — Git-Lens orchestrates itself. Tracey provides visibility and control when needed.**

### Hook/Trigger Mechanism

**How Git-Lens extends LENS workflows:**

Git-Lens uses a **hook file pattern** (no LENS code modification):

1. **Hook files location:**
   ```
   _bmad/lens/extensions/git-lens/hooks/
     ├── before-initiative.md
     ├── before-workflow.md
     ├── after-workflow.md
     ├── before-phase.md
     └── after-phase.md
   ```

2. **LENS workflows check for extension:**
   ```
   IF directory exists: _bmad/lens/extensions/git-lens/
   THEN load and execute: hooks/before-initiative.md
   ```

3. **Hook execution points:**
   - `before-initiative.md` — Executes before LENS workflow begins (runs `init-initiative`)
   - `before-workflow.md` — Executes at workflow step entry (runs `start-workflow` with validation)
   - `after-workflow.md` — Executes at workflow completion (runs `finish-workflow`)
   - `before-phase.md` / `after-phase.md` — Execute at phase boundaries

4. **Extension manifest registration:**
   ```yaml
   # In module.yaml
   extends: lens
   extension_type: hooks
   hook_registration:
     - hook: before-initiative
       trigger: "#file:new-service,#file:new-microservice,#file:new-feature"
       file: "hooks/before-initiative.md"
   ```

**No modification to LENS core.** True extension pattern.

### Agent Menus

**Tracey (State Manager) — Manual Commands:**

| Cmd | Trigger | Action |
|-----|---------|--------|
| `ST` | "status", "where am I" | Show current state, blocks, next steps, branch topology |
| `RS` | "resume", "continue" | Rehydrate from state, checkout correct branch, explain context |
| `SY` | "sync", "fetch" | Background fetch, re-validate state, update to match remote reality |
| `FIX` | "fix", "recover" | Reconstruct state from event log or git branches |
| `OVERRIDE` | "override", "force" | Bypass merge validation (power user escape hatch) |
| `REVIEWERS` | "reviewers", "who" | Query Compass for suggested reviewers by PR type |
| `RECREATE` | "recreate", "restore" | Recreate missing branches from state definitions |
| `ARCHIVE` | "archive", "finish" | Archive completed initiative, clean up state |

**Casey (Conductor) — No Direct Menu (Auto-Triggered Only)**

Casey operates automatically via hooks. Users interact with Tracey for manual control.

### Agent Communication Styles

**Casey (Conductor):**
- **Tone:** Professional, concise, reliable — like a senior release engineer
- **Style:** Short confirmations, clear status, no unnecessary flourish
- **Output:** Actionable (PR links, commands, next steps)
- **Metaphors:** Minimal use of conductor/railroad themes (backstory only, not in regular output)

**Example interactions:**
- "✅ Initiative branches created. Phase 1 ready."
- "✅ Workflow branch ready: `small/p1/w/discovery`"
- "⛔ BLOCKED: Workflow `requirements` not merged. PR: [url] — Merge before continuing."

**Tracey (State Manager):**
- **Tone:** Clinical, diagnostic, methodical — like a forensic analyst
- **Style:** Structured reports, precise status, clear recovery paths
- **Output:** Diagnostic (state summaries, validation results, recovery options)
- **Focus:** Where you are, how you got here, what to do next

**Example interactions:**
```
📍 CURRENT STATUS

Initiative: payment-gateway-20260201
Lane: small | Phase: p1 | Workflow: discovery (in_progress)

Branch: lens/payment-gateway-20260201/small/p1/w/discovery
Last push: 5 minutes ago | Remote: ✅ synced

BRANCH TOPOLOGY:
  base ← lead ← small ← p1 ← [YOU ARE HERE: w/discovery]

BLOCKS: None
NEXT: Finish workflow to open PR → p1
```

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
| **filesystem** | State file read/write, event log append |

### External Services

**Git CLI** (required):
- `git checkout -b` — Create branches
- `git push -u origin` — Push branches
- `git fetch origin` — Update remote refs (background + on-demand)
- `git merge-base --is-ancestor` — Primary validation strategy
- `git rev-parse HEAD` — Get current commit SHA
- `git rev-parse --verify` — Check if branch exists
- `git status --porcelain` — Detect uncommitted changes
- `git symbolic-ref HEAD` — Detect detached HEAD
- `git remote -v` — Validate remote configuration

**Git Pre-Flight Checks:**
- `git rev-parse --git-dir` — Verify git repo exists
- `[ -f .git/shallow ]` — Detect shallow clone
- `git rev-parse --show-superproject-working-tree` — Detect submodule

**No GitHub/GitLab API required for core operations.** PR links are printed for manual creation or use platform CLI (`gh pr create`, `glab mr create`).

Optional GitHub/GitLab API for enhanced validation (Strategy 2 in validation cascade).

### Git Fetch Strategy

**CRITICAL: Background fetch + cached refs (not synchronous blocking)**

1. **Background fetch process:**
   - Spawned on first validation check
   - Runs `git fetch origin` every 60 seconds (configurable: `fetch_ttl`)
   - Updates cached ref SHAs with timestamp

2. **Validation flow:**
   ```
   IF cached_refs_age < fetch_ttl (default: 60s)
     THEN use cached refs (instant)
   ELSE
     THEN fetch now (blocking, but rare)
   ```

3. **User-triggered fetch:**
   - `@tracey SY` forces immediate fetch + validation
   - Updates cache and state

4. **Configuration:**
   ```yaml
   fetch_strategy: background  # background | sync | manual
   fetch_ttl: 60               # seconds
   ```

**Result:** Most validations are instant (cached). Network calls happen in background or on-demand.

### Integrations with Other Modules

| Module | Integration |
|--------|-------------|
| **LENS Core** | Triggered by `#file:new-service`, `#file:new-microservice`, `#file:new-feature` via hook injection or launcher wrapper |
| **Lens Compass** | Query reviewer roster file, filter by role (implementer/lead/architect), output suggested reviewers + rationale per PR type |
| **BMAD Core** | Respects `_bmad-output/` conventions, uses config.yaml |

### Compass Integration Details

**Mechanism:** Git-Lens queries Compass roster for reviewer suggestions filtered by role.

**Required Compass Contract:**
```yaml
compass_integration:
  required_fields:
    - username      # For @mentions in PR suggestions
    - role          # For filtering: implementer|tech-lead|architect|pm
    - initiative    # Optional: scope to specific initiatives
  file_format: CSV or YAML
  fallback_behavior: Silent skip (no reviewers suggested)
```

**Reviewer Suggestion Timing:**
- **Auto-printed** with PR link if Compass available
- **On-demand** via `@tracey REVIEWERS` command
- **Silently skipped** if Compass not installed/configured

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

**Testing without Compass:**
Mock data location: `_bmad/lens/extensions/git-lens/test-data/mock-compass.csv`

---

## Branch Model Specification

### Branch Naming Convention

```
lens/<initiative>/<lane>/<phase>/w/<workflow>

Examples:
- lens/pmt-gateway-a3f2b9/base                    # Initiative base (shortened slug)
- lens/pmt-gateway-a3f2b9/small                   # Small-table review lane
- lens/pmt-gateway-a3f2b9/lead                    # Lead/architect review lane
- lens/pmt-gateway-a3f2b9/small/p1                # Phase 1 branch
- lens/pmt-gateway-a3f2b9/small/p2                # Phase 2 branch
- lens/pmt-gateway-a3f2b9/small/p1/w/discovery    # Workflow branch
```

**Branch Path Budget:** Max 80 characters total (for Windows compatibility with remote refs)

### Branch Creation Order & Timing

1. **Base branch** — `lens/<initiative>/base` (from configurable `base_ref`, default: `main`)
2. **Audience lanes** — `small` and `lead` (from base)
3. **Phase 1 branch** — `small/p1` (eager creation at initiative start)
4. **Phase N branches** — `small/pN` (lazy creation on first workflow of that phase)
5. **Workflow branches** — `small/pN/w/<name>` (from active phase, with gating)

**Eager vs. Lazy:**
- **p1 created eagerly** (at initiative start) — Guarantees user has immediate workspace
- **p2+ created lazily** (when first workflow of that phase starts) — Avoids clutter

### Initiative Slug Generation

**Algorithm:**
```
slug = sanitize(initiative_name) + "-" + short_hash(initiative_name + timestamp)

Examples:
- #file:new-service "Payment Gateway"           → pmt-gateway-a3f2b9
- #file:new-feature "User Authentication"       → usr-auth-7k2m4p
- #file:new-service "Payment Gateway" (retry)   → pmt-gateway-x9q5n1  # Different hash
```

**Rules:**
- Sanitize: lowercase, spaces→hyphens, remove special chars
- Abbreviate: Truncate to ~15 chars, keep words readable
- Short hash: 6-char hex (from name + timestamp) for uniqueness
- Total branch path budget: 80 characters

**Collision Handling:**
Collisions impossible (hash includes timestamp). If branch exists:
- Check state.yaml for initiative match
- If match → resume (idempotent)
- If mismatch → ERROR with clear message

### Branch Collision Handling (Idempotency)

**If branch already exists:**

| Scenario | Action |
|----------|--------|
| Base branch exists, state.yaml matches | Resume existing initiative (idempotent ✅) |
| Base branch exists, no state.yaml | ERROR: "Initiative branch exists but no state found. Run `@tracey FIX` to reconstruct or archive manually." |
| Base branch exists, state.yaml doesn't match | ERROR: "Initiative branch exists but belongs to different initiative. Archive old initiative first." |
| Workflow branch exists for current workflow | Resume on that branch (idempotent ✅) |
| Workflow branch exists for different workflow | ERROR: "Workflow branch naming conflict. Complete or archive existing workflow first." |
| Remote branch exists, local doesn't | Fetch, validate state, checkout (reconstruct from remote ✅) |

**Multi-Initiative Conflict:**
| Scenario | Action |
|----------|--------|
| User starts new initiative while one active | ERROR: "Active initiative `{slug}` exists. Complete via `@tracey ARCHIVE` or finish PRs before starting new initiative." |

**Principle:** Prefer resumption over failure. Error only when state is truly inconsistent or would corrupt existing work.

### PR Merge Topology

```
w/<workflow>  →  small/p{N}     (workflow PR)
small/p{N}    →  small          (phase PR)
small         →  lead           (lead review PR)
lead          →  base           (final PBR PR)
```

---

## State Persistence

### Dual Persistence Strategy

Git-Lens uses **two persistence mechanisms** for resilience:

1. **Primary: state.yaml** — Current state snapshot (fast read/write)
2. **Backup: event-log.jsonl** — Append-only operation log (corruption-proof)

**Recovery:** If state.yaml corrupted, rebuild from event log. If event log missing, reconstruct from git branches.

### State File Location

```
_bmad-output/git-lens/
  ├── state.yaml           # Current state
  ├── state.yaml.bak       # Automatic backup (on corruption)
  └── event-log.jsonl      # Append-only event log
```

### State Schema (state.yaml)

Note: `current.status` reflects local workflow progress; `workflow_status.<phase>.<workflow>.status` reflects merge completion. When `blocked.is_blocked` is true, set `current.status: blocked`; when unblocked, return to `in_progress`.

```yaml
version: 2  # Schema version for future migrations

initiative:
  slug: pmt-gateway-a3f2b9
  name: "Payment Gateway"
  base_ref: main
  created_at: 2026-02-01T19:00:00Z

branches:
  base: lens/pmt-gateway-a3f2b9/base
  small: lens/pmt-gateway-a3f2b9/small
  lead: lens/pmt-gateway-a3f2b9/lead

current:
  lane: small
  phase: p1
  workflow: discovery
  branch: lens/pmt-gateway-a3f2b9/small/p1/w/discovery
  status: in_progress  # not_started | in_progress | completed | blocked

fetch_cache:
  # Cached remote ref SHAs for validation
  refs:
    "origin/lens/pmt-gateway-a3f2b9/small/p1": "abc123..."
  last_fetch: 2026-02-01T19:30:00Z
  ttl: 60  # seconds

workflow_status:
  # Track merge status, NOT SHAs (handles rebase/squash); key by phase to avoid name collisions
  p1:
    discovery:
      status: merged  # not_started | in_progress | merged
      branch: lens/pmt-gateway-a3f2b9/small/p1/w/discovery
      merged_at: 2026-02-01T20:00:00Z
      merge_strategy: ancestry_check  # ancestry_check | pr_metadata | manual_override
      pr_url: https://github.com/org/repo/pull/123

phase_status:
  p1:
    status: in_progress
    started_at: 2026-02-01T19:00:00Z

blocked:
  is_blocked: false
  reason: null
  blocking_branch: null
  unblock_command: null
  blocked_since: null
```

### Event Log Schema (event-log.jsonl)

```jsonl
{"ts":"2026-02-01T19:00:00Z","event":"init-initiative","slug":"pmt-gateway-a3f2b9","name":"Payment Gateway"}
{"ts":"2026-02-01T19:05:00Z","event":"start-workflow","workflow":"discovery","branch":"lens/pmt-gateway-a3f2b9/small/p1/w/discovery"}
{"ts":"2026-02-01T19:30:00Z","event":"finish-workflow","workflow":"discovery","sha":"abc123","pr_url":"https://..."}
{"ts":"2026-02-01T20:00:00Z","event":"merge-detected","workflow":"discovery","strategy":"ancestry_check"}
{"ts":"2026-02-01T20:05:00Z","event":"start-workflow","workflow":"requirements","branch":"lens/pmt-gateway-a3f2b9/small/p1/w/requirements"}
```

**Append-only:** Never modified after write. Corruption-proof. Used for state reconstruction.

### State Reconstruction (Recovery)

**Recovery Cascade:** Try multiple strategies in order:

1. **Strategy 1: Rebuild from Event Log**
   - Parse event-log.jsonl (append-only, corruption-proof)
   - Replay events to rebuild state
   - WARN: "State reconstructed from event log. Validating against git..."

2. **Strategy 2: Scan Git Branches**
   - Find branches matching `lens/*/base` pattern
   - Identify initiative from branch naming
   - Determine current phase/workflow from branch names
   - Run validation to determine merge status
   - WARN: "State reconstructed from git branches. PR URLs and timestamps not recoverable."

3. **Strategy 3: User-Guided Recovery**
   - If both fail, enter recovery mode
   - Tracey asks user: "Which initiative are you working on? Where are you in the workflow?"
   - Build state from user responses
   - WARN: "State manually reconstructed. Verify accuracy before continuing."

**Invocation:** `@tracey FIX` triggers recovery cascade.

---

## Enforcement Rules

### Validation Cascade (Multi-Strategy)

Instead of relying solely on ancestry checks, Git-Lens uses a **validation cascade** that degrades gracefully:

**Validation Flow:**
```
1. Strategy 1: Ancestry Check (git merge-base --is-ancestor)
   ↓ PASS → Allow workflow start
   ↓ FAIL → Try Strategy 2

2. Strategy 2: PR Metadata Check (optional, requires API)
   ↓ Check if PR exists and is merged via GitHub/GitLab API
   ↓ PASS → Allow workflow start
   ↓ FAIL or API unavailable → Try Strategy 3

3. Strategy 3: Manual Override
   ↓ User confirms: @tracey OVERRIDE "requirements merged via squash"
   ↓ PASS → Allow workflow start with warning
   ↓ NOT SET → BLOCK with clear explanation
```

**Configuration:**
```yaml
validation_cascade: ancestry_only | with_pr_api | with_override
pr_api_enabled: false  # Requires GitHub/GitLab API token
```

**Result:** Handles rebase, squash merge, force-push gracefully. Always provides escape hatch.

### Hard Blocks

| Trigger | Condition | Block Message | Escape Hatch |
|---------|-----------|---------------|--------------|
| `start-workflow` | Previous workflow not merged (all strategies fail, no override) | "⛔ BLOCKED: Workflow `X` not merged. PR: [url]. Merge or run `@tracey OVERRIDE`" | `@tracey OVERRIDE` |
| `start-phase` (p2+) | Previous phase not complete (not merged into lane) | "⛔ BLOCKED: Phase `p{N-1}` not complete. Finish phase PR first." | `@tracey OVERRIDE` |
| `init-initiative` | Active initiative exists | "⛔ BLOCKED: Active initiative `{slug}` exists. Archive via `@tracey ARCHIVE` first." | Archive old initiative |
| Any git operation | Not a git repository | "⛔ ERROR: Not a git repository. Run `git init` or disable Git-Lens." | None (hard error) |

### Soft Warnings (Operations Continue)

| Condition | Warning | Degraded Behavior |
|-----------|---------|-------------------|
| No remote configured | "⚠️ No remote configured. Branches created locally. Push manually when ready." | Branches created locally, push skipped |
| Remote push fails (auth) | "⚠️ Push failed (auth). Branch created locally. Fix credentials, then `@tracey SY`" | Local branch exists, state marked `needs_push: true` |
| Remote push fails (network) | "⚠️ Push failed (network). Branch created locally. Retry with `@tracey SY`" | Local branch exists, state marked `needs_push: true` |
| Shallow clone detected | "⚠️ Shallow clone detected. Ancestry validation unreliable. Consider `git fetch --unshallow`" | Validation may fail, manual override available |
| Fetch fails | "⚠️ Fetch failed. Using cached refs (age: {N}s). May be stale." | Uses cached refs from last successful fetch |

### Smart Commit Strategy

**Problem:** Automatic commits are dangerous (conflicts, partial staging).

**Solution:** Commit strategies with user control:

1. **Check git status** — `git status --porcelain`
2. **If clean** — Nothing to commit, proceed to push
3. **If dirty** — Present options:

   ```
   ⚠️ Uncommitted changes detected.
   
   [A] Auto-commit with template message
   [M] Manual commit (pause, let me commit, then continue)
   [S] Stash changes (stash + continue, recover later)
   [C] Cancel (don't finish workflow yet)
   ```

4. **Configuration:**
   ```yaml
   commit_strategy: prompt | always | never
   commit_template: "git-lens: {workflow} workflow complete"
   ```

**Default:** `prompt` (always ask user)

### Error Handling & Recovery

**Error Budget:** Classify errors by severity and recovery path.

| Error Condition | Detection | Error Class | Recovery Action |
|-----------------|-----------|-------------|-----------------|
| **No git repo** | `git rev-parse --git-dir` fails | HARD | ERROR: "Not a git repository. Run `git init` or disable Git-Lens." STOP. |
| **No remote** | `git remote -v` empty | SOFT | WARN: Create branches locally, set `needs_push: true` |
| **Push fails (auth)** | `git push` exit code 128 | SOFT | WARN: Branch created locally, guide user to fix auth |
| **Push fails (network)** | `git push` timeout | SOFT | WARN: Branch created locally, retry available via `@tracey SY` |
| **Fetch fails (network)** | `git fetch` timeout | SOFT | WARN: Use cached refs, mark as potentially stale |
| **State.yaml missing** | File not found | RECOVERABLE | Run recovery cascade (event log → git scan → user-guided) |
| **State.yaml corrupted** | YAML parse error | RECOVERABLE | Backup to .bak, run recovery cascade |
| **State/git mismatch** | Branch in state doesn't exist | RECOVERABLE | Sync state to match git reality, WARN user |
| **Shallow clone** | `.git/shallow` exists | SOFT | WARN: Ancestry validation unreliable, suggest unshallow |
| **Detached HEAD** | `git symbolic-ref HEAD` fails | SOFT | WARN: Checkout a branch before continuing |
| **Multiple remotes** | >1 remote in `git remote -v` | SOFT | Use configured `remote_name` (default: origin), WARN if not found |
| **Submodule repo** | Superproject detected | SOFT | Adjust remote detection, continue with warnings |
| **Dirty working dir** | `git status --porcelain` non-empty | SOFT | On auto-commit: prompt user for strategy (see Smart Commit) |
| **Merge conflict** | Detect via git status | SOFT | WARN: "PR merge incomplete. Resolve conflicts, complete merge, then `@tracey SY`" |
| **Force push detected** | Cached ref SHA doesn't match remote | SOFT | WARN: "Branch history changed. Re-validating..." Force re-fetch |

**Principle:** Never leave user in broken state. Always provide clear recovery path.

### Blocked UX Flow

When a block is detected:

1. **HALT** the current operation (do not proceed)
2. **DISPLAY** block message with:
   - What is blocked (e.g., "Cannot start workflow 'requirements'")
   - Why it's blocked (e.g., "Previous workflow 'discovery' not merged")
   - Validation strategy that failed (ancestry | pr_metadata | manual_override)
   - The blocking branch and target branch
   - PR URL if known (from state workflow_status)
   - Exact command to create PR if URL not known
   - **Escape hatch:** "Run `@tracey OVERRIDE` to force-continue" (defaults to current phase; use `@tracey OVERRIDE p1.discovery` to target a specific phase/workflow)
3. **UPDATE STATE** — Set `blocked.is_blocked: true` with details and `current.status: blocked`
4. **WAIT** — Do not automatically retry
5. **UNBLOCK** — Clear `blocked.*` and set `current.status: in_progress`

**Example block message:**
```
⛔ BLOCKED: Cannot start workflow 'requirements'

Reason: Previous workflow 'discovery' not merged into phase branch
Validation: ancestry_check FAILED

Blocking: lens/pmt-gateway-a3f2b9/small/p1/w/discovery
Target:   lens/pmt-gateway-a3f2b9/small/p1
PR:       https://github.com/org/repo/pull/123

ACTION REQUIRED:
1. Merge the PR above, OR
2. Run `@tracey OVERRIDE "discovery merged via squash"` to bypass

Then run `@tracey SY` to re-validate and continue.
```

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
AND state.yaml + event-log.jsonl are created
AND user sees: "✅ Initiative 'pmt-gateway-a3f2b9' created. Phase 1 ready."
```

**AC-2: Workflow Branch Creation**
```
GIVEN an active initiative with no previous workflows OR previous workflow merged
WHEN LENS workflow begins (e.g., discovery)
THEN Git-Lens creates branch small/p1/w/discovery from phase branch
AND checks out the new branch
AND state.yaml current.workflow is updated
AND event logged to event-log.jsonl
AND user sees: "✅ Workflow branch ready: small/p1/w/discovery"
```

**AC-3: Workflow Merge Gate (Block)**
```
GIVEN workflow 'discovery' exists but is NOT merged into phase branch
AND all validation strategies fail (ancestry, pr_api if enabled)
AND no manual override set
WHEN user attempts to start workflow 'requirements'
THEN operation is BLOCKED
AND user sees: "⛔ BLOCKED: Workflow 'discovery' not merged. PR: [url]. Merge or run @tracey OVERRIDE"
AND state.yaml blocked section is populated
AND no new branch is created
```

**AC-4: Workflow Merge Gate (Pass)**
```
GIVEN workflow 'discovery' HEAD is ancestor of phase branch HEAD (merged)
WHEN user attempts to start workflow 'requirements'
THEN merge gate passes (ancestry_check strategy)
AND new workflow branch is created normally
AND merge logged to event-log.jsonl
```

**AC-5: Finish Workflow with Smart Commit**
```
GIVEN user is on workflow branch with uncommitted changes
AND commit_strategy = prompt (default)
WHEN LENS workflow completes
THEN Git-Lens detects uncommitted changes
AND prompts user: [A]uto-commit [M]anual [S]tash [C]ancel
AND waits for user choice
AND proceeds based on choice
AND pushes the workflow branch (if not cancelled)
AND prints PR link/command targeting phase branch
AND state.yaml workflow_status updated
AND event logged
```

**AC-6: Background Fetch with Cache**
```
GIVEN fetch_strategy = background (default)
AND last successful fetch was 30 seconds ago
WHEN Git-Lens checks merge ancestry
THEN uses cached refs (no network call)
AND validation completes instantly
AND if cache > ttl (60s), spawns background fetch for next time
```

**AC-7: Validation Cascade - Rebase Scenario**
```
GIVEN workflow 'discovery' was rebased and merged (ancestry check FAILS)
AND validation_cascade = with_pr_api
AND GitHub API shows PR #123 merged
WHEN user attempts to start workflow 'requirements'
THEN ancestry_check FAILS
AND pr_metadata_check PASSES
AND workflow allowed to start
AND merge_strategy logged as 'pr_metadata'
```

**AC-8: Manual Override (Escape Hatch)**
```
GIVEN workflow 'discovery' merged via squash (ancestry fails, no API)
AND validation_cascade = with_override
WHEN user runs: @tracey OVERRIDE "discovery merged via squash"
THEN override recorded in state.yaml
AND next workflow start bypasses validation for that workflow
AND merge_strategy logged as 'manual_override'
```

**AC-9: State Corruption Recovery**
```
GIVEN state.yaml is corrupted (YAML parse error)
WHEN Git-Lens attempts to read state OR user runs @tracey FIX
THEN original file backed up to state.yaml.bak
AND recovery cascade starts: event log → git scan → user-guided
AND IF event log valid THEN state rebuilt from event log
AND user sees: "⚠️ State reconstructed from event log."
```

**AC-10: Multi-Initiative Conflict**
```
GIVEN active initiative 'pmt-gateway-a3f2b9' exists (state.yaml present)
WHEN user triggers #file:new-service "User Auth"
THEN init-initiative is BLOCKED
AND user sees: "⛔ BLOCKED: Active initiative 'pmt-gateway-a3f2b9' exists. Complete via @tracey ARCHIVE first."
```

**AC-11: Remote Branch Exists (Resume from Remote)**
```
GIVEN initiative branch 'lens/pmt-gateway-a3f2b9/base' exists on remote but not locally
AND state.yaml missing or doesn't match
WHEN Git-Lens runs OR user runs @tracey FIX
THEN Git-Lens fetches remote branches
AND reconstructs state from remote branch names
AND checks out appropriate branch
AND user sees: "✅ Resumed initiative from remote branches."
```

**AC-12: No Remote Warning (Degraded Mode)**
```
GIVEN git repository has no remote configured
WHEN Git-Lens attempts to push
THEN operation continues (branch created locally)
AND state marked: needs_push: true
AND user sees: "⚠️ No remote configured. Branch created locally. Push manually when ready."
```

**AC-13: Shallow Clone Detection**
```
GIVEN git repository is shallow clone (.git/shallow exists)
WHEN Git-Lens validates merge ancestry
THEN ancestry check likely fails
AND user sees: "⚠️ Shallow clone detected. Ancestry validation unreliable. Consider `git fetch --unshallow` or use @tracey OVERRIDE"
```

**AC-14: Detached HEAD Warning**
```
GIVEN user is in detached HEAD state
WHEN LENS workflow attempts to start
THEN Git-Lens detects detached HEAD
AND user sees: "⚠️ Currently in detached HEAD. Checkout a branch first."
AND operation BLOCKED (hard error)
```

**AC-15: Event Log Persistence**
```
GIVEN any Git-Lens operation completes (success or failure)
WHEN operation finishes
THEN event appended to event-log.jsonl with timestamp, event type, key data
AND append is atomic (write to temp, rename)
```

### Should Have (v1)

- [x] Two-agent architecture (Casey + Tracey)
- [x] Background fetch + cached refs (not sync blocking)
- [x] Validation cascade (ancestry → pr_api → manual override)
- [x] Smart commit with user control (not automatic)
- [x] Event log for corruption-proof recovery
- [x] Manual override escape hatch (`@tracey OVERRIDE`)
- [x] Comprehensive error handling (hard/soft/recoverable)
- [x] Edge case handling (shallow clone, detached HEAD, submodules, multiple remotes)
- [x] State recovery cascade (event log → git scan → user-guided)
- [x] Multi-initiative conflict detection
- [x] Reviewer suggestions via Compass integration (with mock data for testing)
- [x] Configurable fetch strategy, commit strategy, validation cascade
- [x] Branch path budget enforcement (80 chars for Windows compatibility)
- [x] Hook file pattern (no LENS code modification)
- [x] Uninstall strategy (archive state, preserve branches, deregister hooks)

### Won't Have (v1 / Non-goals)

- Automatic PR creation (prints commands/links instead)
- CI/CD integration
- Branch protection rule management
- Multi-initiative parallel support (one active at a time)
- Real-time collaboration (multi-user conflict resolution)
- Git LFS support
- Monorepo-specific features

---

## Configuration

### Module Configuration (module.yaml)

```yaml
code: git-lens
name: "Git-Lens"
header: "Git workflow orchestration for LENS"
subheader: "Automated branching, PR gating, and workflow enforcement"
default_selected: false
location: "_bmad/lens/extensions/git-lens"
extends: lens  # Indicates this extends the LENS module

extension_type: hooks
hook_registration:
  - hook: before-initiative
    trigger: "#file:new-service,#file:new-microservice,#file:new-feature"
    file: "hooks/before-initiative.md"
  - hook: before-workflow
    trigger: "workflow-start"
    file: "hooks/before-workflow.md"
  - hook: after-workflow
    trigger: "workflow-complete"
    file: "hooks/after-workflow.md"

install_prompts:
  - id: base_ref
    text: "Default base branch for initiatives"
    type: text
    default: main
  
  - id: auto_push
    text: "Automatically push branches on creation?"
    type: boolean
    default: true
  
  - id: remote_name
    text: "Git remote name to use"
    type: text
    default: origin
  
  - id: fetch_strategy
    text: "Fetch strategy for remote validation"
    type: select
    options: [background, sync, manual]
    default: background
  
  - id: fetch_ttl
    text: "Fetch cache TTL (seconds)"
    type: number
    default: 60
  
  - id: commit_strategy
    text: "Auto-commit strategy for workflow completion"
    type: select
    options: [prompt, always, never]
    default: prompt
  
  - id: validation_cascade
    text: "Merge validation strategy"
    type: select
    options: [ancestry_only, with_pr_api, with_override]
    default: ancestry_only
    help: "ancestry_only=git only, with_pr_api=use GitHub/GitLab API, with_override=allow manual override"
  
  - id: pr_api_enabled
    text: "Enable GitHub/GitLab API for PR validation?"
    type: boolean
    default: false
    depends_on: validation_cascade=with_pr_api
  
  - id: state_folder
    text: "State file location"
    type: text
    default: "_bmad-output/git-lens"
  
  - id: event_log_enabled
    text: "Enable event log for state recovery?"
    type: boolean
    default: true

uninstall:
  state_files: move_to_archive  # Move _bmad-output/git-lens/ to _bmad-archive/git-lens/
  branches: preserve            # User's git branches remain untouched
  hooks: deregister             # Remove hook registrations from LENS
  warning: "Existing initiative branches and PRs will require manual cleanup."
```

---

## Next Steps

1. **Review this updated brief** — All adversarial panel recommendations integrated
2. **Run create-module workflow** — Build the module structure in `_bmad/lens/extensions/git-lens/`
3. **Create agent files:**
   - **Casey (Conductor)** — Auto-triggered git operations agent
   - **Tracey (State Manager)** — Manual diagnostics and control agent
4. **Create hook files** — before-initiative.md, before-workflow.md, after-workflow.md
5. **Create core workflows:**
   - init-initiative, start-workflow, finish-workflow
   - start-phase, finish-phase
   - open-lead-review, open-final-pbr
6. **Create Tracey workflows:**
   - status, resume, sync, fix, override, reviewers, recreate, archive
7. **Implement state management:**
   - Dual persistence (state.yaml + event-log.jsonl)
   - Atomic writes with backup on corruption
   - Recovery cascade (event log → git scan → user-guided)
8. **Implement validation cascade:**
   - Strategy 1: Ancestry check (git merge-base)
   - Strategy 2: PR metadata check (optional GitHub/GitLab API)
   - Strategy 3: Manual override
9. **Implement background fetch:**
   - Cached refs with TTL
   - Background fetch process
   - On-demand fetch via `@tracey SY`
10. **Implement error handling:**
    - Error budgets (hard/soft/recoverable)
    - Graceful degradation for all soft errors
    - Clear recovery paths for all error scenarios
11. **Implement smart commit:**
    - Detect uncommitted changes
    - Prompt user for strategy (auto/manual/stash/cancel)
    - Configuration: commit_strategy (prompt/always/never)
12. **Add Compass integration:**
    - Query reviewer roster
    - Filter by role per PR type
    - Mock data for testing
13. **Add edge case handling:**
    - Shallow clone detection + warning
    - Detached HEAD detection + block
    - Submodule detection + adjusted logic
    - Multiple remotes + configured remote_name
14. **Create comprehensive README.md:**
    - Installation, Configuration, Usage, Troubleshooting, Architecture
15. **Create TODO.md:**
    - Implementation checklist, Known issues, Future enhancements
16. **Test end-to-end:**
    - Full initiative lifecycle (happy path)
    - All error scenarios (network failures, state corruption, git edge cases)
    - Recovery scenarios (state reconstruction from event log, git scan, user-guided)
    - Multi-strategy validation (ancestry, pr_api, manual override)
    - All Tracey commands (ST, RS, SY, FIX, OVERRIDE, REVIEWERS, RECREATE, ARCHIVE)

---

## Adversarial Review Summary

**All panel concerns addressed:**

✅ **Agent Architecture** — Split into Casey (Conductor) + Tracey (State Manager)  
✅ **Hook Mechanism** — Hook files, no LENS code modification  
✅ **Network Dependency** — Background fetch + cached refs, not sync blocking  
✅ **Error Scenarios** — Comprehensive error budget with hard/soft/recoverable classes  
✅ **Automatic Commits** — Smart commit with user control, not automatic  
✅ **Validation Strategy** — Multi-strategy cascade (ancestry → pr_api → manual override)  
✅ **State Resilience** — Dual persistence (state.yaml + event-log.jsonl)  
✅ **Edge Cases** — Shallow clone, detached HEAD, submodules, multiple remotes, rebase, squash merge  
✅ **Branch Model** — Short slugs with hash, 80-char path budget, clear collision handling  
✅ **Configuration** — 11 install prompts covering all strategies and settings  
✅ **Compass Integration** — Clear contract, mock data for testing  
✅ **UX** — Professional tone (minimal train metaphors), clear status format, escape hatches  
✅ **Acceptance Criteria** — 15 comprehensive ACs covering all scenarios  
✅ **Uninstall Strategy** — Archive state, preserve branches, deregister hooks  
✅ **README/TODO** — Structure defined  
✅ **Location** — Clarified: `_bmad/lens/extensions/git-lens/`

**Status:** Ready for implementation. Module brief is production-ready.

---

_Brief updated 2026-02-01 after comprehensive adversarial review (YOLO mode)_
