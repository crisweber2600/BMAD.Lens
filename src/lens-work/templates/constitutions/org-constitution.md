---
layer: org
name: "{name}"
created_by: "{user}"
ratification_date: "{date}"
last_amended: null
amendment_count: 0
inherits_from: null
---

# Org Constitution: {name}

**Inherits From:** None (root constitution)
**Version:** 2.0.0
**Ratified:** {date}
**Last Amended:** —

---

## Preamble

This constitution establishes the foundational governance principles for all software development within the {name} organization. These articles apply to every domain, service, and repo regardless of team or technology stack.

We hold these principles to ensure consistency, security, quality, and maintainability across our entire technology portfolio.

---

## Track & Gate Governance

### Permitted Tracks

Tracks allowed for all initiatives in this organization:

```yaml
permitted_tracks: [full, feature, tech-change, hotfix, spike]  # All tracks permitted by default
```

### Required Gates

Gates that ALL initiatives must pass, regardless of track:

```yaml
required_gates: []  # e.g., [constitution-gate] to force constitution checks for all
```

### Additional Review Participants

Extra participants added to ALL adversarial reviews (accumulates down inheritance chain):

```yaml
additional_review_participants: {}
# Example:
#   prd: [compliance-officer]
#   architecture: [security-architect]
```

---

## Articles

### Article I: {Principle Title}

{Non-negotiable rule for the entire organization}

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

This constitution establishes the foundational governance standards for the {name} organization. All domains, services, and repos inheriting from this org are bound by these articles and track/gate rules.

---

## Governance

### Amendment Process

1. Propose amendment via `/constitution` amend mode
2. Require approval from Organization Leadership / Architecture Review Board
3. Ratify amendment — Scribe records and Casey commits
4. Amendment logged via Tracey (`constitution-amended` event)
5. All downstream constitutions (domain, service, repo) inherit changes automatically

### Enforcement

- Compliance checks run via `/compliance` command
- Violations surface as WARN or FAIL per article
- Exemptions require documented justification and org-level approval

---

_Constitution ratified on {date}_
