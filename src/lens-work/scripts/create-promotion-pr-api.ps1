# LENS Workbench v2.0.0 - Audience Promotion PR Creation Script (GitHub API)
# =============================================================================
# Creates pull requests for audience promotion gates using GitHub API
# Requires: $env:GITHUB_PAT or -Pat parameter
# Usage: .\create-promotion-pr-api.ps1 -SourceAudience small -TargetAudience medium
# =============================================================================

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("small", "medium", "large")]
    [string]$SourceAudience,

    [Parameter(Mandatory=$true)]
    [ValidateSet("medium", "large", "base")]
    [string]$TargetAudience,

    [string]$InitiativeRoot = "",
    [string]$StateFile = "_bmad-output/lens-work/state.yaml",
    [string]$Pat = $env:GITHUB_PAT,
    [string]$RepoOwner = "",
    [string]$RepoName = "",
    [switch]$DryRun = $false
)

# Color output functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Write-Info "======================================"
Write-Info "LENS Workbench Audience Promotion (API)"
Write-Info "======================================"

# Check for PAT
if (-not $Pat) {
    Write-Error "GitHub Personal Access Token required!"
    Write-Error "Set `$env:GITHUB_PAT or use -Pat parameter"
    exit 1
}

# Get repository info from git remote if not provided
if (-not $RepoOwner -or -not $RepoName) {
    $remoteUrl = git config --get remote.origin.url
    if ($remoteUrl -match "github\.com[:/]([^/]+)/([^/\.]+)") {
        $RepoOwner = $Matches[1]
        $RepoName = $Matches[2]
        Write-Info "Detected repository: $RepoOwner/$RepoName"
    } else {
        Write-Error "Could not detect GitHub repository from remote URL"
        Write-Error "Please provide -RepoOwner and -RepoName parameters"
        exit 1
    }
}

# Validate promotion path
$validPromotions = @{
    "small" = "medium"
    "medium" = "large"
    "large" = "base"
}

if ($validPromotions[$SourceAudience] -ne $TargetAudience) {
    Write-Error "Invalid promotion path: $SourceAudience → $TargetAudience"
    Write-Error "Valid paths: small→medium, medium→large, large→base"
    exit 1
}

# Load state to get initiative root if not provided
if (-not $InitiativeRoot) {
    if (Test-Path $StateFile) {
        # Simple YAML parsing for initiative root
        $stateContent = Get-Content $StateFile -Raw
        if ($stateContent -match "active_initiative:\s*(\S+)") {
            $InitiativeRoot = $Matches[1]
            if ($InitiativeRoot -eq "null") {
                Write-Error "No active initiative found in state.yaml"
                exit 1
            }
            Write-Info "Using initiative: $InitiativeRoot"
        }
    } else {
        Write-Error "State file not found: $StateFile"
        exit 1
    }
}

# Determine promotion gate type and description
$gateInfo = switch ("$SourceAudience-$TargetAudience") {
    "small-medium" {
        @{
            Gate = "adversarial-review"
            Title = "🔍 Adversarial Review Gate: Small → Medium"
            Description = "Party mode review complete. All small-audience phases (preplan, businessplan, techplan) ready for lead review."
            Checklist = @(
                "- [ ] PrePlan artifacts complete (if applicable)",
                "- [ ] BusinessPlan/PRD complete",
                "- [ ] TechPlan/Architecture complete",
                "- [ ] Adversarial review feedback addressed",
                "- [ ] Cross-agent validation passed"
            )
            Labels = @("lens-promotion", "adversarial-review", "small-to-medium")
        }
    }
    "medium-large" {
        @{
            Gate = "stakeholder-approval"
            Title = "👥 Stakeholder Approval Gate: Medium → Large"
            Description = "DevProposal phase complete. Epics, stories, and readiness checklist ready for stakeholder review."
            Checklist = @(
                "- [ ] Epics defined and validated",
                "- [ ] User stories generated with acceptance criteria",
                "- [ ] Story estimates complete",
                "- [ ] Dependencies mapped",
                "- [ ] Readiness checklist passed"
            )
            Labels = @("lens-promotion", "stakeholder-approval", "medium-to-large")
        }
    }
    "large-base" {
        @{
            Gate = "constitution-gate"
            Title = "📋 Constitution Gate: Large → Base"
            Description = "SprintPlan complete. Ready for development execution in target projects."
            Checklist = @(
                "- [ ] Sprint plan approved",
                "- [ ] Story assignments confirmed",
                "- [ ] Constitution compliance verified",
                "- [ ] Development branch strategy confirmed",
                "- [ ] Team capacity validated"
            )
            Labels = @("lens-promotion", "constitution-gate", "large-to-base")
        }
    }
}

# Build branch names
$sourceBranch = "$InitiativeRoot-$SourceAudience"
$targetBranch = if ($TargetAudience -eq "base") { $InitiativeRoot } else { "$InitiativeRoot-$TargetAudience" }

Write-Info "`nPromotion Details:"
Write-Info "  Gate: $($gateInfo.Gate)"
Write-Info "  Source: $sourceBranch"
Write-Info "  Target: $targetBranch"
Write-Info "  Repository: $RepoOwner/$RepoName"

if ($DryRun) {
    Write-Warning "`n[DRY RUN MODE - No changes will be made]"
}

# Check if branches exist locally
Write-Info "`nVerifying branches..."
$sourceBranchExists = (git rev-parse --verify $sourceBranch 2>$null)
if (-not $sourceBranchExists) {
    Write-Error "Source branch not found locally: $sourceBranch"
    exit 1
}
Write-Success "✓ Source branch exists"

