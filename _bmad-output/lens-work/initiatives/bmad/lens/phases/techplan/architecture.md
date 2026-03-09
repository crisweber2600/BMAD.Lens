---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments:
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/preplan/product-brief.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/businessplan/prd.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/businessplan/ux-design-specification.md
workflowType: 'architecture'
project_name: 'Repo Discovery'
user_name: 'CrisWeber'
date: '2026-03-09'
initiative: bmad-lens-repodiscovery
phase: techplan
author: Winston (Architect)
---

# Architecture Decision Document — Repo Discovery (`/discover`)

**Author:** CrisWeber
**Date:** 2026-03-09

---

## Project Context Analysis

### Requirements Overview

**Functional Requirements (9 total — 4 MVP, 4 NTH, 1 Enhancement):**

| ID | FR | Priority | Component |
|---|---|---|---|
| FR-1 | Scan `TargetProjects/{domain}/{service}/` for `.git/` directories | MVP | FileSystemScanner |
| FR-2 | Detect `.bmad/` presence in each discovered repo | MVP | RepoInspector |
| FR-3 | Language detection (build files → extension → `unknown`) | NTH | LanguageDetector |
| FR-4 | Update `repo-inventory.yaml` in governance repo (pull-before-push) | MVP | GovernanceWriter |
| FR-5 | Create `/switch`-navigable branches in control repo | MVP | GitOrchestrator |
| FR-6 | Generate `project-context.md` per repo via delegated workflow | NTH | ContextGenerator |
| FR-7 | Update initiative config `language` from `unknown` | NTH | StateManager |
| FR-8 | Table-formatted discovery report | NTH | ReportRenderer |
| FR-9 | Proactive nudge from downstream workflows | Enhancement (deferred) | PassiveSensor |

**Non-Functional Requirements:**

| ID | NFR | Implication |
|---|---|---|
| NFR-1 | ≤1hr for 10 repos | Sequential scan sufficient; no parallelism required |
| NFR-2 | Idempotent: multiple runs → same state | Check-before-write for every persistence operation |
| NFR-3 | Zero data loss: pull-before-push | Mandatory git pull gate before any governance write |
| NFR-4 | Partial failure recovery | Per-repo error isolation; continue on single-repo failure |
| NFR-5 | Graceful degradation | Language detector returns typed result, never throws |

**Firm Technical Constraints:**
- No GitHub API calls — all detection is local filesystem only
- No branches in TargetProjects repos — control repo branching only
- Agent-command interface — VS Code Copilot Chat, no traditional UI

**Scale:** Low-Medium complexity. CLI/Agent tooling domain. ~10 repos max. No real-time, no multi-tenancy, no regulatory requirements.

### Technical Constraints & Dependencies

- Governance repo must be present (path from `governance-setup.yaml`) — verified in preflight
- `bmad-bmm-generate-project-context` workflow — delegated call for NTH FR-6
- `lifecycle.yaml` — language detection priority order source
- Initiative config — domain + service for scan path resolution

### Cross-Cutting Concerns Identified

1. **Per-repo error isolation** — failures in one repo must not abort remaining repos (FR-4, NFR-4)
2. **Pull-before-write ordering** — governance pull strictly precedes all inventory writes (NFR-3)
3. **Initiative context resolution** — domain/service resolved from active initiative config at entry
4. **NTH feature independence** — MVP pipeline (FR-1, FR-2, FR-4, FR-5) completes without NTH features

---

## System Architecture

### Component Map

```
/discover
    │
    ├── [0] PreFlight
    │       └── InitiativeContextResolver ──→ reads initiative config (domain, service, scan_path)
    │
    ├── [1] FileSystemScanner
    │       └── scans TargetProjects/{domain}/{service}/ for .git/ directories
    │
    ├── [2] RepoInspector
    │       ├── detects .bmad/ presence (FR-2)
    │       └── → LanguageDetector (NTH FR-3)
    │                   detects language from build files / extensions / fallback "unknown"
    │
    ├── [3] GovernanceWriter
    │       ├── pulls governance repo (NFR-3 gate)
    │       ├── reads repo-inventory.yaml
    │       ├── idempotency check → prompts user on conflicts (NFR-2)
    │       ├── upserts entries
    │       └── commits + pushes (non-fatal on push failure — reports ❌)
    │
    ├── [4] GitOrchestrator
    │       └── creates control-repo branches for /switch (FR-5)
    │               branch name: {initiative_root}-{domain}-{service}-{repo_name}
    │
    ├── [5] ContextGenerator (NTH)
    │       └── delegates to bmad-bmm-generate-project-context per repo (FR-6)
    │
    ├── [6] StateManager (NTH)
    │       └── updates initiative config language field (FR-7)
    │
    └── [7] ReportRenderer (NTH)
            └── renders table-formatted discovery report (FR-8)
```

### Data Flow

