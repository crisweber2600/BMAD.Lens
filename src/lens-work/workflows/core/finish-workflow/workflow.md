---
name: finish-workflow
description: Commit, push, and print PR link (v2 — named phases)
agent: casey
trigger: Compass invokes when workflow completes
category: core
auto_triggered: true
imports: lifecycle.yaml
---

# Finish Workflow

**Purpose:** Commit all changes, push workflow branch, and print PR link.

---

## Input Parameters

```yaml
workflow_name: string      # Current workflow from state
commit_message: string     # Optional custom message
```

---

## Execution Sequence

### 0. Validate Branch & Sync

```bash
# Verify we're on a workflow branch
# v2 pattern: {initiative_root}-{audience}-{phase_name}-{workflow}  (flat, hyphen-separated)
current_branch=$(git branch --show-current)

# Branch must contain -(small|medium|large)-{phase_name}-{workflow}
# Valid: chat-spark-backend-xyz-small-preplan-brainstorm
# Invalid: main, chat-spark-backend-xyz, chat-spark-backend-xyz-small
if [[ ! "$current_branch" =~ -(small|medium|large)-(preplan|businessplan|techplan|devproposal|sprintplan)-[a-z0-9]+([-][a-z0-9]+)*$ ]]; then
  # Check for legacy pattern as fallback
  if [[ "$current_branch" =~ -(small|medium|large)-p[0-9]+-[a-z0-9]+([-][a-z0-9]+)*$ ]]; then
    echo "⚠️ Legacy branch naming detected: $current_branch"
    echo "└── Consider running @tracey migrate-lifecycle to update"
  else
    error "Not on a workflow branch: $current_branch"
    error "Expected pattern: {initiative_root}-{audience}-{phase_name}-{workflow}"
    exit 1
  fi
fi

# Ensure branch is checked out and up to date
git checkout "$current_branch"
git fetch origin
```

### 1. Stage Changes

```bash
# Stage all changes in BMAD control repo
git add -A
```

### 2. Commit

```bash
# Default message format
commit_msg="${commit_message:-[lens-work] Complete ${workflow_name}}"
git commit -m "${commit_msg}"
```

### 3. Push

```bash
# Push workflow branch
current_branch=$(git branch --show-current)
git push -u origin "${current_branch}"
```

### 4. Generate PR Link

```bash
# Detect remote type
remote_url=$(git remote get-url origin)

# Parse components from flat branch: {initiative_root}-{audience}-{phase_name}-{workflow}
# e.g., chat-spark-backend-xyz-small-preplan-brainstorm
# Load initiative_root from config to reliably parse
state = load("_bmad-output/lens-work/state.yaml")
initiative = load("_bmad-output/lens-work/initiatives/${state.active_initiative}.yaml")
initiative_root = initiative.initiative_root

# Strip initiative_root prefix to parse remaining segments
segment="${current_branch#${initiative_root}-}"  # small-preplan-brainstorm
audience=$(echo "$segment" | cut -d'-' -f1)       # small
phase_name=$(echo "$segment" | cut -d'-' -f2)     # preplan
workflow=$(echo "$segment" | cut -d'-' -f3-)      # brainstorm

# Target is the phase branch (without workflow suffix)
# e.g., chat-spark-backend-xyz-small-preplan
target_branch="${initiative_root}-${audience}-${phase_name}"
source_branch="${current_branch}"

# Generate PR link based on remote type
if [[ "$remote_url" == *"github.com"* ]]; then
  pr_link="https://github.com/${org}/${repo}/compare/${target_branch}...${source_branch}"
elif [[ "$remote_url" == *"gitlab.com"* ]]; then
  pr_link="https://gitlab.com/${org}/${repo}/-/merge_requests/new?source_branch=${source_branch}&target_branch=${target_branch}"
elif [[ "$remote_url" == *"dev.azure.com"* ]]; then
  pr_link="https://dev.azure.com/${org}/${project}/_git/${repo}/pullrequestcreate?sourceRef=${source_branch}&targetRef=${target_branch}"
fi
```

### 4a. Load PAT and Create PR (HARD GATE)

```yaml
# Load user profile for git credentials
profile = load("_bmad-output/personal/profile.yaml")

# Determine which host PAT to use by matching remote URL
remote_host = extract_hostname(remote_url)  # e.g., "github.com"

pat = null
if profile.git_credentials != null:
  for cred in profile.git_credentials:
    if cred.host == remote_host:
      pat = cred.pat
      break

if pat == null:
  error: |
    ⚠️ HARD GATE: No PAT found for host '${remote_host}'
    ├── Run @scout onboard to configure git credentials
    ├── Or manually add to _bmad-output/personal/profile.yaml:
    │   git_credentials:
    │     - host: "${remote_host}"
    │       pat: "your-pat-here"
    │       type: "github"  # or "gitlab", "azure"
    └── Then re-run this workflow
  exit: 1
```

