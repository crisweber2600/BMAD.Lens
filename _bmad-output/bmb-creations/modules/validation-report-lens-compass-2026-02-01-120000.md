---
validationDate: 2026-02-01T12:00:00Z
targetType: Full
moduleCode: lens-compass
targetPath: src/modules/lens/extensions/lens-compass
status: COMPLETE
---

# Validation Report: lens-compass

## File Structure Validation

**Status:** PASS

**Checks:**
- [x] module.yaml exists
- [x] README.md exists
- [x] TODO.md exists
- [x] docs/ folder exists
- [x] agents/ folder exists
- [x] workflows/ folder exists
- [x] _module-installer/ folder exists
- [x] _module-installer/installer.js exists
- [x] Agent specs present (1 spec)
- [x] Workflow specs present (9 specs)
- [x] Extension module code matches base module (lens)
- [x] Extension folder name is unique (lens-compass)

**Issues Found:**
- None

**Scope Notes:**
- File content/schema checks are covered in later validation steps (module.yaml, specs, docs, installer)

## module.yaml Validation

**Status:** PASS

**Required Fields:** PASS
- code: lens (matches base module)
- name: present
- header: present
- subheader: present
- default_selected: boolean (false)

**Custom Variables:** 5 variables
- personal_profiles_folder (path template uses `{output_folder}`)
- roster_file (path template uses `{project-root}`)
- use_git_identity (boolean default: true)
- suggestion_mode (single-select: smart/always/quiet; default: smart)
- preference_learning (boolean default: true)

**Template Validation:** PASS
- `{output_folder}` and `{project-root}` are valid core templates
- `{value}` used correctly in results

**Naming Conventions:** PASS
- Variables use snake_case, consistent with existing module patterns

**Issues Found:**
- None

**Notes:**
- module.yaml does not include an explicit schema/version field (not required by current conventions)

## Agent Specs Validation

**Status:** WARNINGS

**Agent Summary:**
- Total Agents: 1
- Built Agents: 0
- Spec Agents: 1 (agents/navigator.spec.md)

**Spec Agents:**
- **Navigator**: PASS — Placeholder awaiting agent-builder
	- Metadata present (id, name, title, icon, module)
	- Role, identity, communication style present
	- Menu triggers documented (9 commands)
	- hasSidecar documented with rationale
	- Template structure matches spec template

**Issues Found:**
- No built agents yet (spec-only stage)

**Recommendations:**
- Use `bmad:bmb:agents:agent-builder` to create Navigator
- Re-run validation after agent build for full compliance

## Workflow Specs Validation

**Status:** WARNINGS

**Validation Scope:**
- Scanned: src/modules/lens/extensions/lens-compass/workflows/**/{*.spec.md,workflow.md}

**Workflow Summary:**
- Total Workflows: 9
- Built Workflows: 0 (built = workflow.md + steps/ folder)
- Spec Workflows: 9
	- onboarding (workflows/onboarding/onboarding.spec.md)
	- next-step-router (workflows/next-step-router/next-step-router.spec.md)
	- roster-tracker (workflows/roster-tracker/roster-tracker.spec.md)
	- profile-manager (workflows/profile-manager/profile-manager.spec.md)
	- roster-query (workflows/roster-query/roster-query.spec.md)
	- preference-learner (workflows/preference-learner/preference-learner.spec.md)
	- context-analyzer (workflows/context-analyzer/context-analyzer.spec.md)
	- data-cleanup (workflows/data-cleanup/data-cleanup.spec.md)
	- roster-export (workflows/roster-export/roster-export.spec.md)

**Spec Compliance Checks:**
- Goal, description, workflow type present
- Step outline present
- Inputs/outputs documented
- Primary agent identified

**Issues Found:**
- No built workflows yet (spec-only stage; expected before workflow-builder runs)

**Recommendations:**
- Use `bmad:bmb:workflows:workflow` or `/workflow` to build each workflow
- Re-run validation after workflows are built

## Documentation Validation

**Status:** PASS

**Root Documentation:**
- **README.md:** present — overview, installation, components, structure, docs link
- **TODO.md:** present — agent/workflow checklists, testing, next steps

**User Documentation (docs/):**
- **docs/ folder:** present
- **Documentation files:** 4 files found

**Docs Contents:**
- docs/getting-started.md
- docs/agents.md
- docs/workflows.md
- docs/examples.md

**Alignment Checks:**
- README lists 1 agent and 9 workflows (matches spec count)
- TODO references all 9 workflow specs and 1 agent spec

**Issues Found:**
- None

**Notes:**
- configuration.md and troubleshooting.md are not present (optional at this stage)

## Installation Readiness

**Status:** WARNINGS

**Installer:** present — _module-installer/installer.js
**Install Variables:** 5 variables
**Ready to Install:** Yes (base requirements met)

**Checks:**
- install(options) signature present
- Handles projectRoot/config/installedIDEs/logger
- Try/catch with error logging
- Creates personal profiles folder and roster file
- Idempotent roster creation (write-if-missing)
- Path resolution anchored to projectRoot for templated paths

**Issues Found:**
- No platformCodes validation for IDE identifiers
- No platform-specific handlers present (optional)

**Notes:**
- Installer allows absolute paths for config values (explicit user choice)
- Roster file is not overwritten if already present

**Recommendations:**
- If IDE-specific handlers are needed later, add platform-specific files and platform code validation

---

## Overall Summary

**Status:** WARNINGS

**Breakdown:**
- File Structure: PASS
- module.yaml: PASS
- Agent Specs: WARNINGS (0 built, 1 spec)
- Workflow Specs: WARNINGS (0 built, 9 specs)
- Documentation: PASS
- Installation Readiness: WARNINGS

---

## Component Status

### Agents
- **Built Agents:** 0
- **Spec Agents:** 1 — Navigator

### Workflows
- **Built Workflows:** 0
- **Spec Workflows:** 9 — onboarding, next-step-router, roster-tracker, profile-manager, roster-query, preference-learner, context-analyzer, data-cleanup, roster-export

---

## Recommendations

### Priority 1 - Critical (must fix)
- None

### Priority 2 - High (should fix)
- Build the Navigator agent using agent-builder
- Build the 9 workflows using workflow-builder

### Priority 3 - Medium (nice to have)
- Add platformCodes validation if IDE-specific handlers are introduced
- Consider adding configuration.md and troubleshooting.md to docs

---

## Sub-Process Validation

No built agents or workflows found for deep validation.

---

## Next Steps

1. Build agent and workflow implementations from specs
2. Re-run validation after implementations exist
3. Optionally add IDE-specific handlers and extended docs

---

**Validation Completed:** 2026-02-01T12:00:00Z

