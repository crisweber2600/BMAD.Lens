---
description: Run LENS system preflight check and activate Navigator - validates all lens systems are operational before providing workflow guidance
---

# LENS System Preflight Check & Activation

Execute a comprehensive preflight check of all LENS systems, automatically initialize any installed extensions on first run, then activate Navigator for workflow guidance.

**First Run Behavior:** If no session exists (`_bmad/lens/lens-session.yaml` missing), this workflow will automatically bring all installed extensions to OPERATIONAL status by running initialization routines.

## Phase 1: Core System Preflight Check

### 1.1 LENS Core Module
- [ ] Check for module config: `_bmad/lens/module-config.yaml`
- [ ] Check for Navigator agent: `_bmad/lens/agents/navigator.agent.yaml`
- [ ] Check for session store path in config (`_bmad/lens/lens-session.yaml`)
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
- [ ] Check if `_bmad/_config/manifest.yaml` lists `lens` as installed module (extensions are part of lens)
- [ ] Verify `_bmad/lens/extensions/lens-sync/` directory exists (extensions install under lens module)

**Operational Readiness:**
- [ ] Bridge agent operational: `_bmad/_memory/bridge-sidecar/bridge-state.md` exists with state data
- [ ] Scout discovery run: `_bmad/_memory/scout-sidecar/scout-discoveries.md` exists and not empty
- [ ] Link mappings present: `_bmad/_memory/link-sidecar/link-state.md` exists

**Status:** `OPERATIONAL` | `INSTALLED_NOT_RUN` | `NOT_INSTALLED`

### 2.2 LENS-Compass Extension (Role-Based Navigation)

**Installation Check:**
- [ ] Check if `_bmad/_config/manifest.yaml` lists `lens` as installed module (extensions are part of lens)
- [ ] Verify `_bmad/lens/extensions/lens-compass/` directory exists (extensions install under lens module)

**Operational Readiness:**
- [ ] Roster initialized: `_bmad/lens/extensions/lens-compass/roster.yaml` exists
- [ ] Personal profiles folder exists: Check configured path or default `_bmad-output/personal/`
- [ ] Git identity configured: Verify `use_git_identity` setting in installed module config
- [ ] At least one profile exists: Check for user profile files

**Status:** `OPERATIONAL` | `INSTALLED_NOT_CONFIGURED` | `NOT_INSTALLED`

### 2.3 Git-Lens Extension (Git Workflow Orchestration)

**Installation Check:**
- [ ] Check if `_bmad/_config/manifest.yaml` lists `lens` as installed module (extensions are part of lens)
- [ ] Verify `_bmad/lens/extensions/git-lens/` directory exists (extensions install under lens module)

**Operational Readiness:**
- [ ] Tracey state initialized: `_bmad/_memory/tracey-sidecar/memories.md` exists
- [ ] Event log present: Check for `event-log.jsonl` in tracey-sidecar
- [ ] Base branch configured: Verify `base_ref` in installed module config
- [ ] Git hooks registered: Check if hook files exist in `_bmad/lens/extensions/git-lens/hooks/`

**Status:** `OPERATIONAL` | `INSTALLED_NOT_INITIALIZED` | `NOT_INSTALLED`

### 2.4 SPEC Extension (Constitutional Governance)

**Installation Check:**
- [ ] Check if `_bmad/_config/manifest.yaml` lists `lens` as installed module (extensions are part of lens)
- [ ] Verify `_bmad/lens/extensions/spec/` directory exists (extensions install under lens module)

**Operational Readiness:**
- [ ] Constitution root configured: Verify path in installed module config
- [ ] At least one constitution exists: Check `_bmad/lens/constitutions/` for `.md` files
- [ ] Scribe agent operational: `_bmad/_memory/scribe-sidecar/scribe-state.md` exists
- [ ] Compliance check setting: Verify `auto_compliance_check` configuration

**Status:** `OPERATIONAL` | `INSTALLED_NO_CONSTITUTIONS` | `NOT_INSTALLED`

## Phase 3: Environment & Setup Status

### 3.1 Target Project Structure & Bootstrap Detection
- [ ] Check if `TargetProjects/` directory exists
- [ ] If exists with content: **Verify git repository status**
  - [ ] For each expected repository (from `domain-map.yaml`):
    - [ ] Check if directory exists
    - [ ] Check if `.git/` folder exists (is it a valid git repository?)
    - [ ] If git repo: Verify branch matches expected branch from `service.yaml`
  - [ ] If all repos cloned with correct branches: Report state as `READY`
  - [ ] If some repos missing or not git repos: Report state as `NEEDS_BOOTSTRAP` (partial setup)
