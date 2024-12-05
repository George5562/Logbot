// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Logbot",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "LogbotCore", targets: ["LogbotCore"]),
        .library(name: "LogbotCapture", targets: ["LogbotCapture"]),
        .library(name: "LogbotControl", targets: ["LogbotControl"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/NextLevel/NextLevel.git", from: "0.16.3")
    ],
    targets: [
        // Core Framework
        .target(
            name: "LogbotCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/LogbotCore"
        ),
        .testTarget(
            name: "LogbotCoreTests",
            dependencies: ["LogbotCore"],
            path: "Tests/LogbotCore"
        ),
        
        // iOS Capture App
        .target(
            name: "LogbotCapture",
            dependencies: [
                "LogbotCore",
                "NextLevel"
            ],
            path: "Sources/LogbotCapture"
        ),
        .testTarget(
            name: "LogbotCaptureTests",
            dependencies: ["LogbotCapture"],
            path: "Tests/LogbotCapture"
        ),
        
        // macOS Control App
        .target(
            name: "LogbotControl",
            dependencies: [
                "LogbotCore"
            ],
            path: "Sources/LogbotControl"
        ),
        .testTarget(
            name: "LogbotControlTests",
            dependencies: ["LogbotControl"],
            path: "Tests/LogbotControl"
        )
    ]
) 