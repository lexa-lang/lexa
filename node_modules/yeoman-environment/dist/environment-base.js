import EventEmitter from 'node:events';
import { createRequire } from 'node:module';
import { basename, isAbsolute, join, relative, resolve } from 'node:path';
import process from 'node:process';
import { realpathSync } from 'node:fs';
import { QueuedAdapter } from '@yeoman/adapter';
import { create as createMemFs } from 'mem-fs';
import { FlyRepository } from 'fly-import';
import createdLogger from 'debug';
// @ts-expect-error grouped-queue don't have types
import GroupedQueue from 'grouped-queue';
import { isFilePending } from 'mem-fs-editor/state';
import { transform, filePipeline } from '@yeoman/transform';
import { toNamespace } from '@yeoman/namespace';
import chalk from 'chalk';
import { defaults, pick } from 'lodash-es';
import { ComposedStore } from './composed-store.js';
import Store from './store.js';
import { asNamespace, defaultLookups } from './util/namespace.js';
import { lookupGenerators } from './generator-lookup.js';
import { UNKNOWN_NAMESPACE, UNKNOWN_RESOLVED, defaultQueues } from './constants.js';
import { resolveModulePath } from './util/resolve.js';
import { commitSharedFsTask } from './commit.js';
import { packageManagerInstallTask } from './package-manager.js';
// eslint-disable-next-line import/order
import { splitArgsFromString } from './util/util.js';
const require = createRequire(import.meta.url);
// eslint-disable-next-line @typescript-eslint/naming-convention
const ENVIRONMENT_VERSION = require('../package.json').version;
const debug = createdLogger('yeoman:environment');
const getInstantiateOptions = (args, options) => {
    if (Array.isArray(args) || typeof args === 'string') {
        return { generatorArgs: splitArgsFromString(args), generatorOptions: options };
    }
    if (args !== undefined) {
        if ('generatorOptions' in args || 'generatorArgs' in args) {
            return args;
        }
        if ('options' in args || 'arguments' in args || 'args' in args) {
            const { args: insideArgs, arguments: generatorArgs = insideArgs, options: generatorOptions, ...remainingOptions } = args;
            return { generatorArgs: splitArgsFromString(generatorArgs), generatorOptions: generatorOptions ?? remainingOptions };
        }
    }
    return { generatorOptions: options };
};
const getComposeOptions = (...varargs) => {
    if (varargs.filter(Boolean).length === 0)
        return {};
    const [args, options, composeOptions] = varargs;
    if (typeof args === 'boolean') {
        return { schedule: args };
    }
    let generatorArgs;
    let generatorOptions;
    if (args !== undefined) {
        if (Array.isArray(args)) {
            generatorArgs = args;
        }
        else if (typeof args === 'string') {
            generatorArgs = splitArgsFromString(String(args));
        }
        else if (typeof args === 'object') {
            if ('generatorOptions' in args || 'generatorArgs' in args || 'schedule' in args) {
                return args;
            }
            generatorOptions = args;
        }
    }
    if (typeof options === 'boolean') {
        return { generatorArgs, generatorOptions, schedule: options };
    }
    generatorOptions = generatorOptions ?? options;
    if (typeof composeOptions === 'boolean') {
        return { generatorArgs, generatorOptions, schedule: composeOptions };
    }
    return {};
};
/**
 * Copy and remove null and undefined values
 * @param object
 * @returns
 */
