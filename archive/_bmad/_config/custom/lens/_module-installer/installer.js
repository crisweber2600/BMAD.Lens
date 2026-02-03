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

        const fileExists = await pathExists(destPath);

        if (fileExists && !overwrite) {
            logger.warn(`${label} already exists, skipping: ${path.relative(projectRoot, destPath)}`);
            continue;
        }

        await copyFile(sourcePath, destPath);

        if (fileExists) {
            logger.log(`✓ Updated ${label}: ${path.relative(projectRoot, destPath)}`);
        } else {
            logger.log(`✓ Installed ${label}: ${path.relative(projectRoot, destPath)}`);
        }
    }
}

/**
 * LENS Module Installer
 */
async function install(options) {
    const { projectRoot, installedIDEs, logger } = options;

    try {
        logger.log('Installing LENS module assets...');

        const bmadRoot = path.join(projectRoot, '_bmad');
        const lensRoot = path.join(bmadRoot, 'lens');
        const memoryRoot = path.join(bmadRoot, '_memory');

        // Ensure base directories exist
        await ensureDir(lensRoot);
        await ensureDir(memoryRoot);

        // Install agents to _bmad/lens/agents
        const agentsSource = path.join(__dirname, '..', 'agents');
        const agentsDest = path.join(lensRoot, 'agents');

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

        // Install prompts to .github/prompts (for GitHub Copilot)
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

        // Install module config files
        const configFiles = ['module-config.yaml', 'module.yaml', 'config.yaml'];
        for (const configFile of configFiles) {
            const configSource = path.join(__dirname, '..', configFile);
            if (await pathExists(configSource)) {
                const configDest = path.join(lensRoot, configFile);
                await copyFile(configSource, configDest);
                logger.log(`✓ Installed config: ${path.relative(projectRoot, configDest)}`);
            }
        }

        // Install extensions
        await installExtensions({
            projectRoot,
            logger,
            bmadRoot,
            lensRoot,
            memoryRoot,
            installedIDEs: installedIDEs || []
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

async function installExtensions({ projectRoot, logger, bmadRoot, lensRoot, memoryRoot, installedIDEs }) {
    const extensionsDir = path.join(__dirname, '..', 'extensions');

    if (!(await pathExists(extensionsDir))) {
        logger.log('No extensions directory found. Skipping extension installation.');
        return;
    }

    // Discover all extensions
    const entries = await fs.readdir(extensionsDir, { withFileTypes: true });
    const extensions = entries.filter(e => e.isDirectory()).map(e => e.name);

    if (extensions.length === 0) {
        logger.log('No extensions found in extensions directory.');
        return;
    }

    for (const extensionName of extensions) {
        await installExtension({
            projectRoot,
            logger,
            bmadRoot,
            lensRoot,
            memoryRoot,
            extensionName,
            installedIDEs: installedIDEs || []
        });
    }
}

async function installExtension({ projectRoot, logger, bmadRoot, lensRoot, memoryRoot, extensionName, installedIDEs }) {
    const extensionRoot = path.join(__dirname, '..', 'extensions', extensionName);

    if (!(await pathExists(extensionRoot))) {
        logger.warn(`Extension not found, skipping: ${extensionName}`);
        return;
    }

    logger.log(`Installing ${extensionName} extension...`);

    // Create extension directory in _bmad/lens/extensions
    const extensionDest = path.join(lensRoot, 'extensions', extensionName);
    await ensureDir(extensionDest);

    // Install extension agents to _bmad/lens/agents (merge with core)
    const agentsSource = path.join(extensionRoot, 'agents');
    const agentsDest = path.join(lensRoot, 'agents');
    if (await pathExists(agentsSource)) {
        const agentEntries = await fs.readdir(agentsSource, { withFileTypes: true });

        for (const entry of agentEntries) {
            const sourcePath = path.join(agentsSource, entry.name);
            const destPath = path.join(agentsDest, entry.name);

            if (entry.isDirectory()) {
                // Check if this is a _memory directory
                if (entry.name.endsWith('-sidecar') || entry.name === '_memory') {
                    // Install sidecar memory to _bmad/_memory
                    const sidecarName = entry.name.replace('_memory', '').replace(/\/$/, '');
                    const memoryDest = path.join(memoryRoot, sidecarName || entry.name);

                    await copyDirRecursive(sourcePath, memoryDest, {
                        overwrite: false,
                        logger,
                        projectRoot,
                        label: `extension sidecar (${extensionName})`
                    });
                } else {
                    // Regular agent directory
                    await copyDirRecursive(sourcePath, destPath, {
                        overwrite: false,
                        logger,
                        projectRoot,
                        label: `extension agent (${extensionName})`
                    });
                }
            } else {
                // Agent file (.yaml, .md, etc)
                await ensureDir(agentsDest);

                // Check if file exists before copying
                if (await pathExists(destPath)) {
                    logger.warn(`extension agent (${extensionName}) already exists, skipping: ${path.relative(projectRoot, destPath)}`);
                } else {
                    await copyFile(sourcePath, destPath);
                    logger.log(`✓ Installed extension agent (${extensionName}): ${path.relative(projectRoot, destPath)}`);
                }
            }
        }
    }

    // Install extension workflows to _bmad/lens/extensions/{name}/workflows
    const workflowsSource = path.join(extensionRoot, 'workflows');
    const workflowsDest = path.join(extensionDest, 'workflows');
    if (await pathExists(workflowsSource)) {
        await copyDirRecursive(workflowsSource, workflowsDest, {
            overwrite: false,
            logger,
            projectRoot,
            label: `extension workflow (${extensionName})`
        });
    }

    // Install extension prompts to .github/prompts (for GitHub Copilot)
    const promptsSource = path.join(extensionRoot, 'prompts');
    const promptsDest = path.join(projectRoot, '.github', 'prompts');
    if (await pathExists(promptsSource)) {
        await copyDirRecursive(promptsSource, promptsDest, {
            overwrite: false,
            logger,
            projectRoot,
            label: `extension prompt (${extensionName})`
        });
    }

    // Install extension hooks
    const hooksSource = path.join(extensionRoot, 'hooks');
    const hooksDest = path.join(extensionDest, 'hooks');
    if (await pathExists(hooksSource)) {
        await copyDirRecursive(hooksSource, hooksDest, {
            overwrite: false,
            logger,
            projectRoot,
            label: `extension hook (${extensionName})`
        });
    }

    // Install extension docs
    const docsSource = path.join(extensionRoot, 'docs');
    const docsDest = path.join(extensionDest, 'docs');
    if (await pathExists(docsSource)) {
        await copyDirRecursive(docsSource, docsDest, {
            overwrite: false,
            logger,
            projectRoot,
            label: `extension doc (${extensionName})`
        });
    }

    // Copy module config files
    const configFiles = ['module.yaml', 'README.md', 'TODO.md'];
    for (const configFile of configFiles) {
        const configSource = path.join(extensionRoot, configFile);
        if (await pathExists(configSource)) {
            const configDest = path.join(extensionDest, configFile);
            await copyFile(configSource, configDest);
        }
    }

    // Run extension-specific installer if it exists
    const extensionInstaller = path.join(extensionRoot, '_module-installer', 'installer.js');
    if (await pathExists(extensionInstaller)) {
        try {
            const extInstaller = require(extensionInstaller);
            if (typeof extInstaller.install === 'function') {
                // Pass minimal config - extension installers should be self-contained
                const config = {
                    output_folder: '_bmad-output',
                    state_folder: path.join('_bmad-output', extensionName),
                    project_root: projectRoot
                };

                await extInstaller.install({
                    projectRoot,
                    config,
                    installedIDEs: installedIDEs || [],
                    logger
                });
            }
        } catch (error) {
            logger.warn(`Warning: Extension installer failed for ${extensionName}: ${error.message}`);
        }
    }

    logger.log(`✓ ${extensionName} extension installed`);
}

async function installExtensionAssets({ projectRoot, logger, extensionName }) {
    // Deprecated: kept for backward compatibility
    // Extensions are now installed via installExtension()
    logger.warn(`installExtensionAssets is deprecated, use installExtension instead`);
}
