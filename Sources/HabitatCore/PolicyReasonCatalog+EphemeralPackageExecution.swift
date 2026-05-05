extension PolicyReasonCatalog {
    static let npmEphemeralPackageExecutionCommands = [
        "npm exec",
        "npx",
    ]
    static let pnpmEphemeralPackageExecutionCommands = [
        "pnpm dlx",
    ]
    static let yarnEphemeralPackageExecutionCommands = [
        "yarn dlx",
    ]
    static let bunEphemeralPackageExecutionCommands = [
        "bunx",
    ]
    static let pythonEphemeralPackageExecutionCommands = [
        "uvx",
        "uv tool run",
        "pipx run",
        "pipx runpip",
    ]
    static let ephemeralPackageExecutionCommands = npmEphemeralPackageExecutionCommands
        + pnpmEphemeralPackageExecutionCommands
        + yarnEphemeralPackageExecutionCommands
        + bunEphemeralPackageExecutionCommands
        + pythonEphemeralPackageExecutionCommands
    private static let ephemeralPackageExecutionCommandFamily = CommandFamily(ephemeralPackageExecutionCommands)

    static func isEphemeralPackageExecutionCommand(_ command: String) -> Bool {
        ephemeralPackageExecutionCommandFamily.contains(command)
    }
}
