---
description: Run LENS system preflight check and activate Navigator - validates all lens systems are operational before providing workflow guidance
---

# LENS System Preflight Check & Activation

Execute a comprehensive preflight check of all LENS systems, automatically initialize any installed extensions on first run, then activate Navigator for workflow guidance.

**First Run Behavior:** If no session exists (`.lens/lens-session.yaml` missing), this workflow will automatically bring all installed extensions to OPERATIONAL status by running initialization routines.

## Phase 1: Core System Preflight Check

### 1.1 LENS Core Module
- [ ] Check for module config: `_bmad/lens/module-config.yaml`
- [ ] Check for Navigator agent: `_bmad/lens/agents/navigator.agent.yaml`
- [ ] Check for session store path in config (`.lens/lens-session.yaml`)
- [ ] Validate branch patterns are defined (domain, service, microservice, feature)

### 1.2 Sidecar Memory System
Check sidecar directories exist and have valid structure:
- [ ] `_bmad/_memory/navigator-sidecar/` - Navigator persistence
- [ ] `_bmad/_memory/scout-sidecar/` - Discovery index
- [ ] `_bmad/_memory/bridge-sidecar/` - Sync state
- [ ] `_bmad/_memory/link-sidecar/` - Cross-lens linking
- [ ] `_bmad/_memory/scribe-sidecar/` - Spec governance
- [ ] `_bmad/_memory/tracey-sidecar/` - Git-lens state

### 1.3 Core Workflows
Verify essential workflows are present:
- [ ] `_bmad/lens/workflows/lens-detect/` - Context detection
- [ ] `_bmad/lens/workflows/lens-switch/` - Lens navigation
- [ ] `_bmad/lens/workflows/context-load/` - Context loading
- [ ] `_bmad/lens/workflows/lens-restore/` - Session restoration
- [ ] `_bmad/lens/workflows/workflow-guide/` - Workflow recommendations
- [ ] `_bmad/lens/workflows/bootstrap/` - Initial setup

## Phase 2: Extension Operational Readiness Checks

**Check if extensions are INSTALLED and CONFIGURED, not just if source files exist.**

### 2.1 LENS-Sync Extension (Discovery & Synchronization)

**Installation Check:**
- [ ] Check if `_bmad/_config/manifest.yaml` lists `lens-sync` as installed module
- [ ] Verify `_bmad/lens-sync/` directory exists (installation target, not source)

**Operational Readiness:**
- [ ] Bridge agent operational: `_bmad/_memory/bridge-sidecar/bridge-state.md` exists with state data
- [ ] Scout discovery run: `_bmad/_memory/scout-sidecar/scout-discoveries.md` exists and not empty
- [ ] Link mappings present: `_bmad/_memory/link-sidecar/link-state.md` exists

**Status:** `OPERATIONAL` | `INSTALLED_NOT_RUN` | `NOT_INSTALLED`

### 2.2 LENS-Compass Extension (Role-Based Navigation)

**Installation Check:**
- [ ] Check if `_bmad/_config/manifest.yaml` lists `lens-compass` as installed module
- [ ] Verify `_bmad/lens-compass/` directory exists (installation target)

**Operational Readiness:**
- [ ] Roster initialized: `.bmad-roster.yaml` exists at project root
- [ ] Personal profiles folder exists: Check configured path or default `_bmad-output/personal/`
- [ ] Git identity configured: Verify `use_git_identity` setting in installed module config
- [ ] At least one profile exists: Check for user profile files

**Status:** `OPERATIONAL` | `INSTALLED_NOT_CONFIGURED` | `NOT_INSTALLED`

### 2.3 Git-Lens Extension (Git Workflow Orchestration)

**Installation Check:**
- [ ] Check if `_bmad/_config/manifest.yaml` lists `git-lens` as installed module
- [ ] Verify `_bmad/git-lens/` directory exists (installation target)

**Operational Readiness:**
- [ ] Tracey state initialized: `_bmad/_memory/tracey-sidecar/memories.md` exists
- [ ] Event log present: Check for `event-log.jsonl` in tracey-sidecar
- [ ] Base branch configured: Verify `base_ref` in installed module config
- [ ] Git hooks registered: Check if hook files exist in `_bmad/git-lens/hooks/`

**Status:** `OPERATIONAL` | `INSTALLED_NOT_INITIALIZED` | `NOT_INSTALLED`

### 2.4 SPEC Extension (Constitutional Governance)

**Installation Check:**
- [ ] Check if `_bmad/_config/manifest.yaml` lists `spec` as installed module
- [ ] Verify `_bmad/spec/` directory exists (installation target)

**Operational Readiness:**
- [ ] Constitution root configured: Verify path in installed module config
- [ ] At least one constitution exists: Check `lens/constitutions/` for `.md` files
- [ ] Scribe agent operational: `_bmad/_memory/scribe-sidecar/scribe-state.md` exists
- [ ] Compliance check setting: Verify `auto_compliance_check` configuration

