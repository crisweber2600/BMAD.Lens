---
name: 'step-00-preflight'
description: 'Preflight checks and guardrails'
nextStepFile: './step-01-load-lens-map.md'
---

# Step 0: Preflight

## Goal
Validate prerequisites and guardrails before bootstrapping. This step is the primary safeguard against accidental data loss and ensures all dependencies are available.

## Instructions

### 1. Validate Target Project Root
```
target_path = resolve_absolute(config.target_project_root)
```
- **Check existence**: If `target_path` does not exist, FAIL with message: "Target project root does not exist: {path}"
- **Check is directory**: If exists but is file, FAIL: "Target must be a directory, found file: {path}"
- **Check permissions**: Verify read/write access. Test by attempting to create `.lens-preflight-test` then delete.
- **Check symlink safety**: If `target_path` contains symlinks, resolve them and verify final path is still under intended workspace. Reject paths that escape via `..` or symlink chains.

### 2. Validate Lens Root and Schema Files
Locate lens root at `{target_path}/_lens/` or `{target_path}/lens/` (check both, prefer `_lens`).

**Required files:**
| File | Purpose | Validation |
|------|---------|------------|
| `domain-map.yaml` | Domain structure | Must parse as valid YAML, must have `domains` key |
| `service.yaml` (per domain) | Service definitions | Path from domain-map must resolve, must have `services` array |

**Validation procedure:**
```yaml
# domain-map.yaml expected structure
domains:
  - name: string (required)
    path: string (required, relative)
    service_file: string (optional, defaults to 'service.yaml')
```

For each domain entry:
1. Resolve `{lens_root}/{domain.path}/{domain.service_file}`
2. Verify file exists and is valid YAML
3. Collect all referenced `git_repo` URLs for later validation

### 3. Resolve and Secure Output Folder
```
docs_path = resolve_absolute(config.docs_output_folder)
```
**Security checks:**
- Must not contain `..` after resolution
- Must be under `target_project_root` (compare canonicalized paths)
- Must not be a symlink pointing outside `target_project_root`
- Must not collide with reserved paths: `_lens/`, `.git/`, `node_modules/`

**If missing:** Create with `mkdir -p` equivalent. Record in preflight notes.

### 4. Git Environment Validation
**Required checks:**
```bash
# Verify git is available
git --version  # Must succeed

# Verify we're in a git repo OR cloning to non-repo location is acceptable
git rev-parse --git-dir 2>/dev/null || echo "Not a git repo"
```

**Working tree status:**
```bash
git status --porcelain
```
- If output is non-empty, record dirty files
- If dirty AND no rollback snapshot exists, WARN: "Working tree has uncommitted changes. Recommend creating snapshot before proceeding."

**Clone prerequisites:**
- Verify SSH key or HTTPS credentials can authenticate (test with `git ls-remote` on first repo URL)
- Check disk space: Estimate ~500MB per repo minimum, warn if <2GB free

### 5. Create Pre-Bootstrap Snapshot
```bash
# Create rollback point in sidecar
snapshot_id = "bootstrap-pre-{timestamp}"
snapshot_path = "_memory/bridge-sidecar/snapshots/{snapshot_id}/"

# Record current state
- List of existing directories under target_project_root
- Hash of domain-map.yaml
- Hash of each service.yaml
```
Store in `_memory/bridge-sidecar/bridge-state.md`:
```yaml
last_snapshot: {snapshot_id}
snapshot_timestamp: {ISO8601}
snapshot_trigger: bootstrap-preflight
```

### 6. JIRA Integration Check (Conditional)
**If `enable_jira_integration == true`:**
- Check for JIRA config file at `{lens_root}/jira-config.yaml` or environment variables `JIRA_URL`, `JIRA_USER`, `JIRA_TOKEN`
- Validate credentials with a lightweight API call (e.g., `/rest/api/2/myself`)
- If validation fails, downgrade to WARN (don't block bootstrap)

**If `enable_jira_integration == false`:**
- Skip all JIRA checks, note in preflight output

### 7. User Confirmation Gate
Before proceeding, present summary:
```
BOOTSTRAP PREFLIGHT SUMMARY
===========================
Target Root:     {target_project_root}
Lens Root:       {lens_root}
Domains Found:   {count}
Services Found:  {count}
Repos to Clone:  {count}
Output Folder:   {docs_output_folder}
Git Status:      {clean|dirty with N files}
Snapshot:        {snapshot_id}
JIRA:            {enabled|disabled}

⚠️  This will create folders and clone repositories.
Existing folders matching lens structure will be PRESERVED (not overwritten) unless you confirm.

Proceed? [y/N]
```

## Edge Cases and Failure Modes

| Condition | Action |
|-----------|--------|
| `target_project_root` is `/` or `/home` | REJECT - too dangerous |
| Lens root has circular domain references | FAIL with cycle detection output |
| Git credentials expired mid-check | FAIL with re-auth instructions |
| Disk full | FAIL before any writes occur |
| domain-map.yaml has YAML syntax errors | FAIL with line number and fix hint |
| User declines confirmation | EXIT cleanly, no changes |

## Output
```yaml
preflight_status:
  result: pass|fail
  timestamp: ISO8601
  target_root: /absolute/path
  lens_root: /absolute/path
  domains_found: N
  services_found: N
  repos_to_clone: N
  git_status: clean|dirty
  dirty_files: [list if dirty]
  snapshot_id: string
  jira_enabled: boolean
  jira_validated: boolean|null
  warnings: [list]
  errors: [list]
  remediation_checklist: [list if failed]
```
