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
 * LENS Module Installer
 */
async function install(options) {
    const { projectRoot, installedIDEs, logger } = options;

    try {
        logger.log('Installing LENS module assets...');

        const promptsSource = path.join(__dirname, '..', 'prompts');
        const promptsDest = path.join(projectRoot, '.github', 'prompts');

        if (await pathExists(promptsSource)) {
            await ensureDir(promptsDest);
            const entries = await fs.readdir(promptsSource);

            for (const entry of entries) {
                const sourcePath = path.join(promptsSource, entry);
                const destPath = path.join(promptsDest, entry);
                const stat = await fs.stat(sourcePath);

                if (!stat.isFile()) {
                    continue;
                }

                if (await pathExists(destPath)) {
                    logger.warn(`Prompt already exists, skipping: .github/prompts/${entry}`);
                    continue;
                }

                await copyFile(sourcePath, destPath);
                logger.log(`✓ Installed prompt: .github/prompts/${entry}`);
            }
        } else {
            logger.warn('No prompts directory found in module. Skipping prompt installation.');
        }

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
