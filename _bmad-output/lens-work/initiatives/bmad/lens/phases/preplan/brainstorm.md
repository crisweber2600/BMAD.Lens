---
artifact: brainstorm
phase: preplan
initiative: bmad-lens-repodiscovery
author: Mary (Analyst)
created: "2026-03-09"
---

# Brainstorm — Repo Discovery

## Core Question

> How should `@lens` move from "language: unknown by default" to "language: resolved automatically" — and what else should discovery enable?

---

## Idea Cluster 1: Discovery as a Lifecycle Gate

**Idea:** Make language resolution a required gate before `businessplan` begins. If `language` is still `unknown` at the start of businessplan, either block or prompt.

**Why interesting:** This ties discovery directly into the lifecycle contract — you can't write a meaningful business plan for a TypeScript service if you don't know it's TypeScript. Language-specific constitution rules (code review standards, test framework recommendations) won't fire correctly without it.

**Tension:** Some initiatives are genuinely language-agnostic (process changes, governance updates). Need an explicit `language: none` or `language: agnostic` value to distinguish "never detected" from "intentionally unset."

---

## Idea Cluster 2: Discovery as a Service-Level Snapshot

**Idea:** `/discover` at the service level (not just feature level) produces a "service health snapshot" — showing ALL repos under a service, their detected languages, their BMAD config state, and which have active initiatives.

**Why interesting:** This gives team leads a one-command dashboard: "What do we have, what's configured, what's in-flight?"

**Output sketch:**
```
📦 Service: bmad-lens
  ├── bmad.lens.src — language: unknown (no build files detected) | .bmad/ ✅
  ├── bmad.lens.copilot — language: typescript (package.json) | .bmad/ ✅
  └── bmad.lens.release — language: unknown (config-only) | .bmad/ ✅

Active initiatives: bmad-lens-repodiscovery (preplan/small)
```

---

## Idea Cluster 3: The `.bmad/language` Marker as a Convention

**Idea:** The `.bmad/language` file (step 2 in detection priority) is currently undocumented as a convention. Make it an explicit, documented pattern that developers add to repos where auto-detection is unreliable (config-only repos, polyglot monorepos).

**Why interesting:** Solves the monorepo problem without complex heuristics. Developer declares intent, agent trusts it. Falls back to heuristics only when marker is absent.

**Extension:** Could evolve into `.bmad/config.yaml` with `language:` and `framework:` fields — a "repo declaration file" for the BMAD ecosystem.

---

## Idea Cluster 4: Discovery Feedback Loop

**Idea:** When detection confidence is low (step 4 file-extension analysis returns ambiguous results), `@lens` asks the user to confirm rather than silently picking.

```
🔍 Repo `bmad.lens.src` — detection uncertain:
  .md files: 47  |  .yaml files: 12  |  .ts files: 3
  Best guess: typescript (low confidence)
  Confirm? [typescript / enter correct language / skip]
```

**Why interesting:** Avoids silently wrong `language` values that then enforce wrong constitutions.

---

## Idea Cluster 5: Discovery-Driven Initiative Enrichment

**Idea:** At `/new-feature` time, immediately run discovery on the target service repos. Pre-populate the initiative config not just with `language` but also with:
- `framework` (detected from build tool)
- `test_tool` (jest/pytest/go test/etc.)
- `bmad_configured: true/false`

**Why interesting:** These fields could drive smarter BusinessPlan templates — a React initiative gets a different component design artifact than a Python API initiative.

---

## Idea Cluster 6: Stale Discovery Detection

**Idea:** Track when discovery was last run (`last_discovered` timestamp in initiative config). If an initiative has been active for > 30 days and `last_discovered` is older than 7 days, warn at lifecycle gates.

**Why interesting:** Repos change — a repo might gain a `package.json` after initial discovery. Staleness alerts prevent long-running initiatives from drifting out of sync.

---

## Key Questions for BusinessPlan Phase

1. Which ideas are in scope for v1 of this feature vs future iterations?
2. Should `/discover` be a standalone command or always embedded in lifecycle triggers?
3. Should we standardize `.bmad/language` as a v2 repo convention requirement?
4. What does "language-agnostic" look like in the initiative schema?
5. Is there value in the service-level health snapshot (Cluster 2), or is it premature?

---

## Recommended Focus for v1

Based on research findings, recommend scoping v1 to:

1. **Steps 2–4 of detection** (`.bmad/language` marker, build files, file extension analysis) — covers 90%+ of real cases
2. **On-demand `/discover` command** + auto-trigger at `/new-feature` creation
3. **Low-confidence confirmation prompt** (Cluster 4) for ambiguous detection
4. **`.bmad/language` convention documentation** (Cluster 3, minimal effort, high payoff)

Defer to v2:
- Service health snapshot dashboard (Cluster 2)
- Discovery-driven framework/test tool enrichment (Cluster 5)
- Staleness detection (Cluster 6)
