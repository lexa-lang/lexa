import { requireNamespace } from '@yeoman/namespace';
import { groupBy } from 'lodash-es';
import createLogger from 'debug';
import { createEnv } from '../index.js';
const debug = createLogger('yeoman:yoe');
export const printGroupedGenerator = (generators) => {
    const grouped = groupBy(generators, 'packagePath');
    for (const [packagePath, group] of Object.entries(grouped)) {
        const namespace = requireNamespace(group[0].namespace);
        console.log(`  ${namespace.packageNamespace} at ${packagePath}`);
        for (const generator of group) {
            const generatorNamespace = requireNamespace(generator.namespace);
            console.log(`    :${generatorNamespace.generator || 'app'}`);
        }
        console.log('');
    }
    console.log(`${generators.length} generators`);
};
/**
 * @param {string} generatorNamespace
 * @param {*} options
 * @param {*} command
 * @returns
 */
export const environmentAction = async function (generatorNamespace, options, command) {
    debug('Handling operands %o', generatorNamespace);
    if (!generatorNamespace) {
        return;
    }
    const env = createEnv({ ...options, command: this });
    this.env = env;
    await env.lookupLocalPackages();
    return env.execute(generatorNamespace, command.args.splice(1));
};
