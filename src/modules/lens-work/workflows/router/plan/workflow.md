---
name: plan
description: Complete Solutioning (Epics/Stories/Readiness)
agent: compass
trigger: /plan command
category: router
phase: 3
phase_name: Solutioning
---

# /plan — Solutioning Phase Router

**Purpose:** Complete the Solutioning phase with Epics, Stories, and Readiness checklist.

---

## Role Authorization

**Authorized:** PO, Architect, Tech Lead

---

## Prerequisites

- [x] `/spec` complete (Phase 2 merged)
- [x] Large review approved (small → large merged)
- [x] state.yaml + initiatives/{id}.yaml exist
- [x] P2 gate passed (Planning artifacts committed)

---

## Execution Sequence

### 0. Git Discipline — Verify Clean State

```yaml
# Verify working directory is clean
invoke: casey.verify-clean-state

# Load two-file state
state = load("_bmad-output/lens-work/state.yaml")
initiative = load("_bmad-output/lens-work/initiatives/${state.active_initiative}.yaml")

# Read lane from initiative config (shared, canonical)
lane = initiative.lane
domain_prefix = initiative.domain_prefix

# === Path Resolver (S01-S06: Context Enhancement) ===
docs_path = initiative.docs.path    # e.g., "docs/BMAD/LENS/BMAD.Lens/context-enhancement-9bfe4e"
repo_docs_path = "docs/${initiative.docs.domain}/${initiative.docs.service}/${initiative.docs.repo}"

if docs_path == null or docs_path == "":
  # Fallback for older initiatives without docs block
  docs_path = "_bmad-output/planning-artifacts/"
  repo_docs_path = null
  warning: "⚠️ DEPRECATED: Initiative missing docs.path configuration."
  warning: "  → Run: /compass migrate <initiative-id> to add docs.path"
  warning: "  → This fallback will be removed in a future version."

output_path = docs_path
ensure_directory(output_path)

# === Context Loader (S08: Context Enhancement) ===
product_brief = load_file("${docs_path}/product-brief.md")
prd = load_file("${docs_path}/prd.md")
architecture = load_file("${docs_path}/architecture.md")

if product_brief == null or prd == null or architecture == null:
  FAIL("Required planning artifacts missing from ${docs_path}/")

if repo_docs_path != null:
  repo_readme = load_if_exists("${repo_docs_path}/README.md")
  repo_setup = load_if_exists("${repo_docs_path}/SETUP.md")
  repo_context = { readme: repo_readme, setup: repo_setup }
else:
  repo_context = null

# Validate we're on the correct branch (or can switch)
# Branch pattern: {Domain}/{InitiativeId}/{size}-{phaseNumber}
expected_branch: "${domain_prefix}/${initiative.id}/${lane}-3"
current_branch = casey.get-current-branch()

if current_branch != expected_branch:
  if branch_exists(expected_branch):
    invoke: casey.checkout-branch
    params:
      branch: ${expected_branch}
    invoke: casey.pull-latest
  # else: branch will be created in Step 2
```

### 1. Validate Prerequisites & Gate Check

```yaml
# Gate check — verify P2 (Spec/Planning) is complete
# Branch pattern: {Domain}/{InitiativeId}/{size}-{phaseNumber}
p2_branch = "${domain_prefix}/${initiative.id}/${lane}-2"
lane_branch = "${domain_prefix}/${initiative.id}/${lane}"

# Ancestry check: P2 must be merged into lane
result = casey.exec("git merge-base --is-ancestor origin/${p2_branch} origin/${lane_branch}")

if result.exit_code != 0:
  error: "Phase 2 (Planning) not complete. Run /spec first or merge pending PRs."

# Verify large review is merged (if applicable)
if not large_review_merged():
  warning: "Large review PR not merged. Proceeding but architecture may change."

# Verify P2 artifacts exist
required_artifacts:
  - "${docs_path}/prd.md"
  - "${docs_path}/architecture.md"

for artifact in required_artifacts:
  if not file_exists(artifact):
    # Fallback: check legacy path for backward compatibility
    legacy_path = artifact.replace("${docs_path}/", "_bmad-output/planning-artifacts/")
    if file_exists(legacy_path):
      warning: "Found artifact at legacy path: ${legacy_path}. Consider migrating."
    else:
      warning: "Required artifact not found: ${artifact}."
```

### 2. Start Phase 3 — Auto-Branch Creation

```yaml
# Casey creates P3 branch if it doesn't exist
# Branch pattern: {Domain}/{InitiativeId}/{size}-{phaseNumber}
if not branch_exists("${domain_prefix}/${initiative.id}/${lane}-3"):
  invoke: casey.start-phase
  params:
    phase_number: 3
    phase_name: "Solutioning"
    initiative_id: ${initiative.id}
    lane: ${lane}
    domain_prefix: ${domain_prefix}
  # Casey creates: ${domain_prefix}/{initiative_id}/{lane}-3 and pushes to remote

  invoke: casey.pull-latest
else:
  # Branch exists, ensure we're on it
  invoke: casey.checkout-branch
  params:
    branch: "${domain_prefix}/${initiative.id}/${lane}-3"
  invoke: casey.pull-latest
```

