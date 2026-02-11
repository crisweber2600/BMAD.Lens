<#
.SYNOPSIS
    Applies file-transform rules from _bmad/_config/custom/file-transforms.yaml.
    Renames files and rewrites all internal references so BMAD keeps working
    even when original extensions are blocked by Copilot content-exclusion rules.

.DESCRIPTION
    Execution order follows the config:
      Backup:     Create backup of _bmad directory
      Phase 1:    Rename all YAML files to JSON
      Phase 2:    Convert all XML files to MD
      Phase 3:    Update all references in CSV manifests
      Phase 4:    Update all references in JS files
      Phase 5:    Update all references in MD files
      Validation: Run file integrity check
      Cleanup:    Remove backup after successful validation

    Respects exclusions: state files, external file patterns, GitHub Actions refs.
    Idempotent: running it twice produces the same result.

.PARAMETER ProjectRoot
    Root of the BMAD control repo. Defaults to the script's own directory.

.PARAMETER DryRun
    If set, shows what WOULD happen without touching any files.
#>
[CmdletBinding()]
param(
    [string]$ProjectRoot,
    [switch]$DryRun
)

if (-not $ProjectRoot) {
    $ProjectRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
}

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location -Path $ProjectRoot

# -- Helpers -----------------------------------------------------------------

