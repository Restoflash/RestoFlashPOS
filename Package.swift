// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RestoFlashPOS",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "RestoFlashPOS",
            targets: ["RestoFlashPOS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/Flight-School/Money", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/BeauNouvelle/SimpleCheckbox", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/xmartlabs/Eureka", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/saoudrizwan/Disk", .upToNextMajor(from: "0.6.4")),
        .package(url: "https://github.com/melvitax/DateHelper", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/WeTransfer/Mocker", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/pkluz/PKHUD.git", .upToNextMinor(from: "5.4.0")),
    ],
    targets: [
        .target(
            name: "RestoFlashPOS",
            dependencies: [
                "SimpleCheckbox",
                "Eureka",
                "Mocker",
                "Disk",
                "DateHelper",
                "Money",
                "Alamofire",
                "PKHUD"
            ]
        ),
    ]
)
