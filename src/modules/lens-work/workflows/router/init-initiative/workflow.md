---
name: init-initiative
description: User-facing initiative creation with two-file state architecture
agent: compass
trigger: "/new-domain, /new-service, /new-feature (canonical); #new-* accepted"
category: router
---

# Init Initiative Router

**Purpose:** Accept user input, resolve target repos, delegate git ops to Casey, and write the two-file state architecture for a new initiative.

---

## Input Parameters

```yaml
initiative_name: string    # User-provided name (e.g., "Rate Limiting Feature")
layer: enum                # domain | service | microservice | feature
domain: string | null      # Domain context (required for service/microservice layers)
service: string | null      # Service context (required for microservice layer)
```

---

## Execution Sequence

### 0. Verify Git State (Pre-flight Check)

```bash
# Ensure we're in BMAD control repo
if [ ! -d ".git" ] || [ ! -d "_bmad" ]; then
  error "Must run from BMAD control repo root"
  exit 1
fi

# Ensure clean working directory
if ! git diff-index --quiet HEAD --; then
  error "Uncommitted changes detected. Please commit or stash before creating initiative."
  exit 1
fi

# Sync with remote
git fetch origin main
```

### 1. Gather Initiative Details

```
🧭 New Initiative Setup

Please provide the following details:

**Name:** (descriptive name for this initiative)
**Layer:** [1] Domain  [2] Service  [3] Microservice  [4] Feature

${if layer == "service" || layer == "microservice"}
**Domain:** (parent domain for this ${layer})
${endif}

${if layer == "microservice"}
**Service:** (parent service for this microservice)
${endif}
```

### 1a. Choose Question Mode

```
How would you like to answer phase questions?

**[1] Interactive (chat)** — Current guided flow
**[2] Batch MD** — Single file per phase, filled in one shot

Select mode: [1] or [2]
```

```yaml
question_mode = selection == "2" ? "batch" : "interactive"
```

### 2. Generate Initiative ID

```bash
if [ "${layer}" == "domain" ]; then
  # Domain-layer: use domain_prefix as the initiative ID (no random suffix).
  # The domain name IS the identity — no separate initiative config file needed.
  initiative_id="${domain_prefix}"
else
  # Service/feature layers: generate random suffix
  # Format: {sanitized_name}-{random_6char}
  # Example: rate-limit-x7k2m9
  initiative_id=$(echo "${initiative_name}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c1-20)-$(openssl rand -hex 3)
fi
```

### 3. Resolve Target Repos

```yaml
service_map = load("{project-root}/_bmad/lens-work/service-map.yaml")

# Resolve based on layer
if layer == "domain":
  # Let user select multiple repos from service map
  prompt: |
    Select target repos for this domain initiative:
    ${for repo in service_map.repos}
    [${index}] ${repo.name}
    ${endfor}
    [A] All repos
  target_repos = selected_repos

elif layer == "service" || layer == "microservice":
  # Single repo selection
  prompt: |
    Select target repo:
    ${for repo in service_map.repos}
    [${index}] ${repo.name}
    ${endfor}
  target_repos = [selected_repo]

elif layer == "feature":
  # Single repo + optional dependencies from service map
  prompt: |
    Select primary repo:
    ${for repo in service_map.repos}
    [${index}] ${repo.name}
    ${endfor}
  target_repos = [selected_repo]
```

### 4. Resolve Domain Prefix

