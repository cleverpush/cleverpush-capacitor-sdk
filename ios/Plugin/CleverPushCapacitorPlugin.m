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
                NSDate *createdAtDate = (NSDate*) obj;
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                NSString *convertedDateString = [dateFormatter stringFromDate:createdAtDate];

                if (convertedDateString != nil) {
                    [dict setObject:convertedDateString forKey:key];
                } else {
                    [dict setObject:[obj valueForKey:key] forKey:key];
                }
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
                [obj setObject:[self getNotificationDictionary:notificationDictionary] forKey:@"notification"];
                [obj setObject:subscriptionDictionary forKey:@"subscription"];

                [self notifyListeners:@"notificationReceived" data:obj];
            }
        } handleNotificationOpened:^(CPNotificationOpenedResult *result) {
            if (self.pluginCallDelegate != nil) {
                NSDictionary *notificationDictionary = dictionaryWithPropertiesOfObject(result.notification);
                NSDictionary *subscriptionDictionary = dictionaryWithPropertiesOfObject(result.subscription);

                NSMutableDictionary *obj = [NSMutableDictionary dictionary];
                [obj setObject:[self getNotificationDictionary:notificationDictionary] forKey:@"notification"];
                [obj setObject:subscriptionDictionary forKey:@"subscription"];
                if (result.action != nil) {
                    [obj setObject:result.action forKey:@"action"];
                }

                [self notifyListeners:@"notificationOpened" data:obj];
            }
        } handleSubscribed:^(NSString *subscriptionId) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self;
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
    if (url != nil) {
        [CleverPush trackPageView:url];
        [call resolve:@{@"success":@YES}];
    } else {
        [call reject:@"Invalid URL parameter" :nil :nil :nil];
    }
}

- (void)trackEvent:(CAPPluginCall *)call {
    NSString *eventName = [call.options objectForKey:@"eventName"] ?: @"";
    NSDictionary *properties = [call.options objectForKey:@"properties"] ?: @"";
    if (eventName != nil) {
        if (properties != nil) {
            [CleverPush trackEvent:eventName properties:properties];
        } else {
            [CleverPush trackEvent:eventName];
        }
        [call resolve:@{@"success":@YES}];
    } else {
        [call reject:@"Invalid eventName parameter" :nil :nil :nil];
    }
}

- (void)addSubscriptionTag:(CAPPluginCall *)call {
    NSString *tagId = [call.options objectForKey:@"tagId"] ?: @"";
    if (tagId != nil) {
        [CleverPush addSubscriptionTag:tagId];
        [call resolve:@{@"success":@YES}];
    } else {
        [call reject:@"Invalid tagId parameter" :nil :nil :nil];
    }
}

- (void)removeSubscriptionTag:(CAPPluginCall *)call {
    NSString *tagId = [call.options objectForKey:@"tagId"] ?: @"";
    if (tagId != nil) {
        [CleverPush removeSubscriptionTag:tagId];
        [call resolve:@{@"success":@YES}];
    } else {
        [call reject:@"Invalid tagId parameter" :nil :nil :nil];
    }
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
    if (topics != nil) {
        [CleverPush setSubscriptionTopics:topics];
        [call resolve:@{@"success":@YES}];
    } else {
        [call reject:@"Invalid topics parameter" :nil :nil :nil];
    }
}

- (void)getAvailableTopics:(CAPPluginCall *)call {
    [CleverPush getAvailableTopics:^(NSArray<CPChannelTopic *> *topicsArray) {
        [call resolve:@{@"topics": topicsArray}];
    }];
}

- (void)setSubscriptionAttribute:(CAPPluginCall *)call {
    NSString *attributeId = [call.options objectForKey:@"attributeId"] ?: @"";
    NSString *value = [call.options objectForKey:@"value"] ?: @"";
    if (attributeId != nil && value != nil) {
        [CleverPush setSubscriptionAttribute:attributeId value:value];
        [call resolve:@{@"success":@YES}];
    } else {
        [call reject:@"Invalid attributeId or value parameter" :nil :nil :nil];
    }
}

- (void)getSubscriptionAttribute:(CAPPluginCall *)call {
    NSString *attributeId = [call.options objectForKey:@"attributeId"] ?: @"";
    NSString *value = [CleverPush getSubscriptionAttribute:attributeId] ?: @"";
    [call resolve:@{@"value": value}];
}

