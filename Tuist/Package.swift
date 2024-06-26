// swift-tools-version: 5.10
import PackageDescription

let appName = "WhatToDo"

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [
            "RxDataSources": .framework,
            "RxSwift": .framework,
            "RxCocoa": .framework,
            "RxRelay": .framework,
            "SQLite": .framework,
            "Alamofire": .framework
        ]
    )
#endif

let package = Package(
    name: appName,
    products: [
        .library(
            name: appName,
            targets: [appName]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "5.0.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.3")
    ],
    targets: [
        .target(
            name: appName,
            dependencies: [
                "RxDataSources",
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "SQLite", package: "SQLite.swift")
            ]
        )
    ]
)
