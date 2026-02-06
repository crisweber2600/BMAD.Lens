# CI/CD Integration for lens-work

## Overview

lens-work's branch topology maps naturally to CI/CD pipelines. Each branch level (workflow, phase, lane) represents a different validation scope, enabling progressively stricter checks as work flows toward the base branch.

## Branch-Level CI Strategy

| Branch Level | CI Scope | Trigger |
|---|---|---|
| `lens/*/small/p*/w/*` | Fast checks: lint, unit tests, format | Push |
| `lens/*/small/p*` | Full validation: integration tests, artifact checks | PR merge from workflow |
| `lens/*/small` | Lane validation: cross-phase consistency | PR merge from phase |
| `lens/*/lead` | Lead review: full regression, security scan | PR merge from small |
| `lens/*/base` | Release candidate: E2E, deploy preview | PR merge from lead |

## GitHub Actions Example

```yaml
# .github/workflows/lens-work-ci.yml
name: lens-work CI

on:
  push:
    branches:
      - 'lens/*/small/p*/w/**'
  pull_request:
    branches:
      - 'lens/*/small/p*'
      - 'lens/*/small'
      - 'lens/*/lead'

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
      contains(github.base_ref, '/small/')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate Planning Artifacts
        run: |
          # Check that required artifacts exist for the phase
          PHASE=$(echo "${{ github.base_ref }}" | grep -oP 'p\d+')
          ./.github/scripts/validate-artifacts.sh "$PHASE"

  lead-review:
    if: >
      github.event_name == 'pull_request' &&
      endsWith(github.base_ref, '/lead')
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
| p1 (Analysis) | `brainstorm-notes.md`, `product-brief.md` |
| p2 (Planning) | `prd.md`, `ux-design.md` |
| p3 (Solutioning) | `architecture.md`, `epics/`, `implementation-readiness.md` |
| p4 (Implementation) | `sprint-plan.md`, story files |

Example validation script:

```bash
#!/bin/bash
# .github/scripts/validate-artifacts.sh
PHASE=$1
ARTIFACTS_DIR="_bmad-output/planning-artifacts"

case $PHASE in
  p1) required=("brainstorm-notes.md" "product-brief.md") ;;
  p2) required=("prd.md") ;;
  p3) required=("architecture.md") ;;
  p4) required=("sprint-plan.md") ;;
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
    WORKFLOW=$(echo "${{ github.head_ref }}" | grep -oP 'w/\K.*')
    PHASE=$(echo "${{ github.base_ref }}" | grep -oP 'p\d+')
    echo "{\"ts\":\"$(date -u +%FT%TZ)\",\"event\":\"gate-passed\",\"workflow\":\"$WORKFLOW\",\"phase\":\"$PHASE\"}" \
      >> _bmad-output/lens-work/event-log.jsonl
```

## Azure DevOps Pipelines

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - 'lens/*/small/p*/w/*'

pr:
  branches:
    include:
      - 'lens/*/small/p*'
      - 'lens/*/small'
      - 'lens/*/lead'

stages:
  - stage: Validate
    jobs:
      - job: LintAndTest
        steps:
          - script: npm ci && npm run lint && npm test
```
