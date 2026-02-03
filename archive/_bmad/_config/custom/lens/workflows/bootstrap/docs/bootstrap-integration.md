# Bootstrap Workflow Integration Guide

**Last Updated:** 2026-02-02
**Status:** Active

---

## Overview

The Bootstrap workflow is now fully integrated into the LENS startup process, automatically executing on first run when bootstrap configuration is detected. This integration enables zero-to-operational setup where users go from empty workspace to fully cloned multi-repository structure in a single command.

## Integration Architecture

### Workflow Positioning

```
LENS Startup Flow:
├─ Phase 1-2: Core System & Extension Checks
├─ Phase 3: Environment Detection ← Bootstrap detection happens here
│  └─ 3.1: Detects domain-map.yaml + validates bootstrap config
├─ Phase 4: Preflight Report ← Shows bootstrap status
├─ Phase 5: Auto-Remediation (First Run Only)
│  ├─ 5.1-5.4: Initialize extensions
│  ├─ 5.5: Bootstrap Repository Structure ← Executes here
│  └─ 5.6: Display completion status
└─ Phase 6: Activate Navigator
```

### Key Design Decisions

**1. Timing: After Extension Initialization**
- Extensions (lens-sync, git-lens, etc.) are initialized BEFORE bootstrap runs
- This allows Scout discovery to immediately index newly cloned repositories
- Git-lens can track repository state from first clone

**2. Trigger: Detected, Not Forced**
- Bootstrap only runs if `domain-map.yaml` exists AND `TargetProjects/` is empty/missing
- Users without bootstrap config skip this phase entirely
- Already-populated projects skip bootstrap automatically

**3. User Control: Explicit Approval**
- Bootstrap Step 3 presents full comparison and approval prompts
- User sees exactly which repositories will be cloned before any network activity
- Prevents accidental massive clones or unexpected operations

**4. Error Recovery: Partial State Preservation**
- Failed clones leave partial state in place for diagnostics
- Bootstrap report documents exactly what succeeded/failed
- Users can manually fix issues or retry from failure point

---

## Phase 3.1: Bootstrap Detection

### Detection Logic

```yaml
target_projects_check:
  path: "{workspace_root}/TargetProjects"
  
  if exists_with_content:
    status: READY
    action: Skip bootstrap (already populated)
  
  if missing_or_empty:
    check_bootstrap_config:
      - primary: "_bmad/lens/domain-map.yaml"
      - fallback: "lens/domain-map.yaml"
      
    if config_found:
      validate:
        - YAML structure (must have 'domains' key)
        - Service definitions exist for each domain
        - All git_repo URLs are well-formed
        - Git is available in PATH
      
      if valid:
        status: NEEDS_BOOTSTRAP
        action: Proceed to Phase 5.5
      else:
        status: NEEDS_SETUP
        action: Show validation errors, guide user to fix config
    else:
      status: NEEDS_SETUP
      action: Manual configuration required
```

### Bootstrap Configuration Validation

**Required Files:**
- `_bmad/lens/domain-map.yaml` - Top-level domain map
- `_bmad/{domain}/service.yaml` - Per-domain service definitions

**Validation Checks:**
1. ✅ YAML syntax is valid
2. ✅ `domains` key exists in domain-map.yaml
3. ✅ Each domain has `name` and `path` fields
4. ✅ Service file exists for each domain (path: `{domain.path}/service.yaml`)
5. ✅ Each service.yaml has `domain` and `services` keys
6. ✅ `git_repo` URLs are syntactically valid (if present)
7. ✅ Git executable is available in PATH

**Validation Output:**
```yaml
bootstrap_config_status:
  valid: true|false
  errors: [list of validation errors]
  warnings: [list of warnings]
  summary:
    total_domains: N
    total_services: N
    total_microservices: N
    repos_with_git_url: N
    estimated_clone_size: "X GB" (if available)
```

---

## Phase 4: Bootstrap Status Display

### Enhanced Preflight Report

```
╭──────────────────────────────────────────────────────────────╮
│  SETUP STATUS                                                │
│  ├─ TargetProjects............ NEEDS_BOOTSTRAP               │
│  │  └─ Bootstrap Config...... ✅ Valid                      │
│  │     ├─ Domain Map......... ✅ domain-map.yaml found      │
│  │     └─ Service Definitions ✅ 3 domains, 8 services      │
│  │        └─ Repositories.... 15 repos ready to clone       │
╰──────────────────────────────────────────────────────────────╯
```

**Status Meanings:**
- `READY` - TargetProjects/ populated, bootstrap not needed
- `NEEDS_BOOTSTRAP` - Configuration valid, ready to auto-clone
- `NEEDS_SETUP` - No valid bootstrap config, manual setup required

