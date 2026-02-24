# LENS Workbench v2.0.0 - Chat Startup Branch Check
# =============================================================================
# Ensures correct branch is checked out at the beginning of every chat session
# Should be run automatically when starting work with LENS
# =============================================================================

param(
    [string]$StateFile = "_bmad-output/lens-work/state.yaml",
    [switch]$AutoSwitch = $true,
    [switch]$CreateIfMissing = $false
)

# Color output functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Write-Info "======================================"
Write-Info "LENS Workbench - Branch Check"
Write-Info "======================================"
Write-Info "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Info ""

# First, ensure we're in a git repository
$gitDir = git rev-parse --git-dir 2>$null
if (-not $gitDir) {
    Write-Error "Not in a git repository!"
    exit 1
}

# Fetch latest from remote to ensure we're up to date
Write-Info "Fetching latest from remote..."
git fetch --all --quiet

# Get current branch
$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Info "Current branch: $currentBranch"

# Check if state file exists
if (-not (Test-Path $StateFile)) {
    Write-Warning "State file not found: $StateFile"
    Write-Info "No active initiative. Staying on current branch."

    # Check if we're on a safe default branch
    if ($currentBranch -match "^(main|master|develop|release/.*)$") {
        Write-Success "✓ On safe default branch: $currentBranch"
    } else {
        Write-Warning "⚠ On feature branch without active initiative"
        Write-Warning "Consider running /new-domain, /new-service, or /new-feature to start"
    }
    exit 0
}

# Load state file to get active initiative and phase
Write-Info "Loading state from: $StateFile"
$stateContent = Get-Content $StateFile -Raw

# Parse active initiative
$activeInitiative = $null
if ($stateContent -match "active_initiative:\s*([^\s]+)") {
    $activeInitiative = $Matches[1]
    if ($activeInitiative -eq "null") {
        $activeInitiative = $null
    }
}

# Parse current phase
$currentPhase = $null
if ($stateContent -match "current_phase:\s*([^\s]+)") {
    $currentPhase = $Matches[1]
    if ($currentPhase -eq "null") {
        $currentPhase = $null
    }
}

# Parse workflow status
$workflowStatus = "idle"
if ($stateContent -match "workflow_status:\s*([^\s]+)") {
    $workflowStatus = $Matches[1]
}

Write-Info ""
Write-Info "State Information:"
Write-Info "  Active Initiative: $(if ($activeInitiative) { $activeInitiative } else { 'none' })"
Write-Info "  Current Phase: $(if ($currentPhase) { $currentPhase } else { 'none' })"
Write-Info "  Workflow Status: $workflowStatus"

# If no active initiative, suggest safe branch
if (-not $activeInitiative) {
    Write-Warning "No active initiative set"

    # Suggest switching to main/develop
    $defaultBranch = git symbolic-ref refs/remotes/origin/HEAD 2>$null | ForEach-Object { $_ -replace '^refs/remotes/origin/', '' }
    if (-not $defaultBranch) {
        $defaultBranch = if (git rev-parse --verify origin/main 2>$null) { "main" } else { "master" }
    }

    if ($currentBranch -ne $defaultBranch -and $AutoSwitch) {
        Write-Info "Switching to default branch: $defaultBranch"
        git checkout $defaultBranch
        Write-Success "✓ Switched to $defaultBranch"
    } elseif ($currentBranch -eq $defaultBranch) {
        Write-Success "✓ Already on default branch"
    }
    exit 0
}

# Load initiative config to get more details
$initiativeConfigPath = "_bmad-output/lens-work/initiatives/$activeInitiative.yaml"
if (-not (Test-Path $initiativeConfigPath)) {
    # Try domain/service paths
    $alternativePaths = @(
        "_bmad-output/lens-work/initiatives/*/Domain.yaml",
        "_bmad-output/lens-work/initiatives/*/*/Service.yaml",
        "_bmad-output/lens-work/initiatives/*/$activeInitiative.yaml"
    )

    foreach ($path in $alternativePaths) {
        $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $initiativeConfigPath = $found.FullName
            break
        }
    }
}

# Parse initiative root from config
$initiativeRoot = $activeInitiative  # Default to initiative ID
if (Test-Path $initiativeConfigPath) {
    $initiativeConfig = Get-Content $initiativeConfigPath -Raw
    if ($initiativeConfig -match "initiative_root:\s*([^\s]+)") {
        $initiativeRoot = $Matches[1]
    }
}

