#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(CleverPushCapacitorPlugin, "CleverPushPlugin",
           CAP_PLUGIN_METHOD(getSubscriptionId, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(isSubscribed, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(unsubscribe, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(subscribe, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(enableDevelopmentMode, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(initCleverPush, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(showTopicsDialog, CAPPluginReturnNone);
)
