#import <UIKit/UIKit.h>

//! Project version number for Plugin.
FOUNDATION_EXPORT double PluginVersionNumber;

//! Project version string for Plugin.
FOUNDATION_EXPORT const unsigned char PluginVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Plugin/PublicHeader.h>

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>

@interface CleverPushPlugin : CDVPlugin {}

- (void)setNotificationOpenedHandler:(CDVInvokedUrlCommand*)command;
- (void)setNotificationReceivedHandler:(CDVInvokedUrlCommand*)command;
- (void)setSubscribedHandler:(CDVInvokedUrlCommand*)command;
- (void)setAppBannerOpenedHandler:(CDVInvokedUrlCommand*)command;
- (void)init:(CDVInvokedUrlCommand*)command;
- (void)enableDevelopmentMode:(CDVInvokedUrlCommand*)command;
- (void)showTopicsDialog:(CDVInvokedUrlCommand*)command;
- (void)subscribe:(CDVInvokedUrlCommand*)command;
- (void)unsubscribe:(CDVInvokedUrlCommand*)command;
- (void)isSubscribed:(CDVInvokedUrlCommand*)command;
- (void)getSubscriptionId:(CDVInvokedUrlCommand*)command;

@end
