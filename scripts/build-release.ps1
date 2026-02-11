#!/usr/bin/env pwsh
# BMAD.Lens Local Release Build & Dogfood Script
# Builds a release package and dogfoods it to the local _bmad/ directory
# Mimics the GitHub Actions workflow for local testing

param(
    [string]$Version = "1.0.4",
    [switch]$SkipInstall = $false
)

$ErrorActionPreference = "Stop"

# Ensure script runs from project root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot

Write-Host "🏭️  BMAD.Lens Release Build & Dogfood Script" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Cyan
Write-Host "Working Directory: $(Get-Location)" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will:" -ForegroundColor Gray
Write-Host "  1. Build a clean release package" -ForegroundColor Gray
Write-Host "  2. Dogfood it to your local _bmad/ directory" -ForegroundColor Gray
Write-Host ""
Write-Host ""

# Step 1: Clean workspace — remove all root folders except protected set
Write-Host "🧹 [1/9] Cleaning workspace (removing non-source folders)..." -ForegroundColor Yellow
$protected = @('src', '.git', '_bmad-output', 'scripts', 'TargetProjects', 'Docs', 'release-build')
Get-ChildItem -Directory -Force | ForEach-Object {
    if ($protected -contains $_.Name) {
        Write-Host "   ✓ Keeping $($_.Name)/" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Removing $($_.Name)/" -ForegroundColor Red
        Remove-Item $_.FullName -Recurse -Force
    }
}
Write-Host "   ✓ Workspace cleaned" -ForegroundColor Green

# Step 2: Create release-build directory
Write-Host ""
Write-Host "📁 [2/9] Creating release-build directory..." -ForegroundColor Yellow
if (Test-Path "release-build") {
    Write-Host "   Cleaning existing release-build directory..." -ForegroundColor Gray
    Remove-Item "release-build" -Recurse -Force
}
New-Item -ItemType Directory -Path "release-build" | Out-Null
Write-Host "   ✓ Directory created" -ForegroundColor Green

# Step 3: Clean personal data
Write-Host ""
Write-Host "🧹 [3/9] Cleaning personal data..." -ForegroundColor Yellow
$personalPath = "_bmad-output/lens-work/personal"
$rosterPath = "_bmad-output/lens-work/roster"
$cleaned = $false
if (Test-Path $personalPath) {
    Remove-Item $personalPath -Recurse -Force
    Write-Host "   ✓ Removed personal directory" -ForegroundColor Green
    $cleaned = $true
}
if (Test-Path $rosterPath) {
    Remove-Item $rosterPath -Recurse -Force
    Write-Host "   ✓ Removed roster directory" -ForegroundColor Green
    $cleaned = $true
}
if (-not $cleaned) {
    Write-Host "   ✓ No personal data to clean" -ForegroundColor Green
}

# Step 3: Install BMAD with official modules
if (-not $SkipInstall) {
    Write-Host ""
    Write-Host "📦 [4/9] Installing BMAD with official modules..." -ForegroundColor Yellow
    Write-Host "   This may take 1-2 minutes..." -ForegroundColor Gray
    
    Push-Location "release-build"
    try {
        npx bmad-method@beta install `
            --directory "." `
            --modules "bmm,bmb,cis,gds,tea" `
            --tools "cursor,github-copilot,claude-code" `
            --user-name "BMADRelease" `
            --output-folder "_bmad-output" `
            --yes
        
        Write-Host "   ✓ BMAD installed successfully" -ForegroundColor Green
    }
    finally {
        Pop-Location
    }
} else {
    Write-Host ""
    Write-Host "📦 [4/9] Skipping BMAD installation (--SkipInstall flag)" -ForegroundColor Yellow
}

# Step 4: Copy custom modules
Write-Host ""
Write-Host "📋 [5/9] Copying custom modules..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "release-build\_bmad" -Force | Out-Null
Copy-Item -Path "src\modules\lens-work" -Destination "release-build\_bmad\lens-work" -Recurse -Force
Copy-Item -Path "src\modules\file-transforms" -Destination "release-build\_bmad\file-transforms" -Recurse -Force
Write-Host "   ✓ lens-work module copied" -ForegroundColor Green
Write-Host "   ✓ file-transforms module copied" -ForegroundColor Green

# Step 6: Configure IDE prompts
Write-Host ""
Write-Host "🎨 [6/9] Configuring IDE prompts..." -ForegroundColor Yellow

