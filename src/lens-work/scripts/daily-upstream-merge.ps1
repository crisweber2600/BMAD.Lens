# LENS Workbench v2.0.0 - Daily Upstream Merge Automation
# =============================================================================
# Automates daily merges from feature/base branches up to default branch
# Hierarchy: feature/base → service → domain → default (main/master)
# Should be run daily via scheduled task or cron job
# =============================================================================

param(
    [string]$DefaultBranch = "",
    [string]$Pat = $env:GITHUB_PAT,
    [switch]$DryRun = $false,
    [switch]$CreatePRs = $true,  # Create PRs instead of direct merge for safety
    [switch]$AutoMerge = $false, # Auto-merge PRs if all checks pass
    [string]$LogDir = "_bmad-output/lens-work/merge-logs"
)

# Color output functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

# Initialize log
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = "$LogDir/daily-merge-$timestamp.log"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Write-Log {
    param($Message, $Level = "INFO")
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$Level] $Message"
    Add-Content -Path $logFile -Value $logEntry

    switch ($Level) {
        "SUCCESS" { Write-Success $Message }
        "ERROR" { Write-Error $Message }
        "WARNING" { Write-Warning $Message }
        default { Write-Info $Message }
    }
}

Write-Log "======================================" "INFO"
Write-Log "Daily Upstream Merge - LENS Workbench" "INFO"
Write-Log "======================================" "INFO"
Write-Log "Start Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "INFO"

# Ensure we're in a git repository
$gitDir = git rev-parse --git-dir 2>$null
if (-not $gitDir) {
    Write-Log "Not in a git repository!" "ERROR"
    exit 1
}

# Get default branch if not specified
if (-not $DefaultBranch) {
    $DefaultBranch = git symbolic-ref refs/remotes/origin/HEAD 2>$null | ForEach-Object { $_ -replace '^refs/remotes/origin/', '' }
    if (-not $DefaultBranch) {
        $DefaultBranch = if (git rev-parse --verify origin/main 2>$null) { "main" } else { "master" }
    }
}
Write-Log "Default branch: $DefaultBranch" "INFO"

# Get repository info for PR creation
$remoteUrl = git config --get remote.origin.url
if ($remoteUrl -match "github\.com[:/]([^/]+)/([^/\.]+)") {
    $RepoOwner = $Matches[1]
    $RepoName = $Matches[2]
    Write-Log "Repository: $RepoOwner/$RepoName" "INFO"
} else {
    Write-Log "Could not detect GitHub repository" "WARNING"
    $CreatePRs = $false  # Fall back to direct merge
}

# Fetch latest from all remotes
Write-Log "Fetching latest from remotes..." "INFO"
git fetch --all --prune

# Function to get all branches matching a pattern
function Get-BranchesMatching {
    param($Pattern)
    $branches = git branch -r | ForEach-Object { $_.Trim() -replace '^origin/', '' } |
        Where-Object { $_ -match $Pattern -and $_ -notmatch '^HEAD' } |
        Sort-Object -Unique
    return $branches
}

# Function to check if branch has unique commits
function Test-BranchHasCommits {
    param($SourceBranch, $TargetBranch)
    $commits = git rev-list --count "$TargetBranch..$SourceBranch" 2>$null
    return ($commits -gt 0)
}

# Function to create merge PR via GitHub API
function New-MergePR {
    param($Source, $Target, $Title, $Body)

    if (-not $Pat) {
        Write-Log "No GitHub PAT available, skipping PR creation" "WARNING"
        return $null
    }

    $prData = @{
        title = $Title
        body = $Body
        head = $Source
        base = $Target
        draft = $false
    } | ConvertTo-Json

    $apiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/pulls"
    $headers = @{
        "Authorization" = "Bearer $Pat"
        "Accept" = "application/vnd.github.v3+json"
    }

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $prData -ContentType "application/json"
        Write-Log "Created PR #$($response.number): $Title" "SUCCESS"

        # Add auto-merge label if requested
        if ($AutoMerge -and $response.number) {
            $labelsUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/issues/$($response.number)/labels"
            $labelsData = @{ labels = @("auto-merge", "daily-upstream-sync") } | ConvertTo-Json
            Invoke-RestMethod -Uri $labelsUrl -Method Post -Headers $headers -Body $labelsData -ContentType "application/json" | Out-Null
        }

        return $response.number
    } catch {
        $errorMsg = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($errorMsg.errors[0].message -like "*A pull request already exists*") {
            Write-Log "PR already exists for $Source → $Target" "WARNING"
        } else {
            Write-Log "Failed to create PR: $_" "ERROR"
        }
        return $null
    }
}

