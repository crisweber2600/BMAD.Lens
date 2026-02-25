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

| Gap | Priority | Depends On | Description | Impact |
|-----|----------|-----------|-------------|--------|
| **G. Dangerous Auto-Advance** | P0 — Safety | None | Some workflows auto-advance to next phase without review gates | Violates FT1 (artifacts must be reviewed before code) — the system's fundamental guarantee |
| **A. Competing Lifecycles** | P1 — Foundation | None | Multiple lifecycle models coexist (numbered phases p1-p4, named phases, v1 vs v2 contracts) with no single canonical source of truth | Agents and workflows reference different phase models, causing routing errors and confusion |
| **B. Muddled Size/Audience** | P1 — Foundation | A | "size" (small/medium/large) conflates execution lane, review audience, and branch topology into one overloaded concept | Users can't distinguish "where work happens" from "who reviews it" |
| **D. State Drift** | P2 — Structural | A | state.yaml schema differs from initiative config schema; dual-write contract not enforced | State and config diverge silently, causing stale data in status displays |
| **C. Path Inconsistencies** | P2 — Structural | A, B | Output paths, docs paths, and artifact locations vary across workflows with no normalization | Artifacts land in unpredictable locations; cross-workflow references break |
| **E. Stub Prompts** | P3 — Content | A, B | Phase prompts reference outdated phase names and branching patterns | Agents receive incorrect instructions, producing misaligned artifacts |
| **F. Skeleton Phases** | P3 — Content | A, B, D | Several phase workflows are stubs with no executable logic | Users hit dead ends when invoking phases that appear available |

**Recommended build order:** G (safety gate) → A+B (foundation) → D+C (structural) → E+F (content). Gap G is the only P0 because it directly violates FT1. Gaps A and B are foundational — everything else depends on resolving the lifecycle model and audience semantics first. Gaps D and C are structural plumbing that can proceed in parallel once the foundation is set. E and F are content updates that should come last since they depend on all prior decisions being stable.

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
- **UX Touchpoints:** Placeholder integration points for Sally (UX Designer) at BusinessPlan phase and review gates; Quinn (QA) placeholder at DevProposal readiness checks
- **Minimum Constitution Schema:** Gate enforcement fields (track permissions, required artifacts per phase, required reviewers) defined as the enforceable subset; full schema specification deferred to incremental extension

### Out of Scope (Deferred)

- Jira integration and ticket-linked GitFlow branches in TargetProjects
- Event log structured queryability and dashboard design
- Quinn (QA) detailed test-phase workflow specification (placeholder touchpoints included in-scope)
- Paige (Technical Writer) cross-cutting documentation workflow
- Barry (Quick Flow Solo Dev) alternative execution path
- State migration tooling from current lens-work to v2 architecture
- Multi-org governance (org-level LENS hierarchy)

## 4. Key Architectural Decisions

### Decision 1: Named Phases with Agent Ownership

Replace numbered phases with semantically named phases, each owned by a specific BMM agent.

| Phase | Command | Agent | Audience | Key Artifacts | UX Touchpoint |
|-------|---------|-------|----------|---------------|---------------|
| PrePlan | `/preplan` | Mary (Analyst) | small | brief, research, brainstorm | — |
| BusinessPlan | `/businessplan` | John (PM) + Sally (UX) | small | PRD, UX design | Sally: UX review gate on PRD |
| TechPlan | `/techplan` | Winston (Architect) | small | architecture doc | — |
| DevProposal | `/devproposal` | John (PM) | medium | epics, stories, readiness | Quinn: readiness checklist review |
| SprintPlan | `/sprintplan` | Bob (SM) | large | sprint-status, story files | — |
| Dev | `/dev` | Amelia (Dev) + Quinn (QA) | TargetProjects | code, tests | Quinn: test execution |

**Command naming convention:** All phase commands use lowercase concatenation with no hyphens or separators (e.g., `/businessplan`, `/techplan`, `/devproposal`). This pattern is predictable: take the PascalCase phase name, lowercase it, prefix with `/`.

