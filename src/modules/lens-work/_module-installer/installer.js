const fs = require('node:fs');
const fsp = require('node:fs/promises');
const path = require('node:path');
let chalk = null;
try {
    chalk = require('chalk');
} catch {
    // Optional dependency in some installer contexts
    chalk = {
        blue: (s) => s,
        yellow: (s) => s,
        green: (s) => s,
        gray: (s) => s,
        red: (s) => s,
    };
}

/**
 * LENS Workbench Module Installer
 * 
 * Handles:
 * - Creating output directories
 * - Setting up TargetProjects path
 * - Configuring docs output path
 * - IDE-specific configuration
 */
async function install(options) {
    const { projectRoot, config, installedIDEs, logger } = options;
    const pathExists = async (p) => {
        try {
            await fsp.access(p);
            return true;
        } catch {
            return false;
        }
    };
    const ensureDir = async (p) => {
        await fsp.mkdir(p, { recursive: true });
    };

    try {
        logger.log(chalk.blue('Installing LENS Workbench (lens-work)...'));

        // Create lens-work output directory
        const outputDir = path.join(projectRoot, '_bmad-output', 'lens-work');
        if (!(await pathExists(outputDir))) {
            logger.log(chalk.yellow(`Creating output directory: _bmad-output/lens-work/`));
            await ensureDir(outputDir);
        }

        // Create subdirectories
        const subdirs = ['dashboards', 'archive', 'snapshots'];
        for (const subdir of subdirs) {
            const subdirPath = path.join(outputDir, subdir);
            if (!(await pathExists(subdirPath))) {
                await ensureDir(subdirPath);
            }
        }

        // Create Docs output directory if specified
        if (config['docs_output_path']) {
            const docsPath = config['docs_output_path'].replace('{project-root}/', '');
            const docsDir = path.join(projectRoot, docsPath);
            if (!(await pathExists(docsDir))) {
                logger.log(chalk.yellow(`Creating docs directory: ${docsPath}/`));
                await ensureDir(docsDir);
            }
        }

        // Create lens-work config file
        const configDir = path.join(projectRoot, '_bmad', 'lens-work');
        if (!(await pathExists(configDir))) {
            await ensureDir(configDir);
        }

        const configFile = path.join(configDir, 'config.yaml');
        if (!(await pathExists(configFile))) {
            const configContent = `# LENS Workbench Configuration
# Generated during installation

# TargetProjects path (where repos are cloned)
target_projects_path: "${config['target_projects_path'] || '../TargetProjects'}"

# Docs output path
docs_output_path: "${config['docs_output_path'] || 'Docs'}"

# Telemetry settings
telemetry:
  enabled: ${config['enable_telemetry'] !== false}
  dashboard_format: json  # json, html

# Git settings
git:
  default_remote: ${config['default_git_remote'] || 'github'}
  fetch_strategy: background
  fetch_ttl: 60

# Role gating (advisory by default)
role_gating:
  enabled: true
  mode: advisory  # advisory, enforced
`;
            logger.log(chalk.yellow('Creating lens-work config file'));
            await fsp.writeFile(configFile, configContent);
        }

        // Initialize empty state file
        const stateFile = path.join(outputDir, 'state.yaml');
        if (!(await pathExists(stateFile))) {
            const stateContent = `# LENS Workbench State
# Auto-managed by lens-work - do not edit manually

version: 1
active_initiative: null
`;
            await fsp.writeFile(stateFile, stateContent);
        }

        // IDE-specific configuration
        if (installedIDEs && installedIDEs.length > 0) {
            for (const ide of installedIDEs) {
                await configureForIDE(ide, projectRoot, config, logger);
            }
        }

        logger.log(chalk.green('✓ LENS Workbench installation complete'));
        logger.log(chalk.gray('  Run "@lens-work onboard" to get started'));
        return true;
    } catch (error) {
        logger.error(chalk.red(`Error installing lens-work: ${error.message}`));
        return false;
    }
}

async function configureForIDE(ide, projectRoot, config, logger) {
    const platformSpecificPath = path.join(__dirname, 'platform-specifics', `${ide}.js`);

    try {
        if (await pathExists(platformSpecificPath)) {
            const platformHandler = require(platformSpecificPath);
            if (typeof platformHandler.install === 'function') {
                await platformHandler.install({ projectRoot, config, logger });
            }
        }
    } catch (error) {
        logger.warn(chalk.yellow(`Warning: Could not configure ${ide}: ${error.message}`));
    }
}

module.exports = { install };
