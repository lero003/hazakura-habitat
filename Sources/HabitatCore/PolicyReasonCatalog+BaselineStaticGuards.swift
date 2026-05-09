extension PolicyReasonCatalog {
    private static let baselineLockfileMutationCommandFamily = CommandFamily([
        "modifying lockfiles",
    ])
    static let baselineLockfileMutationCommands = baselineLockfileMutationCommandFamily.commands

    static let baselineForbiddenCoreCommands: [String] = [
        "sudo",
        "destructive file deletion outside the selected project",
    ]

    private static let baselineForbiddenSecretValueCommandFamily = CommandFamily([
        "load secret environment files",
        "read .env values",
        "read .envrc values",
        "read .netrc values",
        "read package manager auth config values",
        "read private keys",
    ])
    static let baselineForbiddenSecretValueCommands = baselineForbiddenSecretValueCommandFamily.commands

    static func isBaselineLockfileMutationCommand(_ command: String) -> Bool {
        baselineLockfileMutationCommandFamily.contains(command)
    }

    static func isBaselineForbiddenSecretValueCommand(_ command: String) -> Bool {
        baselineForbiddenSecretValueCommandFamily.contains(command)
    }
}
