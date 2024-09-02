// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RestoFlashPOS",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "RestoFlashPOS",
            targets: ["RestoFlashPOS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Flight-School/Money", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/xmartlabs/Eureka", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/saoudrizwan/Disk", .upToNextMajor(from: "0.6.4")),
        .package(url: "https://github.com/WeTransfer/Mocker", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/malcommac/SwiftDate", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/relatedcode/ProgressHUD", .upToNextMajor(from: "14.1.0")),
    ],
    targets: [
        .target(
            name: "RestoFlashPOS",
            dependencies: [
                .product(name: "Eureka", package: "Eureka"),
                .product(name: "Disk", package: "Disk"),
                .product(name: "Money", package: "Money"),
                .product(name: "SwiftDate", package: "SwiftDate"),
                .product(name: "ProgressHUD", package: "ProgressHUD"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "RestoFlashPOSTests",
            dependencies: [
                .target(name: "RestoFlashPOS"),
                .product(name: "Mocker", package: "Mocker"),
            ],
            path: "Tests"
        )
    ]
)
