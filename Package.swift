// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CleverpushCapacitorSdk",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "CleverpushCapacitorSdk",
            targets: ["CleverpushCapacitorSdk"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0"),
        .package(url: "https://github.com/cleverpush/cleverpush-ios-sdk-spm.git", from: "1.34.52")
    ],
    targets: [
        .target(
            name: "CleverpushCapacitorSdk",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "CleverPush", package: "cleverpush-ios-sdk-spm")
            ],
            path: "ios/Plugin",
            exclude: ["Info.plist"],
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".")
            ]
        )
    ]
)
