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
        let packageManagerUse = result.project.packageManager.map { packageManager in
            if let version = result.project.packageManagerVersion {
                return "Use `\(packageManager)@\(version)` because `package.json` packageManager points to it."
            }

            return "Use `\(packageManager)` because project files point to it."
        }
        let useLines = ([packageManagerUse] + result.policy.preferredCommands.prefix(2).map { "Prefer `\($0)`." })
            .compactMap { $0 }
        let avoidLines = result.policy.forbiddenCommands.prefix(4).map { "Do not run `\($0)`." }
        let askLines = result.policy.askFirstCommands.prefix(4).map { "Ask before `\($0)`." }
        let mismatchLines = result.warnings.isEmpty ? ["- None detected."] : result.warnings.map { "- \($0)" }
        let relevantDiagnostics = agentRelevantDiagnostics(result)
        let noteLines = relevantDiagnostics.isEmpty
            ? ["- Scan completed without relevant command diagnostics."]
            : relevantDiagnostics.map { "- \($0)" }

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
        let allowed = result.policy.preferredCommands + [
            "read-only project inspection",
            "test commands for the selected project",
            "build commands for the selected project"
        ]

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

    private func agentRelevantCommandNames(_ result: ScanResult) -> Set<String> {
        var names = Set<String>()

        if let packageManager = result.project.packageManager,
           let executable = executableName(forPackageManager: packageManager) {
            names.insert(executable)
        }

        if result.project.runtimeHints.node != nil {
            names.insert("node")
        }

        if result.project.runtimeHints.python != nil {
            names.insert("python3")
        }

        return names
    }

    private func executableName(forPackageManager packageManager: String) -> String? {
        switch packageManager {
        case "npm", "pnpm", "yarn", "bun", "uv", "go", "cargo":
            return packageManager
        case "bundler":
            return "bundle"
        case "swiftpm":
            return "swift"
        case "python":
            return "python3"
        default:
            return nil
        }
    }
}
