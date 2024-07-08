import type { BaseGeneratorMeta } from '@yeoman/types';
import type YeomanCommand from '../util/command.js';
export declare const printGroupedGenerator: (generators: BaseGeneratorMeta[]) => void;
/**
 * @param {string} generatorNamespace
 * @param {*} options
 * @param {*} command
 * @returns
 */
export declare const environmentAction: (this: YeomanCommand, generatorNamespace: string, options: any, command: any) => Promise<void>;
