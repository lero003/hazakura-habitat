import Foundation

public struct ReportWriter {
    public init() {}

    public func write(scanResult: ScanResult, outputURL: URL) throws {
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
        try writeJSON(scanResult: scanResult, outputURL: outputURL)
        try writeText(agentContext(scanResult), to: outputURL.appendingPathComponent("agent_context.md"))
        try writeText(commandPolicy(scanResult), to: outputURL.appendingPathComponent("command_policy.md"))
        try writeText(environmentReport(scanResult), to: outputURL.appendingPathComponent("environment_report.md"))
    }

    private func writeJSON(scanResult: ScanResult, outputURL: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(scanResult)
        try data.write(to: outputURL.appendingPathComponent("scan_result.json"))
    }

    private func writeText(_ text: String, to url: URL) throws {
        try text.write(to: url, atomically: true, encoding: .utf8)
    }

    private func agentContext(_ result: ScanResult) -> String {
        let preferredCommands = markdownPreferredCommands(result)
        let useLines: [String]

        if hasProjectPathVerificationGuard(result) {
            useLines = ["Verify the project path before running project commands."]
        } else {
            let packageManagerUse = result.project.packageManager.map { packageManager in
                if let version = result.project.packageManagerVersion {
                    if result.project.declaredPackageManager == packageManager {
                        return "Use `\(packageManager)@\(version)` because `package.json` packageManager points to it."
                    }

                    return "Use `\(packageManager)@\(version)` because project metadata pins it."
                }

                return "Use `\(packageManager)` because project files point to it."
            }

            useLines = ([packageManagerUse] + preferredCommands.prefix(2).map { "Prefer `\($0)`." })
                .compactMap { $0 }
        }
        let avoidLines = prioritizedForbiddenCommands(result).prefix(5).map { "Do not run `\($0)`." }
        let askLines = result.policy.askFirstCommands.prefix(4).map { "Ask before `\($0)`." }
        let mismatchLines = result.warnings.isEmpty ? ["- None detected."] : result.warnings.map { "- \($0)" }
        let changeLines = result.changes.map { "- \($0.summary) \($0.impact)" }
        let relevantDiagnostics = agentRelevantDiagnostics(result)
        let diagnosticLines = relevantDiagnostics.map { "- \($0)" }
        let noteLines = (changeLines + diagnosticLines).isEmpty
            ? ["- Scan completed without relevant command diagnostics."]
            : changeLines + diagnosticLines

        return """
        # Agent Context

        ## Freshness
        - Scanned at: \(result.scannedAt)
        - Project: \(result.projectPath)

        ## Use
        \(bulletList(useLines, fallback: "- Use read-only inspection first."))

        ## Avoid
        \(bulletList(avoidLines, fallback: "- Do not mutate global environment state."))

        ## Ask First
        \(bulletList(askLines, fallback: "- Ask before dependency installation or version changes."))

        ## Mismatches
        \(mismatchLines.joined(separator: "\n"))

        ## Notes
        \(noteLines.joined(separator: "\n"))
        """
    }

    private func commandPolicy(_ result: ScanResult) -> String {
        let preferredCommands = markdownPreferredCommands(result)
        var allowed: [String]

        if hasProjectPathVerificationGuard(result) {
            allowed = ["path existence checks"]
        } else {
            allowed = preferredCommands + [
                "read-only project inspection"
            ]

            if canAllowSelectedProjectTestCommands(result, preferredCommands: preferredCommands) {
                allowed.append("test commands for the selected project")
            }

            if canAllowSelectedProjectBuildCommands(result, preferredCommands: preferredCommands) {
                allowed.append("build commands for the selected project")
            }
        }

        return """
        # Command Policy

        ## Allowed
        \(bulletList(allowed.map { "`\($0)`" }, fallback: "- `read-only inspection`"))

        ## Ask First
        \(bulletList(result.policy.askFirstCommands.map { "`\($0)`" }, fallback: "- `dependency installation`"))

        ## Forbidden
        \(bulletList(result.policy.forbiddenCommands.map { "`\($0)`" }, fallback: "- `sudo`"))

        ## If Dependency Installation Seems Necessary
        - Re-check lockfiles and version hints first.
        - Prefer the project-specific package manager from `agent_context.md`.
        - Ask before any install, upgrade, uninstall, or global mutation.
        """
    }

