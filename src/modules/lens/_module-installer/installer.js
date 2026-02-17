const fs = require('fs-extra');
const path = require('node:path');
const chalk = require('chalk');

/**
 * Lens Module Installer
 *
 * Handles:
 * - Creating output directories (state, events, dashboards, initiatives)
 * - Setting up config file
 * - Initializing empty state
 * - Copying Copilot instructions to .github/
 * - IDE-specific configuration
 */
async function install(options) {
    const { projectRoot, config, installedIDEs, logger } = options;

    try {
        logger.log(chalk.blue('Installing Lens...'));

        // Create lens output directory
        const outputDir = path.join(projectRoot, '_bmad-output', 'lens');
        if (!(await fs.pathExists(outputDir))) {
            logger.log(chalk.yellow('Creating output directory: _bmad-output/lens/'));
            await fs.ensureDir(outputDir);
        }

        // Create subdirectories
        const subdirs = ['dashboards', 'initiatives', 'profiles', 'snapshots', 'archive'];
        for (const subdir of subdirs) {
            const subdirPath = path.join(outputDir, subdir);
            if (!(await fs.pathExists(subdirPath))) {
                await fs.ensureDir(subdirPath);
            }
        }

        // Create Docs output directory if specified
        if (config['docs_output_path']) {
            const docsPath = config['docs_output_path'].replace('{project-root}/', '');
            const docsDir = path.join(projectRoot, docsPath);
            if (!(await fs.pathExists(docsDir))) {
                logger.log(chalk.yellow(`Creating docs directory: ${docsPath}/`));
                await fs.ensureDir(docsDir);
            }
        }

        // Create lens config file
        const configDir = path.join(projectRoot, '_bmad', 'lens');
        if (!(await fs.pathExists(configDir))) {
            await fs.ensureDir(configDir);
        }

        const configFile = path.join(configDir, 'config.yaml');
        if (!(await fs.pathExists(configFile))) {
            const audiences = config['default_audiences'] || 'small,medium,large';
            const configContent = `# Lens Configuration
# Generated during installation

# TargetProjects path (where repos are cloned)
target_projects_path: "${config['target_projects_path'] || '../TargetProjects'}"

# Docs output path
docs_output_path: "${config['docs_output_path'] || 'Docs'}"

# Telemetry settings
telemetry:
  enabled: ${config['enable_telemetry'] === true}

# Discovery settings
discovery:
  depth: ${config['discovery_depth'] || 'shallow'}

# JIRA integration
jira:
  enabled: ${config['enable_jira_integration'] === true}

# Git settings
git:
  default_remote: "${config['default_git_remote'] || 'origin'}"
  fetch_strategy: background
  fetch_ttl: 60

# Default audiences for new initiatives
default_audiences:
${audiences.split(',').map(a => `  - ${a.trim()}`).join('\n')}
`;
            logger.log(chalk.yellow('Creating lens config file'));
            await fs.writeFile(configFile, configContent);
        }

        // Initialize empty state file
        const stateFile = path.join(outputDir, 'state.yaml');
        if (!(await fs.pathExists(stateFile))) {
            const stateContent = `# Lens State
# Auto-managed by Lens — do not edit manually
# Use /sync, /fix, or /override for state repairs

lens_contract_version: "2.0"
active_initiative: null
background_errors: []
workflow_status: idle
`;
            await fs.writeFile(stateFile, stateContent);
        }

        // Initialize empty event log
        const eventLogFile = path.join(outputDir, 'event-log.jsonl');
        if (!(await fs.pathExists(eventLogFile))) {
            await fs.writeFile(eventLogFile, '');
        }

        // Copy copilot instructions to .github folder
        const sourceInstructionsFile = path.join(__dirname, '..', 'docs', 'copilot-instructions.md');
        const githubDir = path.join(projectRoot, '.github');
        const targetInstructionsFile = path.join(githubDir, 'lens-instructions.md');

        try {
            if (await fs.pathExists(sourceInstructionsFile)) {
                if (!(await fs.pathExists(githubDir))) {
                    await fs.ensureDir(githubDir);
                }
                logger.log(chalk.yellow('Installing Copilot instructions to .github/'));
                await fs.copy(sourceInstructionsFile, targetInstructionsFile, { overwrite: true });

                if (await fs.pathExists(targetInstructionsFile)) {
                    logger.log(chalk.green('✓ Copilot instructions installed'));
                } else {
                    logger.warn(chalk.yellow('Warning: Could not verify Copilot instructions file'));
                }
            } else {
                logger.warn(chalk.yellow(`Warning: Copilot instructions source not found at ${sourceInstructionsFile}`));
            }
        } catch (copyError) {
            logger.warn(chalk.yellow(`Warning: Could not install Copilot instructions: ${copyError.message}`));
        }

        // IDE-specific configuration
        if (installedIDEs && installedIDEs.length > 0) {
            for (const ide of installedIDEs) {
                await configureForIDE(ide, projectRoot, config, logger);
            }
        }

        logger.log(chalk.green('✓ Lens installation complete'));
        logger.log(chalk.gray('  Run "@lens /onboard" to get started'));
        return true;
    } catch (error) {
        logger.error(chalk.red(`Error installing Lens: ${error.message}`));
        return false;
    }
}

async function configureForIDE(ide, projectRoot, config, logger) {
    const platformSpecificPath = path.join(__dirname, 'platform-specifics', `${ide}.js`);

    try {
        if (await fs.pathExists(platformSpecificPath)) {
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
