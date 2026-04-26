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
            ("go", "/usr/bin/env", ["go", "version"]),
            ("cargo", "/usr/bin/env", ["cargo", "--version"]),
            ("rustc", "/usr/bin/env", ["rustc", "--version"]),
            ("xcode-select", "/usr/bin/xcrun", ["xcode-select", "-p"]),
        ] + packageManagerVersionCommandSpecs(project: project)

        let commands = commandSpecs.map { spec in
            runner.run(executable: spec.1, arguments: spec.2, timeout: 3.0)
        }

        let toolNames = ["python3", "node", "npm", "pnpm", "yarn", "bun", "uv", "bundle", "go", "cargo", "rustc", "swift", "git", "brew"]
        let resolvedPaths = toolNames.map { tool in
            let result = runner.run(executable: "/usr/bin/which", arguments: ["-a", tool], timeout: 2.0)
            let paths = result.available && !result.stdout.isEmpty
                ? result.stdout.split(whereSeparator: \.isNewline).map(String.init)
                : []
            return ResolvedTool(name: tool, paths: Array(NSOrderedSet(array: paths)) as? [String] ?? paths)
        }

        let versions = commandSpecs.map { spec in
            let result = commands.first(where: { $0.args == spec.2 })!
            let versionCommandSucceeded = result.available && !result.timedOut && result.exitCode == 0
            let output = versionCommandSucceeded
                ? [result.stdout, result.stderr].first(where: { !$0.isEmpty })
                : nil
            return ToolVersion(name: spec.0, version: output, available: versionCommandSucceeded)
        }

        let warnings = makeWarnings(project: project, resolvedPaths: resolvedPaths, versions: versions)
        let diagnostics = commands.compactMap { command -> String? in
            if command.timedOut { return "\(command.args.joined(separator: " ")) timed out" }
            if !command.available { return "\(command.args.joined(separator: " ")) unavailable: \(command.stderr)" }
            if let exitCode = command.exitCode, exitCode != 0 {
                let detail = [command.stderr, command.stdout].first(where: { !$0.isEmpty })
                return "\(command.args.joined(separator: " ")) failed with exit code \(exitCode)\(detail.map { ": \($0)" } ?? "")"
            }
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
            return javaScriptPreferredCommands(packageManager: "pnpm", project: project)
        case "yarn":
            return javaScriptPreferredCommands(packageManager: "yarn", project: project)
        case "bun":
            return javaScriptPreferredCommands(packageManager: "bun", project: project)
        case "npm":
            return javaScriptPreferredCommands(packageManager: "npm", project: project)
        case "swiftpm":
            return ["swift test", "swift build"]
        case "go":
            return ["go test ./...", "go build ./..."]
        case "cargo":
            return ["cargo test", "cargo build"]
        case "uv":
            return hasProjectVirtualEnvironment(project) ? ["uv run", ".venv/bin/python -m pytest"] : ["uv run"]
        case "python":
            return hasProjectVirtualEnvironment(project) ? [".venv/bin/python -m pytest", ".venv/bin/python"] : ["python3 -m pytest"]
        case "bundler":
            return ["bundle exec"]
        default:
            return ["Use read-only inspection first"]
        }
    }

    private func javaScriptPreferredCommands(packageManager: String, project: ProjectInfo) -> [String] {
        let knownScriptOrder = ["test", "build", "lint", "typecheck", "check"]
        let knownScripts = knownScriptOrder.filter { project.packageScripts.contains($0) }

        if !knownScripts.isEmpty {
            return knownScripts.map { javaScriptRunCommand(packageManager: packageManager, script: $0) }
        }

        if project.detectedFiles.contains("package.json") {
            return [javaScriptRunCommand(packageManager: packageManager, script: nil)]
        }

        return [packageManager]
    }

    private func javaScriptRunCommand(packageManager: String, script: String?) -> String {
        switch (packageManager, script) {
        case ("bun", "test"):
            return "bun test"
        case ("bun", let script?):
            return "bun run \(script)"
        case ("npm", let script?):
            return "npm run \(script)"
        case ("npm", nil):
            return "npm run"
        case (_, let script?):
            return "\(packageManager) run \(script)"
        case (_, nil):
            return "\(packageManager) run"
        }
    }

    private func askFirstCommands(project: ProjectInfo, resolvedPaths: [ResolvedTool], versions: [ToolVersion]) -> [String] {
        var commands = [
            "brew install",
            "pip install",
            "npm install",
            "pnpm install",
            "yarn install",
            "bun install",
            "uv sync",
            "bundle install",
            "go get",
            "go mod tidy",
            "cargo add",
            "cargo update",
            "python -m venv",
            "modifying lockfiles",
            "rm -rf"
        ]

        if let packageManager = project.packageManager {
            for command in dependencyMutationCommands(forPackageManager: packageManager).reversed() {
                commands.removeAll { $0 == command }
                commands.insert(command, at: 0)
            }
        }

        if hasMultipleJavaScriptLockfiles(project) {
            commands.insert("dependency installs when multiple JavaScript lockfiles exist", at: 0)
        }

        if nodeVersionNeedsVerification(project: project, versions: versions) {
            commands.insert("dependency installs before matching active Node to project version hints", at: 0)
        }

        if pythonVersionNeedsVerification(project: project, versions: versions) {
            commands.insert("dependency installs before matching active Python to project version hints", at: 0)
        }

        if packageManagerVersionNeedsVerification(project: project, versions: versions) {
            commands.insert("dependency installs before matching \(project.packageManager ?? "package manager") to packageManager version", at: 0)
        }

        if let packageManager = project.packageManager,
           shouldWarnAboutMissingPreferredTool(packageManager: packageManager, resolvedPaths: resolvedPaths) {
            commands.insert(missingPreferredToolAskFirstCommand(packageManager: packageManager), at: 0)
        }

        return commands
    }

    private func dependencyMutationCommands(forPackageManager packageManager: String) -> [String] {
        switch packageManager {
        case "npm":
            return ["npm install"]
        case "pnpm":
            return ["pnpm install"]
        case "yarn":
            return ["yarn install"]
        case "bun":
            return ["bun install"]
        case "uv":
            return ["uv sync"]
        case "python":
            return ["pip install"]
        case "bundler":
            return ["bundle install"]
        case "go":
            return ["go get", "go mod tidy"]
        case "cargo":
            return ["cargo add", "cargo update"]
        default:
            return []
        }
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

        if let packageManager = project.packageManager,
           let requestedVersion = project.packageManagerVersion {
            let activeToolVersion = versions.first(where: { $0.name == packageManager })
            if let activeVersion = activeToolVersion?.version,
               activeToolVersion?.available == true,
               packageManagerVersionsDiffer(requested: requestedVersion, active: activeVersion) {
                warnings.append("Project requests \(packageManager) \(requestedVersion) via package.json; active \(packageManager) is \(activeVersion); ask before dependency installs.")
            } else if activeToolVersion?.available != true {
                warnings.append("Project requests \(packageManager) \(requestedVersion) via package.json; verify active \(packageManager) before dependency installs.")
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

    private func packageManagerVersionCommandSpecs(project: ProjectInfo) -> [(String, String, [String])] {
        guard project.packageManagerVersion != nil,
              let packageManager = project.packageManager,
              ["npm", "pnpm", "yarn", "bun"].contains(packageManager)
        else {
            return []
        }

        return [(packageManager, "/usr/bin/env", [packageManager, "--version"])]
    }

    private func shouldWarnAboutMissingPreferredTool(packageManager: String, resolvedPaths: [ResolvedTool]) -> Bool {
        guard let toolName = executableName(forPackageManager: packageManager) else {
            return false
        }

        return resolvedPaths.first(where: { $0.name == toolName })?.paths.isEmpty ?? true
    }

    private func missingPreferredToolAskFirstCommand(packageManager: String) -> String {
        switch packageManager {
        case "bundler":
            return "running Bundler commands before bundle is available"
        case "swiftpm":
            return "running SwiftPM commands before swift is available"
        case "go":
            return "running Go commands before go is available"
        case "cargo":
            return "running Cargo commands before cargo is available"
        case "python":
            return "running Python commands before python3 is available"
        default:
            return "substituting another package manager for \(packageManager)"
        }
    }

    private func missingPreferredToolWarning(packageManager: String) -> String {
        switch packageManager {
        case "bundler":
            return "Project files prefer Bundler, but bundle was not found on PATH; ask before running Bundler commands."
        case "swiftpm":
            return "Project files prefer SwiftPM, but swift was not found on PATH; ask before running SwiftPM commands."
        case "go":
            return "Project files prefer Go, but go was not found on PATH; ask before running Go commands."
        case "cargo":
            return "Project files prefer Cargo, but cargo was not found on PATH; ask before running Cargo commands."
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

        guard let activeToolVersion = versions.first(where: { $0.name == "node" }),
              activeToolVersion.available,
              let activeVersion = activeToolVersion.version
        else {
            return true
        }

        return versionsDiffer(requested: nodeHint, active: activeVersion)
    }

    private func pythonVersionNeedsVerification(project: ProjectInfo, versions: [ToolVersion]) -> Bool {
        guard let pythonHint = project.runtimeHints.python else {
            return false
        }

        guard let activeToolVersion = versions.first(where: { $0.name == "python3" }),
              activeToolVersion.available,
              let activeVersion = activeToolVersion.version
        else {
            return true
        }

        return pythonVersionsDiffer(requested: pythonHint, active: activeVersion)
    }

    private func packageManagerVersionNeedsVerification(project: ProjectInfo, versions: [ToolVersion]) -> Bool {
        guard let packageManager = project.packageManager,
              let packageManagerVersion = project.packageManagerVersion
        else {
            return false
        }

        guard let activeToolVersion = versions.first(where: { $0.name == packageManager }),
              activeToolVersion.available,
              let activeVersion = activeToolVersion.version
        else {
            return true
        }

        return packageManagerVersionsDiffer(requested: packageManagerVersion, active: activeVersion)
    }

    private func executableName(forPackageManager packageManager: String) -> String? {
        switch packageManager {
        case "npm", "pnpm", "yarn", "bun", "uv":
            return packageManager
        case "bundler":
            return "bundle"
        case "swiftpm":
            return "swift"
        case "go":
            return "go"
        case "cargo":
            return "cargo"
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

    private func packageManagerVersionsDiffer(requested: String, active: String) -> Bool {
        guard let requestedComponents = versionComponents(from: requested, limit: 3),
              let activeComponents = versionComponents(from: active, limit: 3),
              activeComponents.count >= requestedComponents.count
        else {
            return false
        }

        return Array(activeComponents.prefix(requestedComponents.count)) != requestedComponents
    }

    private func versionComponents(from value: String, limit: Int = 2) -> [Int]? {
        let numericVersion = value.drop { !$0.isNumber }
            .prefix { $0.isNumber || $0 == "." }
        let components = numericVersion
            .split(separator: ".")
            .prefix(limit)
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