    private func environmentReport(_ result: ScanResult) -> String {
        let tools = result.tools.resolvedPaths.map { tool in
            let joined = tool.paths.isEmpty ? "missing" : tool.paths.joined(separator: ", ")
            return "- \(tool.name): \(joined)"
        }.joined(separator: "\n")

        let versions = result.tools.versions.map { tool in
            "- \(tool.name): \(tool.version ?? "unavailable")"
        }.joined(separator: "\n")

        let changes = result.changes.map { change in
            "[\(change.category)] \(change.summary) \(change.impact)"
        }

        let files = result.project.detectedFiles.isEmpty
            ? "- None"
            : result.project.detectedFiles.map { "- \($0)" }.joined(separator: "\n")

        return """
        # Environment Report

        ## System
        - OS: \(result.system.operatingSystemVersion)
        - Architecture: \(result.system.architecture)
        - Shell: \(result.system.shell ?? "unknown")

        ## Project Signals
        \(files)

        ## Resolved Tools
        \(tools)

        ## Tool Versions
        \(versions)

        ## Changes Since Previous Scan
        \(bulletList(changes, fallback: "- None"))

        ## Warnings
        \(bulletList(result.warnings, fallback: "- None"))

        ## Diagnostics
        \(bulletList(result.diagnostics, fallback: "- None"))

        ## Privacy Note
        - This scan avoids reading `.env` values, secrets, browser data, and mail data.
        """
    }

    private func bulletList(_ items: [String], fallback: String) -> String {
        guard !items.isEmpty else { return fallback }
        return items.map { "- \($0)" }.joined(separator: "\n")
    }

    private func agentRelevantDiagnostics(_ result: ScanResult) -> [String] {
        let relevantCommands = agentRelevantCommandNames(result)
        guard !relevantCommands.isEmpty else { return [] }

        return result.diagnostics.filter { diagnostic in
            relevantCommands.contains { commandName in
                diagnostic == commandName || diagnostic.hasPrefix("\(commandName) ")
            }
        }
    }

    private func hasProjectPathVerificationGuard(_ result: ScanResult) -> Bool {
        result.policy.askFirstCommands.contains("running project commands before project path is verified")
    }

    private func markdownPreferredCommands(_ result: ScanResult) -> [String] {
        guard let packageManager = result.project.packageManager,
              let executable = executableName(forPackageManager: packageManager)
        else {
            return result.policy.preferredCommands
        }

        if packageManager == "python",
           result.project.detectedFiles.contains(".venv/bin/python"),
           result.policy.preferredCommands.allSatisfy({ $0.hasPrefix(".venv/bin/python") }) {
            return result.policy.preferredCommands
        }

        if ["npm", "pnpm", "yarn", "bun"].contains(packageManager),
           result.policy.askFirstCommands.contains("running JavaScript commands before node is available") {
            return []
        }

        if ["swiftpm", "xcodebuild"].contains(packageManager),
           result.policy.askFirstCommands.contains("Swift/Xcode build commands before xcode-select -p succeeds") {
            return []
        }

        if projectRelevantVersionCheckGuardApplies(result) {
            return result.policy.preferredCommands.filter {
                isAvailableProjectLocalPreferredCommand($0, result: result)
            }
        }

        let isMissing = selectedExecutableIsMissing(result, executable: executable)

        if isMissing {
            return result.policy.preferredCommands.filter {
                isAvailableProjectLocalPreferredCommand($0, result: result)
            }
        }

        return result.policy.preferredCommands
    }

    private func canAllowSelectedProjectTestCommands(_ result: ScanResult, preferredCommands: [String]) -> Bool {
        guard canAllowSelectedProjectCommands(result, preferredCommands: preferredCommands) else {
            return false
        }

        guard let packageManager = result.project.packageManager,
              let executable = executableName(forPackageManager: packageManager),
              selectedExecutableIsMissing(result, executable: executable)
        else {
            return true
        }

        return preferredCommands.contains {
            isAvailableProjectLocalPreferredCommand($0, result: result)
        }
    }

    private func canAllowSelectedProjectBuildCommands(_ result: ScanResult, preferredCommands: [String]) -> Bool {
        guard canAllowSelectedProjectCommands(result, preferredCommands: preferredCommands) else {
            return false
        }

        guard let packageManager = result.project.packageManager,
              let executable = executableName(forPackageManager: packageManager)
        else {
            return true
        }

        return !selectedExecutableIsMissing(result, executable: executable)
    }

    private func canAllowSelectedProjectCommands(_ result: ScanResult, preferredCommands: [String]) -> Bool {
        guard !preferredCommands.isEmpty else { return false }
        guard result.project.packageManager != "xcodebuild" else { return false }
        guard !result.policy.askFirstCommands.contains("Swift/Xcode build commands before xcode-select -p succeeds") else {
            return false
        }
        guard !result.policy.askFirstCommands.contains("running JavaScript commands before node is available") else {
            return false
        }
        guard !projectRelevantVersionCheckGuardApplies(result) else {
            return false
        }
        guard !result.policy.askFirstCommands.contains("running Python commands before project .venv/bin/python exists") else {
            return false
        }

        return true
    }

