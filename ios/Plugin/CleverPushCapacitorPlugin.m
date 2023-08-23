#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>
#import <objc/runtime.h>

CAP_PLUGIN(CleverPushCapacitorPlugin, "CleverPush",
           CAP_PLUGIN_METHOD(getSubscriptionId, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(isSubscribed, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(unsubscribe, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(subscribe, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(enableDevelopmentMode, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(setAuthorizerToken, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(init, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(showTopicsDialog, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(trackPageView, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(trackEvent, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(addSubscriptionTag, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(removeSubscriptionTag, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(hasSubscriptionTag, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getSubscriptionTags, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getSubscriptionTopics, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setSubscriptionTopics, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getAvailableTopics, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getNotifications, CAPPluginReturnPromise);
)
