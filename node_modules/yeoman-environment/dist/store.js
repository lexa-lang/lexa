import { pathToFileURL } from 'node:url';
import { extname, join } from 'node:path';
import { createRequire } from 'node:module';
import { toNamespace } from '@yeoman/namespace';
import createDebug from 'debug';
const debug = createDebug('yeoman:environment:store');
const require = createRequire(import.meta.url);
/**
 * The Generator store
 * This is used to store generator (npm packages) reference and instantiate them when
 * requested.
 * @constructor
 * @private
 */
export default class Store {
    env;
    _meta = {};
    // Store packages paths by ns
    _packagesPaths = {};
    // Store packages ns
    // eslint-disable-next-line @typescript-eslint/naming-convention
    _packagesNS = [];
    constructor(env) {
        this.env = env;
    }
    /**
     * Store a module under the namespace key
     * @param meta
     * @param generator - A generator module or a module path
     */
    add(meta, Generator) {
        if (typeof meta.resolved === 'string') {
            if (extname(meta.resolved)) {
                meta.resolved = join(meta.resolved);
            }
            else {
                try {
                    // Resolve if meta.resolved is a package path.
                    meta.resolved = require.resolve(meta.resolved);
                }
                catch {
                    // Import must be a file, append index.js to directories
                    meta.resolved = join(meta.resolved, 'index.js');
                }
            }
        }
        if (meta.packagePath) {
            meta.packagePath = join(meta.packagePath);
        }
        let importModule;
        if (!Generator) {
            if (!meta.resolved) {
                throw new Error(`Generator Stub or resolved path is required for ${meta.namespace}`);
            }
            importModule = async () => import(pathToFileURL(meta.resolved).href);
        }
        let importPromise;
        const importGenerator = async () => {
            if (importPromise) {
                Generator = await importPromise;
            }
            if (importModule && !Generator) {
                importPromise = importModule();
                Generator = await importPromise;
            }
            const factory = this.getFactory(Generator);
            if (typeof factory === 'function') {
                importPromise = factory(this.env);
                Generator = await importPromise;
            }
            return this._getGenerator(Generator, meta);
        };
        const instantiate = async (args = [], options = {}) => this.env.instantiate(await importGenerator(), { generatorArgs: args, generatorOptions: options });
        const instantiateHelp = async () => instantiate([], { help: true });
        const { packageNamespace } = toNamespace(meta.namespace) ?? {};
        const generatorMeta = {
            ...meta,
            importGenerator,
            importModule,
            instantiate,
            instantiateHelp,
            packageNamespace,
        };
        this._meta[meta.namespace] = generatorMeta;
        if (packageNamespace) {
            this.addPackageNamespace(packageNamespace);
            if (meta.packagePath) {
                this.addPackage(packageNamespace, meta.packagePath);
            }
        }
        return generatorMeta;
    }
    /**
     * Get the module registered under the given namespace
     * @param  {String} namespace
     * @return {Module}
     */
    async get(namespace) {
        return this.getMeta(namespace)?.importGenerator();
    }
    /**
     * Get the module registered under the given namespace
     * @param  {String} namespace
     * @return {Module}
     */
    getMeta(namespace) {
        return this._meta[namespace];
    }
    /**
     * Returns the list of registered namespace.
     * @return {Array} Namespaces array
     */
    namespaces() {
        return Object.keys(this._meta);
    }
    /**
     * Get the stored generators meta data
     * @return {Object} Generators metadata
     */
    getGeneratorsMeta() {
        return this._meta;
    }
    /**
     * Store a package under the namespace key
     * @param {String}     packageNS - The key under which the generator can be retrieved
     * @param {String}   packagePath - The package path
     */
    addPackage(packageNS, packagePath) {
        if (this._packagesPaths[packageNS]) {
            // Yo environment allows overriding, so the last added has preference.
            if (this._packagesPaths[packageNS][0] !== packagePath) {
                const packagePaths = this._packagesPaths[packageNS];
                debug('Overriding a package with namespace %s and path %s, with path %s', packageNS, this._packagesPaths[packageNS][0], packagePath);
                // Remove old packagePath
                const index = packagePaths.indexOf(packagePath);
                if (index > -1) {
                    packagePaths.splice(index, 1);
                }
                packagePaths.splice(0, 0, packagePath);
            }
        }
        else {
            this._packagesPaths[packageNS] = [packagePath];
        }
    }
    /**
     * Get the stored packages namespaces with paths.
     * @return {Object} Stored packages namespaces with paths.
     */
    getPackagesPaths() {
        return this._packagesPaths;
    }
    /**
     * Store a package ns
     * @param {String} packageNS - The key under which the generator can be retrieved
     */
    addPackageNamespace(packageNS) {
        if (!this._packagesNS.includes(packageNS)) {
            this._packagesNS.push(packageNS);
        }
    }
    /**
     * Get the stored packages namespaces.
     * @return {Array} Stored packages namespaces.
     */
    // eslint-disable-next-line @typescript-eslint/naming-convention
    getPackagesNS() {
        return this._packagesNS;
    }
    getFactory(module) {
        // CJS is imported in default, for backward compatibility we support a Generator exported as `module.exports = { default }`
        return module.createGenerator ?? module.default?.createGenerator ?? module.default?.default?.createGenerator;
    }
    _getGenerator(module, meta) {
        // eslint-disable-next-line  @typescript-eslint/naming-convention
        const Generator = module.default?.default ?? module.default ?? module;
        if (typeof Generator !== 'function') {
            throw new TypeError("The generator doesn't provides a constructor.");
        }
        Object.assign(Generator, meta);
        return Generator;
    }
}
