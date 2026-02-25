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
| Clear status visibility | `@lens /status` shows current phase, pending gates, and next actions | Status reflects current state immediately after any transition — zero lag |
| Audience model clarity | Audience levels have distinct semantic meaning — no command, workflow, or status output conflates audience level with execution lane or review scope | 0 conflation incidents |
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
| Branch topology correct | All branches follow two-tier pattern (audience/phase) for MVP; workflow branches are Growth | 0 naming violations |
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
- Cross-phase context passing: each phase workflow can load prior phase artifacts as input context

### Growth Features (Post-MVP)

**P3 — Content (Gaps E + F):**
- FR42: All phase prompts reference canonical phase names, branching patterns, and audience model from lifecycle.yaml
- FR43: Every phase command listed in the command interface produces at least one artifact file at an expected path
- All 5 phase workflows fully executable with real artifact generation

**P4 — Growth Enhancements:**
- Workflow branches (third tier): `{root}-{audience}-{phase}-{workflow}` for fine-grained artifact isolation within phases
- FR44: @lens can create workflow branches within a phase branch for artifact-level isolation
- FR45: @lens can PR workflow branches back to their phase branch
- FR46: @lens can clean up workflow branches after merge
- FR47: @lens can process constitution override flags and permit gate bypass with mandatory audit log entry
- Quinn (QA) readiness checklist integration at DevProposal phase
- Sally (UX) review gate integration at BusinessPlan phase
- Party mode adversarial reviews at every audience promotion
- Event log structured queryability
- PR template generation with planning artifact checklists for TargetProjects

### Vision (Future)

- Jira-linked GitFlow branches in TargetProjects
- Multi-org governance (org-level LENS hierarchy)
- Dashboard for initiative status across all services
- Barry (Quick Flow Solo Dev) alternative execution path
- Paige (Technical Writer) cross-cutting documentation workflow
- State migration tooling from v1 to v2
- Cross-service initiative coordination for multi-repo initiatives (FT3 — multi-service lifecycle governance)
- FR48: @lens can create an initiative scoped to domain level, coordinating lifecycle across multiple services
- `/revert` command for phase status correction with audit-logged override event
- Command abbreviations (e.g., `/bp`, `/tp`, `/dp`) as aliases

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

### Journey 4: Cris (Product Owner) — Phase Transition Experience

**Opening Scene:** Cris has just merged the BusinessPlan PR. He's ready to start TechPlan. He types `/techplan` in the chat.

**Rising Action:** @lens responds immediately:
```
✔ BusinessPlan complete (PR #14 merged)
✔ Required artifacts: prd.md found at docs/lens/lens-work/feature/upgrade/prd.md
✔ Constitution: track 'full' permits TechPlan
Creating phase branch: lens-lens-work-upgrade-cjki9q-small-techplan...
✔ Branch created. Activating Winston (Architect).
```
Cris sees each validation step pass in real time. The feedback is specific — he knows exactly which checks ran and what passed.

**Climax:** Winston activates and greets Cris with context already loaded: "I’m working on initiative upgrade-cjki9q. I’ve read the product brief and PRD. Let’s design the architecture." Cris didn’t have to explain anything — @lens injected the full planning context.

**Resolution:** Winston produces the architecture doc. @lens creates the PR back to the small audience branch. Cris sees:
```
TechPlan artifact ready: architecture.md
PR #15 created: techplan → small
Next: Review and merge PR #15, then /devproposal
```

### Journey 5: Cris (Product Owner) — Gate Block and Recovery

**Opening Scene:** Cris is eager to move fast. He types `/devproposal` but hasn’t merged the TechPlan PR yet.

**Rising Action:** @lens responds with a clear, actionable error:
```
✗ Cannot start DevProposal — TechPlan phase is not complete.
  Pending: PR #15 (techplan → small) awaiting review.
  Action: Review and merge PR #15, then retry /devproposal.
```
Cris realizes his mistake immediately. The error tells him exactly what’s pending and what to do.

**Climax:** Cris merges PR #15, but then notices `/status` shows a problem:
```
upgrade-cjki9q (full) — TechPlan [pr_pending] on small
⚠ State drift detected: PR #15 merged but phase_status not updated.
Action: Run /sync to reconcile state with git.
```
Cris types `/sync`. @lens responds:
```
Sync results:
  ✔ PR #15 merge detected → TechPlan marked complete
  ✔ state.yaml updated
  ✔ initiative config updated (dual-write)
  Current: TechPlan [complete] → ready for /devproposal
```

