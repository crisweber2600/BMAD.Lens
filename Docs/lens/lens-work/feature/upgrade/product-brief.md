---
repo: bmad.lens.src
initiative: upgrade-cjki9q
initiative_name: "Lens-Work Module Architecture Upgrade"
layer: feature
domain: Lens
service: lens-work
phase: preplan
agent: Mary (Analyst)
generated_at: "2026-02-24T00:00:00Z"
source: brainstorming-session-2026-02-23.md
---

# Product Brief: Lens-Work Module Architecture Upgrade

## 1. Problem Statement

The lens-work BMAD module — the command-driven workbench that orchestrates phase-aware lifecycle governance for software initiatives — has accumulated **seven critical architectural gaps** that undermine its core value proposition:

| Gap | Description | Impact |
|-----|-------------|--------|
| **A. Competing Lifecycles** | Multiple lifecycle models coexist (numbered phases p1-p4, named phases, v1 vs v2 contracts) with no single canonical source of truth | Agents and workflows reference different phase models, causing routing errors and confusion |
| **B. Muddled Size/Audience** | "size" (small/medium/large) conflates execution lane, review audience, and branch topology into one overloaded concept | Users can't distinguish "where work happens" from "who reviews it" |
| **C. Path Inconsistencies** | Output paths, docs paths, and artifact locations vary across workflows with no normalization | Artifacts land in unpredictable locations; cross-workflow references break |
| **D. State Drift** | state.yaml schema differs from initiative config schema; dual-write contract not enforced | State and config diverge silently, causing stale data in status displays |
| **E. Stub Prompts** | Phase prompts reference outdated phase names and branching patterns | Agents receive incorrect instructions, producing misaligned artifacts |
| **F. Skeleton Phases** | Several phase workflows are stubs with no executable logic | Users hit dead ends when invoking phases that appear available |
| **G. Dangerous Auto-Advance** | Some workflows auto-advance to next phase without review gates | Violates FT1 (artifacts must be reviewed before code) — the system's fundamental guarantee |

These gaps emerged organically as the module evolved from a simple phase router to a multi-agent lifecycle orchestrator. The current state is functional but fragile — it works when followed carefully but provides no structural enforcement of its own rules.

## 2. Vision

**Transform lens-work from a loosely-coupled collection of phase scripts into a structurally-enforced lifecycle engine** where:

- Every constraint is enforced through structure (branches, gates, required files), not instructions
- Phase progression is governed by a single canonical lifecycle contract
- AI agents work within disciplined constraints with clear ownership boundaries
- Multi-service initiatives have coordinated governance through constitution inheritance
- The system is internally consistent — planning audience levels mirror code review escalation

The upgraded lens-work module will be the authoritative orchestrator for BMAD initiatives, from first brainstorm to production deployment.

## 3. Scope

### In Scope

- **Lifecycle Contract v2:** Single canonical source of truth (`lifecycle.yaml`) defining phases, audiences, tracks, gates, and agent ownership
- **Named-Phase Architecture:** Replace numbered phases (p1-p4) with semantically named phases: PrePlan, BusinessPlan, TechPlan, DevProposal, SprintPlan
- **Agent Ownership Model:** Each phase owned by a specific BMM agent (Mary, John+Sally, Winston, John, Bob)
- **Audience-as-Promotion-Backbone:** Four clean audience levels (small → medium → large → base) with audience promotions as the primary review mechanism
- **Initiative Tracks:** Five predefined lifecycle profiles (full, feature, tech-change, hotfix, spike) that determine which phases are active per initiative
- **Two-Speed Branch Model:** Rich branch topology for planning in lens-work repo; GitFlow for code execution in TargetProjects
- **Constitution-Enforced Governance:** Additive inheritance through org → domain → service → repo hierarchy; lower levels can only add requirements
- **Central Planning Repo:** All planning artifacts live in lens-work repo; target repos are pure code
- **Adversarial Reviews with Party Mode:** Multi-agent group discussion at every audience promotion gate
- **Path Normalization:** Consistent `docs/{domain}/{service}/repo/{repo}/feature/{feature}` hierarchy
- **State Schema Alignment:** Unified state.yaml and initiative config with enforced dual-write contract
- **Structural Enforcement:** Replace instructional enforcement (prompts/docs) with structural enforcement (branches/gates/required files) wherever possible

