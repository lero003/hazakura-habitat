import Foundation

public struct HabitatScanner {
    private let runner: CommandRunning
    private let detector: ProjectDetector

    public init(runner: CommandRunning = ProcessCommandRunner(), detector: ProjectDetector = ProjectDetector()) {
        self.runner = runner
        self.detector = detector
    }

    public func scan(projectURL: URL) -> ScanResult {
        let project = detector.detect(projectURL: projectURL)
        let pathEntries = (ProcessInfo.processInfo.environment["PATH"] ?? "")
            .split(separator: ":")
            .map(String.init)
            .filter { !$0.isEmpty }

        let commandSpecs: [(String, String, [String])] = [
            ("swift", "/usr/bin/env", ["swift", "--version"]),
            ("git", "/usr/bin/env", ["git", "--version"]),
            ("node", "/usr/bin/env", ["node", "--version"]),
            ("python3", "/usr/bin/env", ["python3", "--version"]),
            ("xcode-select", "/usr/bin/xcrun", ["xcode-select", "-p"]),
        ]

        let commands = commandSpecs.map { spec in
            runner.run(executable: spec.1, arguments: spec.2, timeout: 3.0)
        }

        let toolNames = ["python3", "node", "npm", "pnpm", "yarn", "bun", "uv", "swift", "git", "brew"]
        let resolvedPaths = toolNames.map { tool in
            let result = runner.run(executable: "/usr/bin/which", arguments: ["-a", tool], timeout: 2.0)
            let paths = result.available && !result.stdout.isEmpty
                ? result.stdout.split(whereSeparator: \.isNewline).map(String.init)
                : []
            return ResolvedTool(name: tool, paths: Array(NSOrderedSet(array: paths)) as? [String] ?? paths)
        }

        let versions = commandSpecs.map { spec in
            let result = commands.first(where: { $0.args == spec.2 })!
            let output = [result.stdout, result.stderr].first(where: { !$0.isEmpty })
            return ToolVersion(name: spec.0, version: output, available: result.available && !result.timedOut)
        }

        let warnings = makeWarnings(project: project, resolvedPaths: resolvedPaths, versions: versions)
        let diagnostics = commands.compactMap { command -> String? in
            if command.timedOut { return "\(command.args.joined(separator: " ")) timed out" }
            if !command.available { return "\(command.args.joined(separator: " ")) unavailable: \(command.stderr)" }
            return nil
        }

        return ScanResult(
            schemaVersion: "0.1",
            scannedAt: ISO8601DateFormatter().string(from: Date()),
            projectPath: projectURL.path,
            system: SystemInfo(
                operatingSystemVersion: ProcessInfo.processInfo.operatingSystemVersionString,
                architecture: hostArchitecture(),
                shell: ProcessInfo.processInfo.environment["SHELL"],
                path: pathEntries
            ),
            commands: commands,
            project: project,
            tools: ToolSummary(
                resolvedPaths: resolvedPaths,
                versions: versions
            ),
            policy: PolicySummary(
                preferredCommands: preferredCommands(project: project),
                askFirstCommands: askFirstCommands(project: project, resolvedPaths: resolvedPaths, versions: versions),
                forbiddenCommands: [
                    "sudo",
                    "brew upgrade",
                    "brew uninstall",
                    "npm install -g",
                    "pip install --user",
                    "read .env values",
                    "read SSH private keys"
                ]
            ),
            warnings: warnings,
            diagnostics: diagnostics
        )
    }

    private func hostArchitecture() -> String {
        #if arch(arm64)
        return "arm64"
        #elseif arch(x86_64)
        return "x86_64"
        #else
        return "unknown"
        #endif
    }

