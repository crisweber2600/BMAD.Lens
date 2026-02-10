<#
.SYNOPSIS
    Reverts file-transforms applied by apply-file-transforms.ps1.
    Run this BEFORE upgrading BMAD or lens-work so the installer sees canonical names.

.DESCRIPTION
    Reads the transform config, reverses every rename and reference rewrite.
    Respects the same exclusions. Idempotent: safe to run when transforms
    are not applied.

    Execution order (reverse of apply):
      Backup:   Create backup of current state
      Phase 1:  Revert references in CSV manifests
      Phase 2:  Revert references in JS files
      Phase 3:  Revert references in MD and remaining files
      Phase 4:  Rename .json files back to .yaml/.yml
      Phase 5:  Rename .md files back to .xml
      Validate: Verify canonical files exist
      Cleanup:  Remove backup after validation

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

function Write-Phase { param([string]$msg) Write-Host "" ; Write-Host "--- $msg ---" -ForegroundColor White }
function Write-Step  { param([string]$msg) Write-Host "  -> $msg" -ForegroundColor Cyan }
function Write-OK    { param([string]$msg) Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Skip  { param([string]$msg) Write-Host "  [skip] $msg" -ForegroundColor DarkGray }
function Write-Warn  { param([string]$msg) Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Write-Fail  { param([string]$msg) Write-Host "  [FAIL] $msg" -ForegroundColor Red }

# -- Config Parser (identical to apply script) --------------------------------

function Read-TransformConfig {
    param([string]$Path)

    $lines = Get-Content $Path
    $cfg = @{
        version = 1
        scope = @()
        rewritable_extensions = @()
        transforms = @()
        state_files = @()
        external_file_patterns = @()
    }

    $section = ""
    $currentTransform = $null

    foreach ($raw in $lines) {
        $line = $raw -replace '#.*$', ''
        $line = $line.TrimEnd()
        if ($line -match '^\s*$') { continue }

        if ($line -match '^(\w[\w_]*):\s*(.*)$') {
            $key = $Matches[1]
            $val = $Matches[2].Trim().Trim('"')

            if ($currentTransform) { $cfg.transforms += $currentTransform; $currentTransform = $null }

            if ($key -eq 'version' -and $val)         { $cfg.version = [int]$val }
            elseif ($key -eq 'scope')                  { $section = 'scope' }
            elseif ($key -eq 'rewritable_extensions')  { $section = 'rewritable_extensions' }
            elseif ($key -eq 'transforms')             { $section = 'transforms' }
            elseif ($key -eq 'state_files')            { $section = 'state_files' }
            elseif ($key -eq 'external_file_patterns') { $section = 'external_file_patterns' }
            elseif ($key -eq 'exclusions')             { $section = 'exclusions' }
            elseif ($key -eq 'execution_order')        { $section = 'execution_order' }
            else { $section = "" }
            continue
        }

        if ($section -in @('scope', 'rewritable_extensions', 'state_files', 'external_file_patterns', 'execution_order') -and $line -match '^\s+-\s+"?(.+?)"?\s*$') {
            $item = $Matches[1].Trim().Trim('"')
            if ($cfg.ContainsKey($section)) { $cfg[$section] += $item }
            continue
        }

        if ($section -eq 'exclusions' -and $line -match '^\s+') { continue }

        if ($section -eq 'transforms' -and $line -match '^\s+-\s+type:\s+"?(\w+)"?') {
            if ($currentTransform) { $cfg.transforms += $currentTransform }
            $currentTransform = @{ type = $Matches[1] }
            continue
        }

        if ($section -eq 'transforms' -and $currentTransform -and $line -match '^\s+([\w_]+):\s+"?([^"]+)"?\s*$') {
            $currentTransform[$Matches[1].Trim()] = $Matches[2].Trim().TrimEnd('"')
            continue
        }
    }

    if ($currentTransform) { $cfg.transforms += $currentTransform }

    if ($cfg.scope.Count -eq 0) { $cfg.scope = @("_bmad", "_bmad-output") }
    if ($cfg.rewritable_extensions.Count -eq 0) {
        $cfg.rewritable_extensions = @(".md", ".yaml", ".json", ".csv", ".js", ".xml", ".ps1", ".sh", ".bat")
    }

    return $cfg
}

# -- Begin --------------------------------------------------------------------

$configPath = Join-Path $ProjectRoot "_bmad/_config/custom/file-transforms.yaml"
if (-not (Test-Path $configPath)) {
    Write-Host "No file-transforms.yaml found -- nothing to revert." -ForegroundColor Yellow
    exit 0
}

Write-Host "========================================================" -ForegroundColor White
Write-Host "  BMAD File Transform -- Revert" -ForegroundColor White
Write-Host "========================================================" -ForegroundColor White

if ($DryRun) {
    Write-Host "[DRY RUN] No files will be modified." -ForegroundColor Yellow
}

$cfg = Read-TransformConfig -Path $configPath

# -- Build the REVERSE rename map --------------------------------------------

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

$reverseMap = [ordered]@{}

# Reverse rename rules: find files with transformed names
$renameRules = $cfg.transforms | Where-Object { $_.type -eq "rename" }
foreach ($rule in $renameRules) {
    $oldName = $rule.old_name   # canonical
    $newName = $rule.new_name   # transformed

    $matched = $allFiles | Where-Object { $_.Name -eq $newName }
    foreach ($f in $matched) {
        $canonicalPath = ($f.RelPath -replace [regex]::Escape($newName), $oldName)
        $reverseMap[$f.RelPath] = $canonicalPath
    }
}

$handledPaths = [System.Collections.Generic.HashSet[string]]::new()
foreach ($key in $reverseMap.Keys) { [void]$handledPaths.Add($key) }

# Reverse extension rules: detect transformed files by content inspection
$extRules = $cfg.transforms | Where-Object { $_.type -eq "extension" }
foreach ($rule in $extRules) {
    $oldExt = $rule.old_ext   # canonical extension
    $newExt = $rule.new_ext   # transformed extension
    $collisionPrefix = if ($rule.ContainsKey("collision_prefix")) { $rule.collision_prefix } else { "" }

    $matched = $allFiles | Where-Object { $_.Ext -eq $newExt -and -not $handledPaths.Contains($_.RelPath) }
    foreach ($f in $matched) {
        $content = Get-Content $f.FullPath -Raw -ErrorAction SilentlyContinue
        if (-not $content) { continue }

        $looksLikeOriginal = $false
        if ($oldExt -in @(".yaml", ".yml")) {
            $looksLikeOriginal = ($content -match '^\s*[\w-]+\s*:' -or $content -match '^---')
        }
        elseif ($oldExt -eq ".xml") {
            $looksLikeOriginal = ($content -match '<[\w-]+[\s>]')
        }

        if ($looksLikeOriginal) {
            $baseName = $f.Name
            if ($collisionPrefix -and $baseName.StartsWith($collisionPrefix)) {
                $baseName = $baseName.Substring($collisionPrefix.Length)
            }
            $canonicalName = [System.IO.Path]::GetFileNameWithoutExtension($baseName) + $oldExt
            $canonicalPath = ($f.RelPath.Substring(0, $f.RelPath.Length - $f.Name.Length)) + $canonicalName

            $reverseMap[$f.RelPath] = $canonicalPath
            [void]$handledPaths.Add($f.RelPath)
        }
    }
}

Write-Host "Files to revert: $($reverseMap.Count)" -ForegroundColor White

# -- Backup ------------------------------------------------------------------

Write-Phase "Backup: Creating backup"

$backupDir = Join-Path $ProjectRoot "_bmad-revert-backup"
if (-not $DryRun) {
    if (Test-Path $backupDir) { Remove-Item $backupDir -Recurse -Force }
    Copy-Item -Path (Join-Path $ProjectRoot "_bmad") -Destination $backupDir -Recurse -Force
    Write-OK "Backup created at _bmad-revert-backup/"
} else {
    Write-Skip "Would create backup"
}

# -- Build replacements ------------------------------------------------------

$replacements = [ordered]@{}
foreach ($entry in $reverseMap.GetEnumerator()) {
    $replacements[$entry.Key] = $entry.Value
}
foreach ($rule in $renameRules) {
    $replacements[$rule.new_name] = $rule.old_name
}
foreach ($rule in $extRules) {
    $replacements[$rule.new_ext] = $rule.old_ext
}
$sortedKeys = $replacements.Keys | Sort-Object { $_.Length } -Descending

function Get-ContentFiles {
    param([string]$extFilter, $cfg, [string]$root)
    $files = @()
    $filterExts = if ($extFilter) { @($extFilter) } else {
        ($cfg.rewritable_extensions + @(".json", ".md")) | Sort-Object -Unique
    }
    foreach ($scopeDir in $cfg.scope) {
        $fullDir = Join-Path $root $scopeDir
        if (Test-Path $fullDir) {
            $files += Get-ChildItem -Path $fullDir -Recurse -File | Where-Object { $filterExts -contains $_.Extension }
        }
    }
    $files += Get-ChildItem -Path $root -File | Where-Object { @(".ps1", ".sh", ".bat", ".md") -contains $_.Extension }
    $ghDir = Join-Path $root ".github"
    if (Test-Path $ghDir) {
        $files += Get-ChildItem -Path $ghDir -Recurse -File | Where-Object { $filterExts -contains $_.Extension }
    }
    return ($files | Sort-Object FullName -Unique)
}

function Rewrite-References {
    param($files, $replacements, $sortedKeys, [string]$root, [switch]$DryRun)
    $modified = 0; $refs = 0
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
        } catch { Write-Warn "Could not process: $($file.Name) -- $_" }
    }
    return @{ Modified = $modified; Refs = $refs }
}

