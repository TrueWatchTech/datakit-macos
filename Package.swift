// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FTMacOSSDK",
    platforms: [.macOS(.v10_13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FTMacOSSDK",
            targets: ["FTMacOSSDK"]),
    ],
    dependencies: [
        .package(name: "FTMobileSDK", url: "https://github.com/TrueWatchTech/datakit-ios.git", revision:"1.4.9-alpha.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FTMacOSSDK",
            dependencies: [
                .product(name: "FTSDKCore", package: "FTMobileSDK"),
            ],
            path: "FTMacOSSDK",
            cSettings: [
                .headerSearchPath("SDKCore"),
                .headerSearchPath("SDKCore/AutoTrack"),
            ]
        )

    ])
