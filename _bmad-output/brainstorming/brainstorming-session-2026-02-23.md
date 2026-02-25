---
stepsCompleted: [1, 2, 3]
inputDocuments: []
session_topic: 'Lens-work module architecture reconciliation and improvement strategy'
session_goals: 'Resolve competing lifecycle models, normalize paths/state, decide implementation priorities, produce concrete improvement roadmap'
selected_approach: 'ai-recommended'
techniques_used: ['Assumption Reversal', 'Morphological Analysis', 'First Principles Thinking']
ideas_generated: [Lifecycle-1, Lifecycle-2, Lifecycle-3, Lifecycle-4, Lifecycle-5, Lifecycle-6, Lifecycle-7, Lifecycle-8, Lifecycle-9, Lifecycle-10, Lifecycle-11, Lifecycle-12, Lifecycle-13, Lifecycle-14]
context_file: ''
technique_execution_complete: true
facilitation_notes: 'User brought deep pre-existing analysis. Session pivoted from generic brainstorming to architectural design decision-making. All three techniques completed. 14 lifecycle ideas generated spanning phase naming, audience model, branching, tracks, governance, and execution patterns.'
---

# Brainstorming Session Results

**Facilitator:** CrisWeber
**Date:** 2026-02-23

## Session Overview

**Topic:** Lens-work module architecture reconciliation and improvement strategy

**Goals:**

- Resolve competing lifecycle models into one canonical contract
- Normalize paths and state schemas across the module
- Decide what to fully implement vs. collapse vs. defer
- Produce concrete improvement roadmap (potentially a punchlist PR plan)

### Context Guidance

User has provided comprehensive analysis of lens-work BMAD module including:

- Module's core value as command-driven workbench with phase-aware lifecycle
- 5 infrastructure agents (Compass, Casey, Tracey, Scout, Scribe)
- BMM agents (Mary, John, Winston, Bob, Amelia, Quinn, Sally, Paige, Barry)
- Branch topology and PR-based gates
- 7 major gaps identified (A-G): competing lifecycles, muddled size/audience concepts, path inconsistencies, state drift, stub prompts misalignment, skeleton phases, dangerous auto-advance
- 5 prioritized improvements: lifecycle contract, path normalization, state versioning, executable git operations, documentation pruning

### Session Setup

The user has already done deep analysis and has both a problem taxonomy and initial solution strategy. Session focus:

1. Design decisions within the improvement plan (what should canonical lifecycle be?)
2. Exploring beyond current analysis (hidden gaps, alternative architectures, leapfrog opportunities)

## Technique Selection

**Approach:** AI-Recommended Techniques
**Analysis Context:** Lens-work module architecture with focus on lifecycle reconciliation and improvement roadmap

**Recommended Techniques:**

- **Assumption Reversal (deep):** Surface and challenge assumptions baked into lens-work's current design before redesigning
- **Morphological Analysis (deep):** Systematically map the combinatorial design space of lifecycle phases x execution lanes x review audiences x branch topology x artifact types
- **First Principles Thinking (creative):** Strip back to fundamental truths — what must lens-work guarantee at each stage?

**AI Rationale:** User has completed deep gap analysis but needs to move from "what's broken" to "what the canonical design should be." Sequence challenges inherited assumptions first, then maps the full design space, then distills non-negotiable principles for the new architecture.

---

## Technique Execution Results

### Phase 1: Assumption Reversal

**Interactive Focus:** Challenged 6 fundamental assumptions baked into lens-work's current architecture. Each assumption was surfaced, stress-tested, and resolved into a design decision.

#### Assumptions Challenged

**Assumption 1: "Each lifecycle phase needs its own git branch"**

- Explored decoupling phases from branches entirely (tracking phases purely in state.yaml)
- **Decision:** Branch-per-phase DOES add real value for scoped PR review, rollback granularity, and changeset coherence. Keep it, but fix the mapping.

**Assumption 2: "Commands map 1:1 to phases"**

- The current model (`/pre-plan` = p1, `/spec` = p2, etc.) breaks because `/tech-plan` and `/story-gen` are orphaned
- Reframed: commands map to phases by *artifact type*, not by command name
- Multiple commands can contribute to the same phase

