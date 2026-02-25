---
stepsCompleted: [step-01-init, step-02-discovery, step-02b-vision, step-02c-executive-summary, step-03-success, step-04-journeys, step-05-domain, step-06-innovation, step-07-project-type, step-08-scoping, step-09-functional, step-10-nonfunctional, step-11-polish]
inputDocuments:
  - docs/lens/lens-work/feature/upgrade/product-brief.md
  - _bmad-output/brainstorming/brainstorming-session-2026-02-23.md
  - _bmad-output/brainstorming/lifecycle.yaml
workflowType: 'prd'
initiative: upgrade-cjki9q
initiative_name: "Lens-Work Module Architecture Upgrade"
domain: Lens
service: lens-work
phase: businessplan
agent: John (PM)
classification:
  projectType: developer_tool
  domain: developer-tooling
  complexity: medium
  projectContext: brownfield
---

# Product Requirements Document — Lens-Work Module Architecture Upgrade

**Author:** CrisWeber
**Date:** 2026-02-25
**Initiative:** upgrade-cjki9q
**Phase:** BusinessPlan

## Executive Summary

The lens-work BMAD module is the command-driven workbench that orchestrates phase-aware lifecycle governance for software initiatives — from initial brainstorm through production deployment. It coordinates AI agents, manages planning artifacts, and enforces review gates through git branch topology and PR-based promotions.

The current system has accumulated seven architectural gaps (competing lifecycle models, muddled audience semantics, path inconsistencies, state drift, stub prompts, skeleton phases, and dangerous auto-advance) that collectively undermine its core guarantee: **planning artifacts must exist and be reviewed before code is written**. The module works when followed carefully but provides no structural enforcement of its own rules.

This upgrade replaces the current loosely-coupled phase scripts with a structurally-enforced lifecycle engine built on five pillars: a single canonical lifecycle contract (`lifecycle.yaml`), named phases with agent ownership (PrePlan → BusinessPlan → TechPlan → DevProposal → SprintPlan), audience-as-promotion-backbone (small → medium → large → base), initiative tracks for right-sized ceremony (full/feature/tech-change/hotfix/spike), and constitution-enforced governance through the four-level LENS hierarchy (org → domain → service → repo).

### What Makes This Special

**Structural over instructional enforcement.** Most AI-agent orchestration tells agents what to do via prompts — inherently fragile because agents drift. Lens-work constrains agents through *where they work* (branch topology creates physical boundaries), *what must exist before they proceed* (required artifacts block promotion), and *who must approve* (constitution-enforced gates mandate multi-agent adversarial review). The agent can't bypass what it can't see.

**Two-speed execution model.** Planning needs rich branching for human-speed review gates. Code needs GitFlow for AI-speed integration safety. The architecture recognizes this asymmetry explicitly — and the isomorphism between four planning audience levels and four code merge gates (IC self-review ↔ story→epic, lead review ↔ epic→develop, stakeholder/QA ↔ develop→release, production gate ↔ release→main) emerged naturally, confirming internal consistency.

**Additive constitution inheritance.** Governance rules flow through org → domain → service → repo with strictly additive resolution — lower levels can only add requirements, never remove them. No override ambiguity. The @lens agent's validation is straightforward: merge all levels, check union of requirements.

## Project Classification

| Dimension | Value |
|-----------|-------|
| **Project Type** | Developer Tool — workflow orchestration framework for AI agent lifecycle governance |
| **Domain** | Developer Tooling / AI Agent Orchestration |
| **Complexity** | Medium — multi-agent coordination, state machines, git operations; no regulatory/compliance concerns |
| **Project Context** | Brownfield — upgrading existing lens-work module (7 gaps identified, 14 brainstormed solutions, 3 fundamental truths established) |

## Success Criteria

### User Success

| Criterion | Measurement | Target |
|-----------|-------------|--------|
| Phase commands work end-to-end | Each `/phase` command produces its expected artifact without manual intervention | All 5 phases executable |
| No dead ends | Zero stub workflows that appear available but produce nothing | 0 skeleton phases |
| Predictable artifact locations | Every artifact path resolves from initiative config `docs` block | 100% path consistency |
| Clear status visibility | `@lens /status` shows current phase, pending gates, and next actions | Status accurate within 1 phase transition |
| No accidental phase skip | Every phase transition requires explicit PR review gate | 0 auto-advances |

