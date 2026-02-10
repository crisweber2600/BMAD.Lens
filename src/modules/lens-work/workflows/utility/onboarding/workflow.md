---
name: onboarding
description: Full onboarding — profile, repo reconciliation, state init, welcome
agent: scout
trigger: "@scout onboard" or "@lens-work onboard"
category: utility
first_run: true
---

# Onboarding Workflow

**Purpose:** Create user profile, reconcile TargetProjects against service map, initialize personal state, and orient new team members with next steps.

**⚠️ CRITICAL:** Profile settings override equivalent values in `bmad-config.yaml`. Repo reconciliation delegates health checks to the `check-repos` workflow. State initialization detects legacy format and suggests migration.

---

## Input Parameters

```yaml
# None required — all inputs gathered interactively
```

---

## Execution Sequence

### 0. Welcome

```
🔭 Welcome to LENS Workbench!

I'm Scout, your setup guide. I'll walk you through:
1. Creating your personal profile
2. Reconciling your TargetProjects repos
3. Initializing your workbench state
4. Getting you ready to start building

This takes about 3-5 minutes. Ready? [Y]es / [L]ater
```

```yaml
response = prompt_user("[Y]es / [L]ater")
if response == "L":
  output: "No problem — run @scout onboard when you're ready."
  exit: 0
```

---

## Section 1: Profile Creation

### 1.1 Read Git Config

```bash
# Auto-detect identity from git config
git_user_name=$(git config user.name 2>/dev/null || echo "")
git_user_email=$(git config user.email 2>/dev/null || echo "")

if [ -z "$git_user_name" ]; then
  echo "⚠️ git config user.name not set"
fi
if [ -z "$git_user_email" ]; then
  echo "⚠️ git config user.email not set"
fi
```

```yaml
if git_user_name != "":
  output: "👤 Detected git identity: ${git_user_name} <${git_user_email}>"
  output: "Use this? [Y]es / [N]o (enter manually)"
  confirm = prompt_user()
  if confirm == "N":
    git_user_name = prompt_user("Enter your name:")
    git_user_email = prompt_user("Enter your email:")
else:
  git_user_name = prompt_user("Enter your name:")
  git_user_email = prompt_user("Enter your email:")
```

### 1.2 Select Role

```yaml
output: |
  🎭 What's your primary role?
  
  [1] Developer
  [2] PM (Product Manager)
  [3] Architect
  [4] Tech Lead
  [5] Scrum Master

role_choice = prompt_user("[1-5]")

role_map = {
  "1": "Developer",
  "2": "PM",
  "3": "Architect",
  "4": "Tech Lead",
  "5": "Scrum Master"
}

selected_role = role_map[role_choice]
output: "Role: ${selected_role} ✓"
```

### 1.3 Save Profile

```yaml
profile = {
  name: git_user_name,
  email: git_user_email,
  role: selected_role,
  created_at: now_iso(),
  preferences: {
    auto_fetch: true,
    status_on_start: true,
    color_output: true
  }
}

# Ensure output directory exists
mkdir_p("_bmad-output/personal")

save(profile, "_bmad-output/personal/profile.yaml")
```

Profile file format:

```yaml
# _bmad-output/personal/profile.yaml
name: "Jane Smith"
email: "jane.smith@example.com"
role: "Developer"
created_at: "2026-02-05T14:30:00Z"
preferences:
  auto_fetch: true
  status_on_start: true
  color_output: true
```

> **Note:** Profile values override equivalent settings in `bmad-config.yaml`. For example, `role` in the profile takes precedence over any default role configured at the project level.

```yaml
output: |
  ✅ Profile saved to _bmad-output/personal/profile.yaml
  
  ${git_user_name} (${selected_role})
```

---

## Section 1.5: Git Credentials (PAT Onboarding)

**Purpose:** Collect Personal Access Tokens (PATs) for each unique git host found in the repo inventory. These are required for creating PRs via finish-workflow and finish-phase hard gates.

### 1.5.1 Detect Unique Git Hosts

