# BMAD.Lens Quick Reference Card

**Period:** Jan 30 - Feb 9, 2026 (11 days)  
**Status:** ✅ Production Ready

---

## 🎯 What is BMAD.Lens?

A **guided lifecycle router** that transforms BMAD from a complex framework into an easy-to-use system.

**Core Value:** Git branches = lifecycle phases = process tracker

---

## 🤖 Four Agents

| Agent | Command | Role |
|-------|---------|------|
| **Compass** | `/pre-plan`, `/spec`, `/plan`, `/review`, `/dev` | Phase Router |
| **Casey** | Auto-triggered | Git Conductor |
| **Tracey** | `status`, `resume`, `switch` | State Manager |
| **Scout** | `bootstrap`, `discover` | Discovery Lead |

---

## 📊 Two-File State

```
_bmad-output/lens-work/
├── state.yaml         ← Where are we now?
└── event-log.jsonl    ← What happened? (immutable)
```

---

## 🌳 Branch Topology

```
main
└── {domain}/{initiative_id}/base
    ├── {domain}/{initiative_id}/small
    │   ├── small-1 (Analysis)
    │   ├── small-2 (Planning)
    │   ├── small-3 (Solutioning)
    │   └── small-4 (Implementation)
    └── {domain}/{initiative_id}/large
```

---

## 📈 Repository Stats

| Metric | Count |
|--------|-------|
| **Commits** | 84 |
| **Days** | 11 |
| **Lines of Code** | ~50,000 |
| **Files** | 600+ |
| **Workflows** | 95+ |
| **Tests** | 159 |
| **Docs** | 50+ pages |
| **PRs** | 5 merged |

---

## 🗓️ Quick Timeline

| Date | Milestone |
|------|-----------|
| **Jan 30** | First commit (366 files) |
| **Jan 31** | LENS workflows + validation |
| **Feb 1** | Scout agent + discovery |
| **Feb 2** | Bootstrap + service creation |
| **Feb 3** | V2 init (codex prompts) |
| **Feb 5** | ⭐ V2 state architecture (+7,100 lines) |
| **Feb 6** | ⭐ V3 mega-merge (3 branches) |
| **Feb 7** | V4 governance integration |
| **Feb 8** | ⭐ Constitutional governance (S1-S10) |
| **Feb 9** | Path standardization ✅ |

---

## 🏆 Top 5 Commits

1. **ee63003** (Feb 5) — lens-work v2: State architecture (+7,100 lines)
2. **2d1bc85** (Jan 30) — First commit (366 files)
3. **a712479** (Feb 6) — lensv3 mega-merge (3 branches)
4. **2ad6042** (Feb 8) — Context enhancement (S01-S18)
5. **2cdce90** (Feb 1) — Scout agent with discovery

---

## 📋 Governance Features (Feb 8)

- ✅ S1: ADVISORY parsing
- ✅ S2: Compliance gates
- ✅ S3: Constraint application
- ✅ S4: Requirements checklist
- ✅ S5: Semantic versioning
- ✅ S6: Cross-artifact analysis
- ✅ S7: Scribe workflows
- ✅ S8: Impact reporting
- ✅ S9: Amendment propagation
- ✅ S10: Testability validation

---

## 🔄 Major Versions

### V1 (Jan 30 - Feb 2)
Basic LENS workflows, Scout agent

### V2 (Feb 5)
**State architecture**, Casey agent, routers

### V3 (Feb 6)
**Merged 3 branches**, terminology cleanup

### V4 (Feb 7-8)
**Constitutional governance**, production-ready

---

## 📚 Key Documents

| Document | Lines | Purpose |
|----------|-------|---------|
| `README.md` | 485 | Architecture overview |
| `copilot-instructions.md` | 383 | Copilot integration |
| `CHANGELOG.md` | 2,000+ | Detailed history |
| `EXECUTIVE-SUMMARY.md` | 500+ | High-level overview |
| `TIMELINE.md` | 800+ | Visual timeline |

---

## 🚀 Phase Commands

```bash
/pre-plan   → Bootstrap & discovery (P0 → P1)
/spec       → Create PRD (P1 → P2)
/plan       → Create architecture & epics (P2 → P3)
/review     → Implementation readiness check
/dev        → Implement stories (P3 → P4)
```

