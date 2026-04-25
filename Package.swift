// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "HazakuraHabitat",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "HabitatCore", targets: ["HabitatCore"]),
        .executable(name: "habitat-scan", targets: ["habitat-scan"]),
    ],
    targets: [
        .target(
            name: "HabitatCore"
        ),
        .executableTarget(
            name: "habitat-scan",
            dependencies: ["HabitatCore"]
        ),
        .testTarget(
            name: "HabitatCoreTests",
            dependencies: ["HabitatCore"]
        ),
    ]
)