```yaml
# Scan repo-inventory.yaml and service-map.yaml for unique remote URLs
# If inventory doesn't exist yet, scan service-map.yaml remotes
service_map_paths:
  - "_bmad/lens-work/service-map.yaml"
  - "_lens/domain-map.yaml"
  - "lens/domain-map.yaml"

detected_hosts = []
remote_urls = []

# First try repo-inventory (already has remotes from prior scans)
if file_exists("_bmad-output/lens-work/repo-inventory.yaml"):
  inventory = load("_bmad-output/lens-work/repo-inventory.yaml")
  for repo in inventory.repos:
    if repo.remote and repo.remote != "no-remote" and repo.remote != "unknown":
      remote_urls.append(repo.remote)

# Fall back to service map
if remote_urls.length == 0:
  for path in service_map_paths:
    if file_exists(path):
      sm = load(path)
      for repo in sm.repos:
        if repo.remote_url:
          remote_urls.append(repo.remote_url)
      break

# Also check control repo remote
control_remote = shell("git remote get-url origin 2>/dev/null") or ""
if control_remote != "":
  remote_urls.append(control_remote)

# Extract unique hosts
for url in remote_urls:
  host = extract_hostname(url)  # e.g., "github.com", "gitlab.com", "dev.azure.com"
  if host not in detected_hosts:
    detected_hosts.append(host)
```

### 1.5.2 Classify Hosts

```yaml
# Map each host to a git provider type
host_types = {}
for host in detected_hosts:
  if "github.com" in host or "github" in host:
    host_types[host] = "github"
  elif "gitlab.com" in host or "gitlab" in host:
    host_types[host] = "gitlab"
  elif "dev.azure.com" in host or "visualstudio.com" in host:
    host_types[host] = "azure-devops"
  elif "bitbucket.org" in host:
    host_types[host] = "bitbucket"
  else:
    host_types[host] = "generic"
```

### 1.5.3 Collect PATs

```yaml
output: |
  🔑 Git Credentials Setup
  ═══════════════════════════
  
  lens-work needs Personal Access Tokens (PATs) to create PRs automatically.
  These are stored locally in your profile — never committed to git.
  
  Detected ${detected_hosts.length} unique git host(s):
  ${for host in detected_hosts}
    - ${host} (${host_types[host]})
  ${endfor}
  
  Configure PATs now? [Y]es / [S]kip (can configure later via @scout credentials)

cred_choice = prompt_user("[Y]es / [S]kip")

git_credentials = []

if cred_choice == "Y":
  for host in detected_hosts:
    host_type = host_types[host]
    
    # Show host-specific instructions
    if host_type == "github":
      output: |
        🔗 ${host} (GitHub)
        
        📋 How to create a GitHub Personal Access Token:
        
        1. Go to https://github.com/settings/tokens
        2. Click **"Generate new token"** → select **"Fine-grained token"** (recommended)
        3. Give it a descriptive name (e.g., "LENS Workbench")
        4. Set an expiration (90 days recommended, or custom)
        5. Under **Repository access**, select **"Only select repositories"**
           and choose the repos you work with
        6. Under **Permissions → Repository permissions**, grant:
           • **Contents**: Read and write
           • **Pull requests**: Read and write
           • **Workflows**: Read and write (if using GitHub Actions)
        7. Click **"Generate token"** and copy it immediately
           (you won't be able to see it again!)
        
        💡 Alternatively, for a classic token:
        • Click **"Generate new token (classic)"**
        • Select scopes: **repo**, **workflow**
        • Generate and copy the token
        
        ⚠️ Store your token securely — treat it like a password.
    elif host_type == "gitlab":
      output: |
        🔗 ${host} (GitLab)
        ├── Create PAT: https://${host}/-/user_settings/personal_access_tokens
        ├── Required scopes: api, write_repository
        └── Recommended: Project-scoped token
    elif host_type == "azure-devops":
      output: |
        🔗 ${host} (Azure DevOps)
        ├── Create PAT: https://dev.azure.com/{org}/_usersSettings/tokens
        ├── Required scopes: Code (Read & Write), Pull Request Contribute
        └── Recommended: Custom defined, minimum scopes
    elif host_type == "bitbucket":
      output: |
        🔗 ${host} (Bitbucket)
        ├── Create App Password: https://bitbucket.org/account/settings/app-passwords/
        ├── Required permissions: Repositories (Write), Pull requests (Write)
        └── Use your Bitbucket username as the user field
    else:
      output: |
        🔗 ${host} (Generic Git Host)
        ├── Create a personal access token with PR/merge-request permissions
        └── Consult your git host's documentation
    
    pat = prompt_user("Enter PAT for ${host} (or press Enter to skip):", sensitive=true)
    
    if pat != "":
      git_credentials.append({
        host: host,
        type: host_type,
        pat: pat,
        configured_at: now_iso()
      })
      output: "  ✅ ${host} configured"
    else:
      output: "  ⏭️ ${host} skipped (can add later)"
  
  output: |
    
    🔑 Credentials summary:
    ├── Configured: ${git_credentials.length} / ${detected_hosts.length} hosts
    └── Stored in: _bmad-output/personal/profile.yaml (git_credentials section)

elif cred_choice == "S":
  output: |
    ⏭️ PAT setup skipped. You can configure later:
    ├── Run: @scout credentials
    └── Or manually edit _bmad-output/personal/profile.yaml
```

