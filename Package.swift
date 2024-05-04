// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreDataLayer",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "CoreDataLayer",
            targets: ["CoreDataLayer"]),
    ],
    targets: [
        .target(
            name: "CoreDataLayer"),
        .testTarget(
            name: "CoreDataLayerTests",
            dependencies: ["CoreDataLayer"]),
    ]
)