**Assumption 3: "Phases need numbered names (p1, p2, p3, p4)"**

- Replaced with semantically named phases owned by specific BMM agents
- PrePlan (Mary), BusinessPlan (John), TechPlan (Winston) — self-documenting, no jargon

**Assumption 4: "Planning and execution use the same branch model"**

- Discovered the two-speed model: planning artifacts need rich branch topology (human-review speed), code execution uses GitFlow (AI speed, sprints in hours not weeks)
- Lens-work repo = rich audience-phase branching. TargetProjects = GitFlow with Jira linkage.

**Assumption 5: "Planning docs could live in target repos"**

- Tested whether planning docs could live inside target repos
- **Decision:** ALL planning artifacts live in central lens-work repo, regardless of initiative scope. Even single-repo initiatives. Avoids false positive security scans in code repos. Provides consistency — one place to look, one branch topology pattern.

**Assumption 6: "Every initiative needs all phases"**

- Proposed initiative "tracks" — predefined lifecycle profiles that skip irrelevant phases
- Tracks: full, feature, tech-change, hotfix, spike
- Upgraded to constitution-enforced tracks (governance controls which tracks are permitted per domain/service)

---

### Phase 2: Morphological Analysis

**Interactive Focus:** Built a complete parameter grid mapping all lifecycle dimensions and checked for conflicts between design decisions. Resolved 4 grid conflict questions.

#### Parameter Grid

| Phase | Agent | Audience | Artifacts | Gate Out | Adversarial Reviewer |
|-------|-------|----------|-----------|----------|---------------------|
| PrePlan | Mary (Analyst) | small | brief, research, brainstorm | self-review | — |
| BusinessPlan | John (PM) + Sally (UX) | small | PRD, UX design | self-review | — |
| TechPlan | Winston (Architect) | small | architecture doc | self-review | — |
| *promotion* | — | small → medium | — | adversarial review (party mode) | cross-agent |
| DevProposal | John (PM) | medium | epics, stories, readiness | readiness-check | — |
| *promotion* | — | medium → large | — | stakeholder-approval | — |
| SprintPlan | Bob (SM) | large | sprint-status, story files | sprint-review | — |
| *promotion* | — | large → base | — | constitution-gate (Scribe) | — |
| Dev | Amelia (Dev) + Quinn (QA) | TargetProjects | code, tests | code-review | — |

#### Track Matrix

| Phase | full | feature | tech-change | hotfix | spike |
|-------|------|---------|-------------|--------|-------|
| PrePlan | Y | - | - | - | Y |
| BusinessPlan | Y | Y | - | - | - |
| TechPlan | Y | Y | Y | Y | - |
| small→medium review | Y | Y | Y | constitution-controlled | - |
| DevProposal | Y | Y | constitution-controlled | - | - |
| medium→large | Y | Y | constitution-controlled | - | - |
| SprintPlan | Y | Y | Y | - | - |
| large→base | Y | Y | Y | Y | - |
| Dev | Y | Y | Y | Y | - |

#### Cross-Agent Adversarial Review Pattern (Party Mode)

All adversarial reviews use party mode — multi-agent group discussion, not single reviewer.

| Artifact | Lead Reviewer | Party Mode Participants | Review Focus |
|----------|--------------|------------------------|--------------|
| Product Brief | John (PM) | John, Winston, Sally | Actionable? Buildable? User-centered? |
| PRD | Winston (Architect) | Winston, Mary, Sally | Buildable? Well-researched? UX-aligned? |
| UX Design | John (PM) | John, Winston, Mary | Serves requirements? Feasible? Grounded? |
| Architecture | John (PM) | John, Mary, Bob | Meets spec? Practical? Sprintable? |
| Epics & Stories | Winston (Architect) | Winston, Bob, Amelia | Buildable? Right-sized? Implementable? |

#### Branch Topology (Complete Model)

**Lens-work repo (planning artifacts):**

