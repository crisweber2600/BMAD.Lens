---
artifact: brainstorm
phase: preplan
initiative: bmad-lens-repodiscovery
author: Mary (Analyst)
created: "2026-03-09"
---

# Brainstorm Notes — Repo Discovery

## 1. Core Workflow Sequence

The fundamental flow after `/new-service {domain}/{service}`:

```
/new-service lens-work
  ├── Scaffold TargetProjects/{domain}/{service}/
  ├── Suggest: "Clone repos into this folder, then reply 'done'"
  ├── User clones repos...
  ├── User: "done"
  └── /discover
        ├── Scan TargetProjects/{domain}/{service}/ for .git/ directories
        ├── For each repo:
        │   ├── Detect language (build files → extensions → unknown)
        │   ├── Check .bmad/ presence
        │   ├── Read remote URL from .git/config
        │   └── Run generate-project-context (yolo mode)
        ├── Write repo-inventory.yaml in governance repo
        ├── Update initiative config (language field)
        ├── Create /switch-compatible branches
        └── Display discovery report
```

## 2. Key Design Decisions to Resolve

### 2.1 When Does `/discover` Trigger?

- **Option A (chosen):** Suggested after `/new-service` — user runs manually
- **Option B (rejected):** Auto-runs after `/new-service` — too eager, user may not have cloned yet
- **Option C (future):** Also available as standalone `/discover` for ad-hoc re-scans

Recommendation: Start with Option A, support Option C as a natural extension (same command, different trigger).

### 2.2 Inventory Schema Design

Two approaches:

**Flat list (simpler):**
```yaml
repos:
  - name: bmad.lens.src
    domain: bmad
    service: lens
    path: bmad/lens/bmad.lens.src
    remote: https://github.com/crisweber2600/bmad.lens.src.git
    language: typescript
    bmad_configured: true
```

**Hierarchical (mirrors TargetProjects tree):**
```yaml
domains:
  bmad:
    services:
      lens:
        repos:
          - name: bmad.lens.src
            remote: https://github.com/crisweber2600/bmad.lens.src.git
            language: typescript
            bmad_configured: true
```

Recommendation: Flat list — simpler to parse, easier for `/onboard` to iterate, avoids nesting complexity. Domain/service are fields on each entry.

### 2.3 Branch Strategy for Discovered Repos

Options for making discovered repos navigable via `/switch`:

- **Option A:** One branch per repo in the control repo (e.g., `repo-bmad-lens-bmadlenssrc`)
- **Option B:** Track repos as metadata in the service initiative config — `/switch` reads config to know about repos without dedicated branches
- **Option C:** Register repos in `repo-inventory.yaml` only — `/switch` learns to read inventory

Recommendation: Option C is leanest. `/switch` already reads initiative configs; extending it to also check `repo-inventory.yaml` keeps branch topology clean.

### 2.4 Project Context Generation Mode

For batch discovery of N repos:

- **Yolo mode:** Run `generate-project-context` with all defaults — no user interaction per repo
- **Deferred:** Skip during discover, suggest per-repo `generate project context` as follow-up
- **Summary only:** Generate a lightweight context scan (file tree + language + build system) without full project analysis

Recommendation: Yolo mode for MVP — the user already chose batch execution by running `/discover`. If a repo is complex, they can re-run interactively later.

## 3. Edge Cases

### 3.1 Empty Service Folder
User runs `/discover` but hasn't cloned anything yet.
```
📂 No repositories found in TargetProjects/{domain}/{service}/
Clone repos into this folder and run /discover again.
```

### 3.2 Already-Discovered Repos
User runs `/discover` on a service folder with repos already in `repo-inventory.yaml`.
- Skip re-detection for known repos (match by path or remote URL)
- Only process new entries
- Report: "2 repos already in inventory, 1 new repo discovered"

### 3.3 Non-Git Directories
Folders in the service path that are NOT git repos (no `.git/`).
- Skip silently or warn: "Skipped `docs/` — not a git repository"

### 3.4 Governance Repo Itself
`TargetProjects/lens/lens-governance/` is a repo but should not be inventoried as a code repo.
- Either: exclude by convention (governance path is known from `governance-setup.yaml`)
- Or: tag it as `type: governance` in inventory (not a code repo)

### 3.5 Repos with No Remote
Locally-init'd repos without a remote configured.
- Detect: `git -C {repo} remote -v` returns empty
- Handle: Set `remote: null` in inventory, warn in report

## 4. Integration Points

### 4.1 `/new-service` Step 11 Update

Current next-step:
```
▶️ Run `/new-feature` to create a feature under this service.
```

Proposed update:
```
▶️ Clone relevant repos into `{target_projects_path}/{domain}/{service}/`.
   When done, run `/discover` to register them.
   Or run `/new-feature` to create a feature initiative.
```

### 4.2 `/onboard` Read-Write Pair

```
/discover (writes) ──→ repo-inventory.yaml ──→ /onboard (reads + clones)
```

This completes the lifecycle: one user discovers repos on their machine, inventory is committed to governance, another user runs `/onboard` on a fresh machine and gets all repos cloned automatically.

### 4.3 Constitution Activation

Once language is detected:
```
constitution lookup:
  org/ → always applies
  domain/{domain}/ → if exists, applies
  language/{language}/ → NOW ACTIVATES (was blocked by unknown)
```

## 5. Open Questions

| # | Question | Impact |
|---|----------|--------|
| 1 | Should `repo-inventory.yaml` be auto-committed or staged for user review? | Governance write policy |
| 2 | Should `/discover` also detect the repo's default branch name? | Useful for clone commands in `/onboard` |
| 3 | How to handle the governance repo appearing in service scan paths? | Edge case exclusion rule |
| 4 | Should the discovery report be saved as an artifact or only displayed? | User mentioned "both" — report file + config update |
| 5 | Schema for `repo-inventory.yaml` — should it align with existing BMAD patterns or be custom? | Interop with `/onboard` |