**Gate:** `/review` must pass before `/dev`

---

## 📂 Repository Structure

```
BMAD.Lens/
├── _bmad/                  ← Framework modules
│   ├── lens-work/         ← INSTALLED module
│   ├── bmm/               ← BMAD Method
│   ├── bmb/               ← BMAD Builder
│   ├── cis/               ← Creative Suite
│   └── core/              ← Core platform
├── _bmad-output/
│   └── lens-work/         ← Runtime state
├── src/modules/lens-work/ ← SOURCE module
├── .github/
│   ├── agents/            ← Copilot stubs
│   └── prompts/           ← Prompt files
└── archive/               ← Legacy components
```

---

## 🎨 Workflow Categories

### Router Workflows (5)
- pre-plan, spec, plan, review, dev

### Utility Workflows (6)
- status, resume, switch, onboarding, check-repos, migrate-state

### Discovery Workflows (8)
- bootstrap, discover, generate-docs, analyze-codebase, reconcile, rollback, sync-status, update-lens

### Governance Workflows (5)
- validate-schema, compliance-check, constitution, resolve-constitution, resolve-context

---

## ✅ Quality Metrics

| Metric | Status |
|--------|--------|
| **P0 Review Findings** | ✅ All resolved |
| **Test Coverage** | ✅ 159 specifications |
| **Path Consistency** | ✅ Enforced |
| **Documentation** | ✅ Complete |
| **Adversarial Review** | ✅ Passed |

---

## 🎯 Success Indicators

✅ Production-ready state architecture  
✅ Full constitutional governance  
✅ All P0 findings resolved  
✅ 159 test specifications  
✅ Path standardization complete  
✅ Copilot integration documented  
🔄 Telemetry dashboards (planned)  
🔄 Enhanced multi-repo resolution (planned)

---

## 👥 Team

**Primary:** Cris Weber (92.9% commits)  
**AI Assist:** openai-code-agent, copilot-swe-agent (7.1%)

---

## 🔗 Path Patterns

**Standard:** `{domain}/{service}`

**Examples:**
```
platform/auth
platform/billing
commerce/cart
commerce/checkout
```

**Docs:** `{docs_output_path}/{domain}/{service}/`

---

## 📊 Commit Velocity

```
Average: 7.6 commits/day
Peak: 24 commits (Feb 8)
Total: 84 commits in 11 days
```

---

## 🌟 Innovation Highlights

1. **Git-as-process-tracker** — Branches = phases
2. **Two-file state** — No database needed
3. **11-day delivery** — Foundation → production
4. **Constitutional governance** — Rules as code
5. **Event sourcing** — Immutable audit trail

---

## 📖 Related Docs

- **Detailed History:** [CHANGELOG.md](CHANGELOG.md)
- **Overview:** [EXECUTIVE-SUMMARY.md](EXECUTIVE-SUMMARY.md)
- **Visual Timeline:** [TIMELINE.md](TIMELINE.md)
- **Architecture:** [src/modules/lens-work/README.md](src/modules/lens-work/README.md)
- **Copilot Guide:** [src/modules/lens-work/docs/copilot-instructions.md](src/modules/lens-work/docs/copilot-instructions.md)

---

## 🎓 Quick Start

1. **Bootstrap:** `@compass /pre-plan`
2. **Discover:** Scout runs automatically
3. **Plan:** `@compass /spec` → Create PRD
4. **Solution:** `@compass /plan` → Architecture
5. **Gate:** `@compass /review` → Readiness check
6. **Build:** `@compass /dev` → Implementation

---

## 🔧 State Commands

```bash
@tracey status    # Where are we?
@tracey resume    # Continue where we left off
@tracey switch    # Change initiative
```

---

## 🎉 Milestones

- ✨ **Jan 30:** Foundation established
- 🚀 **Feb 1:** Discovery unlocked
- ⚡ **Feb 5:** V2 revolution
- 🔀 **Feb 6:** The great merge
- 👑 **Feb 7:** Governance crowned
- 📊 **Feb 8:** Productivity peak (24 commits!)
- ✨ **Feb 9:** Production ready!

---

**Current Status:** ✅ Production Ready  
**Next Phase:** Telemetry dashboards & multi-repo enhancements

---

*Last Updated: February 9, 2026*
