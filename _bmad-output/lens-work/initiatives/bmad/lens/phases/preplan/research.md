---
artifact: research
phase: preplan
initiative: bmad-lens-repodiscovery
author: Mary (Analyst)
created: "2026-03-09"
---

# Research Report — Repo Discovery

## 1. Current State Analysis

### 1.1 Language Detection Specification (Existing)

`lifecycle.yaml` defines a 6-step detection priority:

| Step | Source | Example |
|------|--------|---------|
| 1 | Explicit `language` field in initiative config | `language: typescript` |
| 2 | `.bmad/language` marker file in repo | `.bmad/language` → `go` |
| 3 | Build file heuristics | `package.json` → typescript, `pyproject.toml` → python |
| 4 | File extension distribution analysis | `.ts` files > `.js` → typescript |
| 5 | GitHub primary language API | Repo metadata |
| 6 | `unknown` fallback | Default |

**Finding:** Steps 1 and 6 are the only steps currently active at runtime. Steps 2–5 are spec without implementation. This means 100% of new initiative configs default to `language: unknown` unless the user manually sets it.

### 1.2 Supported Languages

`lifecycle.yaml` declares 11 supported languages:
`typescript`, `python`, `go`, `java`, `csharp`, `rust`, `php`, `kotlin`, `swift`, `cpp`

All have language-specific constitution support via `language_constitution_support: enabled`.

### 1.3 TargetProjects Structure (Current Observation)

| Path | Detected Repos | Notes |
|------|---------------|-------|
| `TargetProjects/bmad/lens/bmad.lens.src` | 1 git repo | No build files at root; `_bmad/` present |
| `TargetProjects/lens/lens-governance` | 1 git repo | Config-only repo (no code language) |

**Key finding:** `bmad.lens.src` has no build files at depth 1–2, placing it in the "file extension analysis" path (step 4) or falling through to `unknown`. This is a realistic representation of config-only and documentation-heavy repos that the detection logic must handle gracefully.

### 1.4 bmadconfig.yaml Path Config

`target_projects_path` is defined in `bmad.lens.release/_bmad/lens-work/bmadconfig.yaml` as `../TargetProjects` (relative to the release module). Discovery must resolve this against the control repo working directory.

### 1.5 Existing Sensing Skill (Adjacent Capability)

The `sensing` skill scans **git branches** for initiative overlap detection. It is strictly read-only and operates on branch names, not repository contents. Repo Discovery is complementary — it reads **repository contents**, not branch names.

| Dimension | Sensing Skill | Repo Discovery |
|-----------|--------------|----------------|
| Data source | Git branch names | Repo filesystem (TargetProjects) |
| Purpose | Cross-initiative conflict detection | Language + BMAD config detection |
| Trigger | Lifecycle gates | `/discover` command + `/new-feature` |
| Write ops | None | Updates `language` in initiative config |

## 2. Gap Analysis

| Gap | Impact | Priority |
|-----|--------|----------|
| Language detection steps 2–5 are unimplemented | High — language constitutions inactive | P1 |
| No `/discover` command exists | High — no user-facing trigger | P1 |
| No automatic discovery at `/new-feature` creation | Medium — `language: unknown` persists indefinitely | P1 |
| No TargetProjects health report | Low — manual audit currently needed | P2 |
| Multi-language monorepo handling undefined | Low — no policy for detection tie-breaking | P2 |

## 3. Implementation Pathways

### Option A: Inline Detection in `@lens` Agent (Recommended)

Implement detection directly as a new `repo-discovery` operation within the sensing skill (or as a sibling skill). Detection logic runs locally via agent tool calls (`find`, `ls`, file reads). No external dependencies.

**Pros:** No new infrastructure, aligns with A5 (control repo as operational workspace), uses existing `git-orchestration` file-write patterns for the config update.
**Cons:** File extension analysis (step 4) requires counting file extensions — agent must issue a `find` call per repo.

### Option B: Script-based Detection

Add a `scripts/discover-repos.sh` to the lens-work module that runs the detection algorithm and emits JSON. `@lens` calls the script and parses output.

**Pros:** Testable independently, reproducible, fast.
**Cons:** Adds a script dependency; shell scripts are platform-sensitive (Windows/Unix).

### Option C: GitHub API Primary Language (Step 5 Only)

Call GitHub API to get the primary language for each repo's remote URL.

**Pros:** High accuracy for public/private GitHub repos.
**Cons:** Requires auth at discovery time; not always available (forks, local-only repos, network required). Cannot be the only strategy.

**Recommendation:** Option A for steps 2–4 (local filesystem), Option C as optional enhancement if remote is available. Option B deferred to `tech-change` track if script extraction is needed.

## 4. Build File to Language Mapping

Based on `lifecycle.yaml` supported languages:

| Build File | Language |
|-----------|---------|
| `package.json` | typescript |
| `pyproject.toml`, `setup.py`, `setup.cfg` | python |
| `go.mod` | go |
| `pom.xml`, `build.gradle`, `build.gradle.kts` | java / kotlin |
| `*.csproj`, `*.sln`, `global.json` | csharp |
| `Cargo.toml` | rust |
| `composer.json` | php |
| `build.gradle` (Kotlin DSL) | kotlin |
| `Package.swift` | swift |
| `CMakeLists.txt`, `Makefile` | cpp |

**Ambiguity cases:**
- `build.gradle` → could be Java or Kotlin — check for `.kt` files to disambiguate
- `package.json` → could be JavaScript; use `.ts` file presence to confirm TypeScript

## 5. Design Decisions Needed (for BusinessPlan/TechPlan)

1. **When to auto-trigger discovery?** Options: `/new-feature` creation, first phase start, or on-demand only
2. **Monorepo tie-breaking rule:** Highest file count wins? Or prompt user?
3. **Update policy:** Should discovery overwrite a manually-set `language` field? (Recommendation: no — skip step 3–5 if step 1 is already set)
4. **`.bmad/language` marker format:** Is this a plain text file with one language token, or a YAML file?

## 6. Competitive / Analogous Reference

- **GitHub Linguist** — open-source library behind GitHub's language detection; uses file extension and heuristic scoring. Confirms the build-file-first + extension-distribution approach is industry-standard.
- **Trunk** — repo health checks; similar TargetProjects scanning pattern.
- **mise** — language version management via `.tool-versions`; analogous to the `.bmad/language` marker concept.
