# TODO: LENS: Layered Enterprise Navigation System

Development roadmap for lens module.

---

## Agents to Build

- [x] Navigator (Architectural Context Navigator)
  - Use: `bmad:bmb:agents:agent-builder`
  - Spec: `agents/navigator.spec.md`

---

## Workflows to Build

- [x] lens-detect
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/lens-detect/lens-detect.spec.md`
- [x] lens-switch
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/lens-switch/lens-switch.spec.md`
- [x] context-load
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/context-load/context-load.spec.md`
- [x] lens-restore
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/lens-restore/lens-restore.spec.md`
- [x] lens-configure
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/lens-configure/lens-configure.spec.md`
- [x] workflow-guide
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/workflow-guide/workflow-guide.spec.md`
- [x] domain-map
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/domain-map/domain-map.spec.md`
- [x] impact-analysis
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/impact-analysis/impact-analysis.spec.md`
- [x] new-service
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/new-service/new-service.spec.md`
- [x] new-microservice
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/new-microservice/new-microservice.spec.md`
- [x] new-feature
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/new-feature/new-feature.spec.md`
- [x] lens-sync
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/lens-sync/lens-sync.spec.md`
- [x] service-registry
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/service-registry/service-registry.spec.md`
- [x] onboarding
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/onboarding/onboarding.spec.md`

---

## Prompts & Tooling

- [x] Audit prompts/ for coverage of all workflows and agent commands
- [x] Add #think guidance to prompts where deep reasoning is required
- [x] Add `runSubagent` usage guidance for multi-agent reviews (Party Mode, adversarial)
- [x] Add `manage_todo_list` usage guidance for workflow task tracking outputs

---

## Configuration & State

- [x] Validate `module-config.yaml` defaults and document override rules
- [x] Define `.lens/lens-session.yaml` schema and add an example in docs/
- [x] Document backward-compat/migration notes for session store changes

---

## Quality & Review

- [x] Run Party Mode multi-agent review on specs, prompts, and docs
- [x] Run adversarial review on README/docs/specs and address findings
- [x] Add a spec-completeness checklist (inputs/outputs/edge cases)

---

## Installation Testing

- [x] Test installation with `bmad install lens` (tested 2026-01-31)
- [x] Verify module.yaml prompts work correctly
- [x] Test installer.js — fixed: removed `fs-extra`/`chalk` dependencies, now uses native `node:fs/promises`
- [x] Test IDE-specific handlers (if present) (none found)

---

## Documentation

- [x] Complete README.md with usage examples
- [x] Enhance docs/ folder with more guides
- [x] Add troubleshooting section
- [x] Document configuration options

---

## Next Steps

1. Build agents using create-agent workflow
2. Build workflows using create-workflow workflow
3. Test installation and functionality
4. Iterate based on testing

---

_Last updated: 2026-01-31_
