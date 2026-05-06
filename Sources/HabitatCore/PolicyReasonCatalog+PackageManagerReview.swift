extension PolicyReasonCatalog {
    static func packageManagerMutationReviewCommands(for packageManager: String) -> [String] {
        switch packageManager {
        case "npm":
            return npmDependencyMutationCommands
        case "pnpm":
            return pnpmDependencyMutationCommands
        case "yarn":
            return yarnDependencyMutationCommands
        case "bun":
            return bunDependencyMutationCommands
        case "uv":
            return uvDependencyMutationCommands
        case "python":
            return pipDependencyMutationCommands
        case "bundler":
            return rubyBundlerDependencyMutationCommands
        case "homebrew":
            return homebrewPackageManagerReviewCommands
        case "swiftpm":
            return swiftPackageDependencyResolutionCommands
        case "go":
            return goDependencyMutationCommands
        case "cargo":
            return cargoDependencyMutationCommands
        case "cocoapods":
            return cocoapodsDependencyMutationCommands
        case "carthage":
            return carthageDependencyMutationCommands
        case "xcodebuild":
            return xcodebuildProjectMutationCommands
        default:
            return []
        }
    }
}