### 1.5.4 Save Credentials to Profile

```yaml
# Append git_credentials to existing profile
profile = load("_bmad-output/personal/profile.yaml")

profile.git_credentials = git_credentials

# Also store which hosts were detected but not configured
profile.detected_git_hosts = detected_hosts

save(profile, "_bmad-output/personal/profile.yaml")
```

Updated profile format with credentials:

```yaml
# _bmad-output/personal/profile.yaml
name: "Jane Smith"
email: "jane.smith@example.com"
role: "Developer"
created_at: "2026-02-05T14:30:00Z"
preferences:
  auto_fetch: true
  status_on_start: true
  color_output: true

# Git credentials for PR automation (NEVER committed to git)
git_credentials:
  - host: "github.com"
    type: "github"
    pat: "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    configured_at: "2026-02-05T14:31:00Z"
  - host: "dev.azure.com"
    type: "azure-devops"
    pat: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    configured_at: "2026-02-05T14:31:30Z"

detected_git_hosts:
  - "github.com"
  - "dev.azure.com"

# Lens-work sync tracking (added by daily sync)
lens_work:
  last_sync_date: null
  selected_branch: null
```

> **⚠️ SECURITY NOTE:** The profile.yaml file with PATs must NEVER be committed to git. Ensure `_bmad-output/personal/` is in `.gitignore`.

---

## Section 2: Repository Reconciliation

### 2.1 Load Expected Repos (Service Map)

```yaml
# Load service map from standard locations
service_map_paths:
  - "_bmad/lens-work/service-map.yaml"
  - "_lens/domain-map.yaml"
  - "lens/domain-map.yaml"

service_map = null
for path in service_map_paths:
  if file_exists(path):
    service_map = load(path)
    service_map_path = path
    break

if service_map == null:
  output: |
    ⚠️ No service map found. Skipping repo reconciliation.
    
    Create a service map at _bmad/lens-work/service-map.yaml
    then run @scout onboard again to reconcile repos.
  skip_reconciliation = true
else:
  output: "📋 Service map loaded from: ${service_map_path}"
  skip_reconciliation = false
```

### 2.2 Load Existing Inventory

```yaml
if not skip_reconciliation:
  inventory_path = "_bmad-output/lens-work/repo-inventory.yaml"
  
  if file_exists(inventory_path):
    existing_inventory = load(inventory_path)
    output: "📦 Existing inventory found (last scanned: ${existing_inventory.scanned_at})"
  else:
    existing_inventory = null
    output: "📦 No existing inventory — will create fresh"
```

### 2.3 Scan TargetProjects Directory

```bash
# Build actual repo list by scanning for .git directories
target_projects_path="${service_map.target_projects_path:-TargetProjects}"

actual_repos=()
for dir in $(find "${target_projects_path}" -maxdepth 5 -type d -name ".git" -exec dirname {} \;); do
  repo_name=$(basename "$dir")
  repo_path=$(realpath --relative-to="." "$dir")
  remote=$(git -C "$dir" remote get-url origin 2>/dev/null || echo "no-remote")
  branch=$(git -C "$dir" branch --show-current 2>/dev/null || echo "detached")
  commit=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null || echo "unknown")
  uncommitted=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l)
  
  actual_repos+=("${repo_name}|${repo_path}|${remote}|${branch}|${commit}|${uncommitted}")
done
```

### 2.4 Compare Expected vs Actual

