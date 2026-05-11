extension PolicyReasonCatalog {
    private static let privilegedCommandFamily = CommandFamily([
        "sudo",
    ])
    static let privilegedCommands = privilegedCommandFamily.commands

    static func isPrivilegedCommand(_ command: String) -> Bool {
        privilegedCommandFamily.contains(command)
    }
}
