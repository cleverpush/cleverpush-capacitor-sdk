#import <UIKit/UIKit.h>
#import <Capacitor/CAPPlugin.h>
#import <Capacitor/CAPBridgedPlugin.h>

@class CAPPluginCall;

@interface CleverPushCapacitorPlugin : CAPPlugin <CAPBridgedPlugin>

@property (nonatomic, strong) CAPPluginCall *pluginCallDelegate;
@property (class, nonatomic, strong) NSDictionary *pendingLaunchOptions;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *jsName;

@end

