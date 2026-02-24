#!/bin/bash
# LENS Workbench v2.0.0 - Chat Startup Branch Check
# =============================================================================
# Ensures correct branch is checked out at the beginning of every chat session
# Should be run automatically when starting work with LENS
# =============================================================================

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
error() { echo -e "${RED}✗ $1${NC}" >&2; exit 1; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
info() { echo -e "${CYAN}$1${NC}"; }
warning() { echo -e "${YELLOW}⚠ $1${NC}"; }

# Parse arguments
STATE_FILE="${1:-_bmad-output/lens-work/state.yaml}"
AUTO_SWITCH="${2:-true}"
CREATE_IF_MISSING="${3:-false}"

info "======================================"
info "LENS Workbench - Branch Check"
info "======================================"
info "Time: $(date +'%Y-%m-%d %H:%M:%S')"
echo

# Ensure we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    error "Not in a git repository!"
fi

# Fetch latest from remote
info "Fetching latest from remote..."
git fetch --all --quiet

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
info "Current branch: $CURRENT_BRANCH"

# Check if state file exists
if [[ ! -f "$STATE_FILE" ]]; then
    warning "State file not found: $STATE_FILE"
    info "No active initiative. Staying on current branch."

    # Check if we're on a safe default branch
    if [[ "$CURRENT_BRANCH" =~ ^(main|master|develop|release/.*)$ ]]; then
        success "On safe default branch: $CURRENT_BRANCH"
    else
        warning "On feature branch without active initiative"
        warning "Consider running /new-domain, /new-service, or /new-feature to start"
    fi
    exit 0
fi

# Load state file
info "Loading state from: $STATE_FILE"

# Parse active initiative
ACTIVE_INITIATIVE=$(grep "active_initiative:" "$STATE_FILE" | awk '{print $2}')
if [[ "$ACTIVE_INITIATIVE" == "null" || -z "$ACTIVE_INITIATIVE" ]]; then
    ACTIVE_INITIATIVE=""
fi

# Parse current phase
CURRENT_PHASE=$(grep "current_phase:" "$STATE_FILE" | awk '{print $2}')
if [[ "$CURRENT_PHASE" == "null" || -z "$CURRENT_PHASE" ]]; then
    CURRENT_PHASE=""
fi

# Parse workflow status
WORKFLOW_STATUS=$(grep "workflow_status:" "$STATE_FILE" | awk '{print $2}')
if [[ -z "$WORKFLOW_STATUS" ]]; then
    WORKFLOW_STATUS="idle"
fi

echo
info "State Information:"
info "  Active Initiative: ${ACTIVE_INITIATIVE:-none}"
info "  Current Phase: ${CURRENT_PHASE:-none}"
info "  Workflow Status: $WORKFLOW_STATUS"

# If no active initiative, suggest safe branch
if [[ -z "$ACTIVE_INITIATIVE" ]]; then
    warning "No active initiative set"

    # Get default branch
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    if [[ -z "$DEFAULT_BRANCH" ]]; then
        if git rev-parse --verify origin/main >/dev/null 2>&1; then
            DEFAULT_BRANCH="main"
        else
            DEFAULT_BRANCH="master"
        fi
    fi

    if [[ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" && "$AUTO_SWITCH" == "true" ]]; then
        info "Switching to default branch: $DEFAULT_BRANCH"
        git checkout "$DEFAULT_BRANCH"
        success "Switched to $DEFAULT_BRANCH"
    elif [[ "$CURRENT_BRANCH" == "$DEFAULT_BRANCH" ]]; then
        success "Already on default branch"
    fi
    exit 0
fi

# Load initiative config to get initiative root
INITIATIVE_CONFIG_PATH="_bmad-output/lens-work/initiatives/$ACTIVE_INITIATIVE.yaml"
INITIATIVE_ROOT="$ACTIVE_INITIATIVE"  # Default

# Try alternative paths for initiative config
if [[ ! -f "$INITIATIVE_CONFIG_PATH" ]]; then
    for path in "_bmad-output/lens-work/initiatives/*/Domain.yaml" \
                "_bmad-output/lens-work/initiatives/*/*/Service.yaml" \
                "_bmad-output/lens-work/initiatives/*/$ACTIVE_INITIATIVE.yaml"; do
        if [[ -f "$path" ]]; then
            INITIATIVE_CONFIG_PATH="$path"
            break
        fi
    done
fi

# Parse initiative root from config
if [[ -f "$INITIATIVE_CONFIG_PATH" ]]; then
    ROOT_FROM_CONFIG=$(grep "initiative_root:" "$INITIATIVE_CONFIG_PATH" | awk '{print $2}')
    if [[ -n "$ROOT_FROM_CONFIG" && "$ROOT_FROM_CONFIG" != "null" ]]; then
        INITIATIVE_ROOT="$ROOT_FROM_CONFIG"
    fi
fi

# Determine audience for current phase
case "$CURRENT_PHASE" in
    preplan|businessplan|techplan)
        PHASE_AUDIENCE="small"
        ;;
    devproposal)
        PHASE_AUDIENCE="medium"
        ;;
    sprintplan)
        PHASE_AUDIENCE="large"
        ;;
    dev)
        PHASE_AUDIENCE="base"
        ;;
    *)
        PHASE_AUDIENCE=""
        ;;