### Business Success

| Criterion | Measurement | Target |
|-----------|-------------|--------|
| Single lifecycle contract | One `lifecycle.yaml` referenced by all workflows | 1 contract, 0 competing models |
| Dogfood validation | Complete one full-track initiative through all 5 phases using the upgraded system | 1 initiative through Dev |
| Module adoption | Other BMAD projects can install and use lens-work v2 without v1 workarounds | Clean install, no migration hacks |
| Reduced support burden | Questions about "which phase model do I use?" eliminated | 0 lifecycle model confusion reports |

### Technical Success

| Criterion | Measurement | Target |
|-----------|-------------|--------|
| State alignment | state.yaml and initiative config schemas match; dual-write enforced | 0 state drift incidents |
| Constitution validation | @lens validates track permissions before branch creation | 100% gate enforcement |
| Branch topology correct | All branches follow three-tier pattern (audience/phase/workflow) | 0 naming violations |
| Event log completeness | Every phase transition, PR, and gate decision logged | 100% auditability |
| Named phases everywhere | Zero references to p1/p2/p3/p4 in active workflow code | 0 legacy phase refs |

### Measurable Outcomes

- **3-month milestone:** All 7 gaps (A-G) resolved; all 5 phase workflows produce artifacts; dogfood initiative complete through TechPlan
- **6-month milestone:** Full dogfood initiative complete through Dev; at least 2 initiatives running concurrently without conflict
- **12-month milestone:** Lens-work v2 is the default for all new BMAD initiatives; v1 workflows deprecated

## Product Scope

### MVP — Minimum Viable Product

The MVP resolves the safety-critical gap and establishes the foundational architecture:

**P0 — Safety Gate (Gap G):**
- Remove all auto-advance patterns from phase workflows
- Every phase transition requires explicit PR merge

**P1 — Foundation (Gaps A + B):**
- Single canonical `lifecycle.yaml` defining phases, audiences, tracks, gates, agent ownership
- Named phases (PrePlan, BusinessPlan, TechPlan, DevProposal, SprintPlan) replace numbered phases
- Audience model separated from execution lanes: small = IC work, medium = lead review, large = stakeholder, base = execution-ready
- Initiative tracks (full, feature, tech-change, hotfix, spike) with constitution-controlled permissions

**P2 — Structural (Gaps D + C):**
- State schema alignment: state.yaml and initiative config use identical schemas
- Dual-write contract enforced by @lens agent
- Path normalization: `docs/{domain}/{service}/repo/{repo}/feature/{feature}` hierarchy
- Artifact locations resolve from initiative config

### Growth Features (Post-MVP)

**P3 — Content (Gaps E + F):**
- Phase prompts updated with canonical phase names and branching patterns
- All 5 phase workflows fully executable with real artifact generation
- Cross-phase context passing (each phase workflow can load prior phase artifacts)

**Cross-cutting enhancements:**
- Quinn (QA) readiness checklist integration at DevProposal phase
- Sally (UX) review gate integration at BusinessPlan phase
- Party mode adversarial reviews at every audience promotion
- Event log structured queryability

### Vision (Future)

- Jira-linked GitFlow branches in TargetProjects
- Multi-org governance (org-level LENS hierarchy)
- Dashboard for initiative status across all services
- Barry (Quick Flow Solo Dev) alternative execution path
- Paige (Technical Writer) cross-cutting documentation workflow
- State migration tooling from v1 to v2
- Cross-service initiative coordination for multi-repo initiatives

## User Journeys

### Journey 1: Cris (Product Owner) — First Initiative on v2

**Opening Scene:** Cris has been using lens-work v1 and has experienced the pain firsthand — inconsistent phase names, auto-advancing past review gates, artifacts landing in unpredictable locations. He decides to try the upgraded v2 system on a real initiative.

