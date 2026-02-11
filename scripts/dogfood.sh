#!/bin/bash
# BMAD.Lens Local Dogfooding Script
# 
# ⚠️  DEPRECATED: This script is now merged with build-release.sh
# 
# Instead of using this script, use:
#   ./scripts/build-release.sh [version]
# 
# This will build a clean release AND dogfood it to _bmad/
# 
# This standalone script remains for quick copies without full rebuild
# but may not include all build validations.

set -e

# Ensure script runs from project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

echo "🐕 BMAD.Lens Dogfooding Script"
echo "Working Directory: $(pwd)"
echo ""
echo "⚠️  DEPRECATED: Consider using ./scripts/build-release.sh instead"
echo "   (builds clean release + dogfoods in one step)"
echo ""

# Copy lens-work module
echo "📋 Copying lens-work module from src/ to _bmad/..."
if [ ! -d "_bmad/lens-work" ]; then
    echo "   ⚠️  _bmad/lens-work doesn't exist. Run 'build-release.sh' first to install BMAD."
    exit 1
fi

cp -r src/modules/lens-work/* _bmad/lens-work/
echo "   ✓ lens-work module copied"

# Copy file-transforms module
echo ""
echo "📋 Copying file-transforms module from src/ to _bmad/..."
if [ ! -d "_bmad/file-transforms" ]; then
    mkdir -p _bmad/file-transforms
fi
cp -r src/modules/file-transforms/* _bmad/file-transforms/
echo "   ✓ file-transforms module copied"

echo ""
echo "✨ Dogfooding Complete!"
echo ""
echo "🎯 Your local _bmad/ directory now has the latest changes from src/"
echo "   Test your changes and when ready, run build-release.sh to create a release package"
echo ""
