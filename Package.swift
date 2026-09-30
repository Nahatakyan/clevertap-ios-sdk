// swift-tools-version:5.5

import PackageDescription

// Source-based CleverTapSDK (fork). Based on upstream 7.1.1's source manifest;
// the Swift files added upstream after 7.1.1 live in the separate
// CleverTapSDKSwift target because SwiftPM targets cannot mix Swift and ObjC.
let swiftSources = [
    "Encryption/CTAESGCMCrypt.swift",
    "Encryption/NetworkEncryptionManager.swift",
    "InApps/CustomTemplates/SystemAppFunction/CTAppRatingHelper.swift"
]

let package = Package(
    name: "CleverTapSDK",
    platforms: [
        .iOS(.v15),
        .watchOS(.v2)
    ],
    products: [
        .library(
            name: "CleverTapSDK",
            targets: ["CleverTapSDK"]),
        .library(
            name: "CleverTapLocation",
            targets: ["CleverTapLocation"]
        ),
        .library(
            name: "CleverTapWatchOS",
            targets: ["CleverTapWatchOS"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.11.1")
    ],
    targets: [
        .target(
            name: "CleverTapSDKSwift",
            path: "CleverTapSDK",
            sources: swiftSources
        ),
        .target(
            name: "CleverTapSDK",
            dependencies: [
                "CleverTapSDKSwift",
                .product(name: "SDWebImage", package: "SDWebImage")
            ],
            path: "CleverTapSDK",
            exclude: [
                "Info.plist",
                "tvOS-Info.plist",
                "ios.modulemap",
                "tvos.modulemap"
            ] + swiftSources,
            resources: [
                .copy("AmazonRootCA1.cer"),
                .copy("PrivacyInfo.xcprivacy"),
                .process("InApps/resources"),
                .process("Inbox/resources")
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("./"),
                .headerSearchPath("DisplayUnit/"),
                .headerSearchPath("DisplayUnit/models"),
                .headerSearchPath("DisplayUnit/controllers"),
                .headerSearchPath("FeatureFlags/"),
                .headerSearchPath("FeatureFlags/models"),
                .headerSearchPath("FeatureFlags/controllers"),
                .headerSearchPath("ProductConfig/"),
                .headerSearchPath("ProductConfig/models"),
                .headerSearchPath("ProductConfig/controllers"),
                .headerSearchPath("InApps/"),
                .headerSearchPath("InApps/Matchers/"),
                .headerSearchPath("InApps/CustomTemplates/"),
                .headerSearchPath("InApps/CustomTemplates/SystemAppFunction/"),
                .headerSearchPath("Inbox/"),
                .headerSearchPath("Inbox/cells"),
                .headerSearchPath("Inbox/config"),
                .headerSearchPath("Inbox/controllers"),
                .headerSearchPath("Inbox/models"),
                .headerSearchPath("Inbox/views"),
                .headerSearchPath("ProductExperiences/"),
                .headerSearchPath("Session/"),
                .headerSearchPath("Swizzling/"),
                .headerSearchPath("FileDownload/"),
                .headerSearchPath("EventDatabase/"),
                .headerSearchPath("Encryption/")
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("AVKit"),
                .linkedFramework("CoreData"),
                .linkedFramework("CoreServices"),
                .linkedFramework("CoreTelephony", .when(platforms: [.iOS])),
                .linkedFramework("ImageIO"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("Security"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("UserNotifications"),
                .linkedFramework("WebKit"),
                .linkedLibrary("sqlite3")
            ]
        ),
        .target(
            name: "CleverTapLocation",
            path: "CleverTapLocation",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("./"),
                .headerSearchPath("CleverTapLocation/"),
                .headerSearchPath("CleverTapLocation/Classes/"),
                .headerSearchPath("CleverTapLocation/Classes")
            ],
            linkerSettings: [
                .linkedFramework("CoreLocation")
            ]
        ),
        .target(
            name: "CleverTapWatchOS",
            dependencies: [],
            path: "CleverTapWatchOS",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("./"),
                .headerSearchPath("CleverTapWatchOS/")
            ]
        )
    ]
)