# Create target branch if needed
if ($TargetAudience -eq "base") {
    $targetBranchExists = (git rev-parse --verify $targetBranch 2>$null)
    if (-not $targetBranchExists -and -not $DryRun) {
        Write-Info "Creating base branch: $targetBranch"
        git checkout -b $targetBranch $sourceBranch
        git push -u origin $targetBranch
    }
} else {
    $targetBranchExists = (git rev-parse --verify $targetBranch 2>$null)
    if (-not $targetBranchExists -and -not $DryRun) {
        Write-Info "Creating target audience branch: $targetBranch"
        git checkout -b $targetBranch
        git push -u origin $targetBranch
    }
}
Write-Success "✓ Target branch ready"

# Push source branch to ensure it's up to date
if (-not $DryRun) {
    Write-Info "Pushing source branch..."
    git push origin $sourceBranch
}

# Generate PR body
$prBody = @"
## $($gateInfo.Description)

This pull request represents the **$($gateInfo.Gate)** for audience promotion from ``$SourceAudience`` to ``$TargetAudience``.

---

### 📋 Promotion Checklist

$($gateInfo.Checklist -join "`n")

---

### 🎯 Audience Progression

\`\`\`mermaid
graph LR
    A[small] -->|adversarial-review| B[medium]
    B -->|stakeholder-approval| C[large]
    C -->|constitution-gate| D[base]

    style $(if ($SourceAudience -eq "small") { "A" } elseif ($SourceAudience -eq "medium") { "B" } else { "C" }) fill:#90EE90
    style $(if ($TargetAudience -eq "medium") { "B" } elseif ($TargetAudience -eq "large") { "C" } else { "D" }) fill:#FFD700
\`\`\`

---

### 📁 Files Changed

Review the changes from all completed phases in the **$SourceAudience** audience.

---

### ⚙️ Lifecycle v2 Information

- **Initiative:** ``$InitiativeRoot``
- **Promotion Type:** ``$($gateInfo.Gate)``
- **Source Audience:** ``$SourceAudience``
- **Target Audience:** ``$TargetAudience``
- **Branch Pattern:** v2.0.0 named phases

---

### 🚀 Next Steps

After this PR is merged:
$(
    switch ($TargetAudience) {
        "medium" { "1. Run ``/devproposal`` to begin the DevProposal phase`n2. Complete epics and story generation`n3. Prepare readiness checklist" }
        "large" { "1. Run ``/sprintplan`` to begin sprint planning`n2. Confirm story assignments`n3. Prepare for development handoff" }
        "base" { "1. Run ``/dev`` to begin implementation`n2. Create feature branches in target projects`n3. Begin development sprints" }
    }
)

---

_Generated by LENS Workbench v2.0.0 Audience Promotion_
"@

# Create PR using GitHub API
if (-not $DryRun) {
    Write-Info "`nCreating pull request via GitHub API..."

    # Prepare API request
    $apiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/pulls"
    $headers = @{
        "Authorization" = "Bearer $Pat"
        "Accept" = "application/vnd.github.v3+json"
    }

    $prData = @{
        title = $gateInfo.Title
        body = $prBody
        head = $sourceBranch
        base = $targetBranch
        draft = $false
    } | ConvertTo-Json -Depth 10

    try {
        # Create the pull request
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $prData -ContentType "application/json"

        Write-Success "`n✅ Pull request created successfully!"
        Write-Success "PR Number: #$($response.number)"
        Write-Success "PR URL: $($response.html_url)"

        # Add labels if PR was created successfully
        if ($response.number) {
            Write-Info "Adding labels..."
            $labelsUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/issues/$($response.number)/labels"
            $labelsData = @{
                labels = $gateInfo.Labels
            } | ConvertTo-Json

            try {
                Invoke-RestMethod -Uri $labelsUrl -Method Post -Headers $headers -Body $labelsData -ContentType "application/json" | Out-Null
                Write-Success "✓ Labels added"
            } catch {
                Write-Warning "Could not add labels: $_"
            }
        }

        # Save PR info to file for reference
        $prInfo = @{
            number = $response.number
            url = $response.html_url
            title = $gateInfo.Title
            created_at = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            source_branch = $sourceBranch
            target_branch = $targetBranch
            promotion_type = $gateInfo.Gate
        }

        $prInfoPath = "_bmad-output/lens-work/promotion-prs/$InitiativeRoot-$($gateInfo.Gate)-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
        New-Item -ItemType Directory -Force -Path (Split-Path $prInfoPath) | Out-Null
        $prInfo | ConvertTo-Json | Out-File $prInfoPath
        Write-Info "PR info saved to: $prInfoPath"

    } catch {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($errorDetail.message) {
            Write-Error "GitHub API Error: $($errorDetail.message)"
            if ($errorDetail.errors) {
                foreach ($err in $errorDetail.errors) {
                    Write-Error "  - $($err.message)"
                }
            }
        } else {
            Write-Error "Failed to create pull request: $_"
        }
        exit 1
    }
} else {
    Write-Warning "`n[DRY RUN] Would create PR via API:"
    Write-Info "  URL: https://api.github.com/repos/$RepoOwner/$RepoName/pulls"
    Write-Info "  Title: $($gateInfo.Title)"
    Write-Info "  Base: $targetBranch"
    Write-Info "  Head: $sourceBranch"
    Write-Info "  Labels: $($gateInfo.Labels -join ', ')"
    Write-Info "`nPR Body Preview:"
    Write-Host $prBody
}

Write-Info "`n======================================"
Write-Success "Promotion PR script complete!"
Write-Info "======================================`n"