**Rising Action:** Cris types `/new` in the lens-work repo. The @lens agent asks for initiative details: domain (Lens), service (lens-work), feature name (upgrade), and track (full). It creates the initiative config, audience branches (small/medium/large), and sets the initial state. Cris types `/preplan` and Mary (Analyst) activates — she already knows the initiative context because @lens injected it. Mary produces a product brief, and @lens creates a PR from the phase branch back to the small audience branch.

**Climax:** When Cris tries to type `/businessplan` before the preplan PR is merged, @lens blocks him: "PrePlan phase is not complete — PR #13 awaiting review." This is the moment Cris realizes the system actually enforces its own rules. No more accidental phase skips.

**Resolution:** After merging the PR, Cris continues through BusinessPlan (John + Sally), TechPlan (Winston), and DevProposal (John). At each phase, @lens creates the branch, activates the right agent, and blocks progression until review is complete. The artifacts land exactly where the config says they should. When Cris types `/status`, he sees a clear picture of where the initiative stands.

### Journey 2: Amelia (Developer) — Executing Stories from v2 Planning

**Opening Scene:** Amelia receives a sprint plan from Bob (SM) in the lens-work repo. The stories reference planning artifacts she hasn't seen before — they're organized under `docs/lens/lens-work/feature/upgrade/` instead of scattered across `_bmad-output/planning-artifacts/`.

**Rising Action:** Amelia types `/dev` in the TargetProjects repo. @lens creates a GitFlow feature branch named after the initiative and story. It injects a `planning-context.yaml` linking back to the lens-work planning artifacts. Amelia reads the architecture doc, the relevant stories, and begins implementing.

**Climax:** When Amelia pushes her story branch and opens a PR to the epic branch, she sees that the PR template includes a checklist referencing the planning artifacts: "Does this implementation match the architecture doc?" and "Are the acceptance criteria from the story met?" The planning system and code system are connected.

**Resolution:** Amelia completes her stories, they merge through epic → develop → release → main. The dev phase completes, and the initiative status updates to reflect production deployment.

### Journey 3: Winston (Architect) — Reviewing a Promotion Gate

**Opening Scene:** Winston gets a notification that initiative `upgrade-cjki9q` is ready for promotion from small to medium audience. Three phases of planning artifacts (product brief, PRD, architecture doc) are waiting for adversarial review.

**Rising Action:** Winston opens the PR from `{root}-small` to `{root}-medium`. The PR description lists all artifacts and their locations. @lens has triggered party mode — Winston is the lead reviewer, but John (PM) and Mary (Analyst) are also participating. Each reviewer brings their expertise: Winston checks technical feasibility, John checks business alignment, Mary checks research foundation.

**Climax:** Winston identifies that the architecture doc doesn't address the cross-repo handoff mechanism in enough detail. He leaves a structured review comment with a condition for approval. The party mode discussion produces actionable feedback — not a rubber stamp.

**Resolution:** The artifacts are updated to address review conditions, the PR is approved and merged, and the initiative promotes to medium audience. The event log records the review decision, participants, and conditions addressed.

### Journey 4: @lens Agent — Orchestrating a Phase Transition

**Opening Scene:** @lens detects that the user has typed `/techplan` for initiative `upgrade-cjki9q`. Before doing anything, @lens checks the current state.

**Rising Action:** @lens loads `state.yaml` and verifies: Is BusinessPlan complete? It checks `phase_status.businessplan` — if it's not `complete`, @lens blocks the transition with a clear message explaining what's pending. If BusinessPlan is complete, @lens proceeds: creates the phase branch `{root}-small-techplan` from the small audience branch, updates state to `current_phase: techplan`, writes an event log entry, and activates Winston (Architect).

**Climax:** @lens validates the constitution before creating the branch. It merges the domain constitution with the service constitution (additive only), checks that the initiative's track (`full`) is permitted, and verifies that all required artifacts from prior phases exist. If anything fails validation, @lens blocks with a specific error.

**Resolution:** Winston activates in the correct branch context with all prior phase artifacts accessible. @lens enters a monitoring state, waiting for the phase workflow to complete and a PR to be created. The dual-write contract ensures both state.yaml and the initiative config reflect the transition.

### Journey Requirements Summary