    private func preferredCommands(project: ProjectInfo) -> [String] {
        switch project.packageManager {
        case "pnpm":
            return ["pnpm", "pnpm test", "pnpm build"]
        case "yarn":
            return ["yarn", "yarn test", "yarn build"]
        case "bun":
            return ["bun", "bun test", "bun run build"]
        case "npm":
            return ["npm run test", "npm run build"]
        case "swiftpm":
            return ["swift test", "swift build"]
        case "uv":
            return hasProjectVirtualEnvironment(project) ? ["uv run", ".venv/bin/python -m pytest"] : ["uv run"]
        case "python":
            return hasProjectVirtualEnvironment(project) ? [".venv/bin/python -m pytest", ".venv/bin/python"] : ["python3 -m pytest"]
        default:
            return ["Use read-only inspection first"]
        }
    }

    private func askFirstCommands(project: ProjectInfo, resolvedPaths: [ResolvedTool], versions: [ToolVersion]) -> [String] {
        var commands = [
            "brew install",
            "pip install",
            "npm install",
            "pnpm install",
            "yarn install",
            "bundle install",
            "python -m venv",
            "modifying lockfiles",
            "rm -rf"
        ]

        if hasMultipleJavaScriptLockfiles(project) {
            commands.insert("dependency installs when multiple JavaScript lockfiles exist", at: 0)
        }

        if nodeVersionNeedsVerification(project: project, versions: versions) {
            commands.insert("dependency installs before matching active Node to project version hints", at: 0)
        }

        if pythonVersionNeedsVerification(project: project, versions: versions) {
            commands.insert("dependency installs before matching active Python to project version hints", at: 0)
        }

        if let packageManager = project.packageManager,
           shouldWarnAboutMissingPreferredTool(packageManager: packageManager, resolvedPaths: resolvedPaths) {
            commands.insert(missingPreferredToolAskFirstCommand(packageManager: packageManager), at: 0)
        }

        return commands
    }

    private func makeWarnings(project: ProjectInfo, resolvedPaths: [ResolvedTool], versions: [ToolVersion]) -> [String] {
        var warnings: [String] = []

        if let nodeHint = project.runtimeHints.node {
            let activeNode = resolvedPaths.first(where: { $0.name == "node" })?.paths.first ?? "missing"
            let activeVersion = versions.first(where: { $0.name == "node" })?.version

            if let activeVersion, versionsDiffer(requested: nodeHint, active: activeVersion) {
                warnings.append("Active Node is \(activeVersion), but project requests \(nodeHint); ask before dependency installs (\(activeNode)).")
            } else {
                warnings.append("Project requests Node \(nodeHint); verify active node before installs (\(activeNode)).")
            }
        }

        if let pythonHint = project.runtimeHints.python {
            let activePython = resolvedPaths.first(where: { $0.name == "python3" })?.paths.first ?? "missing"
            let activeVersion = versions.first(where: { $0.name == "python3" })?.version

            if let activeVersion, pythonVersionsDiffer(requested: pythonHint, active: activeVersion) {
                warnings.append("Active Python is \(activeVersion), but project requests \(pythonHint); ask before dependency installs (\(activePython)).")
            } else {
                warnings.append("Project requests Python \(pythonHint); verify active python before installs (\(activePython)).")
            }
        }

        if hasSecretEnvironmentFile(project) {
            warnings.append("Environment file exists; do not read .env values.")
        } else if project.detectedFiles.contains(".env.example") {
            warnings.append("Environment examples exist; do not read real .env values.")
        }

        if project.packageManager == nil {
            warnings.append("No primary package manager signal detected; prefer read-only inspection before mutation.")
        }

        let lockfiles = javaScriptLockfiles(project)
        if lockfiles.count > 1 {
            warnings.append("Multiple JavaScript lockfiles detected (\(lockfiles.joined(separator: ", "))); ask before dependency installs.")
        }

        if hasProjectVirtualEnvironment(project) {
            warnings.append("Project .venv exists; use .venv/bin/python for Python commands before system python3.")
        }

        if let packageManager = project.packageManager,
           shouldWarnAboutMissingPreferredTool(packageManager: packageManager, resolvedPaths: resolvedPaths) {
            warnings.append(missingPreferredToolWarning(packageManager: packageManager))
        }

        return warnings
    }

