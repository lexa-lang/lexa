/**
 * Resolve a module path
 * @param  specifier - Filepath or module name
 * @return           - The resolved path leading to the module
 */
export declare function resolveModulePath(specifier: string, resolvedOrigin?: string): Promise<string | undefined>;