# Determine expected branch based on workflow status and phase
Write-Info ""
Write-Info "Branch Analysis:"

# Determine audience for current phase (from lifecycle.yaml knowledge)
$phaseAudience = switch ($currentPhase) {
    "preplan"      { "small" }
    "businessplan" { "small" }
    "techplan"     { "small" }
    "devproposal"  { "medium" }
    "sprintplan"   { "large" }
    "dev"          { "base" }
    default        { $null }
}

# Build expected branch name
$expectedBranch = $null
if ($workflowStatus -eq "running" -and $currentPhase -and $phaseAudience) {
    # Active workflow - should be on phase branch
    if ($phaseAudience -eq "base") {
        $expectedBranch = $initiativeRoot
    } else {
        $expectedBranch = "$initiativeRoot-$phaseAudience-$currentPhase"
    }
    Write-Info "  Expected branch (active workflow): $expectedBranch"
} elseif ($phaseAudience) {
    # Between workflows - should be on audience branch
    if ($phaseAudience -eq "base") {
        $expectedBranch = $initiativeRoot
    } else {
        $expectedBranch = "$initiativeRoot-$phaseAudience"
    }
    Write-Info "  Expected branch (audience level): $expectedBranch"
} else {
    # No phase - on initiative root
    $expectedBranch = $initiativeRoot
    Write-Info "  Expected branch (initiative root): $expectedBranch"
}

# Check if we're on the expected branch
if ($currentBranch -eq $expectedBranch) {
    Write-Success "✓ Already on correct branch: $currentBranch"

    # Check if branch is behind remote
    $behind = git rev-list --count HEAD..origin/$currentBranch 2>$null
    if ($behind -gt 0) {
        Write-Warning "⚠ Branch is $behind commits behind origin"
        Write-Info "Run 'git pull' to update"
    }
} else {
    Write-Warning "⚠ Not on expected branch"
    Write-Info "  Current: $currentBranch"
    Write-Info "  Expected: $expectedBranch"

    if ($AutoSwitch) {
        # Check if expected branch exists
        $branchExists = git rev-parse --verify $expectedBranch 2>$null

        if ($branchExists) {
            Write-Info "Switching to expected branch..."

            # Check for uncommitted changes
            $hasChanges = git status --porcelain
            if ($hasChanges) {
                Write-Warning "You have uncommitted changes. Please commit or stash them first."
                Write-Warning "Run: git stash"
                exit 1
            }

            git checkout $expectedBranch
            if ($LASTEXITCODE -eq 0) {
                Write-Success "✓ Switched to: $expectedBranch"

                # Pull latest
                git pull origin $expectedBranch 2>$null
            } else {
                Write-Error "Failed to switch branch"
                exit 1
            }
        } elseif ($CreateIfMissing) {
            Write-Info "Creating expected branch: $expectedBranch"

            # Determine base branch for new branch
            $baseBranch = if ($phaseAudience -and $phaseAudience -ne "base") {
                "$initiativeRoot-$phaseAudience"
            } else {
                $initiativeRoot
            }

            # Check if base branch exists
            if (git rev-parse --verify $baseBranch 2>$null) {
                git checkout -b $expectedBranch $baseBranch
                Write-Success "✓ Created and switched to: $expectedBranch"
            } else {
                Write-Error "Cannot create branch - base branch not found: $baseBranch"
                exit 1
            }
        } else {
            Write-Error "Expected branch does not exist: $expectedBranch"
            Write-Info "Run with -CreateIfMissing to create it"
            exit 1
        }
    } else {
        Write-Warning "AutoSwitch is disabled. Run with -AutoSwitch to switch automatically"
    }
}

# Display summary
Write-Info ""
Write-Info "======================================"
Write-Success "Branch Check Complete"
Write-Info "======================================"
Write-Info "Initiative: $activeInitiative"
Write-Info "Phase: $(if ($currentPhase) { $currentPhase } else { 'none' })"
Write-Info "Branch: $(git rev-parse --abbrev-ref HEAD)"
Write-Info ""

# Save check timestamp
$checkInfo = @{
    timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    branch = git rev-parse --abbrev-ref HEAD
    initiative = $activeInitiative
    phase = $currentPhase
    status = "checked"
}

$checkDir = "_bmad-output/lens-work/branch-checks"
New-Item -ItemType Directory -Force -Path $checkDir | Out-Null
$checkInfo | ConvertTo-Json | Out-File "$checkDir/last-check.json"

exit 0