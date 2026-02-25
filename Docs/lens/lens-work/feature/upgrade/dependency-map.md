# Dependency Map — Lens-Work Module Architecture Upgrade

**Initiative:** upgrade-cjki9q
**Phase:** DevProposal
**Agent:** John (PM)
**Date:** 2026-02-25

---

## Critical Path

```
E-001 Safety Gate ──────────────────────────────────────────────────┐
  (P0, no deps)                                                    │
                                                                   │
E-002 State Machine ──┬──── E-003 Git Engine ───────┐              │
  (P1, no deps)       │       (P1, needs E-002)     │              │
                      │                              │              │
                      ├──── E-004 Constitution ─────┤              │
                      │       (P1, needs E-002)     │              │
                      │                              │              │
                      ├──── E-005 Discovery ────────┤              │
                      │       (P2, needs E-002+E-004)│             │
                      │                              │              │
                      ├──── E-006 Checklist ────────┤              │
                      │       (P2, needs E-002+E-004)│             │
                      │                              │              │
                      └────── E-007 Router ─────────┤              │
                                (P1, needs ALL)     │              │
                                                     │              │
                              E-008 Phase Workflows ─┤              │
                                (P1, needs E-007)   │              │
                                                     │              │
                              E-009 Recovery ────────┤              │
                                (P2, needs E-002+E-003)            │
                                                     │              │
                              E-010 Validation ──────┘──────────────┘
                                (P2, needs ALL)
```

## Epic Dependency Matrix

| Epic | Depends On | Blocks | Priority | SP | Stories |
|------|-----------|--------|----------|----|---------|
| E-001 Safety Gate | — | E-010 | P0 | 5 | S-001, S-002 |
| E-002 State Machine | — | E-003, E-004, E-005, E-006, E-007, E-009 | P1 | 21 | S-003→S-007 |
| E-003 Git Engine | E-002 | E-007, E-008, E-009 | P1 | 21 | S-008→S-012 |
| E-004 Constitution | E-002 | E-005, E-006, E-007 | P1 | 13 | S-013→S-016 |
| E-005 Discovery | E-002, E-004 | E-007 | P2 | 13 | S-017→S-020 |
| E-006 Checklist | E-002, E-004 | E-007 | P2 | 8 | S-021→S-023 |
| E-007 Router | E-002, E-003, E-004, E-005, E-006 | E-008 | P1 | 21 | S-024→S-028 |
| E-008 Phase Workflows | E-007 | E-010 | P1 | 21 | S-029→S-034 |
| E-009 Recovery | E-002, E-003 | E-010 | P2 | 8 | S-035→S-037 |
| E-010 Validation | All | — | P2 | 8 | S-038→S-040 |

## Story-Level Dependency Graph

### Foundation Layer (no dependencies)
| Story | Epic | SP | Description |
|-------|------|----|-------------|
| S-001 | E-001 | 3 | Audit and remove auto-advance patterns |
| S-003 | E-002 | 5 | State.yaml read/write v2 schema |
| S-004 | E-002 | 5 | Initiative config CRUD |
| S-006 | E-002 | 3 | Event log append JSONL |
| S-013 | E-004 | 3 | Constitution file loading |

### Layer 1 (depends on Foundation)
| Story | Epic | SP | Depends On |
|-------|------|----|------------|
| S-002 | E-001 | 2 | S-001 |
| S-005 | E-002 | 3 | S-003, S-004 |
| S-008 | E-003 | 3 | S-003 |
| S-014 | E-004 | 5 | S-013 |
| S-024 | E-007 | 3 | S-003 |

### Layer 2 (depends on Layer 1)
| Story | Epic | SP | Depends On |
|-------|------|----|------------|
| S-007 | E-002 | 5 | S-003, S-004, S-005 |
| S-009 | E-003 | 5 | S-008 |
| S-011 | E-003 | 3 | S-008 |
| S-015 | E-004 | 3 | S-014 |
| S-016 | E-004 | 2 | S-013, S-014 |
| S-017 | E-005 | 3 | S-004 |
| S-018 | E-005 | 3 | S-004 |
| S-021 | E-006 | 3 | S-015 |