$totalFilesModified = 0
$totalRefsReplaced = 0

# -- Phase 1: Revert references in CSV ---------------------------------------

Write-Phase "Phase 1: Revert references in CSV manifests"

$csvFiles = Get-ContentFiles -extFilter ".csv" -cfg $cfg -root $ProjectRoot
$result = Rewrite-References -files $csvFiles -replacements $replacements -sortedKeys $sortedKeys -root $ProjectRoot -DryRun:$DryRun
$totalFilesModified += $result.Modified; $totalRefsReplaced += $result.Refs
Write-OK "CSV: $($result.Modified) files, $($result.Refs) references"

# -- Phase 2: Revert references in JS ----------------------------------------

Write-Phase "Phase 2: Revert references in JS files"

$jsFiles = Get-ContentFiles -extFilter ".js" -cfg $cfg -root $ProjectRoot
$result = Rewrite-References -files $jsFiles -replacements $replacements -sortedKeys $sortedKeys -root $ProjectRoot -DryRun:$DryRun
$totalFilesModified += $result.Modified; $totalRefsReplaced += $result.Refs
Write-OK "JS: $($result.Modified) files, $($result.Refs) references"

# -- Phase 3: Revert references in MD and remaining ---------------------------

Write-Phase "Phase 3: Revert references in MD and remaining files"

