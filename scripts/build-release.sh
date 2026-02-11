#!/bin/bash
# BMAD.Lens Local Release Build & Dogfood Script (Bash version)
# Builds a release package and dogfoods it to the local _bmad/ directory
# Mimics the GitHub Actions workflow for local testing

set -e

# Ensure script runs from project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

VERSION="${1:-1.0.4}"
SKIP_INSTALL="${2:-false}"

echo "🏭️  BMAD.Lens Release Build & Dogfood Script"
echo "Version: $VERSION"
echo "Working Directory: $(pwd)"
echo ""
echo "This script will:"
echo "  1. Build a clean release package"
echo "  2. Dogfood it to your local _bmad/ directory"
echo ""

# Step 1: Create release-build directory
echo "📁 [1/8] Creating release-build directory..."
if [ -d "release-build" ]; then
    echo "   Cleaning existing release-build directory..."
    rm -rf release-build
fi
mkdir -p release-build
echo "   ✓ Directory created"

# Step 2: Clean personal data
echo ""
echo "🧹 [2/8] Cleaning personal data..."
if [ -d "_bmad-output/lens-work/personal" ]; then
    rm -rf _bmad-output/lens-work/personal
    echo "   ✓ Removed personal directory"
fi
if [ -d "_bmad-output/lens-work/roster" ]; then
    rm -rf _bmad-output/lens-work/roster
    echo "   ✓ Removed roster directory"
fi
if [ ! -d "_bmad-output/lens-work/personal" ] && [ ! -d "_bmad-output/lens-work/roster" ]; then
    echo "   ✓ No personal data to clean"
fi

# Step 3: Install BMAD with official modules
if [ "$SKIP_INSTALL" != "true" ]; then
    echo ""
    echo "📦 [3/8] Installing BMAD with official modules..."
    echo "   This may take 1-2 minutes..."
    
    cd release-build
    npx bmad-method@beta install \
        --directory "." \
        --modules "bmm,bmb,cis,gds,tea" \
        --tools "cursor,github-copilot,claude-code" \
        --user-name "BMADRelease" \
        --output-folder "_bmad-output" \
        --yes
    cd ..
    
    echo "   ✓ BMAD installed successfully"
else
    echo ""
    echo "📦 [3/8] Skipping BMAD installation (SKIP_INSTALL=true)"
fi

# Step 4: Copy custom modules
echo ""
echo "📋 [4/8] Copying custom modules..."
mkdir -p release-build/_bmad
cp -r src/modules/lens-work release-build/_bmad/lens-work
cp -r src/modules/file-transforms release-build/_bmad/file-transforms
echo "   ✓ lens-work module copied"
echo "   ✓ file-transforms module copied"

# Step 5: Configure IDE prompts
echo ""
echo "🎨 [5/8] Configuring IDE prompts..."

# Configure Codex (copy from Claude Code) - only if .claude exists
if [ -d "release-build/.claude/commands" ]; then
    mkdir -p release-build/.codex/prompts
    cp -r release-build/.claude/commands/* release-build/.codex/prompts/
    echo "   ✓ Codex prompts configured"
fi

# Copy GitHub prompts for lens-work - only if they exist
if [ -d ".github/prompts" ]; then
    mkdir -p release-build/.github
    cp -r .github/prompts release-build/.github/prompts
    echo "   ✓ GitHub prompts copied"
fi

if [ ! -d "release-build/.claude/commands" ] && [ ! -d ".github/prompts" ]; then
    echo "   ✓ No IDE prompts to configure (skipped installation)"
fi

# Step 6: Create release archive
echo ""
echo "📦 [6/8] Creating release archive..."

cd release-build

# Build list of directories to include
DIRS_TO_ARCHIVE=""
for dir in _bmad _bmad-output .cursor .github .claude .codex docs; do
    if [ -d "$dir" ] || [ -e "$dir" ]; then
        DIRS_TO_ARCHIVE="$DIRS_TO_ARCHIVE $dir"
    fi
done

# Try zip first, fall back to tar.gz
ARCHIVE_NAME="bmad-lens-v${VERSION}"
if command -v zip &> /dev/null; then
    zip -r "../${ARCHIVE_NAME}.zip" $DIRS_TO_ARCHIVE
    echo "   ✓ Archive created: ${ARCHIVE_NAME}.zip"
    ARCHIVE_FILE="${ARCHIVE_NAME}.zip"
else
    tar -czf "../${ARCHIVE_NAME}.tar.gz" $DIRS_TO_ARCHIVE
    echo "   ✓ Archive created: ${ARCHIVE_NAME}.tar.gz"
    ARCHIVE_FILE="${ARCHIVE_NAME}.tar.gz"
fi

cd ..

# Display summary
echo ""
echo "✨ Build Complete!"
echo ""
echo "📊 Summary:"
echo "   Release Version: v${VERSION}"
echo "   Archive: ${ARCHIVE_FILE}"

if [ -f "${ARCHIVE_FILE}" ]; then
    SIZE=$(du -h "${ARCHIVE_FILE}" | cut -f1)
    echo "   Size: ${SIZE}"
fi

# Step 7: Dogfood the release
echo ""
echo "🐕 [7/8] Dogfooding the release to local _bmad/..."
if [ -d "_bmad/lens-work" ]; then
    echo "   Copying lens-work from release-build..."
    cp -r release-build/_bmad/lens-work/* _bmad/lens-work/
    echo "   ✓ lens-work module updated"
fi

if [ -d "_bmad/file-transforms" ] || [ -d "release-build/_bmad/file-transforms" ]; then
    if [ ! -d "_bmad/file-transforms" ]; then
        mkdir -p _bmad/file-transforms
    fi
    echo "   Copying file-transforms from release-build..."
    cp -r release-build/_bmad/file-transforms/* _bmad/file-transforms/
    echo "   ✓ file-transforms module updated"
fi

echo "   ✓ Local _bmad/ now running the released version"

# Cleanup
echo ""
echo "🧹 [8/8] Cleaning up..."
if [ -d "release-build" ]; then
    rm -rf release-build
    echo "   ✓ Removed release-build directory"
fi

echo ""
echo "📦 Archive contains:"
echo "   • Core modules: bmm, bmb, cis, gds, tea"
echo "   • Custom modules: lens-work, file-transforms"
echo "   • IDE configs: Cursor, GitHub Copilot, Claude Code, Codex"
echo ""
echo "🎯 Next steps:"
echo "   1. Test your dogfooded changes in the local _bmad/ directory"
echo "   2. If tests pass, push to release/1.0.4 branch to trigger GitHub Actions"
echo "   3. GitHub will create the official release with this archive"
echo ""
