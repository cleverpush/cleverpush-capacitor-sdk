## 1.4.0 (16.07.2025)
* Updated to Capacitor 7.4.2 (from 6.0.0)
* Updated native iOS + Android SDKs

## 1.3.20 (04.04.2025)
* Updated native iOS + Android SDKs
* Resolved an issue where `notificationReceived` was not working when reopening the app from a killed or background state.

## 1.3.19 (24.02.2025)
* Updated native iOS + Android SDKs
* Resolved an issue in `getSubscriptionTopics` and `getAvailableTopics` where topics were not received correctly.

## 1.3.18 (19.09.2024)
* Updated native iOS + Android SDKs

## 1.3.17 (30.08.2024)
* Resolved issue of CleverPush plugin is not implemented on ios updating capacitor from 5 to 6
* Add missing import to CleverPushCapacitorPlugin.java
* Updated native iOS + Android SDKs

## 1.3.16 (24.07.2024)
* Updated native iOS + Android SDKs
* If the CleverPush plugin is not registered, the `init` method will automatically register it.

## 1.3.15 (29.05.2024)
* Updated native iOS + Android SDKs

## 1.3.14 (27.05.2024)
* Migrate plugin to capacitor v6
* Updated native iOS + Android SDKs

## 1.3.13 (01.05.2024)
* Updated native iOS + Android SDKs

## 1.3.12 (05.03.2024)
* Updated native iOS + Android SDKs

## 1.3.11
* Fixed build issue on Android

## 1.3.10
* Fixed return values in TS definition

## 1.3.9
* Optimized resolving of promises in various SDK methods
* Updated native iOS + Android SDKs

## 1.3.8
* Optimized `setAuthorizerToken` method

## 1.3.7
* Added `setShowNotificationsInForeground` method

## 1.3.6
* Fixed timezone for `createdAt` fields on Android

## 1.3.5
* Renamed `id` field to `_id` for Notifications in iOS
* Consistent date formats for `createdAt` field (ISO 8601)

## 1.3.4
* Added attribute methods

## 1.3.3
* Hotfix for Capacitor 5 on iOS

## 1.3.2
* Fixed return type for `subscribe` method

## 1.3.1
* Hotfix for iOS with Capacitor >= 5

## 1.3.0
* Added `getNotifications` method

## 1.2.6
* Added support for Capacitor version 5.2.2+

## 1.2.5
* Updated native iOS & Android SDKs

## 1.2.4
* Fixed `notificationOpened` event for Android cold boots (when init is delayed)

## 1.2.3
* Fixed `notificationOpened` event for iOS cold boots

## 1.2.2
* Added `setAuthorizerToken` method

## 1.2.1
* Added `trackEvent` method

## 1.2.0
* Added new methods

## 1.1.3
* Fixed crash when calling `unsubscribe()` on Android
     
## 1.1.2
* Updated native iOS & Android SDKs

## 1.1.1
* Updated native iOS & Android SDKs

## 1.1.0
* Fixed various bugs
* Breaking change: `initCleverPush` renamed to `init`

## 1.0.0
* Initial release
