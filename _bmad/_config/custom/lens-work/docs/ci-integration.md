# CI/CD Integration for lens-work

## Overview

lens-work's branch topology maps naturally to CI/CD pipelines. Each branch level (workflow, phase, size) represents a different validation scope, enabling progressively stricter checks as work flows toward the base branch.

> **IMPORTANT:** Branch patterns use flat, hyphen-separated naming (no `/` separators). For example, `*-small-preplan-*` matches workflow branches like `chat-spark-xyz-small-preplan-brainstorm`. See [size-topology.md](size-topology.md) for branch naming conventions.

## Branch-Level CI Strategy

| Branch Level | CI Scope | Trigger |
|---|---|---|
| `*-{phaseName}-*` | Fast checks: lint, unit tests, format | Push |
| `*-{phaseName}` | Full validation: integration tests, artifact checks | PR merge from workflow |
| `*-small` | Audience validation: cross-phase consistency | PR merge from phase |
| `*-large` | Large review: full regression, security scan | PR merge from small |
| `{featureBranchRoot}` | Release candidate: E2E, deploy preview | PR merge from large |

## GitHub Actions Example

```yaml
# .github/workflows/lens-work-ci.yml
name: lens-work CI

on:
  push:
    branches:
      - '*-preplan-*'
      - '*-businessplan-*'
      - '*-techplan-*'
      - '*-devproposal-*'
      - '*-sprintplan-*'
  pull_request:
    branches:
      - '*-preplan'
      - '*-businessplan'
      - '*-techplan'
      - '*-devproposal'
      - '*-sprintplan'
      - '*-small'
      - '*-medium'
      - '*-large'

jobs:
  fast-checks:
    if: github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Lint & Format
        run: |
          npm ci
          npm run lint
          npm run format:check
      - name: Unit Tests
        run: npm test

  pr-validation:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Full Test Suite
        run: |
          npm ci
          npm test -- --coverage
      - name: Integration Tests
        run: npm run test:integration

  artifact-validation:
    if: >
      github.event_name == 'pull_request' &&
      contains(github.base_ref, '/small-')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate Planning Artifacts
        run: |
          # Extract phase name from branch name: {featureBranchRoot}-{audience}-{phaseName}
          # Example: chat-spark-xyz-small-businessplan → phase=businessplan
          PHASE=$(echo "${{ github.base_ref }}" | grep -oP '[^-]+$')
          ./.github/scripts/validate-artifacts.sh "$PHASE"

  large-review:
    if: >
      github.event_name == 'pull_request' &&
      endsWith(github.base_ref, '/large')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Security Scan
        run: npm audit --audit-level=high
      - name: Full Regression
        run: npm run test:all
```

## Artifact Validation

Each BMAD phase produces specific artifacts. CI can validate their presence:

| Phase | Expected Artifacts |
|-------|-------------------|
| preplan (PrePlan) | `brainstorm-notes.md`, `product-brief.md` |
| businessplan (BusinessPlan) | `prd.md`, `ux-design.md` |
| techplan (TechPlan) | `architecture.md`, `epics/`, `implementation-readiness.md` |
| sprintplan (SprintPlan) | `sprint-plan.md`, story files |

Example validation script:

```bash
#!/bin/bash
# .github/scripts/validate-artifacts.sh
PHASE=$1
ARTIFACTS_DIR="_bmad-output/planning-artifacts"

case $PHASE in
  preplan) required=("brainstorm-notes.md" "product-brief.md") ;;
  businessplan) required=("prd.md") ;;
  techplan) required=("architecture.md") ;;
  sprintplan) required=("sprint-plan.md") ;;
esac

for artifact in "${required[@]}"; do
  if [[ ! -f "$ARTIFACTS_DIR/$artifact" ]]; then
    echo "❌ Missing required artifact: $artifact"
    exit 1
  fi
done
echo "✅ All required artifacts present for $PHASE"
```

## Gate Automation

CI can automatically update lens-work gates when workflows complete:

```yaml
# Post-merge hook — update gate status
- name: Update Gate
  if: github.event.pull_request.merged == true
  run: |
    WORKFLOW=$(echo "${{ github.head_ref }}" | sed -E 's|.*/[^/]+-[0-9]+-||')
    PHASE_NUM=$(echo "${{ github.base_ref }}" | sed -E 's|.*/[^/]+-([0-9]+)$|\1|')
    PHASE="p${PHASE_NUM}"
    echo "{\"ts\":\"$(date -u +%FT%TZ)\",\"event\":\"gate-passed\",\"workflow\":\"$WORKFLOW\",\"phase\":\"$PHASE\"}" \
      >> _bmad-output/lens-work/event-log.jsonl
```

## Azure DevOps Pipelines

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - '*-small-p*-*'

pr:
  branches:
    include:
      - '*-small-p*'
      - '*-small'
      - '*-large'

stages:
  - stage: Validate
    jobs:
      - job: LintAndTest
        steps:
          - script: npm ci && npm run lint && npm test
```
