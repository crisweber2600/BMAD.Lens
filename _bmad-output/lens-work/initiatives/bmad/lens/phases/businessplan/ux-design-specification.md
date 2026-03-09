---
stepsCompleted: [step-01-init, step-02-discovery, step-03-core-experience, step-04-emotional-response, step-05-inspiration, step-06-design-system, step-07-defining-experience, step-08-visual-foundation, step-09-design-directions, step-10-user-journeys, step-11-component-strategy, step-12-ux-patterns, step-13-responsive-accessibility, step-14-complete]
inputDocuments:
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/preplan/product-brief.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/businessplan/prd.md
  - _bmad-output/lens-work/initiatives/bmad/lens/phases/businessplan/businessplan-questions.md
mode: batch
initiative: bmad-lens-repodiscovery
phase: businessplan
author: Sally (UX Designer)
created: "2026-03-09"
---

# UX Design Specification — Repo Discovery

**Author:** CrisWeber
**Date:** 2026-03-09

---

## Platform & Interaction Model

**Platform:** VS Code Copilot Chat (agent command)
**Interaction type:** Agent conversation — text-based, command-driven
**Rendering context:** Markdown in Copilot Chat panel
**No traditional UI:** No web pages, no forms, no buttons — all interactions are conversational text and markdown output

---

## Core Experience Definition

### Primary Interaction

The ONE thing users do most frequently: **respond "done" after cloning repos**, triggering the discovery scan. This hand-off from manual cloning to automated detection must feel instant and confident.

### Critical Success Moment

The transition from "done" → scanning → report. The user must feel that something happened immediately and that the agent is in control.

### Effortless Interaction

Running `/discover` after `/new-service` should feel like a natural continuation, not a separate tool invocation. Minimal input required — the agent already knows the context (domain, service, initiative).

---

## Emotional Response & Tone

### Target Emotional State

**Minimal and trustworthy.** The user should feel that the agent handled everything quietly and correctly. No fanfare, no unnecessary verbosity.

### Tone Profile

| Dimension | Setting |
|---|---|
| Verbosity | Minimal — one line per repo during execution |
| Confidence | High — no hedging, no "I think..." |
| Warmth | Neutral/professional — helpful, not chatty |
| Error communication | Direct, actionable — state what failed and what to do |
| Waiting prompt | Helpful/instructive — guide the user clearly |

### Anti-Patterns

- No celebratory language during execution ("Great job!", "Awesome!")
- No lengthy explanations of what the agent is doing internally
- No questions mid-discovery — run to completion, then report

---

## Interaction Flows

### Flow 1: Standard Discovery

```
User: /discover
Agent: Clone your repos to `TargetProjects/{domain}/{service}/` and reply "done" when ready.
       (If repos are already detected, skip this prompt.)

User: done

Agent: ✓ discovered: NorthStarET.Lms
       ✓ discovered: NorthStarET.AppHost
       ✓ discovered: NS4.React

       📋 Discovery Report

       | Repo | Language | BMAD | Governance | Branch |
       |------|----------|------|------------|--------|
       | NorthStarET.Lms | C# | ✓ | Updated | Created |
       | NorthStarET.AppHost | C# | ✓ | Updated | Created |
       | NS4.React | TypeScript | ✗ | Updated | Created |

       3 repos discovered and registered.
       You can now use `/switch` to navigate to any discovered repo.
```

### Flow 2: Re-Discovery (Repos Already in Inventory)

```
User: /discover

Agent: ✓ discovered: NorthStarET.Lms
       ⚠️ NorthStarET.Lms already in inventory. Update? [Y/N]

User: Y

Agent: ✓ updated: NorthStarET.Lms
       ✓ discovered: NewRepo

       📋 Discovery Report
       ...
```

### Flow 3: Empty Folder

```
User: /discover

Agent: No repos found. Did you clone them to the right folder?
       Expected: TargetProjects/{domain}/{service}/
```

### Flow 4: Partial Failure (Governance Push Error)