- [ ] If missing or empty: Check for bootstrap configuration:
  - [ ] Look for `_bmad/lens/domain-map.yaml`
  - [ ] If found: Validate YAML structure (must have `domains` key)
  - [ ] For each domain: Verify `service.yaml` exists and is valid
  - [ ] Collect all `git_repo` URLs for connectivity pre-check
  - [ ] Report: `NEEDS_BOOTSTRAP` (bootstrap data found and valid)
- [ ] If no bootstrap data found: Report `NEEDS_SETUP` (manual configuration required)
- [ ] Final states: `READY` | `NEEDS_BOOTSTRAP` | `NEEDS_SETUP`

### 3.2 Session State
- [ ] Check for existing session: `_bmad/lens/lens-session.yaml`
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
│  ├─ TargetProjects............ [READY | NEEDS_BOOTSTRAP | NEEDS_SETUP]   │
│  │  └─ Bootstrap Config...... [✅ Valid | ⚠️ Partial | ❌ Invalid | N/A] │
│  │     ├─ Domain Map......... [✅ domains.yaml found | ❌ Missing]        │
│  │     └─ Service Definitions [✅ N services | ⚠️ Some missing | ❌ None] │
│  ├─ Session State............. [ACTIVE | FRESH]                          │
│  └─ Discovery Index........... [INDEXED | NOT_RUN]                       │
├──────────────────────────────────────────────────────────────┤
│  BOOTSTRAP STATUS                                            │
│  [✅ CONFIGURED | ⚠️ STARTER_TEMPLATE]                       │
│                                                              │
│  If domain-map.yaml NOT FOUND:                               │
│  → Phase 5.5 will auto-create starter domain-map.yaml       │
│  → You can then define domains, services, and repositories  │
│  → Run Phase 5.5 again to bootstrap from your config        │
│                                                              │
│  If domain-map.yaml FOUND:                                   │
│  ✅ Bootstrap ready to configure repository structure       │
│  → Phase 5.5 will clone all defined repositories            │
│  → Review and approve the sync plan before cloning          │
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
- Run Scout discovery: Execute `_bmad/lens/extensions/lens-sync/workflows/discover/workflow.md` to index codebase
- Create Link state: Initialize `_bmad/_memory/link-sidecar/link-state.md`
- Display: "🔍 Running initial SCOUT discovery..."
- Wait for completion, then show: "✅ lens-sync operational"

### 5.2 lens-compass Auto-Initialize  
If status is `INSTALLED_NOT_CONFIGURED`:
- Create roster file: Generate `_bmad/lens/extensions/lens-compass/roster.yaml` with current git user
- Create profiles folder: `_bmad-output/personal/` or configured path
- Execute onboarding workflow: `_bmad/lens/extensions/lens-compass/workflows/onboarding/workflow.md`
  - Step 1: Detect git identity and confirm user
  - Step 2: **Explain available roles and collect selection:**
    
    **Available Roles:**
    - **Product Owner (PO)**: Strategic decision-maker who defines features, priorities, and domain architecture. Uses workflows like new-service, new-domain, and lens-switch to shape the system.
    - **Architect/Lead Dev**: Technical leader who designs solutions, reviews code, and coordinates implementation. Uses workflows like solutioning, architecture review, and sprint planning.
    - **Developer**: Implementation specialist who builds features, fixes bugs, and maintains code quality. Uses workflows like dev-story, code-review, and feature implementation.
    - **Power User**: Multi-role contributor who can operate across different contexts. Commonly architects who also write code, or POs with technical depth.
    
    Present these roles and ask the user to select their primary role(s). Power Users can select multiple roles.
    
  - Step 3: Persist user profile with selected role(s) and preferences
- Update `.gitignore`: Add `/_bmad-output/personal/` to exclude personal profiles from repo
- Display: "👤 Configuring role-based navigation..."
- Show: "✅ lens-compass operational - Profile created with role: {selected_roles}"

### 5.3 git-lens Auto-Initialize
If status is `INSTALLED_NOT_INITIALIZED`:
- Initialize Tracey state: Create `_bmad/_memory/tracey-sidecar/memories.md` with initial state
- Create event log: Initialize empty `event-log.jsonl`
- Detect current branch: Set as base_ref if not configured
- Display: "🌳 Initializing git workflow orchestration..."
- Show: "✅ git-lens operational"

