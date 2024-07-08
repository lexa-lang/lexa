import type { MemFsEditorFile } from 'mem-fs-editor';
import { type InputOutputAdapter } from '@yeoman/types';
import { type Store } from 'mem-fs';
export type PackageManagerInstallTaskOptions = {
    memFs: Store<MemFsEditorFile>;
    packageJsonLocation: string;
    adapter: InputOutputAdapter;
    nodePackageManager?: string;
    customInstallTask?: boolean | ((nodePackageManager: string | undefined, defaultTask: () => Promise<boolean>) => void | Promise<void>);
    skipInstall?: boolean;
};
/**
 * Executes package manager install.
 * - checks if package.json was committed.
 * - uses a preferred package manager or try to detect.
 * @return {Promise<boolean>} Promise true if the install execution suceeded.
 */
export declare function packageManagerInstallTask({ memFs, packageJsonLocation, customInstallTask, adapter, nodePackageManager, skipInstall, }: PackageManagerInstallTaskOptions): Promise<boolean | void>;
