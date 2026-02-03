---
agentName: 'Casey'
agentType: 'module'
agentFile: 'src/modules/lens/extensions/git-lens/agents/casey.agent.yaml'
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

# Validation Report: Casey

## Agent Overview

**Name:** Casey  
**Type:** module  
**module:** lens  
**hasSidecar:** false  
**File:** src/modules/lens/extensions/git-lens/agents/casey.agent.yaml

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
- `name: Casey` is a clear persona name.
- `title: Git Branch Orchestrator` is descriptive.
- `icon: 🏗️` is valid.
- `module: lens` is a valid custom module code.
- `hasSidecar: false` matches actual usage.

*WARNINGS:*
- `id` format does not follow `_bmad/agents/{agent-name}/{agent-name}.md` convention. Current: `_bmad/lens/agents/casey.agent.yaml`.
- `title` does not match filename (`casey.agent.yaml`) per standard filename derivation from title.

*FAILURES:*
- None.

---

### Persona Validation

**Status:** ⚠️ WARNING

**Checks:**
- [x] role: specific, not generic
- [x] identity: defines who agent is
- [x] communication_style: speech patterns only (mostly)
- [x] principles: present and actionable

**Detailed Findings:**

*PASSING:*
- Role clearly defines Casey's operational scope (git orchestration).
- Identity aligns with release-engineer persona.
- Principles are actionable and aligned to gating discipline.

*WARNINGS:*
- Communication style includes behavior phrasing: “Outputs actionable next steps,” which is more behavior than speech pattern.
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
- Menu is minimal, consistent with auto-triggered agent role.

*WARNINGS:*
- Reserved codes `MH` and `DA` are declared in YAML. These are compiler-injected and should not be defined in source YAML.
- No operational command entries (may be intentional for auto-triggered agent).

*FAILURES:*
- None.

---

### Structure Validation

**Status:** ✅ PASS

**Agent Type:** module

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

**Status:** N/A

**Agent Type:** module (no sidecar)

**Checks:**
- [ ] metadata.sidecar-folder present (Expert only)
- [ ] sidecar-path format correct
- [ ] Sidecar files exist

**Detailed Findings:**

*N/A:* Agent does not declare `hasSidecar: true`.

---

## Overall Status

**Status:** ⚠️ WARNING

**Primary Issues:**
- Metadata `id` format and title/filename mismatch.
- Reserved menu codes included in YAML (should be compiler-injected).
- Minor persona formatting guidance (communication_style & expert-first principle).

**Recommended Fixes (Non-blocking):**
1. Update `id` to compiled path convention.
2. Align filename with title OR adjust title to match filename rule.
3. Remove reserved menu items (MH/DA) from YAML.
4. Refine communication_style and first principle to match standards.
