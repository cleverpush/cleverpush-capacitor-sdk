import Foundation
import Capacitor
import CleverPush

@objc(CleverPushCapacitorPlugin)
public class CleverPushCapacitorPlugin: CAPPlugin {
    
    private let implementation = CleverPushPlugin()
    var pluginCallDelegate: CAPPluginCall? = CAPPluginCall()
    let pendingLaunchOptions: [AnyHashable: Any]? = nil
    var responseObject: [String: Any]? = [String: Any]()
    
    func initCleverPushObject(launchOptions: NSDictionary!, channelId: String, autoRegister: Bool) {
        DispatchQueue.main.async {
            CleverPush.initWithLaunchOptions(launchOptions as? [AnyHashable: Any], channelId: channelId, handleNotificationReceived: { receivedResult in
                if(self.pluginCallDelegate != nil) {
                    if let parameters = receivedResult?.payload as? [String: Any] {
                        self.responseObject =  ["success": true, "data": parameters]
                        self.notifyListeners("notificationReceivedListener", data: self.responseObject)
                    } else {
                        self.responseObject =  ["success": false, "error": "something went wrong"]
                        self.notifyListeners("notificationReceivedListener", data: self.responseObject)
                    }
                }
            }, handleNotificationOpened: { openResult in
                if(self.pluginCallDelegate != nil && openResult != nil) {
                    if let parameters = openResult?.payload as? [String: Any] {
                        self.responseObject =  ["success": true, "data": parameters]
                        self.notifyListeners("notificationOpenedListener", data: self.responseObject)
                    } else {
                        self.responseObject =  ["success": false, "error": "something went wrong"]
                        self.notifyListeners("notificationOpenedListener", data: self.responseObject)
                    }
                }
            }, handleSubscribed: { subscriptionId in
                if subscriptionId == "" || subscriptionId == nil {
                    self.responseObject =  ["success": false, "error": "subscriptionId not found"]
                    self.notifyListeners("subscribedListener", data: self.responseObject)
                } else {
                    self.responseObject =  ["success": true, "data": subscriptionId!]
                    self.notifyListeners("subscribedListener", data: self.responseObject)
                }
            }, autoRegister: autoRegister)
            CleverPush.setAppBannerOpenedCallback { action in
                if(self.pluginCallDelegate != nil && action != nil) {
                    var actionObject = [String: Any]()
                    if action?.name != nil {
                        if action?.url != nil {
                            actionObject["url"] = action!.url
                        }
                        if action?.urlType != nil {
                            actionObject["urlType"] = action?.urlType
                        }
                        if action?.name != nil {
                            actionObject["name"] =  action?.name
                        }
                        if action?.type != nil {
                            actionObject["type"] =  action?.type
                        }
                        if action?.screen != nil {
                            actionObject["screen"] =  action?.screen
                        }
                        if action?.tags != nil {
                            actionObject["tags"] =  action?.tags
                        }
                        if action?.topics != nil {
                            actionObject["topics"] =  action?.topics
                        }
                        if action?.attributeId != nil {
                            actionObject["attributeId"] =  action?.attributeId
                        }
                        if action?.attributeValue != nil {
                            actionObject["attributeValue"] =  action?.attributeValue
                        }
                        if action?.dismiss != nil {
                            actionObject["dismiss"] =  action?.dismiss
                        }
                        if action?.openInWebview != nil {
                            actionObject["openInWebview"] =  action?.openInWebview
                        }
                        if action?.openBySystem != nil {
                            actionObject["openBySystem"] =  action?.openBySystem
                        }
                        self.responseObject =  ["success": true, "data": actionObject]
                        self.notifyListeners("appBannerOpenedListener", data: self.responseObject)
                    } else {
                        self.responseObject =  ["success": false, "error": "something went wrong"]
                        self.notifyListeners("appBannerOpenedListener", data: self.responseObject)
                    }
                }
            }
        }
    }
    
    @objc func getSubscriptionId(_ call: CAPPluginCall) {
        let value = CleverPush.getSubscriptionId()
        call.resolve([
            "value": implementation.getSubscriptionId(value ?? "")
        ])
    }
    
    @objc func isSubscribed(_ call: CAPPluginCall) {
        let value = CleverPush.isSubscribed()
        call.resolve([
            "value": implementation.isSubscribed(value)])
    }
    
    @objc func unsubscribe() {
        CleverPush.unsubscribe()
    }
    
    @objc func subscribe(_ call: CAPPluginCall) {
        var responseObject: [String: Any]? = [String: Any]()
        CleverPush.subscribe({ subscriptionId in
            if (self.pluginCallDelegate != nil) && call.callbackId != nil {
                responseObject =  ["success": true, "data": subscriptionId!]
                self.notifyListeners("subscribedListener", data: responseObject)
            }
        }, failure: { error in
            if (self.pluginCallDelegate != nil) && call.callbackId != nil {
                responseObject =  ["success": false, "error": error?.localizedDescription ?? ""]
                self.notifyListeners("subscribedListener", data: responseObject)
            }
        })
    }
    
    @objc func showTopicsDialog(_ call: CAPPluginCall) {
        CleverPush.showTopicsDialog()
    }
    
    @objc func enableDevelopmentMode(_ call: CAPPluginCall) {
        CleverPush.enableDevelopmentMode()
    }
    
    @objc func initCleverPush(_ call: CAPPluginCall) {
        pluginCallDelegate = call
        let channelId = call.getString("channelId") ?? ""
        let autoRegister = call.getBool("autoRegister") ?? true
        initCleverPushObject(launchOptions: pendingLaunchOptions as NSDictionary?, channelId: channelId, autoRegister: autoRegister)
    }
}

