// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "llm-pet",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "llm-pet", targets: ["LlmPet"])
    ],
    targets: [
        .executableTarget(name: "LlmPet", path: "Sources/LlmPet")
    ]
)
