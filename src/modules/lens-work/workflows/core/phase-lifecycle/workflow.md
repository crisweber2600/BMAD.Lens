---
name: phase-lifecycle
description: Start and finish phase operations
agent: casey
trigger: Phase transitions via Compass
category: core
auto_triggered: true
---

# Phase Lifecycle Workflows

---

## Start Phase

**Purpose:** Create phase branch from size when first workflow of phase begins.

### Input

```yaml
phase_number: int          # 1, 2, 3, 4
phase_name: string         # "Analysis", "Planning", "Solutioning", "Implementation"
size: string               # "small" or "large"
initiative_id: string
```

### Sequence

0. **Verify Git State**
   ```bash
   # Ensure clean working tree in BMAD control repo
   if ! git diff-index --quiet HEAD --; then
     echo "Uncommitted changes detected. Commit or stash before starting a phase."
     exit 1
   fi

   git fetch origin
   ```

1. **Validate Previous Phase**
   ```bash
   if [ ${phase_number} -gt 1 ]; then
     prev_phase="p$((phase_number - 1))"
     # Check all workflows in prev_phase are merged
     if ! all_workflows_merged ${prev_phase}; then
       echo "⚠️ Phase ${prev_phase} not complete. Finish all workflows first."
       exit 1
     fi
   fi
   ```

2. **Create Phase Branch**
   ```bash
   git checkout "bmad/${initiative_id}/${size}"
   git pull origin "bmad/${initiative_id}/${size}"
   git checkout -b "bmad/${initiative_id}/${size}/p${phase_number}"
   git push -u origin "bmad/${initiative_id}/${size}/p${phase_number}"
   ```

3. **Update State**
   ```yaml
   current:
     phase: "p${phase_number}"
     phase_name: "${phase_name}"
   ```

4. **Log Event**
   ```json
   {"ts":"${ISO_TIMESTAMP}","event":"start-phase","phase":"p${phase_number}","size":"${size}"}
   ```

5. **Commit Phase Start**
    ```bash
    # Ensure we're on the new phase branch
    git checkout "bmad/${initiative_id}/${size}/p${phase_number}"

    # Stage state + event log
    git add _bmad-output/lens-work/state.yaml _bmad-output/lens-work/event-log.jsonl

    # Commit only if there are changes
    if ! git diff-index --quiet HEAD --; then
       git commit -m "phase(p${phase_number}): Start ${phase_name} (${initiative_id})"
       git push origin "bmad/${initiative_id}/${size}/p${phase_number}"
    else
       echo "No phase-start changes to commit."
    fi
    ```

---

## Finish Phase

**Purpose:** Push phase branch and print PR to size after all workflows complete.

### Sequence

0. **Verify Git State**
   ```bash
   # Ensure clean working tree in BMAD control repo
   if ! git diff-index --quiet HEAD --; then
     echo "Uncommitted changes detected. Commit or stash before finishing a phase."
     exit 1
   fi

   git fetch origin
   ```

1. **Validate All Workflows Complete**
   ```bash
   if ! all_workflows_merged ${phase}; then
     echo "⚠️ Not all workflows merged. Complete remaining workflows."
     exit 1
   fi
   ```

2. **Push Phase Branch**
   ```bash
   git push origin "bmad/${initiative_id}/${size}/${phase}"
   ```

