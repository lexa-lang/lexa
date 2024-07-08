import { createConflicterTransform, createYoResolveTransform, forceYoFiles } from '@yeoman/conflicter';
import createdLogger from 'debug';
import { create as createMemFsEditor } from 'mem-fs-editor';
import { createCommitTransform } from 'mem-fs-editor/transform';
import { isFilePending } from 'mem-fs-editor/state';
const debug = createdLogger('yeoman:environment:commit');
/**
 * Commits the MemFs to the disc.
 */
export const commitSharedFsTask = async ({ adapter, conflicterOptions, sharedFs, }) => {
    debug('Running commitSharedFsTask');
    const editor = createMemFsEditor(sharedFs);
    await sharedFs.pipeline({ filter: (file) => isFilePending(file) || file.path.endsWith('.yo-resolve') }, createYoResolveTransform(), forceYoFiles(), createConflicterTransform(adapter, conflicterOptions), createCommitTransform());
};
