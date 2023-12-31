// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlertLayer",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AlertLayer",
            targets: ["AlertLayer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pxlshpr/SwiftSugar", from: "0.0.97")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AlertLayer",
            dependencies: [
                .product(name: "SwiftSugar", package: "SwiftSugar"),
            ]
        ),
        .testTarget(
            name: "AlertLayerTests",
            dependencies: ["AlertLayer"]),
    ]
)
