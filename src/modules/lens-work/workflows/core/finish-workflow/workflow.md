---
name: finish-workflow
description: Commit, push, and print PR link
agent: casey
trigger: Compass invokes when workflow completes
category: core
auto_triggered: true
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
current_branch=$(git branch --show-current)
if [[ ! "$current_branch" =~ ^lens/.*/(w|p[0-9]+) ]]; then
  error "Not on a workflow or phase branch: $current_branch"
  exit 1
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

# Parse components
initiative_id=$(echo ${current_branch} | cut -d'/' -f2)
lane=$(echo ${current_branch} | cut -d'/' -f3)
phase=$(echo ${current_branch} | cut -d'/' -f4)

target_branch="lens/${initiative_id}/${lane}/${phase}"
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

### 5. Update State

```yaml
# Update gates in state.yaml
gates:
  - name: "${phase}/w/${workflow_name}"
    status: completed
    completed_at: "${ISO_TIMESTAMP}"
    pr_link: "${pr_link}"

current:
  workflow_status: completed
```

### 6. Log Event

```json
{"ts":"${ISO_TIMESTAMP}","event":"finish-workflow","workflow":"${workflow_name}","pr":"${pr_link}"}
```

### 7. Output

```
✅ Workflow complete: ${workflow_name}
├── Committed: ${commit_hash}
├── Pushed: ${current_branch}
├── PR: ${pr_link}
└── Next: Merge PR, then continue to next workflow
```

---

## Error Handling

| Error | Recovery |
|-------|----------|
| Nothing to commit | Warn but continue (empty workflow) |
| Push rejected | Pull + rebase, then retry |
| Remote type unknown | Output manual PR instructions |