| Journey | Capabilities Revealed |
|---------|----------------------|
| Cris (PO) | Initiative creation, phase routing, gate enforcement, status visibility, artifact path resolution |
| Amelia (Dev) | Cross-repo handoff, planning context injection, GitFlow integration, story execution |
| Winston (Architect) | Audience promotion, party mode review, structured feedback, review evidence |
| @lens Agent | State validation, branch creation, constitution checking, event logging, dual-write |

## Innovation & Novel Patterns

### Structural Enforcement via Branch Topology

The core innovation is using git branch topology as a physical enforcement mechanism for lifecycle governance. Rather than instructing agents to follow conventions (which they can and do drift from), the system constrains agents to branches where they have the right context and blocks promotion until structural prerequisites (required artifacts, review approvals) are met.

This pattern is novel in the AI-agent orchestration space because most frameworks rely on prompt engineering for governance. Lens-work makes governance structural — the agent literally can't see or access the next phase until gates are satisfied.

### Audience-Phase Isomorphism

The four-level audience progression (small → medium → large → base) and the four-level code merge progression (story→epic → epic→develop → develop→release → release→main) weren't designed to be isomorphic — they emerged independently from first-principles analysis. This structural consistency suggests the architecture captures something fundamental about escalating review scope.

### Validation Approach

- **Dogfood validation:** This initiative (`upgrade-cjki9q`) is both the first test case and the deliverable. If the system can manage its own development lifecycle, it validates the architecture.
- **Constitution stress test:** Create constitutions at domain and service levels with different constraints; verify additive resolution produces correct merged requirements.
- **Gate enforcement test:** Attempt to invoke phase commands out of order; verify @lens blocks with clear error messages.

### Risk Mitigation

- **Fallback if structural enforcement proves too rigid:** Constitution can define `override_allowed: true` for specific gates, allowing human override with audit trail
- **Fallback if branch topology becomes unwieldy:** Initiative IDs use 6-char random suffix to keep names manageable; branch cleanup after phase completion reduces active branch count

## Developer Tool Specific Requirements

### Workflow Orchestration Architecture

The @lens agent serves as the central orchestration point, combining five capabilities that were previously distributed across five separate agents (Casey, Compass, Tracey, Scout, Scribe):

| Capability | Description | Implementation Pattern |
|------------|-------------|----------------------|
| **Git Orchestration** | Branch creation, PR management, merge operations | Git CLI via terminal commands |
| **State Management** | Phase tracking, gate status, dual-write contract | YAML file read/write with validation |
| **Discovery** | Initiative lookup, artifact location, context loading | File system search + config resolution |
| **Constitution** | Governance rule loading, additive merge, gate validation | YAML merge with union semantics |
| **Checklist** | Readiness checks, artifact existence, review status | File existence + PR status checks |

### Command Interface

All commands are invoked as slash commands in the chat interface:

| Command | Phase/Action | Agent Activated | Precondition |
|---------|-------------|-----------------|--------------|
| `/new` | Create initiative | @lens | None |
| `/preplan` | PrePlan phase | Mary (Analyst) | Initiative exists |
| `/businessplan` | BusinessPlan phase | John (PM) + Sally (UX) | PrePlan complete |
| `/techplan` | TechPlan phase | Winston (Architect) | BusinessPlan complete |
| `/devproposal` | DevProposal phase | John (PM) | TechPlan complete |
| `/sprintplan` | SprintPlan phase | Bob (SM) | DevProposal complete |
| `/dev` | Dev execution | Amelia (Dev) + Quinn (QA) | SprintPlan complete |
| `/status` | Show status | @lens | Initiative exists |
| `/switch` | Switch initiative | @lens | Multiple initiatives |
| `/sync` | Sync state | @lens | Initiative exists |
| `/fix` | Fix state issues | @lens | Error detected |
| `/onboard` | First-time setup | @lens | None |

### Configuration Schema

**Initiative Config (`initiatives/{id}.yaml`):**
```yaml
initiative_id: string        # e.g., "upgrade-cjki9q"
initiative_name: string      # Human-readable name
layer: enum[domain, service, repo, feature]
domain: string
service: string
track: enum[full, feature, tech-change, hotfix, spike]
current_phase: enum[preplan, businessplan, techplan, devproposal, sprintplan, dev]
phase_status: map[phase → status]
gate_status: map[gate → status]
audience_status: map[promotion → status]
docs_path: string            # Resolved artifact root
branch_root: string          # e.g., "lens-lens-work-upgrade-cjki9q"
```

