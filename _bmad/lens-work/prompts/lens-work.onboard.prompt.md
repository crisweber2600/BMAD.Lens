```prompt
---
description: Create user profile and bootstrap TargetProjects for new team members
---

Activate Scout agent and execute onboarding workflow:

1. Load workflow: `_bmad/lens-work/workflows/utility/onboarding/workflow.md`
2. Welcome new team member (3-5 minute setup)
3. Create profile from git config
4. Prompt for role and scope selection
5. Run discovery → reconcile → documentation cycle
6. Confirm setup complete

**Profile Creation:**
1. Extract name/email from git config
2. Single prompt for role, domain/scope, AND PAT setup:
   - Role: [1] Developer [2] Tech Lead [3] Architect [4] Product Owner [5] Scrum Master
   - Domain: Select specific domain or "all" for full access
   - PAT: [Y]es to set up now, [N]o to skip
   - Format: Enter three values space-separated (e.g., "3 9 Y" = Architect + all domains + set up PAT)
3. GitHub PAT storage (if Y selected):
   - Workflow detects GitHub domains from repo inventory
   - Provides exact command to copy-paste into NEW terminal
   - Command includes: `cd <project-root> && bash _bmad/lens-work/scripts/store-github-pat.sh`
   - Script runs outside LLM context for security
   - Script will prompt for PAT (characters won't appear - normal for secure input)
   - Script opens credentials file in VS Code when complete
   - User sends "Continue" to resume workflow
   - Credentials stored in `_bmad-output/lens-work/personal/github-credentials.yaml` (gitignored)
4. Create personal profile (gitignored)
5. Create roster entry (for team stats)

**Bootstrap Sequence:**
1. Determine scope (domain-specific or full)
2. Run repo-discover (create inventory)
3. Run repo-reconcile (clone missing repos)
4. Run repo-document (generate initial docs)
5. Report completion with next steps

**Creates:**
- Personal profile: `_bmad-output/lens-work/personal/profile.yaml` (gitignored)
- GitHub credentials: `_bmad-output/lens-work/personal/github-credentials.yaml` (gitignored, per-domain tokens)
- Roster entry: `_bmad-output/lens-work/roster/{name}.yaml` (tracked)
- Personal inventory: `_bmad-output/lens-work/personal/personal-repo-inventory.yaml`
- Canonical docs: `Docs/{domain}/{service}/`

**Next Steps:**
- Run `#new-feature "description"` to start an initiative
- Run `@tracey ST` to see status
- Run `@compass H` for help

```