### Out of Scope (Deferred)

- Jira integration and ticket-linked GitFlow branches in TargetProjects
- Full constitution schema specification (beyond additive inheritance model)
- Event log structured queryability and dashboard design
- Sally (UX Designer) and Quinn (QA) exact lifecycle integration points
- Paige (Technical Writer) cross-cutting documentation workflow
- Barry (Quick Flow Solo Dev) alternative execution path
- State migration tooling from current lens-work to v2 architecture
- Multi-org governance (org-level LENS hierarchy)

## 4. Key Architectural Decisions

### Decision 1: Named Phases with Agent Ownership

Replace numbered phases with semantically named phases, each owned by a specific BMM agent.

| Phase | Agent | Audience | Key Artifacts |
|-------|-------|----------|---------------|
| PrePlan | Mary (Analyst) | small | brief, research, brainstorm |
| BusinessPlan | John (PM) + Sally (UX) | small | PRD, UX design |
| TechPlan | Winston (Architect) | small | architecture doc |
| DevProposal | John (PM) | medium | epics, stories, readiness |
| SprintPlan | Bob (SM) | large | sprint-status, story files |
| Dev | Amelia (Dev) + Quinn (QA) | TargetProjects | code, tests |

**Rationale:** Phase names become self-documenting. Agent ownership creates clear accountability. Commands become agent invocations, not phase numbers.

### Decision 2: Audience-as-Promotion-Backbone

Four audience levels become the primary progression axis:

- **small** = IC creation work (where phases happen)
- **medium** = lead review (adversarial gate, party mode)
- **large** = stakeholder approval + sprint planning
- **base** = ready for execution (constitution-gated)

**Rationale:** Decouples "where work happens" (always in small) from "who reviews it" (audience promotions). Eliminates the size/audience/execution-lane confusion.

### Decision 3: Two-Speed Branch Model

- **Lens-work repo:** Rich branch topology (phase branches within audiences, audience promotion PRs) for human-speed review gates
- **TargetProjects:** GitFlow (story → epic → develop → release → main) for AI-speed execution with integration safety

**Rationale:** AI-speed execution fundamentally changes what branch overhead means. Planning needs rich branching for human review. Code needs GitFlow for integration safety.

### Decision 4: Initiative Tracks

Five predefined lifecycle profiles:

| Track | Active Phases | Use Case |
|-------|---------------|----------|
| full | All 5 | Greenfield, significant impact |
| feature | BusinessPlan → SprintPlan | Known requirements, existing patterns |
| tech-change | TechPlan → SprintPlan | Refactoring, tech debt, architecture |
| hotfix | TechPlan only | Production issues, critical bugs |
| spike | PrePlan only | Exploration, feasibility, POC |

**Rationale:** Not every initiative needs every phase. Tracks make the lifecycle contract both maximal (all possibilities defined) and minimal (each initiative uses what it needs).

### Decision 5: Constitution-Enforced Governance

Governance rules inherit through the four-level LENS hierarchy (org → domain → service → repo) with **strictly additive** resolution:

```yaml
resolved_constitution = merge(
  org_constitution,       # base requirements
  domain_constitution,    # + domain additions
  service_constitution,   # + service additions
  repo_constitution       # + repo additions
)
# merge() is always union, never subtraction
```

**Rationale:** Simplest possible inheritance model. No ambiguity about overrides. Scribe's validation becomes straightforward.

### Decision 6: Structural Over Instructional Enforcement

> "Wherever possible, enforce constraints through structure (branches, gates, required files) rather than through instructions (prompts, documentation, conventions)."

- Casey creates the branch → agent works where it's placed (strong)
- Scribe blocks promotion until artifacts exist → agent can't skip what it can't bypass (strong)
- Telling an agent "follow this convention" in a prompt → agent might drift (weak)

### Decision 7: Party Mode Adversarial Reviews

Every adversarial review at audience promotions invokes party mode — multi-agent group discussion:

| Artifact | Lead Reviewer | Participants | Focus |
|----------|--------------|-------------|-------|
| Product Brief | John (PM) | John, Winston, Sally | Actionable? Buildable? User-centered? |
| PRD | Winston (Architect) | Winston, Mary, Sally | Buildable? Well-researched? UX-aligned? |
| Architecture | John (PM) | John, Mary, Bob | Meets spec? Practical? Sprintable? |
| Epics & Stories | Winston (Architect) | Winston, Bob, Amelia | Buildable? Right-sized? Implementable? |

