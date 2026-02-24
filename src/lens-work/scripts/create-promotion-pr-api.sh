#!/bin/bash
# LENS Workbench v2.0.0 - Audience Promotion PR Creation Script (GitHub API)
# =============================================================================
# Creates pull requests for audience promotion gates using GitHub API
# Requires: GITHUB_PAT environment variable
# Usage: ./create-promotion-pr-api.sh small medium [initiative_root]
# =============================================================================

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse arguments
SOURCE_AUDIENCE=$1
TARGET_AUDIENCE=$2
INITIATIVE_ROOT=$3
DRY_RUN=${4:-false}

# Functions
error() { echo -e "${RED}✗ $1${NC}" >&2; exit 1; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
info() { echo -e "${CYAN}$1${NC}"; }
warning() { echo -e "${YELLOW}⚠ $1${NC}"; }

# Header
info "======================================"
info "LENS Workbench Audience Promotion (API)"
info "======================================"

# Check for GitHub PAT
if [[ -z "$GITHUB_PAT" ]]; then
    error "GitHub Personal Access Token required! Set GITHUB_PAT environment variable."
fi

# Validate arguments
if [[ -z "$SOURCE_AUDIENCE" || -z "$TARGET_AUDIENCE" ]]; then
    error "Usage: $0 <source_audience> <target_audience> [initiative_root] [dry_run]"
fi

# Validate promotion path
case "$SOURCE_AUDIENCE-$TARGET_AUDIENCE" in
    "small-medium"|"medium-large"|"large-base")
        success "Valid promotion: $SOURCE_AUDIENCE → $TARGET_AUDIENCE"
        ;;
    *)
        error "Invalid promotion path: $SOURCE_AUDIENCE → $TARGET_AUDIENCE\nValid: small→medium, medium→large, large→base"
        ;;
esac

# Get repository info from git remote
REMOTE_URL=$(git config --get remote.origin.url)
if [[ $REMOTE_URL =~ github\.com[:/]([^/]+)/([^/\.]+) ]]; then
    REPO_OWNER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]}"
    info "Detected repository: $REPO_OWNER/$REPO_NAME"
else
    error "Could not detect GitHub repository from remote URL"
fi

# Get initiative root from state if not provided
if [[ -z "$INITIATIVE_ROOT" ]]; then
    STATE_FILE="_bmad-output/lens-work/state.yaml"
    if [[ -f "$STATE_FILE" ]]; then
        INITIATIVE_ROOT=$(grep "active_initiative:" "$STATE_FILE" | awk '{print $2}')
        if [[ -z "$INITIATIVE_ROOT" || "$INITIATIVE_ROOT" == "null" ]]; then
            error "No active initiative found in state.yaml"
        fi
        info "Using initiative: $INITIATIVE_ROOT"
    else
        error "State file not found: $STATE_FILE"
    fi
fi

# Set gate information based on promotion type
case "$SOURCE_AUDIENCE-$TARGET_AUDIENCE" in
    "small-medium")
        GATE="adversarial-review"
        TITLE="🔍 Adversarial Review Gate: Small → Medium"
        DESC="Party mode review complete. All small-audience phases ready for lead review."
        LABELS='["lens-promotion", "adversarial-review", "small-to-medium"]'
        CHECKLIST="- [ ] PrePlan artifacts complete (if applicable)
- [ ] BusinessPlan/PRD complete
- [ ] TechPlan/Architecture complete
- [ ] Adversarial review feedback addressed
- [ ] Cross-agent validation passed"
        ;;
    "medium-large")
        GATE="stakeholder-approval"
        TITLE="👥 Stakeholder Approval Gate: Medium → Large"
        DESC="DevProposal phase complete. Epics and stories ready for stakeholder review."
        LABELS='["lens-promotion", "stakeholder-approval", "medium-to-large"]'
        CHECKLIST="- [ ] Epics defined and validated
- [ ] User stories generated with acceptance criteria
- [ ] Story estimates complete
- [ ] Dependencies mapped
- [ ] Readiness checklist passed"
        ;;
    "large-base")
        GATE="constitution-gate"
        TITLE="📋 Constitution Gate: Large → Base"
        DESC="SprintPlan complete. Ready for development execution."
        LABELS='["lens-promotion", "constitution-gate", "large-to-base"]'
        CHECKLIST="- [ ] Sprint plan approved
- [ ] Story assignments confirmed
- [ ] Constitution compliance verified
- [ ] Development branch strategy confirmed
- [ ] Team capacity validated"
        ;;
esac

# Build branch names
SOURCE_BRANCH="$INITIATIVE_ROOT-$SOURCE_AUDIENCE"
if [[ "$TARGET_AUDIENCE" == "base" ]]; then
    TARGET_BRANCH="$INITIATIVE_ROOT"
else
    TARGET_BRANCH="$INITIATIVE_ROOT-$TARGET_AUDIENCE"
fi

info "\nPromotion Details:"
info "  Gate: $GATE"
info "  Source: $SOURCE_BRANCH"
info "  Target: $TARGET_BRANCH"
info "  Repository: $REPO_OWNER/$REPO_NAME"

if [[ "$DRY_RUN" == "true" ]]; then
    warning "\n[DRY RUN MODE - No changes will be made]"
fi

# Verify source branch exists
if ! git rev-parse --verify "$SOURCE_BRANCH" >/dev/null 2>&1; then
    error "Source branch not found: $SOURCE_BRANCH"
fi
success "Source branch exists"

