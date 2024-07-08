type AsNamespaceOptions = {
    lookups?: string[];
};
export declare const defaultLookups: string[];
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
 * @param filepath
 * @param lookups paths
 */
export declare const asNamespace: (filepath: string, { lookups }: AsNamespaceOptions) => string;
export {};