**Resolution:** Cris types `/devproposal` and it proceeds normally. He’s learned that the system catches drift and provides recovery tools.

### Journey 6: Cris (Product Owner) — Returning After a Break

**Opening Scene:** Cris has been away for a week. He has 2 initiatives running and doesn’t remember where either stands.

**Rising Action:** Cris types `/status` without specifying an initiative. @lens shows all initiatives:
```
Active initiatives:
  1. upgrade-cjki9q (full) — DevProposal [in_progress] on small
  2. auth-refactor-x8m3p2 (feature) — TechPlan [complete] on small

Current: upgrade-cjki9q. Use /switch to change.
```

**Climax:** Cris types `/switch auth-refactor-x8m3p2`. @lens switches context and shows:
```
auth-refactor-x8m3p2 (feature) — TechPlan [complete] on small
Next: /devproposal to begin DevProposal phase.
```

**Resolution:** Cris is re-oriented within two commands. No manual file inspection, no git log spelunking. The system remembers where he left off.

### Journey Requirements Summary

| Journey | Capabilities Revealed |
|---------|----------------------|
| Cris (PO) — First Initiative | Initiative creation, phase routing, gate enforcement, status visibility, artifact path resolution |
| Amelia (Dev) | Cross-repo handoff, planning context injection, GitFlow integration, story execution |
| Winston (Architect) | Audience promotion, party mode review, structured feedback, review evidence |
| Cris (PO) — Phase Transition | Real-time validation feedback, context injection, progress indicators, next-action guidance |
| Cris (PO) — Gate Block | Error message design, sync recovery, state drift detection, actionable error guidance |
| Cris (PO) — Returning User | Multi-initiative status, context switching, re-orientation UX |

## UX Design Decisions

*Resolves deferred UX debt from PrePlan (product brief Appendix A).*

### 1. Progressive Disclosure / Onboarding Model

Commands are grouped by frequency and revealed progressively:

**Tier 1 — Essential (taught during `/onboard`):**
- `/new` — create an initiative
- `/status` — see where you are
- `/switch` — change active initiative

**Tier 2 — Phase Commands (surfaced contextually by `/status`):**
- `/preplan`, `/businessplan`, `/techplan`, `/devproposal`, `/sprintplan`, `/dev`
- `/status` output always suggests the next phase command: "Next: type `/techplan` to begin TechPlan phase."

**Tier 3 — Recovery (surfaced only when problems arise):**
- `/sync` — reconcile state with git (surfaced when drift detected)
- `/fix` — repair state issues (surfaced when errors detected)

**Tier 4 — Governance (surfaced on demand):**
- `/constitution` — view resolved constitution for current initiative
- `/onboard` — re-run onboarding

`/onboard` flow (NFR12: under 5 interactions):
1. Detect whether initiatives exist → returning vs. new user path
2. Explain three core concepts: "Phases = what you do. Tracks = how much ceremony. Audiences = who reviews."
3. Show Tier 1 commands with one-line descriptions
4. Offer to create a first initiative (`/new`) or switch to existing (`/switch`)

### 2. Gate Feedback Contract / Error Messages

Every gate block follows this template:

```
✗ Cannot start {phase} — {precondition_phase} phase is not complete.
  Reason: {specific_reason}
  Action: {specific_action_to_resolve}
```

Error categories with examples:

| Category | Example Message |
|----------|----------------|
| Missing PR merge | `✗ Cannot start TechPlan — BusinessPlan PR #14 awaiting review. Action: Merge PR #14.` |
| Missing artifact | `✗ Cannot complete PrePlan — required artifact 'product-brief.md' not found at expected path. Action: Ensure product brief is saved.` |
| Constitution violation | `✗ Cannot create initiative — track 'hotfix' is not permitted by service constitution. Permitted tracks: [full, feature, tech-change].` |
| State drift | `⚠ State drift detected: PR #15 merged but phase_status not updated. Action: Run /sync.` |

All error messages are structured (not prose), include the specific failed check, and provide a concrete next action.

### 3. Audience Label Rationale