```yaml
# Domain prefix for branch naming
# Determines the {Domain} segment of branch names: {Domain}/{InitiativeId}-{audience}-p{N}-{workflow}
normalize_domain_prefix(input):
  token = input or ""
  if token contains "/":
    token = token.split("/").last_non_empty()
  token = token.to_lower()
  token = token.replace(/[^a-z0-9-]/g, "-")
  token = token.replace(/-+/g, "-").trim("-")
  return token

selected_repo = find(service_map.repos, repo => repo.name == target_repos[0])

if layer == "domain" || layer == "service" || layer == "microservice":
  # Domain/service flows must resolve from explicit domain input.
  domain_prefix = normalize_domain_prefix(domain)
elif layer == "feature":
  # Feature flows resolve from explicit domain first, then repo metadata.
  domain_prefix = normalize_domain_prefix(domain)
  if domain_prefix == "":
    domain_prefix = normalize_domain_prefix(selected_repo.domain_prefix)
  if domain_prefix == "":
    domain_prefix = normalize_domain_prefix(selected_repo.domain)
  if domain_prefix == "":
    # Expected local_path: TargetProjects/{Org}/{Domain}/{Repo}
    path_parts = split_path(selected_repo.local_path)
    domain_candidate = path_parts[2] or path_parts[1]
    domain_prefix = normalize_domain_prefix(domain_candidate)

if domain_prefix == "":
  error: "Unable to resolve domain prefix for ${initiative_name}. Provide domain or add repo domain metadata to service-map.yaml."
  exit: 1
```

### 4a. Resolve Docs Path (Docs/{Domain}/{Service}/{Repo}/{Feature})

```yaml
normalize_docs_segment(input):
  token = input or ""
  token = token.trim()
  token = token.replace(/[\\/:*?"<>|]/g, "-")
  token = token.replace(/\s+/g, "-")
  token = token.replace(/-+/g, "-").trim("-")
  return token

docs_domain = normalize_docs_segment(domain)
if docs_domain == "":
  docs_domain = normalize_docs_segment(domain_prefix)
if docs_domain == "":
  docs_domain = normalize_docs_segment(selected_repo.domain)

docs_service = normalize_docs_segment(service)
if docs_service == "":
  docs_service = normalize_docs_segment(selected_repo.service)

docs_repo = normalize_docs_segment(selected_repo.name)
docs_feature = normalize_docs_segment(initiative_id)

if layer == "domain":
  docs_service = ""
  docs_repo = ""

docs_segments = [docs_domain, docs_service, docs_repo, docs_feature].filter(seg => seg != "")
docs_path = "docs/" + docs_segments.join("/")
```

### 5. Delegate Branch Creation to Casey

```yaml
# Hand off to Casey for git operations
invoke: casey.init-initiative
params:
  initiative_id: ${initiative_id}
  initiative_name: "${initiative_name}"
  layer: ${layer}
  domain_prefix: ${domain_prefix}
  target_repos: ${target_repos}

${if layer == "domain"}
# Domain-layer: Casey creates ONLY the domain branch (pushed immediately to remote):
# - ${domain_prefix}
#
# Domain branches are organizational — no audience/phase branches needed.
# Service/feature initiatives within this domain will create their own topology.
${else}
# Casey creates (ALL pushed immediately to remote):
# - ${domain_prefix}/${initiative_id}/base
# - ${domain_prefix}/${initiative_id}-small    (review audience: small — p1 PRs target here)
# - ${domain_prefix}/${initiative_id}-medium   (review audience: medium — p2 PRs target here)
# - ${domain_prefix}/${initiative_id}-large    (review audience: large — p3/p4 PRs target here)
# - ${domain_prefix}/${initiative_id}-small-p1 (phase 1 branch, first working branch)
${endif}
```

### 6. Write Initiative Config (Git-Committed)

${if layer == "domain"}
**Domain-layer: SKIP this step.** Domain.yaml (created in Step 6a) serves as
both the domain descriptor AND the initiative config. No separate
`{initiative_id}.yaml` file is created for domain-layer.
${else}
Create directory and file at `{project-root}/_bmad-output/lens-work/initiatives/${initiative_id}.yaml`:

```yaml
id: ${initiative_id}
name: "${initiative_name}"
layer: ${layer}
domain: ${domain}
domain_prefix: ${domain_prefix}
service: ${service}
question_mode: ${question_mode}
created_at: "${ISO_TIMESTAMP}"
created_by: ${git_user}
target_repos:
${for repo in target_repos}
  - ${repo}
${endfor}
docs:
  root: "docs"
  domain: "${docs_domain}"
  service: "${docs_service}"
  repo: "${docs_repo}"
  feature: "${docs_feature}"
  path: "${docs_path}"
review_audience_map:           # Phase → review audience size
  p1: small
  p2: medium
  p3: large
  p4: large
gates:
  - name: tests-pass
    status: open
blocks: []
branches:
  base: "${domain_prefix}/${initiative_id}/base"
  audiences:
    small: "${domain_prefix}/${initiative_id}-small"
    medium: "${domain_prefix}/${initiative_id}-medium"
    large: "${domain_prefix}/${initiative_id}-large"
  active: "${domain_prefix}/${initiative_id}-small-p1"
```

