```prompt
---
description: Run LENS Workbench preflight check and activate Compass for lifecycle navigation
---

# LENS Workbench System Preflight Check & Activation

## Phase 0: User Profile Gate

**FIRST: Check for user profile:**

```bash
Check for file: _bmad-output/lens-work/personal/profile.yaml
```

### IF FILE DOES NOT EXIST:

**Display this message:**
```
🔭 Welcome to LENS Workbench!

No user profile detected. You need to complete onboarding first.

Starting onboarding now...
```

**Then IMMEDIATELY load and execute:**
```
_bmad/lens-work/prompts/lens-work.onboard.prompt.md
```

**DO NOT proceed to Phase 1. STOP HERE and run the onboard prompt.**

---

### IF FILE EXISTS:

Profile found. Proceed to Phase 1 below.

---

## Phase 0.5: Daily Sync Check (Optional)

### 0.1 Load User Profile
- [ ] Check for profile: `_bmad-output/personal/profile.yaml`
- [ ] Load last sync timestamp from `profile.lens_work.last_sync.date`
- [ ] Compare to today's date

### 0.2 Decide Sync Action
```
if profile.lens_work.last_sync.date == today:
  ✅ Already synced today
  └── Use cached branch selection from profile
  
else:
  ⚠️  First sync today
  └── [1] Run sync-and-select-branch workflow (recommended)
      [2] Skip and continue with cached selection
      [3] Skip sync entirely
```

### 0.3 If User Selects [1] Sync
- Invoke: `{project-root}/_bmad/lens-work/workflows/utility/sync-and-select-branch/workflow.md`
- Pass: active_initiative, target_repo from state
- Receive: selected_branch, commit_date, commit_hash
- Proceed to Phase 1 with freshly selected branch

> **Note:** Profile-tracked sync runs at most once per day per user. Use `/sync-now` command in Compass to force immediate re-sync after first run.

---

## Phase 1: Core System Check

### 1.1 Module Configuration
- [ ] Check for module config: `_bmad/lens-work/module.yaml`
- [ ] Check for Compass agent: `_bmad/lens-work/agents/compass.agent.yaml`
- [ ] Check for state directory: `_bmad-output/lens-work/`

### 1.2 Agent Roster
- [ ] Compass (Phase Router) — `agents/compass.agent.yaml`
- [ ] Casey (Git Conductor) — `agents/casey.agent.yaml`
- [ ] Tracey (State Manager) — `agents/tracey.agent.yaml`
- [ ] Scout (Bootstrap & Discovery) — `agents/scout.agent.yaml`

### 1.3 Core Workflows
- [ ] `workflows/router/pre-plan/` — Analysis phase
- [ ] `workflows/router/spec/` — Planning phase
- [ ] `workflows/router/plan/` — Solutioning phase
- [ ] `workflows/router/review/` — Gate phase
- [ ] `workflows/router/dev/` — Implementation phase
- [ ] `workflows/discovery/repo-discover/` — Repo inventory
- [ ] `workflows/utility/bootstrap/` — Initial setup

## Phase 2: State Check (Two-File Pattern)

### 2.1 Active Initiative
- [ ] Check for state file: `_bmad-output/lens-work/state.yaml` (active initiative pointer)
- [ ] Check for initiative configs: `_bmad-output/lens-work/initiatives/{initiative_id}.yaml`
- [ ] Check for event log: `_bmad-output/lens-work/event-log.jsonl`
- [ ] Detect current phase and branch from active initiative config

### 2.2 Repo Inventory
- [ ] Check for repo inventory: `_bmad-output/lens-work/repo-inventory.yaml`
- [ ] Check TargetProjects path from config

## Phase 3: Activate Compass

**Profile has been confirmed in Phase 0. Proceed with activation:**
1. Load profile from `_bmad-output/lens-work/personal/profile.yaml`
2. Load Compass agent: `_bmad/lens-work/agents/compass.agent.yaml`
3. Display preflight check results and status
4. Show available commands based on current state

If state exists, show current position:
```
📍 Current Position
├── Initiative: {id}
├── Phase: {phase}
├── Workflow: {workflow}
└── Next: {recommendation}
```

**Additional Commands:**
- `/switch` — Switch between active initiatives
- `/context` — Display full current context
- `[onboard]` — First-time user onboarding walkthrough

```
