# Branch Protection for lens-work Branches

## Overview

lens-work creates a structured branch topology under the `lens/` prefix. Proper branch protection rules ensure lifecycle integrity — preventing accidental pushes to lane branches, enforcing review gates, and keeping the merge flow aligned with BMAD phases.

## Branch Topology Recap

```
lens/{id}/base          ← Initiative root (created once, rarely touched)
lens/{id}/small         ← Small-team lane (planning phases merge here)
lens/{id}/lead          ← Lead review lane (receives from small after review)
lens/{id}/small/p1      ← Phase branch (Analysis)
lens/{id}/small/p1/w/*  ← Workflow branches (individual work)
```

## Recommended Protection Rules

### Lane Branches (small, lead)

| Rule | Value | Rationale |
|------|-------|-----------|
| Require PR for merge | ✅ Yes | Workflow → phase merges must be reviewable |
| Required reviewers | 1+ | At least one team member reviews completed phase work |
| Dismiss stale reviews | ✅ Yes | Re-review if workflow branch changes after approval |
| Allow force push | ❌ No | Lane branches are accumulation points — never rewrite |
| Allow deletion | ❌ No | Lane branches persist for the initiative lifetime |

### Phase Branches (p1, p2, p3, p4)

| Rule | Value | Rationale |
|------|-------|-----------|
| Require PR for merge | ✅ Yes | Workflow branches merge into phase via PR |
| Required reviewers | 0–1 | Optional for solo dev, recommended for teams |
| Allow force push | ❌ No | Phase branches track sequential workflow merges |
| Allow deletion | ✅ After merge | Clean up after phase → lane merge |

### Workflow Branches (w/*)

| Rule | Value | Rationale |
|------|-------|-----------|
| Require PR for merge | Optional | Team preference |
| Allow force push | ✅ Yes | Developer may rebase during active work |
| Allow deletion | ✅ After merge | Clean up after workflow → phase merge |

## Lane-to-Lane Merge Reviews

The `small → lead` merge is a critical gate representing the **Lead Review** phase. This merge should always require:

- **2+ reviewers** including a tech lead or architect
- **All CI checks passing** (see [ci-integration.md](ci-integration.md))
- **No unresolved comments**
- **Linear merge history** (squash or rebase)

## Platform Configuration

### GitHub

```yaml
# .github/settings.yml (probot/settings format)
branches:
  - name: "lens/*/small"
    protection:
      required_pull_request_reviews:
        required_approving_review_count: 1
        dismiss_stale_reviews: true
      enforce_admins: true
      restrictions: null

  - name: "lens/*/lead"
    protection:
      required_pull_request_reviews:
        required_approving_review_count: 2
        dismiss_stale_reviews: true
      enforce_admins: true
```

> **Note:** GitHub branch protection rules support wildcard patterns. Use `lens/*/small` to match all initiative lane branches.

### Azure DevOps

1. Navigate to **Project Settings → Repos → Branches**
2. Add branch policy for pattern `lens/*/small` and `lens/*/lead`
3. Set minimum reviewers (1 for small, 2 for lead)
4. Enable **Check for linked work items** if using Azure Boards
5. Add build validation policy referencing your CI pipeline

### GitLab

1. Navigate to **Settings → Repository → Protected Branches**
2. Add `lens/*/small` — Allowed to merge: Maintainers, Allowed to push: No one
3. Add `lens/*/lead` — Allowed to merge: Maintainers, Allowed to push: No one
4. Configure merge request approvals under **Settings → Merge Requests**
