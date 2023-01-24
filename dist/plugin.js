var capacitorCleverPushCapacitor = (function (exports, core) {
    'use strict';

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

    Object.defineProperty(exports, '__esModule', { value: true });

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
