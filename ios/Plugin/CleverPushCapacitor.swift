import Foundation
import CleverPush
@objc public class CleverPushCapacitor: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    @objc public func subscribe(_ value: Bool) -> Bool {
        print(value)
        CleverPush.subscribe()
        CleverPush.
        return value
    }
    
}
