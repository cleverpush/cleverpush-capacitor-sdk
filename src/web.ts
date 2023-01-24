import { WebPlugin } from '@capacitor/core';

import type { CleverPushCapacitorPlugin } from './definitions';

export class CleverPushCapacitorWeb
  extends WebPlugin
  implements CleverPushCapacitorPlugin
{
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