**Decision: Keep `small`, `medium`, `large` labels.**

Rationale: The t-shirt size metaphor was deliberately chosen because the audience levels describe *scope of exposure*, not organizational roles. The mapping is:
- **small** = smallest audience (IC working alone)
- **medium** = medium audience (IC + lead)
- **large** = large audience (IC + lead + stakeholders)
- **base** = everyone (execution-ready, merged to main)

Semantic alternatives (`draft/review/approved/released`, `ic/lead/stakeholder/production`) were evaluated and rejected because:
- Role-based labels (`ic/lead`) conflate the audience with the reviewer — the audience is "who can see it," not "who reviews it"
- Status-based labels (`draft/approved`) conflate the audience with the artifact state — an artifact can be "approved at small" but "draft at medium"
- T-shirt sizes avoid both conflations by being neutral descriptors of scope magnitude

**Mitigation:** Every user-facing output that mentions an audience level also shows its semantic meaning in parentheses on first occurrence. `/onboard` teaches the mapping explicitly. `/status` shows `small (IC)` not just `small`.

### 4. Party Mode Feedback Format

All party mode reviews follow a structured format:

```
### {Agent} ({Role}) — {Review Type} Review
**Verdict:** [Approve | Approve with Conditions | Request Changes]
**Summary:** [2-3 sentences]
**Findings:**
- [BLOCKER|CONDITION|SUGGESTION] #N: {Title}
  - Issue: {specific problem}
  - Impact: {why it matters}
  - Recommendation: {how to fix}
```

Findings are categorized as:
- **BLOCKER** — must fix before merge
- **CONDITION** — must address in revision
- **SUGGESTION** — improvement, not required

The review initiator can choose: `[F] Fix all` | `[B] Blockers only` | `[R] Review individually`

### 5. Constitution Transparency

- `/constitution` command shows the resolved constitution for the current initiative
- Output shows each LENS level's contribution and the merged result
- Example:
```
Constitution for upgrade-cjki9q:
  org:     (none)
  domain:  required_reviewers.small_to_medium: [pm, architect]
  service: required_reviewers.small_to_medium: [qa]
  repo:    (none)
  ─────────────────────────────────────
  resolved: required_reviewers.small_to_medium: [pm, architect, qa]
```
- FR19 (NFR19) ensures this transparency is always available on demand

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

All commands are invoked as slash commands in the chat interface, organized by function:

**Core Workflow:**

| Command | Action | Agent | Precondition |
|---------|--------|-------|-------------|
| `/new` | Create initiative | @lens | None |
| `/status` | Show status (suggests next command) | @lens | Initiative exists |
| `/switch` | Switch active initiative | @lens | Multiple initiatives |

**Phase Commands:**

| Command | Phase | Agent Activated | Precondition |
|---------|-------|-----------------|-------------|
| `/preplan` | PrePlan | Mary (Analyst) | Initiative exists |
| `/businessplan` | BusinessPlan | John (PM) + Sally (UX) | PrePlan complete |
| `/techplan` | TechPlan | Winston (Architect) | BusinessPlan complete |
| `/devproposal` | DevProposal | John (PM) | TechPlan complete |
| `/sprintplan` | SprintPlan | Bob (SM) | DevProposal complete |
| `/dev` | Dev execution | Amelia (Dev) + Quinn (QA) | SprintPlan complete |

**Recovery:**

| Command | Action | Agent | Precondition |
|---------|--------|-------|-------------|
| `/sync` | Reconcile local state with remote git | @lens | Initiative exists |
| `/fix` | Detect and repair state issues | @lens | Error detected |

**Governance & Setup:**

| Command | Action | Agent | Precondition |
|---------|--------|-------|-------------|
| `/constitution` | View resolved constitution | @lens | Initiative exists |
| `/onboard` | First-time setup / re-onboard | @lens | None |

**Confirmation prompts** are required before irreversible operations:
- `/new` — "Create initiative '{name}' with track '{track}'? This will create 3 audience branches. [y/n]"
- Audience promotion PRs — "Create promotion PR: small → medium? [y/n]"
- `/fix` — previews changes before applying: "Found: state drift (PR merged but status not updated). Apply fix? [y/n]"

**`/sync` conflict resolution:** Remote-wins strategy. When local and remote state diverge, @lens reconstructs state from git branch existence + PR merge status + event log. User is shown a diff of what changed.