```
1. User runs /discover
   ↓
2. InitiativeContextResolver
   → reads: _bmad-output/lens-work/initiatives/{id}.yaml
   → resolves: domain, service, scan_path = TargetProjects/{domain}/{service}/
   ↓
3. FileSystemScanner
   → walks: scan_path/*/
   → emits: list of repo_dir paths (contains .git/)
   → if empty: prompt "clone repos → done" → re-scan → if still empty: exit 0
   ↓
4. Per-repo pipeline (sequential, isolated):
   RepoInspector → LanguageDetector → GovernanceWriter → GitOrchestrator
   → each step updates repo result record
   → failures logged to result record, pipeline continues
   ↓
5. Post-pipeline:
   ContextGenerator (NTH) → StateManager (NTH) → ReportRenderer
   ↓
6. Output: Discovery Report table
```

---

## Component Specifications

### FileSystemScanner

**Responsibility:** Enumerate immediate child directories of the service scan path that contain a `.git/` subdirectory.

**Interface:**
```
scan_for_git_dirs(scan_path: string) → string[]  // list of repo directory paths
```

**Rules:**
- Walk immediate children only (not recursive) — user clones top-level repos, not nested
- Predicate: child directory exists AND `{child}/.git/` is a directory
- Returns empty array (not error) when no repos found — caller handles empty case

**Error handling:** If scan_path does not exist → caller (PreFlight) reports and exits before scan runs.

---

### RepoInspector

**Responsibility:** For a given repo directory, determine BMAD configuration presence.

**Interface:**
```
inspect_repo(repo_dir: string) → { bmad_configured: bool }
```

**Rules:**
- `bmad_configured = directory_exists(repo_dir + "/.bmad/")`
- Does not recurse — top-level `.bmad/` only

---

### LanguageDetector (NTH)

**Responsibility:** Detect the primary programming language of a repo using the priority order from `lifecycle.yaml`.

**Interface:**
```
detect_language(repo_dir: string) → string  // language identifier or "unknown"
```

**Detection priority (from `lifecycle.yaml` `language_detection_priority`):**
1. `.bmad/language` file content
2. Build file heuristics:
   - `package.json` → `typescript` (preferred) or `javascript`
   - `*.csproj`, `*.sln` → `csharp`
   - `pyproject.toml`, `setup.py`, `requirements.txt` → `python`
   - `go.mod` → `go`
   - `pom.xml`, `build.gradle` → `java`
   - `Cargo.toml` → `rust`
3. File extension frequency analysis (top language by count)
4. Fallback: `"unknown"`

**Rules:**
- Never throws — all exceptions caught, fallback to `"unknown"`
- Returns the language identifier string matching `lifecycle.yaml` `supported_languages` list, or `"unknown"`

---

### GovernanceWriter

**Responsibility:** Update `repo-inventory.yaml` in the governance repo with discovered repo entries.

**Interface:**
```
write_governance_entry(governance_path: string, entry: RepoEntry) → WriteResult
```

**RepoEntry schema:**
```yaml
name: string          # repo directory name
path: string          # relative path from workspace root
language: string      # detected language or "unknown"
bmad_configured: bool
domain: string
service: string
```

**Rules:**
1. `git pull` the governance repo **before** any read or write (NFR-3 — hard gate; exit on failure)
2. Read current `repo-inventory.yaml` (create if absent — empty `repos: []`)
3. For each entry: check if `name` already present
   - If present: ask user `[Y/N]` before overwriting (NFR-2)
   - If not present: append new entry
4. After all entries written: `git add`, `git commit`, `git push`
5. If `git push` fails: mark all entries for this batch as `governance_status: "❌ Failed"` — **do not report success**
6. Commit message: `[discover] Add/update repos for {domain}/{service}`

**`repo-inventory.yaml` structure:**
```yaml
# repo-inventory.yaml — governed by lens-governance
repos:
  - name: string
    path: string
    language: string
    bmad_configured: bool
    domain: string
    service: string
    discovered_at: ISO8601
```

---

### GitOrchestrator (control-repo branching)

**Responsibility:** Create a branch in the control repo for each discovered repo so `/switch` can navigate to it.

**Interface:**
```
create_switch_branch(initiative_root: string, domain: string, service: string, repo_name: string) → BranchResult
```

**Branch naming convention:**
```
{initiative_root}-{domain}-{service}-{repo_name}
```
Example: `bmad-lens-repodiscovery-bmad-lens-NorthStarET.Lms`

**Rules:**
- Control repo only — no branches created inside TargetProjects repos (FR-5 hard constraint)
- If branch already exists: `BranchResult.status = "Exists"` (not an error)
- If creation fails: `BranchResult.status = "❌ Failed"` (non-fatal — continue to next repo)
- Push branch to remote after creation

---

### ContextGenerator (NTH)

**Responsibility:** Invoke the `bmad-bmm-generate-project-context` workflow for each discovered repo.

**Rules:**
- Delegated call — ContextGenerator does not implement context generation logic
- Non-fatal: failure is caught, result recorded as `project_context: "⚠️ Failed"`
- Inputs passed: `repo_path`, `language`
- Output: `project-context.md` created in `{repo_path}/`

---

### StateManager (NTH)

**Responsibility:** Update initiative config `language` field when a consistent primary language is resolved across all discovered repos.

