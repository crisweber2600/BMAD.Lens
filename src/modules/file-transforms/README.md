# @bmad-lens/file-transforms

**Post-install file transform engine for BMAD** — renames files and rewrites all internal references to dodge org-level GitHub Copilot content-exclusion rules.

---

## Problem

Many organizations configure GitHub Copilot to exclude files matching certain patterns (e.g., `*.yaml`, `*.xml`). BMAD modules rely heavily on YAML configs, agent definitions, and workflow manifests. This package provides an automated, idempotent transform pipeline that:

1. Renames files (`.yaml` → `.json`, `.xml` → `.md`, etc.)
2. Rewrites **all** internal references across CSV manifests, JS files, Markdown, and more
3. Validates file integrity after transforms
4. Reverts cleanly before upgrades so the BMAD installer sees canonical filenames

## Quick Start

```bash
# Initialize a default config in your BMAD control repo
npx @bmad-lens/file-transforms init

# Preview what would change
npx @bmad-lens/file-transforms apply --dry-run

# Apply transforms
npx @bmad-lens/file-transforms apply

# Revert before an upgrade
npx @bmad-lens/file-transforms revert
```

## Configuration

The transform rules live in `_bmad/_config/custom/file-transforms.yaml`. Run `init` to create a default config, then customize:

```yaml
version: 1

scope:
  - _bmad
  - _bmad-output

transforms:
  - type: rename
    old_name: "config.yaml"
    new_name: "bmad-config.json"

  - type: extension
    old_ext: ".yaml"
    new_ext: ".json"

  - type: extension
    old_ext: ".yml"
    new_ext: ".json"

  - type: extension
    old_ext: ".xml"
    new_ext: ".md"
    collision_prefix: "x-"

exclusions:
  paths:
    - "_bmad-output/lens-work/state.yaml"
  external_patterns:
    - "pom.xml"
    - "results.xml"
```

## Integration with install-lens-work-relative.ps1

The install script already calls these scripts automatically:

- **Step 0**: `revert-file-transforms.ps1` (before upgrade)
- **Step 4**: `apply-file-transforms.ps1` (after install)

## Programmatic API

```javascript
const { apply, revert } = require('@bmad-lens/file-transforms');

// Apply transforms
apply({ projectRoot: '/path/to/control-repo', dryRun: false });

// Revert transforms
revert({ projectRoot: '/path/to/control-repo' });
```

## Requirements

- **Node.js** >= 18
- **PowerShell** (pwsh or powershell) — the transform engine is PowerShell-based for robust file system operations

## License

MIT
