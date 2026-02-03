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

    try {
        logger.log('Installing LENS Workbench (lens-work)...');

        // Create lens-work output directory
        const outputDir = path.join(projectRoot, '_bmad-output', 'lens-work');
        if (!(await pathExists(outputDir))) {
            logger.log(`Creating output directory: _bmad-output/lens-work/`);
            await ensureDir(outputDir);
        }

        // Create subdirectories
        const subdirs = ['dashboards', 'archive', 'snapshots', 'profiles'];
        for (const subdir of subdirs) {
            const subdirPath = path.join(outputDir, subdir);
            if (!(await pathExists(subdirPath))) {
                await ensureDir(subdirPath);
            }
        }

        // Create Docs output directory if specified
        const docsPath = config?.docs_output_path || 'Docs';
        const cleanDocsPath = docsPath.replace('{project-root}/', '');
        const docsDir = path.join(projectRoot, cleanDocsPath);
        if (!(await pathExists(docsDir))) {
            logger.log(`Creating docs directory: ${cleanDocsPath}/`);
            await ensureDir(docsDir);
        }

        // Create lens-work config file
        const configDir = path.join(projectRoot, '_bmad', 'lens-work');
        await ensureDir(configDir);

        const configFile = path.join(configDir, 'config.yaml');
        if (!(await pathExists(configFile))) {
            const configContent = `# LENS Workbench Configuration
# Generated during installation
# Date: ${new Date().toISOString()}

# TargetProjects path (where repos are cloned)
target_projects_path: "${config?.target_projects_path || '../TargetProjects'}"

# Docs output path
docs_output_path: "${config?.docs_output_path || 'Docs'}"

# Telemetry settings
telemetry:
  enabled: ${config?.enable_telemetry !== false}
  dashboard_format: json  # json, html

# Git settings
git:
  default_remote: ${config?.default_git_remote || 'github'}
  fetch_strategy: background
  fetch_ttl: 60

# Role gating (advisory by default)
role_gating:
  enabled: true
  mode: advisory  # advisory, enforced
`;
            logger.log('Creating lens-work config file');
            await fs.writeFile(configFile, configContent, 'utf8');
        }

        // Initialize empty state file
        const stateFile = path.join(outputDir, 'state.yaml');
        if (!(await pathExists(stateFile))) {
            const stateContent = `# LENS Workbench State
# Auto-managed by lens-work - do not edit manually

version: 1
active_initiative: null
`;
            await fs.writeFile(stateFile, stateContent, 'utf8');
        }

        // Initialize empty event log
        const eventLog = path.join(outputDir, 'event-log.jsonl');
        if (!(await pathExists(eventLog))) {
            await fs.writeFile(eventLog, '', 'utf8');
        }

        // IDE-specific configuration
        if (installedIDEs && installedIDEs.length > 0) {
            for (const ide of installedIDEs) {
                await configureForIDE(ide, projectRoot, config, logger);
            }
        }

        logger.log('✓ LENS Workbench installation complete');
        logger.log('  Run "lens-work.onboard" prompt to get started');
        return true;
    } catch (error) {
        logger.error(`Error installing lens-work: ${error.message}`);
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
        logger.warn(`Warning: Could not configure ${ide}: ${error.message}`);
    }
}

module.exports = { install };
