extension PolicyReasonCatalog {
    private static let corepackPackageManagerActivationCommandFamily = CommandFamily([
        "corepack enable",
        "corepack disable",
        "corepack prepare",
        "corepack install",
        "corepack use",
        "corepack up",
    ])

    static let corepackPackageManagerActivationCommands = corepackPackageManagerActivationCommandFamily.commands

    static func isPackageManagerActivationCommand(_ command: String) -> Bool {
        corepackPackageManagerActivationCommandFamily.contains(command)
    }
}