### 5.4 spec Auto-Initialize
If status is `INSTALLED_NO_CONSTITUTIONS`:
- Create constitution root: Ensure `_bmad/lens/constitutions/` directory exists
- Generate default constitution: Create basic `default-constitution.md` with standard governance rules
- Initialize Scribe state: Create `_bmad/_memory/scribe-sidecar/scribe-state.md`
- Display: "📜 Creating default constitution..."
- Show: "✅ spec operational"

### 5.5 Bootstrap Repository Structure (If Needed)
If `NEEDS_BOOTSTRAP` status was detected in Phase 3:
- Display: "🔄 Setting up target project structure from bootstrap configuration..."
- Execute bootstrap workflow: `{project-root}/_bmad/lens/workflows/bootstrap/workflow.md`
  - Step 0: Preflight validation (TargetProjects guardrails, YAML parsing, git environment)
  - Step 1: Load lens domain map and service definitions
  - Step 2: Scan current target project structure
  - Step 3: Present comparison and get user approval for repository clones
  - Step 4: Execute sync (create folders, clone git repositories)
- Wait for completion

**After Bootstrap Completion:**
- Update `.gitignore` to ensure proper ignore patterns:
  - Ensure `/_bmad-output/personal/` is ignored (personal profiles)
  - Ensure `/TargetProjects/` is present if not already (to sync structure but not content)
  - Add any domain-specific ignore patterns from domain-map.yaml if specified
- **Commit bootstrap and .gitignore update:**
  ```bash
  git add _bmad/lens/domain-map.yaml _bmad/**/*.yaml .gitignore
  git commit -m "chore: initialize LENS domain map, service config, and system file protection"
  ```
  
- If successful: Show "✅ Repository structure bootstrapped from lens domain map"
- If commit fails: Show warning with instructions to manually commit
- Update Phase 3.1 status to `READY` after successful bootstrap

### 5.6 Update .gitignore and Commit LENS Configuration

**CRITICAL: Protect LENS system files from accidental commits**

Before completing initialization, ensure .gitignore is properly configured and committed:

#### Step 1: Create/Update .gitignore

Use the LENS .gitignore template: `_bmad/lens/.gitignore.template`

If `.gitignore` doesn't exist in project root:
```bash
cp _bmad/lens/.gitignore.template .gitignore
```

If `.gitignore` already exists:
- Merge the patterns from `.gitignore.template` into `.gitignore`
- Ensure these patterns are present:

```gitignore
# LENS System Files - Never commit these
_bmad/_memory/**/*.md
_bmad/_memory/**/*.jsonl
_bmad/_memory/**/*.json
_bmad/lens/lens-session.yaml
_bmad-output/personal/
_bmad-output/implementation-artifacts/
```

#### Step 2: Verify Git Status
```bash
# Check what would be committed
cd {project-root}
git status
```

**Ensure NO files from `_bmad/_memory/` or `.gitignore`-listed paths appear in staging area.**

#### Step 3: Commit .gitignore Update
```bash
cd {project-root}
git add .gitignore
git commit -m "chore: add LENS system file protection to gitignore"
```

**Display:**
```
🔒 Protecting LENS system files from accidental commits...
✅ .gitignore updated and committed
```

#### Step 4: Verify Clean Working Directory
After commit, verify no LENS system files are untracked or staged:
```bash
git status
```

**Expected result:** Only project files should be untracked, not LENS system files.

