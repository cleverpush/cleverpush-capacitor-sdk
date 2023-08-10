#import "CleverPushCapacitorPlugin.h"
#import <Foundation/Foundation.h>
#import <CleverPush/CleverPush.h>
#import <objc/runtime.h>
#import <Capacitor/Capacitor-Swift.h>

NSDictionary* dictionaryWithPropertiesOfObject(id obj) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);

    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if ([obj valueForKey:key] != nil) {
            if ([[obj valueForKey:key] isKindOfClass:[NSDate class]]) {
                NSString *convertedDateString = [NSString stringWithFormat:@"%@", [obj valueForKey:key]];
                [dict setObject:convertedDateString forKey:key];
            } else {
                [dict setObject:[obj valueForKey:key] forKey:key];
            }
        }
    }
    free(properties);
    return [NSDictionary dictionaryWithDictionary:dict];
}

@implementation CleverPushCapacitorPlugin

static NSString * _pendingLaunchOptions;
+ (NSString *)pendingLaunchOptions { return _pendingLaunchOptions; }
+ (void)setPendingLaunchOptions:(NSString *)pendingLaunchOptions { _pendingLaunchOptions = pendingLaunchOptions; }

- (void)initCleverPushObjectWithLaunchOptions:(NSDictionary *)launchOptions channelId:(NSString *)channelId autoRegister:(BOOL)autoRegister {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CleverPush initWithLaunchOptions:launchOptions channelId:channelId handleNotificationReceived:^(CPNotificationReceivedResult *result) {
            if (self.pluginCallDelegate != nil) {
                NSDictionary *notificationDictionary = dictionaryWithPropertiesOfObject(result.notification);
                NSDictionary *subscriptionDictionary = dictionaryWithPropertiesOfObject(result.subscription);

                NSMutableDictionary *obj = [NSMutableDictionary dictionary];
                [obj setObject:notificationDictionary forKey:@"notification"];
                [obj setObject:subscriptionDictionary forKey:@"subscription"];

                [self notifyListeners:@"notificationReceived" data:obj];
            }
        } handleNotificationOpened:^(CPNotificationOpenedResult *result) {
            if (self.pluginCallDelegate != nil) {
                NSDictionary *notificationDictionary = dictionaryWithPropertiesOfObject(result.notification);
                NSDictionary *subscriptionDictionary = dictionaryWithPropertiesOfObject(result.subscription);

                NSMutableDictionary *obj = [NSMutableDictionary dictionary];
                [obj setObject:notificationDictionary forKey:@"notification"];
                [obj setObject:subscriptionDictionary forKey:@"subscription"];
                if (result.action != nil) {
                    [obj setObject:result.action forKey:@"action"];
                }

                [self notifyListeners:@"notificationOpened" data:obj];
            }
        } handleSubscribed:^(NSString *subscriptionId) {
            [self notifyListeners:@"subscribed" data:@{@"subscriptionId": subscriptionId}];
        } autoRegister:autoRegister];

        [CleverPush setAppBannerOpenedCallback:^(CPAppBannerAction *action) {
            if (self.pluginCallDelegate != nil && action != nil) {
                NSDictionary *actionObject = dictionaryWithPropertiesOfObject(action);
                [self notifyListeners:@"appBannerOpened" data:actionObject];
            }
        }];
    });
}

- (void)getSubscriptionId:(CAPPluginCall *)call {
    NSString *value = [CleverPush getSubscriptionId];
    [call resolve:@{@"subscriptionId": value ?: @""}];
}

- (void)trackPageView:(CAPPluginCall *)call {
    NSString *url = [call.options objectForKey:@"url"] ?: @"";
    [CleverPush trackPageView:url];
}

- (void)trackEvent:(CAPPluginCall *)call {
    NSString *eventName = [call.options objectForKey:@"eventName"] ?: @"";
    NSDictionary *properties = [call.options objectForKey:@"properties"] ?: @"";
    if (properties != nil) {
        [CleverPush trackEvent:eventName properties:properties];
    } else {
        [CleverPush trackEvent:eventName];
    }
}

- (void)addSubscriptionTag:(CAPPluginCall *)call {
    NSString *tagId = [call.options objectForKey:@"tagId"] ?: @"";
    [CleverPush addSubscriptionTag:tagId];
}