> **Note:** This file is committed to the repo and shared across collaborators. It holds the canonical initiative definition, the **review audience map** (phase → audience size), and branch topology. The audience map determines which review branch each phase's PR targets.
${endif}

### 6a. Scaffold Domain Folders (Domain-Layer Only)

${if layer == "domain"}

Create domain folder structure with `.gitkeep` files and a `Domain.yaml` descriptor:

```bash
# Scaffold domain folders
DOMAIN_NAME="${domain_prefix}"

# Create domain folders with .gitkeep
mkdir -p "_bmad-output/lens-work/initiatives/${DOMAIN_NAME}"
touch "_bmad-output/lens-work/initiatives/${DOMAIN_NAME}/.gitkeep"

mkdir -p "TargetProjects/${DOMAIN_NAME}"
touch "TargetProjects/${DOMAIN_NAME}/.gitkeep"

mkdir -p "Docs/${DOMAIN_NAME}"
touch "Docs/${DOMAIN_NAME}/.gitkeep"
```

Create `{project-root}/_bmad-output/lens-work/initiatives/${DOMAIN_NAME}/Domain.yaml`.
This file serves as BOTH the domain descriptor AND the initiative config for domain-layer.
No separate `{initiative_id}.yaml` is created.

```yaml
# Domain.yaml — single source of truth for domain-layer initiatives
domain: "${domain}"
domain_prefix: "${domain_prefix}"
layer: domain
question_mode: ${question_mode}
created_at: "${ISO_TIMESTAMP}"
created_by: "${git_user}"
target_repos:
${for repo in target_repos}
  - ${repo}
${endfor}
folders:
  initiatives: "_bmad-output/lens-work/initiatives/${domain_prefix}/"
  target_projects: "TargetProjects/${domain_prefix}/"
  docs: "Docs/${domain_prefix}/"
docs:
  root: "docs"
  domain: "${docs_domain}"
  service: ""
  repo: ""
  feature: ""
  path: "${docs_path}"
branch: "${domain_prefix}"
gates:
  - name: tests-pass
    status: open
blocks: []
```

> **Note:** Domain.yaml is both the domain anchor and the initiative config for domain-layer.
> It contains target_repos, docs, gates, and blocks — the same fields other layers
> store in `{initiative_id}.yaml`. Service and feature initiatives within this domain
> will be created as separate files in the initiatives folder.
> The `.gitkeep` files ensure empty directories are committed.

${endif}

### 7. Write Personal State (Git-Ignored)

Write to `{project-root}/_bmad-output/lens-work/state.yaml`:

```yaml
active_initiative: ${initiative_id}
${if layer == "domain"}
# For domain-layer: active_initiative = domain_prefix (e.g., "bmad")
# Load via: initiatives/${active_initiative}/Domain.yaml
${else}
# For service/feature: active_initiative = generated ID (e.g., "rate-limit-x7k2m9")
# Load via: initiatives/${active_initiative}.yaml
${endif}
current:
${if layer == "domain"}
  phase: null
  phase_name: null
  workflow: null
  workflow_status: null
${else}
  phase: p1
  phase_name: "Analysis"
  workflow: null
  workflow_status: pending
${endif}
```

> **Note:** This file is git-ignored. It tracks the individual user's current position in the initiative. Each collaborator has their own local copy. Review audience is NOT stored here — derived from phase via initiative config's review_audience_map.

### 8. Log Event

Append to `{project-root}/_bmad-output/lens-work/event-log.jsonl`:

