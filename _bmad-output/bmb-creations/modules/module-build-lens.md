# Module Build Tracking: Lens

**Module Code:** lens
**Brief:** `_bmad-output/bmb-creations/modules/module-brief-lens.md`
**Source:** `src/modules/lens/`
**Created:** 2026-02-17
**Status:** Implementation Complete — Ready for Integration Testing

---

## Build Summary

| Category | Count | Status |
|----------|-------|--------|
| module.yaml | 1 | ✅ Done |
| Installer | 1 | ✅ Done |
| Agent Spec | 1 | ✅ Done |
| Agent YAML | 1 | ✅ Done (572 lines) |
| Skills | 5 | ✅ Done |
| Workflow Specs | 22 | ✅ Done |
| Workflow Implementations | 22 | ✅ Done |
| Includes | 3 | ✅ Done |
| Prompts | 13 | ✅ Done |
| Docs | 9 | ✅ Done |
| Templates | 2 | ✅ Done |
| Test Spec | 1 | ✅ Done |
| Scripts | 1 | ✅ Done |
| README | 1 | ✅ Done |
| TODO | 1 | ✅ Done |
| **Total** | **84** | **✅ All Implementation Complete** |

---

## File Manifest

### Core
- [x] `module.yaml` — Module manifest with full config
- [x] `README.md` — Module documentation
- [x] `TODO.md` — Implementation tracking
- [x] `_module-installer/installer.js` — Install script

### Agent
- [x] `agents/lens.spec.md` — @lens agent specification
- [x] `agents/lens.agent.yaml` — @lens unified agent (572 lines)

### Skills (5)
- [x] `skills/git-orchestration.md`
- [x] `skills/state-management.md`
- [x] `skills/discovery.md`
- [x] `skills/constitution.md`
- [x] `skills/checklist.md`

### Phase Workflows (6) — Specs + Implementations
- [x] `workflows/phase/pre-plan/workflow.spec.md` + `workflow.md` (304 lines)
- [x] `workflows/phase/plan/workflow.spec.md` + `workflow.md` (219 lines)
- [x] `workflows/phase/tech-plan/workflow.spec.md` + `workflow.md` (166 lines)
- [x] `workflows/phase/story-gen/workflow.spec.md` + `workflow.md` (166 lines)
- [x] `workflows/phase/review/workflow.spec.md` + `workflow.md` (255 lines)
- [x] `workflows/phase/dev/workflow.spec.md` + `workflow.md` (204 lines)

### Initiative Workflows (2) — Specs + Implementations
- [x] `workflows/initiative/init-initiative/workflow.spec.md` + `workflow.md` (249 lines)
- [x] `workflows/initiative/switch-context/workflow.spec.md` + `workflow.md` (138 lines)

### Utility Workflows (6) — Specs + Implementations
- [x] `workflows/utility/status/workflow.spec.md` + `workflow.md` (93 lines)
- [x] `workflows/utility/sync-state/workflow.spec.md` + `workflow.md` (128 lines)
- [x] `workflows/utility/fix-state/workflow.spec.md` + `workflow.md` (141 lines)
- [x] `workflows/utility/override-state/workflow.spec.md` + `workflow.md` (134 lines)
- [x] `workflows/utility/resume/workflow.spec.md` + `workflow.md` (120 lines)
- [x] `workflows/utility/archive/workflow.spec.md` + `workflow.md` (126 lines)

### Discovery Workflows (3) — Specs + Implementations
- [x] `workflows/discovery/onboard/workflow.spec.md` + `workflow.md` (171 lines)
- [x] `workflows/discovery/discover/workflow.spec.md` + `workflow.md` (113 lines)
- [x] `workflows/discovery/bootstrap/workflow.spec.md` + `workflow.md` (168 lines)

### Background Workflows (5) — Specs + Implementations
- [x] `workflows/background/state-sync/workflow.spec.md` + `workflow.md` (108 lines)
- [x] `workflows/background/event-log/workflow.spec.md` + `workflow.md` (135 lines)
- [x] `workflows/background/branch-validate/workflow.spec.md` + `workflow.md` (90 lines)
- [x] `workflows/background/constitution-check/workflow.spec.md` + `workflow.md` (130 lines)
- [x] `workflows/background/checklist-update/workflow.spec.md` + `workflow.md` (177 lines)

### Includes (3)
- [x] `workflows/includes/size-topology.md`
- [x] `workflows/includes/pr-links.md`
- [x] `workflows/includes/artifact-validator.md`

### Prompts (13)
- [x] `prompts/lens.pre-plan.prompt.md`
- [x] `prompts/lens.plan.prompt.md`
- [x] `prompts/lens.tech-plan.prompt.md`
- [x] `prompts/lens.story-gen.prompt.md`
- [x] `prompts/lens.review.prompt.md`
- [x] `prompts/lens.dev.prompt.md`
- [x] `prompts/lens.new.prompt.md`
- [x] `prompts/lens.switch.prompt.md`
- [x] `prompts/lens.status.prompt.md`
- [x] `prompts/lens.sync.prompt.md`
- [x] `prompts/lens.fix.prompt.md`
- [x] `prompts/lens.onboard.prompt.md`
- [x] `prompts/lens.lens.prompt.md`

### Docs (9)
- [x] `docs/getting-started.md`
- [x] `docs/architecture.md`
- [x] `docs/configuration.md`
- [x] `docs/branch-topology.md`
- [x] `docs/constitution-guide.md`
- [x] `docs/migration-from-lens-work.md`
- [x] `docs/copilot-instructions.md`
- [x] `docs/troubleshooting.md`
- [x] `docs/api-reference.md`

### Templates (2)
- [x] `templates/state-template.yaml`
- [x] `templates/initiative-template.yaml`

### Tests (1)
- [x] `tests/lens-tests.spec.md`

### Scripts (1)
- [x] `scripts/validate.js`

---

## Next Phase: Integration Testing

All implementation is complete. See `TODO.md` for remaining work:
1. Test cross-module routing (BMM, CIS, TEA)
2. Run full lifecycle end-to-end (onboard → new → pre-plan → ... → archive)
3. Test recovery workflows and state management
4. Run dogfood deployment via `scripts/dogfood.sh`

---

_Build tracking created: 2026-02-17 | Implementation completed: 2026-02-17_