**Rules:**
- Only updates if ALL repos share the same non-`"unknown"` language
- Updates `_bmad-output/lens-work/initiatives/{id}.yaml` `language` field
- Commits the config update to the current branch

---

### ReportRenderer (NTH)

**Responsibility:** Render the final discovery report table after all per-repo operations complete.

**Output format:**
```
📋 Discovery Report

| Repo | Language | BMAD | Governance | Branch |
|------|----------|------|------------|--------|
| {name} | {lang} | ✓/✗ | {status} | {status} |

{n} repo(s) discovered and registered.
You can now use `/switch` to navigate to any discovered repo.
```

**Column values:**
| Column | Values |
|---|---|
| Language | detected language string or `unknown` |
| BMAD | `✓` (`.bmad/` exists) / `✗` |
| Governance | `Updated` / `Skipped` / `❌ Failed` |
| Branch | `Created` / `Exists` / `❌ Failed` |

---

## Integration Contracts

### With governance repo (`lens-governance`)

- **Protocol:** Git operations via `git -C {governance_path}` shell commands
- **Pre-condition:** governance repo is a valid git repo with remote `origin`
- **File touched:** `repo-inventory.yaml` in governance repo root
- **Ordering:** pull → read → write → commit → push (strict)
- **Failure mode:** push failure → entries marked failed, no silent success

### With `bmad-bmm-generate-project-context` (NTH)

- **Protocol:** BMAD workflow delegation (`invoke: bmad-bmm-generate-project-context`)
- **Inputs:** `repo_path`, `language`
- **Output expectation:** `project-context.md` at `{repo_path}/project-context.md`
- **Failure handling:** catch all exceptions; log `project_context: "⚠️ Failed"`

### With `/switch`

- **Coupling:** indirect — `/switch` discovers branches by pattern matching control repo branch names
- **Contract:** branch name format `{initiative_root}-{domain}-{service}-{repo_name}` must be stable
- **No API call** — `/switch` reads git branches, discovery creates them

---

## Error Handling Strategy

| Failure Point | Handling | User Visible |
|---|---|---|
| `scan_path` does not exist | Preflight exits with error message | Yes — "Run /new-service first" |
| Governance repo missing | Preflight exits with error message | Yes — "Run /onboard to configure" |
| Governance `git pull` fails | Exit before writes, report error | Yes |
| Governance `git push` fails | Continue; mark entries `❌ Failed` | Yes — report table |
| Branch creation fails | Continue; mark `❌ Failed` | Yes — report table |
| Language detection fails | Return `"unknown"`, continue | Implicit (column shows `unknown`) |
| Context generation fails | Continue; mark `⚠️ Failed` | Yes — NTH column |
| Zero repos found on re-scan | Exit 0 with friendly message | Yes |

**Principle:** No silent failures. Every failure is represented in the discovery report or in preflight output.

---

## Sequence Diagram

```
User          @lens         Scanner      Inspector   GovernanceWriter   GitOrch    Reporter
 │  /discover   │              │              │             │               │          │
 │────────────→ │              │              │             │               │          │
 │             │ scan()       │              │             │               │          │
 │             │─────────────→│              │             │               │          │
 │             │ [repo list]  │              │             │               │          │
 │             │←─────────────│              │             │               │          │
 │             │              │  inspect()  │             │               │          │
 │             │─────────────────────────→  │             │               │          │
 │ "✓ repo-A" │              │  {bmad, lang}│             │               │          │
 │←────────── │              │              │             │               │          │
 │             │              │              │  pull()     │               │          │
 │             │──────────────────────────────────────── →│               │          │
 │  [Y/N]?    │              │              │   conflict? │               │          │
 │←────────── │              │              │             │               │          │
 │  Y         │              │              │             │               │          │
 │────────────→│              │              │  upsert()   │               │          │
 │             │──────────────────────────────────────── →│               │          │
 │             │              │              │  push()     │               │          │
 │             │──────────────────────────────────────── →│               │          │
 │             │              │              │             │  createBranch()         │
 │             │──────────────────────────────────────────────────────── →│          │
 │             │              │              │             │               │ render() │
 │             │──────────────────────────────────────────────────────────────────── →│
 │  [report]  │              │              │             │               │          │
 │←────────── │              │              │             │               │          │
```

---

## Validation Checklist

- [x] All 4 MVP requirements (FR-1, FR-2, FR-4, FR-5) have concrete component assignments
- [x] Pull-before-push enforced in GovernanceWriter (NFR-3)
- [x] Per-repo isolation confirmed — no early abort on single-repo failure (NFR-4)
- [x] Language detector returns typed result, never throws (NFR-5)
- [x] No GitHub API calls — all detection is filesystem-only (firm constraint)
- [x] No branches in TargetProjects repos — GitOrchestrator targets control repo only (FR-5)
- [x] Idempotency: GovernanceWriter checks before writing, prompts on conflict (NFR-2)
- [x] NTH features (FR-3, FR-6, FR-7, FR-8) have clean separation — MVP works without them
- [x] All failure modes surface in output — no silent failures
- [x] `repo-inventory.yaml` schema defined and stable
- [x] `/switch` branch naming convention defined and stable
