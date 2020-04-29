// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwiftMocked",
    products: [
        .executable(name: "swiftmockedcli", targets: ["swiftmockedcli"]),
        .library(
            name: "SwiftMocked",
            targets: ["SwiftMocked"])
    ],
    dependencies: [
        .package(url: "https://github.com/Carthage/Commandant.git", .upToNextMinor(from: "0.17.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMinor(from: "8.0.1")),
        .package(url: "https://github.com/jpsim/SourceKitten.git", .upToNextMinor(from: "0.29.0"))
    ],
    targets: [
        .target(
            name: "swiftmockedcli",
            dependencies: ["Commandant", "SwiftMockedCLIFramework"]),
        .target(
            name: "SwiftMocked",
            dependencies: []),
        .target(
            name: "SwiftMockedCLIFramework",
            dependencies: ["Commandant", "SourceKittenFramework"]),
        .testTarget(
            name: "SwiftMockedTests",
            dependencies: ["Nimble", "SwiftMocked"])
    ]
)
