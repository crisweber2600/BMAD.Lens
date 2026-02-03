---
agentName: 'Tracey'
agentType: 'module'
agentFile: 'src/modules/lens/extensions/git-lens/agents/tracey.agent.yaml'
validationDate: '2026-02-01'
stepsCompleted:
  - v-01-load-review.md
  - v-02a-validate-metadata.md
  - v-02b-validate-persona.md
  - v-02c-validate-menu.md
  - v-02d-validate-structure.md
  - v-02e-validate-sidecar.md
  - v-03-summary.md
---

# Validation Report: Tracey

## Agent Overview

**Name:** Tracey  
**Type:** module (expert with sidecar)  
**module:** lens  
**hasSidecar:** true  
**File:** src/modules/lens/extensions/git-lens/agents/tracey.agent.yaml

---

## Validation Findings

### Metadata Validation

**Status:** ⚠️ WARNING

**Checks:**
- [x] id: present
- [x] name: clear display name
- [x] title: concise function description
- [x] icon: appropriate emoji/symbol
- [x] module: correct format (custom module code)
- [x] hasSidecar: matches actual usage

**Detailed Findings:**

*PASSING:*
- `name: Tracey` and `title: State & Diagnostics Specialist` are clear.
- `icon: 🧭` is valid.
- `module: lens` is a valid custom module code.
- `hasSidecar: true` correctly indicates expert behavior.

*WARNINGS:*
- `id` format does not follow `_bmad/agents/{agent-name}/{agent-name}.md` convention. Current: `_bmad/lens/agents/tracey.agent.yaml`.
- `title` does not match filename (`tracey.agent.yaml`) per standard filename derivation from title.

*FAILURES:*
- None.

---

### Persona Validation

**Status:** ⚠️ WARNING

**Checks:**
- [x] role: specific, not generic
- [x] identity: defines who agent is
- [x] communication_style: speech patterns only (mostly)
- [ ] communication_style includes memory reference patterns
- [x] principles: present and actionable

**Detailed Findings:**

*PASSING:*
- Role and identity are aligned and specific to diagnostics.
- Principles are actionable and consistent with auditability focus.

*WARNINGS:*
- Communication style does not include memory reference patterns (required for expert agents).
- First principle does not explicitly activate expert knowledge per principles-crafting guidance.

*FAILURES:*
- None.

---

### Menu Validation

**Status:** ⚠️ WARNING

**Checks:**
- [x] Menu exists
- [x] Trigger format is consistent
- [ ] Reserved codes not used
- [x] Descriptions follow [XX] format

**Detailed Findings:**

*PASSING:*
- Menu entries map to appropriate diagnostic workflows.

*WARNINGS:*
- Reserved codes `MH`, `CH`, and `DA` are declared in YAML. These are compiler-injected and should not be defined in source YAML.
- `exec` paths reference `src/modules/...` rather than `{project-root}/_bmad/{module}/...` (may be acceptable for extension modules, but inconsistent with standard pattern).

*FAILURES:*
- None.

---

### Structure Validation

**Status:** ✅ PASS

**Agent Type:** module (expert)

**Checks:**
- [x] Valid YAML syntax
- [x] Required sections present
- [x] Field types correct
- [x] Consistent indentation

**Detailed Findings:**

*PASSING:*
- YAML parses cleanly.
- Metadata, persona, critical_actions, and menu sections are present.
- Indentation and structure are consistent.

*WARNINGS:*
- None.

*FAILURES:*
- None.

---

### Sidecar Validation

**Status:** ❌ FAIL

**Agent Type:** module with sidecar

**Checks:**
- [ ] metadata.sidecar-folder present (Expert only)
- [ ] sidecar-path format correct
- [ ] Sidecar files exist at specified path
- [ ] All referenced files present

**Detailed Findings:**

*PASSING:*
- `critical_actions` includes a sidecar access boundary line.

*WARNINGS:*
- `critical_actions` does not load `{project-root}/_bmad/_memory/{sidecar-folder}/memories.md` (required for expert agents).

*FAILURES:*
- Sidecar folder `{project-root}/_bmad/_memory/tracey-sidecar/` does not exist in repo.
- `critical_actions` references `tracey-state.md`, but no sidecar files are present.

---

## Overall Status

**Status:** ❌ FAIL

**Primary Issues:**
- Missing sidecar folder and required memory files.
- Missing expert-required memory load in `critical_actions`.

**Recommended Fixes (Required):**
1. Create `_bmad/_memory/tracey-sidecar/` with `memories.md` and `instructions.md`.
2. Update `critical_actions` to load `memories.md` in addition to instructions.
3. Consider aligning `id` format and filename/title convention.
4. Remove reserved menu codes from YAML.
5. Add memory reference pattern to `communication_style`.
