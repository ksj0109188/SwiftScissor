// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftScissor",
    platforms: [
        .iOS(.v17),
    ],
  products: [
        .library(
            name: "SwiftScissor",
            targets: ["SwiftScissor"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftScissor",
            path: "Sources/Core"),
    ]
)