    private func projectRelevantVersionCheckGuardApplies(_ result: ScanResult) -> Bool {
        result.policy.askFirstCommands.contains { command in
            let lowercasedCommand = command.lowercased()

            return command.contains("version check succeeds")
                && (
                    lowercasedCommand.contains("running javascript commands")
                        || lowercasedCommand.contains("running swiftpm commands")
                        || lowercasedCommand.contains("running go commands")
                        || lowercasedCommand.contains("running cargo commands")
                        || lowercasedCommand.contains("running python commands")
                        || lowercasedCommand.contains("running bundler commands")
                        || lowercasedCommand.contains("running homebrew bundle commands")
                        || lowercasedCommand.contains("running cocoapods commands")
                        || lowercasedCommand.contains("running carthage commands")
                        || lowercasedCommand.contains("running xcode build commands")
                        || result.project.packageManager.map { lowercasedCommand.contains("running \($0) commands") } == true
                )
        }
    }

    private func selectedExecutableIsMissing(_ result: ScanResult, executable: String) -> Bool {
        result.tools.resolvedPaths
            .first(where: { $0.name == executable })?
            .paths
            .isEmpty ?? true
    }

    private func isAvailableProjectLocalPreferredCommand(_ command: String, result: ScanResult) -> Bool {
        let executable = command
            .split(whereSeparator: \.isWhitespace)
            .first
            .map(String.init)

        switch executable {
        case ".venv/bin/python":
            return result.project.detectedFiles.contains(".venv/bin/python")
        default:
            return false
        }
    }

    private func prioritizedForbiddenCommands(_ result: ScanResult) -> [String] {
        var commands: [String] = []

        append("sudo", to: &commands, from: result.policy.forbiddenCommands)
        append("destructive file deletion outside the selected project", to: &commands, from: result.policy.forbiddenCommands)

        if hasSecretDotEnvFile(result.project) || result.project.detectedFiles.contains(".env.example") {
            append("read .env values", to: &commands, from: result.policy.forbiddenCommands)
        }

        if hasSecretEnvrcFile(result.project) || result.project.detectedFiles.contains(".envrc.example") {
            append("read .envrc values", to: &commands, from: result.policy.forbiddenCommands)
        }

        if hasSSHPrivateKeyFile(result.project) {
            append("read SSH private keys", to: &commands, from: result.policy.forbiddenCommands)
        }

        if hasPackageManagerAuthConfig(result.project) {
            append("read package manager auth config values", to: &commands, from: result.policy.forbiddenCommands)
        }

        for command in result.policy.forbiddenCommands where !commands.contains(command) {
            commands.append(command)
        }

        return commands
    }

    private func append(_ command: String, to commands: inout [String], from source: [String]) {
        guard source.contains(command), !commands.contains(command) else { return }
        commands.append(command)
    }

    private func hasSecretDotEnvFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            file == ".env" || (file.hasPrefix(".env.") && file != ".env.example")
        }
    }

    private func hasSecretEnvrcFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            file == ".envrc" || (file.hasPrefix(".envrc.") && file != ".envrc.example")
        }
    }

    private func hasPackageManagerAuthConfig(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            file == ".npmrc" || file == ".pnpmrc" || file == ".yarnrc" || file == ".yarnrc.yml"
        }
    }

    private func hasSSHPrivateKeyFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            ["id_rsa", "id_dsa", "id_ecdsa", "id_ed25519"].contains(file)
        }
    }

    private func agentRelevantCommandNames(_ result: ScanResult) -> Set<String> {
        var names = Set<String>()

        if let packageManager = result.project.packageManager,
           let executable = executableName(forPackageManager: packageManager) {
            names.insert(executable)

            if ["npm", "pnpm", "yarn", "bun"].contains(packageManager) {
                names.insert("node")
            }
        }

        if result.project.runtimeHints.node != nil {
            names.insert("node")
        }

        if result.project.runtimeHints.python != nil {
            names.insert("python3")
        }

        if result.project.runtimeHints.ruby != nil {
            names.insert("ruby")
        }

        if let packageManager = result.project.packageManager,
           ["swiftpm", "xcodebuild"].contains(packageManager) {
            names.insert("xcode-select")
        }

        return names
    }

    private func executableName(forPackageManager packageManager: String) -> String? {
        switch packageManager {
        case "npm", "pnpm", "yarn", "bun", "uv", "go", "cargo", "carthage", "xcodebuild":
            return packageManager
        case "bundler":
            return "bundle"
        case "homebrew":
            return "brew"
        case "cocoapods":
            return "pod"
        case "swiftpm":
            return "swift"
        case "python":
            return "python3"
        default:
            return nil
        }
    }
}
