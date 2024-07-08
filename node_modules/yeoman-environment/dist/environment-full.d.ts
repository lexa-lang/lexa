import type { BaseGeneratorConstructor } from '@yeoman/types';
import { type LookupOptions } from './generator-lookup.js';
import EnvironmentBase, { type EnvironmentOptions } from './environment-base.js';
declare class FullEnvironment extends EnvironmentBase {
    constructor(options?: EnvironmentOptions);
    /**
     * Load options passed to the Generator that should be used by the Environment.
     *
     * @param {Object} options
     */
    loadEnvironmentOptions(options: EnvironmentOptions): Pick<EnvironmentOptions, "skipInstall" | "nodePackageManager">;
    /**
     * Load options passed to the Environment that should be forwarded to the Generator.
     *
     * @param {Object} options
     */
    loadSharedOptions(options: EnvironmentOptions): Pick<EnvironmentOptions, "skipInstall" | "forceInstall" | "skipCache" | "skipLocalCache" | "skipParseOptions" | "localConfigOnly" | "askAnswered">;
    /**
     * @protected
     * Outputs the general help and usage. Optionally, if generators have been
     * registered, the list of available generators is also displayed.
     *
     * @param {String} name
     */
    help(name?: string): string;
    /**
     * @protected
     * Returns the list of registered namespace.
     * @return {Array}
     */
    namespaces(): string[];
    /**
     * @protected
     * Returns stored generators meta
     * @return {Object}
     */
    getGeneratorsMeta(): Record<string, import("@yeoman/types").GeneratorMeta>;
    /**
     * @protected
     * Get registered generators names
     *
     * @return {Array}
     */
    getGeneratorNames(): (string | undefined)[];
    /**
     * Get last added path for a namespace
     *
     * @param  {String} - namespace
     * @return {String} - path of the package
     */
    getPackagePath(namespace: string): string | undefined;
    /**
     * Get paths for a namespace
     *
     * @param - namespace
     * @return array of paths.
     */
    getPackagePaths(namespace: string): string[];
    /**
     * Generate a command for the generator and execute.
     *
     * @param {string} generatorNamespace
     * @param {string[]} args
     */
    execute(generatorNamespace: string, args?: never[]): Promise<void>;
    requireGenerator(namespace: string): Promise<BaseGeneratorConstructor | undefined>;
    /**
     * Install generators at the custom local repository and register.
     *
     * @param  {Object} packages - packages to install key(packageName): value(versionRange).
     * @return  {Boolean} - true if the install succeeded.
     */
    installLocalGenerators(packages: Record<string, string | undefined>): Promise<boolean>;
    /**
     * Lookup and register generators from the custom local repository.
     *
     * @param  {String[]} [packagesToLookup='generator-*'] - packages to lookup.
     */
    lookupLocalPackages(packagesToLookup?: string[]): Promise<void>;
    /**
     * Lookup and register generators from the custom local repository.
     *
     * @private
     * @param  {YeomanNamespace[]} namespacesToLookup - namespaces to lookup.
     * @return {Promise<Object[]>} List of generators
     */
    lookupLocalNamespaces(namespacesToLookup: string | string[]): Promise<void | never[]>;
    /**
     * Search for generators or sub generators by namespace.
     *
     * @private
     * @param {boolean|Object} [options] options passed to lookup. Options singleResult,
     *                                   filePatterns and packagePatterns can be overridden
     * @return {Array|Object} List of generators
     */
    lookupNamespaces(namespaces: string | string[], options?: LookupOptions): Promise<import("@yeoman/types").LookupGeneratorMeta[][]>;
    /**
     * Load or install namespaces based on the namespace flag
     *
     * @private
     * @param  {String|Array} - namespaces
     * @return  {boolean} - true if every required namespace was found.
     */
    prepareEnvironment(namespaces: string | string[]): Promise<boolean>;
    /**
     * Tries to locate and run a specific generator. The lookup is done depending
     * on the provided arguments, options and the list of registered generators.
     *
     * When the environment was unable to resolve a generator, an error is raised.
     *
     * @param {String|Array} args
     * @param {Object}       [options]
     */
    run(args?: string[], options?: any): Promise<void>;
}
export default FullEnvironment;
