---
name: bootstrap
description: Setup TargetProjects from service map
agent: scout
trigger: "@scout bootstrap"
category: utility
---

# Bootstrap Workflow

**Purpose:** Set up TargetProjects by running discovery, reconcile, and documentation.

---

## Execution Sequence

### 1. Check Prerequisites

```yaml
# Check for service map
service_map_paths = [
  "_bmad/lens-work/service-map.yaml",
  "_lens/domain-map.yaml",
  "lens/domain-map.yaml"
]

service_map = null
for path in service_map_paths:
  if file_exists(path):
    service_map = load(path)
    break

if service_map == null:
  output: |
    ⚠️ No service map found.
    
    Bootstrap requires a service map at one of:
    - _bmad/lens-work/service-map.yaml
    - _lens/domain-map.yaml
    - lens/domain-map.yaml
    
    Create a service map first, then run bootstrap again.
  exit: 1
```

### 2. Run Discovery

```yaml
invoke: scout.repo-discover

inventory = load("_bmad-output/lens-work/repo-inventory.yaml")
```

### 3. Confirm Actions

```yaml
output: |
  📋 Bootstrap Plan
  
  Service map: ${service_map_path}
  TargetProjects: ${config.target_projects_path}
  
  Actions:
  ├── Clone: ${inventory.repos.missing.length} repos
  ├── Document: ${inventory.repos.matched.length + inventory.repos.missing.length} repos
  └── Skip: ${inventory.repos.extra.length} extra repos (not in service map)
  
  Estimated time: ${estimate_time(inventory)} minutes
  
  Proceed? [Y]es / [N]o
```

### 4. Run Reconcile

```yaml
if confirmed:
  invoke: scout.repo-reconcile
```

### 5. Run Documentation

```yaml
invoke: scout.repo-document
params:
  mode: "full"
```

### 6. Generate Report

```yaml
report = {
  timestamp: now(),
  service_map: service_map_path,
  target_projects: config.target_projects_path,
  repos_cloned: cloned_count,
  repos_documented: documented_count,
  errors: errors,
  duration: duration
}

save_markdown(report, "_bmad-output/lens-work/bootstrap-report.md")
```

### 7. Output Summary

```
✅ Bootstrap Complete

Duration: ${report.duration}

Results:
├── Cloned: ${report.repos_cloned} repos
├── Documented: ${report.repos_documented} repos
${if report.errors.length > 0}
├── Errors: ${report.errors.length}
${endif}
└── Report: _bmad-output/lens-work/bootstrap-report.md

Canonical docs at: Docs/

Ready to start an initiative:
└── Run #new-feature "your-feature-name"
```
