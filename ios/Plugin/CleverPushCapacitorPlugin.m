#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(CleverPushCapacitorPlugin, "CleverPushCapacitor",
           CAP_PLUGIN_METHOD(echo, CAPPluginReturnPromise);
)

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "CleverPushCapacitorPlugin.h"
#import <CleverPush/CleverPush.h>

NSString* notificationReceivedCallbackId;
NSString* notificationOpenedCallbackId;
NSString* subscribedCallbackId;
NSString* appBannerOpenedCallbackId;

CPNotificationOpenedResult* notificationOpenedResult;
NSString* pendingSubscribedResult;

NSDictionary* pendingLaunchOptions;

id <CDVCommandDelegate> pluginCommandDelegate;

void successCallback(NSString* callbackId, NSDictionary* data) {
    CDVPluginResult* commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
    commandResult.keepCallback = @1;
    [pluginCommandDelegate sendPluginResult:commandResult callbackId:callbackId];
}

void booleanSuccessCallback(NSString* callbackId, BOOL data) {
    CDVPluginResult* commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:data];
    commandResult.keepCallback = @1;
    [pluginCommandDelegate sendPluginResult:commandResult callbackId:callbackId];
}

void stringSuccessCallback(NSString* callbackId, NSString *data) {
    CDVPluginResult* commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:data];
    commandResult.keepCallback = @1;
    [pluginCommandDelegate sendPluginResult:commandResult callbackId:callbackId];
}

void subscriptionCallback(NSString* callbackId, NSString* data) {
    CDVPluginResult* commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:data];
    commandResult.keepCallback = @1;
    [pluginCommandDelegate sendPluginResult:commandResult callbackId:callbackId];
}

void failureCallback(NSString* callbackId, NSString* data) {
    CDVPluginResult* commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:data];
    commandResult.keepCallback = @1;
    [pluginCommandDelegate sendPluginResult:commandResult callbackId:callbackId];
}

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

NSString* stringifyNotificationOpenedResult(CPNotificationOpenedResult* result) {
    NSDictionary *notificationDictionary = dictionaryWithPropertiesOfObject(result.notification);
    NSDictionary *subscriptionDictionary = dictionaryWithPropertiesOfObject(result.subscription);

    NSMutableDictionary* obj = [NSMutableDictionary new];
    [obj setObject:notificationDictionary forKeyedSubscript:@"notification"];
    [obj setObject:subscriptionDictionary forKeyedSubscript:@"subscription"];
    [obj setObject:result.action forKeyedSubscript:@"action"];

    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&err];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

NSString* stringifyNotificationReceivedResult(CPNotificationReceivedResult* result) {
    NSDictionary *notificationDictionary = dictionaryWithPropertiesOfObject(result.notification);
    NSDictionary *subscriptionDictionary = dictionaryWithPropertiesOfObject(result.subscription);

    NSMutableDictionary* obj = [NSMutableDictionary new];
    [obj setObject:notificationDictionary forKeyedSubscript:@"notification"];
    [obj setObject:subscriptionDictionary forKeyedSubscript:@"subscription"];

    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&err];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

NSString* stringifyAppBannerAction(CPAppBannerAction* action) {
    NSDictionary *actionDictionary = dictionaryWithPropertiesOfObject(action);
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:actionDictionary options:0 error:&err];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

void processNotificationReceived(CPNotificationReceivedResult* result) {
    NSString* data = stringifyNotificationReceivedResult(result);
    NSError *jsonError;
    NSData *objectData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    if (!jsonError) {
        successCallback(notificationReceivedCallbackId, json);
    }
}

void processNotificationOpened(CPNotificationOpenedResult* result) {
    NSString* data = stringifyNotificationOpenedResult(result);
    NSError *jsonError;
    NSData *objectData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    if (!jsonError) {
        successCallback(notificationOpenedCallbackId, json);
        notificationOpenedResult = nil;
    }
}

void processAppBannerOpened(CPAppBannerAction* action) {
    NSString* data = stringifyAppBannerAction(action);
    NSError *jsonError;
    NSData *objectData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    if (!jsonError) {
        successCallback(appBannerOpenedCallbackId, json);
    }
}

void initCleverPushObject(NSDictionary* launchOptions, const char* channelId, BOOL autoRegister) {
    NSString* channelIdStr = (channelId ? [NSString stringWithUTF8String:channelId] : nil);
    
    [CleverPush
        initWithLaunchOptions:launchOptions
        channelId:channelIdStr
        handleNotificationReceived:^(CPNotificationReceivedResult* receivedResult) {
            if (pluginCommandDelegate && notificationReceivedCallbackId != nil) {
                processNotificationReceived(receivedResult);
            }
        }
        handleNotificationOpened:^(CPNotificationOpenedResult* openResult) {
            notificationOpenedResult = openResult;
            if (pluginCommandDelegate && notificationOpenedCallbackId != nil) {
                processNotificationOpened(openResult);
            }
        }
        handleSubscribed:^(NSString *subscriptionId) {
            if (pluginCommandDelegate && subscribedCallbackId != nil) {
                subscriptionCallback(subscribedCallbackId, subscriptionId);
            } else {
                pendingSubscribedResult = subscriptionId;
            }
        }
        autoRegister:autoRegister
    ];

    [CleverPush setAppBannerOpenedCallback:^(CPAppBannerAction *action) {
        if (pluginCommandDelegate && appBannerOpenedCallbackId != nil) {
            processAppBannerOpened(action);
        }
    }];
}


