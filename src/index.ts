import { registerPlugin } from '@capacitor/core';

import type { CleverPushCapacitorPlugin } from './definitions';

const CleverPushCapacitor = registerPlugin<CleverPushCapacitorPlugin>(
  'CleverPushCapacitor',
  {
    web: () => import('./web').then(m => new m.CleverPushCapacitorWeb()),
  },
);

export * from './definitions';
export { CleverPushCapacitor };
