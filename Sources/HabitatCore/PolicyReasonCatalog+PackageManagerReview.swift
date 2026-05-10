extension PolicyReasonCatalog {
    struct PackageManagerReviewRoute: Sendable {
        let packageManager: String
        let commands: [String]
    }

    static let packageManagerMutationReviewRoutes: [PackageManagerReviewRoute] = [
        .init(packageManager: "npm", commands: npmDependencyMutationCommands),
        .init(packageManager: "pnpm", commands: pnpmDependencyMutationCommands),
        .init(packageManager: "yarn", commands: yarnDependencyMutationCommands),
        .init(packageManager: "bun", commands: bunDependencyMutationCommands),
        .init(packageManager: "uv", commands: uvDependencyMutationCommands),
        .init(packageManager: "python", commands: pipDependencyMutationCommands),
        .init(packageManager: "bundler", commands: rubyBundlerDependencyMutationCommands),
        .init(packageManager: "homebrew", commands: homebrewPackageManagerReviewCommands),
        .init(packageManager: "swiftpm", commands: swiftPackageDependencyResolutionCommands),
        .init(packageManager: "go", commands: goDependencyMutationCommands),
        .init(packageManager: "cargo", commands: cargoDependencyMutationCommands),
        .init(packageManager: "cocoapods", commands: cocoapodsPackageManagerReviewCommands),
        .init(packageManager: "carthage", commands: carthageDependencyMutationCommands),
        .init(packageManager: "xcodebuild", commands: xcodebuildProjectMutationCommands),
    ]

    static func packageManagerMutationReviewCommands(for packageManager: String) -> [String] {
        packageManagerMutationReviewRoutes.first {
            $0.packageManager == packageManager
        }?.commands ?? []
    }
}
