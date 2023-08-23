#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Capacitor/CAPPlugin.h>
#import <Capacitor/CAPBridgedPlugin.h>

@interface CleverPushCapacitorPlugin : CAPPlugin <CAPBridgedPlugin>

@property (nonatomic, strong) CAPPluginCall *pluginCallDelegate;
@property (class, nonatomic, strong) NSDictionary *pendingLaunchOptions;

@end


@implementation UIApplication(CleverPushCapacitorPlugin)

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
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(setDelegate:)), class_getInstanceMethod(self, @selector(setCleverPushCapacitorDelegate:)));
    });
}

- (void)setCleverPushCapacitorDelegate:(id<UIApplicationDelegate>)delegate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class delegateClass = [delegate class];

        injectSelector(self.class, @selector(cleverPushApplication:didFinishLaunchingWithOptions:),
                       delegateClass, @selector(application:didFinishLaunchingWithOptions:));
        [self setCleverPushCapacitorDelegate:delegate];
    });
}

- (BOOL)cleverPushApplication:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    if (launchOptions != nil) {
        CleverPushCapacitorPlugin.pendingLaunchOptions = launchOptions;
    }

    if ([self respondsToSelector:@selector(cleverPushApplication:didFinishLaunchingWithOptions:)]) {
      return [self cleverPushApplication:application didFinishLaunchingWithOptions:launchOptions];
    }
    return YES;
}

@end
