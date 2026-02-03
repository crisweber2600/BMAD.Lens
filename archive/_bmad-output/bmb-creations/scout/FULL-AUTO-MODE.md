# SCOUT Full Auto Mode - Implementation Summary

## Overview

SCOUT agent now has a **FULL AUTO** mode that automatically runs DS → AC → GD on ALL projects in the domain map using `runSubagent` in YOLO mode (no confirmations).

## What Was Modified

### 1. SCOUT Agent ([scout.agent.yaml](../../../src/modules/lens/extensions/lens-sync/agents/scout/scout.agent.yaml))

Added new menu item at the top:

```yaml
- trigger: AUTO or YOLO or fuzzy match on full auto
  exec: inline
  description: '[AUTO] Full auto mode - Run DS → AC → GD on all projects in YOLO mode'
```

**Behavior:**
1. **Loads domain map** from `{project-root}/_lens/domain-map.yaml`
2. **Extracts all projects** (services + microservices)
3. **Phase 1: DS on all** - Uses `runSubagent` to run discover workflow on each project
4. **Phase 2: AC on all** - Uses `runSubagent` to run analyze-codebase on each project
5. **Phase 3: GD on all** - Uses `runSubagent` to run generate-docs on each project
6. **Final Report** - Consolidated summary of all discoveries

**Key Features:**
- ✅ Uses `#tool:runSubagent` for parallel/sequential execution
- ✅ YOLO mode - no confirmations needed
- ✅ Processes ALL projects in domain map automatically
- ✅ Returns comprehensive summary report
- ✅ Estimates: ~15-30 minutes per project

### 2. Discover Workflow Handoff ([step-05-handoff-scout.md](../../../src/modules/lens/extensions/lens-sync/workflows/discover/steps-c/step-05-handoff-scout.md))

Updated to trigger SCOUT AUTO mode instead of manual pipeline:

**Before:**
```
Activate SCOUT agent with YOLO flag
Execute: DS → AC → GD pipeline on single target
```

**After:**
```
Activate SCOUT agent: AUTO mode
SCOUT will:
- Load domain map
- Execute DS → AC → GD on EVERY project
- Return consolidated summary
```

## Usage

### Option 1: Direct SCOUT Activation

```
User: SCOUT
Agent: [shows SCOUT menu]
User: AUTO
Agent: [runs full auto mode on all projects]
```

### Option 2: Via Discover Workflow

```
User: DISC (from Navigator)
Agent: [runs discover workflow steps 00-04]
Agent: [step-05 hands off to SCOUT AUTO mode]
SCOUT: [runs DS → AC → GD on all projects automatically]
```

### Option 3: Alternative Triggers

Any of these activate AUTO mode:
- `AUTO`
- `YOLO`
- "full auto"
- "run everything"

## Expected Flow

1. **User triggers DISC from Navigator**
2. **Discover workflow runs** (steps 00-04)
   - Preflight checks
   - Select initial target
   - Extract git context
   - Basic analysis
   - Generate initial docs
3. **Step 05: Handoff to SCOUT**
   - Display handoff message
   - Activate SCOUT agent
   - Trigger AUTO mode
4. **SCOUT AUTO Mode Executes**
   - Read domain-map.yaml
   - For each project:
     - DS: Run discover workflow (brownfield analysis)
     - AC: Run analyze-codebase (deep technical analysis)
     - GD: Run generate-docs (comprehensive documentation)
5. **SCOUT Returns Summary**
   - Projects processed count
   - Per-project metrics (services, confidence, docs)
   - Total documentation generated
   - Elapsed time

## Benefits

✅ **Fully Automated** - No manual intervention needed  
✅ **Comprehensive** - Covers ALL projects in domain map  
✅ **Consistent** - Same pipeline for every project  
✅ **Parallelizable** - Uses subagent tool for efficiency  
✅ **Transparent** - Clear progress reporting  
✅ **Reproducible** - YOLO mode ensures same behavior  

## Example Output

```
✅ SCOUT Full Auto Discovery Complete

Projects Processed: 13

- NS4.WebAPI
  - DS: ✅ 1 service, 8 controllers
  - AC: ✅ 92/100 confidence
  - GD: ✅ 5 documents generated (2.3MB)

- IdentityServer
  - DS: ✅ 1 service, 12 controllers
  - AC: ✅ 88/100 confidence
  - GD: ✅ 5 documents generated (1.8MB)

... (11 more projects)

Total Documentation: 65 files, 28.4MB
Total Time: 4h 23m

All discovery artifacts ready for use.
```

## Files Modified

1. `src/modules/lens/extensions/lens-sync/agents/scout/scout.agent.yaml`
   - Added AUTO mode menu item with inline instructions
   
2. `src/modules/lens/extensions/lens-sync/workflows/discover/steps-c/step-05-handoff-scout.md`
   - Updated to trigger SCOUT AUTO mode
   - Enhanced completion documentation

## What This Fixes

From the user's real-world scenario:
- ❌ **Before:** Navigator runs DISC → only does initial discovery → stops
- ✅ **After:** Navigator runs DISC → initial discovery → SCOUT AUTO → DS+AC+GD on ALL projects

The user saw SCOUT being activated but it just showed a menu. Now when triggered via the discover workflow handoff, SCOUT will automatically execute the full pipeline on all projects without requiring menu selections.
