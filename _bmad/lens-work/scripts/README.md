# LENS Workbench Scripts

## Audience Promotion PR Scripts

These scripts automate the creation of pull requests for audience promotion gates in the LENS Workbench v2.0.0 lifecycle.

### Available Scripts

| Script | Description | Requirements |
|--------|-------------|--------------|
| `create-promotion-pr-api.ps1` | PowerShell version using GitHub API | GitHub PAT |
| `create-promotion-pr-api.sh` | Bash version using GitHub API | GitHub PAT |
| `create-promotion-pr.ps1` | PowerShell version using gh CLI | gh CLI tool |
| `create-promotion-pr.sh` | Bash version using gh CLI | gh CLI tool |

### GitHub Personal Access Token Setup

The API versions (`*-api.ps1` and `*-api.sh`) require a GitHub Personal Access Token with the following permissions:

- `repo` (Full control of private repositories)
- `workflow` (Update GitHub Action workflows) - optional
- `write:org` (Read/write org data) - if working with org repos

#### Creating a PAT

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a name like "LENS Workbench Promotion"
4. Select scopes: `repo` (minimum)
5. Generate and copy the token

#### Setting the PAT

**Windows (PowerShell):**
```powershell
# For current session
$env:GITHUB_PAT = "ghp_yourTokenHere"

# For persistent (user-level)
[Environment]::SetEnvironmentVariable("GITHUB_PAT", "ghp_yourTokenHere", "User")
```

**Linux/Mac (Bash):**
```bash
# For current session
export GITHUB_PAT="ghp_yourTokenHere"

# For persistent (add to ~/.bashrc or ~/.zshrc)
echo 'export GITHUB_PAT="ghp_yourTokenHere"' >> ~/.bashrc
source ~/.bashrc
```

### Usage Examples

#### API Version (Recommended)

**PowerShell:**
```powershell
# Basic usage (uses GITHUB_PAT from environment)
.\create-promotion-pr-api.ps1 -SourceAudience small -TargetAudience medium

# With explicit PAT
.\create-promotion-pr-api.ps1 -SourceAudience small -TargetAudience medium -Pat "ghp_token"

# With specific initiative
.\create-promotion-pr-api.ps1 -SourceAudience medium -TargetAudience large -InitiativeRoot "payment-gateway"

# Dry run (preview without creating)
.\create-promotion-pr-api.ps1 -SourceAudience large -TargetAudience base -DryRun

# Specify repository explicitly
.\create-promotion-pr-api.ps1 -SourceAudience small -TargetAudience medium `
    -RepoOwner "myorg" -RepoName "myrepo"
```

**Bash:**
```bash
# Basic usage (uses GITHUB_PAT from environment)
./create-promotion-pr-api.sh small medium

# With specific initiative
./create-promotion-pr-api.sh medium large "payment-gateway"

# Dry run
./create-promotion-pr-api.sh large base "payment-gateway" true
```

### Promotion Gates

The scripts handle three types of audience promotions:

| Source | Target | Gate Type | Description |
|--------|--------|-----------|-------------|
| small | medium | adversarial-review | Party mode review of creation phases |
| medium | large | stakeholder-approval | Stakeholder review of proposals |
| large | base | constitution-gate | Final compliance check before dev |

### Created PR Features

Each PR created by these scripts includes:

1. **Descriptive Title** with gate type and promotion path
2. **Comprehensive Body** containing:
   - Promotion checklist
   - Audience progression diagram (Mermaid)
   - Files changed summary
   - Next steps after merge
3. **Automatic Labels**:
   - `lens-promotion`
   - Gate-specific label (e.g., `adversarial-review`)
   - Path label (e.g., `small-to-medium`)
4. **Saved PR Info** in `_bmad-output/lens-work/promotion-prs/`

### Branch Management

The scripts automatically:

1. Verify source branch exists locally
2. Create target branch if it doesn't exist
3. Push branches to remote
4. Handle special "base" audience (uses initiative root as branch name)

### Error Handling

Common errors and solutions:

| Error | Solution |
|-------|----------|
| "GitHub Personal Access Token required!" | Set `GITHUB_PAT` environment variable |
| "Source branch not found" | Ensure you're on the correct branch or it exists locally |
| "Could not detect GitHub repository" | Ensure git remote origin is set to GitHub |
| "401 Unauthorized" | Check PAT is valid and has correct permissions |
| "422 Unprocessable Entity" | Usually means PR already exists or branches are identical |

### Validation Script

Test your v2.0.0 setup:

```powershell
# PowerShell
.\test-v2-initiative.ps1

# Creates test report in tests/
```

### Migration Script

Validate the complete v2.0.0 implementation:

```powershell
# PowerShell
.\validate-v2.ps1

# Checks:
# - lifecycle.yaml exists
# - Templates use v2 fields
# - No legacy files remain
# - Branch patterns are correct
```

---

## Other Scripts

| Script | Description |
|--------|-------------|
| `validate-v2.ps1` | Validates v2.0.0 implementation |
| `test-v2-initiative.ps1` | Tests initiative creation |
| `validate-lens-work.ps1` | General module validation |

---

_Scripts for LENS Workbench v2.0.0 - Lifecycle Contract_