### Layer 3 (depends on Layer 2)
| Story | Epic | SP | Depends On |
|-------|------|----|------------|
| S-010 | E-003 | 5 | S-009 |
| S-012 | E-003 | 5 | S-008, S-009, S-010 |
| S-019 | E-005 | 3 | S-018, S-003 |
| S-020 | E-005 | 4 | S-018 |
| S-022 | E-006 | 2 | S-017, S-021 |
| S-023 | E-006 | 3 | S-006, S-021 |
| S-025 | E-007 | 5 | S-003, S-004, S-015 |
| S-026 | E-007 | 5 | S-017, S-004 |
| S-027 | E-007 | 3 | S-003, S-004, S-018 |

### Layer 4 (depends on Layer 3)
| Story | Epic | SP | Depends On |
|-------|------|----|------------|
| S-028 | E-007 | 5 | S-025 |
| S-034 | E-008 | 4 | S-003, S-004, S-006, S-008 |
| S-035 | E-009 | 3 | S-003, S-007, S-009 |

### Layer 5 (depends on Layer 4)
| Story | Epic | SP | Depends On |
|-------|------|----|------------|
| S-029 | E-008 | 3 | S-009, S-024, S-025, S-026 |
| S-036 | E-009 | 3 | S-035 |
| S-037 | E-009 | 2 | S-006, S-009 |

### Layer 6 (depends on Layer 5)
| Story | Epic | SP | Depends On |
|-------|------|----|------------|
| S-030 | E-008 | 3 | S-029 |

### Layer 7 (depends on Layer 6)
| Story | Epic | SP | Depends On |
|-------|------|----|------------|
| S-031 | E-008 | 3 | S-030 |

### Layer 8 (depends on Layer 7)
| Story | Epic | SP | Depends On |
|-------|------|----|------------|
| S-032 | E-008 | 5 | S-031, S-012 |

### Layer 9 (depends on Layer 8)
| Story | Epic | SP | Depends On |
|-------|------|----|------------|
| S-033 | E-008 | 3 | S-032 |

### Final Layer (depends on everything)
| Story | Epic | SP | Depends On |
|-------|------|----|------------|
| S-038 | E-010 | 3 | S-029→S-033 |
| S-039 | E-010 | 3 | S-013, S-014, S-015 |
| S-040 | E-010 | 2 | S-025, S-028 |

## Recommended Sprint Allocation

### Sprint 1 — Foundation (34 SP)
- **E-001** Safety Gate: S-001, S-002 (5 SP)
- **E-002** State Machine: S-003, S-004, S-005, S-006, S-007 (21 SP)
- **E-004** Constitution loading: S-013 (3 SP)
- **E-003** Audience branches: S-008 (3 SP)
- **E-007** Routing table: S-024 (2 SP, stretch)

### Sprint 2 — Engines (38 SP)
- **E-003** Git Engine: S-009, S-010, S-011, S-012 (18 SP)
- **E-004** Constitution: S-014, S-015, S-016 (10 SP)
- **E-005** Discovery: S-017, S-018 (6 SP)
- **E-006** Checklist: S-021 (3 SP, stretch)
- **E-007** Error messages: S-024 (1 SP)

### Sprint 3 — Integration (40 SP)
- **E-005** Discovery: S-019, S-020 (7 SP)
- **E-006** Checklist: S-022, S-023 (5 SP)
- **E-007** Router: S-025, S-026, S-027, S-028 (18 SP)
- **E-008** Init: S-034 (4 SP)
- **E-009** Recovery: S-035, S-036, S-037 (8 SP, stretch)

### Sprint 4 — Workflows & Validation (27 SP)
- **E-008** Phase Workflows: S-029, S-030, S-031, S-032, S-033 (17 SP)
- **E-010** Validation: S-038, S-039, S-040 (8 SP)
- Buffer for carry-over (2 SP)

## Risk Nodes

| Risk | Impact | Mitigation |
|------|--------|------------|
| E-002 State Machine delays | Blocks 6 other epics | Start first, no dependencies |
| E-007 Router complexity | Integrates all engines | Early skeleton, incremental integration |
| E-003 Git MCP fallbacks | PR creation fragility | Manual fallback from day 1 |
| Cascade merge conflicts | Block audience promotions | Test early with real branches |

---

*Generated from architecture.md §3-§9 and epics.md. Cross-referenced with lifecycle.yaml gate chain.*
