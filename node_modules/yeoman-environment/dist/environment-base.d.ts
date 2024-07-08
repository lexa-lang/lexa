/// <reference types="node" resolution-mode="require"/>
import EventEmitter from 'node:events';
import { QueuedAdapter, type TerminalAdapterOptions } from '@yeoman/adapter';
import type { ApplyTransformsOptions, BaseEnvironment, BaseEnvironmentOptions, BaseGenerator, BaseGeneratorConstructor, BaseGeneratorMeta, ComposeOptions, GeneratorMeta, GetGeneratorConstructor, InputOutputAdapter, InstantiateOptions, LookupGeneratorMeta } from '@yeoman/types';
import { type Store as MemFs } from 'mem-fs';
import { type MemFsEditorFile } from 'mem-fs-editor';
import { FlyRepository } from 'fly-import';
import GroupedQueue from 'grouped-queue';
import { type FilePipelineTransform } from '@yeoman/transform';
import { type YeomanNamespace } from '@yeoman/namespace';
import { type ConflicterOptions } from '@yeoman/conflicter';
import { ComposedStore } from './composed-store.js';
import Store from './store.js';
import type YeomanCommand from './util/command.js';
import { type LookupOptions } from './generator-lookup.js';
export type EnvironmentLookupOptions = LookupOptions & {
    /** Add a scope to the namespace if there is no scope */
    registerToScope?: string;
    /** Customize the namespace to be registered */
    customizeNamespace?: (ns?: string) => string | undefined;
};
export type EnvironmentOptions = BaseEnvironmentOptions & Omit<TerminalAdapterOptions, 'promptModule'> & {
    adapter?: InputOutputAdapter;
    logCwd?: string;
    command?: YeomanCommand;
    yeomanRepository?: string;
    arboristRegistry?: string;
    nodePackageManager?: string;
};
/**
 * Copy and remove null and undefined values
 * @param object
 * @returns
 */
