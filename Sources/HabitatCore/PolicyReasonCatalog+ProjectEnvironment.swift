extension PolicyReasonCatalog {
    private static let virtualEnvironmentMutationCommandFamily = CommandFamily([
        "python -m venv",
        "python3 -m venv",
        "uv venv",
        "virtualenv",
        "creating or deleting virtual environments",
    ])

    static let virtualEnvironmentMutationCommands = virtualEnvironmentMutationCommandFamily.commands

    private static let versionManagerMutationCommandFamily = CommandFamily([
        "modifying version manager files",
    ])

    static let versionManagerMutationCommands = versionManagerMutationCommandFamily.commands

    static func isVersionManagerMutationCommand(_ command: String) -> Bool {
        versionManagerMutationCommandFamily.contains(command)
    }
}