### 5.7 Display Final Status
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
│  • bootstrap: N domains, M repositories cloned, X GB data    │
╰──────────────────────────────────────────────────────────────╯
```

## Phase 6: Activate Navigator

After preflight and auto-remediation complete:
1. Load agent: `_bmad/lens/agents/navigator.agent.yaml`
2. Execute Navigator's activation_sequence (which includes its own preflight)
3. Display navigation card with current lens and available workflows
4. Proceed to Phase 7 for postflight verification

## Phase 7: Postflight Verification & Recommendations

After Navigator activation, perform a final verification to ensure all systems are operational:

### 7.1 System Health Verification

Re-check critical systems to confirm operational status:
- [ ] Verify all extension sidecars have initialized state files
- [ ] Confirm session file created: `_bmad/lens/lens-session.yaml`
- [ ] Check SCOUT discovery completed (if lens-sync initialized)
- [ ] Verify user profile exists (if lens-compass initialized)
- [ ] Confirm git-lens tracking is active (if git-lens initialized)
- [ ] Verify constitution exists (if spec initialized)

### 7.2 Generate Postflight Report

Display a concise summary of operational status:

```
╭──────────────────────────────────────────────────────────────╮
│  ✅ POSTFLIGHT CHECK - ALL SYSTEMS OPERATIONAL                │
├──────────────────────────────────────────────────────────────┤
│  System Health:                                              │
│  ├─ Core LENS................ ✅ Operational                 │
│  ├─ lens-sync................ ✅ Operational                 │
│  ├─ lens-compass............. ✅ Operational                 │
│  ├─ git-lens................. ✅ Operational                 │
│  ├─ spec..................... ✅ Operational                 │
│  └─ Navigator................ ✅ Active                      │
├──────────────────────────────────────────────────────────────┤
│  📊 Discovery Status:                                         │
│  • Indexed files: N files across M repositories             │
│  • Tracked repositories: X git repos in TargetProjects      │
│  • User profile: {name} ({role})                             │
╰──────────────────────────────────────────────────────────────╯
```

### 7.3 First Recommendations

Present immediate next steps based on system state:

**🎯 Recommended First Action: Run SCOUT Discovery**

Since this is your first run, it's recommended to perform a comprehensive SCOUT discovery to index your entire codebase:

```
╭──────────────────────────────────────────────────────────────╮
│  🔍 RECOMMENDED: Run SCOUT Discovery                          │
├──────────────────────────────────────────────────────────────┤
│  Why: SCOUT builds a comprehensive index of your architecture │
│  enabling faster navigation, better context awareness, and   │
│  intelligent workflow recommendations.                       │
│                                                              │
│  What it does:                                               │
│  • Indexes all source files, configs, and documentation      │
│  • Maps service dependencies and boundaries                  │
│  • Identifies architectural patterns and anti-patterns       │
│  • Enables semantic search across your codebase             │
│                                                              │
│  Command: [DISC] or say "Run SCOUT discovery"               │
│  Time: ~2-5 minutes for typical projects                    │
╰──────────────────────────────────────────────────────────────╯
```

**Other Available Actions:**
1. **[GUIDE]** - Get workflow recommendations based on current lens
2. **[NAV]** - Detect and display current architectural lens
3. **[SW]** - Switch to a different lens level
4. **[BOOT]** - Configure domain map and bootstrap structure (if needed)

### 7.4 Display Welcome Message

Show personalized welcome with system capabilities:

```
╭──────────────────────────────────────────────────────────────╮
│  🎉 Welcome to LENS - Layered Enterprise Navigation System   │
├──────────────────────────────────────────────────────────────┤
│  Hello {user_name} ({role})!                                 │
│                                                              │
│  Your architectural navigation system is ready. LENS helps  │
│  you work efficiently across {N} repositories by providing: │
│                                                              │
│  ✨ Smart lens detection (Domain/Service/Microservice)      │
│  🔍 SCOUT-powered discovery and semantic search              │
│  🧭 Role-aware workflow recommendations                      │
│  🌳 Git workflow orchestration with Tracey                   │
│  📜 Constitutional governance with SPEC                      │
│  🔗 Cross-repository link management                         │
│                                                              │
│  Type [DISC] to index your codebase, or [GUIDE] for next   │
│  steps based on your current context!                       │
╰──────────────────────────────────────────────────────────────╯
```

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
- Offer: `[I] Install LENS module` → Reinstall lens module to get extensions
- Guide: "Extensions are installed as part of the LENS module. To reinstall extensions, run `npx bmad-method@alpha install` and select the LENS module. If using source repo, check `src/modules/lens/extensions/` for extension sources. Extensions install to `_bmad/lens/extensions/{name}/`."

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

## DISC Command: Discovery Workflow

**When user types [DISC] or requests SCOUT discovery:**

1. Execute the discover workflow: `_bmad/lens/workflows/discover/workflow.md`
2. Complete steps 00-04 (preflight, target selection, context extraction, analysis, doc generation)
3. **CRITICAL: Execute step-05-handoff-scout.md** which MUST:

### Deep Scan Prompt (Required)

After initial discovery completes, you **MUST** present this prompt to the user:

```
╭──────────────────────────────────────────────────────────────╮
│  🔍 Initial Discovery Complete!                              │
├──────────────────────────────────────────────────────────────┤
│  Discovery Summary:                                          │
│  • Targets scanned: {count}                                  │
│  • Services identified: {count}                              │
│  • Files indexed: {count}                                    │
├──────────────────────────────────────────────────────────────┤
│  🧭 Would you like to run a deep scan next?                  │
│                                                              │
│  SCOUT can run the complete discovery pipeline for           │
│  comprehensive technical analysis and documentation:         │
│                                                              │
│  • [DS] Deep Discover ⭐ RECOMMENDED                         │
│  • [AC] Analyze Codebase                                     │
│  • [GD] Generate Docs                                        │
│                                                              │
│  Estimated time: 15-30 minutes per project                   │
├──────────────────────────────────────────────────────────────┤
│  Options:                                                    │
│  [DEEP]  Run full deep scan pipeline (recommended)           │
│  [SKIP]  Continue to Navigator (run later with [DEEP])       │
╰──────────────────────────────────────────────────────────────╯
```

**DO NOT skip this prompt.** The user must choose whether to run the deep scan.

---

## MAP Command: Domain Map Workflow

**When user types [MAP] or requests domain map:**

1. Execute the domain-map workflow: `_bmad/lens/workflows/domain-map/workflow.md`
2. **CRITICAL: Detect git remote URLs** for each repository:

### Git Remote URL Detection (Required)

For each repository in TargetProjects, run:
```bash
cd {repo_path} && git remote get-url origin 2>/dev/null
```

- If remote exists: Use the URL in the `git_repo` field
- If no remote: Show `(local repository - no remote configured)`

**DO NOT show "(local repository)" if a remote URL exists.** Always check with git commands.

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
    • Environment & bootstrap detection
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
           ↓         • bootstrap → Clone repos (if configured)
           ↓              ↓
           ↓         Display: ✅ All systems operational
           ↓              ↓
           └──────┬───────┘
                  ↓
           [Phase 6: Activate Navigator]
           • Load agent
           • Display navigation card
                  ↓
           [Phase 7: Postflight Verification]
           • Re-verify all systems operational
           • Display postflight report (green status)
           • Recommend SCOUT discovery as first action
           • Show welcome message with capabilities
                  ↓
           🎉 Ready for use!
           First suggestion: [DISC] Run SCOUT Discovery
```

