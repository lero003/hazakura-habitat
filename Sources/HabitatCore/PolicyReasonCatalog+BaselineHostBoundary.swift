extension PolicyReasonCatalog {
    private static let privilegedCommandFamily = CommandFamily([
        "sudo",
    ])
    static let privilegedCommands = privilegedCommandFamily.commands

    private static let outsideProjectDeletionCommandFamily = CommandFamily([
        "destructive file deletion outside the selected project",
    ])
    static let outsideProjectDeletionCommands = outsideProjectDeletionCommandFamily.commands

    static func isPrivilegedCommand(_ command: String) -> Bool {
        privilegedCommandFamily.contains(command)
    }

    static func isOutsideProjectDeletionCommand(_ command: String) -> Bool {
        outsideProjectDeletionCommandFamily.contains(command)
    }
}
