import type { InputOutputAdapter } from '@yeoman/types';
import { type ConflicterOptions } from '@yeoman/conflicter';
import type { Store } from 'mem-fs';
import { type MemFsEditorFile } from 'mem-fs-editor';
/**
 * Commits the MemFs to the disc.
 */
export declare const commitSharedFsTask: ({ adapter, conflicterOptions, sharedFs, }: {
    adapter: InputOutputAdapter;
    conflicterOptions?: ConflicterOptions | undefined;
    sharedFs: Store<MemFsEditorFile>;
}) => Promise<void>;
