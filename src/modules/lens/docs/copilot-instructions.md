# Lens Copilot Instructions

These instructions are installed to `.github/lens-instructions.md` during module installation and configure GitHub Copilot behavior for Lens-managed repositories.

---

## Copilot Integration

When working in a repository managed by Lens:

### Agent Activation

Use `@lens` to activate the Lens agent. All lifecycle commands go through this single agent.

### State Awareness

Lens maintains state at `_bmad-output/lens/state.yaml`. Before making changes:
1. Check the current phase with `/status`
2. Ensure you're on the correct branch
3. Follow the phase workflow for the current stage

### Branch Discipline

- **Never push directly to audience or root branches** — always use phase branches
- **Create workflow branches from phase branches** for individual work items
- **PR at phase end** — merge phase → audience, not phase → root
- Use flat hyphen-separated naming: `{featureBranchRoot}-{audience}-p{N}`

### File Organization

- Planning artifacts go in `_bmad-output/planning-artifacts/`
- Implementation artifacts go in `_bmad-output/implementation-artifacts/`
- Lens state files are auto-managed — don't edit manually
- Use `/sync` or `/fix` if state seems wrong

### Constitution Compliance

Constitution checks run automatically. If you see governance warnings:
1. Read the cited rule
2. Follow the remediation guidance
3. Use `/lens` to see full compliance status

### Command Reference

| Command | Purpose |
|---------|---------|
| `/pre-plan` | Brainstorming & discovery |
| `/plan` | Product requirements |
| `/tech-plan` | Architecture |
| `/Story-Gen` | Stories |
| `/Review` | Readiness |
| `/Dev` | Implementation |
| `/new` | Create initiative |
| `/switch` | Switch initiative |
| `/status` | Quick status |
| `/lens` | Full context |
| `/sync` | Reconcile state |
| `/fix` | Repair state |
| `/onboard` | First-time setup |
