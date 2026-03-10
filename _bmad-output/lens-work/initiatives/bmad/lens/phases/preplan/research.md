---
artifact: research
phase: preplan
initiative: bmad-lens-repodiscovery
author: Mary (Analyst)
created: "2026-03-09"
---

# Research Report — Repo Discovery

## 1. Current State Analysis

### 1.1 The `/new-service` Gap

The `init-initiative` workflow (covering `/new-domain`, `/new-service`, `/new-feature`) creates organizational structure but stops short of repo awareness:

| Step | `/new-domain` | `/new-service` | `/new-feature` |
|------|--------------|----------------|----------------|
| Validate names | ✅ | ✅ | ✅ |
| Create initiative config | ✅ | ✅ | ✅ |
| Scaffold TargetProjects folder | ✅ | ✅ | — |
| Create branch topology | root only | root only | root + small |
| **Detect cloned repos** | ❌ | ❌ | ❌ |
| **Update governance inventory** | ❌ | ❌ | ❌ |
| **Generate project context** | ❌ | ❌ | ❌ |
| **Create switchable branches** | ❌ | ❌ | ❌ |

After `/new-service`, the next-step prompt says:
```
▶️ Run `/new-feature` to create a feature under this service.
```

There is no mention of cloning repos or discovering what exists. The user must know to clone repos manually, and nothing processes them afterward.

### 1.2 Language Detection Specification (Existing but Unimplemented)

`lifecycle.yaml` defines a 6-step detection priority under `language_detection_priority`:

| Step | Source | Example | Status |
|------|--------|---------|--------|
| 1 | Explicit `language` field in initiative config | `language: typescript` | ✅ Active |
| 2 | `.bmad/language` marker file in repo | `.bmad/language` → `go` | ❌ Spec only |
| 3 | Build file heuristics | `package.json` → typescript | ❌ Spec only |
| 4 | File extension distribution analysis | `.ts` > `.js` → typescript | ❌ Spec only |
| 5 | GitHub primary language API | Repo metadata | ❌ Spec only (out of scope) |
| 6 | `unknown` fallback | Default | ✅ Active |

Steps 2–4 are the implementation targets for `/discover`. Step 5 (GitHub API) is out of scope — discovery is local-only. This means 100% of new initiative configs default to `language: unknown` unless the user manually sets it.

### 1.3 Supported Languages

`lifecycle.yaml` declares 10 supported languages:
`typescript`, `python`, `go`, `java`, `csharp`, `rust`, `php`, `kotlin`, `swift`, `cpp`

All have language-specific constitution support enabled via `language_constitution_support: enabled`.

### 1.4 Build File → Language Mapping (Heuristics)

Standard mappings for Step 3 detection:

| Build File | Language | Confidence |
|-----------|----------|------------|
| `package.json` | typescript (check for `tsconfig.json`) or javascript | High |
| `tsconfig.json` | typescript | High |
| `pyproject.toml` | python | High |
| `setup.py` / `setup.cfg` | python | High |
| `requirements.txt` | python | Medium |
| `go.mod` | go | High |
| `pom.xml` | java | High |
| `build.gradle` / `build.gradle.kts` | java / kotlin | High |
| `*.csproj` / `*.sln` | csharp | High |
| `Cargo.toml` | rust | High |
| `composer.json` | php | High |
| `Package.swift` | swift | High |
| `CMakeLists.txt` / `Makefile` | cpp (heuristic — could be C) | Medium |

### 1.5 TargetProjects Structure (Current Observation)

| Path | Contents | Notes |
|------|----------|-------|
| `TargetProjects/bmad/lens/bmad.lens.src/` | 1 git repo | `_bmad/` present, no root build files — falls to extension analysis |
| `TargetProjects/lens/lens-governance/` | 1 git repo | Config-only repo (YAML, MD) — will detect as `unknown` correctly |
| `TargetProjects/lenswork/` | Empty folder | Scaffolded but no repos cloned yet |

Key finding: `bmad.lens.src` has no build files at root, placing it in the file extension analysis path (step 4). This validates the need for the full detection chain rather than build-file-only heuristics.

