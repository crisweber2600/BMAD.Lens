const fs = require('node:fs/promises');
const path = require('node:path');
const chalk = require('chalk');

const supportedIDEs = new Set(['claude-code', 'windsurf', 'cursor']);

async function pathExists(filePath) {
    try {
        await fs.access(filePath);
        return true;
    } catch {
        return false;
    }
}

async function ensureDir(dirPath) {
    await fs.mkdir(dirPath, { recursive: true });
}

function resolvePath(projectRoot, configuredPath, outputFolder) {
    if (!configuredPath) {
        return null;
    }

    let expanded = configuredPath;
    if (outputFolder) {
        expanded = expanded.replace(/\{output_folder\}/g, outputFolder);
    }
    expanded = expanded.replace(/\{project-root\}/g, projectRoot);
    if (expanded.match(/\{[^}]+\}/)) {
        throw new Error(`Unresolved placeholder in path: ${expanded}`);
    }
    return path.isAbsolute(expanded) ? expanded : path.join(projectRoot, expanded);
}

/**
 * Git-Lens Module Installer
 */
async function install(options) {
    const { projectRoot, config, installedIDEs, logger } = options;

    try {
        logger.log(chalk.blue('Installing Git-Lens extension assets...'));

        const stateFolder = resolvePath(projectRoot, config.state_folder, config.output_folder);
        if (stateFolder) {
            if (!(await pathExists(stateFolder))) {
                await ensureDir(stateFolder);
                logger.log(chalk.yellow(`✓ Created state folder: ${stateFolder}`));
            }
        }

        const testDataFolder = path.join(projectRoot, '_bmad', 'lens', 'extensions', 'git-lens', 'test-data');
        if (!(await pathExists(testDataFolder))) {
            await ensureDir(testDataFolder);
            logger.log(chalk.yellow('✓ Created git-lens test-data folder'));
        }

        if (installedIDEs && installedIDEs.length > 0) {
            for (const ide of installedIDEs) {
                await configureForIDE(ide, projectRoot, config, logger);
            }
        }

        logger.log(chalk.green('✓ Git-Lens extension installation complete'));
        return true;
    } catch (error) {
        logger.error(chalk.red(`Error installing Git-Lens extension: ${error.message}`));
        return false;
    }
}

async function configureForIDE(ide, projectRoot, config, logger) {
    if (!ide || typeof ide !== 'string') {
        logger.warn(chalk.yellow('Warning: Invalid IDE identifier. Skipping.'));
        return;
    }

    if (!supportedIDEs.has(ide)) {
        logger.warn(chalk.yellow(`Warning: Unknown platform '${ide}'. Skipping.`));
        return;
    }

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
