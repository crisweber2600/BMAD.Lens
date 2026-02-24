---
layer: domain
name: "{name}"
created_by: "{user}"
ratification_date: "{date}"
last_amended: null
amendment_count: 0
inherits_from: org
---

# Domain Constitution: {name}

**Inherits From:** Org constitution (resolved via `/resolve`)
**Version:** 2.0.0
**Ratified:** {date}
**Last Amended:** —

---

## Preamble

This constitution establishes the governance principles for all software development within the {name} domain. These articles apply to every service and repo within this domain. It inherits all articles from the Org Constitution and adds domain-specific governance.

We hold these principles to ensure consistency, security, quality, and maintainability across this domain.

---

## Track & Gate Governance

### Permitted Tracks

Tracks allowed for initiatives within this domain (additive — can only restrict what Org permits):

```yaml
permitted_tracks: [full, feature, tech-change, hotfix, spike]  # Customize per domain
```

### Required Gates

Gates that ALL initiatives in this domain must pass, even if their track would skip them:

```yaml
required_gates: []  # e.g., [adversarial-review, stakeholder-approval]
```

### Additional Review Participants

Extra participants added to adversarial reviews for this domain (additive — accumulates with Org):

```yaml
additional_review_participants: {}
# Example:
#   prd: [domain-architect]
#   architecture: [security-reviewer]
```

---

## Articles

### Article I: {Principle Title}

{Non-negotiable rule for this domain}

**Rationale:** {Why this rule exists}

**Evidence Required:** {What artifact demonstrates compliance}

---

### Article II: {Principle Title}

{Rule}

**Rationale:** {Why}

**Evidence Required:** {What}

---

### Article Enforcement Levels

By default, all articles are **MANDATORY** — violations produce **FAIL** (blocking) during compliance checks.

To make an article advisory (non-blocking), add `(ADVISORY)` suffix to the article header:

> Example: `### Article VI: Documentation Standards (ADVISORY)`

- **MANDATORY** (default) — Violations produce FAIL, block compliance
- **(ADVISORY)** — Violations produce WARN only, non-blocking
- **(NON-NEGOTIABLE)** — Valid for documentation clarity, but has no behavioral effect (all non-ADVISORY articles already default to FAIL enforcement)

---

## Amendments

(none)

## Rationale

This constitution establishes the governance standards for the {name} domain. All services and repos inheriting from this domain are bound by these articles and track/gate rules.

---

## Governance

### Amendment Process

1. Propose amendment via `/constitution` amend mode
2. Require approval from Architecture Review Board
3. Ratify amendment — Scribe records and Casey commits
4. Amendment logged via Tracey (`constitution-amended` event)

### Enforcement

- Compliance checks run via `/compliance` command
- Violations surface as WARN or FAIL per article
- Exemptions require documented justification

---

_Constitution ratified on {date}_
