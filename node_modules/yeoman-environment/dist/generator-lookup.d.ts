import { type LookupOptions as LookupOptionsApi } from '@yeoman/types';
import { type ModuleLookupOptions } from './module-lookup.js';
export type LookupOptions = LookupOptionsApi & ModuleLookupOptions & {
    lookups?: string[];
};
type LookupMeta = {
    filePath: string;
    packagePath: string;
    lookups: string[];
};
export declare const defaultExtensions: string[];
/**
 * Search for generators and their sub generators.
 *
 * A generator is a `:lookup/:name/index.js` file placed inside an npm package.
 *
 * Defaults lookups are:
 *   - ./
 *   - generators/
 *   - lib/generators/
 *
 * So this index file `node_modules/generator-dummy/lib/generators/yo/index.js` would be
 * registered as `dummy:yo` generator.
 *
 * @param {boolean|Object} [options]
 * @param {boolean} [options.localOnly = false] - Set true to skip lookups of
 *                                               globally-installed generators.
 * @param {string|Array} [options.packagePaths] - Paths to look for generators.
 * @param {string|Array} [options.npmPaths] - Repository paths to look for generators packages.
 * @param {string|Array} [options.filePatterns='*\/index.js'] - File pattern to look for.
 * @param {string|Array} [options.packagePatterns='generator-*'] - Package pattern to look for.
 * @param {boolean}      [options.singleResult=false] - Set true to stop lookup on the first match.
 * @param {Number}       [options.globbyDeep] - Deep option to be passed to globby.
 * @return {Promise<Object[]>} List of generators
 */
export declare function lookupGenerators(options?: LookupOptions, register?: (meta: LookupMeta) => boolean): Promise<{
    filePath: string;
    packagePath: string;
}[]>;
/**
 * Lookup for a specific generator.
 *
 * @param  {String} namespace
 * @param  {Object} [options]
 * @param {Boolean} [options.localOnly=false] - Set true to skip lookups of
 *                                                     globally-installed generators.
 * @param {Boolean} [options.packagePath=false] - Set true to return the package
 *                                                       path instead of generators file.
 * @param {Boolean} [options.singleResult=true] - Set false to return multiple values.
 * @return {String} generator
 */
export declare function lookupGenerator(namespace: string, options?: ModuleLookupOptions & {
    packagePath?: boolean;
    generatorPath?: boolean;
}): string | string[];
export {};
