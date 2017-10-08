// swift-tools-version:3.1

import PackageDescription

let package = Package(
        name: "Kitura-HuanxinSDK",
        dependencies: [
            .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 7),
            .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 7),
            .Package(url: "https://github.com/IBM-Swift/Swift-Kuery.git", majorVersion: 0),
            .Package(url: "https://github.com/IBM-Swift/Kitura-Request.git", majorVersion: 0),
            .Package(url: "https://github.com/IBM-Swift/SwiftKueryMySQL.git", majorVersion: 0)
        ]
)
