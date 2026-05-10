extension PolicyReasonCatalog {
    private static let cocoapodsDependencyMutationCommandFamily = CommandFamily([
        "pod install",
        "pod update",
        "pod repo update",
    ])
    static let cocoapodsDependencyMutationCommands = cocoapodsDependencyMutationCommandFamily.commands

    private static let cocoapodsProjectMutationCommandFamily = CommandFamily([
        "pod deintegrate",
    ])
    static let cocoapodsProjectMutationCommands = cocoapodsProjectMutationCommandFamily.commands

    static let cocoapodsPackageManagerReviewCommands = cocoapodsDependencyMutationCommands
        + cocoapodsProjectMutationCommands

    private static let carthageDependencyMutationCommandFamily = CommandFamily([
        "carthage bootstrap",
        "carthage update",
        "carthage checkout",
    ])
    static let carthageDependencyMutationCommands = carthageDependencyMutationCommandFamily.commands

    private static let carthageBuildArtifactMutationCommandFamily = CommandFamily([
        "carthage build",
    ])
    static let carthageBuildArtifactMutationCommands = carthageBuildArtifactMutationCommandFamily.commands

    private static let xcodebuildProjectMutationCommandFamily = CommandFamily([
        "xcodebuild build/test/archive before selecting a scheme",
        "xcodebuild -resolvePackageDependencies",
        "xcodebuild -allowProvisioningUpdates",
    ])
    static let xcodebuildProjectMutationCommands = xcodebuildProjectMutationCommandFamily.commands

    static func isCarthageBuildArtifactMutationCommand(_ command: String) -> Bool {
        carthageBuildArtifactMutationCommandFamily.contains(command)
    }
}
