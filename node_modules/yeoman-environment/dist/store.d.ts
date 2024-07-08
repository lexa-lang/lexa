import type { BaseEnvironment, GetGeneratorConstructor, GeneratorMeta, BaseGeneratorMeta } from '@yeoman/types';
/**
 * The Generator store
 * This is used to store generator (npm packages) reference and instantiate them when
 * requested.
 * @constructor
 * @private
 */
export default class Store {
    private readonly env;
    private readonly _meta;
    private readonly _packagesPaths;
    private readonly _packagesNS;
    constructor(env: BaseEnvironment);
    /**
     * Store a module under the namespace key
     * @param meta
     * @param generator - A generator module or a module path
     */
    add<M extends BaseGeneratorMeta>(meta: M, Generator?: unknown): GeneratorMeta & M;
    /**
     * Get the module registered under the given namespace
     * @param  {String} namespace
     * @return {Module}
     */
    get(namespace: string): Promise<GetGeneratorConstructor | undefined>;
    /**
     * Get the module registered under the given namespace
     * @param  {String} namespace
     * @return {Module}
     */
    getMeta(namespace: string): GeneratorMeta | undefined;
    /**
     * Returns the list of registered namespace.
     * @return {Array} Namespaces array
     */
    namespaces(): string[];
    /**
     * Get the stored generators meta data
     * @return {Object} Generators metadata
     */
    getGeneratorsMeta(): Record<string, GeneratorMeta>;
    /**
     * Store a package under the namespace key
     * @param {String}     packageNS - The key under which the generator can be retrieved
     * @param {String}   packagePath - The package path
     */
    addPackage(packageNS: string, packagePath: string): void;
    /**
     * Get the stored packages namespaces with paths.
     * @return {Object} Stored packages namespaces with paths.
     */
    getPackagesPaths(): Record<string, string[]>;
    /**
     * Store a package ns
     * @param {String} packageNS - The key under which the generator can be retrieved
     */
    addPackageNamespace(packageNS: string): void;
    /**
     * Get the stored packages namespaces.
     * @return {Array} Stored packages namespaces.
     */
    getPackagesNS(): string[];
    private getFactory;
    private _getGenerator;
}
