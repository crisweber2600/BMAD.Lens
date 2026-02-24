# LENS Workbench v2.0.0 - BMAD Process Pre-flight Check
# =============================================================================
# Runs automatically before EVERY BMAD process to ensure correct branch
# This should be integrated into BMAD's execution flow
# =============================================================================

param(
    [string]$ProcessName = $env:BMAD_PROCESS_NAME,
    [string]$Command = $env:BMAD_COMMAND,
    [string]$StateFile = "_bmad-output/lens-work/state.yaml",
    [switch]$Force = $false,
    [switch]$SkipFetch = $false,
    [switch]$Silent = $false
)

# Set up logging
$script:LogFile = "_bmad-output/lens-work/preflight-checks.jsonl"
$script:Silent = $Silent

function Write-Log {
    param($Message, $Level = "INFO")
    $logEntry = @{
        timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")
        level = $Level
        message = $Message
        process = $ProcessName
        command = $Command
    } | ConvertTo-Json -Compress

    # Always write to log file
    Add-Content -Path $script:LogFile -Value $logEntry -ErrorAction SilentlyContinue

    # Console output unless silent
    if (-not $script:Silent) {
        switch ($Level) {
            "ERROR" { Write-Host "❌ $Message" -ForegroundColor Red }
            "WARNING" { Write-Host "⚠️  $Message" -ForegroundColor Yellow }
            "SUCCESS" { Write-Host "✅ $Message" -ForegroundColor Green }
            "DEBUG" { if ($env:BMAD_DEBUG) { Write-Host "🔍 $Message" -ForegroundColor Gray } }
            default { Write-Host "ℹ️  $Message" -ForegroundColor Cyan }
        }
    }
}

# Create log directory if needed
$logDir = Split-Path $LogFile
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
}

Write-Log "BMAD Pre-flight Check Starting" "INFO"
Write-Log "Process: $ProcessName, Command: $Command" "DEBUG"

# 1. Check if we're in a git repository
$gitDir = git rev-parse --git-dir 2>$null
if (-not $gitDir) {
    # Check if this is a BMAD control repo command
    $requiresGit = $ProcessName -match "lens-work|workflow|initiative"
    if ($requiresGit -and -not $Force) {
        Write-Log "Not in a git repository - BMAD control repo required" "ERROR"
        exit 1
    }
    Write-Log "Not in git repository - skipping branch check" "INFO"
    exit 0
}

# 2. Safe commands that don't need branch switching
$safeCommands = @("help", "status", "config", "version", "list", "show")
$isSafeCommand = $false
foreach ($safe in $safeCommands) {
    if ($Command -like "*$safe*" -or $ProcessName -like "*$safe*") {
        $isSafeCommand = $true
        break
    }
}

# 3. Get current branch
$currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
Write-Log "Current branch: $currentBranch" "INFO"

# 4. Fetch latest (unless skipped or safe command)
if (-not $SkipFetch -and -not $isSafeCommand) {
    Write-Log "Fetching latest from remote..." "INFO"
    git fetch --all --quiet --prune 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to fetch from remote (may be offline)" "WARNING"
    }
}

# 5. Check for uncommitted changes
$hasChanges = git status --porcelain
if ($hasChanges -and -not $isSafeCommand -and -not $Force) {
    Write-Log "Uncommitted changes detected" "WARNING"

    # Show what's changed
    if (-not $Silent) {
        Write-Host "`nUncommitted changes:" -ForegroundColor Yellow
        git status --short
        Write-Host ""
    }

    # Check if emergency override is set
    if ($env:BMAD_EMERGENCY_OVERRIDE -eq "true") {
        Write-Log "Emergency override active - stashing changes" "WARNING"
        $stashMsg = "Auto-stash by BMAD preflight at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        git stash push -m $stashMsg
        $script:StashedChanges = $true
    } else {
        Write-Log "Please commit or stash changes before proceeding" "ERROR"
        Write-Log "Run 'git stash' to temporarily save changes" "INFO"
        exit 1
    }
}

# 6. Load state to determine expected branch
if (-not (Test-Path $StateFile)) {
    Write-Log "No state file found - using default branch" "INFO"

    # Get default branch
    $defaultBranch = git symbolic-ref refs/remotes/origin/HEAD 2>$null |
        ForEach-Object { $_ -replace '^refs/remotes/origin/', '' }
    if (-not $defaultBranch) {
        $defaultBranch = if (git rev-parse --verify origin/main 2>$null) { "main" } else { "master" }
    }

    if ($currentBranch -ne $defaultBranch -and -not $isSafeCommand) {
        Write-Log "Switching to default branch: $defaultBranch" "INFO"
        git checkout $defaultBranch 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Switched to $defaultBranch" "SUCCESS"
        }
    }
    exit 0
}

