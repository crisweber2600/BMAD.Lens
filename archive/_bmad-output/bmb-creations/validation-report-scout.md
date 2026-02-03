---
agentName: 'Scout'
agentType: 'module'
agentFile: '/workspaces/BMAD.Lens/_bmad-output/bmb-creations/scout/scout.agent.yaml'
validationDate: '2026-01-31'
stepsCompleted:
  - v-01-load-review.md
  - v-02a-validate-metadata.md
  - v-02b-validate-persona.md
  - v-02c-validate-menu.md
  - v-02d-validate-structure.md
  - v-02e-validate-sidecar.md
  - v-03-summary.md
---

# Validation Report: Scout

## Agent Overview

**Name:** Scout
**Type:** module
**module:** lens
**hasSidecar:** true
**File:** /workspaces/BMAD.Lens/_bmad-output/bmb-creations/scout/scout.agent.yaml

---

## Validation Findings

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
- id present and formatted as `_bmad/agents/scout/scout.md`
- name present and clear (`Scout`)
- title present and descriptive (`Discovery Specialist`)
- icon present and representative (🔍)
- module format valid (`lens`)
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
- Role is clear and aligned with discovery responsibilities.
- Identity defines character without mixing role or principles.
- Communication style focuses on speech patterns (investigative tone).
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
- Commands align to Scout capabilities.
- Exec handlers set to `todo` until workflows are implemented (acceptable placeholder).

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
- Module code format is valid.

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
- Sidecar folder exists at `{project-root}/_bmad/_memory/scout-sidecar/`.
- `scout-discoveries.md` and `instructions.md` are present.
- critical_actions use correct `{project-root}/_bmad/_memory/scout-sidecar/` format.

*WARNINGS:*
- None

*FAILURES:*
- None