# Build merge hierarchy
Write-Log "" "INFO"
Write-Log "Building merge hierarchy..." "INFO"

$mergeQueue = @()

# 1. Find all base/feature branches that need to merge to service branches
$featureBranches = Get-BranchesMatching "^[a-z0-9-]+-[a-z0-9-]+-[a-z0-9-]+$"
foreach ($feature in $featureBranches) {
    # Parse the branch structure (e.g., ecom-chkt-payment-gateway)
    if ($feature -match "^([a-z0-9]+)-([a-z0-9]+)-(.+)$") {
        $domain = $Matches[1]
        $service = $Matches[2]

        # Check if service branch exists
        $serviceBranch = "$domain-$service"
        if (git rev-parse --verify "origin/$serviceBranch" 2>$null) {
            if (Test-BranchHasCommits $feature $serviceBranch) {
                $mergeQueue += @{
                    Source = $feature
                    Target = $serviceBranch
                    Level = "feature-to-service"
                    Priority = 1
                }
            }
        }
    }
}

# 2. Find all service branches that need to merge to domain branches
$serviceBranches = Get-BranchesMatching "^[a-z0-9]+-[a-z0-9]+$"
foreach ($service in $serviceBranches) {
    if ($service -match "^([a-z0-9]+)-[a-z0-9]+$") {
        $domain = $Matches[1]

        # Check if domain branch exists
        $domainBranch = $domain
        if (git rev-parse --verify "origin/$domainBranch" 2>$null) {
            if (Test-BranchHasCommits $service $domainBranch) {
                $mergeQueue += @{
                    Source = $service
                    Target = $domainBranch
                    Level = "service-to-domain"
                    Priority = 2
                }
            }
        }
    }
}

# 3. Find all domain branches that need to merge to default branch
$domainBranches = Get-BranchesMatching "^[a-z0-9]+$" | Where-Object {
    $_ -ne $DefaultBranch -and $_ -ne "main" -and $_ -ne "master" -and $_ -ne "develop"
}
foreach ($domain in $domainBranches) {
    if (Test-BranchHasCommits $domain $DefaultBranch) {
        $mergeQueue += @{
            Source = $domain
            Target = $DefaultBranch
            Level = "domain-to-default"
            Priority = 3
        }
    }
}

# 4. Check for any release branches that need to merge to default
$releaseBranches = Get-BranchesMatching "^release/"
foreach ($release in $releaseBranches) {
    if (Test-BranchHasCommits $release $DefaultBranch) {
        $mergeQueue += @{
            Source = $release
            Target = $DefaultBranch
            Level = "release-to-default"
            Priority = 4
        }
    }
}

# Sort by priority to ensure proper merge order
$mergeQueue = $mergeQueue | Sort-Object Priority

Write-Log "Found $($mergeQueue.Count) branches requiring upstream merge" "INFO"

if ($mergeQueue.Count -eq 0) {
    Write-Log "No merges needed - all branches are up to date!" "SUCCESS"
    exit 0
}

# Display merge plan
Write-Log "" "INFO"
Write-Log "Merge Plan:" "INFO"
foreach ($merge in $mergeQueue) {
    Write-Log "  $($merge.Source) → $($merge.Target) [$($merge.Level)]" "INFO"
}

if ($DryRun) {
    Write-Log "" "WARNING"
    Write-Log "[DRY RUN MODE] No actual merges will be performed" "WARNING"
    exit 0
}