```json
{"ts":"${ISO_TIMESTAMP}","event":"init-initiative","id":"${initiative_id}","layer":"${layer}","target_repos":${JSON.stringify(target_repos)},"domain":"${domain}","service":"${service}","question_mode":"${question_mode}","docs_path":"${docs_path}"}
```

### 9. Commit Initiative Config

${if layer == "domain"}
```bash
# Domain-layer: checkout the domain branch
git checkout "${domain_prefix}"

# Stage domain scaffolding and event log (NO separate initiative config — Domain.yaml IS the config)
git add "_bmad-output/lens-work/initiatives/${domain_prefix}/Domain.yaml"
git add "_bmad-output/lens-work/initiatives/${domain_prefix}/.gitkeep"
git add "TargetProjects/${domain_prefix}/.gitkeep"
git add "Docs/${domain_prefix}/.gitkeep"
git add "_bmad-output/lens-work/event-log.jsonl"

# Create targeted commit
git commit -m "init(${domain_prefix}): Create domain '${initiative_name}'

Domain: ${domain}
Layer: domain

Creates:
- Domain branch: ${domain_prefix}
- Domain.yaml: initiatives/${domain_prefix}/Domain.yaml (domain config + initiative config)
- Domain folders: initiatives/${domain_prefix}/, TargetProjects/${domain_prefix}/, Docs/${domain_prefix}/
- Event log entry

Domain-layer: organizational branch only, no audience/phase topology.
Service and feature initiatives within this domain create their own branches."

# Push domain branch
git push -u origin "${domain_prefix}"
```
${else}
```bash
# Ensure on small-p1 branch (phase 1)
git checkout "${domain_prefix}/${initiative_id}-small-p1"

# Stage initiative config and event log (NOT state.yaml — it's git-ignored)
git add "_bmad-output/lens-work/initiatives/${initiative_id}.yaml"
git add "_bmad-output/lens-work/event-log.jsonl"

# Create targeted commit
git commit -m "init(${initiative_id}): Create ${layer} initiative '${initiative_name}'

Initiative: ${initiative_id}
Layer: ${layer}
Domain: ${domain}
Target repos: ${target_repos}

Review audience progression:
  p1 → small | p2 → medium | p3 → large | p4 → large

Creates:
- Branch topology: base, -small, -medium, -large, -small-p1
- Initiative config: initiatives/${initiative_id}.yaml (includes review_audience_map)
- Event log entry

Branch pattern: {Domain}/{id}-{audience}-p{N}-{workflow}
State architecture: two-file (personal state + shared initiative config)
Ready for /pre-plan workflow."

# Push to small-p1 branch
git push -u origin "${domain_prefix}/${initiative_id}-small-p1"
```
${endif}

### 10. Ensure .gitignore for Personal State

```bash
${if layer == "domain"}
PUSH_BRANCH="${domain_prefix}"
${else}
PUSH_BRANCH="${domain_prefix}/${initiative_id}-small-p1"
${endif}

# Ensure state.yaml is git-ignored (personal state should not be committed)
if ! grep -q "_bmad-output/lens-work/state.yaml" .gitignore 2>/dev/null; then
  echo "_bmad-output/lens-work/state.yaml" >> .gitignore
  git add .gitignore
  git commit -m "chore: gitignore personal lens-work state"
  git push origin "${PUSH_BRANCH}"
fi
```

### 10.5. Run Daily Branch Sync and Selection

Once initiative is configured, run the sync workflow to select target branch for each target repo:

```bash
# For each target repo (usually 1-3 repos)
for target_repo in ${target_repos[@]}; do
  output: |
    🔄 Setting up target repo: ${target_repo}
    
  # Invoke sync-and-select-branch workflow with force_sync=true
  # (Always sync on first initiative creation, even if profile was synced today)
  invoke_workflow:
    path: "{project-root}/_bmad/lens-work/workflows/utility/sync-and-select-branch/workflow.md"
    params:
      initiative_id: ${initiative_id}
      target_repo: ${target_repo}
      force_sync: true    # New initiatives always sync branches
    capture_result: branch_selection_result
  
  # branch_selection_result contains:
  # - branch: selected branch name
  # - commit_hash: commit SHA
  # - commit_date: ISO date
  # - cached: false (always fresh on new initiative)
  # - timestamp: sync timestamp
  
  output: |
    ✅ ${target_repo}: ${branch_selection_result.branch}
    └── Last commit: ${branch_selection_result.commit_date}
  
done

# At this point, all target repos have checked out their selected branches
# and profile.lens_work.selected_branch is populated for this initiative
```

