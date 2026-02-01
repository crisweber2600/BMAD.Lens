const chalk = require('chalk');

async function install(options) {
    const { logger } = options;
    logger.log(chalk.dim('  Git-Lens: no Cursor specific setup required.'));
    return true;
}

module.exports = { install };
