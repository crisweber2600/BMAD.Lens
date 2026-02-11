# Store GitHub Personal Access Token Securely
# This script runs OUTSIDE of Copilot/LLM context to keep tokens secure

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir "../../..")
$CredentialsFile = Join-Path $ProjectRoot "_bmad-output/lens-work/personal/github-credentials.yaml"

Write-Host "🔐 GitHub Personal Access Token Storage" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  SECURITY NOTE:" -ForegroundColor Yellow
Write-Host "   PATs should NEVER be entered directly into Copilot, Claude, or any LLM chat."
Write-Host "   This script runs in your terminal to keep your credentials secure."
Write-Host ""
Write-Host "   Your PAT will be stored in:"
Write-Host "   _bmad-output/lens-work/personal/github-credentials.yaml"
Write-Host "   (This file is gitignored and never committed)"
Write-Host ""

# Ensure directories exist
$PersonalDir = Join-Path $ProjectRoot "_bmad-output/lens-work/personal"
if (!(Test-Path $PersonalDir)) {
    New-Item -ItemType Directory -Path $PersonalDir -Force | Out-Null
}

# Load repo inventory to detect GitHub domains
$InventoryFile = Join-Path $ProjectRoot "_bmad-output/lens-work/repo-inventory.yaml"
$Domains = @()

if (Test-Path $InventoryFile) {
    # Extract unique GitHub domains from repo inventory
    Write-Host "🔍 Detecting GitHub domains from your repositories..."
    $Content = Get-Content $InventoryFile -Raw
    $Domains = [regex]::Matches($Content, 'https?://([^/]+github[^/]*)') | 
        ForEach-Object { $_.Groups[1].Value } | 
        Select-Object -Unique | 
        Sort-Object
    
    if ($Domains.Count -gt 0) {
        Write-Host ""
        Write-Host "Found GitHub domain(s):"
        foreach ($domain in $Domains) {
            Write-Host "  • $domain"
        }
        Write-Host ""
    }
}

# If no domains found or no inventory, default to github.com
if ($Domains.Count -eq 0) {
    Write-Host "ℹ️  No repo inventory found. Defaulting to github.com" -ForegroundColor Cyan
    Write-Host "   (Run repo-discover workflow to detect additional GitHub domains)"
    Write-Host ""
    $Domains = @("github.com")
}

# Initialize credentials file if it doesn't exist
if (!(Test-Path $CredentialsFile)) {
    @"
# GitHub Personal Access Tokens
# Generated: $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))

"@ | Out-File -FilePath $CredentialsFile -Encoding UTF8
}

# Prompt for each domain
foreach ($domain in $Domains) {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    
    if ($domain -eq "github.com") {
        Write-Host "📍 GitHub.com (SaaS)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Generate token at: https://github.com/settings/tokens"
        Write-Host "Required scopes: repo, read:org"
    } else {
        Write-Host "📍 $domain (GitHub Enterprise)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Generate token at: https://$domain/settings/tokens"
        Write-Host "Required scopes: repo, read:org"
    }
    
    Write-Host ""
    Write-Host "💡 Note: Characters won't appear when typing - this is normal for secure input" -ForegroundColor Cyan
    $SecureString = Read-Host "Paste your PAT and press enter (or press Enter to skip)" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    $Pat = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    
    if ($Pat) {
        # Read existing content
        $Content = Get-Content $CredentialsFile -Raw
        $Timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        $Type = if ($domain -eq "github.com") { "github.com" } else { "github_enterprise" }
        
        # Check if domain already exists
        if ($Content -match "(?m)^${domain}:") {
            # Update existing entry
            $Content = $Content -replace "(?m)^(${domain}:.*?\n  token:).*", "`$1 $Pat"
            $Content = $Content -replace "(?m)^(${domain}:.*?\n.*?\n  created_at:).*", "`$1 `"$Timestamp`""
            Set-Content -Path $CredentialsFile -Value $Content -Encoding UTF8
            Write-Host "✅ Updated PAT for $domain" -ForegroundColor Green
        } else {
            # Add new entry
            @"

${domain}:
  token: $Pat
  created_at: "$Timestamp"
  type: $Type

"@ | Add-Content -Path $CredentialsFile -Encoding UTF8
            Write-Host "✅ Saved PAT for $domain" -ForegroundColor Green
        }
    } else {
        Write-Host "⏭️  Skipped $domain" -ForegroundColor Yellow
    }
    Write-Host ""
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "✨ PAT storage complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Your credentials are stored at:"
Write-Host $CredentialsFile
Write-Host ""
Write-Host "🔒 Security reminders:" -ForegroundColor Yellow
Write-Host "   • This file is gitignored"
Write-Host "   • Never commit or share this file"
Write-Host "   • Rotate PATs periodically"
Write-Host "   • You can re-run this script anytime to update tokens"
Write-Host ""

# Try to open in VS Code
if (Get-Command code -ErrorAction SilentlyContinue) {
    Write-Host "📝 Opening credentials file in VS Code..." -ForegroundColor Cyan
    code $CredentialsFile
} else {
    Write-Host "💡 To view your credentials, open: $CredentialsFile" -ForegroundColor Cyan
}
Write-Host "   • You can re-run this script anytime to update tokens"
