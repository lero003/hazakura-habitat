extension PolicyReasonCatalog {
    private static let packageRegistryMutationCommandFamily = CommandFamily([
        "npm publish",
        "npm unpublish",
        "npm deprecate",
        "npm dist-tag",
        "npm owner",
        "npm access",
        "npm team",
        "pnpm publish",
        "yarn publish",
        "yarn npm publish",
        "bun publish",
        "uv publish",
        "twine upload",
        "python -m twine upload",
        "python3 -m twine upload",
        "gem push",
        "gem yank",
        "gem owner",
        "cargo publish",
        "cargo yank",
        "cargo owner",
        "pod trunk add-owner",
        "pod trunk remove-owner",
        "pod trunk push",
        "pod trunk deprecate",
        "pod trunk delete",
    ])
    static let packageRegistryMutationCommands = packageRegistryMutationCommandFamily.commands

    static func isPackageRegistryMutationCommand(_ command: String) -> Bool {
        packageRegistryMutationCommandFamily.contains(command)
    }
}
