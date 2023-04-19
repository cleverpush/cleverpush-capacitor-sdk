#import <UIKit/UIKit.h>
#import <Capacitor/CAPPlugin.h>
#import <Capacitor/CAPBridgedPlugin.h>

//! Project version number for Plugin.
FOUNDATION_EXPORT double PluginVersionNumber;

//! Project version string for Plugin.
FOUNDATION_EXPORT const unsigned char PluginVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Plugin/PublicHeader.h>


@class CAPPluginCall;

@interface CleverPushCapacitorPlugin : CAPPlugin <CAPBridgedPlugin>

@property (nonatomic, strong) CAPPluginCall *pluginCallDelegate;
@property (nonatomic, strong) NSDictionary *pendingLaunchOptions;

@end
