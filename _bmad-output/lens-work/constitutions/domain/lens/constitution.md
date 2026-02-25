---
layer: domain
name: "Lens"
created_by: "Cris Weber"
ratification_date: "2026-02-24"
last_amended: null
amendment_count: 0
inherits_from: org
---

# Domain Constitution: Lens

**Inherits From:** Org constitution (resolved via `/resolve`)
**Version:** 2.0.0
**Ratified:** 2026-02-24
**Last Amended:** —

---

## Preamble

This constitution establishes the governance principles for all software development within the Lens domain. These articles apply to every service and repo within this domain, including the lens-work orchestration layer and all target projects under the Lens umbrella.

We hold these principles to ensure that AI-assisted development remains disciplined, auditable, and structurally enforced — not merely instructed. Every initiative within the Lens domain must produce reviewed artifacts before code is written, operate within clear agent boundaries, and follow the canonical lifecycle contract.

This constitution inherits all articles from the Org Constitution and adds domain-specific governance derived from the architectural decisions ratified in the brainstorming session of 2026-02-23.

---

## Track & Gate Governance

### Permitted Tracks

Tracks allowed for initiatives within the Lens domain:

```yaml
permitted_tracks: [full, feature, tech-change, hotfix, spike]
```

### Required Gates

Gates that ALL initiatives in the Lens domain must pass, regardless of track:

```yaml
required_gates: [constitution-check]
```

### Additional Review Participants

Extra participants added to adversarial reviews for this domain (additive — accumulates with Org):

```yaml
additional_review_participants:
  product_brief: [pm, architect, ux-designer]
  prd: [architect, analyst, ux-designer]
  ux_design: [pm, architect, analyst]
  architecture: [pm, analyst, sm]
  epics_stories: [architect, sm, dev]
```

---

## Articles

### Article I: Structural Enforcement Over Instructional Enforcement (NON-NEGOTIABLE)

Wherever possible, constraints within the Lens domain SHALL be enforced through structure — branches, gates, required files, and automated checks — rather than through instructions, prompts, documentation, or verbal conventions.

**Rationale:** AI agents may drift from instructional guidance. Structural enforcement (e.g., Casey creating branches, Scribe blocking promotion until artifacts exist) is deterministic and auditable. This is the foundational design principle derived from First Principles Thinking (FT2: "AI agents must work within disciplined constraints, not freestyle").

**Evidence Required:** Every new workflow or gate must demonstrate that its primary constraint mechanism is structural. Instructional fallbacks are acceptable only when structural enforcement is technically infeasible, and must be documented as technical debt.

---

### Article II: All Development Work in Target Projects (NON-NEGOTIABLE)

All code, tests, and executable development artifacts SHALL reside exclusively within `TargetProjects/lens/` (specifically `TargetProjects/lens/lens-work/bmad.lens.src` for the lens-work module source). No code SHALL exist in the planning artifact tree (`docs/`, `_bmad-output/`).

Only BMAD planning documents (product briefs, PRDs, architecture docs, sprint plans, constitutions, and other non-executable governance artifacts) SHALL exist outside of `TargetProjects/`.

**Rationale:** Strict separation of planning artifacts from code prevents false-positive security scans, maintains clean repository boundaries, and ensures the two-speed branch model (rich planning branches vs. GitFlow code branches) operates without cross-contamination.

**Evidence Required:** Repository structure audit confirms no executable code outside `TargetProjects/`. Planning artifacts confirmed in `docs/{domain}/{service}/` hierarchy.

---

### Article III: Artifacts Before Code (NON-NEGOTIABLE)

No code execution phase (Dev) SHALL begin until all required planning artifacts for the initiative's track have been created, reviewed, and promoted through the appropriate audience gates.

**Rationale:** This is Fundamental Truth #1 from the architectural session: "Planning artifacts must exist and be reviewed before code is written." The three guarantees are: (G1.1) defined artifact sets per track, (G1.2) review by different expertise than creation, (G1.3) enforceable gates between planning and execution.

**Evidence Required:** Constitution gate at large→base must verify all required artifacts exist. Casey must refuse to create dev branches without gate clearance from Scribe.

---

### Article IV: Agent Scope Boundaries

Each BMM agent operating within the Lens domain SHALL work only within their defined phase ownership. Agents SHALL NOT create artifacts outside their assigned phases, self-promote their own work for review, or skip phases without constitution authorization.

| Phase | Owning Agent(s) |
|-------|-----------------|
| PrePlan | Mary (Analyst) |
| BusinessPlan | John (PM) + Sally (UX) |
| TechPlan | Winston (Architect) |
| DevProposal | John (PM) |
| SprintPlan | Bob (SM) |
| Dev | Amelia (Dev) + Quinn (QA) |