---

## Phase 5.5: Bootstrap Execution

### Execution Flow

When `NEEDS_BOOTSTRAP` is detected:

```markdown
1. Display: "🔄 Setting up target project structure from bootstrap configuration..."

2. Execute: {project-root}/_bmad/lens/workflows/bootstrap/workflow.md
   ├─ Step 0: Preflight validation
   │  ├─ Validate TargetProjects/ guardrails
   │  ├─ Confirm git environment
   │  └─ Check disk space
   │
   ├─ Step 1: Load lens domain map
   │  ├─ Parse domain-map.yaml
   │  ├─ Load all service.yaml files
   │  └─ Build in-memory structure
   │
   ├─ Step 2: Scan target structure
   │  ├─ Inventory current TargetProjects/
   │  └─ Identify existing repos vs empty structure
   │
   ├─ Step 3: Compare & approve
   │  ├─ Generate comparison matrix
   │  ├─ Build sync plan (folders to create, repos to clone)
   │  └─ **APPROVAL PROMPT** - User must confirm before clones
   │
   └─ Step 4: Execute sync & report
      ├─ Create directory structure
      ├─ Clone repositories sequentially
      ├─ Verify branch checkouts
      └─ Generate bootstrap-report.md

3. Wait for completion (can take several minutes for large projects)

4. Handle outcomes:
   ✅ SUCCESS:
      - Display: "✅ Repository structure bootstrapped from lens domain map"
      - Update Phase 3.1 status to READY
      - Trigger Scout discovery re-index
   
   ⚠️ PARTIAL SUCCESS:
      - Display: "⚠️ Bootstrap partially completed. See report for details."
      - Preserve partial clones for manual inspection
      - Offer retry option
   
   ❌ FAILURE:
      - Display: "❌ Bootstrap failed. See report for diagnostics."
      - Preserve partial state
      - Offer: [R]etry | [M]anual fix | [S]kip to Navigator
```

### Step 3: User Approval Interface

**Critical Safeguard:** User must explicitly approve before any git clone operations.

**Approval Prompt Format:**
```
╭──────────────────────────────────────────────────────────────╮
│  📋 BOOTSTRAP SYNC PLAN                                      │
├──────────────────────────────────────────────────────────────┤
│  Target: D:/BMAD.Lens/TargetProjects                         │
│                                                              │
│  Actions:                                                    │
│  • Create 3 domain folders                                   │
│  • Create 8 service folders                                  │
│  • Clone 15 repositories (~2.3 GB estimated)                 │
│                                                              │
│  Sample repositories to clone:                               │
│  • platform/auth-service/auth-api                           │
│    └─ git@github.com:org/auth-api.git (branch: main)       │
│  • platform/data-service/data-processor                      │
│    └─ git@github.com:org/data-processor.git (branch: dev)   │
│  ... (13 more)                                               │
│                                                              │
│  Network checks:                                             │
│  ✅ Git available                                            │
│  ✅ SSH keys configured                                      │
│  ✅ Disk space sufficient (5 GB free)                        │
├──────────────────────────────────────────────────────────────┤
│  This will clone repositories from external sources.         │
│  Review the plan carefully before proceeding.                │
╰──────────────────────────────────────────────────────────────╯

Proceed with bootstrap? [y/N]: _
```

**User Options:**
- `y` - Approve and execute sync plan
- `n` - Cancel bootstrap (can retry later manually)
- `d` - Show detailed plan (full list of all operations)
- `f` - Filter plan (e.g., "only clone domain: platform")

---

## Phase 5.6: Completion Status

### Enhanced Final Status Display

```
╭──────────────────────────────────────────────────────────────╮
│  ✅ FIRST RUN COMPLETE - ALL SYSTEMS OPERATIONAL             │
├──────────────────────────────────────────────────────────────┤
│  Initialized:                                                │
│  • lens-sync: Codebase indexed (127 files discovered)       │
│  • lens-compass: User profile created                        │
│  • git-lens: Branch tracking active                          │
│  • spec: Default constitution created                        │
│  • bootstrap: 3 domains, 15 repositories cloned, 2.3 GB data │
│                                                              │
│  📄 Reports generated:                                       │
│  • _bmad-output/bootstrap-report.md                          │
╰──────────────────────────────────────────────────────────────╯
```

---

## Bootstrap Configuration Format

### domain-map.yaml Structure

**Location:** `_bmad/lens/domain-map.yaml`

