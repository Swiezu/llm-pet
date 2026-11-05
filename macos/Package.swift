// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "llm-pet",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "llm-pet", targets: ["LlmPet"]),
        .library(name: "LlmPetRender", targets: ["LlmPetRender"])
    ],
    targets: [
        .target(name: "LlmPetRender", path: "Sources/LlmPetRender"),
        .executableTarget(name: "LlmPet", dependencies: ["LlmPetRender"], path: "Sources/LlmPet")
    ]
)
