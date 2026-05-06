extension PolicyReasonCatalog {
    private static let cocoapodsDependencyMutationCommandFamily = CommandFamily([
        "pod install",
        "pod update",
        "pod repo update",
        "pod deintegrate",
    ])
    static let cocoapodsDependencyMutationCommands = cocoapodsDependencyMutationCommandFamily.commands

    private static let carthageDependencyMutationCommandFamily = CommandFamily([
        "carthage bootstrap",
        "carthage update",
        "carthage checkout",
        "carthage build",
    ])
    static let carthageDependencyMutationCommands = carthageDependencyMutationCommandFamily.commands

    private static let xcodebuildProjectMutationCommandFamily = CommandFamily([
        "xcodebuild build/test/archive before selecting a scheme",
        "xcodebuild -resolvePackageDependencies",
        "xcodebuild -allowProvisioningUpdates",
    ])
    static let xcodebuildProjectMutationCommands = xcodebuildProjectMutationCommandFamily.commands
}
