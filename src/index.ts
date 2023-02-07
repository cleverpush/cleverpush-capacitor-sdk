import { registerPlugin } from '@capacitor/core';

import type { CleverPushCapacitorPlugin } from './definitions';

const CleverPushPlugin = registerPlugin<CleverPushCapacitorPlugin>(
  'CleverPushPlugin',
  {},
);

export * from './definitions';
export default CleverPushPlugin;
