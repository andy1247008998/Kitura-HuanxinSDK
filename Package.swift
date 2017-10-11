// swift-tools-version:3.1

import PackageDescription

let package = Package(
        name: "Kitura-HuanxinSDK",
        dependencies: [
            .Package(url: "https://github.com/IBM-Swift/Kitura-Request.git", majorVersion: 0),
            .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 17),
        ]
)