**Key Principle:** First run should leave the system fully operational, including repository bootstrap if bootstrap data is present. Subsequent runs skip initialization and proceed directly to Navigator activation. All runs complete with postflight verification and actionable recommendations.

---

## Postflight Success Criteria

The system is considered fully operational when:
- ✅ All installed extensions report OPERATIONAL status
- ✅ Session state file exists with current lens position
- ✅ SCOUT discovery has indexed at least basic file structure
- ✅ User profile exists with role(s) selected
- ✅ Navigator responds to commands

If any criteria fail, the postflight report shows warnings with remediation steps.
```

**Key Principle:** First run should leave the system fully operational, including repository bootstrap if bootstrap data is present. Subsequent runs skip initialization and proceed directly to Navigator activation.

## Bootstrap Integration Details

### When Bootstrap Executes
- **Trigger**: Detected in Phase 3.1 when `domain-map.yaml` exists but `TargetProjects/` is empty
- **Timing**: Phase 5.5, after all extension initialization (extensions are configured before repos are cloned)
- **User Control**: User is shown approval prompts in bootstrap Step 3 (compare & approve) before any clones occur

### Prerequisites for Bootstrap
- ✅ `_bmad/lens/domain-map.yaml` must exist and be valid YAML
- ✅ Each referenced `service.yaml` must exist in `_bmad/{domain}/service.yaml`
- ✅ Git must be available in PATH
- ✅ SSH keys or credentials configured for private repos (if any)

### Bootstrap Output
- Creates `docs/bootstrap/bootstrap-report.md` with detailed status
- Clones repositories into `TargetProjects/{domain}/{service}/{microservice}/` hierarchy
- Initializes git workflow state for each cloned repo
- Updates Scout discovery to index newly cloned repositories

### Rollback on Failure
If bootstrap fails:
- Partial clones are left in place (user can inspect)
- Bootstrap report indicates which steps failed
- User options: Retry, Manual fix, or Skip to Navigator (operate without bootstrap)
- No automatic cleanup to preserve partial state for diagnostics
