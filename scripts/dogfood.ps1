#!/usr/bin/env pwsh
# BMAD.Lens Local Dogfooding Script (PowerShell version)
# 
# ⚠️  DEPRECATED: This script is now merged with build-release.ps1
# 
# Instead of using this script, use:
#   .\scripts\build-release.ps1 -Version "1.0.4"
# 
# This will build a clean release AND dogfood it to _bmad/
# 
# This standalone script remains for quick copies without full rebuild
# but may not include all build validations.

$ErrorActionPreference = "Stop"

# Ensure script runs from project root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot

Write-Host "🐕 BMAD.Lens Dogfooding Script" -ForegroundColor Cyan
Write-Host "Working Directory: $(Get-Location)"
Write-Host ""
Write-Host "⚠️  DEPRECATED: Consider using .\scripts\build-release.ps1 instead" -ForegroundColor Yellow
Write-Host "   (builds clean release + dogfoods in one step)" -ForegroundColor Yellow
Write-Host ""

# Copy lens-work module
Write-Host "📋 Copying lens-work module from src/ to _bmad/..." -ForegroundColor Yellow
if (-not (Test-Path "_bmad\lens-work")) {
    Write-Host "   Warning: _bmad\lens-work does not exist. Run build-release.ps1 first to install BMAD." -ForegroundColor Red
    exit 1
}

Copy-Item -Path "src\modules\lens-work\*" -Destination "_bmad\lens-work\" -Recurse -Force
Write-Host "   ✓ lens-work module copied" -ForegroundColor Green

# Copy file-transforms module
Write-Host ""
Write-Host "📋 Copying file-transforms module from src/ to _bmad/..." -ForegroundColor Yellow
if (-not (Test-Path "_bmad\file-transforms")) {
    New-Item -ItemType Directory -Path "_bmad\file-transforms" -Force | Out-Null
}
Copy-Item -Path "src\modules\file-transforms\*" -Destination "_bmad\file-transforms\" -Recurse -Force
Write-Host "   ✓ file-transforms module copied" -ForegroundColor Green

Write-Host ""
Write-Host "✨ Dogfooding Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Your local _bmad/ directory now has the latest changes from src/"
Write-Host "   Test your changes and when ready, run build-release.ps1 to create a release package"
Write-Host ""