## 5. Three Fundamental Truths

Every mechanism in the upgraded architecture traces to at least one of these non-negotiable truths:

**FT1: "Planning artifacts must exist and be reviewed before code is written."**
- Ensures artifacts get created (agent invocations, phase workflows)
- Ensures artifacts get reviewed (audience promotions, adversarial reviews, gates)
- Ensures code can't start until satisfied (readiness checks, constitution gates)

**FT2: "AI agents must work within disciplined constraints, not freestyle."**
- Each agent has defined scope
- Agents cannot self-promote their own work (creator ≠ approver)
- Actions must be auditable (event log, git history)
- Pattern is prescribed, not improvised

**FT3: "Multi-service initiatives must have coordinated lifecycle governance."**
- Single coordination point exists (central lens-work repo)
- Governance rules inherit through LENS layers (additive only)
- Track requirements consistent across services
- Cross-service impacts visible before execution

## 6. Success Criteria

| Criterion | Measurement |
|-----------|-------------|
| Single lifecycle contract | One `lifecycle.yaml` referenced by all workflows — no competing models |
| Named phases everywhere | Zero references to p1/p2/p3/p4 in active workflow code |
| Audience model clarity | size/audience/execution-lane concepts fully separated |
| Path consistency | All artifact paths resolve from initiative config `docs` block |
| State alignment | state.yaml and initiative config schemas match; dual-write enforced |
| Executable phases | All 5 phase routers produce artifacts (no stub workflows) |
| No auto-advance | Every phase transition requires explicit PR review gate |
| Constitution validation | Scribe validates track permissions before branch creation |
| Party mode reviews | Adversarial reviews at every audience promotion invoke multi-agent discussion |
| Branch topology correct | Branch names follow `{initiative_root}-{audience}-{phase}` pattern consistently |

## 7. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Migration complexity from v1 to v2 lifecycle | High | Medium | Parallel operation period; v1 workflows continue working during transition |
| Constitution schema underspecification | Medium | High | Start with minimal schema (track permissions only); extend incrementally |
| Party mode review quality | Medium | Medium | Define specific review questions per artifact type; constitution can add participants |
| Branch name length limits | Low | Low | Monitor; initiative IDs use 6-char random suffix to keep names manageable |
| Stash/state loss during phase transitions | Low | High | Event log provides recovery audit trail; state reconstruction from git history |

## 8. Dependencies

| Dependency | Required For | Status |
|------------|-------------|--------|
| BMM module (core agents) | Phase execution (Mary, John, Winston, Bob, Amelia) | Available |
| CIS module | Brainstorming, research, party mode | Available |
| TEA module | Test planning integration | Available (optional) |
| Core module | BMAD infrastructure, editorial review | Available |
| lifecycle.yaml | Canonical lifecycle contract | Exists, needs v2 update |
| Constitution schema | Governance enforcement | Needs design |

## 9. Stakeholders

| Role | Person/Agent | Interest |
|------|-------------|----------|
| Product Owner | Cris Weber | Overall direction, priority decisions |
| Architect | Winston | Technical feasibility, branch topology |
| Analyst | Mary | Requirements completeness, gap coverage |
| Scrum Master | Bob | Sprint planning integration, story sizing |
| Developer | Amelia | Implementation feasibility, dev workflow |

## 10. Recommended Next Steps

1. **BusinessPlan Phase** (`/businessplan`): John (PM) creates PRD with detailed requirements for each architectural decision
2. **TechPlan Phase** (`/tech-plan`): Winston (Architect) designs the implementation architecture — lifecycle.yaml schema, state migration, branch topology implementation
3. **DevProposal Phase** (`/plan`): John creates epics and stories for implementation
4. **SprintPlan Phase** (`/sprintplan`): Bob plans sprint execution with story prioritization
5. **Dev Phase** (`/dev`): Amelia implements the upgrade in bmad.lens.src

---

*Generated during PrePlan phase by Mary (Analyst) for initiative upgrade-cjki9q.*
*Source: Brainstorming session 2026-02-23 — 14 lifecycle ideas, 10 architectural decisions, 3 fundamental truths.*
