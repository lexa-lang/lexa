import { Command, Option } from 'commander';
import type BaseEnvironment from '../environment-base.js';
export default class YeomanCommand extends Command {
    env?: BaseEnvironment;
    createCommand(name?: string): YeomanCommand;
    /**
     * Override addOption to register a negative alternative for every option.
     * @param {Option} option
     * @return {YeomanCommand} this;
     */
    addOption(option: Option): this;
    /**
     * Load Generator options into a commander instance.
     *
     * @param {Generator} generator - Generator
     * @return {Command} return command
     */
    registerGenerator(generator: any): this;
    /**
     * Register arguments using generator._arguments structure.
     * @param {object[]} generatorArgs
     * @return {YeomanCommand} this;
     */
    addGeneratorArguments(generatorArgs?: any[]): this;
    /**
     * Register options using generator._options structure.
     * @param {object} options
     * @param {string} blueprintOptionDescription - description of the blueprint that adds the option
     * @return {YeomanCommand} this;
     */
    addGeneratorOptions(options: Record<string, any>): this;
    _addGeneratorOption(optionName: string, optionDefinition: any, additionalDescription?: string): any;
}
export declare const addEnvironmentOptions: (command?: YeomanCommand) => YeomanCommand;
