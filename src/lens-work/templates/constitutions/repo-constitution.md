---
layer: repo
name: "{name}"
created_by: "{user}"
ratification_date: "{date}"
last_amended: null
amendment_count: 0
inherits_from: service
---

# Repo Constitution: {name}

**Inherits From:** All parent constitutions — Org, Domain, Service (resolved via `/resolve`)
**Version:** 2.0.0
**Ratified:** {date}
**Last Amended:** —

---

## Preamble

This constitution governs the {name} repository within its service bounded context. It inherits all articles from Org, Domain, and Service Constitutions and adds repo-specific governance.

{Brief description of the repo's responsibility}

---

## Inherited Articles

*All articles from parent Constitutions apply automatically. Run `/resolve` to see the full accumulated ruleset.*

---

## Repo Articles

### Article {N}: {Repo-Specific Principle}

{Non-negotiable rule specific to this repo}

**Rationale:** {Why this rule exists}

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

{Why this repo-level constitution exists and what it adds beyond org/domain/service rules}

---

## Governance

### Amendment Process

Repo constitutions are typically versioned with each major change. For amendments:

1. Propose amendment via `/constitution` amend mode
2. Require approval from Repo Owner / Tech Lead
3. Ratify with approval — Scribe records and Casey commits

### Owner

- Repo Owner: {Name}

---

_Constitution ratified on {date}_
