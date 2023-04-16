// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "iCalParser",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "iCalParser",
            targets: ["iCalParser"]),
    ],
    targets: [
        .target(
            name: "iCalParser",
            dependencies: []),
        .testTarget(
            name: "iCalParserTests",
            dependencies: ["iCalParser"]),
    ]
)
