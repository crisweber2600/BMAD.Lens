# Module Brief: lens-compass

**Date:** February 1, 2026
**Author:** Cris
**Module Code:** lens-compass
**Module Type:** Extension
**Status:** Ready for Development

---

## Executive Summary

Lens Compass is an intelligent navigation system that transforms Lens from a tool users figure out into a system they trust. By understanding user roles, tracking contribution depth, and learning preferences over time, Compass guides teams to the right workflows at the right moments — reducing cognitive load and enabling institutional knowledge sharing.

**Module Category:** Developer Productivity & Team Collaboration
**Target Users:** Product Owners, Architects/Lead Developers, Developers, Power Users
**Complexity Level:** Medium (single agent, 9 workflows total, git + file system integration)

---

## Module Identity

### Module Code & Name

- **Code:** `lens-compass`
- **Name:** `Lens Compass: Intelligent Role-Based Navigation`

### Core Concept

Lens Compass extends the Lens module with role-aware guidance, automatic tracking, and intelligent next-step suggestions. It learns who you are (via git), remembers what you've done (via project roster), and guides you through complex workflows with the wisdom of a senior mentor.

### Personality Theme

Professional mentor with warmth — supportive, knowledgeable, encouraging, and always thinking about what the user needs next.

---

## Module Type

**Type:** Extension

Lens Compass extends the existing Lens module by:
- Adding a new Navigator agent that enhances Lens guidance
- Creating workflows for onboarding, profile management, and next-step routing
- Integrating with all existing Lens workflows (new-service, new-microservice, new-feature, dev-story, code-review, lens-switch, etc.)
- Auto-tracking user contributions to build institutional knowledge
- Creating personal profiles tied to git identity (stored in gitignored folder)

---

## Unique Value Proposition

**What makes this module special:**

- **Understands user identity** — Detects git user, ties preferences to git email (hashed for privacy)
- **Learns role expectations** — PO workflows differ from Developer workflows; power users get all options
- **Tracks depth automatically** — Logs who created what (`created`, `modified`, `reviewed`, `contributed`)
- **Suggests next steps intelligently** — Role-based decision trees guide users based on context
- **Enables team knowledge** — "Who's worked on this service?" surfaces collaborators without explicit prompts
- **Adapts to preferences** — Learns what users skip, persists preferences over time
- **Reduces decision fatigue** — Instead of searching menus, users trust the guided path

**Why users would choose this module:**

Lens Compass removes friction from complex multi-phase workflows. A new team member onboards and immediately feels guided by a senior mentor. Teams build institutional memory automatically. Users stop asking "what should I do next?" because the system tells them — contextually, intelligently, respectfully.

---

## User Scenarios

### Target Users

1. **Product Owners (Analysis & Planning Phase)**
   - Decide between new-service vs lens-switch
   - Understand when to create microservices vs features
   - Guided through service architecture decisions

2. **Architects/Lead Developers (Planning & Solutioning Phase)**
   - Guide the entire sprint-planning → dev-story preparation flow
   - Ensure developers have clear context
   - Coordinate across multiple services and microservices

3. **Developers (Implementation Phase)**
   - Execute dev-stories with clear guidance
   - Know when to run code-review
   - Understand sprint retrospectives and next assignments

4. **Power Users (All Phases)**
   - Access full menu across all phases
   - Intelligent filtering suggests role-specific workflows
   - Can context-switch between roles mid-session

### Primary Use Case

Alice (PO) launches Lens for the first time. Compass detects her git identity and asks: "Hi Alice! What's your primary role?" She selects "Product Owner." Compass learns this. Next time she logs in, her onboarding is instant. When she runs `new-service`, the system logs it. Later, Bob (Developer) logs in. When Bob explores the same service, Compass tells him: "Alice created this — consider reaching out for architecture context." Bob runs a `new-feature` workflow. Compass tracks this too. Over weeks, the system becomes an institutional memory of "who did what."

### User Journey

1. **Day 1 — New User Onboarding** → Git detection → Role selection → Brief preference discovery → Personal profile created
2. **Day 2 — First Workflow** → User runs (e.g., new-service) → Compass tracks completion → Updates project roster
3. **Week 1 — Pattern Recognition** → Compass notices user skips brainstorming 3 times → Offers to persist preference
4. **Month 1 — Team Synergy** → Multiple users, roster full of "who worked on what" → Collaboration suggestions become valuable
5. **Steady State — Trusted Guide** → Users stop thinking about what to do next; they trust Compass's suggestions

---

## Agent Architecture

### Agent Count Strategy

**Single Agent Strategy:** Lens Compass uses one specialized agent — the Navigator. This is intentional:
- Navigator handles all onboarding, routing, and guidance
- Stays focused on one mission: getting users to the right place
- Lighter footprint than multi-agent systems
- Easier to maintain and evolve

### Agent Roster

| Agent | Name | Role | Expertise |
|-------|------|------|-----------|
| Navigator | Compass | Intelligent guide for role-based workflow routing | Onboarding, context analysis, preference learning, next-step suggestions, roster queries |

