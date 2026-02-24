# LENS Workbench v2.0.0 - Audience Promotion PR Creation Script
# =============================================================================
# Creates pull requests for audience promotion gates
# Usage: .\create-promotion-pr.ps1 -SourceAudience small -TargetAudience medium
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
    [switch]$DryRun = $false
)

# Color output functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Write-Info "======================================"
Write-Info "LENS Workbench Audience Promotion"
Write-Info "======================================"

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
        $state = Get-Content $StateFile -Raw | ConvertFrom-Yaml
        $InitiativeRoot = $state.active_initiative
        if (-not $InitiativeRoot) {
            Write-Error "No active initiative found in state.yaml"
            exit 1
        }
        Write-Info "Using initiative: $InitiativeRoot"
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
                "PrePlan artifacts complete (if applicable)",
                "BusinessPlan/PRD complete",
                "TechPlan/Architecture complete",
                "Adversarial review feedback addressed",
                "Cross-agent validation passed"
            )
        }
    }
    "medium-large" {
        @{
            Gate = "stakeholder-approval"
            Title = "👥 Stakeholder Approval Gate: Medium → Large"
            Description = "DevProposal phase complete. Epics, stories, and readiness checklist ready for stakeholder review."
            Checklist = @(
                "Epics defined and validated",
                "User stories generated with acceptance criteria",
                "Story estimates complete",
                "Dependencies mapped",
                "Readiness checklist passed"
            )
        }
    }
    "large-base" {
        @{
            Gate = "constitution-gate"
            Title = "📋 Constitution Gate: Large → Base"
            Description = "SprintPlan complete. Ready for development execution in target projects."
            Checklist = @(
                "Sprint plan approved",
                "Story assignments confirmed",
                "Constitution compliance verified",
                "Development branch strategy confirmed",
                "Team capacity validated"
            )
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

if ($DryRun) {
    Write-Warning "`n[DRY RUN MODE - No changes will be made]"
}

# Check if branches exist
Write-Info "`nVerifying branches..."
$sourceBranchExists = (git rev-parse --verify $sourceBranch 2>$null)
if (-not $sourceBranchExists) {
    Write-Error "Source branch not found: $sourceBranch"
    exit 1
}
Write-Success "✓ Source branch exists"

# For base target, the branch should be the initiative root
if ($TargetAudience -eq "base") {
    # Check if initiative root branch exists, if not create it
    $targetBranchExists = (git rev-parse --verify $targetBranch 2>$null)
    if (-not $targetBranchExists -and -not $DryRun) {
        Write-Info "Creating base branch: $targetBranch"
        git checkout -b $targetBranch $sourceBranch
        git push -u origin $targetBranch
    }
} else {
    # For non-base targets, create audience branch if needed
    $targetBranchExists = (git rev-parse --verify $targetBranch 2>$null)
    if (-not $targetBranchExists -and -not $DryRun) {
        Write-Info "Creating target audience branch: $targetBranch"
        git checkout -b $targetBranch
        git push -u origin $targetBranch
    }
}
Write-Success "✓ Target branch ready"

# Generate PR body
$prBody = @"
## $($gateInfo.Description)

This pull request represents the **$($gateInfo.Gate)** for audience promotion from ``$SourceAudience`` to ``$TargetAudience``.

---

### 📋 Promotion Checklist

$(($gateInfo.Checklist | ForEach-Object { "- [ ] $_" }) -join "`n")

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

Review the changes from all completed phases in the **$SourceAudience** audience:

\`\`\`bash
git diff $targetBranch...$sourceBranch --stat
\`\`\`

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

# Create the PR
if (-not $DryRun) {
    Write-Info "`nCreating pull request..."

    # Push current branch first
    git push origin $sourceBranch

    # Create PR using gh CLI
    $prCommand = @"
gh pr create `
    --title "$($gateInfo.Title)" `
    --body "$prBody" `
    --base "$targetBranch" `
    --head "$sourceBranch" `
    --label "lens-promotion,$($gateInfo.Gate)" `
    --assignee "@me"
"@

    Write-Info "Executing: $prCommand"
    Invoke-Expression $prCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Success "`n✅ Pull request created successfully!"
        Write-Success "View your PR: gh pr view --web"
    } else {
        Write-Error "Failed to create pull request"
        exit 1
    }
} else {
    Write-Warning "`n[DRY RUN] Would create PR:"
    Write-Info "  Title: $($gateInfo.Title)"
    Write-Info "  Base: $targetBranch"
    Write-Info "  Head: $sourceBranch"
    Write-Info "`nPR Body Preview:"
    Write-Host $prBody
}

Write-Info "`n======================================"
Write-Success "Promotion PR script complete!"
Write-Info "======================================`n"