```
init-svc-foo-small-preplan      → PR → init-svc-foo-small
init-svc-foo-small-businessplan → PR → init-svc-foo-small
init-svc-foo-small-techplan     → PR → init-svc-foo-small
init-svc-foo-small              → PR → init-svc-foo-medium  (adversarial review, party mode)
init-svc-foo-medium-devproposal → PR → init-svc-foo-medium
init-svc-foo-medium             → PR → init-svc-foo-large   (stakeholder approval)
init-svc-foo-large-sprintplan   → PR → init-svc-foo-large
init-svc-foo-large              → PR → base                 (constitution gate)
```

**TargetProjects (code execution — GitFlow with Jira linkage):**

```
main (production)
└── release/{version} (release candidate, stabilization)
    └── develop (integration branch)
        ├── feature/PROJ-100 (epic branch, Jira epic ID)
        │   ├── feature/PROJ-101 → PR → feature/PROJ-100  (story)
        │   ├── feature/PROJ-102 → PR → feature/PROJ-100  (story)
        │   └── feature/PROJ-103 → PR → feature/PROJ-100  (story)
        │   feature/PROJ-100 → PR → develop
        │
        └── feature/PROJ-200 (another epic)
            └── ...

develop → PR → release/{version}
release/{version} → PR → main
```

**Four merge gates in target repos:**

1. **Story → Epic:** Amelia's code review (automated, fast)
2. **Epic → Develop:** Feature-complete review (does the epic work as a unit?)
3. **Develop → Release:** Release readiness (all epics for this release integrated)
4. **Release → Main:** Production gate (final sign-off)

**Isomorphism between planning and code review:**

| Lens-work (planning) | Target Repo (code) | Review scope |
|----------------------|-------------------|--------------|
| Phase → small | Story → Epic | IC self-review |
| Small → medium | Epic → Develop | Lead review |
| Medium → large | Develop → Release | Stakeholder/QA |
| Large → base | Release → Main | Production gate |

#### Audience Model (Resolved)

- **small** = IC creation work (where phases happen)
- **medium** = lead review (adversarial gate, party mode)
- **large** = stakeholder approval + sprint planning
- **base** = ready for execution (constitution-gated)

Sprint-plan is a PHASE within large, NOT a separate audience level. Four clean audience levels: small, medium, large, base.

#### Constitution Enforcement

Constitutions at each LENS layer (org, domain, service, repo) define:

- Which tracks are permitted
- Which gates can be skipped per track
- Whether adversarial review is required for specific tracks
- Whether stories are required even for lightweight tracks
- Inheritance is strictly **additive** — lower levels can only add requirements, never remove

Example:

```yaml
# domain-level constitution
tracks:
  hotfix:
    required_gates: [techplan-review]
    skip_gates: [adversarial-full]
    override_allowed: false
```

---

### Phase 3: First Principles Thinking

**Interactive Focus:** Identified three fundamental truths that lens-work must satisfy. Validated every mechanism against these truths. Discovered the structural enforcement principle and refined the LENS hierarchy.

#### Three Fundamental Truths

**FT1: "Planning artifacts must exist and be reviewed before code is written."**

Every mechanism should trace to:

- A) Ensuring artifacts get *created* (agent invocations, phase workflows)
- B) Ensuring artifacts get *reviewed* (audience promotions, adversarial reviews, gates)
- C) Ensuring code *can't start* until A and B are satisfied (readiness checks, constitution gates)

**FT2: "AI agents must work within disciplined constraints, not freestyle."**

- Each agent has a defined scope — what they can and cannot do
- Agents cannot self-promote their own work (creator != approver)
- Agent actions must be auditable (event log, git history)
- The execution pattern is prescribed, not improvised (branch conventions, commit patterns)
- Agents cannot skip or reorder phases without constitution authorization

**FT3: "Multi-service initiatives must have coordinated lifecycle governance."**

- A single coordination point exists for initiative-level planning
- Governance rules inherit through LENS layers (org → domain → service → repo)
- Track requirements are consistent across all services in an initiative
- Cross-service impacts are visible before execution begins
- Phase completion in one service is independent of another (no false coupling — unless initiator chooses coupling)

#### Mechanism Validation Against Fundamental Truths

