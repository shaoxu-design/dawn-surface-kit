// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DawnSurfaceKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "DawnSurfaceKit",
            targets: ["DawnSurfaceKit"]
        ),
        .library(
            name: "DawnSurfaceTCA",
            targets: ["DawnSurfaceTCA"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.26.0"),
    ],
    targets: [
        .target(
            name: "DawnSurfaceKit",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .target(
            name: "DawnSurfaceTCA",
            dependencies: [
                "DawnSurfaceKit",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .testTarget(
            name: "DawnSurfaceKitTests",
            dependencies: ["DawnSurfaceKit"]
        ),
        .testTarget(
            name: "DawnSurfaceTCATests",
            dependencies: [
                "DawnSurfaceTCA",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
)
