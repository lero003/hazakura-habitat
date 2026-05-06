extension PolicyReasonCatalog {
    private static let secretBearingBroadSearchCommandFamily = CommandFamily([
        "recursive project search without excluding secret-bearing files",
        "grep -R <pattern> .",
        "grep -r <pattern> .",
        "grep -R -n <pattern> .",
        "grep -r -n <pattern> .",
        "find . -type f -exec grep <pattern> {} +",
        "find . -type f -exec grep -n <pattern> {} +",
        "find . -type f -print0 | xargs -0 grep <pattern>",
        "find . -type f -print0 | xargs -0 grep -n <pattern>",
        "rg <pattern>",
        "rg -n <pattern>",
        "rg <pattern> .",
        "rg -n <pattern> .",
        "rg --line-number <pattern> .",
        "rg --hidden <pattern> .",
        "rg --hidden -n <pattern> .",
        "rg --no-ignore <pattern> .",
        "rg --no-ignore -n <pattern> .",
        "rg -u <pattern> .",
        "rg -uu <pattern> .",
        "rg -uuu <pattern> .",
        "git grep <pattern>",
        "git grep -n <pattern>",
        "git grep <pattern> -- .",
        "git grep -n <pattern> -- .",
    ])
    static let secretBearingBroadSearchCommands = secretBearingBroadSearchCommandFamily.commands

    static func isSecretBearingBroadSearchCommand(_ command: String) -> Bool {
        secretBearingBroadSearchCommandFamily.contains(command)
    }
}
