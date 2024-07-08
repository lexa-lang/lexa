import YeomanCommand, { addEnvironmentOptions } from './util/command.js';
import { createEnv } from './index.js';
/**
 * Prepare a commander instance for cli support.
 *
 * @param {Command} command - Command to be prepared
 * @param  generatorPath - Generator to create Command
 * @return {Command} return command
 */
export const prepareGeneratorCommand = async ({ command = addEnvironmentOptions(new YeomanCommand()), resolved, generator, namespace, }) => {
    const env = createEnv();
    let meta;
    if (generator && namespace) {
        meta = env.register(generator, { namespace, resolved });
    }
    else if (resolved) {
        meta = env.register(resolved, { namespace });
    }
    else {
        throw new Error(`A generator with namespace or a generator path is required`);
    }
    command.env = env;
    command.registerGenerator(await meta.instantiateHelp());
    command.action(async function () {
        // eslint-disable-next-line @typescript-eslint/no-this-alias
        let rootCommand = this;
        while (rootCommand.parent) {
            rootCommand = rootCommand.parent;
        }
        const generator = await meta.instantiate(this.args, this.opts());
        await env.runGenerator(generator);
    });
    return command;
};
/**
 * Prepare a commander instance for cli support.
 *
 * @param generatorPaht - Generator to create Command
 * @return Return a Command instance
 */
export const prepareCommand = async (options) => {
    options.command = options.command ?? new YeomanCommand();
    addEnvironmentOptions(options.command);
    return prepareGeneratorCommand(options);
};