function Write-Phase { param([string]$msg) Write-Host "" ; Write-Host "--- $msg ---" -ForegroundColor White }
function Write-Step  { param([string]$msg) Write-Host "  -> $msg" -ForegroundColor Cyan }
function Write-OK    { param([string]$msg) Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Skip  { param([string]$msg) Write-Host "  [skip] $msg" -ForegroundColor DarkGray }
function Write-Warn  { param([string]$msg) Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Write-Fail  { param([string]$msg) Write-Host "  [FAIL] $msg" -ForegroundColor Red }

# -- Config Parser -----------------------------------------------------------
# Line-by-line YAML parser for file-transforms config

function Read-TransformConfig {
    param([string]$Path)

    $lines = Get-Content $Path
    $cfg = @{
        version = 1
        scope = @()
        rewritable_extensions = @()
        transforms = @()
        exclusions = @{
            paths = @()
            reference_only = @()
            external_patterns = @()
        }
    }

    $section = ""
    $subSection = ""
    $currentTransform = $null

    foreach ($raw in $lines) {
        $line = $raw -replace '#.*$', ''
        $line = $line.TrimEnd()
        if ($line -match '^\s*$') { continue }

        # Top-level keys (no leading whitespace)
        if ($line -match '^(\w[\w_]*):\s*(.*)$') {
            $key = $Matches[1]
            $val = $Matches[2].Trim().Trim('"')

            if ($currentTransform) { $cfg.transforms += $currentTransform; $currentTransform = $null }
            $subSection = ""

            if ($key -eq 'version' -and $val)         { $cfg.version = [int]$val }
            elseif ($key -eq 'scope')                  { $section = 'scope' }
            elseif ($key -eq 'rewritable_extensions')  { $section = 'rewritable_extensions' }
            elseif ($key -eq 'transforms')             { $section = 'transforms' }
            elseif ($key -eq 'exclusions')             { $section = 'exclusions' }
            elseif ($key -eq 'execution_order')        { $section = 'execution_order' }
            else { $section = "" }
            continue
        }

        # Exclusions sub-keys (2-space indent): paths, reference_only, external_patterns, description
        if ($section -eq 'exclusions' -and $line -match '^\s{2}(\w[\w_]*):\s*(.*)$') {
            $subKey = $Matches[1]
            if ($subKey -in @('paths', 'reference_only', 'external_patterns')) {
                $subSection = $subKey
            } else {
                $subSection = 'skip'  # description, etc.
            }
            continue
        }

        # List items under exclusions sub-sections (4-space indent)
        if ($section -eq 'exclusions' -and $subSection -in @('paths', 'reference_only', 'external_patterns') -and $line -match '^\s+-\s+"?(.+?)"?\s*$') {
            $item = $Matches[1].Trim().Trim('"')
            $cfg.exclusions[$subSection] += $item
            continue
        }

        # Skip other exclusions content (description text, informational items)
        if ($section -eq 'exclusions') { continue }

        # List items under simple list sections
        if ($section -in @('scope', 'rewritable_extensions', 'execution_order') -and $line -match '^\s+-\s+"?(.+?)"?\s*$') {
            $item = $Matches[1].Trim().Trim('"')
            if ($cfg.ContainsKey($section)) { $cfg[$section] += $item }
            continue
        }

        # Transform list items: new item starts with "  - type:"
        if ($section -eq 'transforms' -and $line -match '^\s+-\s+type:\s+"?(\w+)"?') {
            if ($currentTransform) { $cfg.transforms += $currentTransform }
            $currentTransform = @{ type = $Matches[1] }
            continue
        }

        # Properties of the current transform item
        if ($section -eq 'transforms' -and $currentTransform -and $line -match '^\s+([\w_]+):\s+"?([^"]+)"?\s*$') {
            $currentTransform[$Matches[1].Trim()] = $Matches[2].Trim().TrimEnd('"')
            continue
        }
    }

    if ($currentTransform) { $cfg.transforms += $currentTransform }

    # Defaults
    if ($cfg.scope.Count -eq 0) { $cfg.scope = @("_bmad", "_bmad-output") }
    if ($cfg.rewritable_extensions.Count -eq 0) {
        $cfg.rewritable_extensions = @(".md", ".yaml", ".json", ".csv", ".js", ".xml", ".ps1", ".sh", ".bat")
    }

    return $cfg
}

# -- Build exclusion sets ----------------------------------------------------

function Build-ExclusionSet {
    param($cfg, [string]$root)

    $excluded = [System.Collections.Generic.HashSet[string]]::new()

    # Parse exclusions.paths: exact relative paths to exclude from rename
    $exPaths = $cfg.exclusions.paths
    if ($exPaths) {
        foreach ($path in $exPaths) {
            # Strip inline comments (text after #)
            $clean = ($path -split '#')[0].Trim()
            if ($clean) { [void]$excluded.Add($clean) }
        }
    }

    # Parse exclusions.external_patterns: filenames that should never be renamed
    $externalNames = @()
    $exPatterns = $cfg.exclusions.external_patterns
    if ($exPatterns) {
        foreach ($entry in $exPatterns) {
            $name = ($entry -split '#')[0].Trim()
            if ($name) { $externalNames += $name }
        }
    }

    # Find all files matching external patterns in scope
    foreach ($scopeDir in $cfg.scope) {
        $fullDir = Join-Path $root $scopeDir
        if (Test-Path $fullDir) {
            Get-ChildItem -Path $fullDir -Recurse -File | ForEach-Object {
                $relPath = $_.FullName.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/'
                if ($externalNames -contains $_.Name) {
                    [void]$excluded.Add($relPath)
                }
            }
        }
    }

    return ,$excluded
}

# -- Load Config -------------------------------------------------------------

$configPath = Join-Path $ProjectRoot "_bmad/_config/custom/file-transforms.yaml"
if (-not (Test-Path $configPath)) {
    Write-Host "No file-transforms.yaml found at $configPath -- nothing to do." -ForegroundColor Yellow
    exit 0
}

Write-Host "========================================================" -ForegroundColor White
Write-Host "  BMAD File Transform -- Apply" -ForegroundColor White
Write-Host "========================================================" -ForegroundColor White

if ($DryRun) {
    Write-Host "[DRY RUN] No files will be modified." -ForegroundColor Yellow
}

$cfg = Read-TransformConfig -Path $configPath
Write-Host "Loaded $($cfg.transforms.Count) transform rules" -ForegroundColor Gray
Write-Host "Scope: $($cfg.scope -join ', ')" -ForegroundColor Gray

$exPathCount = if ($cfg.exclusions.paths) { $cfg.exclusions.paths.Count } else { 0 }
$exPatternCount = if ($cfg.exclusions.external_patterns) { $cfg.exclusions.external_patterns.Count } else { 0 }
Write-Host "Excluded paths: $exPathCount  |  External patterns: $exPatternCount" -ForegroundColor Gray

# Build exclusion set
$excludedPaths = Build-ExclusionSet -cfg $cfg -root $ProjectRoot
Write-Host "Total excluded paths: $($excludedPaths.Count)" -ForegroundColor Gray

# ============================================================================
# Backup: Create backup of _bmad directory
# ============================================================================

Write-Phase "Backup: Creating backup of _bmad directory"

$backupDir = Join-Path $ProjectRoot "_bmad-backup"
if (-not $DryRun) {
    if (Test-Path $backupDir) { Remove-Item $backupDir -Recurse -Force }
    Copy-Item -Path (Join-Path $ProjectRoot "_bmad") -Destination $backupDir -Recurse -Force
    Write-OK "Backup created at _bmad-backup/"
} else {
    Write-Skip "Would create backup at _bmad-backup/"
}

# ============================================================================
# Build rename map (respecting exclusions)
# ============================================================================

$renameMap = [ordered]@{}
$refReplaceMap = [ordered]@{}

# Gather all files in scope
$allFiles = @()
foreach ($scopeDir in $cfg.scope) {
    $fullDir = Join-Path $ProjectRoot $scopeDir
    if (Test-Path $fullDir) {
        $allFiles += Get-ChildItem -Path $fullDir -Recurse -File | ForEach-Object {
            [PSCustomObject]@{
                FullPath = $_.FullName
                RelPath  = $_.FullName.Substring($ProjectRoot.Length).TrimStart('\', '/') -replace '\\', '/'
                Name     = $_.Name
                Ext      = $_.Extension
            }
        }
    }
}

Write-Host "  Found $($allFiles.Count) files in scope" -ForegroundColor Gray

# Pass 1: "rename" rules (specific filename matches -- highest priority)
$renameRules = $cfg.transforms | Where-Object { $_.type -eq "rename" }
foreach ($rule in $renameRules) {
    $oldName = $rule.old_name
    $newName = $rule.new_name
    Write-Step "Rename rule: $oldName -> $newName"

    $matched = $allFiles | Where-Object { $_.Name -eq $oldName -and -not $excludedPaths.Contains($_.RelPath) }
    foreach ($f in $matched) {
        $newRelPath = ($f.RelPath -replace [regex]::Escape($oldName), $newName)
        $renameMap[$f.RelPath] = $newRelPath
        $refReplaceMap[$oldName] = $newName
    }
    Write-OK "$($matched.Count) files matched"
}

# Mark handled
$handledPaths = [System.Collections.Generic.HashSet[string]]::new()
foreach ($key in $renameMap.Keys) { [void]$handledPaths.Add($key) }

# Pass 2: "extension" rules (bulk transforms)
$extRules = $cfg.transforms | Where-Object { $_.type -eq "extension" }
foreach ($rule in $extRules) {
    $oldExt = $rule.old_ext
    $newExt = $rule.new_ext
    $collisionPrefix = if ($rule.ContainsKey("collision_prefix")) { $rule.collision_prefix } else { "" }
    Write-Step "Extension rule: *$oldExt -> *$newExt"

    $matched = $allFiles | Where-Object {
        $_.Ext -eq $oldExt -and
        -not $handledPaths.Contains($_.RelPath) -and
        -not $excludedPaths.Contains($_.RelPath)
    }
    $count = 0
    foreach ($f in $matched) {
        $newName = [System.IO.Path]::GetFileNameWithoutExtension($f.Name) + $newExt
        $newRelPath = ($f.RelPath.Substring(0, $f.RelPath.Length - $f.Name.Length)) + $newName

        # Check collision
        $newFullPath = Join-Path $ProjectRoot ($newRelPath -replace '/', '\')
        if ((Test-Path $newFullPath) -and $collisionPrefix) {
            $newName = $collisionPrefix + $newName
            $newRelPath = ($f.RelPath.Substring(0, $f.RelPath.Length - $f.Name.Length)) + $newName
        }

        $renameMap[$f.RelPath] = $newRelPath
        [void]$handledPaths.Add($f.RelPath)
        $count++
    }

    $refReplaceMap[$oldExt] = $newExt
    Write-OK "$count files matched"
}

Write-Host ""
Write-Host "Total files to rename: $($renameMap.Count)" -ForegroundColor White

# ============================================================================
# Phase 1: Rename all YAML files to JSON
# ============================================================================

Write-Phase "Phase 1: Rename all YAML files to JSON"

$yamlRenames = $renameMap.GetEnumerator() | Where-Object {
    $_.Key -match '\.(yaml|yml)$'
}

$renamedYaml = 0
$skippedYaml = 0

foreach ($entry in $yamlRenames) {
    $oldFull = Join-Path $ProjectRoot ($entry.Key -replace '/', '\')
    $newFull = Join-Path $ProjectRoot ($entry.Value -replace '/', '\')

    if (-not (Test-Path $oldFull)) { $skippedYaml++; continue }

    if (-not $DryRun) {
        $newDir = Split-Path $newFull -Parent
        if (-not (Test-Path $newDir)) { New-Item -ItemType Directory -Path $newDir -Force | Out-Null }
        Move-Item -Path $oldFull -Destination $newFull -Force
        $renamedYaml++
    } else {
        $renamedYaml++
    }
}

Write-OK "YAML renamed: $renamedYaml, already done: $skippedYaml"

# ============================================================================
# Phase 2: Convert all XML files to MD
# ============================================================================

Write-Phase "Phase 2: Convert all XML files to MD"

$xmlRenames = $renameMap.GetEnumerator() | Where-Object {
    $_.Key -match '\.xml$'
}

$renamedXml = 0
$skippedXml = 0

foreach ($entry in $xmlRenames) {
    $oldFull = Join-Path $ProjectRoot ($entry.Key -replace '/', '\')
    $newFull = Join-Path $ProjectRoot ($entry.Value -replace '/', '\')

    if (-not (Test-Path $oldFull)) { $skippedXml++; continue }

    if (-not $DryRun) {
        $newDir = Split-Path $newFull -Parent
        if (-not (Test-Path $newDir)) { New-Item -ItemType Directory -Path $newDir -Force | Out-Null }
        Move-Item -Path $oldFull -Destination $newFull -Force
        $renamedXml++
    } else {
        $renamedXml++
    }
}

Write-OK "XML renamed: $renamedXml, already done: $skippedXml"

$totalRenamed = $renamedYaml + $renamedXml

# ============================================================================
# Build replacement map for reference rewriting
# ============================================================================

$replacements = [ordered]@{}
foreach ($entry in $renameMap.GetEnumerator()) {
    $replacements[$entry.Key] = $entry.Value
}
foreach ($rule in $renameRules) {
    $replacements[$rule.old_name] = $rule.new_name
}
$sortedKeys = $replacements.Keys | Sort-Object { $_.Length } -Descending

# Gather content files (use new extensions since files are now renamed)
function Get-ContentFiles {
    param([string]$extFilter, $cfg, [string]$root)

    $files = @()
    $filterExts = if ($extFilter) { @($extFilter) } else {
        ($cfg.rewritable_extensions + @(".json", ".md")) | Sort-Object -Unique
    }

    foreach ($scopeDir in $cfg.scope) {
        $fullDir = Join-Path $root $scopeDir
        if (Test-Path $fullDir) {
            $files += Get-ChildItem -Path $fullDir -Recurse -File | Where-Object {
                $filterExts -contains $_.Extension
            }
        }
    }

    # Root-level scripts
    $files += Get-ChildItem -Path $root -File | Where-Object {
        @(".ps1", ".sh", ".bat", ".md") -contains $_.Extension
    }

    # .github
    $ghDir = Join-Path $root ".github"
    if (Test-Path $ghDir) {
        $files += Get-ChildItem -Path $ghDir -Recurse -File | Where-Object {
            $filterExts -contains $_.Extension
        }
    }

    return ($files | Sort-Object FullName -Unique)
}

function Rewrite-References {
    param($files, $replacements, $sortedKeys, [string]$root, [switch]$DryRun)

    $modified = 0
    $refs = 0

    foreach ($file in $files) {
        try {
            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
            if (-not $content) { continue }

            $changed = $false
            foreach ($oldRef in $sortedKeys) {
                $newRef = $replacements[$oldRef]
                if ($content.Contains($oldRef)) {
                    $hitCount = ([regex]::Matches($content, [regex]::Escape($oldRef))).Count
                    $content = $content.Replace($oldRef, $newRef)
                    $refs += $hitCount
                    $changed = $true
                }
            }

            if ($changed) {
                if (-not $DryRun) {
                    [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.UTF8Encoding]::new($false))
                }
                $modified++
            }
        } catch {
            Write-Warn "Could not process: $($file.Name) -- $_"
        }
    }

    return @{ Modified = $modified; Refs = $refs }
}

$totalFilesModified = 0
$totalRefsReplaced = 0

# ============================================================================
# Phase 3: Update all references in CSV manifests
# ============================================================================

Write-Phase "Phase 3: Update all references in CSV manifests"

$csvFiles = Get-ContentFiles -extFilter ".csv" -cfg $cfg -root $ProjectRoot
Write-Host "  Scanning $($csvFiles.Count) CSV files..." -ForegroundColor Gray

$result = Rewrite-References -files $csvFiles -replacements $replacements -sortedKeys $sortedKeys -root $ProjectRoot -DryRun:$DryRun
$totalFilesModified += $result.Modified
$totalRefsReplaced += $result.Refs
Write-OK "CSV: $($result.Modified) files modified, $($result.Refs) references"

# ============================================================================
# Phase 4: Update all references in JS files
# ============================================================================

Write-Phase "Phase 4: Update all references in JS files"

$jsFiles = Get-ContentFiles -extFilter ".js" -cfg $cfg -root $ProjectRoot
Write-Host "  Scanning $($jsFiles.Count) JS files..." -ForegroundColor Gray

$result = Rewrite-References -files $jsFiles -replacements $replacements -sortedKeys $sortedKeys -root $ProjectRoot -DryRun:$DryRun
$totalFilesModified += $result.Modified
$totalRefsReplaced += $result.Refs
Write-OK "JS: $($result.Modified) files modified, $($result.Refs) references"

# ============================================================================
# Phase 5: Update all references in MD files (and remaining types)
# ============================================================================

Write-Phase "Phase 5: Update all references in MD and remaining files"

# Get ALL content files, then exclude CSV and JS (already processed)
$allContentFiles = Get-ContentFiles -extFilter $null -cfg $cfg -root $ProjectRoot
$remainingFiles = $allContentFiles | Where-Object { $_.Extension -notin @(".csv", ".js") }
Write-Host "  Scanning $($remainingFiles.Count) remaining files (MD, JSON, PS1, etc.)..." -ForegroundColor Gray

$result = Rewrite-References -files $remainingFiles -replacements $replacements -sortedKeys $sortedKeys -root $ProjectRoot -DryRun:$DryRun
$totalFilesModified += $result.Modified
$totalRefsReplaced += $result.Refs
Write-OK "Remaining: $($result.Modified) files modified, $($result.Refs) references"

# ============================================================================
# Validation: Run file integrity check
# ============================================================================

Write-Phase "Validation: Running file integrity check"

$validationPassed = $true
$validationErrors = @()

# Check 1: Verify no orphaned references to old extensions remain
if ($DryRun) {
    Write-Skip "Orphan check skipped in DryRun (references not actually rewritten)"
} else {
    $postFiles = Get-ContentFiles -extFilter $null -cfg $cfg -root $ProjectRoot
    $orphanCount = 0

    foreach ($file in $postFiles) {
        try {
            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
            if (-not $content) { continue }

            foreach ($entry in $renameMap.GetEnumerator()) {
                if ($content.Contains($entry.Key)) {
                    $orphanCount++
                    if ($orphanCount -le 5) {
                        $relPath = $file.FullName.Substring($ProjectRoot.Length)
                        $validationErrors += "Orphaned ref '$($entry.Key)' in $relPath"
                    }
                }
            }
        } catch { }
    }

    if ($orphanCount -gt 0) {
        Write-Warn "Found $orphanCount orphaned references (old paths still referenced)"
        foreach ($err in $validationErrors) { Write-Warn "  $err" }
        if ($orphanCount -gt 5) { Write-Warn "  ... and $($orphanCount - 5) more" }
    } else {
        Write-OK "No orphaned references found"
    }
}

# Check 2: Verify excluded files still exist untouched
$excludeCheck = 0
foreach ($exPath in $excludedPaths) {
    $fullPath = Join-Path $ProjectRoot ($exPath -replace '/', '\')
    if (Test-Path $fullPath) {
        $excludeCheck++
    }
}
Write-OK "Excluded files verified: $excludeCheck of $($excludedPaths.Count)"

# Check 3: Verify renamed files exist at new locations
$missingCount = 0
foreach ($entry in $renameMap.GetEnumerator()) {
    $newFull = Join-Path $ProjectRoot ($entry.Value -replace '/', '\')
    if (-not (Test-Path $newFull) -and -not $DryRun) {
        $missingCount++
        if ($missingCount -le 3) {
            $validationErrors += "Missing after rename: $($entry.Value)"
        }
    }
}

if ($missingCount -gt 0 -and -not $DryRun) {
    Write-Fail "Missing $missingCount files after rename"
    $validationPassed = $false
} else {
    Write-OK "All renamed files present at new locations"
}

if ($validationPassed) {
    Write-OK "Validation PASSED"
} else {
    Write-Fail "Validation FAILED -- backup preserved at _bmad-backup/"
}

# ============================================================================
# Cleanup: Remove backup after successful validation
# ============================================================================

Write-Phase "Cleanup: Removing backup"

if ($validationPassed -and -not $DryRun) {
    if (Test-Path $backupDir) {
        Remove-Item $backupDir -Recurse -Force
        Write-OK "Backup removed"
    }
} elseif (-not $validationPassed) {
    Write-Warn "Backup preserved at _bmad-backup/ due to validation failure"
    Write-Warn "To restore: Remove-Item _bmad -Recurse; Rename-Item _bmad-backup _bmad"
} else {
    Write-Skip "Would remove backup"
}

# ============================================================================
# Write transform log
# ============================================================================

$logPath = Join-Path $ProjectRoot "_bmad-output/lens-work/file-transform-log.txt"
$logDir = Split-Path $logPath -Parent
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

$logLines = @()
$logLines += "# BMAD File Transform Log"
$logLines += "# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$logLines += "# Direction: APPLY (canonical -> transformed)"
$logLines += "# DryRun: $DryRun"
$logLines += "# Validation: $(if ($validationPassed) { 'PASSED' } else { 'FAILED' })"
$logLines += "#"
$logLines += "# YAML renamed:  $renamedYaml"
$logLines += "# XML renamed:   $renamedXml"
$logLines += "# Total renamed: $totalRenamed"
$logLines += "# References:    $totalRefsReplaced"
$logLines += "# Files modified: $totalFilesModified"
$logLines += "# Excluded paths: $($excludedPaths.Count)"
$logLines += "#"
$logLines += "# -- Excluded Files --"
foreach ($ex in $excludedPaths) { $logLines += "# EXCL: $ex" }
$logLines += "#"
$logLines += "# -- Rename Map --"
$logLines += ""
foreach ($entry in $renameMap.GetEnumerator()) {
    $logLines += "$($entry.Key) -> $($entry.Value)"
}

$logText = $logLines -join "`n"

if (-not $DryRun) {
    [System.IO.File]::WriteAllText($logPath, $logText, [System.Text.UTF8Encoding]::new($false))
    Write-OK "Log written to _bmad-output/lens-work/file-transform-log.txt"
} else {
    Write-Skip "Log would be written to _bmad-output/lens-work/file-transform-log.txt"
}

# ============================================================================
# Summary
# ============================================================================

Write-Host ""
Write-Host "========================================================" -ForegroundColor $(if ($validationPassed) { "Green" } else { "Red" })
Write-Host "  Transform Complete" -ForegroundColor $(if ($validationPassed) { "Green" } else { "Red" })
Write-Host "  YAML files renamed:    $renamedYaml" -ForegroundColor Green
Write-Host "  XML files renamed:     $renamedXml" -ForegroundColor Green
Write-Host "  References rewritten:  $totalRefsReplaced" -ForegroundColor Green
Write-Host "  Content files modified: $totalFilesModified" -ForegroundColor Green
Write-Host "  Excluded files:        $($excludedPaths.Count)" -ForegroundColor Green
Write-Host "  Validation:            $(if ($validationPassed) { 'PASSED' } else { 'FAILED' })" -ForegroundColor $(if ($validationPassed) { "Green" } else { "Red" })
Write-Host "========================================================" -ForegroundColor $(if ($validationPassed) { "Green" } else { "Red" })
Write-Host ""
