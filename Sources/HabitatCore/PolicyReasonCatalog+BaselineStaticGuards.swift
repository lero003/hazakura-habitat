extension PolicyReasonCatalog {
    private static let baselineLockfileMutationCommandFamily = CommandFamily([
        "modifying lockfiles",
    ])
    static let baselineLockfileMutationCommands = baselineLockfileMutationCommandFamily.commands

    private static let privilegedCommandFamily = CommandFamily([
        "sudo",
    ])
    static let privilegedCommands = privilegedCommandFamily.commands

    private static let outsideProjectDeletionCommandFamily = CommandFamily([
        "destructive file deletion outside the selected project",
    ])
    static let outsideProjectDeletionCommands = outsideProjectDeletionCommandFamily.commands

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

    static func isPrivilegedCommand(_ command: String) -> Bool {
        privilegedCommandFamily.contains(command)
    }

    static func isOutsideProjectDeletionCommand(_ command: String) -> Bool {
        outsideProjectDeletionCommandFamily.contains(command)
    }

    static func isBaselineForbiddenSecretValueCommand(_ command: String) -> Bool {
        baselineForbiddenSecretValueCommandFamily.contains(command)
    }
}
