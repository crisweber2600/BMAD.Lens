---
initiative: upgrade-cjki9q
initiative_name: "Lens-Work Module Architecture Upgrade"
domain: Lens
service: lens-work
phase: techplan
agent: Winston (Architect)
date: "2026-02-25"
inputDocuments:
  - docs/lens/lens-work/feature/upgrade/product-brief.md
  - docs/lens/lens-work/feature/upgrade/prd.md
  - docs/lens/lens-work/feature/upgrade/architecture.md
---

# Technology Decisions Log — Lens-Work Module Architecture Upgrade

**Author:** Winston (Architect)
**Date:** 2026-02-25
**Initiative:** upgrade-cjki9q
**Phase:** TechPlan

---

## Decision Format

Each decision follows the Architecture Decision Record (ADR) pattern:
- **Status**: Accepted | Proposed | Deprecated | Superseded
- **Context**: Why the decision is needed
- **Decision**: What was decided
- **Alternatives**: What else was considered
- **Consequences**: Trade-offs and implications

---

## TD-001: File-Based State Storage (No Database)

**Status:** Accepted
**Category:** Data Architecture
**Priority:** Foundation

### Context

The lens-work module needs persistent state for initiative tracking, phase progression, and gate validation. Options range from a database to file-based storage. The system runs entirely within VS Code + GitHub Copilot Chat — there is no server process.

### Decision

Use **YAML files** for structured state (`state.yaml`, `initiatives/{id}.yaml`) and **JSONL** for the event log (`event-log.jsonl`). No database. No server.

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| SQLite database | Rich queries, ACID transactions | Requires runtime, binary file in git, merge conflicts | Adds dependency; binary files don't diff in git |
| JSON files | Native to JS, simple parsing | No comments, verbose for nested data, merge-hostile | YAML is more human-friendly for config-style data |
| Git notes | Stored in git metadata | Not visible in file tree, limited tooling | Poor discoverability; agents can't easily read |
| In-memory only | Fastest, simplest | Lost on session end, no recovery | Violates recoverability requirement (NFR2) |

### Consequences

- **Positive:** Zero runtime dependencies; files are git-diffable; state is recoverable from filesystem; agents can read/write with standard file operations
- **Negative:** No ACID transactions; concurrent writes could corrupt state (mitigated by single-active-initiative design); manual schema validation required
- **Trade-off:** Simplicity and portability over query power and transactional safety

---

## TD-002: JSONL for Event Log (Append-Only)

**Status:** Accepted
**Category:** Data Architecture
**Priority:** Foundation

### Context

The event log must be append-only, immutable after write, and support efficient reading of recent events. It's used for auditability (NFR17-NFR20) and state reconstruction (NFR2).

### Decision

Use **JSON Lines** format (`.jsonl`) — one JSON object per line, appended with `echo '...' >> file`.

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| YAML array | Consistent with state files | Multi-line entries make appending fragile; git diffs show entire array on any change | Bad append ergonomics |
| SQLite WAL | True append-only, ACID | Binary file, requires runtime | Same as TD-001 |
| Markdown log | Human-readable | No machine parsing without custom parser | Hard to query programmatically |
| Separate JSON files per event | Clean isolation | File explosion; directory bloat | Too many files for frequent events |

### Consequences