```yaml
if not skip_reconciliation:
  comparison = {
    matched: [],
    missing: [],
    extra: [],
    issues: []
  }

  # Check each expected repo from service map
  for expected in service_map.repos:
    found = find_in(actual_repos, expected.name)
    
    if found:
      entry = {
        name: expected.name,
        path: found.path,
        remote: found.remote,
        current_branch: found.branch,
        last_commit: found.commit,
        has_uncommitted: found.uncommitted > 0,
        is_git_repo: true
      }
      comparison.matched.append(entry)
      
      # Check for issues
      if found.uncommitted > 0:
        comparison.issues.append({
          repo: expected.name,
          issue: "uncommitted_changes",
          detail: "${found.uncommitted} uncommitted file(s)"
        })
      
      if found.branch != expected.default_branch:
        comparison.issues.append({
          repo: expected.name,
          issue: "wrong_branch",
          detail: "On '${found.branch}', expected '${expected.default_branch}'"
        })
    else:
      comparison.missing.append({
        name: expected.name,
        expected_path: expected.local_path,
        remote: expected.remote_url,
        action: "clone"
      })

  # Check for extra repos not in service map
  for actual in actual_repos:
    if actual.name not in [r.name for r in service_map.repos]:
      comparison.extra.append({
        name: actual.name,
        path: actual.path,
        remote: actual.remote,
        note: "Not in service map"
      })
```

### 2.5 Present Reconciliation Plan

```yaml
if not skip_reconciliation:
  output: |
    📊 Repo Reconciliation Results
    ═══════════════════════════════
    ├── ✅ Matched: ${comparison.matched.length} repos
    ├── ⚠️ Missing: ${comparison.missing.length} repos
    ├── ❓ Extra: ${comparison.extra.length} repos
    └── 🔧 Issues: ${comparison.issues.length}
  
  # Handle missing repos
  if comparison.missing.length > 0:
    output: |
      
      📥 Missing repos (need clone):
      ${for repo in comparison.missing}
        - ${repo.name}: ${repo.remote}
          → ${repo.expected_path}
      ${endfor}
      
      Clone missing repos? [Y]es / [N]o / [S]elect individually
    
    clone_choice = prompt_user()
    
    if clone_choice == "Y":
      for repo in comparison.missing:
        output: "Cloning ${repo.name}..."
        shell: git clone "${repo.remote}" "${repo.expected_path}"
    elif clone_choice == "S":
      for repo in comparison.missing:
        output: "Clone ${repo.name}? [Y/N]"
        if prompt_user() == "Y":
          shell: git clone "${repo.remote}" "${repo.expected_path}"
  
  # Handle extra repos
  if comparison.extra.length > 0:
    output: |
      
      ❓ Extra repos (not in service map):
      ${for repo in comparison.extra}
        - ${repo.name} at ${repo.path}
      ${endfor}
      
      Add to service map? [Y]es / [I]gnore / [S]elect individually
    
    extra_choice = prompt_user()
    
    if extra_choice == "Y":
      for repo in comparison.extra:
        service_map.repos.append({
          name: repo.name,
          local_path: repo.path,
          remote_url: repo.remote,
          default_branch: "main"
        })
      save(service_map, service_map_path)
      output: "✅ Service map updated with ${comparison.extra.length} new repo(s)"
    elif extra_choice == "S":
      for repo in comparison.extra:
        output: "Add ${repo.name} to service map? [Y/N]"
        if prompt_user() == "Y":
          service_map.repos.append({
            name: repo.name,
            local_path: repo.path,
            remote_url: repo.remote,
            default_branch: "main"
          })
      save(service_map, service_map_path)
  
  # Handle issues
  if comparison.issues.length > 0:
    output: |
      
      🔧 Issues detected:
      ${for issue in comparison.issues}
        - ${issue.repo}: ${issue.issue} — ${issue.detail}
      ${endfor}
    
    # Wrong branch issues
    branch_issues = [i for i in comparison.issues if i.issue == "wrong_branch"]
    if branch_issues.length > 0:
      output: "Fix branch issues (checkout default branch)? [Y]es / [N]o"
      if prompt_user() == "Y":
        for issue in branch_issues:
          repo = find_repo(comparison.matched, issue.repo)
          shell: git -C "${repo.path}" checkout "${service_map.get_default_branch(issue.repo)}"
    
    # Uncommitted changes — warn only
    uncommitted_issues = [i for i in comparison.issues if i.issue == "uncommitted_changes"]
    if uncommitted_issues.length > 0:
      output: |
        ⚠️ Repos with uncommitted changes (manual action needed):
        ${for issue in uncommitted_issues}
          - ${issue.repo}: ${issue.detail}
        ${endfor}
```

### 2.6 Delegate Health Checks

```yaml
if not skip_reconciliation:
  # Delegate per-repo health checks to check-repos workflow
  invoke: scout.check-repos
  params:
    repos: comparison.matched
    verbose: false
  
  health_results = check_repos_output
```