# Create target branch if needed
if ! git rev-parse --verify "$TARGET_BRANCH" >/dev/null 2>&1; then
    if [[ "$DRY_RUN" != "true" ]]; then
        info "Creating target branch: $TARGET_BRANCH"
        if [[ "$TARGET_AUDIENCE" == "base" ]]; then
            git checkout -b "$TARGET_BRANCH" "$SOURCE_BRANCH"
        else
            git checkout -b "$TARGET_BRANCH"
        fi
        git push -u origin "$TARGET_BRANCH"
    else
        warning "[DRY RUN] Would create branch: $TARGET_BRANCH"
    fi
fi
success "Target branch ready"

# Push source branch
if [[ "$DRY_RUN" != "true" ]]; then
    info "Pushing source branch..."
    git push origin "$SOURCE_BRANCH"
fi

# Determine next steps based on target audience
case "$TARGET_AUDIENCE" in
    "medium")
        NEXT_STEPS="1. Run \\\`/devproposal\\\` to begin the DevProposal phase
2. Complete epics and story generation
3. Prepare readiness checklist"
        ;;
    "large")
        NEXT_STEPS="1. Run \\\`/sprintplan\\\` to begin sprint planning
2. Confirm story assignments
3. Prepare for development handoff"
        ;;
    "base")
        NEXT_STEPS="1. Run \\\`/dev\\\` to begin implementation
2. Create feature branches in target projects
3. Begin development sprints"
        ;;
esac

# Generate PR body (escape backticks for JSON)
PR_BODY="## $DESC

This pull request represents the **$GATE** for audience promotion from \\\`$SOURCE_AUDIENCE\\\` to \\\`$TARGET_AUDIENCE\\\`.

---

### 📋 Promotion Checklist

$CHECKLIST

---

### 🎯 Audience Progression

\\\`\\\`\\\`mermaid
graph LR
    A[small] -->|adversarial-review| B[medium]
    B -->|stakeholder-approval| C[large]
    C -->|constitution-gate| D[base]
\\\`\\\`\\\`

---

### 📁 Files Changed

Review the changes from all completed phases in the **$SOURCE_AUDIENCE** audience.

---

### ⚙️ Lifecycle v2 Information

- **Initiative:** \\\`$INITIATIVE_ROOT\\\`
- **Promotion Type:** \\\`$GATE\\\`
- **Source Audience:** \\\`$SOURCE_AUDIENCE\\\`
- **Target Audience:** \\\`$TARGET_AUDIENCE\\\`
- **Branch Pattern:** v2.0.0 named phases

---

### 🚀 Next Steps

After this PR is merged:
$NEXT_STEPS

---

_Generated by LENS Workbench v2.0.0 Audience Promotion_"

# Create PR using GitHub API
if [[ "$DRY_RUN" != "true" ]]; then
    info "\nCreating pull request via GitHub API..."

    # Prepare JSON payload (properly escape the body)
    PR_DATA=$(cat <<EOF
{
  "title": "$TITLE",
  "body": "$PR_BODY",
  "head": "$SOURCE_BRANCH",
  "base": "$TARGET_BRANCH",
  "draft": false
}
EOF
)

    # Make API request to create PR
    API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls"
    RESPONSE=$(curl -s -X POST \
        -H "Authorization: Bearer $GITHUB_PAT" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        -d "$PR_DATA" \
        "$API_URL")

    # Check if PR was created successfully
    PR_NUMBER=$(echo "$RESPONSE" | grep -o '"number":[0-9]*' | cut -d: -f2 | head -1)
    PR_URL=$(echo "$RESPONSE" | grep -o '"html_url":"[^"]*' | cut -d'"' -f4 | head -1)

    if [[ -n "$PR_NUMBER" && "$PR_NUMBER" != "null" ]]; then
        success "\n✅ Pull request created successfully!"
        success "PR Number: #$PR_NUMBER"
        success "PR URL: $PR_URL"

        # Add labels
        info "Adding labels..."
        LABELS_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues/$PR_NUMBER/labels"
        LABELS_DATA="{\"labels\": $LABELS}"

        curl -s -X POST \
            -H "Authorization: Bearer $GITHUB_PAT" \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Content-Type: application/json" \
            -d "$LABELS_DATA" \
            "$LABELS_URL" > /dev/null

        if [[ $? -eq 0 ]]; then
            success "✓ Labels added"
        else
            warning "Could not add labels"
        fi

        # Save PR info
        PR_INFO_DIR="_bmad-output/lens-work/promotion-prs"
        mkdir -p "$PR_INFO_DIR"
        PR_INFO_FILE="$PR_INFO_DIR/$INITIATIVE_ROOT-$GATE-$(date +%Y%m%d-%H%M%S).json"

        cat > "$PR_INFO_FILE" <<EOF
{
  "number": $PR_NUMBER,
  "url": "$PR_URL",
  "title": "$TITLE",
  "created_at": "$(date +'%Y-%m-%d %H:%M:%S')",
  "source_branch": "$SOURCE_BRANCH",
  "target_branch": "$TARGET_BRANCH",
  "promotion_type": "$GATE"
}
EOF
        info "PR info saved to: $PR_INFO_FILE"

    else
        # Extract error message if available
        ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message":"[^"]*' | cut -d'"' -f4)
        if [[ -n "$ERROR_MSG" ]]; then
            error "GitHub API Error: $ERROR_MSG"
        else
            error "Failed to create pull request. Response: $RESPONSE"
        fi
    fi
else
    warning "\n[DRY RUN] Would create PR via API:"
    info "  URL: https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls"
    info "  Title: $TITLE"
    info "  Base: $TARGET_BRANCH"
    info "  Head: $SOURCE_BRANCH"
    info "  Labels: $LABELS"
    echo -e "\nPR Body Preview:\n$(echo "$PR_BODY" | sed 's/\\\\`/`/g')"
fi

info "\n======================================"
success "Promotion PR script complete!"
info "======================================"