### 1.6 Governance Repo Inventory

The governance repo (`TargetProjects/lens/lens-governance/`) is documented to contain `repo-inventory.yaml` at its root, but **this file does not yet exist**. The README references it:

```
repo-inventory.yaml  ← Canonical discovered-repo inventory
```

The `lifecycle.yaml` data zones section confirms:
```yaml
governance:
  artifacts:
    - constitutions/
    - roster/
    - policies/
    - repo-inventory.yaml
```

The `/onboard` workflow reads `repo-inventory.yaml` to bootstrap TargetProjects clones. So `/discover` is the write-side complement: it populates the inventory that `/onboard` consumes.

### 1.7 The `generate-project-context` Workflow

The `bmad-bmm-generate-project-context` prompt delegates to `_bmad/bmm/workflows/generate-project-context/workflow.md`. This workflow:
- Uses micro-file step architecture
- Discovers project structure, patterns, and conventions
- Produces `project-context.md` with AI implementation rules
- Is designed for interactive step-by-step execution

For batch `/discover` usage, this will need to run in a defaults/yolo mode to avoid per-repo interactive questioning.

### 1.8 The `/switch` Command

The `switch` utility workflow navigates between initiative branches. Currently it lists initiatives by branch pattern. For `/discover` to integrate, it needs:
- A branch per discovered repo (or per service root) so `/switch` can find them
- Branch naming that follows the existing initiative-root pattern

## 2. Adjacent Systems

### 2.1 Sensing Skill (Read-Only, Complementary)

The sensing skill scans **git branches** for initiative overlap detection. It is strictly read-only and operates on branch names, not repository contents. Repo Discovery is complementary — it reads **repository contents**, not branch names.

### 2.2 Constitution System (Downstream Consumer)

Language-specific constitutions in the governance repo activate only when a repo's language is known. `/discover` unblocks this by resolving `language: unknown`:
```
constitutions/
  org/          ← applies to all
  domain/       ← applies to domain repos
  language/     ← applies ONLY when language is resolved (e.g., typescript/)
```

### 2.3 `/onboard` Workflow (Inverse Operation)

`/onboard` reads `repo-inventory.yaml` and clones missing repos. `/discover` writes to `repo-inventory.yaml` after repos are cloned. They form a read-write pair:

```
/discover → writes repo-inventory.yaml → /onboard reads it → clones to new machines
```

## 3. Design Considerations

### 3.1 Schema for `repo-inventory.yaml`

Not yet defined. Needs to support at minimum:
```yaml
repos:
  - name: bmad.lens.src
    domain: bmad
    service: lens
    path: bmad/lens/bmad.lens.src
    remote: https://github.com/crisweber2600/bmad.lens.src.git
    language: unknown
    bmad_configured: true
    discovered_at: "2026-03-09T00:00:00Z"
```

The `/onboard` workflow expects entries it can iterate to clone. The remote URL will need to be read from each repo's `.git/config`.

### 3.2 Batch vs. Interactive Project Context Generation

`generate-project-context` is designed for interactive use. Running it for N repos during `/discover` requires either:
- **Option A:** Run in yolo/defaults mode per repo (auto-complete all steps)
- **Option B:** Skip project-context generation during discovery, suggest it as follow-up
- **Option C:** Create a lightweight batch variant that produces minimal context

Recommendation: Option A (yolo mode) for the MVP. The user already committed to batch mode by running `/discover`.

### 3.3 Trigger Placement

Per user input: `/discover` should be **suggested** after `/new-service`, not run automatically. This means:
- The `init-initiative` workflow's Step 11 (service scope next-step) needs updating from:
  ```
  ▶️ Run `/new-feature` to create a feature under this service.
  ```
  to:
  ```
  ▶️ Clone relevant repos into `{target_projects_path}/{domain}/{service}/`, then run `/discover` to register them.
  ```

### 3.4 Governance Write Permissions

`lifecycle.yaml` restricts governance writes to `[Tech Lead, Architect]` with `pr_required: true`. However, repo-inventory updates are operational (not policy changes), so the constitution may need to differentiate between inventory writes and constitution/policy writes.