```yaml
version: "1.0"
metadata:
  project_name: "NorthStar Enterprise"
  last_updated: "2026-02-02T10:30:00Z"
  maintainer: "Platform Team"

domains:
  - name: "Platform"
    description: "Core platform services"
    path: "platform"
    service_file: "service.yaml"
    tags: ["infrastructure", "core"]
  
  - name: "Business"
    description: "Business domain services"
    path: "business"
    service_file: "service.yaml"
    tags: ["domain", "application"]
```

### service.yaml Structure

**Location:** `_bmad/{domain}/service.yaml`

```yaml
domain: "Platform"
services:
  - name: "auth-service"
    description: "Authentication and authorization"
    path: "auth"
    microservices:
      - name: "auth-api"
        path: "auth-api"
        git_repo: "git@github.com:org/auth-api.git"
        branch: "main"
        tech_stack: ["typescript", "express", "postgresql"]
        status: "active"
      
      - name: "auth-worker"
        path: "auth-worker"
        git_repo: "git@github.com:org/auth-worker.git"
        branch: "main"
        tech_stack: ["typescript", "rabbitmq"]
        status: "active"
  
  - name: "data-service"
    description: "Data processing pipelines"
    path: "data"
    microservices:
      - name: "data-processor"
        path: "data-processor"
        git_repo: "git@github.com:org/data-processor.git"
        branch: "dev"
        tech_stack: ["python", "spark"]
        status: "active"
```

**Field Descriptions:**
- `domain` (required): Must match parent domain name
- `services[].name` (required): Service identifier
- `services[].path` (required): Relative path within domain
- `microservices[].name` (required): Microservice identifier
- `microservices[].path` (required): Relative path within service
- `microservices[].git_repo` (optional): Full clone URL (SSH or HTTPS)
- `microservices[].branch` (required if git_repo present): Branch to checkout
- `microservices[].tech_stack` (optional): Technology tags for discovery
- `microservices[].status` (optional): active | deprecated | planned

---

## TargetProjects/ Guardrails

### Safety Enforcement

**All bootstrap operations are restricted to the `TargetProjects/` directory to prevent accidental modifications to:**
- LENS workspace itself (`_bmad/`, `src/`, etc.)
- User home directory
- System directories
- Parent directories of the workspace

**Enforcement Points:**

1. **Step 0 (Preflight):** Validates TargetProjects/ path safety
   ```bash
   # Blocked operations:
   - TargetProjects == workspace root
   - TargetProjects is parent of workspace
   - TargetProjects is system directory (/, /home, C:\, etc.)
   - TargetProjects is symlink to unsafe location
   ```

2. **Step 4 (Execute):** Double-checks every clone target path
   ```bash
   # Before each clone:
   realpath "{target_path}" | grep -q "^{TargetProjects}/" || ABORT
   ```

3. **Configuration Validation:** Rejects configs pointing outside TargetProjects
   ```yaml
   # INVALID - will be rejected:
   target_project_root: "../external-folder"
   
   # VALID:
   target_project_root: "TargetProjects/my-project"
   ```

---

## Error Handling & Recovery

### Bootstrap Failure Scenarios

#### 1. Network Failures (Git clone timeout/failure)

