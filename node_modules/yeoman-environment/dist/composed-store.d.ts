import type { Logger, BaseGenerator } from '@yeoman/types';
export declare class ComposedStore {
    private readonly log?;
    private readonly generators;
    private readonly uniqueByPathMap;
    private readonly uniqueGloballyMap;
    constructor({ log }?: {
        log?: Logger;
    });
    get customCommitTask(): any;
    get customInstallTask(): any;
    getGenerators(): Record<string, BaseGenerator>;
    addGenerator(generator: BaseGenerator): {
        uniqueBy: any;
        identifier: any;
        added: boolean;
        generator: BaseGenerator | undefined;
    } | {
        identifier: any;
        added: boolean;
        generator: BaseGenerator;
        uniqueBy?: undefined;
    };
    getUniqueByPathMap(root: string): Map<string, BaseGenerator>;
    findFeature(featureName: string): Array<{
        generatorId: string;
        feature: any;
    }>;
    private findUniqueFeature;
}