**Status:** `OPERATIONAL` | `INSTALLED_NO_CONSTITUTIONS` | `NOT_INSTALLED`

## Phase 3: Environment & Setup Status

### 3.1 Target Project Structure
- [ ] Check if `TargetProjects/` directory exists
- [ ] If exists: Ready for normal operation
- [ ] If missing: Check for `_lens/domain-map.yaml` (bootstrap data)
- [ ] Report setup state: `READY` | `NEEDS_BOOTSTRAP` | `NEEDS_SETUP`

### 3.2 Session State
- [ ] Check for existing session: `.lens/lens-session.yaml`
- [ ] If exists: Report last lens position and timestamp → **Skip Phase 5 (already initialized)**
- [ ] If missing: Fresh start detected → **Proceed to Phase 5 (auto-remediation)**

## Phase 4: Generate Preflight Report

Display a status card summarizing all checks:

```
╭──────────────────────────────────────────────────────────────╮
│  🚀 LENS SYSTEM PREFLIGHT CHECK                              │
├──────────────────────────────────────────────────────────────┤
│  CORE SYSTEMS                                                │
│  ├─ Navigator Agent........... ✅ Ready                      │
│  ├─ Module Config............. ✅ Loaded                     │
│  ├─ Sidecar Memory............ ✅ 6 sidecars found           │
│  └─ Core Workflows............ ✅ 6/6 present                │
├──────────────────────────────────────────────────────────────┤
│  EXTENSIONS (Operational Status)                            │
│  ├─ lens-sync................. [OPERATIONAL | INSTALLED_NOT_RUN | NOT_INSTALLED]  │
│  │  ├─ Bridge state.......... [✅ Active | ⚠️ Empty | ❌ Missing]          │
│  │  ├─ Scout discovery....... [✅ Indexed | ⚠️ Not run | ❌ Missing]       │
│  │  └─ Link mappings......... [✅ Present | ⚠️ Empty | ❌ Missing]         │
│  ├─ lens-compass.............. [OPERATIONAL | INSTALLED_NOT_CONFIGURED | NOT_INSTALLED]  │
│  │  ├─ Roster file........... [✅ Exists | ❌ Missing]                    │
│  │  ├─ Profiles folder....... [✅ Configured | ❌ Missing]                │
│  │  └─ User profiles......... [✅ N profiles | ⚠️ None | ❌ Not setup]    │
│  ├─ git-lens.................. [OPERATIONAL | INSTALLED_NOT_INITIALIZED | NOT_INSTALLED]  │
│  │  ├─ Tracey state.......... [✅ Initialized | ❌ Missing]               │
│  │  ├─ Event log............. [✅ Present | ⚠️ Empty | ❌ Missing]        │
│  │  └─ Base branch........... [✅ Configured | ❌ Not set]                │
│  └─ spec...................... [OPERATIONAL | INSTALLED_NO_CONSTITUTIONS | NOT_INSTALLED]  │
│     ├─ Constitutions......... [✅ N found | ⚠️ None | ❌ Not configured]  │
│     ├─ Scribe state.......... [✅ Active | ❌ Missing]                    │
│     └─ Auto-compliance....... [✅ Enabled | ⚠️ Disabled]                  │
├──────────────────────────────────────────────────────────────┤
│  SETUP STATUS                                                │
│  ├─ TargetProjects............ [READY | NEEDS_BOOTSTRAP | NONE]          │
│  ├─ Session State............. [ACTIVE | FRESH]                          │
│  └─ Discovery Index........... [INDEXED | NOT_RUN]                       │
├──────────────────────────────────────────────────────────────┤
│  OVERALL STATUS: [✅ ALL SYSTEMS OPERATIONAL | ⚠️ SOME NEED SETUP | ❌ CRITICAL ISSUES]  │
│  [Action Required: Run module installers for extensions marked NOT_INSTALLED]  │
╰──────────────────────────────────────────────────────────────╯
```

## Phase 5: Auto-Remediation (First Run Only)

**If this is the first run (no session exists), automatically bring all installed extensions to OPERATIONAL:**

### 5.1 lens-sync Auto-Initialize
If status is `INSTALLED_NOT_RUN`:
- Create Bridge state: Initialize `_bmad/_memory/bridge-sidecar/bridge-state.md` with empty state
- Run Scout discovery: Execute `_bmad/lens-sync/workflows/discover/workflow.md` to index codebase
- Create Link state: Initialize `_bmad/_memory/link-sidecar/link-state.md`
- Display: "🔍 Running initial SCOUT discovery..."
- Wait for completion, then show: "✅ lens-sync operational"

### 5.2 lens-compass Auto-Initialize  
If status is `INSTALLED_NOT_CONFIGURED`:
- Create roster file: Generate `.bmad-roster.yaml` with current git user
- Create profiles folder: `_bmad-output/personal/` or configured path
- Create initial profile: Use git identity to create first user profile
- Display: "👤 Configuring role-based navigation..."
- Show: "✅ lens-compass operational"