**Rationale:** Phase names become self-documenting. Agent ownership creates clear accountability. Commands become agent invocations, not phase numbers.

### Decision 2: Audience-as-Promotion-Backbone

Four audience levels become the primary progression axis:

- **small** = IC creation work (where phases happen)
- **medium** = lead review (adversarial gate, party mode)
- **large** = stakeholder approval + sprint planning
- **base** = ready for execution (constitution-gated)

**Rationale:** Decouples "where work happens" (always in small) from "who reviews it" (audience promotions). Eliminates the size/audience/execution-lane confusion.

### Decision 3: Two-Speed Branch Model

- **Lens-work repo:** Rich branch topology for human-speed review gates:
  - **Audience branches** (`{root}-{audience}`) — long-lived; one per audience level per initiative
  - **Phase branches** (`{root}-{audience}-{phase}`) — created from audience branch when phase starts; PR'd back to audience branch when phase completes
  - **Workflow branches** (`{root}-{audience}-{phase}-{workflow}`) — created from phase branch per workflow; PR'd back to phase branch when workflow completes
  - **Audience promotion** — PR from one audience branch to the next (e.g., `{root}-small` → `{root}-medium`) with adversarial review gate
- **TargetProjects:** GitFlow (story → epic → develop → release → main) for AI-speed execution with integration safety

**Concrete example (this initiative):**
```
lens-lens-work-upgrade-cjki9q                    # initiative root (= base)
lens-lens-work-upgrade-cjki9q-small               # audience branch
lens-lens-work-upgrade-cjki9q-small-preplan       # phase branch (current)
lens-lens-work-upgrade-cjki9q-small-preplan-brief # workflow branch (within phase)
lens-lens-work-upgrade-cjki9q-medium              # next audience (promotion target)
lens-lens-work-upgrade-cjki9q-large               # stakeholder audience
```

**Cross-repo handoff (Lens → TargetProjects):** When SprintPlan completes in the lens-work repo and Dev begins in TargetProjects, the @lens agent:
1. Creates a GitFlow feature branch in the target repo named after the initiative + story
2. Injects a `planning-context.yaml` file linking back to the lens-work planning artifacts
3. Constitution enforcement crosses the repo boundary via the planning-context link — the @lens agent validates readiness before creating target branches
4. Developers reference planning artifacts via the link; updates to planning require switching back to the lens-work repo

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

**Minimum Constitution Schema (Gate Enforcement Fields):**

```yaml
# Minimum enforceable fields — required for structural gate enforcement
constitution:
  track_permissions:           # Which tracks are allowed at this LENS level
    allowed: [full, feature, tech-change, hotfix, spike]
  required_artifacts:          # Artifacts that must exist before phase completion
    preplan: [product-brief]
    businessplan: [prd]
    techplan: [architecture]
    devproposal: [epics, stories, implementation-readiness]
    sprintplan: [sprint-status]
  required_reviewers:          # Minimum reviewers per audience promotion
    small_to_medium: [pm, architect]
    medium_to_large: [po, architect]
    large_to_base: [po]
  additional_review_participants:  # Extra party-mode participants (additive per level)
    product_brief: [pm, architect, ux-designer]
    prd: [architect, analyst, ux-designer]
    architecture: [pm, analyst, sm]
    epics_stories: [architect, sm, dev]
```

Full schema specification (custom validation rules, conditional requirements, override policies) is deferred for incremental extension. The above fields are sufficient for @lens to enforce all gates defined in this brief.

**Rationale:** Simplest possible inheritance model. No ambiguity about overrides. The @lens agent's validation becomes straightforward because the enforceable fields are concrete and finite.

### Decision 6: Structural Over Instructional Enforcement

> "Wherever possible, enforce constraints through structure (branches, gates, required files) rather than through instructions (prompts, documentation, conventions)."

