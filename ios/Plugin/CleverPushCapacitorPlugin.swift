import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CleverPushCapacitorPlugin)
public class CleverPushCapacitorPlugin: CAPPlugin {
    private let implementation = CleverPushCapacitor()

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
    
    @objc func subscribe(_ call: CAPPluginCall) {
        let value = call.getBool("value") ?? false
        call.resolve([
            "value": implementation.subscribe(value)
        ])
    }
    
}