    private func hasProjectVirtualEnvironment(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains(".venv")
    }

    private func hasSecretEnvironmentFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            file == ".env" || (file.hasPrefix(".env.") && file != ".env.example")
        }
    }

    private func hasMultipleJavaScriptLockfiles(_ project: ProjectInfo) -> Bool {
        javaScriptLockfiles(project).count > 1
    }

    private func javaScriptLockfiles(_ project: ProjectInfo) -> [String] {
        ["package-lock.json", "pnpm-lock.yaml", "yarn.lock", "bun.lockb"].filter {
            project.detectedFiles.contains($0)
        }
    }

    private func shouldWarnAboutMissingPreferredTool(packageManager: String, resolvedPaths: [ResolvedTool]) -> Bool {
        guard let toolName = executableName(forPackageManager: packageManager) else {
            return false
        }

        return resolvedPaths.first(where: { $0.name == toolName })?.paths.isEmpty ?? true
    }

    private func missingPreferredToolAskFirstCommand(packageManager: String) -> String {
        switch packageManager {
        case "swiftpm":
            return "running SwiftPM commands before swift is available"
        case "python":
            return "running Python commands before python3 is available"
        default:
            return "substituting another package manager for \(packageManager)"
        }
    }

    private func missingPreferredToolWarning(packageManager: String) -> String {
        switch packageManager {
        case "swiftpm":
            return "Project files prefer SwiftPM, but swift was not found on PATH; ask before running SwiftPM commands."
        case "python":
            return "Project files prefer Python, but python3 was not found on PATH; ask before running Python commands."
        default:
            return "Project files prefer \(packageManager), but \(packageManager) was not found on PATH; ask before substituting another package manager."
        }
    }

    private func nodeVersionNeedsVerification(project: ProjectInfo, versions: [ToolVersion]) -> Bool {
        guard let nodeHint = project.runtimeHints.node else {
            return false
        }

        guard let activeVersion = versions.first(where: { $0.name == "node" })?.version else {
            return true
        }

        return versionsDiffer(requested: nodeHint, active: activeVersion)
    }

    private func pythonVersionNeedsVerification(project: ProjectInfo, versions: [ToolVersion]) -> Bool {
        guard let pythonHint = project.runtimeHints.python else {
            return false
        }

        guard let activeVersion = versions.first(where: { $0.name == "python3" })?.version else {
            return true
        }

        return pythonVersionsDiffer(requested: pythonHint, active: activeVersion)
    }

    private func executableName(forPackageManager packageManager: String) -> String? {
        switch packageManager {
        case "npm", "pnpm", "yarn", "bun", "uv":
            return packageManager
        case "swiftpm":
            return "swift"
        case "python":
            return "python3"
        default:
            return nil
        }
    }

    private func versionsDiffer(requested: String, active: String) -> Bool {
        guard let requestedMajor = majorVersion(from: requested),
              let activeMajor = majorVersion(from: active)
        else {
            return false
        }

        return requestedMajor != activeMajor
    }

    private func pythonVersionsDiffer(requested: String, active: String) -> Bool {
        guard let requestedComponents = versionComponents(from: requested),
              let activeComponents = versionComponents(from: active)
        else {
            return false
        }

        return requestedComponents != activeComponents
    }

    private func versionComponents(from value: String) -> [Int]? {
        let numericVersion = value.drop { !$0.isNumber }
            .prefix { $0.isNumber || $0 == "." }
        let components = numericVersion
            .split(separator: ".")
            .prefix(2)
            .compactMap { Int($0) }
        return components.isEmpty ? nil : Array(components)
    }

    private func majorVersion(from value: String) -> Int? {
        let digits = value
            .drop { !$0.isNumber }
            .prefix { $0.isNumber }
        return Int(digits)
    }
}
