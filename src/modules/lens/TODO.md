# TODO: LENS: Layered Enterprise Navigation System

Development roadmap for lens module.

---

## Agents to Build

- [ ] Navigator (Architectural Context Navigator)
  - Use: `bmad:bmb:agents:agent-builder`
  - Spec: `agents/navigator.spec.md`

---

## Workflows to Build

- [ ] lens-detect
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/lens-detect/lens-detect.spec.md`
- [ ] lens-switch
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/lens-switch/lens-switch.spec.md`
- [ ] context-load
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/context-load/context-load.spec.md`
- [ ] lens-restore
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/lens-restore/lens-restore.spec.md`
- [ ] lens-configure
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/lens-configure/lens-configure.spec.md`
- [ ] workflow-guide
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/workflow-guide/workflow-guide.spec.md`
- [ ] domain-map
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/domain-map/domain-map.spec.md`
- [ ] impact-analysis
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/impact-analysis/impact-analysis.spec.md`
- [ ] new-service
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/new-service/new-service.spec.md`
- [ ] new-microservice
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/new-microservice/new-microservice.spec.md`
- [ ] new-feature
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/new-feature/new-feature.spec.md`
- [ ] lens-sync
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/lens-sync/lens-sync.spec.md`
- [ ] service-registry
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/service-registry/service-registry.spec.md`
- [ ] onboarding
  - Use: `bmad:bmb:workflows:workflow` or `/workflow`
  - Spec: `workflows/onboarding/onboarding.spec.md`

---

## Installation Testing

- [ ] Test installation with `bmad install lens`
- [ ] Verify module.yaml prompts work correctly
- [ ] Test installer.js (if present)
- [ ] Test IDE-specific handlers (if present)

---

## Documentation

- [ ] Complete README.md with usage examples
- [ ] Enhance docs/ folder with more guides
- [ ] Add troubleshooting section
- [ ] Document configuration options

---

## Next Steps

1. Build agents using create-agent workflow
2. Build workflows using create-workflow workflow
3. Test installation and functionality
4. Iterate based on testing

---

_Last updated: 2026-01-30_