# Execute merges
Write-Log "" "INFO"
Write-Log "Executing merges..." "INFO"

$successCount = 0
$failureCount = 0
$prNumbers = @()

foreach ($merge in $mergeQueue) {
    Write-Log "" "INFO"
    Write-Log "Processing: $($merge.Source) → $($merge.Target)" "INFO"

    if ($CreatePRs) {
        # Create a PR for the merge
        $prTitle = "🔄 Daily Upstream Sync: $($merge.Source) → $($merge.Target)"
        $prBody = @"
## Automated Daily Upstream Merge

This pull request automatically syncs changes from **$($merge.Source)** to **$($merge.Target)**.

### Merge Details
- **Type:** $($merge.Level)
- **Source Branch:** ``$($merge.Source)``
- **Target Branch:** ``$($merge.Target)``
- **Automated:** Daily upstream synchronization

### Changes Included
\`\`\`bash
git log --oneline $($merge.Target)..$($merge.Source)
\`\`\`

### Merge Hierarchy
\`\`\`
feature/base → service → domain → $DefaultBranch
\`\`\`

---

_Generated by LENS Workbench Daily Upstream Merge_
_Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')_
"@

        $prNumber = New-MergePR -Source $merge.Source -Target $merge.Target -Title $prTitle -Body $prBody
        if ($prNumber) {
            $successCount++
            $prNumbers += $prNumber
        } else {
            $failureCount++
        }
    } else {
        # Direct merge (less safe, not recommended for production)
        Write-Log "Attempting direct merge..." "WARNING"

        # Checkout target branch
        git checkout $merge.Target 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Failed to checkout $($merge.Target)" "ERROR"
            $failureCount++
            continue
        }

        # Pull latest
        git pull origin $merge.Target

        # Attempt merge
        git merge "origin/$($merge.Source)" --no-ff -m "Daily upstream merge: $($merge.Source) → $($merge.Target)"
        if ($LASTEXITCODE -eq 0) {
            # Push the merge
            git push origin $merge.Target
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Successfully merged $($merge.Source) → $($merge.Target)" "SUCCESS"
                $successCount++
            } else {
                Write-Log "Failed to push merge" "ERROR"
                git reset --hard "origin/$($merge.Target)"
                $failureCount++
            }
        } else {
            Write-Log "Merge conflict detected" "ERROR"
            git merge --abort
            $failureCount++
        }
    }
}

# Generate summary report
Write-Log "" "INFO"
Write-Log "======================================" "INFO"
Write-Log "Daily Merge Summary" "INFO"
Write-Log "======================================" "INFO"
Write-Log "Total Merges Attempted: $($mergeQueue.Count)" "INFO"
Write-Log "Successful: $successCount" "SUCCESS"
Write-Log "Failed: $failureCount" $(if ($failureCount -gt 0) { "ERROR" } else { "INFO" })

if ($prNumbers.Count -gt 0) {
    Write-Log "" "INFO"
    Write-Log "Created PRs: #$($prNumbers -join ', #')" "INFO"

    if ($AutoMerge) {
        Write-Log "PRs marked for auto-merge when checks pass" "INFO"
    } else {
        Write-Log "Manual review required for PR merging" "WARNING"
    }
}

# Save summary to JSON
$summary = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    default_branch = $DefaultBranch
    total_merges = $mergeQueue.Count
    successful = $successCount
    failed = $failureCount
    pr_numbers = $prNumbers
    merge_queue = $mergeQueue | ForEach-Object {
        @{
            source = $_.Source
            target = $_.Target
            level = $_.Level
        }
    }
}

$summaryPath = "$LogDir/daily-merge-summary-$timestamp.json"
$summary | ConvertTo-Json -Depth 10 | Out-File $summaryPath
Write-Log "Summary saved to: $summaryPath" "INFO"

Write-Log "" "INFO"
Write-Log "Daily upstream merge complete!" "SUCCESS"

# Return appropriate exit code
exit $(if ($failureCount -eq 0) { 0 } else { 1 })