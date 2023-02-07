import Foundation

@objc public class CleverPushPlugin: NSObject {
    
    @objc public func getSubscriptionId(_ value: String) -> String {
        print(value)
        return value
    }
    
    @objc public func isSubscribed(_ value: Bool) -> Bool {
        print(value)
        return value
    }
    
    @objc public func unsubscribe () {}
    
    @objc public func subscribe () {}
    
    @objc public func enableDevelopmentMode() {}
    
    @objc public func initCleverPush() {}
    
    @objc public func showTopicsDialog() {}
    
}
