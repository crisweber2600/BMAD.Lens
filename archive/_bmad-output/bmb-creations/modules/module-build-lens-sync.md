---
moduleCode: lens
extensionCode: lens-sync
moduleName: "LENS Sync & Discovery"
moduleType: Extension
briefFile: "/workspaces/BMAD.Lens/lens-sync.md"
stepsCompleted: ['step-01-load-brief','step-02-structure','step-03-config','step-04-installer','step-05-agents','step-06-workflows','step-07-docs','step-08-complete']
created: 2026-01-31T05:11:52Z
completed: 2026-01-31T05:32:42Z
status: COMPLETE
targetLocation: "src/modules/lens/extensions/lens-sync/"
---

agentSpecs:
	- "src/modules/lens/extensions/lens-sync/agents/bridge.spec.md"
	- "src/modules/lens/extensions/lens-sync/agents/scout.spec.md"
	- "src/modules/lens/extensions/lens-sync/agents/link.spec.md"

workflowSpecs:
	- "src/modules/lens/extensions/lens-sync/workflows/bootstrap/bootstrap.spec.md"
	- "src/modules/lens/extensions/lens-sync/workflows/sync-status/sync-status.spec.md"
	- "src/modules/lens/extensions/lens-sync/workflows/reconcile/reconcile.spec.md"
	- "src/modules/lens/extensions/lens-sync/workflows/discover/discover.spec.md"
	- "src/modules/lens/extensions/lens-sync/workflows/analyze-codebase/analyze-codebase.spec.md"
	- "src/modules/lens/extensions/lens-sync/workflows/generate-docs/generate-docs.spec.md"
	- "src/modules/lens/extensions/lens-sync/workflows/update-lens/update-lens.spec.md"
	- "src/modules/lens/extensions/lens-sync/workflows/validate-schema/validate-schema.spec.md"
	- "src/modules/lens/extensions/lens-sync/workflows/rollback/rollback.spec.md"