**`/fix` scope:** Detects and repairs three categories of state issues:
1. **State drift** — PR merged but phase_status not updated → updates phase_status from git
2. **Orphan branches** — branches exist without state entries → offers deletion
3. **Orphan state** — state entries reference non-existent branches → clears stale entries

`/fix` always shows a preview before applying changes. It does not delete branches or modify state without confirmation.

### Phase-Audience Routing

All five planning phases execute at the **small** audience level. Audience promotions are user-triggered discrete events, not automatic:

| Phase | Audience Branch | Phase Branch Created From |
|-------|----------------|-------------------------|
| PrePlan | small | `{root}-small` |
| BusinessPlan | small | `{root}-small` |
| TechPlan | small | `{root}-small` |
| DevProposal | small | `{root}-small` |
| SprintPlan | small | `{root}-small` |
| Dev | (TargetProjects) | GitFlow feature branch |

**Audience promotion** happens between phase groups, triggered by the user:
- After TechPlan complete → user can promote small → medium (lead review of planning artifacts)
- After SprintPlan complete → user can promote medium → large (stakeholder review before Dev)
- After Dev complete → user can promote large → base (production release)

Promotion is not required between every phase — it's a governance checkpoint. Constitution can specify at which phase completions promotion is mandatory.

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

**Planning Context (`planning-context.yaml` — injected into TargetProjects):**
```yaml
initiative_id: string            # e.g., "upgrade-cjki9q"
initiative_name: string          # Human-readable name
planning_repo: string            # e.g., "github.com/org/BMAD.Lens"
planning_branch: string          # e.g., "lens-lens-work-upgrade-cjki9q-small"
artifact_paths:
  product_brief: string          # Relative path from repo root
  prd: string
  architecture: string
  epics_and_stories: string
  sprint_plan: string
resolved_constitution:           # Snapshot of merged constitution at Dev start
  required_reviewers: map
  required_artifacts: map
  permitted_tracks: list
discovery_mechanism: ".planning-context.yaml at repo root"  # Where agents find this file
```

The file is placed at the TargetProjects repo root as `.planning-context.yaml`. Dev-phase agents discover it automatically. It provides a cross-repo link without requiring agents to clone or access the planning repo directly.

**Two-repo handoff sequence (user perspective):**
1. `/status` in planning repo shows: "SprintPlan complete. Ready for Dev. Target repo: `{target_repo}`. Run `/dev` there."
2. User opens TargetProjects repo, types `/dev`
3. @lens prompts for story selection from the sprint plan
4. @lens creates GitFlow feature branch and injects `.planning-context.yaml`
5. Dev agent loads context from `.planning-context.yaml` and begins implementation

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
- FR18: @lens can perform additive merge of constitutions using **set-union semantics** — the resolved value for any list-valued field is the deduplicated union of all values from all LENS levels; no level can remove an item added by a higher level

> **Merge semantics example:** Domain sets `required_reviewers.small_to_medium: [pm, architect]`. Service adds `required_reviewers.small_to_medium: [pm, qa]`. Resolved: `[pm, architect, qa]` (set-union, deduplicated). Service cannot remove `architect` — only add.
>
> **Default behavior:** If no constitution exists at a given LENS level, that level contributes an empty set to the merge. If no constitution exists at any level, all gates pass with zero additional requirements (lifecycle.yaml defaults apply).

- FR19: @lens can validate track permissions against the resolved constitution before creating branches
- FR20: @lens can validate required artifacts exist before allowing phase completion
- FR21: @lens can validate required reviewers are present before allowing audience promotion
- FR21b: @lens can display the resolved constitution for the current initiative via `/constitution` command
- FR21c: @lens can create and validate constitution files at each LENS level (constitution locations: `_bmad-output/lens-work/constitutions/{level}.yaml`)

### Gate Enforcement

- FR22: @lens can block any phase transition that does not have a merged PR
- FR23: @lens can trigger party mode adversarial review at audience promotion gates
- FR24: @lens can record gate decisions (approved/blocked/conditional) in the event log
- FR25: @lens can enforce that the creating agent is not the sole approver (creator ≠ approver). *Note: In single-user deployments, this is enforced at the role level (different agent personas review from different perspectives) but does not constitute independent human review. For production-grade governance, constitution can specify `governance_model: multi-user` to require distinct human approvals.*