### 11. Return Control to Compass

Output to Compass:

${if layer == "domain"}
```
✅ Domain created: ${domain_prefix}
├── Name: ${initiative_name}
├── Layer: domain
├── Domain: ${domain}
├── Question mode: ${question_mode}
├── Docs path: ${docs_path}
├── Target repos: ${target_repos}
├──
├── Branch: ${domain_prefix} (domain-only, committed & pushed)
├──
├── Domain Folders:
│   ├── Initiatives: _bmad-output/lens-work/initiatives/${domain_prefix}/
│   ├── TargetProjects: TargetProjects/${domain_prefix}/
│   └── Docs: Docs/${domain_prefix}/
├──
├── Domain Config: _bmad-output/lens-work/initiatives/${domain_prefix}/Domain.yaml
├──
├── Branch Selection:
│   ${for target_repo in target_repos}
│   ├── ${target_repo}: ${branch_selection_result[target_repo].branch}
│   │  └── Synced: ${branch_selection_result[target_repo].timestamp}
│   ${endfor}
├──
├── State Architecture:
│   ├── Personal state: _bmad-output/lens-work/state.yaml (git-ignored)
│   ├── Domain.yaml: _bmad-output/lens-work/initiatives/${domain_prefix}/Domain.yaml (committed, includes initiative config)
│   └── Profile selected_branch: _bmad-output/personal/profile.yaml (git-ignored)
├──
└── Ready for /new-service or /new-feature within this domain

State loading pattern:
  state = load("_bmad-output/lens-work/state.yaml")
  # active_initiative = domain_prefix for domain-layer
  initiative = load("_bmad-output/lens-work/initiatives/${state.active_initiative}/Domain.yaml")
  profile = load("_bmad-output/personal/profile.yaml")
```
${else}
```
✅ Initiative created: ${initiative_id}
├── Name: ${initiative_name}
├── Layer: ${layer}
├── Domain: ${domain}
├── Question mode: ${question_mode}
├── Docs path: ${docs_path}
├── Target repos: ${target_repos}
├──
├── Review Audience Progression:
│   ├── p1 (Analysis)     → small  (solo dev, 1 reviewer)
│   ├── p2 (Planning)     → medium (small team, 2-3 reviewers)
│   ├── p3 (Solutioning)  → large  (full team, formal gates)
│   └── p4 (Implementation) → large  (full team, formal gates)
├──
├── Branch Topology:
│   ├── Base: ${domain_prefix}/${initiative_id}/base
│   ├── Small audience:  ${domain_prefix}/${initiative_id}-small
│   ├── Medium audience: ${domain_prefix}/${initiative_id}-medium
│   ├── Large audience:  ${domain_prefix}/${initiative_id}-large
│   └── Phase: ${domain_prefix}/${initiative_id}-small-p1 (committed & pushed)
├──
├── Branch Selection:
│   ${for target_repo in target_repos}
│   ├── ${target_repo}: ${branch_selection_result[target_repo].branch}
│   │  └── Synced: ${branch_selection_result[target_repo].timestamp}
│   ${endfor}
├──
├── State Architecture:
│   ├── Personal state: _bmad-output/lens-work/state.yaml (git-ignored)
│   ├── Initiative config: _bmad-output/lens-work/initiatives/${initiative_id}.yaml (committed, includes review_audience_map)
│   └── Profile selected_branch: _bmad-output/personal/profile.yaml (git-ignored, includes branch + commit)
├──
└── Ready for /pre-plan

State loading pattern:
  state = load("_bmad-output/lens-work/state.yaml")
  initiative = load("_bmad-output/lens-work/initiatives/${state.active_initiative}.yaml")
  profile = load("_bmad-output/personal/profile.yaml")
  
  review_size = initiative.review_audience_map[state.current.phase]   # Phase determines audience
  selected_branch = profile.lens_work.selected_branch.branch  # Cached branch selection
```
${endif}