- **Positive:** One-line append via shell; git diffs show only new lines; grep-friendly; each line is independently parseable
- **Negative:** No indexing — full scan for historical queries; file grows unbounded (mitigated: one initiative's events are typically <100 lines)
- **Trade-off:** Append simplicity over query performance

---

## TD-003: Flat Hyphen-Separated Branch Names

**Status:** Accepted
**Category:** Git Operations
**Priority:** Foundation

### Context

Branch names must encode initiative identity, audience level, and phase. Git allows `/` in branch names but different platforms handle them inconsistently (Windows path issues, some Git GUIs treat `/` as folder hierarchy).

### Decision

Use **flat hyphen-separated** branch names with no `/` characters:
```
lens-lens-work-upgrade-cjki9q-small-techplan
```

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| Slash-separated | Visual hierarchy (`lens/lens-work/upgrade/...`) | Windows MAX_PATH issues; some tools create folders; merge operations more complex | Cross-platform reliability |
| Underscore-separated | No special char concerns | Harder to read; inconsistent with git conventions | Less readable |
| Abbreviated | Shorter names (`l-lw-upg-cjk-s-tp`) | Unreadable; requires lookup table | Violates usability (NFR11) |

### Consequences

- **Positive:** Cross-platform safe; simple string operations for parsing; no escaping needed; users never type these (abstracted by @lens)
- **Negative:** Branch names can be long (mitigated: 6-char random IDs; `MAX_PATH` validation at creation time)
- **Trade-off:** Length for reliability; acceptable because users never type branch names directly

---

## TD-004: Constitution Format — Markdown with YAML Code Blocks

**Status:** Accepted
**Category:** Governance
**Priority:** Structural

### Context

Constitutions must be both human-readable (for governance review) and machine-parseable (for gate validation). They contain prose articles AND structured gate enforcement fields.

### Decision

Use **Markdown files** with **YAML code blocks** for enforceable fields:
```markdown
# Domain Constitution: Lens

## Articles
### Article I: Structural Enforcement (prose)

## Track & Gate Governance
```yaml
permitted_tracks: [full, feature, tech-change]
required_gates: [constitution-check]
```
```

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| Pure YAML | Easy to parse, structured | Poor readability for governance prose; articles lose formatting | Constitution articles need prose format |
| Pure Markdown | Great readability | Hard to machine-parse gate rules | Gate enforcement needs structured fields |
| JSON Schema | Strict validation | Poor readability; no prose support | Not human-friendly for governance docs |
| Separate files (prose.md + rules.yaml) | Clean separation | Two files per level; sync burden | More files, more drift risk |

### Consequences

- **Positive:** Single file per constitution level; human-readable articles with machine-parseable rules; familiar format for agents
- **Negative:** Parsing requires extracting YAML from code blocks (standard operation for AI agents); YAML code blocks must be well-formed
- **Trade-off:** Single-file convenience with dual-format flexibility

---

## TD-005: Single @lens Agent (Unified Orchestration)

**Status:** Accepted
**Category:** Agent Architecture
**Priority:** Foundation

### Context

The previous architecture used five separate infrastructure agents (Casey, Compass, Tracey, Scout, Scribe). Each had its own persona, context, and state awareness. This created coordination overhead — agents needed to "call" each other, context was fragmented, and users had to understand which agent to address.

### Decision

Replace five agents with a **single @lens agent** that has five skills:
- git-orchestration (was Casey)
- state-management (was Tracey)
- discovery (was Scout)
- constitution (was Scribe)
- checklist (new capability)

The router function (was Compass) becomes the @lens agent's primary interface.

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| Keep 5 agents | Clear separation of concerns | Context fragmentation; coordination overhead; user confusion about which agent to address | Multi-agent coordination is the #1 source of failures |
| 2 agents (router + worker) | Simpler than 5 | Still requires inter-agent coordination; unclear boundary | Half-measure that doesn't solve the core problem |
| Extension-based (VS Code extension) | Native UI, true agent boundary | Massive implementation effort; lock-in to VS Code; no cross-IDE support | Disproportionate effort for the problem being solved |

### Consequences

- **Positive:** Single entry point (`@lens`); no inter-agent coordination; full context in one agent; consistent behavior; simpler mental model for users
- **Negative:** Larger agent definition (agent YAML becomes 500+ lines); skill boundaries are conventions, not physical separations
- **Trade-off:** Agent size for coordination simplicity; justified because the five "agents" were never truly independent — they always operated on the same state

---

## TD-006: Two-Tier Branch Model for MVP

**Status:** Accepted
**Category:** Git Operations
**Priority:** MVP Scope

### Context

The product brief defined a three-tier branch model (audience/phase/workflow). The PRD's adversarial review identified that workflow branches have zero functional requirements and would add complexity without clear value for MVP.

### Decision

**MVP uses two-tier branches** (audience + phase):
```
{root}-{audience}                    # Long-lived audience branch
{root}-{audience}-{phase}            # Ephemeral phase branch
```

**Growth (P4) adds workflow branches** (third tier):
```
{root}-{audience}-{phase}-{workflow}  # Fine-grained artifact isolation
```

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| Three-tier from start | Full isolation; clean per-workflow PRs | No backing FRs; adds branch management overhead; more complex merge chain | YAGNI — solve known problems first |
| One-tier (audience only) | Simplest; fewer branches | No phase isolation; all phase work on same branch; harder to review individual phases | Insufficient isolation for review gates |
| Feature branches per artifact | Ultimate isolation | Branch explosion; complex merge topology | Over-engineering for planning artifacts |

### Consequences

- **Positive:** Simpler merge chain; fewer branches to manage; fewer opportunities for merge conflicts; clear upgrade path to three-tier
- **Negative:** Phase work within an audience shares a branch lineage; can't independently review individual artifacts within a phase (all-or-nothing PR)
- **Trade-off:** Simplicity now with designed extensibility later

---

## TD-007: Audience Promotion as Discrete User-Triggered Events

**Status:** Accepted
**Category:** Workflow Architecture
**Priority:** Foundation

### Context

Audience promotions (small → medium → large → base) could be automatic (triggered by phase completion) or manual (triggered by user). Automatic promotion would reduce ceremony but skip human review.

### Decision

**Audience promotions are discrete, user-triggered events.** The @lens agent never automatically promotes. The user explicitly types a promotion command or creates the promotion PR manually.

Promotions happen at governance checkpoints, not after every phase:
- After TechPlan complete → user can promote small → medium
- After SprintPlan complete → user can promote medium → large
- After Dev complete → user can promote large → base

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| Automatic after each phase | Less ceremony | Violates FT1 (artifacts must be reviewed); no human judgment in promotion | Directly contradicts the safety guarantee |
| Automatic with constitution override | Configurable | Constitution should constrain, not automate; default-automatic is dangerous | Wrong default; opt-in is safer than opt-out |
| Promotion required after every phase | Maximum review | Excessive ceremony; 5 promotions for 5 phases is burdensome | Review fatigue reduces review quality |

### Consequences

- **Positive:** FT1 enforced at every promotion; user controls pace; constitution can specify when promotion is mandatory; review fatigue minimized by batching phases
- **Negative:** User must remember to promote; @lens must remind via `/status` output
- **Trade-off:** Ceremony for safety; mitigated by clear next-action guidance in `/status`

---

## TD-008: Set-Union Semantics for Constitution Merge

**Status:** Accepted
**Category:** Governance
**Priority:** Structural

### Context

When constitutions exist at multiple LENS hierarchy levels (org, domain, service, repo), their fields must be merged. The merge semantics determine whether lower levels can override, replace, or only extend upper-level rules.

### Decision

**Set-union merge with deduplication.** For list-valued fields, the resolved value is the deduplicated union of all values from all levels. No level can remove an item added by a higher level.

```
Domain: required_reviewers.small_to_medium: [pm, architect]
Service: required_reviewers.small_to_medium: [pm, qa]
Resolved: required_reviewers.small_to_medium: [pm, architect, qa]
```

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| Last-writer-wins | Simplest; full override power | Lower levels could weaken governance; violates additive inheritance principle | Contradicts FT2 and constitution design |
| Intersection (most restrictive) | Maximum safety | Lower levels couldn't add reviewers for their specific needs; overly restrictive | Prevents useful specialization |
| Explicit override markers | Flexible; controlled | Complex parsing; ambiguity about what "override" means; harder to validate | Over-engineering for the use case |

### Consequences

- **Positive:** Deterministic; no ambiguity; lower levels always strengthen governance; easy to implement; easy to validate (just merge and deduplicate)
- **Negative:** Lower levels cannot remove requirements that are inappropriate at their level (mitigated: incorrect upper-level rules should be fixed at the upper level, not overridden below)
- **Trade-off:** Rigidity for predictability; appropriate for governance where predictability is paramount

---

## TD-009: Planning-Context YAML for Cross-Repo Handoff

**Status:** Accepted
**Category:** Integration Architecture
**Priority:** Structural

### Context

When Dev begins in TargetProjects, the dev agent needs access to planning artifacts (architecture doc, stories, sprint plan) that live in BMAD.Lens. The two repos are independent git repositories.

### Decision

**Inject a `.planning-context.yaml` file** at the TargetProjects repo root when Dev starts. This file contains:
- Initiative identity (ID, name)
- Planning repo URL and branch
- Artifact paths (relative to planning repo root)
- Resolved constitution snapshot (frozen at Dev start)

The dev agent discovers this file automatically and uses it to reference planning artifacts.

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| Git submodule | Live link; auto-updating | Complex git operations; merge conflicts; slow clones | Overly complex for artifact references |
| Shared filesystem | Direct file access | Assumes co-location; breaks in distributed setups | Not portable |
| API service | Clean separation | Requires running service; network dependency | Violates zero-runtime-dependency principle |
| Copy artifacts to target repo | Self-contained | Duplication; stale copies; increases target repo size | Violates single-source-of-truth principle |
| Symlinks | Direct access; no duplication | Platform-dependent; git doesn't track symlinks consistently | Cross-platform reliability |

### Consequences

- **Positive:** File-based; zero runtime dependencies; dev agent auto-discovers; constitution snapshot prevents drift during Dev; explicit rather than implicit
- **Negative:** Snapshot is stale if planning artifacts change during Dev (mitigated: planning changes require going back to lens-work repo and re-promoting)
- **Trade-off:** Stale snapshot for independence; appropriate because Dev should implement against a stable spec, not a moving target

---

## TD-010: PR-Only Merge Strategy (Never Auto-Merge)

**Status:** Accepted
**Category:** Git Operations
**Priority:** Safety (P0)

### Context

Gap G in the product brief identified "dangerous auto-advance" as the only P0 priority. Some workflows auto-advanced to the next phase without review gates. This directly violated FT1: "Planning artifacts must exist and be reviewed before code is written."

### Decision

**Every phase transition and audience promotion requires a PR.** The @lens agent creates PRs but never merges them. Merging is always a user action requiring review.

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| Auto-merge with constitution override | Faster for trusted tracks | Any auto-merge path risks FT1 violation; "trusted" is subjective | FT1 is non-negotiable |
| Auto-merge for specific phases | Reduced ceremony for low-risk phases | Which phases are "low-risk" is context-dependent; auto-merge habit spreads | Slippery slope |
| Merge on approval (GitHub auto-merge) | Faster after review | Still requires PR creation and approval; acceptable future enhancement | Could be Growth feature |

### Consequences

- **Positive:** FT1 structurally enforced; every transition has a review record in git; no phase can be accidentally skipped; audit trail is complete
- **Negative:** More PRs to review (up to 5 phase PRs + 3 audience PRs per initiative); mitigated by batching phases within an audience and doing audience promotions as batch reviews
- **Trade-off:** Ceremony for safety; this is the correct trade-off for a governance system

---

## TD-011: Remote-Wins Strategy for State Sync

**Status:** Accepted
**Category:** State Management
**Priority:** Recovery

### Context

When local state and remote git state diverge (e.g., user merges a PR outside the normal flow, or state.yaml is manually edited), the system needs a reconciliation strategy.

### Decision

**Remote-wins.** When `/sync` detects divergence, the git branch state (branches exist, PRs merged) is treated as ground truth. Local `state.yaml` and `initiatives/{id}.yaml` are updated to match.

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| Local-wins | Preserves manual edits | Ignores reality; branches may not match state | State says X, git says Y → user is confused |
| Manual conflict resolution | User chooses | Extra ceremony; user may not understand the diff | Too much cognitive load for a planning tool |
| Merge strategy | Best of both | Complex; hard to define "merge" for state files | Over-engineering |

### Consequences

- **Positive:** Simple mental model ("git is truth"); predictable behavior; user sees a diff before changes apply; event log records what changed
- **Negative:** Manual state edits are overwritten; mitigated by showing diff and requiring confirmation
- **Trade-off:** Ease of use for manual edit preservation; acceptable because manual edits should be rare

---

## TD-012: Initiative ID Format — Feature Name + 6-Char Random Suffix

**Status:** Accepted
**Category:** Naming
**Priority:** Usability

### Context

Initiative IDs must be unique, human-readable enough for branch names and file paths, and short enough to avoid `MAX_PATH` issues on Windows.

### Decision

Format: `{feature-name}-{6-char-alphanum}` (e.g., `upgrade-cjki9q`).

The feature name is user-provided (lowercase, hyphens only). The 6-char suffix is randomly generated to ensure uniqueness.

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| UUID | Guaranteed unique | 32+ chars; unreadable; wastes MAX_PATH budget | Too long for branch names |
| Sequential numbers | Short; predictable | Not unique across repos; collision risk | Global uniqueness needed |
| Feature name only | Most readable | Collision risk; no uniqueness guarantee | Must be unique |
| Timestamp-based | Unique; sortable | Long (13+ chars); not human-memorable | Too long |

### Consequences

- **Positive:** Human-readable prefix; unique suffix; short enough for branch names; easy to type in `/switch` commands
- **Negative:** 6-char collision risk is ~1 in 2 billion (36^6); practically zero for a single workspace
- **Trade-off:** Brevity for theoretical collision risk; acceptable at this scale

---

## TD-013: Lifecycle YAML as Single Source of Truth

**Status:** Accepted
**Category:** Architecture
**Priority:** Foundation (Gap A Resolution)

### Context

Gap A identified "competing lifecycles" — multiple lifecycle models coexisted (numbered phases p1-p4, named phases, v1 vs v2 contracts) with no canonical source of truth.

### Decision

A single `lifecycle.yaml` file defines ALL lifecycle semantics: phases, audiences, tracks, gates, agent ownership, branch patterns, merge chains, and adversarial review configuration. All workflows import this file rather than defining their own lifecycle behavior.

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| Distributed config (per-workflow) | Workflows are self-contained | Lifecycle drift; competing models; no single truth | This IS the problem being solved (Gap A) |
| JSON config | Simpler parsing | No comments; less readable for complex nested config | YAML is standard for BMAD configs |
| Database-backed config | Central, queryable | Runtime dependency; breaks file-based principle | Contradicts TD-001 |

### Consequences

- **Positive:** One file to update when lifecycle changes; all workflows reference the same truth; backward-compatible via `legacy_phase_number` mappings; schema version enables evolution
- **Negative:** Single file becomes critical — corruption or invalid YAML breaks all workflows (mitigated: file is git-committed; easy to recover from git history)
- **Trade-off:** Single point of truth = single point of failure; the benefit of consistency outweighs the risk

---

## TD-014: Advisory-First Constitution Mode

**Status:** Accepted
**Category:** Governance
**Priority:** Usability

### Context

Constitution checks run at every workflow step. If they block progress on every minor violation, the system becomes unusable during early adoption when rules may not be fully configured.

### Decision

**Advisory mode is the default.** Constitution violations produce warnings but don't block progress. `Enforced` mode is opt-in per initiative via `constitution_mode: enforced` in initiative config.

### Alternatives Considered

| Alternative | Pros | Cons | Rejection Reason |
|-------------|------|------|------------------|
| Enforced by default | Maximum safety | Blocks progress on misconfigured rules; hostile to new users | Adoption barrier |
| No advisory mode | Simpler; binary (on/off) | No middle ground; users either have full enforcement or nothing | Prevents gradual adoption |
| Per-rule enforcement level | Fine-grained control | Complex configuration; hard to understand precedence | Over-engineering for MVP |

### Consequences

- **Positive:** Low adoption barrier; users see governance value before enforcement; gradual migration from advisory → enforced; no "day one blocking" risk
- **Negative:** Advisory mode may be ignored; violations may accumulate (mitigated: warnings are visible; `/compliance` shows full status; event log records all checks)
- **Trade-off:** Adoption ease for enforcement rigor; appropriate for a tool that needs voluntary adoption

---

## Decision Index

| ID | Decision | Category | Priority | Status |
|----|----------|----------|----------|--------|
| TD-001 | File-based state storage | Data Architecture | Foundation | Accepted |
| TD-002 | JSONL for event log | Data Architecture | Foundation | Accepted |
| TD-003 | Flat hyphen-separated branches | Git Operations | Foundation | Accepted |
| TD-004 | Constitution Markdown + YAML | Governance | Structural | Accepted |
| TD-005 | Single @lens agent | Agent Architecture | Foundation | Accepted |
| TD-006 | Two-tier branch model for MVP | Git Operations | MVP Scope | Accepted |
| TD-007 | User-triggered audience promotions | Workflow Architecture | Foundation | Accepted |
| TD-008 | Set-union constitution merge | Governance | Structural | Accepted |
| TD-009 | Planning-context YAML cross-repo | Integration Architecture | Structural | Accepted |
| TD-010 | PR-only merge (never auto-merge) | Git Operations | Safety (P0) | Accepted |
| TD-011 | Remote-wins for state sync | State Management | Recovery | Accepted |
| TD-012 | Feature name + 6-char ID | Naming | Usability | Accepted |
| TD-013 | Lifecycle YAML single source | Architecture | Foundation | Accepted |
| TD-014 | Advisory-first constitution mode | Governance | Usability | Accepted |

---

*Generated during TechPlan phase by Winston (Architect) for initiative upgrade-cjki9q.*
*Source: Product Brief (PrePlan), PRD (BusinessPlan), Architecture Document (TechPlan).*