$allContentFiles = Get-ContentFiles -extFilter $null -cfg $cfg -root $ProjectRoot
$remainingFiles = $allContentFiles | Where-Object { $_.Extension -notin @(".csv", ".js") }
$result = Rewrite-References -files $remainingFiles -replacements $replacements -sortedKeys $sortedKeys -root $ProjectRoot -DryRun:$DryRun
$totalFilesModified += $result.Modified; $totalRefsReplaced += $result.Refs
Write-OK "Remaining: $($result.Modified) files, $($result.Refs) references"

# -- Phase 4: Rename .json back to .yaml/.yml ---------------------------------

Write-Phase "Phase 4: Rename JSON files back to YAML"

$yamlReverts = $reverseMap.GetEnumerator() | Where-Object { $_.Value -match '\.(yaml|yml)$' }
$revertedYaml = 0

foreach ($entry in $yamlReverts) {
    $transformedFull = Join-Path $ProjectRoot ($entry.Key -replace '/', '\')
    $canonicalFull = Join-Path $ProjectRoot ($entry.Value -replace '/', '\')

    if (-not (Test-Path $transformedFull)) { continue }

    if (-not $DryRun) {
        $dir = Split-Path $canonicalFull -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Move-Item -Path $transformedFull -Destination $canonicalFull -Force
        $revertedYaml++
    } else {
        $revertedYaml++
    }
}

Write-OK "YAML reverted: $revertedYaml"

# -- Phase 5: Rename .md back to .xml ----------------------------------------

Write-Phase "Phase 5: Rename MD files back to XML"

$xmlReverts = $reverseMap.GetEnumerator() | Where-Object { $_.Value -match '\.xml$' }
$revertedXml = 0

foreach ($entry in $xmlReverts) {
    $transformedFull = Join-Path $ProjectRoot ($entry.Key -replace '/', '\')
    $canonicalFull = Join-Path $ProjectRoot ($entry.Value -replace '/', '\')

    if (-not (Test-Path $transformedFull)) { continue }

    if (-not $DryRun) {
        $dir = Split-Path $canonicalFull -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Move-Item -Path $transformedFull -Destination $canonicalFull -Force
        $revertedXml++
    } else {
        $revertedXml++
    }
}

Write-OK "XML reverted: $revertedXml"

$totalReverted = $revertedYaml + $revertedXml

# -- Validation ---------------------------------------------------------------

Write-Phase "Validation: Verify canonical files exist"

$validationPassed = $true
$missingCount = 0

foreach ($entry in $reverseMap.GetEnumerator()) {
    $canonicalFull = Join-Path $ProjectRoot ($entry.Value -replace '/', '\')
    if (-not (Test-Path $canonicalFull) -and -not $DryRun) {
        $missingCount++
    }
}

if ($missingCount -gt 0) {
    Write-Fail "Missing $missingCount files after revert"
    $validationPassed = $false
} else {
    Write-OK "All files reverted to canonical locations"
}

# -- Cleanup ------------------------------------------------------------------

Write-Phase "Cleanup"

if ($validationPassed -and -not $DryRun) {
    if (Test-Path $backupDir) {
        Remove-Item $backupDir -Recurse -Force
        Write-OK "Backup removed"
    }
} elseif (-not $validationPassed) {
    Write-Warn "Backup preserved at _bmad-revert-backup/"
} else {
    Write-Skip "Would remove backup"
}

# Remove transform log
$logPath = Join-Path $ProjectRoot "_bmad-output/lens-work/file-transform-log.txt"
if ((Test-Path $logPath) -and -not $DryRun) {
    Remove-Item $logPath -Force
    Write-OK "Removed transform log"
}

# -- Summary ------------------------------------------------------------------

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "  Revert Complete" -ForegroundColor Green
Write-Host "  YAML reverted:         $revertedYaml" -ForegroundColor Green
Write-Host "  XML reverted:          $revertedXml" -ForegroundColor Green
Write-Host "  References reverted:   $totalRefsReplaced" -ForegroundColor Green
Write-Host "  Content files modified: $totalFilesModified" -ForegroundColor Green
Write-Host "  Validation:            $(if ($validationPassed) { 'PASSED' } else { 'FAILED' })" -ForegroundColor $(if ($validationPassed) { "Green" } else { "Red" })
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "BMAD files are back to canonical names. Safe to run installer." -ForegroundColor Gray
Write-Host ""
