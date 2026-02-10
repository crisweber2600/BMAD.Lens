#!/usr/bin/env node
'use strict';

const { Command } = require('commander');
const { execFileSync } = require('node:child_process');
const path = require('node:path');
const fs = require('node:fs');
const chalk = require('chalk');

const pkg = require('../package.json');

const program = new Command();

program
  .name('bmad-transform')
  .description('BMAD file transform engine — rename files and rewrite references')
  .version(pkg.version);

/**
 * Find the PowerShell executable (pwsh preferred, falls back to powershell on Windows).
 */
function findPowerShell() {
  const candidates = process.platform === 'win32'
    ? ['pwsh', 'powershell']
    : ['pwsh'];

  for (const cmd of candidates) {
    try {
      execFileSync(cmd, ['-Version'], { stdio: 'ignore' });
      return cmd;
    } catch { /* not found, try next */ }
  }
  return null;
}

/**
 * Run a PowerShell script with the given arguments.
 */
function runScript(scriptName, args, opts) {
  const ps = findPowerShell();
  if (!ps) {
    console.error(chalk.red('PowerShell (pwsh or powershell) is required but not found.'));
    console.error(chalk.yellow('Install PowerShell: https://learn.microsoft.com/powershell/scripting/install/installing-powershell'));
    process.exit(1);
  }

  const scriptPath = path.join(__dirname, '..', 'scripts', scriptName);
  if (!fs.existsSync(scriptPath)) {
    console.error(chalk.red(`Script not found: ${scriptPath}`));
    process.exit(1);
  }

  const psArgs = [
    '-NoProfile',
    '-ExecutionPolicy', 'Bypass',
    '-File', scriptPath,
    ...args,
  ];

  try {
    execFileSync(ps, psArgs, {
      stdio: 'inherit',
      cwd: opts.root ? path.resolve(opts.root) : process.cwd(),
    });
  } catch (err) {
    process.exit(err.status || 1);
  }
}

// ─── apply ──────────────────────────────────────────────────────────────────
program
  .command('apply')
  .description('Apply file transforms (rename files + rewrite references)')
  .option('-r, --root <path>', 'Project root (defaults to cwd)', process.cwd())
  .option('-n, --dry-run', 'Preview changes without modifying files')
  .action((opts) => {
    const args = ['-ProjectRoot', path.resolve(opts.root)];
    if (opts.dryRun) args.push('-DryRun');
    runScript('apply-file-transforms.ps1', args, opts);
  });

// ─── revert ─────────────────────────────────────────────────────────────────
program
  .command('revert')
  .description('Revert file transforms (restore original filenames + references)')
  .option('-r, --root <path>', 'Project root (defaults to cwd)', process.cwd())
  .option('-n, --dry-run', 'Preview changes without modifying files')
  .action((opts) => {
    const args = ['-ProjectRoot', path.resolve(opts.root)];
    if (opts.dryRun) args.push('-DryRun');
    runScript('revert-file-transforms.ps1', args, opts);
  });

// ─── init ───────────────────────────────────────────────────────────────────
program
  .command('init')
  .description('Create a default file-transforms.yaml config in _bmad/_config/custom/')
  .option('-r, --root <path>', 'Project root (defaults to cwd)', process.cwd())
  .action((opts) => {
    const projectRoot = path.resolve(opts.root);
    const configDir = path.join(projectRoot, '_bmad', '_config', 'custom');
    const configFile = path.join(configDir, 'file-transforms.yaml');

    if (fs.existsSync(configFile)) {
      console.log(chalk.yellow(`Config already exists: ${configFile}`));
      return;
    }

    const templatePath = path.join(__dirname, '..', 'templates', 'file-transforms.yaml');
    if (!fs.existsSync(templatePath)) {
      console.error(chalk.red('Template not found — package may be corrupted'));
      process.exit(1);
    }

    fs.mkdirSync(configDir, { recursive: true });
    fs.copyFileSync(templatePath, configFile);
    console.log(chalk.green(`✓ Created ${configFile}`));
    console.log(chalk.gray('  Edit the file to customize transform rules, then run:'));
    console.log(chalk.gray('  npx @bmad-lens/file-transforms apply --dry-run'));
  });

// ─── info ───────────────────────────────────────────────────────────────────
program
  .command('info')
  .description('Show package version and paths')
  .action(() => {
    console.log(`  Package:  ${pkg.name}`);
    console.log(`  Version:  ${pkg.version}`);
    console.log(`  Scripts:  ${path.join(__dirname, '..', 'scripts')}`);
  });

program.parse();
