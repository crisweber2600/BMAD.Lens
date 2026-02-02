# LENS Module Installation Guide

## Problem: "Module directory not found" for git-lens, lens-compass, etc.

The BMAD npm installer looks for modules in `src/modules/{module-name}/`, but **git-lens, lens-compass, lens-sync, and spec are LENS extensions**, not standalone modules.

They live at:
```
src/modules/lens/extensions/git-lens/
src/modules/lens/extensions/lens-compass/
src/modules/lens/extensions/lens-sync/
src/modules/lens/extensions/spec/
```

## Solution: Install LENS Only

The LENS module installer automatically installs all extensions from `src/modules/lens/extensions/`.

### Installation Steps

1. **Run the LENS installer:**
   ```bash
   node src/modules/lens/_module-installer/installer.js install
   ```

2. **What gets installed:**
   - LENS core agents → `_bmad/lens/agents/`
   - LENS workflows → `_bmad/lens/workflows/`
   - LENS prompts → `.github/prompts/`
   - LENS config files → `_bmad/lens/`
   - **All extension modules** → `_bmad/{extension-name}/`
     - git-lens → `_bmad/git-lens/`
     - lens-compass → `_bmad/lens-compass/`
     - lens-sync → `_bmad/lens-sync/`
     - spec → `_bmad/spec/`

3. **Extensions are registered in manifest:**
   ```yaml
   installed_modules:
     - lens
     - git-lens
     - lens-compass
     - lens-sync
     - spec
   ```

## For Custom Installations

If you've already cached LENS as a custom module:

1. The cache is at: `_bmad/_config/custom/lens/`
2. Install from the cache using the LENS installer:
   ```bash
   node _bmad/_config/custom/lens/_module-installer/installer.js install
   ```

## What NOT to Do

❌ **Don't** try to install extensions separately:
```bash
npx bmad-method install git-lens  # ❌ Won't work
npx bmad-method install lens-compass  # ❌ Won't work
```

✅ **Do** install LENS, which auto-installs all extensions:
```bash
node src/modules/lens/_module-installer/installer.js install
```

## Verifying Installation

After running the LENS installer, check:
```bash
ls _bmad/lens/agents/          # Core LENS agents
ls _bmad/git-lens/workflows/   # git-lens workflows
ls _bmad/lens-compass/         # lens-compass module
ls _bmad/lens-sync/            # lens-sync module
ls _bmad/spec/                 # spec module
```

All should exist.

## Integration with `npx bmad-method install`

The BMAD installer should recognize LENS as a custom module and skip trying to install the extensions separately. If it's still trying to install them, the issue is that the installer doesn't know git-lens/lens-compass/etc. are **part of LENS**, not standalone modules.

The proper fix is to tell the BMAD installer that these are LENS extensions, not separate modules. This requires updating the BMAD installer to recognize extension relationships.

---

**Module Code:** `lens`  
**Extensions:** `git-lens`, `lens-compass`, `lens-sync`, `spec`  
**Installed at:** `_bmad/lens/` + `_bmad/{extension}/`
