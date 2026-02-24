# LENS Workbench v2.0.0 Validation Script
# Validates the lifecycle contract implementation is complete

$ErrorCount = 0
$WarningCount = 0

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "LENS Workbench v2.0.0 Validation" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Function to check file exists
function Test-FileExists {
    param($Path, $Description)
    if (Test-Path $Path) {
        Write-Host "[✓] $Description" -ForegroundColor Green
        return $true
    } else {
        Write-Host "[✗] $Description - File not found: $Path" -ForegroundColor Red
        $script:ErrorCount++
        return $false
    }
}

# Function to check file does NOT exist
function Test-FileNotExists {
    param($Path, $Description)
    if (-not (Test-Path $Path)) {
        Write-Host "[✓] $Description removed" -ForegroundColor Green
        return $true
    } else {
        Write-Host "[✗] $Description still exists: $Path" -ForegroundColor Red
        $script:ErrorCount++
        return $false
    }
}

# Function to check file contains text
function Test-FileContains {
    param($Path, $Text, $Description)
    if (Test-Path $Path) {
        $content = Get-Content $Path -Raw
        if ($content -match [regex]::Escape($Text)) {
            Write-Host "[✓] $Description" -ForegroundColor Green
            return $true
        } else {
            Write-Host "[✗] $Description - Text not found in $Path" -ForegroundColor Yellow
            $script:WarningCount++
            return $false
        }
    }
    return $false
}

# Function to check file does NOT contain text
function Test-FileNotContains {
    param($Path, $Pattern, $Description)
    if (Test-Path $Path) {
        $content = Get-Content $Path -Raw
        if ($content -notmatch $Pattern) {
            Write-Host "[✓] $Description" -ForegroundColor Green
            return $true
        } else {
            Write-Host "[✗] $Description - Legacy pattern found in $Path" -ForegroundColor Yellow
            $script:WarningCount++
            return $false
        }
    }
    return $true
}

Write-Host "1. Core Files" -ForegroundColor Yellow
Write-Host "-------------" -ForegroundColor Yellow
Test-FileExists "_bmad/_config/custom/lens-work/lifecycle.yaml" "lifecycle.yaml exists"
Test-FileExists "_bmad/_config/custom/lens-work/module.yaml" "module.yaml exists"
Test-FileContains "_bmad/_config/custom/lens-work/module.yaml" 'version: "2.0.0"' "Version 2.0.0 set"
Write-Host ""

Write-Host "2. Removed Files" -ForegroundColor Yellow
Write-Host "----------------" -ForegroundColor Yellow
Test-FileNotExists "_bmad/_config/custom/lens-work/workflows/includes/lifecycle-adapter.md" "lifecycle-adapter.md"
Test-FileNotExists "_bmad/_config/custom/lens-work/templates/constitutions/feature-constitution.md" "feature-constitution.md"
Test-FileNotExists "_bmad/_config/custom/lens-work/templates/constitutions/microservice-constitution.md" "microservice-constitution.md"
Test-FileNotExists "_bmad/lens-work" "Duplicate lens-work directory"
Write-Host ""

Write-Host "3. Template Validation" -ForegroundColor Yellow
Write-Host "----------------------" -ForegroundColor Yellow
Test-FileNotContains "_bmad/_config/custom/lens-work/templates/initiative-template.yaml" "featureBranchRoot|review_audience_map|gate_status" "No legacy fields in initiative template"
Test-FileNotContains "_bmad/_config/custom/lens-work/templates/state-template.yaml" "gate_status" "No legacy fields in state template"
Write-Host ""

Write-Host "4. Workflow Validation" -ForegroundColor Yellow
Write-Host "----------------------" -ForegroundColor Yellow
Test-FileNotContains "_bmad/_config/custom/lens-work/workflows/background/state-sync/workflow.md" "lifecycle-adapter" "state-sync has no adapter import"
Test-FileNotContains "_bmad/_config/custom/lens-work/module.yaml" "legacy_phase|legacy_workflow" "No legacy branch patterns"
Write-Host ""

Write-Host "5. Constitution Hierarchy" -ForegroundColor Yellow
Write-Host "-------------------------" -ForegroundColor Yellow
Test-FileExists "_bmad/_config/custom/lens-work/templates/constitutions/org-constitution.md" "org-constitution.md exists"
Test-FileExists "_bmad/_config/custom/lens-work/templates/constitutions/domain-constitution.md" "domain-constitution.md exists"
Test-FileExists "_bmad/_config/custom/lens-work/templates/constitutions/service-constitution.md" "service-constitution.md exists"
Test-FileExists "_bmad/_config/custom/lens-work/templates/constitutions/repo-constitution.md" "repo-constitution.md exists"
Write-Host ""

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Validation Results" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

if ($ErrorCount -eq 0 -and $WarningCount -eq 0) {
    Write-Host "✅ ALL CHECKS PASSED!" -ForegroundColor Green
    Write-Host "LENS Workbench v2.0.0 is properly configured." -ForegroundColor Green
    exit 0
} else {
    if ($ErrorCount -gt 0) {
        Write-Host "❌ Found $ErrorCount errors" -ForegroundColor Red
    }
    if ($WarningCount -gt 0) {
        Write-Host "⚠️  Found $WarningCount warnings" -ForegroundColor Yellow
    }
    Write-Host "Please review the issues above." -ForegroundColor Yellow
    exit 1
}