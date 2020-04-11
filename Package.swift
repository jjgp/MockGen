// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwiftMocked",
    products: [
        .library(
            name: "SwiftMocked",
            targets: ["SwiftMocked"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.0.1")),
    ],
    targets: [
        .target(
            name: "SwiftMocked",
            dependencies: []),
        .testTarget(
            name: "SwiftMockedTests",
            dependencies: ["Nimble", "SwiftMocked"]),
    ]
)