### 5.3 git-lens Auto-Initialize
If status is `INSTALLED_NOT_INITIALIZED`:
- Initialize Tracey state: Create `_bmad/_memory/tracey-sidecar/memories.md` with initial state
- Create event log: Initialize empty `event-log.jsonl`
- Detect current branch: Set as base_ref if not configured
- Display: "🌳 Initializing git workflow orchestration..."
- Show: "✅ git-lens operational"

### 5.4 spec Auto-Initialize
If status is `INSTALLED_NO_CONSTITUTIONS`:
- Create constitution root: Ensure `lens/constitutions/` directory exists
- Generate default constitution: Create basic `default-constitution.md` with standard governance rules
- Initialize Scribe state: Create `_bmad/_memory/scribe-sidecar/scribe-state.md`
- Display: "📜 Creating default constitution..."
- Show: "✅ spec operational"

### 5.5 Display Final Status
After all auto-remediation:
```
╭──────────────────────────────────────────────────────────────╮
│  ✅ FIRST RUN COMPLETE - ALL SYSTEMS OPERATIONAL             │
├──────────────────────────────────────────────────────────────┤
│  Initialized:                                                │
│  • lens-sync: Codebase indexed (N files discovered)         │
│  • lens-compass: User profile created                        │
│  • git-lens: Branch tracking active                          │
│  • spec: Default constitution created                        │
╰──────────────────────────────────────────────────────────────╯
```

## Phase 6: Activate Navigator

After preflight and auto-remediation complete:
1. Load agent: `_bmad/lens/agents/navigator.agent.yaml`
2. Execute Navigator's activation_sequence (which includes its own preflight)
3. Display navigation card with current lens and available workflows
4. Auto-run GUIDE workflow for contextual recommendations

## Error Handling

### Critical Failures (Block Activation)

If CORE systems fail (Navigator agent, module config, core workflows):
- Display critical failure in status card with ❌
- **Do not proceed with auto-remediation or activation**
- Provide remediation guidance:
  - Missing module config → Reinstall LENS core module
  - Missing sidecar directories → Create structure: `mkdir -p _bmad/_memory/{navigator,scout,bridge,link,scribe,tracey}-sidecar`
  - Missing workflows → Reinstall LENS module
  
Action Options:
- `[F] Fix Core Issues` → Auto-create missing directories and files
- `[R] Reinstall LENS` → Guide to reinstall core module
- `[E] Exit` → Cancel activation

### Non-Critical Issues (Continue with Warning)

If extensions have issues but core is healthy:

**Extension Not Installed:**
- Status: ⚠️ WARNING (not blocking)
- Auto-skip in Phase 5 (can't initialize what's not installed)
- Offer: `[I] Install {name}` → Run module installer after activation
- Guide: "Navigate to extension installer or run: `npx bmad-method@alpha install`"

**Extension Partially Configured:**
- Status: ⚠️ NEEDS INITIALIZATION (will be fixed in Phase 5)
- Automatically remediated during first-run initialization
- If auto-remediation fails: Offer manual configuration steps

### User Override Options

At any point, user can:
- `[S] Skip auto-initialization` → Proceed to Navigator without fixing extensions
- `[D] Details` → Show detailed diagnostic information about failures
- `[M] Manual mode` → Step through each initialization one at a time

## Additional Guidance

- If the user requests Party Mode or adversarial review, use `runSubagent` with multiple agents (pm, dev, tech-writer, ux-designer, architect) and synthesize findings.
- For multi-step plans or execution, initialize and maintain a task list with `manage_todo_list`.
- Run this preflight check periodically or after major changes to ensure system health.

---

## Workflow Summary

```
┌─────────────────────────────────────────────────────────────┐
│ START WORKFLOW                                              │
└─────────────────────────────────────────────────────────────┘
           ↓
    [Phase 1-3: Preflight Checks]
    • Core systems health
    • Extension installation status
    • Session state detection
           ↓
    ┌─────────────────────┐
    │ Session exists?     │
    └─────────────────────┘
           ↓              ↓
         YES             NO (First Run)
           ↓              ↓
    Skip Phase 5    [Phase 5: Auto-Initialize]
           ↓         • lens-sync → Run SCOUT
           ↓         • lens-compass → Create roster/profiles
           ↓         • git-lens → Initialize Tracey
           ↓         • spec → Create default constitution
           ↓              ↓
           ↓         Display: ✅ All systems operational
           ↓              ↓
           └──────┬───────┘
                  ↓
           [Phase 6: Activate Navigator]
           • Load agent
           • Display navigation card
           • Run GUIDE workflow
                  ↓
           Ready for use!
```

**Key Principle:** First run should leave the system fully operational. Subsequent runs skip initialization and proceed directly to Navigator activation.
