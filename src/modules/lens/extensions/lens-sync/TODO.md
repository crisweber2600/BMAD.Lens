# TODO: LENS Sync & Discovery

Development roadmap for lens (lens-sync extension).

---

## Agents to Build

- [x] Bridge (The Synchronizer)
  - Use: `bmad:bmb:agents:agent-builder`
  - Spec: `agents/bridge.spec.md`
- [x] Scout (Discovery Specialist)
  - Use: `bmad:bmb:agents:agent-builder`
  - Spec: `agents/scout.spec.md`
- [x] Link (Lens Guardian)
  - Use: `bmad:bmb:agents:agent-builder`
  - Spec: `agents/link.spec.md`

---

## Workflows to Build

- [x] bootstrap
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/bootstrap/bootstrap.spec.md`
- [x] sync-status
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/sync-status/sync-status.spec.md`
- [x] reconcile
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/reconcile/reconcile.spec.md`
- [x] discover
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/discover/discover.spec.md`
- [x] analyze-codebase
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/analyze-codebase/analyze-codebase.spec.md`
- [x] generate-docs
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/generate-docs/generate-docs.spec.md`
- [x] update-lens
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/update-lens/update-lens.spec.md`
- [x] validate-schema
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/validate-schema/validate-schema.spec.md`
- [x] rollback
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/rollback/rollback.spec.md`

---

## Planning & Scope

- [x] Define scope boundaries (in/out of lens-sync extension) — documented in docs/scope.md
- [x] Establish MVP priorities and milestone sequencing — documented in docs/scope.md
- [x] Define success criteria and acceptance checklist (per agent/workflow) — documented in docs/scope.md
- [x] Map dependencies and prerequisites across workflows — documented in docs/scope.md
- [x] Confirm spec files exist and align with roadmap scope — documented in docs/scope.md

---

## Architecture & Integration

- [x] Document agent/workflow interaction map (inputs/outputs, handoffs) — documented in docs/architecture.md
- [x] Define integration contracts & schemas (lens metadata, docs output) — documented in docs/architecture.md
- [x] Identify external dependencies and required versions (JIRA, tooling, repo layout) — documented in docs/prerequisites.md
- [x] Define ownership/responsibility matrix and escalation path — documented in docs/operations.md

---

## Testing & QA

- [ ] Test installation with `bmad install lens` (blocked: `bmad` CLI not installed in workspace)
- [ ] Verify module.yaml prompts work correctly (blocked: `bmad` CLI not installed in workspace)
- [ ] Test installer.js for docs folder and prompts copy (blocked: requires installer harness)
- [ ] Test IDE-specific handlers (if added) (blocked: requires installer harness)
- [x] Create unit/integration/end-to-end test plan for agents + workflows — documented in docs/testing.md
- [x] Add regression test repo or fixtures for discovery workflows — created fixtures/regression-fixture/
- [x] Define CI gates for tests, linting, and validation — documented in docs/testing.md
- [x] Validate platform matrix (OS/Node versions) and failure scenarios — documented in docs/testing.md

---

## Release & Operations

- [x] Define versioning strategy and changelog process — documented in docs/operations.md
- [x] Set rollout/rollback criteria and risk mitigation plan — documented in docs/operations.md
- [x] Add observability plan (logging, metrics, audit trail) — documented in docs/operations.md
- [x] Define feedback loop (issue templates, triage cadence) — documented in docs/operations.md

---

## Documentation

- [x] Review README.md for accuracy
- [x] Validate docs/ references against specs — documented in docs/traceability.md
- [x] Add troubleshooting section updates as workflows evolve
- [x] Document prerequisites and environment setup — documented in docs/prerequisites.md
- [x] Add spec-to-doc traceability checklist — documented in docs/traceability.md
- [x] Add examples for each workflow and expected outputs

---

## Governance & Reviews

- [x] #think: run Party Mode roundtable review of roadmap — documented in docs/reviews/party-mode-review-2026-01-31.md
- [x] runSubagent: run adversarial review of TODO/specs — documented in docs/reviews/adversarial-review-2026-01-31.md
- [ ] manage_todo_list: keep task board synced with TODO.md

---

## Next Steps

1. Execute installation and prompt tests (manual)
2. Create a regression fixture repo and run workflow validation
3. Run governance reviews (Party Mode + adversarial)
4. Re-run validation and update changelog

---

_Last updated: 2026-01-31_