# Parse state file
$stateContent = Get-Content $StateFile -Raw
$activeInitiative = if ($stateContent -match "active_initiative:\s*([^\s]+)" -and $Matches[1] -ne "null") {
    $Matches[1]
} else {
    $null
}
$currentPhase = if ($stateContent -match "current_phase:\s*([^\s]+)" -and $Matches[1] -ne "null") {
    $Matches[1]
} else {
    $null
}
$workflowStatus = if ($stateContent -match "workflow_status:\s*([^\s]+)") {
    $Matches[1]
} else {
    "idle"
}

Write-Log "State: Initiative=$activeInitiative, Phase=$currentPhase, Status=$workflowStatus" "DEBUG"

# 7. Determine expected branch
if (-not $activeInitiative) {
    # No active initiative
    $expectedBranch = $null
} else {
    # Get initiative root
    $initiativeRoot = $activeInitiative
    $configPath = "_bmad-output/lens-work/initiatives/$activeInitiative.yaml"
    if (Test-Path $configPath) {
        $configContent = Get-Content $configPath -Raw
        if ($configContent -match "initiative_root:\s*([^\s]+)") {
            $initiativeRoot = $Matches[1]
        }
    }

    # Determine audience from phase
    $audience = switch ($currentPhase) {
        "preplan" { "small" }
        "businessplan" { "small" }
        "techplan" { "small" }
        "devproposal" { "medium" }
        "sprintplan" { "large" }
        "dev" { "base" }
        default { $null }
    }

    # Build expected branch
    if ($workflowStatus -eq "running" -and $currentPhase -and $audience) {
        # Active workflow - phase branch
        $expectedBranch = if ($audience -eq "base") {
            $initiativeRoot
        } else {
            "$initiativeRoot-$audience-$currentPhase"
        }
    } elseif ($audience) {
        # Between workflows - audience branch
        $expectedBranch = if ($audience -eq "base") {
            $initiativeRoot
        } else {
            "$initiativeRoot-$audience"
        }
    } else {
        # No phase - initiative root
        $expectedBranch = $initiativeRoot
    }
}

Write-Log "Expected branch: $expectedBranch" "INFO"

# 8. Switch branch if needed (unless safe command)
if ($expectedBranch -and $currentBranch -ne $expectedBranch -and -not $isSafeCommand) {
    Write-Log "Branch mismatch - switching from $currentBranch to $expectedBranch" "INFO"

    # Check if expected branch exists
    $branchExists = git rev-parse --verify $expectedBranch 2>$null
    if ($branchExists) {
        git checkout $expectedBranch 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Switched to $expectedBranch" "SUCCESS"

            # Pull latest
            git pull origin $expectedBranch --quiet 2>$null

            # Restore stash if we stashed earlier
            if ($script:StashedChanges) {
                Write-Log "Restoring stashed changes..." "INFO"
                git stash pop --quiet
            }
        } else {
            Write-Log "Failed to switch branch" "ERROR"
            exit 1
        }
    } else {
        # Branch doesn't exist
        if ($env:BMAD_AUTO_CREATE_BRANCH -eq "true") {
            Write-Log "Creating branch: $expectedBranch" "INFO"

            # Determine base branch
            $baseBranch = if ($audience -and $audience -ne "base") {
                "$initiativeRoot-$audience"
            } else {
                $initiativeRoot
            }

            git checkout -b $expectedBranch $baseBranch 2>$null
            if ($LASTEXITCODE -eq 0) {
                git push -u origin $expectedBranch 2>$null
                Write-Log "Created and pushed branch: $expectedBranch" "SUCCESS"
            }
        } else {
            Write-Log "Expected branch does not exist: $expectedBranch" "ERROR"
            Write-Log "Set BMAD_AUTO_CREATE_BRANCH=true to auto-create" "INFO"
            exit 1
        }
    }
} elseif ($expectedBranch -and $currentBranch -eq $expectedBranch) {
    Write-Log "Already on correct branch" "SUCCESS"

    # Check if behind remote (unless safe command)
    if (-not $isSafeCommand) {
        $behind = git rev-list --count HEAD..origin/$currentBranch 2>$null
        if ($behind -gt 0) {
            Write-Log "Branch is $behind commits behind remote - updating..." "INFO"
            git pull origin $currentBranch --quiet
        }
    }
}

# 9. Record successful preflight
$record = @{
    timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")
    process = $ProcessName
    command = $Command
    branch = git rev-parse --abbrev-ref HEAD
    initiative = $activeInitiative
    phase = $currentPhase
    status = "success"
} | ConvertTo-Json -Compress

Add-Content -Path "_bmad-output/lens-work/preflight-success.jsonl" -Value $record

Write-Log "Pre-flight check complete" "SUCCESS"
exit 0