- The @lens agent creates the branch → owning agent works where it's placed (strong)
- The @lens agent blocks promotion until required artifacts exist → owning agent can't skip what it can't bypass (strong)
- Telling an agent "follow this convention" in a prompt → agent might drift (weak)

**Enforcement actor:** All structural enforcement is performed by the single `@lens` agent, which replaces the previous multi-agent model (Casey, Compass, Tracey, Scout, Scribe). The @lens agent combines branch orchestration, state management, constitution validation, and gate enforcement into one unified actor.

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
| Constitution validation | @lens agent validates track permissions before branch creation |
| Party mode reviews | Adversarial reviews at every audience promotion invoke multi-agent discussion |
| Branch topology correct | Branch names follow three-tier pattern: `{root}-{audience}` (long-lived), `{root}-{audience}-{phase}` (phase work), `{root}-{audience}-{phase}-{workflow}` (individual workflows) |

## 7. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Scope magnitude (12 in-scope items, 7 gaps) | High | High | Phased delivery: P0 safety gates → P1 foundation → P2 structural → P3 content. MVP = G+A+B (auto-advance fix + lifecycle contract + audience model) |
| Migration complexity from v1 to v2 lifecycle | High | Medium | Parallel operation period; v1 workflows continue working during transition |
| Constitution schema underspecification | Medium | High | Minimum schema defined (Decision 5); extend incrementally per LENS level |
| Two-repo context switching cognitive load | Medium | Medium | @lens agent automates handoff; planning-context.yaml provides cross-repo link |
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

1. **BusinessPlan Phase** (`/businessplan`): John (PM) creates PRD with detailed requirements for each architectural decision; Sally (UX) provides UX review on PRD
2. **TechPlan Phase** (`/techplan`): Winston (Architect) designs the implementation architecture — lifecycle.yaml schema, state migration, branch topology implementation
3. **DevProposal Phase** (`/devproposal`): John creates epics and stories for implementation; Quinn (QA) reviews readiness checklist
4. **SprintPlan Phase** (`/sprintplan`): Bob plans sprint execution with story prioritization
5. **Dev Phase** (`/dev`): Amelia implements the upgrade in bmad.lens.src

---

*Generated during PrePlan phase by Mary (Analyst) for initiative upgrade-cjki9q.*
*Source: Brainstorming session 2026-02-23 — 14 lifecycle ideas, 10 architectural decisions, 3 fundamental truths.*

---

## Appendix A: Adversarial Review Findings (PrePlan Gate)

**Review Date:** 2026-02-24 | **Mode:** Party Mode | **Artifact:** Product Brief

| Reviewer | Verdict | Key Conditions |
|----------|---------|----------------|
| John (PM) — Lead | Approve with Conditions | Sally/Quinn scope, agent refs, branch naming, gap ordering, constitution schema |
| Winston (Architect) | Approve with Conditions | Branch topology, constitution enforcement, promotion bottleneck, cross-repo handoff, track semantics |
| Sally (UX Designer) | Request Changes | Progressive disclosure, gate feedback, command naming, UX integration, two-repo journey |

**Conditions addressed in this revision:**
1. Branch topology reconciled — three-tier model documented with concrete example (Decision 3)
2. Casey/Scribe/Compass references replaced with @lens agent (Decision 6)
3. Sally/Quinn scope resolved — UX touchpoints added in-scope as placeholders; removed from Out of Scope (Decision 1, Scope)
4. Gap dependency ordering added with P0-P3 priority and build sequence (Section 1)
5. Minimum constitution schema defined with concrete gate enforcement fields (Decision 5)
6. Command naming convention standardized — lowercase concatenation, no hyphens (Decision 1)

**Deferred to BusinessPlan (tracked as known UX debt):**
- Progressive disclosure / onboarding model (Sally #1)
- Gate feedback contract and pre-gate visibility (Sally #2)
- Audience label naming evaluation — small/medium/large vs semantic names (Sally #3)
- Party mode feedback format and iteration cycle (Sally #8)
- Resolved-constitution transparency view for users (Sally #7)
