extension PolicyReasonCatalog {
    private static let outsideProjectDeletionCommandFamily = CommandFamily([
        "destructive file deletion outside the selected project",
    ])
    static let outsideProjectDeletionCommands = outsideProjectDeletionCommandFamily.commands

    static func isOutsideProjectDeletionCommand(_ command: String) -> Bool {
        outsideProjectDeletionCommandFamily.contains(command)
    }
}
