extension PolicyReasonCatalog {
    private static let swiftPackageDependencyResolutionCommandFamily = CommandFamily([
        "swift package update",
        "swift package resolve",
    ])

    static let swiftPackageDependencyResolutionCommands = swiftPackageDependencyResolutionCommandFamily.commands

    static func isSwiftPackageDependencyResolutionMutationCommand(_ command: String) -> Bool {
        swiftPackageDependencyResolutionCommandFamily.contains(command)
    }
}