### Agent Coordination

- FR26: @lens can activate the correct BMM agent for a phase (Mary for PrePlan, John for BusinessPlan, etc.)
- FR27: @lens can inject initiative context (config, prior artifacts, constitution) when activating an agent
- FR28: @lens can pass planning context to TargetProjects via `.planning-context.yaml` injection (see Configuration Schema for full schema)
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
- FR39: @lens can provide onboarding guidance for first-time users (see UX Design Decisions §1 for `/onboard` flow specification)
- FR40: @lens can switch between multiple active initiatives
- FR41: @lens can sync local state with remote branch state using remote-wins strategy (see Command Interface for `/sync` conflict resolution)
- FR41b: @lens can detect and repair three classes of state issues: state drift (PR merged but status not updated), orphan branches (branches without state entries), and orphan state (state entries without branches) — see Command Interface for `/fix` scope
- FR41c: @lens can detect phase completion by checking PR merge status on the phase branch's PR to its audience branch
- FR41d: @lens can automatically trigger party mode review when an audience promotion PR is created, with participants determined by the resolved constitution

## Non-Functional Requirements

### Reliability

- NFR1: State operations are idempotent — re-running any @lens command produces the same result if preconditions haven't changed
- NFR2: State is reconstructable from event-log.jsonl + git history within 1 manual intervention step
- NFR3: Dual-write failures are detectable — @lens reports when state.yaml and initiative config diverge
- NFR4: Failed branch operations are detectable and recoverable — @lens can identify orphan branches (branches without state entries) and orphan state entries (state entries without branches) and offer cleanup via `/fix`

### Consistency

- NFR5: All phase names use the canonical set (preplan, businessplan, techplan, devproposal, sprintplan) — zero legacy references (p1/p2/p3/p4)
- NFR6: All artifact paths resolve from initiative config — zero hardcoded paths in workflows
- NFR7: Constitution merge produces deterministic results — same inputs always produce same resolved constitution
- NFR8: Event log entries are append-only and immutable — no retroactive edits

### Usability

- NFR9: Error messages from gate enforcement include the specific precondition that failed and what action is needed to resolve it
- NFR10: `/status` output shows current phase, pending gates, and clear next action in a structured 3-line summary format:
  ```
  {initiative_id} ({track}) — {phase} [{status}] on {audience} ({audience_label})
  {pending_item_or_all_clear}
  Next: {specific_next_action}
  ```
  A verbose mode (`/status -v`) shows all phases, all gates, branch names, and event history count.
- NFR11: Command naming follows consistent lowercase-concatenation convention — predictable from phase name
- NFR12: New initiative setup (`/new` → first phase command) completes in under 5 user interactions

### Maintainability

- NFR13: Adding a new phase requires changes to lifecycle.yaml and its associated configuration — no modification to existing phase workflow implementations
- NFR14: Adding a new track requires changes to lifecycle.yaml and its associated configuration — phase workflows are track-agnostic
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
| Branch name length limits | Medium (Windows) | Medium | 6-char random suffix; branch name validation against platform `MAX_PATH` limits; @lens abstracts branch names — users never type them directly |
| State loss during phase transitions | Low | High | Event log provides recovery audit trail; state reconstruction from git history |
| GitHub API rate limiting during heavy orchestration | Low | Medium | Cache PR status; batch operations where possible; graceful retry |
| Concurrent initiative state contention | Medium | Medium | state.yaml tracks `active_initiative` as singleton pointer; full per-initiative state in `initiatives/{id}.yaml`; `/switch` is a stateful operation that updates the pointer; two initiatives cannot be in-progress simultaneously in the same workspace |

---

*Generated during BusinessPlan phase by John (PM) for initiative upgrade-cjki9q.*
*Source: Product Brief (PrePlan), Brainstorming Session 2026-02-23, Lifecycle Contract v1 Draft.*

## Appendix: Party Mode Review Resolution

*Adversarial review conducted 2026-02-25 by Winston (Architect), Mary (Analyst), Sally (UX Designer).*

### Blockers Resolved