**Rationale:** Fundamental Truth #2: "AI agents must work within disciplined constraints, not freestyle." Agent scope boundaries ensure accountability and prevent the "AI doing everything at once" anti-pattern.

**Evidence Required:** Workflow routing must direct commands to the correct owning agent. Event log must record which agent produced each artifact. Cross-agent adversarial review (party mode) must involve agents from outside the creating phase.

---

### Article V: Canonical Lifecycle Contract

All initiatives within the Lens domain SHALL follow the canonical lifecycle contract defined in `lifecycle.yaml`. The lifecycle defines: named phases, audience levels, track matrices, gate requirements, and agent ownership.

No workflow, prompt, or agent instruction SHALL reference alternative lifecycle models (numbered phases, legacy v1 contracts, ad-hoc phase ordering). All lifecycle references SHALL resolve to the single canonical contract.

**Rationale:** Gap A ("Competing Lifecycles") was the root cause of routing errors, confusion, and inconsistent behavior. A single source of truth eliminates these entirely.

**Evidence Required:** Grep audit confirms zero references to p1/p2/p3/p4 phase naming. All workflow routing resolves through lifecycle.yaml. State.yaml phase fields use canonical phase names (preplan, businessplan, techplan, devproposal, sprintplan, dev).

---

### Article VI: Audience Promotion as Review Gate

Audience promotions (small→medium, medium→large, large→base) SHALL be the primary review mechanism within the Lens domain. Each promotion SHALL require:

- **small→medium:** Adversarial review via party mode (multi-agent group discussion)
- **medium→large:** Stakeholder approval
- **large→base:** Constitution gate (Scribe validation)

Phase work SHALL occur within the `small` audience level. Promotions SHALL be the only mechanism for escalating review scope.

**Rationale:** The audience-as-promotion-backbone model decouples "where work happens" from "who reviews it," resolving Gap B ("Muddled Size/Audience"). The four audience levels mirror the four code merge gates in target repos, creating internal architectural consistency.

**Evidence Required:** Branch topology follows `{init}-{audience}-{phase}` pattern. PR targets for phase branches are always the corresponding audience branch. Promotion PRs cross audience boundaries with appropriate review requirements.

---

### Article VII: Additive Governance Inheritance

Constitution inheritance through org→domain→service→repo levels SHALL be strictly additive. Lower-level constitutions MAY add requirements, gates, review participants, and track restrictions. Lower-level constitutions SHALL NEVER remove, relax, or override requirements established at higher levels.

Resolution of the effective constitution for any initiative SHALL be computed as the union of all applicable constitutional layers.

**Rationale:** Fundamental Truth #3 and Lifecycle #11: "Governance rules inherit through LENS layers, additive only." The simplest possible inheritance model — no ambiguity about overrides, no conflict resolution needed. Scribe's validation becomes straightforward: merge all levels, check union of requirements.

**Evidence Required:** Scribe's `/resolve` command produces merged constitution. No service or repo constitution contains `override: true` or `skip_gate` directives that contradict parent layers.

---

### Article Enforcement Levels

By default, all articles are **MANDATORY** — violations produce **FAIL** (blocking) during compliance checks.

- **MANDATORY** (default) — Violations produce FAIL, block compliance
- **(ADVISORY)** — Violations produce WARN only, non-blocking
- **(NON-NEGOTIABLE)** — Explicit emphasis; behaviorally identical to MANDATORY but signals zero-tolerance intent

Articles I, II, and III are marked **(NON-NEGOTIABLE)** — they represent the three fundamental truths and the user's explicit governance constraint. No exemption process applies.

---

## Amendments

(none)

---

## Rationale

This constitution codifies the ten key architectural decisions from the brainstorming session of 2026-02-23 into enforceable governance:

1. Named phases with agent ownership (Article IV, V)
2. Audience-as-promotion-backbone (Article VI)
3. Two-speed branch model (Article II)
4. Initiative tracks (Track & Gate Governance)
5. Constitution-enforced governance (Article VII)
6. Central planning repo / code separation (Article II)
7. Party mode adversarial reviews (Article VI, Review Participants)
8. Structural enforcement principle (Article I)
9. Canonical lifecycle contract (Article V)
10. Additive inheritance (Article VII)

The user's explicit constraint — "all dev work happens in `TargetProjects/lens/lens-work/bmad.lens.src`, only BMAD planning documents outside" — is codified as Article II with NON-NEGOTIABLE enforcement.

---

## Governance

### Amendment Process

1. Propose amendment via `/constitution` amend mode
2. Require approval from Architecture Review Board
3. Ratify amendment — Scribe records and Casey commits
4. Amendment logged via Tracey (`constitution-amended` event)

### Enforcement

- Compliance checks run via `/compliance` command
- Violations surface as WARN or FAIL per article enforcement level
- Exemptions require documented justification (not available for NON-NEGOTIABLE articles)

---

_Constitution ratified on 2026-02-24_