@implementation UIApplication(CleverPushCordovaPush)
    static void injectSelector(Class newClass, SEL newSel, Class addToClass, SEL makeLikeSel) {
        Method newMeth = class_getInstanceMethod(newClass, newSel);
        IMP imp = method_getImplementation(newMeth);
        const char* methodTypeEncoding = method_getTypeEncoding(newMeth);

        BOOL successful = class_addMethod(addToClass, makeLikeSel, imp, methodTypeEncoding);
        if (!successful) {
            class_addMethod(addToClass, newSel, imp, methodTypeEncoding);
            newMeth = class_getInstanceMethod(addToClass, newSel);

            Method orgMeth = class_getInstanceMethod(addToClass, makeLikeSel);

            method_exchangeImplementations(orgMeth, newMeth);
        }
    }

+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(setDelegate:)), class_getInstanceMethod(self, @selector(setCleverPushCordovaDelegate:)));
}

static Class delegateClass = nil;

- (void) setCleverPushCordovaDelegate:(id<UIApplicationDelegate>)delegate {
    if(delegateClass != nil)
    return;
    delegateClass = [delegate class];

    injectSelector(self.class, @selector(cleverPushApplication:didFinishLaunchingWithOptions:),
                  delegateClass, @selector(application:didFinishLaunchingWithOptions:));
    [self setCleverPushCordovaDelegate:delegate];
}

- (BOOL)cleverPushApplication:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    pendingLaunchOptions = launchOptions;
    
    if ([self respondsToSelector:@selector(cleverPushApplication:didFinishLaunchingWithOptions:)]) {
        return [self cleverPushApplication:application didFinishLaunchingWithOptions:launchOptions];
    }
    return YES;
}

@end


@implementation CleverPushPlugin

- (void)setNotificationReceivedHandler:(CDVInvokedUrlCommand*)command {
    notificationReceivedCallbackId = command.callbackId;
}

- (void)setNotificationOpenedHandler:(CDVInvokedUrlCommand*)command {
    notificationOpenedCallbackId = command.callbackId;
}

- (void)setSubscribedHandler:(CDVInvokedUrlCommand*)command {
    subscribedCallbackId = command.callbackId;
}

- (void)setAppBannerOpenedHandler:(CDVInvokedUrlCommand*)command {
    appBannerOpenedCallbackId = command.callbackId;
}

- (void)init:(CDVInvokedUrlCommand*)command {
    pluginCommandDelegate = self.commandDelegate;

    NSString* channelId = (NSString*)command.arguments[0];
    BOOL autoRegister = YES;
    if ([command.arguments count] > 1) {
        autoRegister = [(NSNumber*)command.arguments[1] boolValue];
    }

    initCleverPushObject(pendingLaunchOptions, [channelId UTF8String], autoRegister);

    if (pendingSubscribedResult) {
        subscriptionCallback(subscribedCallbackId, pendingSubscribedResult);
        pendingSubscribedResult = nil;
    }
    
    if (notificationOpenedResult) {
        processNotificationOpened(notificationOpenedResult);
    }
}

- (void)enableDevelopmentMode:(CDVInvokedUrlCommand*)command {
    [CleverPush enableDevelopmentMode];
}

- (void)showTopicsDialog:(CDVInvokedUrlCommand*)command {
    [CleverPush showTopicsDialog];
}

- (void)subscribe:(CDVInvokedUrlCommand*)command {
    [CleverPush subscribe:^(NSString* subscriptionId) {
      if (pluginCommandDelegate && command.callbackId != nil) {
          subscriptionCallback(command.callbackId, subscriptionId);
      }
  } failure:^(NSError* error) {
    if (pluginCommandDelegate && command.callbackId != nil) {
        failureCallback(command.callbackId, error.localizedDescription);
    }
  }];
}

- (void)unsubscribe:(CDVInvokedUrlCommand*)command {
    [CleverPush unsubscribe];
}

- (void)isSubscribed:(CDVInvokedUrlCommand*)command {
    BOOL isSubscribed = [CleverPush isSubscribed];
    booleanSuccessCallback(command.callbackId, isSubscribed);
}

- (void)getSubscriptionId:(CDVInvokedUrlCommand*)command {
    NSString *subscriptionId = [CleverPush getSubscriptionId];
    stringSuccessCallback(command.callbackId, subscriptionId);
}

@end
