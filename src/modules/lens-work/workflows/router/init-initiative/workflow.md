---
name: init-initiative
description: User-facing initiative creation with two-file state architecture
agent: compass
trigger: "#new-domain, #new-service, #new-feature"
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

### 2. Generate Initiative ID

```bash
# Format: {sanitized_name}-{random_6char}
# Example: rate-limit-x7k2m9
initiative_id=$(echo "${initiative_name}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c1-20)-$(openssl rand -hex 3)
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

### 4. Delegate Branch Creation to Casey

```yaml
# Hand off to Casey for git operations
invoke: casey.init-initiative
params:
  initiative_id: ${initiative_id}
  initiative_name: "${initiative_name}"
  layer: ${layer}
  target_repos: ${target_repos}
  
# Casey creates:
# - lens/${initiative_id}/base
# - lens/${initiative_id}/small
# - lens/${initiative_id}/lead
# - lens/${initiative_id}/small/p1
```

### 5. Write Initiative Config (Git-Committed)

Create directory and file at `{project-root}/_bmad-output/lens-work/initiatives/${initiative_id}.yaml`:

```yaml
id: ${initiative_id}
name: "${initiative_name}"
layer: ${layer}
domain: ${domain}
service: ${service}
created_at: "${ISO_TIMESTAMP}"
created_by: ${git_user}
target_repos:
${for repo in target_repos}
  - ${repo}
${endfor}
gates:
  - name: tests-pass
    status: open
blocks: []
branches:
  base: "lens/${initiative_id}/base"
  active: "lens/${initiative_id}/small/p1"
```

> **Note:** This file is committed to the repo and shared across collaborators. It holds the canonical initiative definition and configuration.

### 6. Write Personal State (Git-Ignored)

Write to `{project-root}/_bmad-output/lens-work/state.yaml`:

```yaml
active_initiative: ${initiative_id}
current:
  phase: p1
  phase_name: "Analysis"
  workflow: null
  workflow_status: pending
  lane: small
```

> **Note:** This file is git-ignored. It tracks the individual user's current position in the initiative. Each collaborator has their own local copy.

### 7. Log Event

Append to `{project-root}/_bmad-output/lens-work/event-log.jsonl`:

```json
{"ts":"${ISO_TIMESTAMP}","event":"init-initiative","id":"${initiative_id}","layer":"${layer}","target_repos":${JSON.stringify(target_repos)},"domain":"${domain}","service":"${service}"}
```

### 8. Commit Initiative Config

```bash
# Ensure on p1 branch
git checkout "lens/${initiative_id}/small/p1"

# Stage initiative config and event log (NOT state.yaml — it's git-ignored)
git add "_bmad-output/lens-work/initiatives/${initiative_id}.yaml"
git add "_bmad-output/lens-work/event-log.jsonl"

# Create targeted commit
git commit -m "init(${initiative_id}): Create ${layer} initiative '${initiative_name}'

Initiative: ${initiative_id}
Layer: ${layer}
Domain: ${domain}
Target repos: ${target_repos}

Creates:
- Branch topology: base, small, lead, p1
- Initiative config: initiatives/${initiative_id}.yaml
- Event log entry

State architecture: two-file (personal state + initiative config)
Ready for /pre-plan workflow."

# Push to p1 branch
git push -u origin "lens/${initiative_id}/small/p1"
```

### 9. Ensure .gitignore for Personal State

```bash
# Ensure state.yaml is git-ignored (personal state should not be committed)
if ! grep -q "_bmad-output/lens-work/state.yaml" .gitignore 2>/dev/null; then
  echo "_bmad-output/lens-work/state.yaml" >> .gitignore
  git add .gitignore
  git commit -m "chore: gitignore personal lens-work state"
  git push origin "lens/${initiative_id}/small/p1"
fi
```

### 10. Return Control to Compass

Output to Compass:

```
✅ Initiative created: ${initiative_id}
├── Name: ${initiative_name}
├── Layer: ${layer}
├── Domain: ${domain}
├── Target repos: ${target_repos}
├──
├── Branch Topology:
│   ├── Base: lens/${initiative_id}/base
│   ├── Small: lens/${initiative_id}/small
│   ├── Lead: lens/${initiative_id}/lead
│   └── Phase: lens/${initiative_id}/small/p1 (committed & pushed)
├──
├── State Architecture:
│   ├── Personal state: _bmad-output/lens-work/state.yaml (git-ignored)
│   └── Initiative config: _bmad-output/lens-work/initiatives/${initiative_id}.yaml (committed)
├──
└── Ready for /pre-plan

State loading pattern:
  state = load("_bmad-output/lens-work/state.yaml")
  initiative = load("_bmad-output/lens-work/initiatives/${state.active_initiative}.yaml")
```

---

## State Architecture Reference

The two-file state architecture separates concerns:

| File | Scope | Git Status | Contents |
|------|-------|------------|----------|
| `state.yaml` | Personal | git-ignored | Active initiative pointer, current phase/workflow position |
| `initiatives/{id}.yaml` | Shared | committed | Initiative definition, gates, blocks, branches, target repos |

**Loading pattern used by all downstream workflows:**

```yaml
# Step 1: Load personal state to find active initiative
state = load("_bmad-output/lens-work/state.yaml")

# Step 2: Load initiative config using the active_initiative pointer
initiative = load("_bmad-output/lens-work/initiatives/${state.active_initiative}.yaml")

# Step 3: Use both for workflow logic
current_phase = state.current.phase
initiative_layer = initiative.layer
target_repos = initiative.target_repos
gates = initiative.gates
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

---

## Post-Conditions

- [ ] Initiative ID generated and unique
- [ ] All 4 branches created and pushed (via Casey)
- [ ] `initiatives/{id}.yaml` created and committed
- [ ] `state.yaml` written locally (git-ignored)
- [ ] `.gitignore` updated for `state.yaml`
- [ ] `event-log.jsonl` entry appended and committed
- [ ] Control returned to Compass for /pre-plan routing
