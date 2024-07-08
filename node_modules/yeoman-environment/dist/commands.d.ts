import { type BaseGeneratorConstructor } from '@yeoman/types';
import YeomanCommand from './util/command.js';
export type CommandPreparation = {
    resolved?: string;
    command?: YeomanCommand;
    generator?: BaseGeneratorConstructor;
    namespace?: string;
};
/**
 * Prepare a commander instance for cli support.
 *
 * @param {Command} command - Command to be prepared
 * @param  generatorPath - Generator to create Command
 * @return {Command} return command
 */
export declare const prepareGeneratorCommand: ({ command, resolved, generator, namespace, }: CommandPreparation) => Promise<YeomanCommand>;
/**
 * Prepare a commander instance for cli support.
 *
 * @param generatorPaht - Generator to create Command
 * @return Return a Command instance
 */
export declare const prepareCommand: (options: CommandPreparation) => Promise<YeomanCommand>;