---

## Section 3: Inventory Update

### 3.1 Build Reconciled Inventory

```yaml
if not skip_reconciliation:
  # Re-scan after reconciliation (repos may have been cloned/fixed)
  reconciled_repos = []
  
  for expected in service_map.repos:
    repo_dir = expected.local_path
    
    if dir_exists(repo_dir) AND is_git_repo(repo_dir):
      remote = shell("git -C '${repo_dir}' remote get-url origin 2>/dev/null") or "no-remote"
      branch = shell("git -C '${repo_dir}' branch --show-current 2>/dev/null") or "detached"
      commit = shell("git -C '${repo_dir}' rev-parse --short HEAD 2>/dev/null") or "unknown"
      uncommitted = shell("git -C '${repo_dir}' status --porcelain 2>/dev/null | wc -l")
      
      # Extract domain/service from path structure
      path_parts = expected.local_path.split("/")
      domain = path_parts[1] if path_parts.length >= 3 else "default"
      service = path_parts[2] if path_parts.length >= 4 else "default"
      
      reconciled_repos.append({
        name: expected.name,
        path: expected.local_path,
        remote: remote,
        current_branch: branch,
        last_commit: commit,
        has_uncommitted: int(uncommitted) > 0,
        is_git_repo: true,
        domain: domain,
        service: service,
        last_scanned: now_iso()
      })
    else:
      reconciled_repos.append({
        name: expected.name,
        path: expected.local_path,
        remote: expected.remote_url or "unknown",
        current_branch: "n/a",
        last_commit: "n/a",
        has_uncommitted: false,
        is_git_repo: false,
        domain: "unknown",
        service: "unknown",
        last_scanned: now_iso()
      })
```

### 3.2 Write Inventory

Write to `_bmad-output/lens-work/repo-inventory.yaml`:

```yaml
version: 2
scanned_at: "${ISO_TIMESTAMP}"
onboarding_run: true

repos:
  - name: "{repo_name}"
    path: "TargetProjects/{domain}/{service}/{repo_name}"
    remote: "{remote_url}"
    current_branch: "{branch}"
    last_commit: "{commit_hash}"
    has_uncommitted: false
    is_git_repo: true
    domain: "{domain}"
    service: "{service}"
    last_scanned: "{ISO_TIMESTAMP}"

summary:
  total_expected: ${service_map.repos.length}
  total_found: ${reconciled_repos.filter(r => r.is_git_repo).length}
  healthy: ${healthy_count}
  issues: ${issue_count}
```

```yaml
if not skip_reconciliation:
  inventory = {
    version: 2,
    scanned_at: now_iso(),
    onboarding_run: true,
    repos: reconciled_repos,
    summary: {
      total_expected: service_map.repos.length,
      total_found: reconciled_repos.filter(r => r.is_git_repo).length,
      healthy: reconciled_repos.filter(r => r.is_git_repo AND not r.has_uncommitted).length,
      issues: comparison.issues.length
    }
  }
  
  save(inventory, "_bmad-output/lens-work/repo-inventory.yaml")
  output: "✅ Inventory updated: _bmad-output/lens-work/repo-inventory.yaml"
```

---

## Section 4: State Initialization

### 4.1 Check Existing State

```yaml
state_path = "_bmad-output/lens-work/state.yaml"

if file_exists(state_path):
  existing_state = load(state_path)
  output: "📍 Existing state found"
  
  # Check for legacy single-file format
  if existing_state.initiative != null AND existing_state.active_initiative == null:
    output: |
      ⚠️ Legacy state format detected (single-file).
      The current format uses two-file architecture:
        - state.yaml (personal state + active initiative pointer)
        - initiatives/{id}.yaml (initiative config)
      
      Run @tracey migrate-state to upgrade.
    legacy_detected = true
  else:
    legacy_detected = false
else:
  output: "📍 No state file — will create initial state"
  legacy_detected = false
```

### 4.2 Create Initial State (if needed)

```yaml
if not file_exists(state_path):
  initial_state = {
    version: 2,
    active_initiative: null,
    profile_ref: "_bmad-output/personal/profile.yaml",
    current: {
      phase: null,
      phase_name: null,
      workflow: null,
      workflow_status: "idle",
      size: selected_size
    },
    last_updated: now_iso()
  }
  
  save(initial_state, state_path)
  output: "✅ State initialized: ${state_path}"
```

### 4.3 Check for Existing Initiatives