```bash
# Create actual PR using GitHub CLI (or equivalent for other hosts)
if [[ "$remote_url" == *"github.com"* ]]; then
  # Parse org/repo from remote URL
  org_repo=$(echo "$remote_url" | sed -E 's|https://github\.com/||; s|\.git$||')

  export GH_TOKEN="${pat}"

  pr_result=$(gh pr create \
    --repo "${org_repo}" \
    --base "${target_branch}" \
    --head "${source_branch}" \
    --title "feat(${initiative_root}): Complete ${workflow_name}" \
    --body "## Workflow Complete: ${workflow_name}

**Initiative:** ${initiative_root}
**Phase:** ${phase_name}
**Audience:** ${audience}
**Branch:** ${source_branch} → ${target_branch}

### Changes
All artifacts from the ${workflow_name} workflow.

---
*Created automatically by lens-work finish-workflow*" 2>&1)

  pr_exit_code=$?

  if [ $pr_exit_code -ne 0 ]; then
    # Check if PR already exists
    if echo "$pr_result" | grep -q "already exists"; then
      echo "ℹ️ PR already exists for this branch"
      pr_url=$(gh pr view "${source_branch}" --repo "${org_repo}" --json url -q '.url' 2>/dev/null)
    else
      echo "❌ HARD GATE: PR creation failed"
      echo "├── Error: ${pr_result}"
      echo "├── Source: ${source_branch}"
      echo "├── Target: ${target_branch}"
      echo "└── Fix the issue and re-run finish-workflow"
      exit 1
    fi
  else
    pr_url="${pr_result}"
  fi

elif [[ "$remote_url" == *"gitlab.com"* ]]; then
  # GitLab: Use API to create merge request
  org_repo=$(echo "$remote_url" | sed -E 's|https://gitlab\.com/||; s|\.git$||')
  encoded_repo=$(echo "$org_repo" | sed 's|/|%2F|g')

  pr_result=$(curl -s -X POST \
    "https://gitlab.com/api/v4/projects/${encoded_repo}/merge_requests" \
    -H "PRIVATE-TOKEN: ${pat}" \
    -d "source_branch=${source_branch}" \
    -d "target_branch=${target_branch}" \
    -d "title=feat(${initiative_root}): Complete ${workflow_name}" \
    -d "description=Workflow ${workflow_name} complete for ${initiative_root}")

  pr_url=$(echo "$pr_result" | jq -r '.web_url // empty')

  if [ -z "$pr_url" ]; then
    echo "❌ HARD GATE: MR creation failed"
    echo "├── Response: ${pr_result}"
    echo "└── Fix the issue and re-run finish-workflow"
    exit 1
  fi

elif [[ "$remote_url" == *"dev.azure.com"* ]]; then
  # Azure DevOps: Use REST API to create pull request
  ado_org=$(echo "$remote_url" | sed -E 's|https://dev\.azure\.com/([^/]+)/.*|\1|')
  ado_project=$(echo "$remote_url" | sed -E 's|https://dev\.azure\.com/[^/]+/([^/]+)/.*|\1|')
  ado_repo=$(echo "$remote_url" | sed -E 's|.*/_git/([^/]+)(\.git)?$|\1|')

  pr_result=$(curl -s -X POST \
    "https://dev.azure.com/${ado_org}/${ado_project}/_apis/git/repositories/${ado_repo}/pullrequests?api-version=7.0" \
    -H "Authorization: Basic $(echo -n ":${pat}" | base64)" \
    -H "Content-Type: application/json" \
    -d "{\"sourceRefName\":\"refs/heads/${source_branch}\",\"targetRefName\":\"refs/heads/${target_branch}\",\"title\":\"feat(${initiative_root}): Complete ${workflow_name}\"}")

  pr_url=$(echo "$pr_result" | jq -r '.url // empty')

  if [ -z "$pr_url" ]; then
    echo "❌ HARD GATE: PR creation failed"
    echo "├── Response: ${pr_result}"
    echo "└── Fix the issue and re-run finish-workflow"
    exit 1
  fi

else
  echo "⚠️ Unknown remote type: ${remote_url}"
  echo "├── PR link (manual): ${pr_link}"
  echo "└── Create PR manually before proceeding"
  pr_url="${pr_link}"
fi

echo "✅ PR created: ${pr_url}"
```

### 5. Update State

```yaml
# Update state.yaml
workflow_status: idle

# Phase status is updated by finish-phase, not finish-workflow
```

### 6. Log Event

```json
{"ts":"${ISO_TIMESTAMP}","event":"finish-workflow","workflow":"${workflow_name}","phase":"${phase_name}","audience":"${audience}","pr_url":"${pr_url}"}
```

### 7. Output

```
✅ Workflow complete: ${workflow_name}
├── Committed: ${commit_hash}
├── Pushed: ${current_branch}
├── PR Created: ${pr_url}
├── Phase: ${phase_name} (${audience} audience)
└── HARD GATE: PR must be merged before next workflow can start
```

---

## Error Handling

| Error | Recovery |
|-------|----------|
| Nothing to commit | Warn but continue (empty workflow) |
| Push rejected | Pull + rebase, then retry |
| Remote type unknown | Output manual PR instructions with link |
| **No PAT found** | **HARD GATE: Run @scout onboard to configure credentials** |
| **PR creation failed** | **HARD GATE: Fix issue and re-run finish-workflow** |
| **PR already exists** | Use existing PR URL, continue |
| Legacy branch detected | Warn about migration, continue with adapter |