**State File (`state.yaml`):**
```yaml
lifecycle_version: 2
active_initiative: string
current_phase: enum[...]
active_track: enum[...]
workflow_status: enum[ready, in_progress, pr_pending, complete]
phase_status: map[phase → status]   # Dual-written with initiative config
audience_status: map[promotion → status]
```

### Implementation Considerations

- **No runtime dependencies:** All orchestration is file-based (YAML, markdown, git). No database, no server, no API.
- **Idempotent operations:** Every @lens command can be re-run safely. State is reconstructable from git history + event log.
- **Graceful degradation:** If state.yaml is corrupted, @lens can reconstruct from event-log.jsonl and git branch state.
- **Cross-platform:** Git operations use standard CLI; no platform-specific tooling.

## Functional Requirements

### Lifecycle Management

- FR1: @lens can create a new initiative with specified domain, service, feature name, and track
- FR2: @lens can determine the next phase for an initiative based on its track and current phase
- FR3: @lens can block phase transitions when precondition phases are not complete
- FR4: @lens can load the canonical lifecycle contract and resolve phase ordering for any track
- FR5: @lens can mark a phase as complete when its PR is merged to the audience branch

### Branch Orchestration

- FR6: @lens can create audience branches (small/medium/large) when an initiative is initialized
- FR7: @lens can create a phase branch from the current audience branch when a phase starts
- FR8: @lens can create a PR from a phase branch to its audience branch when a phase workflow completes
- FR9: @lens can create a PR from one audience branch to the next for audience promotion
- FR10: @lens can delete phase branches after they are merged
- FR11: @lens can create GitFlow feature branches in TargetProjects when Dev phase begins

### State Management

- FR12: @lens can read and write state.yaml with the v2 lifecycle contract schema
- FR13: @lens can read and write initiative config YAML files
- FR14: @lens can enforce dual-write contract — every state change updates both state.yaml and initiative config
- FR15: @lens can reconstruct state from event-log.jsonl and git branch state if state.yaml is corrupted
- FR16: @lens can report current initiative status including phase, pending gates, and next actions

### Constitution Enforcement

- FR17: @lens can load constitutions from all four LENS hierarchy levels (org, domain, service, repo)
- FR18: @lens can perform additive merge of constitutions (union of all requirements, no subtraction)
- FR19: @lens can validate track permissions against the resolved constitution before creating branches
- FR20: @lens can validate required artifacts exist before allowing phase completion
- FR21: @lens can validate required reviewers are present before allowing audience promotion

### Gate Enforcement

- FR22: @lens can block any phase transition that does not have a merged PR
- FR23: @lens can trigger party mode adversarial review at audience promotion gates
- FR24: @lens can record gate decisions (approved/blocked/conditional) in the event log
- FR25: @lens can enforce that the creating agent is not the sole approver (creator ≠ approver)

### Agent Coordination

- FR26: @lens can activate the correct BMM agent for a phase (Mary for PrePlan, John for BusinessPlan, etc.)
- FR27: @lens can inject initiative context (config, prior artifacts, constitution) when activating an agent
- FR28: @lens can pass planning context to TargetProjects via `planning-context.yaml` injection
- FR29: @lens can coordinate party mode participants based on constitution and lifecycle contract

### Artifact Management

- FR30: @lens can resolve artifact paths from initiative config `docs` block
- FR31: @lens can verify artifact existence at expected paths before gate checks
- FR32: @lens can normalize all output paths to the `docs/{domain}/{service}/repo/{repo}/feature/{feature}` pattern
- FR33: @lens can discover and load artifacts from prior phases as context for current phase

### Event Logging

- FR34: @lens can append structured events to event-log.jsonl for every phase transition, PR, and gate decision
- FR35: @lens can record agent activations, review participants, and review outcomes
- FR36: @lens can provide event history for a specific initiative
- FR37: @lens can use event log for state reconstruction when primary state files are inconsistent

### Discovery & Onboarding