| # | Finding | Reviewer | Resolution |
|---|---------|----------|------------|
| B1 | Workflow branches have zero FRs | Winston #1, Mary #1 | Downgraded to Growth (P4); two-tier model (audience/phase) for MVP; workflow branch FRs (FR44-FR46) added to Growth scope; success criterion updated to "two-tier" |
| B2 | `planning-context.yaml` schema unspecified | Winston #2 | Full schema defined in Configuration Schema section; two-repo handoff sequence specified from user perspective |
| B3 | 5 deferred UX items from PrePlan not addressed | Sally #1 | Dedicated "UX Design Decisions" section added resolving all 5 items: progressive disclosure model, gate feedback contract, audience label rationale, party mode format, constitution transparency |
| B4 | No error/recovery journeys; Journey 4 not UX | Sally #2, #3 | Journey 4 replaced with user-perspective phase transition; Journey 5 (gate block + sync recovery) and Journey 6 (returning user) added |

### Conditions Resolved

| # | Finding | Reviewer | Resolution |
|---|---------|----------|------------|
| C1 | `/fix`, `/sync` have no backing FRs | Winston #1 | `/fix` scope (3 categories), `/sync` conflict resolution (remote-wins), FR41b-FR41d added |
| C2 | NFR4 "atomic branches" unachievable | Winston #2 | Rewritten as compensating-action requirement per recommendation |
| C3 | Constitution merge semantics ambiguous for lists | Winston #3 | Explicit set-union semantics with example added to FR18; default behavior specified |
| C4 | Phase-to-audience routing implicit | Winston #4 | Explicit Phase-Audience Routing table added; all phases at small; promotions user-triggered |
| C5 | FR25 meaningless in single-user | Winston #5 | Clarifying note added; `governance_model` constitution field recommended |
| C6 | Journey capabilities without FRs | Winston #6 | FR41d (auto party mode trigger), FR41c (phase-completion detection) added; PR templates moved to Growth |
| C7 | No FR for constitution CRUD | Winston #7 | FR21b (display) and FR21c (create/validate) added; file locations specified; default behavior documented |
| M2 | Gaps E + F have zero FRs | Mary #2 | FR42 and FR43 added explicitly in Growth P3 scope |
| M3 | Gap B has no success criterion | Mary #3 | "Audience model clarity" criterion added to User Success table |
| M4 | FR33 contradicts Growth scope | Mary #4 | Cross-phase context moved to MVP P2; removed from Growth |
| M5 | Multi-service coordination (FT3) has no FRs | Mary #5 | FR48 added to Vision scope with explicit FT3 reference |
| S4 | `/onboard` has no specification | Sally #4 | `/onboard` 4-step flow specified in UX Design Decisions §1 |
| S5 | Audience labels unexamined | Sally #5 | Rationale documented in UX Design Decisions §3; mitigation added |
| S6 | 12 commands with no grouping | Sally #6 | Command Interface reorganized into 4 groups (Core/Phase/Recovery/Governance) |
| S7 | `/status` is constraint not design | Sally #7 | 3-line output format designed; verbose mode specified |
| S8 | Two-repo handoff UX undesigned | Sally #8 | Handoff sequence specified in Configuration Schema section |
| M9 | "Status accurate within 1 phase transition" ambiguous | Mary #9 | Reworded to "immediately after any transition — zero lag" |

### Suggestions Incorporated

| # | Finding | Resolution |
|---|---------|------------|
| Winston S1 | NFR13-14 overstated | Rephrased to "lifecycle.yaml and its associated configuration" |
| Winston S2 | No rollback mechanism | `/revert` added to Vision scope |
| Winston S3 | Branch name length understated | Risk upgraded to Medium (Windows); branch name validation suggested; users never type branch names |
| Mary S6 | Missing concurrent initiative risk | Risk added with mitigation (singleton pointer + per-initiative config) |
| Mary S7 | Override mechanism absent from FRs | FR47 added to Growth P4 scope |
| Sally S9 | Missing returning-user journey | Journey 6 added |
| Sally S11 | No command abbreviations | Added to Vision scope |
| Sally S13 | No confirmation before irreversible ops | Confirmation prompts specified in Command Interface |
| Sally S10 | `/fix` is a black box | `/fix` scope specified with 3 categories + preview behavior |
| Sally S12 | Branch names are user-hostile | Specified that users never type branch names; @lens abstracts them |