| Mechanism | FT1 (artifacts reviewed) | FT2 (agent discipline) | FT3 (multi-svc governance) |
|-----------|-------------------------|----------------------|--------------------------|
| Named phases | Organizes creation | Constrains what agents do when | Coordinates sequence across services |
| Agent ownership | Right expertise creates | Agents can't freelance — each has a lane | Same agent works across service boundaries |
| Audience promotions | Gates review scope | Agents can't self-promote | Governance scales across services |
| Adversarial review (party mode) | Review isn't rubber-stamp | Agent output gets challenged by group | Cross-service consistency check |
| Branch-per-phase | PR coherence | Work is visible and auditable | Branch topology is consistent across initiatives |
| Two-speed branching | — | Constrains HOW agents do dev | — |
| Initiative tracks | Minimum artifact set | Agents can't skip phases | Track requirements span services |
| Constitution enforcement | Prevents skipping gates | External rules bind agents | Governance inheritance across LENS layers |
| Central planning repo | — | — | Essential — the coordination point |
| GitFlow in targets | — | Constrains dev execution pattern | — |

**All mechanisms are load-bearing.** Each traces to at least one fundamental truth.

#### Guarantee Sets

**FT1 Guarantees:**

- G1.1: For every track, a defined set of artifacts must exist before dev begins
- G1.2: Every artifact must be reviewed by a different expertise than created it (party mode)
- G1.3: The gate between planning completion and code execution must be enforceable, not advisory
- G1.4: Review evidence must be preserved (PR history, approval records)

**FT2 Guarantees:**

- G2.1: Each agent has a defined scope — what they can and cannot do
- G2.2: Agents cannot self-promote their own work (creator != approver)
- G2.3: Agent actions must be auditable (event log, git history)
- G2.4: The execution pattern is prescribed, not improvised
- G2.5: Agents cannot skip or reorder phases without constitution authorization

**FT3 Guarantees:**

- G3.1: A single coordination point exists for initiative-level planning (central lens-work repo)
- G3.2: Governance rules inherit through LENS layers (org → domain → service → repo), additive only
- G3.3: Track requirements are consistent across all services in an initiative
- G3.4: Cross-service impacts are visible before execution begins
- G3.5: Service coupling is determined by the initiator at the scope level where `/new-feature` is invoked

#### Design Principle: Structural Over Instructional Enforcement

**"Wherever possible, enforce constraints through structure (branches, gates, required files) rather than through instructions (prompts, documentation, conventions)."**

- Telling an agent "follow this branch convention" in a prompt is weak — the agent might drift
- Making Casey create the branch and hand it to the agent is strong — the agent works where it's placed
- Making Scribe block promotion until artifacts exist is strong — the agent can't skip what it can't bypass

#### Four-Level LENS Hierarchy

The full LENS hierarchy is four levels:

```
Org
└── Domain
    └── Service
        └── Repo
```

Initiative scope is determined by where `/new-feature` is invoked:

| Initiative Scope | Coordination Point | Coupling |
|-----------------|-------------------|----------|
| Repo | Lens-work repo, repo section | No coupling question |
| Service | Lens-work repo, service section | Initiator chooses repo coupling |
| Domain | Lens-work repo, domain section | Initiator chooses service coupling |
| Org | Lens-work repo, org section | Initiator chooses domain + service coupling |

Constitution inheritance follows the four-level chain with **additive resolution** — merge all levels, union of all requirements. No conflict resolution needed.

```yaml
resolved_constitution = merge(
  org_constitution,       # base requirements
  domain_constitution,    # + domain additions
  service_constitution,   # + service additions
  repo_constitution       # + repo additions
)
# merge() is always union, never subtraction
```

---

## Key Ideas Generated

### [Lifecycle #1]: Named-Phase Lifecycle with Agent Ownership

_Concept_: Replace numbered phases (p1-p4) with semantically named phases (PrePlan, BusinessPlan, TechPlan) each owned by a specific BMM agent (Mary, John, Winston). Commands become agent invocations, not phase numbers.
_Novelty_: Eliminates the "what does p2 mean?" problem entirely. Phase names are self-documenting and agent ownership creates clear accountability.

