export type ModuleLookupOptions = {
    /** Set true to skip lookups of globally-installed generators */
    localOnly?: boolean;
    /** Paths to look for generators */
    packagePaths?: string[];
    /** Repository paths to look for generators packages */
    npmPaths?: string[];
    /** File pattern to look for */
    filePatterns?: string[];
    /** The package patterns to look for */
    packagePatterns?: string[];
    /** A value indicating whether the lookup should be stopped after finding the first result */
    singleResult?: boolean;
    filterPaths?: boolean;
    /** Set true reverse npmPaths/packagePaths order */
    reverse?: boolean;
    /** The `deep` option to pass to `globby` */
    globbyDeep?: number;
    globbyOptions?: any;
};
/**
 * Search for npm packages.
 */
export declare function moduleLookupSync(options: ModuleLookupOptions, find: (arg: {
    files: string[];
    packagePath: string;
}) => string | undefined): {
    filePath: string;
    packagePath: string;
}[];
/**
 * Search npm for every available generators.
 * Generators are npm packages who's name start with `generator-` and who're placed in the
 * top level `node_module` path. They can be installed globally or locally.
 *
 * @method
 *
 * @param searchPaths List of search paths
 * @param packagePatterns Pattern of the packages
 * @param globbyOptions
 * @return List of the generator modules path
 */
export declare function findPackagesIn(searchPaths: string[], packagePatterns: string[], globbyOptions?: any): any[];
/**
 * Get the npm lookup directories (`node_modules/`)
 *
 * @method
 *
 * @param {boolean|Object} [options]
 * @param {boolean} [options.localOnly = false] - Set true to skip lookups of
 *                                               globally-installed generators.
 * @param {boolean} [options.filterPaths = false] - Remove paths that don't ends
 *                       with a supported path (don't touch at NODE_PATH paths).
 * @return {Array} lookup paths
 */
export declare function getNpmPaths(options?: {
    localOnly?: boolean;
    filterPaths?: boolean;
}): string[];
