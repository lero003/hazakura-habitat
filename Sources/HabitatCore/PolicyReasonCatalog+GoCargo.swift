extension PolicyReasonCatalog {
    private static let goDependencyMutationCommandFamily = CommandFamily([
        "go get",
        "go mod tidy",
    ])
    static let goDependencyMutationCommands = goDependencyMutationCommandFamily.commands

    private static let cargoDependencyMutationCommandFamily = CommandFamily([
        "cargo add",
        "cargo update",
        "cargo remove",
    ])
    static let cargoDependencyMutationCommands = cargoDependencyMutationCommandFamily.commands

    static func isGoCargoDependencyMutationCommand(_ command: String) -> Bool {
        goDependencyMutationCommandFamily.contains(command)
            || cargoDependencyMutationCommandFamily.contains(command)
    }
}
