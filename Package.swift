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
        .executable(name: "LogbotCapture", targets: ["LogbotCaptureApp"]),
        .executable(name: "LogbotControl", targets: ["LogbotControlApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
    ],
    targets: [
        // Core Framework
        .target(
            name: "LogbotCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        
        // iOS Capture App
        .target(
            name: "LogbotCapture",
            dependencies: [
                "LogbotCore"
            ]
        ),
        .executableTarget(
            name: "LogbotCaptureApp",
            dependencies: ["LogbotCapture"]
        ),
        
        // macOS Control App
        .target(
            name: "LogbotControl",
            dependencies: [
                "LogbotCore"
            ]
        ),
        .executableTarget(
            name: "LogbotControlApp",
            dependencies: ["LogbotControl"]
        )
    ]
) 