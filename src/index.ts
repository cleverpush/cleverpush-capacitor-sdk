import { registerPlugin } from '@capacitor/core';

import type { CleverPushCapacitorPlugin } from './definitions';

const CleverPushPlugin = registerPlugin<CleverPushCapacitorPlugin>(
  'CleverPush',
  {},
);

export * from './definitions';
export default CleverPushPlugin;
