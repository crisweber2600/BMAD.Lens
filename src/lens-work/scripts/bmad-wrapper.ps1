# LENS Workbench v2.0.0 - BMAD Command Wrapper
# =============================================================================
# This wrapper ensures branch preflight check runs before EVERY BMAD command
# Install by adding to PowerShell profile or as an alias
# =============================================================================

function Invoke-BMAD {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )

    # Set environment variables for preflight
    $env:BMAD_PROCESS_NAME = "bmad"
    $env:BMAD_COMMAND = $Arguments -join ' '

    # Determine script directory
    $scriptDir = "$PSScriptRoot"
    if (-not $scriptDir) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    }

    # Path to preflight script
    $preflightScript = Join-Path $scriptDir "bmad-preflight.ps1"

    # Check if preflight script exists
    if (-not (Test-Path $preflightScript)) {
        # Try alternative paths
        $alternativePaths = @(
            "_bmad/_config/custom/lens-work/scripts/bmad-preflight.ps1",
            "_bmad/lens-work/scripts/bmad-preflight.ps1",
            ".bmad/scripts/bmad-preflight.ps1"
        )

        foreach ($path in $alternativePaths) {
            if (Test-Path $path) {
                $preflightScript = $path
                break
            }
        }
    }

    # Run preflight check (unless explicitly disabled)
    if ($env:BMAD_SKIP_PREFLIGHT -ne "true") {
        if (Test-Path $preflightScript) {
            Write-Host "🚀 Running BMAD pre-flight check..." -ForegroundColor Cyan

            # Run preflight
            & $preflightScript -Silent:$false

            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ Pre-flight check failed" -ForegroundColor Red
                return $LASTEXITCODE
            }

            Write-Host "✅ Pre-flight check passed" -ForegroundColor Green
            Write-Host "" # Blank line for clarity
        } else {
            Write-Host "⚠️  Pre-flight script not found - skipping check" -ForegroundColor Yellow
        }
    }

    # Now run the actual BMAD command
    # Check if bmad.exe exists in common locations
    $bmadPaths = @(
        "bmad.exe",
        "bmad",
        "_bmad/bin/bmad.exe",
        "_bmad/bin/bmad",
        "$env:BMAD_HOME/bmad.exe",
        "$env:BMAD_HOME/bmad"
    )

    $bmadExe = $null
    foreach ($path in $bmadPaths) {
        if (Get-Command $path -ErrorAction SilentlyContinue) {
            $bmadExe = $path
            break
        }
    }

    if ($bmadExe) {
        # Execute BMAD with original arguments
        & $bmadExe @Arguments
    } else {
        Write-Error "BMAD executable not found. Please ensure BMAD is installed and in PATH."
        return 1
    }
}

# Set up alias
Set-Alias -Name bmad -Value Invoke-BMAD -Scope Global -Force

# Also create shortcuts for common LENS commands
function lens { Invoke-BMAD @args }
function compass { Invoke-BMAD compass @args }
function casey { Invoke-BMAD casey @args }
function tracey { Invoke-BMAD tracey @args }
function scout { Invoke-BMAD scout @args }
function scribe { Invoke-BMAD scribe @args }

# Export functions
Export-ModuleMember -Function Invoke-BMAD, lens, compass, casey, tracey, scout, scribe -Alias bmad

Write-Host @"
╔════════════════════════════════════════════════════════════════════╗
║                    LENS Workbench v2.0.0 Loaded                    ║
║                                                                     ║
║  BMAD commands will now run automatic pre-flight branch checks     ║
║                                                                     ║
║  Commands available:                                               ║
║    bmad     - Run any BMAD command with preflight                 ║
║    lens     - LENS Workbench commands                             ║
║    compass  - Phase router commands                               ║
║    casey    - Git orchestration                                   ║
║    tracey   - State management                                    ║
║    scout    - Discovery                                           ║
║    scribe   - Governance                                          ║
║                                                                     ║
║  To skip preflight: `$env:BMAD_SKIP_PREFLIGHT = "true"            ║
║  To auto-create branches: `$env:BMAD_AUTO_CREATE_BRANCH = "true"  ║
║                                                                     ║
╚════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan