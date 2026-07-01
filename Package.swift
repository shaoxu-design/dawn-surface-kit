// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DawnSheetKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "DawnSheetKit",
            targets: ["DawnSheetKit"]
        ),
    ],
    targets: [
        .target(
            name: "DawnSheetKit",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .testTarget(
            name: "DawnSheetKitTests",
            dependencies: ["DawnSheetKit"]
        ),
    ]
)