# Ensure directories exist in release-build
@('.claude/commands', '.codex/prompts', '.cursor/commands', '.github/agents') | ForEach-Object {
    $dirPath = "release-build/$_"
    if (-not (Test-Path $dirPath)) {
        New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
    }
}

# Configure Codex (copy from Claude Code) - only if .claude exists and has files
if ((Test-Path "release-build\.claude\commands") -and ((Get-ChildItem -Path "release-build\.claude\commands" -Recurse -File -ErrorAction SilentlyContinue).Count -gt 0)) {
    Copy-Item -Path "release-build\.claude\commands\*" -Destination "release-build\.codex\prompts\" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   ✓ Codex prompts configured" -ForegroundColor Green
} else {
    Write-Host "   ✓ .codex directory created (empty)" -ForegroundColor Green
}

# Copy GitHub agent prompts - only if they exist
if ((Test-Path ".github\agents") -and ((Get-ChildItem -Path ".github\agents" -Recurse -File -ErrorAction SilentlyContinue).Count -gt 0)) {
    Copy-Item -Path ".github\agents\*" -Destination "release-build\.github\agents\" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   ✓ GitHub agent prompts copied" -ForegroundColor Green
} else {
    Write-Host "   ✓ .github/agents directory created (empty)" -ForegroundColor Green
}

Write-Host "   ✓ IDE prompt directories ready" -ForegroundColor Green

# Step 7: Create release archive
Write-Host ""
Write-Host "📦 [7/9] Creating release archive..." -ForegroundColor Yellow

Push-Location "release-build"
try {
    $archiveName = "bmad-lens-v$Version.zip"
    $archivePath = "..\$archiveName"
    
    # Build list of paths to include (only existing directories)
    $pathsToArchive = @()
    $dirsToCheck = @("_bmad", "_bmad-output", ".cursor", ".github", ".claude", ".codex", "docs")
    foreach ($dir in $dirsToCheck) {
        if (Test-Path $dir) {
            $pathsToArchive += "$dir\*"
        }
    }
    
    if ($pathsToArchive.Count -gt 0) {
        # Use PowerShell's Compress-Archive
        Compress-Archive -Path $pathsToArchive `
                         -DestinationPath $archivePath `
                         -Force
        
        Write-Host "   ✓ Archive created: $archiveName" -ForegroundColor Green
    } else {
        Write-Host "   ✗ No directories to archive" -ForegroundColor Red
        throw "No directories found to archive"
    }
}
finally {
    Pop-Location
}

# Display summary
Write-Host ""
Write-Host "✨ Build Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "   Release Version: v$Version"
Write-Host "   Archive: bmad-lens-v$Version.zip"

if (Test-Path "bmad-lens-v$Version.zip") {
    $size = (Get-Item "bmad-lens-v$Version.zip").Length / 1MB
    Write-Host "   Size: $([math]::Round($size, 2)) MB"
}

# Step 8: Dogfood the release — copy everything from release-build to workspace root
Write-Host ""
Write-Host "🐕 [8/9] Dogfooding the release to workspace root..." -ForegroundColor Yellow
Get-ChildItem -Path "release-build" -Directory -Force | ForEach-Object {
    Write-Host "   Copying $($_.Name)/" -ForegroundColor Gray
    Copy-Item -Path $_.FullName -Destination $_.Name -Recurse -Force
}
Write-Host "   ✓ Workspace rebuilt from release-build" -ForegroundColor Green

# Cleanup
Write-Host ""
Write-Host "🧹 [9/9] Cleaning up..." -ForegroundColor Yellow
if (Test-Path "release-build") {
    Remove-Item "release-build" -Recurse -Force
    Write-Host "   ✓ Removed release-build directory" -ForegroundColor Green
}

Write-Host ""
Write-Host "📦 Archive contains:" -ForegroundColor Cyan
Write-Host "   • Core modules: bmm, bmb, cis, gds, tea"
Write-Host "   • Custom modules: lens-work, file-transforms"
Write-Host "   • IDE configs: Cursor, GitHub Copilot, Claude Code, Codex"
Write-Host ""
Write-Host "🎯 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Test your dogfooded changes in the local _bmad/ directory"
Write-Host "   2. If tests pass, push to release/1.0.4 branch to trigger GitHub Actions"
Write-Host "   3. GitHub will create the official release with this archive"
Write-Host ""