### 2a. Batch Mode (Single-File Questions)

```yaml
if initiative.question_mode == "batch":
  invoke: lens-work.batch-process
  params:
    phase_number: "3"
    phase_name: "Solutioning"
    template_path: "templates/phase-3-solutioning-questions.template.md"
    output_filename: "phase-3-solutioning-questions.md"
  exit: 0
```

### 3. Execute Workflows

#### Epics — Story Breakdown Integration:
```yaml
invoke: casey.start-workflow
params:
  workflow_name: epics

# Reference Epic generation workflow from BMM module
invoke: bmm.create-epics
params:
  architecture: "${docs_path}/architecture.md"
  prd: "${docs_path}/prd.md"
  output_path: "${docs_path}/"

invoke: casey.finish-workflow
```

#### Stories — Story Breakdown Integration:
```yaml
invoke: casey.start-workflow
params:
  workflow_name: stories

# Reference Story generation workflow from BMM module
invoke: bmm.create-stories
params:
  epics: "${docs_path}/epics.md"
  architecture: "${docs_path}/architecture.md"
  output_path: "${docs_path}/"

invoke: casey.finish-workflow
```

#### Readiness Checklist:
```yaml
invoke: casey.start-workflow
params:
  workflow_name: readiness

invoke: bmm.readiness-checklist
params:
  artifacts:
    - product-brief.md
    - prd.md
    - architecture.md
    - epics.md
    - stories.md
  output_path: "${docs_path}/"

invoke: casey.finish-workflow
```

### 4. Phase Completion

```yaml
if all_workflows_complete("p3"):
  invoke: casey.finish-phase
  invoke: casey.open-final-pbr  # PR: large → base
  
  output: |
    ✅ /plan complete
    ├── Phase 3 (Solutioning) finished
    ├── Final PBR PR opened (large → base)
    ├── Stories ready for sprint planning
    └── Next: Run /review for implementation gate
```

### 5. Update State Files

```yaml
# Update initiative file: _bmad-output/lens-work/initiatives/${initiative.id}.yaml
invoke: tracey.update-initiative
params:
  initiative_id: ${initiative.id}
  updates:
    current_phase: "p3"
    current_phase_name: "Solutioning"
    phases:
      p3:
        status: "in_progress"
        started_at: "${ISO_TIMESTAMP}"
    gates:
      p2_complete:
        status: "passed"
        verified_at: "${ISO_TIMESTAMP}"
      large_review:
        status: "passed"
        verified_at: "${ISO_TIMESTAMP}"

# Update state.yaml
invoke: tracey.update-state
params:
  updates:
    current_phase: "p3"
    current_phase_name: "Solutioning"
    active_branch: "${domain_prefix}/${initiative.id}/${lane}-3"
```

### 6. Commit State Changes

```yaml
# Casey commits all state and artifact changes
invoke: casey.commit-and-push
params:
  paths:
    - "_bmad-output/lens-work/state.yaml"
    - "_bmad-output/lens-work/initiatives/${initiative.id}.yaml"
    - "_bmad-output/lens-work/event-log.jsonl"
    - "${docs_path}/"
  message: "[lens-work] /plan: Phase 3 Solutioning — ${initiative.id}"
  branch: "${domain_prefix}/${initiative.id}/${lane}-3"
```

### 7. Log Event

```json
{"ts":"${ISO_TIMESTAMP}","event":"plan","id":"${initiative.id}","phase":"p3","workflow":"plan","status":"complete"}
```

---

## Output Artifacts

| Artifact | Location |
|----------|----------|
| Epics | `${docs_path}/epics.md` |
| Stories | `${docs_path}/stories.md` |
| Readiness | `${docs_path}/readiness-checklist.md` |
| Initiative State | `_bmad-output/lens-work/initiatives/${id}.yaml` |

---

## Error Handling

| Error | Recovery |
|-------|----------|
| P2 not complete | Error with merge instructions |
| Lead review not merged | Warn but allow proceeding |
| PRD/Architecture missing | Warn, proceeding may produce incomplete epics |
| Dirty working directory | Prompt to stash or commit changes first |
| Branch creation failed | Check remote connectivity, retry with backoff |
| P2 ancestry check failed | Prompt to merge P2 PR before continuing |
| Epic/Story generation failed | Retry or allow manual creation |
| State file write failed | Retry (max 3 attempts), then fail with save instructions |

---

## Post-Conditions

- [ ] Working directory clean (all changes committed)
- [ ] On correct branch: `{domain_prefix}/{initiative_id}/{lane}-3`
- [ ] state.yaml updated with phase p3
- [ ] initiatives/{id}.yaml updated with p3 status and p2 gate passed
- [ ] event-log.jsonl entry appended
- [ ] Planning artifacts written to `${docs_path}/` (epics, stories, readiness-checklist)
- [ ] Final PBR PR opened (large → base)
- [ ] All changes pushed to origin
