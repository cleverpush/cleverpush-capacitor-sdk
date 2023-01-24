import { WebPlugin } from '@capacitor/core';
import type { CleverPushCapacitorPlugin } from './definitions';
export declare class CleverPushCapacitorWeb extends WebPlugin implements CleverPushCapacitorPlugin {
    echo(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
}