export function removePropertiesWithNullishValues(object) {
    return Object.fromEntries(Object.entries(object).filter(([_key, value]) => value !== undefined && value !== null));
}
// eslint-disable-next-line unicorn/prefer-event-target
export default class EnvironmentBase extends EventEmitter {
    cwd;
    logCwd;
    adapter;
    sharedFs;
    conflicterOptions;
    options;
    aliases = [];
    store;
    command;
    runLoop;
    composedStore;
    lookups;
    sharedOptions;
    repository;
    experimental;
    _rootGenerator;
    compatibilityMode;
    constructor(options = {}) {
        super();
        this.setMaxListeners(100);
        const { cwd = process.cwd(), logCwd = cwd, sharedFs = createMemFs(), command, yeomanRepository, arboristRegistry, sharedOptions = {}, experimental, console: adapterConsole, stdin, stderr, stdout, adapter = new QueuedAdapter({ console: adapterConsole, stdin, stdout, stderr }), ...remainingOptions } = options;
        this.options = remainingOptions;
        this.adapter = adapter;
        this.cwd = resolve(cwd);
        this.logCwd = logCwd;
        this.store = new Store(this);
        this.command = command;
        this.runLoop = new GroupedQueue(defaultQueues, false);
        this.composedStore = new ComposedStore({ log: this.adapter.log });
        this.sharedFs = sharedFs;
        // Each composed generator might set listeners on these shared resources. Let's make sure
        // Node won't complain about event listeners leaks.
        this.runLoop.setMaxListeners(0);
        this.sharedFs.setMaxListeners(0);
        this.lookups = defaultLookups;
        this.sharedOptions = sharedOptions;
        // Create a default sharedData.
        this.sharedOptions.sharedData = this.sharedOptions.sharedData ?? {};
        // Pass forwardErrorToEnvironment to generators.
        this.sharedOptions.forwardErrorToEnvironment = false;
        this.repository = new FlyRepository({
            repositoryPath: yeomanRepository ?? `${this.cwd}/.yo-repository`,
            arboristConfig: {
                registry: arboristRegistry,
            },
        });
        // eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing
        this.experimental = experimental || process.argv.includes('--experimental');
        this.alias(/^([^:]+)$/, '$1:app');
    }
    findFeature(featureName) {
        return this.composedStore.findFeature(featureName);
    }
    async applyTransforms(transformStreams, options = {}) {
        const { streamOptions = { filter: file => isFilePending(file) }, stream = this.sharedFs.stream(streamOptions), name = 'Transforming', } = options;
        if (!Array.isArray(transformStreams)) {
            transformStreams = [transformStreams];
        }
        await this.adapter.progress(async ({ step }) => {
            await filePipeline(stream, [
                ...transformStreams,
                transform(file => {
                    step('Completed', relative(this.logCwd, file.path));
                    return undefined;
                }),
            ]);
        }, { name, disabled: !(options?.log ?? true) });
    }
    /**
     * @param   namespaceOrPath
     * @return the generator meta registered under the namespace
     */
    async findMeta(namespaceOrPath) {
        // Stop the recursive search if nothing is left
        if (!namespaceOrPath) {
            return;
        }
        const parsed = toNamespace(namespaceOrPath);
        if (typeof namespaceOrPath !== 'string' || parsed) {
            const ns = parsed.namespace;
            return this.store.getMeta(ns) ?? this.store.getMeta(this.alias(ns));
        }
        const maybeMeta = this.store.getMeta(namespaceOrPath) ?? this.store.getMeta(this.alias(namespaceOrPath));
        if (maybeMeta) {
            return maybeMeta;
        }
        try {
            const resolved = await resolveModulePath(namespaceOrPath);
            if (resolved) {
                return this.store.add({ resolved, namespace: this.namespace(resolved) });
            }
        }
        catch { }
        return undefined;
    }
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
    async get(namespaceOrPath) {
        const meta = await this.findMeta(namespaceOrPath);
        return meta?.importGenerator();
    }
    async create(namespaceOrPath, ...args) {
        let constructor;
        const namespace = typeof namespaceOrPath === 'string' ? toNamespace(namespaceOrPath) : undefined;
        const checkGenerator = (Generator) => {
            const generatorNamespace = Generator?.namespace;
            if (namespace && generatorNamespace !== namespace.namespace && generatorNamespace !== UNKNOWN_NAMESPACE) {
                // Update namespace object in case of aliased namespace.
                try {
                    namespace.namespace = Generator.namespace;
                }
                catch {
                    // Invalid namespace can be aliased to a valid one.
                }
            }
            if (typeof Generator !== 'function') {
                throw new TypeError(chalk.red(`You don't seem to have a generator with the name “${namespace?.generatorHint}” installed.`) +
                    '\n' +
                    'But help is on the way:\n\n' +
                    'You can see available generators via ' +
                    chalk.yellow('npm search yeoman-generator') +
                    ' or via ' +
                    chalk.yellow('http://yeoman.io/generators/') +
                    '. \n' +
                    'Install them with ' +
                    chalk.yellow(`npm install ${namespace?.generatorHint}`) +
                    '.\n\n' +
                    'To see all your installed generators run ' +
                    chalk.yellow('yo --generators') +
                    '. ' +
                    'Adding the ' +
                    chalk.yellow('--help') +
                    ' option will also show subgenerators. \n\n' +
                    'If ' +
                    chalk.yellow('yo') +
                    ' cannot find the generator, run ' +
                    chalk.yellow('yo doctor') +
                    ' to troubleshoot your system.');
            }
            return Generator;
        };
        if (typeof namespaceOrPath !== 'string') {
            return this.instantiate(checkGenerator(namespaceOrPath), ...args);
        }
        if (typeof namespaceOrPath === 'string') {
            const meta = await this.findMeta(namespaceOrPath);
            constructor = await meta?.importGenerator();
            if (namespace && !constructor) {
                // Await this.lookupLocalNamespaces(namespace);
                // constructor = await this.get(namespace);
            }
            if (constructor) {
                constructor._meta = meta;
            }
        }
        else {
            constructor = namespaceOrPath;
        }
        return this.instantiate(checkGenerator(constructor), ...args);
    }
    async instantiate(constructor, ...args) {
        const composeOptions = args.length > 0 ? getInstantiateOptions(...args) : {};
        const { namespace = UNKNOWN_NAMESPACE, resolved = UNKNOWN_RESOLVED, _meta } = constructor;
        const environmentOptions = { env: this, resolved, namespace };
        const generator = new constructor(composeOptions.generatorArgs ?? [], {
            ...this.sharedOptions,
            ...composeOptions.generatorOptions,
            ...environmentOptions,
        });
        generator._meta = _meta;
        generator._environmentOptions = {
            ...this.options,
            ...this.sharedOptions,
            ...environmentOptions,
        };
        if (!composeOptions.generatorOptions?.help && generator._postConstruct) {
            await generator._postConstruct();
        }
        return generator;
    }
    async composeWith(generator, ...args) {
        const options = getComposeOptions(...args);
        const { schedule: passedSchedule = true, ...instantiateOptions } = options;
        const generatorInstance = await this.create(generator, instantiateOptions);
        // Convert to function to keep type compatibility with old @yeoman/types where schedule is boolean only
        const schedule = typeof passedSchedule === 'function' ? passedSchedule : () => passedSchedule;
        return this.queueGenerator(generatorInstance, { schedule: schedule(generatorInstance) });
    }
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
    namespace(filepath, lookups = this.lookups) {
        return asNamespace(filepath, { lookups });
    }
    getVersion(packageName) {
        if (packageName && packageName !== 'yeoman-environment') {
            try {
                return require(`${packageName}/package.json`).version;
            }
            catch {
                return undefined;
            }
        }
        return ENVIRONMENT_VERSION;
    }
    /**
     * Queue generator run (queue itself tasks).
     *
     * @param {Generator} generator Generator instance
     * @param {boolean} [schedule=false] Whether to schedule the generator run.
     * @return {Generator} The generator or singleton instance.
     */
    async queueGenerator(generator, queueOptions) {
        const schedule = typeof queueOptions === 'boolean' ? queueOptions : queueOptions?.schedule ?? false;
        const { added, identifier, generator: composedGenerator } = this.composedStore.addGenerator(generator);
        if (!added) {
            debug(`Using existing generator for namespace ${identifier}`);
            return composedGenerator;
        }
        this.emit('compose', identifier, generator);
        this.emit(`compose:${identifier}`, generator);
        const runGenerator = async () => {
            if (generator.queueTasks) {
                // Generator > 5
                this.once('run', () => generator.emit('run'));
                this.once('end', () => generator.emit('end'));
                await generator.queueTasks();
                return;
            }
            if (!generator.options.forwardErrorToEnvironment) {
                generator.on('error', (error) => this.emit('error', error));
            }
            generator.promise = generator.run();
        };
        if (schedule) {
            this.queueTask('environment:run', async () => runGenerator());
        }
        else {
            await runGenerator();
        }
        return generator;
    }
    /**
     * Get the first generator that was queued to run in this environment.
     *
     * @return {Generator} generator queued to run in this environment.
     */
    rootGenerator() {
        return this._rootGenerator;
    }
    async runGenerator(generator) {
        generator = await this.queueGenerator(generator);
        this.compatibilityMode = generator.queueTasks ? false : 'v4';
        this._rootGenerator = this._rootGenerator ?? generator;
        return this.start(generator.options);
    }
    register(pathOrStub, meta, ...args) {
        if (typeof pathOrStub === 'string') {
            if (typeof meta === 'object') {
                return this.registerGeneratorPath(pathOrStub, meta.namespace, meta.packagePath);
            }
            // Backward compatibility
            return this.registerGeneratorPath(pathOrStub, meta, ...args);
        }
        if (pathOrStub) {
            if (typeof meta === 'object') {
                return this.registerStub(pathOrStub, meta.namespace, meta.resolved, meta.packagePath);
            }
            // Backward compatibility
            return this.registerStub(pathOrStub, meta, ...args);
        }
        throw new TypeError('You must provide a generator name to register.');
    }
    /**
     * Queue tasks
     * @param {string} priority
     * @param {(...args: any[]) => void | Promise<void>} task
     * @param {{ once?: string, startQueue?: boolean }} [options]
     */
    queueTask(priority, task, options) {
        this.runLoop.add(priority, async (done, stop) => {
            try {
                await task();
                done();
            }
            catch (error) {
                stop(error);
            }
        }, {
            once: options?.once,
            run: options?.startQueue ?? false,
        });
    }
    /**
     * Add priority
     * @param {string} priority
     * @param {string} [before]
     */
    addPriority(priority, before) {
        if (this.runLoop.queueNames.includes(priority)) {
            return;
        }
        this.runLoop.addSubQueue(priority, before);
    }
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
    async lookup(options) {
        const { registerToScope, customizeNamespace = (ns) => ns, lookups = this.lookups, ...remainingOptions } = options ?? { localOnly: false };
        options = {
            ...remainingOptions,
            lookups,
        };
        const generators = [];
        await lookupGenerators(options, ({ packagePath, filePath, lookups }) => {
            let repositoryPath = join(packagePath, '..');
            if (basename(repositoryPath).startsWith('@')) {
                // Scoped package
                repositoryPath = join(repositoryPath, '..');
            }
            let namespace = customizeNamespace(asNamespace(relative(repositoryPath, filePath), { lookups }));
            try {
                const resolved = realpathSync(filePath);
                if (!namespace) {
                    namespace = customizeNamespace(asNamespace(resolved, { lookups }));
                }
                namespace = namespace;
                if (registerToScope && !namespace.startsWith('@')) {
                    namespace = `@${registerToScope}/${namespace}`;
                }
                const meta = this.store.add({ namespace, packagePath, resolved });
                if (meta) {
                    generators.push({
                        ...meta,
                        registered: true,
                    });
                    return Boolean(options?.singleResult);
                }
            }
            catch (error) {
                console.error('Unable to register %s (Error: %s)', filePath, error);
            }
            generators.push({
                resolved: filePath,
                namespace: namespace,
                packagePath,
                registered: false,
            });
            return false;
        });
        return generators;
    }
    /**
     * Verify if a package namespace already have been registered.
     *
     * @param  packageNS - namespace of the package.
     * @return true if any generator of the package has been registered
     */
    isPackageRegistered(packageNamespace) {
        const registeredPackages = this.getRegisteredPackages();
        return registeredPackages.includes(packageNamespace) || registeredPackages.includes(this.alias(packageNamespace).split(':', 2)[0]);
    }
    /**
     * Get all registered packages namespaces.
     *
     * @return array of namespaces.
     */
    getRegisteredPackages() {
        return this.store.getPackagesNS();
    }
    /**
     * Returns stored generators meta
     * @param namespace
     */
    getGeneratorMeta(namespace) {
        const meta = this.store.getMeta(namespace) ?? this.store.getMeta(this.alias(namespace));
        if (!meta) {
            return;
        }
        // eslint-disable-next-line @typescript-eslint/consistent-type-assertions
        return { ...meta };
    }
    alias(match, value) {
        if (match && value) {
            this.aliases.push({
                match: match instanceof RegExp ? match : new RegExp(`^${match}$`),
                value,
            });
            return this;
        }
        if (typeof match !== 'string') {
            throw new TypeError('string is required');
        }
        const aliases = [...this.aliases].reverse();
        return aliases.reduce((resolved, alias) => {
            if (!alias.match.test(resolved)) {
                return resolved;
            }
            return resolved.replace(alias.match, alias.value);
        }, match);
    }
    /**
     * Watch for package.json and queue package manager install task.
     */
    watchForPackageManagerInstall({ cwd, queueTask, installTask, } = {}) {
        if (cwd && !installTask) {
            throw new Error(`installTask is required when using a custom cwd`);
        }
        const npmCwd = cwd ?? this.cwd;
        const queueInstallTask = () => {
            this.queueTask('install', async () => {
                if (this.compatibilityMode === 'v4') {
                    debug('Running in generator < 5 compatibility. Package manager install is done by the generator.');
                    return;
                }
                const { adapter, sharedFs: memFs } = this;
                const { skipInstall, nodePackageManager } = this.options;
                await packageManagerInstallTask({
                    adapter,
                    memFs,
                    packageJsonLocation: npmCwd,
                    skipInstall,
                    nodePackageManager,
                    customInstallTask: installTask ?? this.composedStore.customInstallTask,
                });
            }, { once: `package manager install ${npmCwd}` });
        };
        this.sharedFs.on('change', file => {
            if (file === join(npmCwd, 'package.json')) {
                queueInstallTask();
            }
        });
        if (queueTask) {
            queueInstallTask();
        }
    }
    /**
     * Start Environment queue
     * @param {Object} options - Conflicter options.
     */
    async start(options) {
        return new Promise((resolve, reject) => {
            Object.assign(this.options, removePropertiesWithNullishValues(pick(options, ['skipInstall', 'nodePackageManager'])));
            this.logCwd = options.logCwd ?? this.logCwd;
            this.conflicterOptions = pick(defaults({}, this.options, options), ['force', 'bail', 'ignoreWhitespace', 'dryRun', 'skipYoResolve']);
            this.conflicterOptions.cwd = this.logCwd;
            this.queueCommit();
            this.queueTask('install', () => {
                // Postpone watchForPackageManagerInstall to install priority since env's cwd can be changed by generators
                this.watchForPackageManagerInstall({ queueTask: true });
            });
            /*
             * Listen to errors and reject if emmited.
             * Some cases the generator relied at the behavior that the running process
             * would be killed if an error is thrown to environment.
             * Make sure to not rely on that behavior.
             */
            this.on('error', async (error) => {
                this.runLoop.pause();
                await this.adapter.onIdle?.();
                reject(error);
                this.adapter.close();
            });
            this.once('end', async () => {
                await this.adapter.onIdle?.();
                resolve();
                this.adapter.close();
            });
            /*
             * For backward compatibility
             */
            this.on('generator:reject', error => {
                this.emit('error', error);
            });
            /*
             * For backward compatibility
             */
            this.on('generator:resolve', () => {
                this.emit('end');
            });
            this.runLoop.on('error', (error) => {
                this.emit('error', error);
            });
            this.runLoop.on('paused', () => {
                this.emit('paused');
            });
            /* If runLoop has ended, the environment has ended too. */
            this.runLoop.once('end', () => {
                this.emit('end');
            });
            this.emit('run');
            this.runLoop.start();
        });
    }
    /**
     * Queue environment's commit task.
     */
    queueCommit() {
        const queueCommit = () => {
            debug('Queueing conflicts task');
            this.queueTask('environment:conflicts', async () => {
                debug('Adding queueCommit listener');
                // Conflicter can change files add listener before commit task.
                const changedFileHandler = (filePath) => {
                    const file = this.sharedFs.get(filePath);
                    if (isFilePending(file)) {
                        queueCommit();
                        this.sharedFs.removeListener('change', changedFileHandler);
                    }
                };
                this.sharedFs.on('change', changedFileHandler);
                debug('Running conflicts');
                const { customCommitTask = async () => commitSharedFsTask(this) } = this.composedStore;
                if (typeof customCommitTask === 'function') {
                    await customCommitTask();
                }
                else {
                    debug('Ignoring commit, custom commit was provided');
                }
            }, {
                once: 'write memory fs to disk',
            });
        };
        queueCommit();
    }
    /**
     * Registers a specific `generator` to this environment. This generator is stored under
     * provided namespace, or a default namespace format if none if available.
     *
     * @param   name      - Filepath to the a generator or a npm package name
     * @param   namespace - Namespace under which register the generator (optional)
     * @param   packagePath - PackagePath to the generator npm package (optional)
     * @return  environment - This environment
     */
    registerGeneratorPath(generatorPath, namespace, packagePath) {
        if (typeof generatorPath !== 'string') {
            throw new TypeError('You must provide a generator name to register.');
        }
        if (!isAbsolute(generatorPath)) {
            throw new Error(`An absolute path is required to register`);
        }
        namespace = namespace ?? this.namespace(generatorPath);
        if (!namespace) {
            throw new Error('Unable to determine namespace.');
        }
        // Generator is already registered and matches the current namespace.
        const generatorMeta = this.store.getMeta(namespace);
        if (generatorMeta && generatorMeta.resolved === generatorPath) {
            return generatorMeta;
        }
        const meta = this.store.add({ namespace, resolved: generatorPath, packagePath });
        debug('Registered %s (%s) on package %s (%s)', namespace, generatorPath, meta.packageNamespace, packagePath);
        return meta;
    }
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
    registerStub(Generator, namespace, resolved = UNKNOWN_RESOLVED, packagePath) {
        if (typeof Generator !== 'function' && typeof Generator.createGenerator !== 'function') {
            throw new TypeError('You must provide a stub function to register.');
        }
        if (typeof namespace !== 'string') {
            throw new TypeError('You must provide a namespace to register.');
        }
        const meta = this.store.add({ namespace, resolved, packagePath }, Generator);
        debug('Registered %s (%s) on package (%s)', namespace, resolved, packagePath);
        return meta;
    }
}