esac

echo
info "Branch Analysis:"

# Build expected branch name
if [[ "$WORKFLOW_STATUS" == "running" && -n "$CURRENT_PHASE" && -n "$PHASE_AUDIENCE" ]]; then
    # Active workflow - should be on phase branch
    if [[ "$PHASE_AUDIENCE" == "base" ]]; then
        EXPECTED_BRANCH="$INITIATIVE_ROOT"
    else
        EXPECTED_BRANCH="$INITIATIVE_ROOT-$PHASE_AUDIENCE-$CURRENT_PHASE"
    fi
    info "  Expected branch (active workflow): $EXPECTED_BRANCH"
elif [[ -n "$PHASE_AUDIENCE" ]]; then
    # Between workflows - should be on audience branch
    if [[ "$PHASE_AUDIENCE" == "base" ]]; then
        EXPECTED_BRANCH="$INITIATIVE_ROOT"
    else
        EXPECTED_BRANCH="$INITIATIVE_ROOT-$PHASE_AUDIENCE"
    fi
    info "  Expected branch (audience level): $EXPECTED_BRANCH"
else
    # No phase - on initiative root
    EXPECTED_BRANCH="$INITIATIVE_ROOT"
    info "  Expected branch (initiative root): $EXPECTED_BRANCH"
fi

# Check if we're on the expected branch
if [[ "$CURRENT_BRANCH" == "$EXPECTED_BRANCH" ]]; then
    success "Already on correct branch: $CURRENT_BRANCH"

    # Check if branch is behind remote
    BEHIND=$(git rev-list --count HEAD..origin/"$CURRENT_BRANCH" 2>/dev/null)
    if [[ "$BEHIND" -gt 0 ]]; then
        warning "Branch is $BEHIND commits behind origin"
        info "Run 'git pull' to update"
    fi
else
    warning "Not on expected branch"
    info "  Current: $CURRENT_BRANCH"
    info "  Expected: $EXPECTED_BRANCH"

    if [[ "$AUTO_SWITCH" == "true" ]]; then
        # Check if expected branch exists
        if git rev-parse --verify "$EXPECTED_BRANCH" >/dev/null 2>&1; then
            info "Switching to expected branch..."

            # Check for uncommitted changes
            if [[ -n $(git status --porcelain) ]]; then
                warning "You have uncommitted changes. Please commit or stash them first."
                warning "Run: git stash"
                exit 1
            fi

            git checkout "$EXPECTED_BRANCH"
            if [[ $? -eq 0 ]]; then
                success "Switched to: $EXPECTED_BRANCH"
                git pull origin "$EXPECTED_BRANCH" 2>/dev/null
            else
                error "Failed to switch branch"
            fi
        elif [[ "$CREATE_IF_MISSING" == "true" ]]; then
            info "Creating expected branch: $EXPECTED_BRANCH"

            # Determine base branch for new branch
            if [[ -n "$PHASE_AUDIENCE" && "$PHASE_AUDIENCE" != "base" ]]; then
                BASE_BRANCH="$INITIATIVE_ROOT-$PHASE_AUDIENCE"
            else
                BASE_BRANCH="$INITIATIVE_ROOT"
            fi

            # Check if base branch exists
            if git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
                git checkout -b "$EXPECTED_BRANCH" "$BASE_BRANCH"
                success "Created and switched to: $EXPECTED_BRANCH"
            else
                error "Cannot create branch - base branch not found: $BASE_BRANCH"
            fi
        else
            error "Expected branch does not exist: $EXPECTED_BRANCH"
        fi
    else
        warning "AutoSwitch is disabled. Set second parameter to 'true' to enable"
    fi
fi

# Display summary
echo
info "======================================"
success "Branch Check Complete"
info "======================================"
info "Initiative: $ACTIVE_INITIATIVE"
info "Phase: ${CURRENT_PHASE:-none}"
info "Branch: $(git rev-parse --abbrev-ref HEAD)"
echo

# Save check timestamp
CHECK_DIR="_bmad-output/lens-work/branch-checks"
mkdir -p "$CHECK_DIR"

cat > "$CHECK_DIR/last-check.json" <<EOF
{
  "timestamp": "$(date +'%Y-%m-%d %H:%M:%S')",
  "branch": "$(git rev-parse --abbrev-ref HEAD)",
  "initiative": "$ACTIVE_INITIATIVE",
  "phase": "$CURRENT_PHASE",
  "status": "checked"
}
EOF

exit 0