```
User: /discover

Agent: ✓ discovered: RepoA
       ✓ discovered: RepoB
       ❌ Governance push failed for RepoA (network error)
       ✓ RepoB governance updated

       📋 Discovery Report

       | Repo | Language | BMAD | Governance | Branch |
       |------|----------|------|------------|--------|
       | RepoA | unknown | ✓ | ❌ Failed | Created |
       | RepoB | C# | ✓ | Updated | Created |

       ⚠️ 1 governance update failed. Re-run `/discover` to retry.
```

---

## Progress Output Design

### During Execution

One line per discovered repo, printed as each is found:

```
✓ discovered: {repo-name}
```

If a repo triggers an interactive question (idempotency):

```
⚠️ {repo-name} already in inventory. Update? [Y/N]
```

### Error Indicators

| Severity | Prefix | Example |
|---|---|---|
| Success | `✓` | `✓ discovered: RepoA` |
| Warning | `⚠️` | `⚠️ RepoA already in inventory` |
| Error | `❌` | `❌ Governance push failed for RepoA` |

Text labels always accompany icons for clarity.

---

## Report Design

### Format

Table-based summary. Structured, data-first, concise — not conversational.

### Report Template

```markdown
📋 Discovery Report

| Repo | Language | BMAD | Governance | Branch |
|------|----------|------|------------|--------|
| {name} | {lang} | ✓/✗ | {status} | {status} |

{count} repos discovered and registered.
You can now use `/switch` to navigate to any discovered repo.
```

### Column Definitions

| Column | Values | Description |
|---|---|---|
| Repo | repo directory name | Name of the discovered git repository |
| Language | detected language or `unknown` | Primary language (nice-to-have feature) |
| BMAD | ✓ / ✗ | Whether `.bmad/` directory exists |
| Governance | Updated / ❌ Failed / Skipped | `repo-inventory.yaml` update status |
| Branch | Created / Exists / ❌ Failed | Control repo branch status |

### Footer

- Count of repos discovered
- "What next" nudge: "You can now use `/switch` to navigate to any discovered repo."
- If failures occurred: "⚠️ {n} operation(s) failed. Re-run `/discover` to retry."

---

## Waiting Prompt Design

### When Repos Not Yet Detected

```
Clone your repos to `TargetProjects/{domain}/{service}/` and reply "done" when ready.
```

**Tone:** Helpful/instructive — tells the user exactly what to do and where.

### When Repos Already Present

Skip the waiting prompt entirely. Proceed directly to scanning.

---

## Agent Persona

**Agent:** @lens (default agent — no sub-persona switch needed)

The @lens agent runs `/discover` in its standard persona. No need to switch to a specialized agent persona since this is a utility/lifecycle command, not a planning workflow.

---

## Zero-State Handling

### No Repos Found

Message: "No repos found. Did you clone them to the right folder?"

No table rendered. No governance updates. No branches created. Clean exit.

### Governance Repo Missing

Detected in preflight. Message: "Governance repo not found at `TargetProjects/lens/lens-governance/`. Clone it first."

---

## Accessibility

No special accessibility constraints identified. Standard Copilot Chat markdown rendering applies.

Table format is used for the report (confirmed by user as acceptable in this rendering context). Icons (✓, ✗, ⚠️, ❌) always have accompanying text labels.

---

## Responsive Design

Not applicable — VS Code Copilot Chat has a single rendering context. No responsive breakpoints needed.

---

## UX Patterns & Consistency

### Command Pattern

`/discover` follows the same pattern as other lens-work utility commands:

1. Preflight checks (verify prerequisites)
2. Execute (scan, detect, update)
3. Report (table summary)
4. Nudge (suggest next action)

### Error Pattern

All lens-work commands use the same error/warning prefix convention:
- `✓` success
- `⚠️` warning (non-blocking)
- `❌` error (operation failed, but execution continues)

### Idempotency Pattern

When existing data is detected, always warn and ask before overwriting. Never silently overwrite governance data.
