# BMAD Module Installation Chain Fix

## Problem

The BMAD installer (`npx bmad-method install`) fails when trying to install custom LENS modules because it looks for git-lens, lens-compass, lens-sync, and spec as **standalone modules** in `src/modules/{name}/`, but they are actually **LENS extensions** located at `src/modules/lens/extensions/{name}/`.

## Root Cause

The BMAD npm package doesn't include these extensions because they're custom modules in development repos. The installer tries to install them individually and fails with:

```
Module directory not found: .../node_modules/bmad-method/src/modules/git-lens
Module directory not found: .../node_modules/bmad-method/src/modules/lens-compass
...
```

## Solution: Chain Installation

### 1. LENS Installer Auto-Installs Extensions

The LENS module installer now automatically installs all extensions from `src/modules/lens/extensions/`:

```javascript
// In src/modules/lens/_module-installer/installer.js
async function installExtensions({ projectRoot, logger, bmadRoot, lensRoot, memoryRoot, installedIDEs }) {
    const extensionsDir = path.join(__dirname, '..', 'extensions');
    const entries = await fs.readdir(extensionsDir, { withFileTypes: true });
    const extensions = entries.filter(e => e.isDirectory()).map(e => e.name);
    
    for (const extensionName of extensions) {
        await installExtension({ projectRoot, logger, bmadRoot, lensRoot, memoryRoot, extensionName, installedIDEs });
    }
}
```

**What gets installed:**
- LENS core → `_bmad/lens/`
- git-lens → `_bmad/git-lens/`
- lens-compass → `_bmad/lens-compass/`
- lens-sync → `_bmad/lens-sync/`
- spec → `_bmad/spec/`

### 2. FH Installer Chains LENS Installation

The File Harmonizer installer now checks if LENS is installed and auto-installs it if missing:

```javascript
// In src/modules/fh/_module-installer/installer.js
const lensRoot = path.join(bmadRoot, 'lens');
if (!(await pathExists(lensRoot))) {
    logger.log('  → LENS not found, installing LENS module first...');
    const lensInstaller = path.join(projectRoot, 'src', 'modules', 'lens', '_module-installer', 'installer.js');
    if (await pathExists(lensInstaller)) {
        const lensModule = require(lensInstaller);
        await lensModule.install({ projectRoot, logger, installedIDEs });
    }
}
```

### 3. CLI Entry Points Added

Both installers now have CLI entry points for direct execution:

```javascript
// CLI entry point
if (require.main === module) {
    const logger = { log: console.log, warn: console.warn, error: console.error };
    const projectRoot = process.cwd();
    
    install({ projectRoot, logger, installedIDEs: ['github-copilot'] })
        .then(success => process.exit(success ? 0 : 1))
        .catch(error => { logger.error(`Fatal error: ${error.message}`); process.exit(1); });
}
```

## Usage

### Install Everything (Recommended)

```bash
# From BMAD.Lens repo
cd /d/BMAD.Lens
node src/modules/fh/_module-installer/installer.js install
```

This will:
1. Check if LENS is installed
2. If not, install LENS (which auto-installs all extensions)
3. Install FH

### Install LENS Only

```bash
cd /d/BMAD.Lens
node src/modules/lens/_module-installer/installer.js install
```

### Verify Installation

```bash
ls _bmad/
# Expected output:
# lens/
# git-lens/
# lens-compass/
# lens-sync/
# spec/
# fh/

cat _bmad/_config/manifest.yaml
# Expected to see:
# installed_modules:
#   - git-lens
#   - lens-compass
#   - lens-sync
#   - spec
#   - lens
#   - fh
```

## What Changed

### LENS Installer (`src/modules/lens/_module-installer/installer.js`)
- ✅ Added CLI entry point with logger
- ✅ Extension auto-installation already worked
- ✅ Registers all extensions in manifest

### FH Installer (`src/modules/fh/_module-installer/installer.js`)
- ✅ Added LENS dependency check
- ✅ Auto-installs LENS if missing
- ✅ CLI entry point already existed
- ✅ Full file copying implementation
- ✅ Manifest registration

### Documentation
- ✅ Created [LENS-INSTALLATION-GUIDE.md](LENS-INSTALLATION-GUIDE.md)
- ✅ Updated prompt guidance in [src/modules/lens/prompts/bmad.start.prompt.md](src/modules/lens/prompts/bmad.start.prompt.md#L455)
- ✅ Updated prompt guidance in [Contoso.BMAD/_bmad/lens/prompts/bmad.start.prompt.md](../../Contoso.BMAD/_bmad/lens/prompts/bmad.start.prompt.md#L455)

## Integration with `npx bmad-method install`

The BMAD CLI installer needs to be updated to recognize that:
1. **git-lens, lens-compass, lens-sync, spec are NOT standalone modules**
2. They are **extensions of LENS**
3. Installing `lens` from custom cache should be sufficient

### Recommended BMAD CLI Fix

The BMAD installer should:
1. Detect that a custom module has extensions
2. Skip trying to install extensions as standalone modules
3. Rely on the parent module's installer to handle extensions

OR:

1. When it sees these modules in the cache manifest, recognize they're installed as part of LENS
2. Skip the "module not found" error for known extensions

## Testing

Tested on D:/BMAD.Lens:
```bash
$ cd /d/BMAD.Lens
$ node src/modules/lens/_module-installer/installer.js install
Installing LENS module assets...
✓ Updated .gitignore with 2 LENS entries
✓ Installed agent: _bmad\lens\agents\...
...
✓ git-lens extension installed
✓ lens-compass extension installed
✓ lens-sync extension installed
✓ spec extension installed
✓ LENS module installation complete
```

Result:
- All extensions installed ✅
- Manifest updated ✅
- No errors ✅

---

**Status:** ✅ Complete  
**Modules:** LENS, git-lens, lens-compass, lens-sync, spec, FH  
**Install Location:** `_bmad/{module}/`  
**Chain:** FH → LENS → all extensions