- FR38: @lens can discover existing initiatives and their current state from the file system
- FR39: @lens can provide onboarding guidance for first-time users
- FR40: @lens can switch between multiple active initiatives
- FR41: @lens can sync local state with remote branch state

## Non-Functional Requirements

### Reliability

- NFR1: State operations are idempotent — re-running any @lens command produces the same result if preconditions haven't changed
- NFR2: State is reconstructable from event-log.jsonl + git history within 1 manual intervention step
- NFR3: Dual-write failures are detectable — @lens reports when state.yaml and initiative config diverge
- NFR4: Branch operations are atomic — a failed branch creation does not leave partial state

### Consistency

- NFR5: All phase names use the canonical set (preplan, businessplan, techplan, devproposal, sprintplan) — zero legacy references (p1/p2/p3/p4)
- NFR6: All artifact paths resolve from initiative config — zero hardcoded paths in workflows
- NFR7: Constitution merge produces deterministic results — same inputs always produce same resolved constitution
- NFR8: Event log entries are append-only and immutable — no retroactive edits

### Usability

- NFR9: Error messages from gate enforcement include the specific precondition that failed and what action is needed to resolve it
- NFR10: `/status` output shows current phase, pending gates, and clear next action within 3 lines
- NFR11: Command naming follows consistent lowercase-concatenation convention — predictable from phase name
- NFR12: New initiative setup (`/new` → first phase command) completes in under 5 user interactions

### Maintainability

- NFR13: Adding a new phase requires changes to lifecycle.yaml only — no workflow code changes needed for routing
- NFR14: Adding a new track requires changes to lifecycle.yaml only — phase workflows are track-agnostic
- NFR15: Constitution schema is extensible — new gate types can be added without modifying existing gate validation logic
- NFR16: All @lens capabilities are independently testable — each skill can be validated in isolation

### Auditability

- NFR17: Every gate decision (approved/blocked/conditional) is recorded with timestamp, actor, and rationale
- NFR18: Every state transition is traceable through git history + event log
- NFR19: Constitution resolution is transparent — @lens can show the resolved constitution for any initiative on demand
- NFR20: Review evidence (PR approvals, party mode outcomes) is preserved in git history

## Dependencies & Constraints

| Dependency | Required For | Status | Risk |
|------------|-------------|--------|------|
| BMM module agents (Mary, John, Winston, Bob, Amelia) | Phase execution | Available | Low — agents exist |
| CIS module | Brainstorming, party mode reviews | Available | Low — module exists |
| TEA module | Test planning integration | Available (optional) | Low — optional |
| Core module | BMAD infrastructure, editorial review | Available | Low — module exists |
| Git CLI | All branch/PR operations | Available | Low — standard tooling |
| GitHub API (via MCP) | PR creation, merge, status checks | Available | Medium — API rate limits |
| `lifecycle.yaml` | Canonical lifecycle contract | Exists (draft v1) | Medium — needs v2 update |
| Constitution schema | Governance enforcement | Needs design | High — blocks gate enforcement |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Scope magnitude (12 in-scope items, 7 gaps) | High | High | Phased delivery: P0 (safety) → P1 (foundation) → P2 (structural) → P3 (content). MVP = G+A+B |
| Migration complexity from v1 to v2 | High | Medium | Parallel operation period; v1 workflows continue during transition |
| Constitution schema underspecification | Medium | High | Minimum schema defined in product brief; extend incrementally per LENS level |
| Two-repo context switching cognitive load | Medium | Medium | @lens automates handoff; planning-context.yaml provides cross-repo link |
| Party mode review quality variance | Medium | Medium | Specific review questions per artifact type; constitution can add participants |
| Branch name length limits | Low | Low | 6-char random suffix on initiative IDs keeps names manageable |
| State loss during phase transitions | Low | High | Event log provides recovery audit trail; state reconstruction from git history |
| GitHub API rate limiting during heavy orchestration | Low | Medium | Cache PR status; batch operations where possible; graceful retry |

---

*Generated during BusinessPlan phase by John (PM) for initiative upgrade-cjki9q.*
*Source: Product Brief (PrePlan), Brainstorming Session 2026-02-23, Lifecycle Contract v1 Draft.*