export declare function removePropertiesWithNullishValues(object: Record<string, any>): Record<string, any>;
export default class EnvironmentBase extends EventEmitter implements BaseEnvironment {
    cwd: string;
    logCwd: string;
    adapter: QueuedAdapter;
    sharedFs: MemFs<MemFsEditorFile>;
    conflicterOptions?: ConflicterOptions;
    protected readonly options: EnvironmentOptions;
    protected readonly aliases: Array<{
        match: RegExp;
        value: string;
    }>;
    protected store: Store;
    protected command?: YeomanCommand;
    protected runLoop: GroupedQueue;
    protected composedStore: ComposedStore;
    protected lookups: string[];
    protected sharedOptions: Record<string, any>;
    protected repository: FlyRepository;
    protected experimental: boolean;
    protected _rootGenerator?: BaseGenerator;
    protected compatibilityMode?: false | 'v4';
    constructor(options?: EnvironmentOptions);
    findFeature(featureName: string): Array<{
        generatorId: string;
        feature: any;
    }>;
    applyTransforms(transformStreams: FilePipelineTransform[], options?: ApplyTransformsOptions): Promise<void>;
    /**
     * @param   namespaceOrPath
     * @return the generator meta registered under the namespace
     */
    findMeta(namespaceOrPath: string | YeomanNamespace): Promise<GeneratorMeta | undefined>;
    /**
     * Get a single generator from the registered list of generators. The lookup is
     * based on generator's namespace, "walking up" the namespaces until a matching
     * is found. Eg. if an `angular:common` namespace is registered, and we try to
     * get `angular:common:all` then we get `angular:common` as a fallback (unless
     * an `angular:common:all` generator is registered).
     *
     * @param   namespaceOrPath
     * @return the generator registered under the namespace
     */
    get<C extends BaseGeneratorConstructor = BaseGeneratorConstructor>(namespaceOrPath: string | YeomanNamespace): Promise<C | undefined>;
    /**
     * Create is the Generator factory. It takes a namespace to lookup and optional
     * hash of options, that lets you define `arguments` and `options` to
     * instantiate the generator with.
     *
     * An error is raised on invalid namespace.
     *
     * @param namespaceOrPath
     * @param instantiateOptions
     * @return The instantiated generator
     */
    create<G extends BaseGenerator = BaseGenerator>(namespaceOrPath: string | GetGeneratorConstructor<G>, instantiateOptions?: InstantiateOptions<G>): Promise<G>;
    /**
     * Instantiate a Generator with metadatas
     *
     * @param  generator   Generator class
     * @param instantiateOptions
     * @return The instantiated generator
     */
    instantiate<G extends BaseGenerator = BaseGenerator>(generator: GetGeneratorConstructor<G>, instantiateOptions?: InstantiateOptions<G>): Promise<G>;
    /**
     * @protected
     * Compose with the generator.
     *
     * @param {String} namespaceOrPath
     * @return {Generator} The instantiated generator or the singleton instance.
     */
    composeWith<G extends BaseGenerator = BaseGenerator>(generator: string | GetGeneratorConstructor<G>, composeOptions?: ComposeOptions<G>): Promise<G>;
    /**
     * Given a String `filepath`, tries to figure out the relative namespace.
     *
     * ### Examples:
     *
     *     this.namespace('backbone/all/index.js');
     *     // => backbone:all
     *
     *     this.namespace('generator-backbone/model');
     *     // => backbone:model
     *
     *     this.namespace('backbone.js');
     *     // => backbone
     *
     *     this.namespace('generator-mocha/backbone/model/index.js');
     *     // => mocha:backbone:model
     *
     * @param {String} filepath
     * @param {Array} lookups paths
     */
    namespace(filepath: string, lookups?: string[]): string;
    /**
     * Returns the environment or dependency version.
     * @param  {String} packageName - Module to get version.
     * @return {String} Environment version.
     */
    getVersion(): string;
    getVersion(dependency: string): string | undefined;
    /**
     * Queue generator run (queue itself tasks).
     *
     * @param {Generator} generator Generator instance
     * @param {boolean} [schedule=false] Whether to schedule the generator run.
     * @return {Generator} The generator or singleton instance.
     */
    queueGenerator<G extends BaseGenerator = BaseGenerator>(generator: G, queueOptions?: {
        schedule?: boolean;
    }): Promise<G>;
    /**
     * Get the first generator that was queued to run in this environment.
     *
     * @return {Generator} generator queued to run in this environment.
     */
    rootGenerator<G extends BaseGenerator = BaseGenerator>(): G;
    runGenerator(generator: BaseGenerator): Promise<void>;
    /**
     * Registers a specific `generator` to this environment. This generator is stored under
     * provided namespace, or a default namespace format if none if available.
     *
     * @param  name      - Filepath to the a generator or a npm package name
     * @param  namespace - Namespace under which register the generator (optional)
     * @param  packagePath - PackagePath to the generator npm package (optional)
     * @return environment - This environment
     */
    register(filePath: string, meta?: Partial<BaseGeneratorMeta> | undefined): GeneratorMeta;
    register(generator: unknown, meta: BaseGeneratorMeta): GeneratorMeta;
    /**
     * Queue tasks
     * @param {string} priority
     * @param {(...args: any[]) => void | Promise<void>} task
     * @param {{ once?: string, startQueue?: boolean }} [options]
     */
    queueTask(priority: string, task: () => void | Promise<void>, options?: {
        once?: string | undefined;
        startQueue?: boolean | undefined;
    } | undefined): void;
    /**
     * Add priority
     * @param {string} priority
     * @param {string} [before]
     */
    addPriority(priority: string, before?: string | undefined): void;
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
     */
    lookup(options?: EnvironmentLookupOptions): Promise<LookupGeneratorMeta[]>;
    /**
     * Verify if a package namespace already have been registered.
     *
     * @param  packageNS - namespace of the package.
     * @return true if any generator of the package has been registered
     */
    isPackageRegistered(packageNamespace: string): boolean;
    /**
     * Get all registered packages namespaces.
     *
     * @return array of namespaces.
     */
    getRegisteredPackages(): string[];
    /**
     * Returns stored generators meta
     * @param namespace
     */
    getGeneratorMeta(namespace: string): GeneratorMeta | undefined;
    /**
     * Get or create an alias.
     *
     * Alias allows the `get()` and `lookup()` methods to search in alternate
     * filepath for a given namespaces. It's used for example to map `generator-*`
     * npm package to their namespace equivalent (without the generator- prefix),
     * or to default a single namespace like `angular` to `angular:app` or
     * `angular:all`.
     *
     * Given a single argument, this method acts as a getter. When both name and
     * value are provided, acts as a setter and registers that new alias.
     *
     * If multiple alias are defined, then the replacement is recursive, replacing
     * each alias in reverse order.
     *
     * An alias can be a single String or a Regular Expression. The finding is done
     * based on .match().
     *
     * @param {String|RegExp} match
     * @param {String} value
     *
     * @example
     *
     *     env.alias(/^([a-zA-Z0-9:\*]+)$/, 'generator-$1');
     *     env.alias(/^([^:]+)$/, '$1:app');
     *     env.alias(/^([^:]+)$/, '$1:all');
     *     env.alias('foo');
     *     // => generator-foo:all
     */
    alias(match: string | RegExp, value: string): this;
    alias(value: string): string;
    /**
     * Watch for package.json and queue package manager install task.
     */
    watchForPackageManagerInstall({ cwd, queueTask, installTask, }?: {
        cwd?: string;
        queueTask?: boolean;
        installTask?: (nodePackageManager: string | undefined, defaultTask: () => Promise<boolean>) => void | Promise<void>;
    }): void;
    /**
     * Start Environment queue
     * @param {Object} options - Conflicter options.
     */
    protected start(options: any): Promise<void>;
    /**
     * Queue environment's commit task.
     */
    protected queueCommit(): void;
    /**
     * Registers a specific `generator` to this environment. This generator is stored under
     * provided namespace, or a default namespace format if none if available.
     *
     * @param   name      - Filepath to the a generator or a npm package name
     * @param   namespace - Namespace under which register the generator (optional)
     * @param   packagePath - PackagePath to the generator npm package (optional)
     * @return  environment - This environment
     */
    protected registerGeneratorPath(generatorPath: string, namespace?: string, packagePath?: string): GeneratorMeta;
    /**
     * Register a stubbed generator to this environment. This method allow to register raw
     * functions under the provided namespace. `registerStub` will enforce the function passed
     * to extend the Base generator automatically.
     *
     * @param  Generator  - A Generator constructor or a simple function
     * @param  namespace  - Namespace under which register the generator
     * @param  resolved - The file path to the generator
     * @param  packagePath - The generator's package path
     */
    protected registerStub(Generator: any, namespace: string, resolved?: string, packagePath?: string): GeneratorMeta;
}
