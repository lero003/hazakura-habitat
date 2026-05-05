extension PolicyReasonCatalog {
    private static let npmDependencyMutationCommandFamily = CommandFamily([
        "npm install",
        "npm ci",
        "npm update",
        "npm uninstall",
        "npm remove",
        "npm rm",
    ])

    static let npmDependencyMutationCommands = npmDependencyMutationCommandFamily.commands

    private static let pnpmDependencyMutationCommandFamily = CommandFamily([
        "pnpm install",
        "pnpm add",
        "pnpm update",
        "pnpm remove",
        "pnpm rm",
        "pnpm uninstall",
    ])

    static let pnpmDependencyMutationCommands = pnpmDependencyMutationCommandFamily.commands

    private static let yarnDependencyMutationCommandFamily = CommandFamily([
        "yarn install",
        "yarn add",
        "yarn up",
        "yarn remove",
    ])

    static let yarnDependencyMutationCommands = yarnDependencyMutationCommandFamily.commands

    private static let bunDependencyMutationCommandFamily = CommandFamily([
        "bun install",
        "bun add",
        "bun update",
        "bun remove",
    ])

    static let bunDependencyMutationCommands = bunDependencyMutationCommandFamily.commands

    static func isJavaScriptPackageManagerDependencyMutationCommand(_ command: String) -> Bool {
        npmDependencyMutationCommandFamily.contains(command)
            || pnpmDependencyMutationCommandFamily.contains(command)
            || yarnDependencyMutationCommandFamily.contains(command)
            || bunDependencyMutationCommandFamily.contains(command)
    }
}
