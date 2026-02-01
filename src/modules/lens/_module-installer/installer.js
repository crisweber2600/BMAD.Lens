const fs = require('node:fs/promises');
const path = require('node:path');

/**
 * Helper: Check if path exists
 */
async function pathExists(filePath) {
    try {
        await fs.access(filePath);
        return true;
    } catch {
        return false;
    }
}

/**
 * Helper: Ensure directory exists (recursive mkdir)
 */
async function ensureDir(dirPath) {
    await fs.mkdir(dirPath, { recursive: true });
}

/**
 * Helper: Copy file
 */
async function copyFile(src, dest) {
    await fs.copyFile(src, dest);
}

/**
 * Helper: Copy directory recursively
 */
async function copyDirRecursive(src, dest, { overwrite = false, logger, projectRoot, label }) {
    await ensureDir(dest);
    const entries = await fs.readdir(src, { withFileTypes: true });

    for (const entry of entries) {
        const sourcePath = path.join(src, entry.name);
        const destPath = path.join(dest, entry.name);

        if (entry.isDirectory()) {
            await copyDirRecursive(sourcePath, destPath, { overwrite, logger, projectRoot, label });
            continue;
        }

        if (await pathExists(destPath)) {
            if (!overwrite) {
                logger.warn(`${label} already exists, skipping: ${path.relative(projectRoot, destPath)}`);
                continue;
            }

            logger.warn(`Overwriting ${label}: ${path.relative(projectRoot, destPath)}`);
        }

        await copyFile(sourcePath, destPath);
        logger.log(`✓ Installed ${label}: ${path.relative(projectRoot, destPath)}`);
    }
}

/**
 * LENS Module Installer
 */
async function install(options) {
    const { projectRoot, installedIDEs, logger } = options;

    try {
        logger.log('Installing LENS module assets...');

        // Install agents
        const agentsSource = path.join(__dirname, '..', 'agents');
        const agentsDest = path.join(projectRoot, '.github', 'agents');

        if (await pathExists(agentsSource)) {
            await copyDirRecursive(agentsSource, agentsDest, {
                overwrite: false,
                logger,
                projectRoot,
                label: 'agent'
            });
        } else {
            logger.warn('No agents directory found in module. Skipping agent installation.');
        }

        // Install prompts
        const promptsSource = path.join(__dirname, '..', 'prompts');
        const promptsDest = path.join(projectRoot, '.github', 'prompts');

        if (await pathExists(promptsSource)) {
            await copyDirRecursive(promptsSource, promptsDest, {
                overwrite: false,
                logger,
                projectRoot,
                label: 'prompt'
            });
        } else {
            logger.warn('No prompts directory found in module. Skipping prompt installation.');
        }

        await installExtensions({
            projectRoot,
            logger,
            extensions: ['lens-sync', 'lens-compass']
        });

        if (installedIDEs && installedIDEs.length > 0) {
            for (const ide of installedIDEs) {
                await configureForIDE(ide, projectRoot, logger);
            }
        }

        logger.log('✓ LENS module installation complete');
        return true;
    } catch (error) {
        logger.error(`Error installing LENS module: ${error.message}`);
        return false;
    }
}

async function configureForIDE(ide, projectRoot, logger) {
    const platformSpecificPath = path.join(__dirname, 'platform-specifics', `${ide}.js`);

    try {
        if (await pathExists(platformSpecificPath)) {
            const platformHandler = require(platformSpecificPath);
            if (typeof platformHandler.install === 'function') {
                await platformHandler.install({ projectRoot, logger });
            }
        }
    } catch (error) {
        logger.warn(`Warning: Could not configure ${ide}: ${error.message}`);
    }
}

module.exports = { install };

async function installExtensions({ projectRoot, logger, extensions }) {
    for (const extensionName of extensions) {
        await installExtensionAssets({ projectRoot, logger, extensionName });
    }
}

async function installExtensionAssets({ projectRoot, logger, extensionName }) {
    const extensionRoot = path.join(__dirname, '..', 'extensions', extensionName);

    if (!(await pathExists(extensionRoot))) {
        logger.warn(`Extension not found, skipping: ${extensionName}`);
        return;
    }

    logger.log(`Installing ${extensionName} extension assets...`);

    const agentsSource = path.join(extensionRoot, 'agents');
    const agentsDest = path.join(projectRoot, '.github', 'agents');
    if (await pathExists(agentsSource)) {
        await copyDirRecursive(agentsSource, agentsDest, {
            overwrite: true,
            logger,
            projectRoot,
            label: 'extension agent'
        });
    }

    const promptsSource = path.join(extensionRoot, 'prompts');
    const promptsDest = path.join(projectRoot, '.github', 'prompts');
    if (await pathExists(promptsSource)) {
        await copyDirRecursive(promptsSource, promptsDest, {
            overwrite: true,
            logger,
            projectRoot,
            label: 'extension prompt'
        });
    }

    logger.log(`✓ ${extensionName} extension assets installed`);
}
