/**
 * @bmad-lens/file-transforms
 *
 * Programmatic API for the BMAD file transform engine.
 * Renames files and rewrites references to dodge org-level
 * Copilot content-exclusion rules.
 *
 * Most consumers will use the CLI:
 *   npx @bmad-lens/file-transforms apply --dry-run
 *   npx @bmad-lens/file-transforms revert
 *   npx @bmad-lens/file-transforms init
 */
const { execFileSync } = require('node:child_process');
const path = require('node:path');
const fs = require('node:fs');

/**
 * Find a working PowerShell executable.
 * @returns {string|null}
 */
function findPowerShell() {
  const candidates = process.platform === 'win32'
    ? ['pwsh', 'powershell']
    : ['pwsh'];

  for (const cmd of candidates) {
    try {
      execFileSync(cmd, ['-Version'], { stdio: 'ignore' });
      return cmd;
    } catch { /* not found */ }
  }
  return null;
}

/**
 * Run the apply-file-transforms.ps1 script.
 *
 * @param {object} options
 * @param {string} options.projectRoot - Absolute path to the BMAD control repo
 * @param {boolean} [options.dryRun]   - If true, no files are modified
 * @returns {void}
 * @throws {Error} if PowerShell is not found or the script fails
 */
function apply({ projectRoot, dryRun = false }) {
  const ps = findPowerShell();
  if (!ps) throw new Error('PowerShell (pwsh or powershell) not found');

  const script = path.join(__dirname, 'scripts', 'apply-file-transforms.ps1');
  const args = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', script, '-ProjectRoot', projectRoot];
  if (dryRun) args.push('-DryRun');

  execFileSync(ps, args, { stdio: 'inherit', cwd: projectRoot });
}

/**
 * Run the revert-file-transforms.ps1 script.
 *
 * @param {object} options
 * @param {string} options.projectRoot - Absolute path to the BMAD control repo
 * @param {boolean} [options.dryRun]   - If true, no files are modified
 * @returns {void}
 * @throws {Error} if PowerShell is not found or the script fails
 */
function revert({ projectRoot, dryRun = false }) {
  const ps = findPowerShell();
  if (!ps) throw new Error('PowerShell (pwsh or powershell) not found');

  const script = path.join(__dirname, 'scripts', 'revert-file-transforms.ps1');
  const args = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', script, '-ProjectRoot', projectRoot];
  if (dryRun) args.push('-DryRun');

  execFileSync(ps, args, { stdio: 'inherit', cwd: projectRoot });
}

/**
 * Get the path to the default config template.
 * @returns {string}
 */
function getTemplatePath() {
  return path.join(__dirname, 'templates', 'file-transforms.yaml');
}

module.exports = { apply, revert, getTemplatePath };
