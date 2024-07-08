import { type SyncOptions } from 'execa';
export declare const execaOutput: (cmg: string, args: string[], options: SyncOptions) => string | undefined;
/**
 * Two-step argument splitting function that first splits arguments in quotes,
 * and then splits up the remaining arguments if they are not part of a quote.
 */
export declare function splitArgsFromString(argsString: string | string[]): string[];