---

## State Architecture Reference

The three-part state architecture:

| File | Scope | Git Status | Contents |
|------|-------|------------|----------|
| `state.yaml` | Personal | git-ignored | Active initiative pointer, current phase/workflow position |
| `initiatives/{id}.yaml` | Shared | committed | Initiative definition, **review_audience_map**, gates, blocks, branches, target repos |
| `initiatives/{domain}/Domain.yaml` | Shared | committed | Domain-layer: domain descriptor + initiative config (replaces `{id}.yaml` for domain-layer) |
| `personal/profile.yaml` | Personal | git-ignored | User preferences, **branch selection + last sync timestamp** (per initiative) |

**Loading pattern used by all downstream workflows:**

```yaml
# Step 1: Load personal state to find active initiative
state = load("_bmad-output/lens-work/state.yaml")

# Step 2: Load initiative config using the active_initiative pointer
${if layer == "domain"}
# Domain-layer: active_initiative = domain_prefix (e.g., "bmad")
# Domain.yaml IS the initiative config — no separate {id}.yaml
initiative = load("_bmad-output/lens-work/initiatives/${state.active_initiative}/Domain.yaml")
${else}
initiative = load("_bmad-output/lens-work/initiatives/${state.active_initiative}.yaml")
${endif}

# Step 3: Load personal profile for branch selection and user preferences
profile = load("_bmad-output/personal/profile.yaml")

# Step 4: Use all three for workflow logic
current_phase = state.current.phase
initiative_layer = initiative.layer
${if layer != "domain"}
review_size = initiative.review_audience_map[current_phase]  # Phase determines review audience
${endif}
target_repos = initiative.target_repos
selected_branch = profile.lens_work.selected_branch.branch
last_sync_date = profile.lens_work.last_sync.date
```

---

## Error Handling

| Error | Recovery |
|-------|----------|
| Branch already exists | Prompt: "Initiative ID collision. Regenerate?" |
| Push failed | Check remote connectivity, retry with backoff |
| Service map not found | Error: "service-map.yaml missing. Run bootstrap first." |
| initiatives/ dir creation failed | Ensure _bmad-output/lens-work/ exists and is writable |
| Casey delegation failed | Output Casey error, allow retry |
| state.yaml already exists | Warn: "Active initiative found. Switch or archive first." |
| Sync-and-select-branch workflow failed | Retry manually with `/sync-now` after resolving connectivity |

---

## Post-Conditions

### All Layers
- [ ] Initiative ID generated and unique
- [ ] Initiative config created and committed (for domain: Domain.yaml; for others: `initiatives/{id}.yaml`)
- [ ] `state.yaml` written locally (git-ignored)
- [ ] `.gitignore` updated for `state.yaml`
- [ ] `event-log.jsonl` entry appended and committed
- [ ] **Target repos synced and branches selected** (via sync-and-select-branch)
- [ ] `profile.lens_work.selected_branch` and `last_sync.date` updated
- [ ] Control returned to Compass

### Domain-Layer Specific
- [ ] `initiative_id` = `domain_prefix` (no random suffix)
- [ ] Single `${domain_prefix}` branch created and pushed
- [ ] Domain folders scaffolded: `initiatives/{domain}/`, `TargetProjects/{domain}/`, `Docs/{domain}/`
- [ ] `.gitkeep` files created in all domain folders
- [ ] `Domain.yaml` created in `initiatives/{domain}/` with initiative config fields (target_repos, docs, gates, blocks)
- [ ] **No separate `{initiative_id}.yaml` file** — Domain.yaml is the single source of truth
- [ ] Ready for /new-service or /new-feature within this domain

### Service/Microservice/Feature Layers
- [ ] All 5 branches created and pushed (via Casey: base, -small, -medium, -large, -small-p1)
- [ ] Control returned to Compass for /pre-plan routing