### Agent Interaction Model

Navigator works in collaboration loops:
1. **Initialization** → Detects git user, loads (or creates) personal profile
2. **Context Analysis** → Determines current phase (Analysis, Planning, Solutioning, Implementation)
3. **Role Filtering** → Suggests workflows appropriate to user's role(s)
4. **Decision Support** → Offers next-step suggestions with explanations
5. **Preference Learning** → Over time, notices patterns and asks to persist preferences
6. **Roster Integration** → Queries project roster for collaboration insights

### Agent Communication Style

Navigator communicates as a supportive mentor:
- Encouraging and warm, never condescending
- Explains *why* a workflow is suggested, not just *that* it should be done
- Celebrates milestones: "🎯 First dev-story complete!"
- Remembers user context: "Welcome back, Cris!"
- Offers choices without overwhelming: 2-3 options at a time, not 10

---

## Workflow Ecosystem

### Core Workflows (Essential)

1. **Onboarding** — Detects git user, guides role selection, creates personal profile, establishes communication preferences
2. **Next-Step Router** — Analyzes context (current phase, completed workflows, role), suggests appropriate next workflow
3. **Roster Tracker** — Auto-logs workflow completions, updates `.bmad-roster.yaml` with depth indicators

### Feature Workflows (Specialized)

1. **Profile Manager** — View/edit personal profile (name, roles, preferences), switch active role for power users
2. **Roster Query** — Search who worked on domains/services/microservices, discover collaborators
3. **Preference Learner** — Capture user patterns (e.g., "always skips brainstorming"), offer to persist preferences
4. **Context Analyzer** — Determines workflow phase, complexity level, recommended next steps

### Utility Workflows (Support)

1. **Data Cleanup** — Reset personal profile, clear preference history, reset roster entries (admin/manual)
2. **Roster Export** — Generate team knowledge reports, export collaboration history

---

## Tools & Integrations

### MCP Tools

- **Git Integration** — Read git config (user.name, user.email), detect repository information
- **File System Access** — Read/write personal profiles (`_bmad-output/personal/`), read/write project roster (`.bmad-roster.yaml`)
- **YAML Parsing** — Parse and generate YAML files for profiles and roster

### External Services

- None required (future: optional telemetry/analytics)

### Integrations with Other Modules

- Deep integration with **Lens** module workflows:
  - `new-service` — Compass logs as `created` depth
  - `new-microservice` — Compass logs as `created` depth
  - `new-feature` — Compass logs as `created` depth
  - `dev-story` — Compass logs as `modified` depth
  - `code-review` — Compass logs as `reviewed` depth
  - `lens-switch` — Compass logs context, suggests next workflows
- **Workflow completion hooks** — All Lens workflows trigger Compass roster updates

---

## Creative Features

### Personality & Theming

Navigator embodies the metaphor of a **compass**: always pointing toward True North (the right next step). The personality is:
- Wise but not aloof — shares knowledge generously
- Encouraging without being pushy — suggests, doesn't demand
- Contextually aware — remembers your role, history, preferences
- Celebrates progress — marks milestones with emoji and messages

### Easter Eggs & Delighters

1. **First-time completion celebration** — "🎯 First dev-story complete! You're officially in the Developer phase."
2. **Milestone messages** — At 5 workflows: "You're becoming a Lens pro! 🚀" | At 20: "You're a Lens master!" 
3. **Stat tracking command** — `[STATS]` shows: "You've created 2 services, 8 microservices, 23 features, reviewed 12 PRs"
4. **Zen quotes** — Random encouraging quotes at workflow start: "The best time to plant a tree was 20 years ago. The second best time is now."
5. **Collaboration celebration** — When Compass surfaces a collaborator: "✨ Bob worked on this service — you're in good company!"
6. **Role-switching fun** — For power users: "Switching to Architect mode! New workflows unlocked: sprint-planning, solutioning-review"

### Module Lore

Lens Compass is imagined as a seasoned guide who's navigated countless development journeys. It doesn't command users — it advises. It doesn't overwhelm with choices — it illuminates the path forward. Over time, users come to trust it like a mentor they've worked with for years. The compass metaphor runs throughout: it always points true north, it helps orient the lost, it guides expeditions through complex terrain.

---

## Next Steps

1. **Review this brief** — Ensure the vision is clear and complete
2. **Run create-module workflow (CM)** — Builds the extension structure in `src/modules/lens/extensions/lens-compass`
3. **Create Navigator agent** — Use agent-builder to flesh out the complete agent specification
4. **Create workflows** — Build each of the 8 workflows (onboarding, router, tracker, etc.)
5. **Add gitignore entries** — Ensure `_bmad-output/personal/` is gitignored
6. **Test integration** — Install extension, test onboarding and workflow tracking
7. **Iterate and refine** — Based on real usage, evolve preferences, suggestions, and messages

---

_Brief created on February 1, 2026 by Cris using the BMAD Module Workflow (Interactive Mode)_