### [Lifecycle #2]: Audience-as-Promotion-Backbone

_Concept_: Audience levels (small → medium → large → base) become the primary progression axis. Phases happen within small. Promotion between audiences IS the review gate. Adversarial review at small→medium, DevProposal at medium→large, PBR/SprintPlan within large, constitution gate at large→base.
_Novelty_: Decouples "where work happens" (always in small) from "who reviews it" (audience promotions). Kills the size/audience/execution-lane confusion (original gap B) entirely.

### [Lifecycle #3]: Two-Speed Branch Model

_Concept_: Lens-work repo uses rich branch topology (phase branches within audiences, audience promotion PRs) because planning involves human-speed review gates. TargetProjects use GitFlow because AI execution compresses sprints to hours but still needs integration safety valves.
_Novelty_: Recognizes that AI-speed execution fundamentally changes what branch overhead means. Planning needs rich branching for human review. Code needs GitFlow for integration safety.

### [Lifecycle #4]: Story-as-Commit, Not Story-as-Branch (Revised → Jira-Linked GitFlow)

_Concept_: In target repos, stories are branches (`feature/{jira-storyid}`) that PR into epic branches (`feature/{jira-epicid}`). Epics merge to develop, develop to release, release to main. Jira IDs in branch names create automatic traceability.
_Novelty_: Revised from original "stories as commits" when Jira traceability and epic-level review coherence proved more valuable than minimizing branch overhead.

### [Lifecycle #5]: Initiative Tracks (Predefined Lifecycle Profiles)

_Concept_: The canonical lifecycle defines all possible phases. Each initiative selects a "track" that determines which phases are active. Standard tracks: full, feature, tech-change, hotfix, spike. Casey only creates branches for active phases. Compass routes to the correct starting agent.
_Novelty_: Resolves the "not every initiative needs every phase" problem without ad-hoc skipping. Makes the lifecycle contract both maximal (all possibilities defined) and minimal (each initiative only uses what it needs).

### [Lifecycle #6]: Central Planning Repo for Multi-Service Orchestration

_Concept_: ALL planning artifacts live in the central lens-work repo, regardless of initiative scope — even single-repo initiatives. Target repos are pure code. Avoids false positive security scans triggered by documentation content in code repos.
_Novelty_: A practical constraint (security scan false positives) drives an architectural simplification. No conditional "where do docs live?" logic needed.

### [Lifecycle #7]: Constitution-Enforced Track Requirements

_Concept_: Constitutions at each LENS layer (org, domain, service, repo) define which tracks are permitted and what phase/gate minimums apply. Scribe validates before Casey creates branches.
_Novelty_: Transforms tracks from developer preference into organizational policy. Governance answers "who decides what gets skipped?" — not the individual, the constitution.

### [Lifecycle #8]: Initiative Scope Determines Service Coupling

_Concept_: `/new-feature` can be invoked at repo, service, domain, or org level. The scope determines whether coupling questions exist. The initiator (not the system) decides coupling mode for multi-service/multi-repo initiatives.
_Novelty_: Avoids over-engineering governance for a decision that the human is best positioned to make. The system provides the mechanism, the human provides the judgment.

### [Lifecycle #9]: Four-Level LENS Hierarchy with Scope-Determined Coordination

_Concept_: The LENS hierarchy is org → domain → service → repo (four levels, not three). Initiative scope is determined by invocation level. Constitution inheritance follows the full chain with additive resolution.
_Novelty_: Corrects the collapsed three-level model. Makes repo an explicit governance layer, which matters because a single service often spans multiple repos with different conventions.

### [Lifecycle #10]: All Planning Artifacts Live in Central Lens-Work Repo

_Concept_: Regardless of initiative scope, all planning artifacts live in the lens-work repo. Never in target code repos. Eliminates conditional logic, provides consistency, avoids false positive security scans.
_Novelty_: Practical constraint drives architectural simplification. One place to look. One branch topology pattern. Casey needs no conditional "where do docs go?" logic.

### [Lifecycle #11]: Additive Constitution Inheritance

