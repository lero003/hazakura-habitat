extension PolicyReasonCatalog {
    private static let baselineForbiddenSecretValueCommandFamily = CommandFamily([
        "load secret environment files",
        "read .env values",
        "read .envrc values",
        "read .netrc values",
        "read package manager auth config values",
        "read private keys",
    ])
    static let baselineForbiddenSecretValueCommands = baselineForbiddenSecretValueCommandFamily.commands

    static func isBaselineForbiddenSecretValueCommand(_ command: String) -> Bool {
        baselineForbiddenSecretValueCommandFamily.contains(command)
    }
}
