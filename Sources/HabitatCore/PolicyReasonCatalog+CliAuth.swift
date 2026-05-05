extension PolicyReasonCatalog {
    private static let cliAuthAndCredentialStoreCommandFamily = CommandFamily([
        "gh auth token",
        "gh auth status --show-token",
        "gh auth status -t",
        "gh auth login",
        "gh auth logout",
        "gh auth refresh",
        "gh auth setup-git",
        "git credential fill",
        "git credential approve",
        "git credential reject",
        "git credential-osxkeychain get",
        "git credential-osxkeychain store",
        "git credential-osxkeychain erase",
        "security find-generic-password -w",
        "security find-internet-password -w",
        "security dump-keychain",
        "security export",
    ])
    static let cliAuthAndCredentialStoreCommands = cliAuthAndCredentialStoreCommandFamily.commands

    static func isCliAuthAndCredentialStoreCommand(_ command: String) -> Bool {
        cliAuthAndCredentialStoreCommandFamily.contains(command)
    }
}