3. **Load PAT & Create PR (HARD GATE)**
   ```yaml
   # Load user profile for git credentials
   profile = load("_bmad-output/personal/profile.yaml")
   
   # Determine which host PAT to use by matching remote URL
   remote_url = shell("git remote get-url origin")
   remote_host = extract_hostname(remote_url)
   
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
       └── Then re-run finish-phase
     exit: 1
   ```

   ```bash
   # Create PR: phase → size (using same multi-host logic as finish-workflow)
   source_branch="bmad/${initiative_id}/${size}/${phase}"
   target_branch="bmad/${initiative_id}/${size}"
   
   if [[ "$remote_url" == *"github.com"* ]]; then
     org_repo=$(echo "$remote_url" | sed -E 's|https://github\.com/||; s|\.git$||')
     export GH_TOKEN="${pat}"
     
     pr_result=$(gh pr create \
       --repo "${org_repo}" \
       --base "${target_branch}" \
       --head "${source_branch}" \
       --title "phase(${phase}): Complete ${phase_name} for ${initiative_id}" \
       --body "## Phase Complete: ${phase_name}

   **Initiative:** ${initiative_id}
   **Phase:** ${phase} (${phase_name})
   **Size:** ${size}
   
   All workflows in this phase have been completed and merged.
   
   ---
   *Created automatically by lens-work phase-lifecycle*" 2>&1)
     
     pr_exit_code=$?
     if [ $pr_exit_code -ne 0 ]; then
       if echo "$pr_result" | grep -q "already exists"; then
         echo "ℹ️ PR already exists for this phase"
         pr_url=$(gh pr view "${source_branch}" --repo "${org_repo}" --json url -q '.url' 2>/dev/null)
       else
         echo "❌ HARD GATE: PR creation failed"
         echo "├── Error: ${pr_result}"
         echo "└── Fix the issue and re-run finish-phase"
         exit 1
       fi
     else
       pr_url="${pr_result}"
     fi
   
   elif [[ "$remote_url" == *"gitlab.com"* ]]; then
     org_repo=$(echo "$remote_url" | sed -E 's|https://gitlab\.com/||; s|\.git$||')
     encoded_repo=$(echo "$org_repo" | sed 's|/|%2F|g')
     pr_result=$(curl -s -X POST \
       "https://gitlab.com/api/v4/projects/${encoded_repo}/merge_requests" \
       -H "PRIVATE-TOKEN: ${pat}" \
       -d "source_branch=${source_branch}" \
       -d "target_branch=${target_branch}" \
       -d "title=phase(${phase}): Complete ${phase_name} for ${initiative_id}")
     pr_url=$(echo "$pr_result" | jq -r '.web_url // empty')
     if [ -z "$pr_url" ]; then
       echo "❌ HARD GATE: MR creation failed"
       exit 1
     fi
   
   elif [[ "$remote_url" == *"dev.azure.com"* ]]; then
     ado_org=$(echo "$remote_url" | sed -E 's|https://dev\.azure\.com/([^/]+)/.*|\1|')
     ado_project=$(echo "$remote_url" | sed -E 's|https://dev\.azure\.com/[^/]+/([^/]+)/.*|\1|')
     ado_repo=$(echo "$remote_url" | sed -E 's|.*/_git/([^/]+)(\.git)?$|\1|')
     pr_result=$(curl -s -X POST \
       "https://dev.azure.com/${ado_org}/${ado_project}/_apis/git/repositories/${ado_repo}/pullrequests?api-version=7.0" \
       -H "Authorization: Basic $(echo -n ":${pat}" | base64)" \
       -H "Content-Type: application/json" \
       -d "{\"sourceRefName\":\"refs/heads/${source_branch}\",\"targetRefName\":\"refs/heads/${target_branch}\",\"title\":\"phase(${phase}): Complete ${phase_name}\"}")
     pr_url=$(echo "$pr_result" | jq -r '.url // empty')
     if [ -z "$pr_url" ]; then
       echo "❌ HARD GATE: PR creation failed"
       exit 1
     fi
   
   else
     echo "⚠️ Unknown remote type. Create PR manually: ${source_branch} → ${target_branch}"
     pr_url="manual"
   fi
   
   echo "✅ Phase PR created: ${pr_url}"
   ```

4. **Log Event**
   ```json
   {"ts":"${ISO_TIMESTAMP}","event":"finish-phase","phase":"${phase}","pr_url":"${pr_url}"}
   ```

5. **Commit Phase Finish**
   ```bash
   # Ensure we're on the phase branch
   git checkout "bmad/${initiative_id}/${size}/${phase}"

   # Stage state + event log
   git add _bmad-output/lens-work/state.yaml _bmad-output/lens-work/event-log.jsonl

   # Commit only if there are changes
   if ! git diff-index --quiet HEAD --; then
     git commit -m "phase(${phase}): Finish ${initiative_id} phase"
     git push origin "bmad/${initiative_id}/${size}/${phase}"
   else
     echo "No phase-finish changes to commit."
   fi
   ```

6. **Output**
   ```
   ✅ Phase ${phase} complete
   ├── All workflows merged
   ├── PR Created: ${pr_url}
   ├── HARD GATE: PR must be merged before next phase can proceed
   └── Ready for next phase (after PR merge)
   ```

---

## Open Large Review

**Trigger:** Phase 2 complete + architecture workflow merged

**Purpose:** Open PR from small → large for large review.

```bash
# Validate p2 complete
if phase_complete "p2"; then
  pr_link="${remote}/compare/large...small"
  echo "🔍 Large Review Ready"
  echo "├── PR: ${pr_link}"
  echo "└── Assign large reviewers"
fi
```

---

## Open Final PBR

**Trigger:** Large review merged

**Purpose:** Open PR from large → base for final product backlog review.

```bash
# Validate large merged from small
if large_merged_from_small; then
  pr_link="${remote}/compare/base...large"
  echo "📋 Final PBR Ready"
  echo "├── PR: ${pr_link}"
  echo "└── Ready for implementation planning"
fi
```
