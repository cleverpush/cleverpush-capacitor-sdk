import { registerPlugin } from '@capacitor/core';
const CleverPushCapacitor = registerPlugin('CleverPushCapacitor', {
    web: () => import('./web').then(m => new m.CleverPushCapacitorWeb()),
});
export * from './definitions';
export { CleverPushCapacitor };
//# sourceMappingURL=index.js.map