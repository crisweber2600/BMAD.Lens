#!/bin/bash
# Store GitHub Personal Access Token Securely
# This script runs OUTSIDE of Copilot/LLM context to keep tokens secure

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../../.." && pwd )"
CREDENTIALS_FILE="$PROJECT_ROOT/_bmad-output/lens-work/personal/github-credentials.yaml"

echo "🔐 GitHub Personal Access Token Storage"
echo "======================================"
echo ""
echo "⚠️  SECURITY NOTE:"
echo "   PATs should NEVER be entered directly into Copilot, Claude, or any LLM chat."
echo "   This script runs in your terminal to keep your credentials secure."
echo ""
echo "   Your PAT will be stored in:"
echo "   $_bmad-output/lens-work/personal/github-credentials.yaml"
echo "   (This file is gitignored and never committed)"
echo ""

# Ensure directories exist
mkdir -p "$PROJECT_ROOT/_bmad-output/lens-work/personal"

# Load repo inventory to detect GitHub domains
INVENTORY_FILE="$PROJECT_ROOT/_bmad-output/lens-work/repo-inventory.yaml"
DOMAINS=""

if [ -f "$INVENTORY_FILE" ]; then
    # Extract unique GitHub domains from repo inventory
    echo "🔍 Detecting GitHub domains from your repositories..."
    DOMAINS=$(grep -oP 'https?://\K[^/]+' "$INVENTORY_FILE" | grep github | sort -u || true)
    
    if [ -n "$DOMAINS" ]; then
        echo ""
        echo "Found GitHub domain(s):"
        for domain in $DOMAINS; do
            echo "  • $domain"
        done
        echo ""
    fi
fi

# If no domains found or no inventory, default to github.com
if [ -z "$DOMAINS" ]; then
    echo "ℹ️  No repo inventory found. Defaulting to github.com"
    echo "   (Run repo-discover workflow to detect additional GitHub domains)"
    echo ""
    DOMAINS="github.com"
fi

# Initialize credentials file if it doesn't exist
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "# GitHub Personal Access Tokens" > "$CREDENTIALS_FILE"
    echo "# Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$CREDENTIALS_FILE"
    echo "" >> "$CREDENTIALS_FILE"
fi

# Prompt for each domain
for domain in $DOMAINS; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ "$domain" == "github.com" ]; then
        echo "📍 GitHub.com (SaaS)"
        echo ""
        echo "Generate token at: https://github.com/settings/tokens"
        echo "Required scopes: repo, read:org"
    else
        echo "📍 $domain (GitHub Enterprise)"
        echo ""
        echo "Generate token at: https://$domain/settings/tokens"
        echo "Required scopes: repo, read:org"
    fi
    
    echo ""
    echo "💡 Note: Characters won't appear when typing - this is normal for secure input"
    read -sp "Paste your PAT and press enter (or press Enter to skip): " pat
    echo ""
    
    if [ -n "$pat" ]; then
        # Check if domain already exists in credentials
        if grep -q "^${domain}:" "$CREDENTIALS_FILE" 2>/dev/null; then
            # Update existing entry
            sed -i "/^${domain}:/,/^  type:/ {
                s|^  token:.*|  token: $pat|
                s|^  created_at:.*|  created_at: \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"|
            }" "$CREDENTIALS_FILE"
            echo "✅ Updated PAT for $domain"
        else
            # Add new entry
            {
                echo "${domain}:"
                echo "  token: $pat"
                echo "  created_at: \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\""
                if [ "$domain" == "github.com" ]; then
                    echo "  type: github.com"
                else
                    echo "  type: github_enterprise"
                fi
                echo ""
            } >> "$CREDENTIALS_FILE"
            echo "✅ Saved PAT for $domain"
        fi
    else
        echo "⏭️  Skipped $domain"
    fi
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ PAT storage complete!"
echo ""
echo "Your credentials are stored at:"
echo "$CREDENTIALS_FILE"
echo ""
echo "🔒 Security reminders:"
echo "   • This file is gitignored"
echo "   • Never commit or share this file"
echo "   • Rotate PATs periodically"
echo "   • You can re-run this script anytime to update tokens"
echo ""

# Try to open in VS Code
if command -v code &> /dev/null; then
    echo "📝 Opening credentials file in VS Code..."
    code "$CREDENTIALS_FILE"
else
    echo "💡 To view your credentials, open: $CREDENTIALS_FILE"
fi
