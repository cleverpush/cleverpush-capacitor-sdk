import Foundation
import Capacitor
import CleverPush

@objc(CleverPushCapacitorPlugin)
public class CleverPushCapacitorPlugin: CAPPlugin {

    var pluginCallDelegate: CAPPluginCall? = CAPPluginCall()
    let pendingLaunchOptions: [AnyHashable: Any]? = nil

    func initCleverPushObject(launchOptions: NSDictionary!, channelId: String, autoRegister: Bool) {
        DispatchQueue.main.async {
            CleverPush.initWithLaunchOptions(launchOptions as? [AnyHashable: Any], channelId: channelId, handleNotificationReceived: { receivedResult in
                if(self.pluginCallDelegate != nil) {
                    let notificationDictionary = self.dictionaryWithProperties(of: (receivedResult?.notification)!)
                    let subscriptionDictionary = self.dictionaryWithProperties(of: (receivedResult?.subscription)!)

                    var obj: [String: Any] = [:]
                    obj["notification"] = notificationDictionary
                    obj["subscription"] = subscriptionDictionary

                    self.notifyListeners("notificationReceived", data: obj)
                }
            }, handleNotificationOpened: { openResult in
                if(self.pluginCallDelegate != nil && openResult != nil) {
                    let notificationDictionary = self.dictionaryWithProperties(of: (openResult?.notification)!)
                    let subscriptionDictionary = self.dictionaryWithProperties(of: (openResult?.subscription)!)

                    var obj: [String: Any] = [:]
                    obj["notification"] = notificationDictionary
                    obj["subscription"] = subscriptionDictionary

                    if let action = openResult?.action {
                        obj["action"] = action
                    }

                    self.notifyListeners("notificationOpened", data: obj)
                }
            }, handleSubscribed: { subscriptionId in
                var obj = [String: Any]()
                obj["subscriptionId"] = subscriptionId
                self.notifyListeners("subscribed", data: obj)

            }, autoRegister: autoRegister)
            CleverPush.setAppBannerOpenedCallback { action in
                if(self.pluginCallDelegate != nil && action != nil) {
                    let actionObject = self.dictionaryWithProperties(of: action! )
                    self.notifyListeners("appBannerOpened", data: actionObject)

                }
            }
        }
    }

    @objc func getSubscriptionId(_ call: CAPPluginCall) {
        let value = CleverPush.getSubscriptionId()
        call.resolve([
            "subscriptionId": value ?? ""
        ])
    }

    @objc func trackPageView(_ call: CAPPluginCall) {
        let url = call.getString("url") ?? ""
        CleverPush.trackPageView(url)
    }

    @objc func trackEvent(_ call: CAPPluginCall) {
        let eventName = call.getString("eventName") ?? ""
        let properties = call.getObject("properties") ?? [:]

        if !properties.isEmpty {
            CleverPush.trackEvent(eventName, properties: properties)
        } else {
            CleverPush.trackEvent(eventName)
        }

        call.resolve()
    }

    @objc func addSubscriptionTag(_ call: CAPPluginCall) {
        if let tagId = call.options["tagId"] as? String {
            CleverPush.addSubscriptionTag(tagId)
            call.resolve()
        }
    }

    @objc func removeSubscriptionTag(_ call: CAPPluginCall) {
        if let tagId = call.getString("tagId") {
            CleverPush.removeSubscriptionTag(tagId)
        }
    }

    @objc func hasSubscriptionTag(_ call: CAPPluginCall) {
        let tagId = call.options?["tagId"] as? String ?? ""
        let hasTag = CleverPush.hasSubscriptionTag(tagId)
        call.resolve(["hasTag": hasTag])
    }

    @objc func getSubscriptionTags(_ call: CAPPluginCall) {
        if let tagIds = CleverPush.getSubscriptionTags() {
            call.resolve(["tagId": tagIds])
        }
    }

    @objc func getSubscriptionTopics(_ call: CAPPluginCall) {
        if let topicIds = CleverPush.getSubscriptionTopics() {
            call.resolve(["topicIds": topicIds])
        }
    }

    @objc func setSubscriptionTopics(_ call: CAPPluginCall) {
        if let topics = call.options["topics"] as? [String] {
            let topicsArray = NSMutableArray(array: topics)
            CleverPush.setSubscriptionTopics(topicsArray)
        }
    }

    @objc func getAvailableTopics(_ call: CAPPluginCall) {
        CleverPush.getAvailableTopics { topicsArray in
            if let notifications = topicsArray {
                var notificationsArray: [[String: Any]] = []
                for notification in notifications {
                    if let notificationDictionary = self.dictionaryWithProperties(of: notification) {
                        notificationsArray.append(notificationDictionary)
                    }
                }
                call.resolve(["notifications": notificationsArray])
            }
        }
    }

    @objc func isSubscribed(_ call: CAPPluginCall) {
        let value = CleverPush.isSubscribed()
        call.resolve(["isSubscribed": value])
    }

    @objc func unsubscribe(_ call: CAPPluginCall) {
        CleverPush.unsubscribe()
        call.resolve()
    }

    @objc func subscribe(_ call: CAPPluginCall) {
        CleverPush.subscribe({ subscriptionId in
            if self.pluginCallDelegate != nil && (call.callbackId != nil ) {
                call.resolve(["subscriptionId": subscriptionId ?? ""])
            }
        }, failure: { error in
            if self.pluginCallDelegate != nil && (call.callbackId != nil ) {
                call.reject(error!.localizedDescription, nil, nil, nil)
            }
        })
    }

    @objc func showTopicsDialog(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            CleverPush.showTopicsDialog()
        }
    }

    @objc func enableDevelopmentMode(_ call: CAPPluginCall) {
        CleverPush.enableDevelopmentMode()
        call.resolve()
    }

    @objc func setAuthorizerToken(_ call: CAPPluginCall) {
        let token = call.options?["token"] as? String ?? ""
        CleverPush.setAuthorizerToken(token)
        call.resolve()
    }

    @objc func getNotifications(_ call: CAPPluginCall) {
        if let notifications = CleverPush.getNotifications() {
            var notificationsArray: [[String: Any]] = []
            for notification in notifications {
                if let notificationDictionary = dictionaryWithProperties(of: notification) {
                    notificationsArray.append(notificationDictionary)
                }
            }
            call.resolve(["notifications": notificationsArray])
        }
    }

    func dictionaryWithProperties(of object: NSObject) -> [String: Any]? {
        var count: UInt32 = 0
        let properties = class_copyPropertyList(object.classForCoder, &count)
        var dictionary: [String: Any] = [:]

        for i in 0..<Int(count) {
            let property = properties![i]
            let propertyName = String(cString: property_getName(property))

            if let value = object.value(forKey: propertyName) {
                dictionary[propertyName] = value
            }
        }

        free(properties)
        return dictionary.isEmpty ? nil : dictionary
    }

    @objc func `init`(_ call: CAPPluginCall) {
        pluginCallDelegate = call
        let channelId = call.getString("channelId") ?? ""
        let autoRegister = call.getBool("autoRegister") ?? true
        initCleverPushObject(launchOptions: pendingLaunchOptions as NSDictionary?, channelId: channelId, autoRegister: autoRegister)
    }

    @objc public class func jsName() -> String {
        return "CleverPush"
    }

    @objc public class func identifier() -> String {
        return "CleverPushCapacitorPlugin"
    }

    @objc public class func pluginId() -> String {
        return "CleverPushCapacitorPlugin"
    }

}