```yaml
initiatives_dir = "_bmad-output/lens-work/initiatives"

if dir_exists(initiatives_dir):
  initiative_files = list_files(initiatives_dir, "*.yaml")
  initiative_count = initiative_files.length
  
  if initiative_count > 0:
    output: |
      📂 Found ${initiative_count} existing initiative(s):
      ${for file in initiative_files}
        - ${file.name_without_ext}
      ${endfor}
else:
  mkdir_p(initiatives_dir)
  initiative_count = 0
  output: "📂 Created initiatives directory: ${initiatives_dir}"
```

### 4.4 Ensure Event Log Exists

```yaml
event_log_path = "_bmad-output/lens-work/event-log.jsonl"

if not file_exists(event_log_path):
  touch(event_log_path)
  output: "📝 Created event log: ${event_log_path}"

# Log onboarding event
append_jsonl(event_log_path, {
  ts: now_iso(),
  event: "onboarding",
  user: git_user_name,
  role: selected_role,
  size: selected_size,
  repos_tracked: reconciled_repos.length or 0
})
```

---

## Section 5: Welcome and Next Steps

### 5.1 Compute Summary Counts

```yaml
if not skip_reconciliation:
  repos_tracked = inventory.summary.total_found
  repos_healthy = inventory.summary.healthy
  repos_issues = inventory.summary.issues
else:
  repos_tracked = 0
  repos_healthy = 0
  repos_issues = 0
```

### 5.2 Display Completion

```
✅ Onboarding complete!
├── Profile: _bmad-output/personal/profile.yaml
├── Credentials: ${git_credentials.length} / ${detected_hosts.length} git hosts configured
├── Repos: ${repos_tracked} tracked, ${repos_healthy} healthy, ${repos_issues} issues
├── State: initialized
├── Initiatives: ${initiative_count} found
│
├── 🚀 Next Steps:
│   ├── Start a new feature: @compass /new-feature "your feature"
│   ├── Switch context: @compass /switch
│   ├── Check status: @compass ?
│   ├── Configure credentials: @scout credentials
│   └── Get help: @compass H
```

---

## Section 5.3: Git Credentials Management (Post-Onboarding)

For post-onboarding credential management, use the **manage-credentials** workflow:

```bash
@scout credentials
@compass /credentials
```

This workflow provides advanced PAT management:
- **Add new credentials** for additional git hosts
- **Update existing credentials** when PATs expire or rotate
- **Remove credentials** when hosts are no longer needed
- **Re-detect hosts** from repos and service map
- **Test credentials** for validity before use

### Credentials Storage

Git credentials are stored in `_bmad-output/personal/profile.yaml` under the `git_credentials` section:

```yaml
git_credentials:
  - host: "github.com"
    type: "github"
    pat: "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    configured_at: "2026-02-05T14:31:00Z"
  - host: "dev.azure.com"
    type: "azure-devops"
    pat: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    configured_at: "2026-02-05T14:31:30Z"
```

⚠️ **SECURITY:** This file must NEVER be committed to git. Ensure `_bmad-output/personal/` is in `.gitignore`.

---

## Error Handling

| Error | Recovery |
|-------|----------|
| `git config` not set | Prompt for name/email manually |
| Service map not found | Skip reconciliation, warn user to create one |
| Clone fails | Log error, continue with remaining repos, report at end |
| State file corrupted | Back up existing, create fresh state |
| Initiatives dir inaccessible | Create directory, warn if permission error |
| Legacy state detected | Do not overwrite — suggest `@tracey migrate-state` |
| Profile already exists | Ask: overwrite / keep existing / merge |

---

## Post-Conditions

- [ ] Profile saved to `_bmad-output/personal/profile.yaml`
- [ ] Git credentials (PATs) collected for detected hosts and saved to profile
- [ ] `_bmad-output/personal/` is confirmed in `.gitignore` (PATs must not be committed)
- [ ] Service map loaded and reconciled against TargetProjects
- [ ] Missing repos offered for cloning; extra repos offered for service-map addition
- [ ] Repo inventory updated at `_bmad-output/lens-work/repo-inventory.yaml`
- [ ] `_bmad-output/lens-work/state.yaml` exists (created or preserved)
- [ ] `_bmad-output/lens-work/initiatives/` directory exists
- [ ] `_bmad-output/lens-work/event-log.jsonl` has onboarding event
- [ ] Legacy state format detected and migration suggested (if applicable)
- [ ] Completion summary displayed with next-step commands
