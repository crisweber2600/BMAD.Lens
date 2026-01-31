---
agentName: 'Bridge'
agentType: 'module'
agentFile: '/workspaces/BMAD.Lens/_bmad-output/bmb-creations/bridge/bridge.agent.yaml'
validationDate: '2026-01-31'
stepsCompleted:
  - v-01-load-review.md
---

# Validation Report: Bridge

## Agent Overview

**Name:** Bridge
**Type:** module
**module:** lens
**hasSidecar:** true
**File:** /workspaces/BMAD.Lens/_bmad-output/bmb-creations/bridge/bridge.agent.yaml

---

## Validation Findings

*This section will be populated by validation steps*

### Metadata Validation

**Status:** ✅ PASS

**Checks:**
- [x] id: kebab-case, no spaces, unique
- [x] name: clear display name
- [x] title: concise function description
- [x] icon: appropriate emoji/symbol
- [x] module: correct format (code or stand-alone)
- [x] hasSidecar: matches actual usage

**Detailed Findings:**

*PASSING:*
- id present and formatted as `_bmad/agents/bridge/bridge.md`
- name present and clear (`Bridge`)
- title present and descriptive (`Lens Synchronizer`)
- icon present and representative (🧱)
- hasSidecar is boolean and matches usage (true)

*WARNINGS:*
- None

*FAILURES:*
- None

### Persona Validation

**Status:** ✅ PASS

**Checks:**
- [x] role: specific, not generic
- [x] identity: defines who agent is
- [x] communication_style: speech patterns only
- [x] principles: first principle activates expert knowledge

**Detailed Findings:**

*PASSING:*
- Role is clear and aligned with sync/bootstrapping responsibilities.
- Identity defines character without mixing role or principles.
- Communication style focuses on speech patterns (construction metaphors).
- Principles are specific, actionable, and first principle activates expert knowledge.
- Persona aligns with menu items and agent purpose.

*WARNINGS:*
- None

*FAILURES:*
- None

### Menu Validation

**Status:** ✅ PASS

**Checks:**
- [x] A/P/C convention followed
- [x] Command names clear and descriptive
- [x] Command descriptions specific and actionable
- [x] Menu handling logic properly specified
- [x] Agent type appropriate menu links verified

**Detailed Findings:**

*PASSING:*
- Menu section exists with 3 commands.
- Triggers follow `XX or fuzzy match on command` pattern.
- Descriptions use `[XX]` format and are clear.
- Commands align to Bridge capabilities.

*WARNINGS:*
- None

*FAILURES:*
- None

### Structure Validation

**Status:** ✅ PASS

**Agent Type:** module

**Checks:**
- [x] Valid YAML syntax
- [x] Required fields present (metadata, persona, critical_actions, menu)
- [x] Field types correct (arrays, strings)
- [x] Consistent 2-space indentation
- [x] Agent type appropriate structure

**Detailed Findings:**

*PASSING:*
- YAML parses cleanly with required sections.
- critical_actions present with three entries.
- Menu items are well-formed.

*WARNINGS:*
- None

*FAILURES:*
- None

### Sidecar Validation

**Status:** ✅ PASS

**Agent Type:** module with sidecar

**Checks:**
- [x] sidecar-path format correct
- [x] Sidecar files exist at specified path
- [x] All referenced files present

**Detailed Findings:**

*PASSING (for Expert agents):*
- Sidecar folder exists at `{project-root}/_bmad/_memory/bridge-sidecar/` with `bridge-state.md` and `instructions.md`.
- critical_actions use correct `{project-root}/_bmad/_memory/bridge-sidecar/` format.

*WARNINGS:*
- None

*FAILURES:*
- None
