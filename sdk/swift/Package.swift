// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "LlmPetKit",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "LlmPetKit", targets: ["LlmPetKit"])
    ],
    targets: [
        .target(name: "LlmPetKit")
    ]
)
