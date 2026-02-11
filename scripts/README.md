# BMAD.Lens Build Scripts

Local build scripts for creating BMAD.Lens release packages.

## Scripts

### build-release.ps1 / build-release.sh (PRIMARY)
**Release build & dogfood** scripts that create a clean release package AND dogfood it to your local `_bmad/` directory.

**Usage:**
```powershell
# PowerShell (Windows)
.\scripts\build-release.ps1 -Version "1.0.5"

# Bash (Linux/Mac/WSL)
./scripts/build-release.sh 1.0.5
```

**What it does:**
1. Creates a clean release-build directory
2. Installs BMAD with official modules
3. Copies custom modules from `src/`
4. Configures IDE prompts
5. Creates release archive
6. **Dogfoods the built release to `_bmad/`** ⭐
7. Cleans up temporary build directory

**When to use:**
- After editing files in `src/modules/lens-work/` or `src/modules/file-transforms/`
- When you want to test a clean build locally
- Before pushing to a release branch
- This is now the recommended workflow for both building and testing

**Options:**
```powershell
# PowerShell
.\scripts\build-release.ps1 -Version "1.0.5" -SkipInstall

# Bash
./scripts/build-release.sh 1.0.5 true
```

### dogfood.sh / dogfood.ps1 (DEPRECATED)
⚠️ **DEPRECATED:** These scripts are now merged into `build-release`. They remain for quick copies without full rebuild but may not include all build validations.

**Usage:**
```bash
# Bash (Linux/Mac/WSL)
./scripts/dogfood.sh

# PowerShell (Windows)
.\scripts\dogfood.ps1
```

**What it does:**
- Copies `src/modules/lens-work/` → `_bmad/lens-work/`
- Copies `src/modules/file-transforms/` → `_bmad/file-transforms/`

**Recommendation:** Use `build-release` scripts instead for validated builds.

## Development Workflow

**Source-First Development Model:**

1. **Edit in `src/modules/`** — All changes go in source directory
2. **Build & dogfood** — Run `./scripts/build-release.sh {version}` to:
   - Build a clean release package
   - Dogfood it to your local `_bmad/` directory
3. **Validate** — Test the changes in your local `_bmad/` environment
4. **Push to release branch** — GitHub Actions will create the official release

**Quick iteration (optional):**
- For rapid testing without a full rebuild, you can still use `./scripts/dogfood.sh`
- But `build-release` is recommended for validated builds

## What Gets Built

The scripts create a complete BMAD.Lens release package containing:

### Official BMAD Modules
- **bmm** — BMAD Method Master
- **bmb** — BMAD Builder  
- **cis** — Creative Intelligence Suite
- **gds** — Game Dev Studio
- **tea** — Test Architect

### Custom Modules
- **lens-work** — LENS Workbench (guided lifecycle router)
- **file-transforms** — Post-install file transform engine

### IDE Configurations
- **Cursor** — Command prompts in `.cursor/commands/`
- **GitHub Copilot** — Agent definitions in `.github/agents/`
- **Claude Code** — Command prompts in `.claude/commands/`
- **Codex** — Command prompts in `.codex/prompts/`

### Additional Content
- GitHub prompts for lens-work in `.github/prompts/`
- Documentation in `docs/`
- Output directories in `_bmad-output/`

## Build Process

1. **Creates release-build directory** — Clean workspace for assembly
2. **Installs BMAD** — Downloads and configures official modules via npx
3. **Copies custom modules** — Adds lens-work and file-transforms from src/
4. **Configures IDE prompts** — Sets up Codex and GitHub integrations
5. **Creates archive** — Packages everything into a .zip or .tar.gz
6. **Dogfoods to local _bmad/** — Copies built modules to your working directory
7. **Cleans up** — Removes temporary release-build directory

## Output

- **PowerShell:** `bmad-lens-v{VERSION}.zip`
- **Bash:** `bmad-lens-v{VERSION}.zip` or `.tar.gz` (if zip unavailable)

## Testing the Build

After building, test the release:

```bash
# Extract to a temporary location
mkdir test-install
cd test-install
unzip ../bmad-lens-v1.0.4.zip

# Verify structure
ls _bmad/
ls .cursor/commands/
ls .github/prompts/

# Test a module
cat _bmad/lens-work/module.yaml
```

## CI/CD Integration

These scripts mirror the [.github/workflows/release.yml](../.github/workflows/release.yml) workflow:
- Local builds validate before pushing to release branches
- GitHub Actions uses the same steps for official releases
- Version is extracted from branch name in CI (e.g., `release/1.0.4` → `v1.0.4`)

## Troubleshooting

**"npx: command not found"**
- Install Node.js 22+ from https://nodejs.org/

**"Permission denied" on bash script**
- Run: `chmod +x scripts/build-release.sh`

**Archive size seems small**
- Check that BMAD installed correctly in release-build/_bmad/
- Verify src/modules/lens-work and file-transforms exist

**PowerShell execution policy error**
- Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
