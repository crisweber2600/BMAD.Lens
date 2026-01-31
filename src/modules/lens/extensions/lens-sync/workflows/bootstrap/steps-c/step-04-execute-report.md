---
name: 'step-04-execute-report'
description: 'Execute sync and write bootstrap report'
outputFile: '{docs_output_folder}/lens-sync/bootstrap-report.md'
---

# Step 4: Execute & Report

## Goal
Execute the approved sync plan with full error handling, progress reporting, and rollback capability. Produce a comprehensive bootstrap report documenting all actions taken.

## Instructions

### 1. Pre-Execution Validation
Before executing, verify:
```yaml
pre_execution_checks:
  - plan_status: approved           # must be approved
  - plan_age: < 1 hour              # reject stale plans
  - snapshot_exists: true           # rollback point ready
  - network_available: true         # for clone operations
  - disk_space_sufficient: true     # based on estimated size
```

If any check fails, STOP and prompt user to re-run from Step 3.

### 2. Execute Folder Creation
Process `sync_plan.actions.create_folders` in order (parents before children):

```bash
# For each folder
mkdir -p "{target_path}"

# Verify creation
if [ -d "{target_path}" ]; then
  record_success(folder, "created")
else
  record_failure(folder, "mkdir failed: {error}")
fi
```

**Progress tracking:**
```yaml
folder_progress:
  total: N
  completed: N
  failed: N
  current: "{path}"
```

### 3. Execute Repository Clones
Process `sync_plan.actions.clone_repos` sequentially (not parallel to avoid network contention):

**For each repo:**
```bash
# Navigate to parent directory
cd "{parent_path}"

# Clone with appropriate depth
if [ "{depth}" = "shallow" ]; then
  git clone --depth 1 --branch {branch} "{git_repo}" "{folder_name}"
else
  git clone --branch {branch} "{git_repo}" "{folder_name}"
fi

# Verify clone success
cd "{folder_name}"
git status  # should succeed
git remote -v  # verify remote URL
```

**Clone error handling:**
| Error | Action |
|-------|--------|
| Authentication failed | Log, skip, add to manual_fixes |
| Network timeout | Retry once, then skip |
| Branch not found | Try default branch, warn |
| Disk full | STOP all clones, report partial state |
| Repository not found (404) | Log, skip, warn about stale lens data |

**Progress tracking:**
```yaml
clone_progress:
  total: N
  completed: N
  failed: N
  skipped: N
  current:
    repo: "{git_repo}"
    progress: "Receiving objects: X%"
```

### 4. Execute Manual Resolutions
For approved manual resolutions from Step 3:

**Remote mismatch - Update lens:**
```yaml
# Update service.yaml with actual remote
microservice.git_repo = target_git_repo
# Write back to lens file
```

**Remote mismatch - Re-clone:**
```bash
# Backup existing
mv "{path}" "{path}.backup-{timestamp}"
# Clone fresh
git clone --branch {branch} "{lens_git_repo}" "{path}"
# If successful, remove backup
rm -rf "{path}.backup-{timestamp}"
```

### 5. Post-Execution Validation
After all actions complete:

```bash
# For each expected microservice path
cd "{path}"
[ -d ".git" ] && git status --porcelain
[ -f "package.json" ] || [ -f "requirements.txt" ] || ...
```

**Build validation report:**
```yaml
validation_results:
  total_expected: N
  total_validated: N
  validation_failures:
    - path: string
      issue: "Missing .git directory"|"Wrong remote"|"Clone incomplete"
```

### 6. Update Bridge Sidecar State
Update `_memory/bridge-sidecar/bridge-state.md`:

```yaml
last_sync: ISO8601
last_sync_type: bootstrap
last_sync_plan_id: "{plan_id}"
sync_status: success|partial|failed

sync_statistics:
  folders_created: N
  repos_cloned: N
  repos_skipped: N
  manual_fixes_pending: N

last_drift_report: null  # reset after bootstrap
pending_conflicts: []     # clear conflicts
```

### 7. Generate Bootstrap Report
Write comprehensive report to `{docs_output_folder}/lens-sync/bootstrap-report.md`:

```markdown
# Bootstrap Report

**Generated:** {ISO8601}
**Plan ID:** {plan_id}
**Status:** {SUCCESS|PARTIAL|FAILED}

## Summary

| Metric | Count |
|--------|-------|
| Domains bootstrapped | N |
| Services bootstrapped | N |
| Microservices bootstrapped | N |
| Folders created | N |
| Repositories cloned | N |
| Items skipped | N |
| Manual fixes needed | N |

## Execution Timeline

| Time | Action | Result |
|------|--------|--------|
| HH:MM:SS | Created platform/ | ✓ |
| HH:MM:SS | Cloned auth-api | ✓ |
| HH:MM:SS | Cloned auth-ui | ✗ Auth failed |
| ... | ... | ... |

## Successfully Bootstrapped

### Domain: {name}

#### Service: {name}
- ✓ microservice-1 (cloned from {repo})
- ✓ microservice-2 (folder only)

## Failures and Skipped Items

| Item | Reason | Remediation |
|------|--------|-------------|
| payments/gateway | Auth failed | Run: `git clone {url}` manually |
| ... | ... | ... |

## Manual Fixes Required

1. **payments/gateway** - Clone failed due to authentication
   ```bash
   cd {target_root}/payments/gateway
   git clone git@github.com:org/gateway.git .
   ```

2. **business/reporting** - Remote URL mismatch
   - Current: git@github.com:fork/reporting.git
   - Expected: git@github.com:org/reporting.git
   - Action: Verify correct remote and update lens or repo

## Next Steps

1. Run `sync-status` to verify bootstrap completeness
2. Resolve manual fixes listed above
3. Run `discover` on bootstrapped repos to generate docs
4. Commit changes if working in a tracked workspace

## Rollback Information

To rollback this bootstrap:
- Snapshot ID: {snapshot_id}
- Run: `lens-sync rollback --snapshot {snapshot_id}`
```

### 8. Handle Partial Failure
If some actions fail but others succeed:

1. **DO NOT rollback automatically** - preserve successful work
2. **Mark status as PARTIAL** 
3. **List specific failures** with remediation steps
4. **Offer continue option**: "N items failed. Run bootstrap again to retry failed items?"

## Edge Cases and Failure Modes

| Condition | Action |
|-----------|--------|
| All clones fail (network down) | FAIL, preserve folder structure, report |
| Clone interrupted (Ctrl+C) | Cleanup partial clone, mark as failed |
| Disk fills mid-clone | Stop remaining clones, report space issue |
| Git LFS objects fail | Clone succeeds, warn about LFS |
| Submodules present | Warn, don't auto-init submodules |
| Report file write fails | Log to console, warn but don't fail entire operation |

## Output
```yaml
execution_result:
  status: success|partial|failed
  plan_id: string
  execution_time_seconds: N
  
  statistics:
    folders_created: N
    repos_cloned: N
    repos_failed: N
    manual_pending: N
  
  failures:
    - item: string
      error: string
      remediation: string
  
  report_path: "{docs_output_folder}/lens-sync/bootstrap-report.md"
  
  next_actions:
    - "Run sync-status to verify"
    - "Resolve N manual fixes"
```
