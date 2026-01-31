const fs = require('fs-extra');
const path = require('node:path');
const chalk = require('chalk');
const platformCodes = require(path.join(__dirname, '../../../../../../tools/cli/lib/platform-codes'));

/**
 * LENS Sync & Discovery Module Installer
 */
async function install(options) {
    const { projectRoot, config, installedIDEs, logger } = options;

    try {
        logger.log(chalk.blue('Installing LENS Sync & Discovery module assets...'));

        // Create docs output directory (from module.yaml)
        if (config.docs_output_folder) {
            const docsPath = path.isAbsolute(config.docs_output_folder)
                ? config.docs_output_folder
                : path.join(projectRoot, config.docs_output_folder);

            if (!(await fs.pathExists(docsPath))) {
                logger.log(chalk.yellow(`Creating docs output folder: ${docsPath}`));
                await fs.ensureDir(docsPath);
            }
        }

        // Install prompts (similar to LENS)
        const promptsSource = path.join(__dirname, '..', 'prompts');
        const promptsDest = path.join(projectRoot, '.github', 'prompts');

        if (await fs.pathExists(promptsSource)) {
            await fs.ensureDir(promptsDest);
            const entries = await fs.readdir(promptsSource);

            for (const entry of entries) {
                const sourcePath = path.join(promptsSource, entry);
                const destPath = path.join(promptsDest, entry);
                const stat = await fs.stat(sourcePath);

                if (!stat.isFile()) {
                    continue;
                }

                if (await fs.pathExists(destPath)) {
                    logger.warn(chalk.yellow(`Prompt already exists, skipping: .github/prompts/${entry}`));
                    continue;
                }

                await fs.copy(sourcePath, destPath);
                logger.log(chalk.green(`✓ Installed prompt: .github/prompts/${entry}`));
            }
        } else {
            logger.warn(chalk.yellow('No prompts directory found in module. Skipping prompt installation.'));
        }

        if (installedIDEs && installedIDEs.length > 0) {
            for (const ide of installedIDEs) {
                await configureForIDE(ide, projectRoot, config, logger);
            }
        }

        logger.log(chalk.green('✓ LENS Sync & Discovery installation complete'));
        return true;
    } catch (error) {
        logger.error(chalk.red(`Error installing module: ${error.message}`));
        return false;
    }
}

async function configureForIDE(ide, projectRoot, config, logger) {
    if (!platformCodes.isValidPlatform(ide)) {
        logger.warn(chalk.yellow(`Unknown platform: '${ide}'. Skipping.`));
        return;
    }

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