**Behavior:**
- Partial clones are preserved in place
- Bootstrap continues to next repository (doesn't abort entire process)
- Failed repos are logged in bootstrap-report.md

**Recovery:**
```bash
# Manual retry of failed clones:
cd TargetProjects/{domain}/{service}
git clone {failed_repo_url} {microservice_name}

# Or re-run bootstrap (will skip existing clones):
# Bootstrap workflow is create-only, safe to re-run
```

#### 2. Invalid Configuration

**Behavior:**
- Bootstrap aborts in Step 0 or Step 1 (before any clones)
- Validation errors displayed to user
- No partial clones created

**Recovery:**
```bash
# Fix domain-map.yaml or service.yaml
# Re-run bmad.start workflow
# Bootstrap will re-validate and proceed if fixed
```

#### 3. Disk Space Exhaustion

**Behavior:**
- Pre-flight check (Step 0) estimates total clone size
- If insufficient space detected, prompts user before proceeding
- If space exhausted mid-clone, clone fails, logged, and process continues

**Recovery:**
```bash
# Free up disk space
# Re-run bootstrap workflow manually:
# Navigate to: _bmad/lens/workflows/bootstrap/workflow.md
```

#### 4. Authentication Failures (SSH key issues)

**Behavior:**
- Git clone fails with authentication error
- Logged as failure in bootstrap report
- Process continues to next repository

**Recovery:**
```bash
# Verify SSH keys:
ssh -T git@github.com

# Or switch to HTTPS URLs in service.yaml:
git_repo: "https://github.com/org/repo.git"

# Re-run bootstrap (skips already cloned repos)
```

### Manual Bootstrap Execution

If automatic bootstrap fails or is skipped:

```bash
# Navigate to bootstrap workflow
cd _bmad/lens/workflows/bootstrap

# Execute workflow manually
# Follow prompts in workflow.md
```

---

## Integration Testing

### Test Scenarios

**1. First Run with Valid Bootstrap Config**
- ✅ Extensions initialize
- ✅ Bootstrap detects config
- ✅ User sees approval prompt
- ✅ Repositories clone successfully
- ✅ Scout indexes new repos
- ✅ Navigator activates with full context

**2. First Run without Bootstrap Config**
- ✅ Extensions initialize
- ✅ Bootstrap skipped (NEEDS_SETUP status)
- ✅ Navigator activates normally
- ✅ User can run bootstrap manually later

**3. Subsequent Runs (TargetProjects Already Populated)**
- ✅ Bootstrap detection returns READY status
- ✅ Phase 5.5 skipped entirely
- ✅ Fast startup to Navigator

**4. Bootstrap Partial Failure**
- ✅ Failed clones logged in report
- ✅ Successful clones preserved
- ✅ User offered retry option
- ✅ Navigator activates (can operate without all repos)

**5. Bootstrap Configuration Errors**
- ✅ Validation errors displayed clearly
- ✅ No clone attempts made
- ✅ User guided to fix configuration
- ✅ Can retry after fix

---

## Performance Considerations

### Clone Optimization

**Sequential Cloning (Default):**
- Avoids network contention
- Easier progress tracking
- Better error isolation

**Estimated Times:**
| Repositories | Size | Time (Approx) |
|-------------|------|---------------|
| 5 repos | 500 MB | 1-2 minutes |
| 15 repos | 2 GB | 5-8 minutes |
| 30 repos | 5 GB | 15-20 minutes |
| 50+ repos | 10+ GB | 30+ minutes |

**Optimization Options (Future):**
- Shallow clones (`--depth 1`) for faster initial setup
- Parallel cloning with configurable concurrency
- Pre-flight bandwidth test to estimate completion time

### Post-Bootstrap Operations

**Scout Discovery Re-Index:**
- Automatically triggered after successful bootstrap
- Indexes all newly cloned repositories
- Adds ~1-2 minutes for large projects

**Git-Lens Initialization:**
- Already initialized in Phase 5.3
- Immediately tracks newly cloned repositories
- No additional setup time

---

## Troubleshooting

### Common Issues

**1. "Bootstrap config not detected"**
- Check file path: `_bmad/lens/domain-map.yaml` (note: `_bmad`, not `.bmad`)
- Verify YAML syntax is valid
- Ensure `domains` key exists in domain-map.yaml

**2. "Service definition missing"**
- Each domain in domain-map.yaml must have corresponding `service.yaml`
- Check path: `_bmad/{domain.path}/{service_file}`
- Default service_file is `service.yaml`

**3. "Clone outside TargetProjects blocked"**
- All clones restricted to `{workspace_root}/TargetProjects/`
- Check `target_project_root` in config
- Must be relative path or absolute path within TargetProjects

**4. "Git authentication failed"**
- Verify SSH keys: `ssh -T git@github.com`
- Or switch to HTTPS URLs in service.yaml
- Ensure git credentials are configured

**5. "Bootstrap stuck at approval prompt"**
- Expected behavior - user must approve before clones
- Review sync plan carefully
- Type `y` to proceed, `n` to cancel, `d` for details

---

## Future Enhancements

### Planned Features

**1. Incremental Sync Mode**
- Detect new repositories added to domain-map.yaml
- Clone only new repos, skip existing
- Update mode for pulling latest changes

**2. Parallel Clone Support**
- Configurable concurrency level
- Faster bootstrap for large projects
- Progress tracking per repository

**3. Selective Bootstrap**
- Filter by domain: `--domains platform,business`
- Filter by service: `--services auth-service`
- Filter by tag: `--tags infrastructure`

**4. Bootstrap Templates**
- Pre-built domain maps for common architectures
- Microservices template
- Monorepo template
- Multi-tenant template

**5. Cloud Integration**
- Pre-check repository accessibility before clone
- Bandwidth estimation and progress ETA
- Resume capability for interrupted clones

---

## Related Documentation

- [bmad.start.prompt.md](../../prompts/bmad.start.prompt.md) - Full startup workflow
- [bootstrap/workflow.md](../workflow.md) - Bootstrap workflow entry point
- [bootstrap/steps-c/](../steps-c/) - Individual bootstrap steps
- [module-config.yaml](../../module-config.yaml) - LENS module configuration
- [session-store.md](../../docs/session-store.md) - Session persistence

---

**Document Owner:** LENS Core Team  
**Review Cycle:** Quarterly  
**Next Review:** 2026-05-02