- (void)getSubscriptionAttributes:(CAPPluginCall *)call {
    NSDictionary *attributes = [CleverPush getSubscriptionAttributes] ?: @"";
    [call resolve:@{@"attributes": attributes}];
}

- (void)getAvailableAttributes:(CAPPluginCall *)call {
    [CleverPush getAvailableAttributes:^(NSMutableArray *attributes) {
        [call resolve:@{@"attributes": attributes}];
    }];
}

- (void)isSubscribed:(CAPPluginCall *)call {
    BOOL value = [CleverPush isSubscribed];
    [call resolve:@{@"isSubscribed": @(value)}];
}

- (void)unsubscribe:(CAPPluginCall *)call {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CleverPush unsubscribe:^(BOOL success) {
            if (success) {
                [call resolve:@{@"success":@YES}];
            } else {
                [call reject:@"unsubscribe failed" :nil :nil :nil];
            }
        }];
    });
}

- (void)subscribe:(CAPPluginCall *)call {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CleverPush subscribe:^(NSString *subscriptionId) {
            if (self.pluginCallDelegate != nil && call.callbackId != nil) {
                [call resolve:@{@"subscriptionId": subscriptionId}];
            }
        } failure:^(NSError *error) {
            if (self.pluginCallDelegate != nil || call.callbackId != nil) {
                [call reject:error.localizedDescription ?: @"" :nil :nil :nil];
            }
        }];
    });
}

- (void)showTopicsDialog:(CAPPluginCall *)call {
    dispatch_async(dispatch_get_main_queue(), ^{
        [CleverPush showTopicsDialog];
        [call resolve:@{@"success":@YES}];
    });
}

- (void)enableDevelopmentMode:(CAPPluginCall *)call {
    [CleverPush enableDevelopmentMode];
    [call resolve:@{@"success":@YES}];
}

- (void)setAuthorizerToken:(CAPPluginCall *)call {
    NSString *token = [call.options objectForKey:@"token"] ?: @"";
    if (token != nil) {
        [CleverPush setAuthorizerToken:token];
        [call resolve:@{@"success":@YES}];
    } else {
        [call reject:@"Invalid token parameter" :nil :nil :nil];
    }
}

- (void)setShowNotificationsInForeground:(CAPPluginCall *)call {
    BOOL show = [call.options objectForKey:@"showNotifications"] ? [[call.options objectForKey:@"showNotifications"] boolValue] : YES;
    [CleverPush setShowNotificationsInForeground:show];
    [call resolve:@{@"success":@YES}];
}

- (NSDictionary*)getNotificationDictionary:(NSDictionary*)notificationDictionary {
    NSMutableDictionary *mutableNotificationDictionary = [notificationDictionary mutableCopy];
    // rename `id` to `_id`
    [mutableNotificationDictionary setObject:[mutableNotificationDictionary objectForKey:@"id"] forKey:@"_id"];
    [mutableNotificationDictionary removeObjectForKey:@"id"];

    return mutableNotificationDictionary;
}

- (void)getNotifications:(CAPPluginCall *)call {
    NSArray *notifications = [CleverPush getNotifications];
    NSMutableArray *notificationsArray = [NSMutableArray array];
    for (CPNotification *notification in notifications) {
        NSDictionary *notificationDictionary = dictionaryWithPropertiesOfObject(notification);
        [notificationsArray addObject:[self getNotificationDictionary:notificationDictionary]];
    }
    [call resolve:@{@"notifications": notificationsArray}];
}

- (void)init:(CAPPluginCall *)call {
    self.pluginCallDelegate = call;
    
    NSString *channelId = [call.options objectForKey:@"channelId"] ?: @"";
    BOOL autoRegister = [call.options objectForKey:@"autoRegister"] != nil ? [[call.options objectForKey:@"autoRegister"] boolValue] : YES;
    [self initCleverPushObjectWithLaunchOptions:CleverPushCapacitorPlugin.pendingLaunchOptions channelId:channelId autoRegister:autoRegister];
}

- (NSString *)jsName {
    return @"CleverPush";
}

- (NSString *)identifier {
    return @"CleverPushCapacitorPlugin";
}

- (NSArray *)pluginMethods {
    NSMutableArray *methods = [NSMutableArray new];
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
    return methods;
}

@synthesize identifier;

@synthesize jsName;

@synthesize pluginMethods;

@end