_Concept_: Constitution inheritance through org → domain → service → repo is strictly additive. Lower levels can only add requirements, never remove them. Resolution is union of all levels — no conflict resolution needed.
_Novelty_: Simplest possible inheritance model. No ambiguity about overrides. Scribe's validation becomes straightforward: merge all levels, check union of requirements.

### [Lifecycle #12]: Target Project Branch Convention with Jira Linkage

_Concept_: Story branches follow `feature/{jira-storyid}`, merging to `feature/{jira-epicid}` (epic branch). Branch names map directly to Jira tracking, creating automatic git ↔ project management traceability.
_Novelty_: Makes the Jira link structural (in the branch name) rather than ceremonial (in commit messages that might be forgotten). Epic branches provide feature-coherent review units.

### [Lifecycle #13]: GitFlow Target Project Branching

_Concept_: Target repos follow GitFlow: story → epic → develop → release → main. Four merge gates mirror the four audience levels in lens-work. The two systems are isomorphic — same escalation pattern, different content.
_Novelty_: The isomorphism between planning audience levels and code merge gates wasn't designed — it emerged from the analysis. Both systems have four escalating review scopes. This suggests the architecture is internally consistent.

### [Lifecycle #14]: Adversarial Reviews Use Party Mode

_Concept_: Every adversarial review at audience promotions invokes party mode — multi-agent group discussion. The cross-agent reviewer is the lead, but other relevant agents participate. A PRD review isn't just Winston — it's Winston, Mary, and Sally debating from their perspectives.
_Novelty_: Transforms review from single-expert check to multi-perspective debate. Strengthens the structural enforcement principle — party mode is harder to bypass than a single reviewer's judgment. Constitution can add participants per domain/service (additive).

---

## Session Summary

### Techniques Completed

- **Assumption Reversal (full):** 6 assumptions challenged, all resolved into design decisions
- **Morphological Analysis (full):** Complete parameter grid built, 4 conflict questions resolved, branch topology mapped
- **First Principles Thinking (full):** 3 fundamental truths identified, all mechanisms validated, design principle established

### Key Architectural Decisions

1. Named phases with agent ownership replace numbered phases
2. Four audience levels (small, medium, large, base) as promotion backbone
3. Two-speed model: rich branching for planning, GitFlow for code execution
4. Five initiative tracks: full, feature, tech-change, hotfix, spike
5. Constitution-enforced governance with additive inheritance across 4 LENS levels
6. All planning in central repo, code in target repos (never mixed)
7. Party mode for all adversarial reviews
8. Structural enforcement over instructional enforcement
9. Initiative scope and coupling determined by invoker, not system
10. GitFlow with Jira-linked branch names in target repos

### Creative Facilitation Narrative

This session demonstrated exceptional pre-analysis from the facilitator, who arrived with a comprehensive gap taxonomy (7 gaps) and prioritized improvement list (5 items). Rather than generic brainstorming, the session became a structured architectural design workshop.

The Assumption Reversal technique proved particularly powerful — the discovery that AI-speed execution invalidates enterprise branching patterns was a genuine breakthrough that none of the original gap analysis had identified. This was later revised when Jira traceability requirements brought epic branches back in a GitFlow model.

The Morphological Analysis grid served as a verification tool, confirming that design decisions fit together as a coherent system and surfacing the cross-agent adversarial review pattern (with party mode) as an elegant solution to review orchestration.

First Principles Thinking validated every mechanism against three fundamental truths and revealed the striking isomorphism between planning audience levels and code merge gates — a sign of internal architectural consistency that wasn't deliberately designed.

### Open Questions for Future Sessions

- Sally (UX Designer) and Quinn (QA) — exact integration points in the lifecycle
- Paige (Technical Writer) — documentation as phase or cross-cutting concern?
- Barry (Quick Flow Solo Dev) — alternative to full Amelia+Bob execution?
- Bob/SM bridging lens-work state and TargetProject execution tracking
- Constitution schema design — full field specification
- Party mode participant lists — fixed in lifecycle or constitution-additive?
- Event log schema and structured queryability design
- State migration strategy from current lens-work to new architecture

### Deliverable

See `lifecycle.yaml` for the canonical lifecycle contract derived from this session.
