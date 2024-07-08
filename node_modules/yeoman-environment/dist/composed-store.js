import crypto from 'node:crypto';
import { toNamespace } from '@yeoman/namespace';
import createdLogger from 'debug';
const debug = createdLogger('yeoman:environment:composed-store');
export class ComposedStore {
    log;
    generators = {};
    uniqueByPathMap = new Map();
    uniqueGloballyMap = new Map();
    constructor({ log } = {}) {
        this.log = log;
    }
    get customCommitTask() {
        return this.findUniqueFeature('customCommitTask');
    }
    get customInstallTask() {
        return this.findUniqueFeature('customInstallTask');
    }
    getGenerators() {
        return { ...this.generators };
    }
    addGenerator(generator) {
        const { features = generator.getFeatures?.() ?? {} } = generator;
        let { uniqueBy } = features;
        const { uniqueGlobally } = features;
        let identifier = uniqueBy;
        if (!uniqueBy) {
            const { namespace } = generator.options;
            const instanceId = crypto.randomBytes(20).toString('hex');
            let namespaceDefinition = toNamespace(namespace);
            if (namespaceDefinition) {
                namespaceDefinition = namespaceDefinition.with({ instanceId });
                uniqueBy = namespaceDefinition.id;
                identifier = namespaceDefinition.namespace;
            }
            else {
                uniqueBy = `${namespace}#${instanceId}`;
                identifier = namespace;
            }
        }
        const generatorRoot = generator.destinationRoot();
        const uniqueByMap = uniqueGlobally ? this.uniqueGloballyMap : this.getUniqueByPathMap(generatorRoot);
        if (uniqueByMap.has(uniqueBy)) {
            return { uniqueBy, identifier, added: false, generator: uniqueByMap.get(uniqueBy) };
        }
        uniqueByMap.set(uniqueBy, generator);
        this.generators[uniqueGlobally ? uniqueBy : `${generatorRoot}#${uniqueBy}`] = generator;
        return { identifier, added: true, generator };
    }
    getUniqueByPathMap(root) {
        if (!this.uniqueByPathMap.has(root)) {
            this.uniqueByPathMap.set(root, new Map());
        }
        return this.uniqueByPathMap.get(root);
    }
    findFeature(featureName) {
        return Object.entries(this.generators)
            .map(([generatorId, generator]) => {
            const { features = generator.getFeatures?.() } = generator;
            const feature = features?.[featureName];
            return feature ? { generatorId, feature } : undefined;
        })
            .filter(Boolean);
    }
    findUniqueFeature(featureName) {
        const providedFeatures = this.findFeature(featureName);
        if (providedFeatures.length > 0) {
            if (providedFeatures.length > 1) {
                this.log?.info?.(`Multiple ${featureName} tasks found (${providedFeatures.map(({ generatorId }) => generatorId).join(', ')}). Using the first.`);
            }
            const { generatorId, feature } = providedFeatures[0];
            debug(`Feature ${featureName} provided by ${generatorId}`);
            return feature;
        }
        return undefined;
    }
}
