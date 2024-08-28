#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(CleverPushCapacitorPlugin, "CleverPush",
           CAP_PLUGIN_METHOD(getSubscriptionId, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(isSubscribed, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(unsubscribe, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(subscribe, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(enableDevelopmentMode, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setAuthorizerToken, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(init, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(showTopicsDialog, CAPPluginReturnPromise);
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
           CAP_PLUGIN_METHOD(setSubscriptionAttribute, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getSubscriptionAttribute, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getSubscriptionAttributes, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getAvailableAttributes, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setShowNotificationsInForeground, CAPPluginReturnPromise);
)
