// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FlashcardAutomation",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "FlashcardAutomation",
            targets: ["FlashcardAutomation"]),
    ],
    dependencies: [
        // Dependencies will be added here as we implement features
        .package(url: "https://github.com/facebook/facebook-business-sdk-swift", from: "21.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "FlashcardAutomation",
            dependencies: [
                .product(name: "FacebookBusinessSDK", package: "facebook-business-sdk-swift")
            ]),
        .testTarget(
            name: "FlashcardAutomationTests",
            dependencies: ["FlashcardAutomation"]),
    ]
)
