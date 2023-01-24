'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var core = require('@capacitor/core');

const CleverPushCapacitor = core.registerPlugin('CleverPushCapacitor', {
    web: () => Promise.resolve().then(function () { return web; }).then(m => new m.CleverPushCapacitorWeb()),
});

class CleverPushCapacitorWeb extends core.WebPlugin {
    async echo(options) {
        console.log('ECHO', options);
        return options;
    }
}

var web = /*#__PURE__*/Object.freeze({
    __proto__: null,
    CleverPushCapacitorWeb: CleverPushCapacitorWeb
});

exports.CleverPushCapacitor = CleverPushCapacitor;
//# sourceMappingURL=plugin.cjs.js.map
