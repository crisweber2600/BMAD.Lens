---
layer: service
name: "{name}"
created_by: "{user}"
ratification_date: "{date}"
last_amended: null
amendment_count: 0
inherits_from: domain
---

# Service Constitution: {name}

**Inherits From:** Domain constitution (resolved via `/resolve`)
**Version:** 2.0.0
**Ratified:** {date}
**Last Amended:** —

---

## Preamble

This constitution governs the {name} service and all repos within its bounded context. It inherits all articles from the Org and Domain Constitutions and adds service-specific governance.

{Brief description of the service's purpose and scope}

---

## Track & Gate Governance

### Permitted Tracks

Tracks allowed for initiatives targeting this service (additive — can only restrict what Domain permits):

```yaml
permitted_tracks: [full, feature, tech-change, hotfix, spike]  # Customize per service
```

### Required Gates

Gates that ALL initiatives targeting this service must pass:

```yaml
required_gates: []  # e.g., [adversarial-review]
```

### Additional Review Participants

Extra participants for adversarial reviews (additive — accumulates with Org + Domain):

```yaml
additional_review_participants: {}
# Example:
#   architecture: [service-owner]
#   epics-and-stories: [qa-lead]
```

---

## Inherited Articles

*All articles from the Domain Constitution apply automatically. Run `/resolve` to see the full accumulated ruleset.*

---

## Service Articles

### Article {N}: {Service-Specific Principle}

{Non-negotiable rule specific to this service}

**Rationale:** {Why this rule exists for this service}

**Evidence Required:** {What artifact demonstrates compliance}

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

{Why this service-level constitution exists and what it adds beyond org/domain rules}

---

## Governance

### Amendment Process

1. Propose amendment via `/constitution` amend mode
2. Require approval from Service Owner
3. Notify dependent services of changes
4. Ratify with Service Owner approval — Scribe records and Casey commits

### Service Owner

- Name: {Owner Name}

---

_Constitution ratified on {date}_
