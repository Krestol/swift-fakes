// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-fakes",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .visionOS(.v1)
    ],
    products: [
        .library(
            name: "Fakes",
            targets: ["Fakes"]
        ),
    ],
    dependencies: [
        .package(url:  "https://github.com/Krestol/Nimble.git", from: "13.3.1"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Fakes",
            dependencies: ["Nimble"],
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "FakesTests",
            dependencies: ["Fakes", "Nimble"],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
    ]
)
