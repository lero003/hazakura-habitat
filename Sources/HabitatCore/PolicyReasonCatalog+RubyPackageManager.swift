extension PolicyReasonCatalog {
    private static let rubyBundlerDependencyMutationCommandFamily = CommandFamily([
        "bundle install",
        "bundle add",
        "bundle update",
        "bundle lock",
        "bundle remove",
    ])
    static let rubyBundlerDependencyMutationCommands = rubyBundlerDependencyMutationCommandFamily.commands

    static func isRubyPackageManagerDependencyMutationCommand(_ command: String) -> Bool {
        rubyBundlerDependencyMutationCommandFamily.contains(command)
    }
}
