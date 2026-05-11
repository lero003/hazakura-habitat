extension PolicyReasonCatalog {
    private static let baselineLockfileMutationCommandFamily = CommandFamily([
        "modifying lockfiles",
    ])
    static let baselineLockfileMutationCommands = baselineLockfileMutationCommandFamily.commands

    static func isBaselineLockfileMutationCommand(_ command: String) -> Bool {
        baselineLockfileMutationCommandFamily.contains(command)
    }
}