- (void)removeSubscriptionTag:(CAPPluginCall *)call {
    NSString *tagId = [call.options objectForKey:@"tagId"] ?: @"";
    [CleverPush removeSubscriptionTag:tagId];
}

- (void)hasSubscriptionTag:(CAPPluginCall *)call {
    NSString *tagId = [call.options objectForKey:@"tagId"] ?: @"";
    BOOL hasTag = [CleverPush hasSubscriptionTag:tagId];
    [call resolve:@{@"hasTag": @(hasTag)}];
}

- (void)getSubscriptionTags:(CAPPluginCall *)call {
    NSMutableArray *tagIds = [[CleverPush getSubscriptionTags] mutableCopy];
    [call resolve:@{@"tagId": tagIds}];
}

- (void)getSubscriptionTopics:(CAPPluginCall *)call {
    NSMutableArray *topicIds = [[CleverPush getSubscriptionTopics] mutableCopy];
    [call resolve:@{@"topicIds": topicIds}];
}

- (void)setSubscriptionTopics:(CAPPluginCall *)call {
    NSMutableArray *topics = [[call.options valueForKey:@"topics"] mutableCopy];
    [CleverPush setSubscriptionTopics:topics];
}

- (void)getAvailableTopics:(CAPPluginCall *)call {
    [CleverPush getAvailableTopics:^(NSArray<CPChannelTopic *> *topicsArray) {
        [call resolve:@{@"topics": topicsArray}];
    }];
}

- (void)isSubscribed:(CAPPluginCall *)call {
    BOOL value = [CleverPush isSubscribed];
    [call resolve:@{@"isSubscribed": @(value)}];
}

- (void)unsubscribe:(CAPPluginCall *)call {
    [CleverPush unsubscribe];
}

- (void)subscribe:(CAPPluginCall *)call {
    [CleverPush subscribe:^(NSString *subscriptionId) {
        if (self.pluginCallDelegate != nil && call.callbackId != nil) {
            [call resolve:@{@"subscriptionId": subscriptionId}];
        }
    } failure:^(NSError *error) {
        if (self.pluginCallDelegate != nil && call.callbackId != nil) {
            [call reject:error.localizedDescription ?: @"" :nil :nil :nil];
        }
    }];
}

- (void)showTopicsDialog:(CAPPluginCall *)call {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CleverPush showTopicsDialog];
    });
}

- (void)enableDevelopmentMode:(CAPPluginCall *)call {
    [CleverPush enableDevelopmentMode];
}

- (void)setAuthorizerToken:(CAPPluginCall *)call {
    NSString *token = [call.options objectForKey:@"token"] ?: @"";
    [CleverPush setAuthorizerToken:token];
}

- (void)getNotifications:(CAPPluginCall *)call {
    NSArray *notifications = [CleverPush getNotifications];
    NSMutableArray *notificationsArray = [NSMutableArray array];
    for (CPNotification *notification in notifications) {
        [notificationsArray addObject:dictionaryWithPropertiesOfObject(notification)];
    }
    [call resolve:@{@"notifications": notificationsArray}];
}

- (void)init:(CAPPluginCall *)call {
    self.pluginCallDelegate = call;

    NSString *channelId = [call.options objectForKey:@"channelId"] ?: @"";
    BOOL autoRegister = [call.options objectForKey:@"autoRegister"] != nil ? [[call.options objectForKey:@"autoRegister"] boolValue] : YES;
    [self initCleverPushObjectWithLaunchOptions:CleverPushCapacitorPlugin.pendingLaunchOptions channelId:channelId autoRegister:autoRegister];
}

+ (CAPPluginMethod *)getMethod:(NSString *)methodName {
    NSArray *methods = [self pluginMethods];
    for (CAPPluginMethod *method in methods) {
      if ([method.name isEqualToString:methodName]) {
        return method;
      }
    }
    return nil;
}

+ (NSString *)jsName {
    return @"CleverPush";
}

+ (NSString *)identifier {
    return @"CleverPushCapacitorPlugin";
}

+ (NSString *)pluginId {
    return @"CleverPushCapacitorPlugin";
}

+ (NSArray *)pluginMethods {
    NSMutableArray *methods = [NSMutableArray new];
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
    return methods;
}

@synthesize identifier;

@synthesize jsName;

@synthesize pluginMethods;

@end
