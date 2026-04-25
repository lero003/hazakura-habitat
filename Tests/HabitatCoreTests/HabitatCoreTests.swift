import Testing
import Foundation
@testable import HabitatCore

struct FakeCommandRunner: CommandRunning {
    let results: [String: CommandInfo]

    func run(executable: String, arguments: [String], timeout: TimeInterval) -> CommandInfo {
        let key = ([executable] + arguments).joined(separator: " ")
        return results[key] ?? CommandInfo(
            name: executable,
            args: arguments,
            exitCode: nil,
            durationMs: 0,
            timedOut: false,
            available: false,
            stdout: "",
            stderr: "missing"
        )
    }
}

struct HabitatCoreTests {
    @Test
    func scanPrefersPnpmWhenLockfileExists() throws {
        let projectURL = try makeProject(files: [
            "pnpm-lock.yaml": "lockfile",
            "package.json": "{}",
            ".nvmrc": "v20\n",
            ".env.example": "EXAMPLE=1\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.runtimeHints.node == "v20")
        #expect(result.policy.preferredCommands.contains("pnpm"))
        #expect(result.warnings.contains(where: { $0.contains("do not read real .env values") }))
    }

    @Test
    func scanWarnsWhenActiveNodeDiffersFromNvmrc() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "pnpm-lock.yaml": "lockfile",
            ".nvmrc": "v20\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v25.9.0", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.warnings.contains("Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node)."))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))
    }

    @Test
    func scanUsesNodeVersionFileForRuntimeInstallGuard() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
            ".node-version": "24.0.0\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v22.15.0", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".node-version"))
        #expect(result.project.runtimeHints.node == "24.0.0")
        #expect(result.warnings.contains("Active Node is v22.15.0, but project requests 24.0.0; ask before dependency installs (/opt/homebrew/bin/node)."))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))
    }

    @Test
    func scanWarnsBeforeSubstitutingMissingPreferredPackageManager() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "pnpm-lock.yaml": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.policy.askFirstCommands.contains("substituting another package manager for pnpm"))
        #expect(result.warnings.contains("Project files prefer pnpm, but pnpm was not found on PATH; ask before substituting another package manager."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        #expect(context.contains("Ask before `substituting another package manager for pnpm`."))
    }

    @Test
    func scanAsksBeforeLockfileMutation() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.policy.askFirstCommands.contains("modifying lockfiles"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(policy.contains("`modifying lockfiles`"))
    }

    @Test
    func scanDoesNotReadOrEmitSecretFileValues() throws {
        let secretValue = "sk-habitat-test-secret-123"
        let privateKeyMarker = "-----BEGIN OPENSSH PRIVATE KEY-----"
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            ".nvmrc": "v20\n",
            ".env": "OPENAI_API_KEY=\(secretValue)\n",
            ".env.example": "OPENAI_API_KEY=\n",
            "id_rsa": "\(privateKeyMarker)\n\(secretValue)\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".env"))
        #expect(result.project.detectedFiles.contains(".env.example"))
        #expect(result.project.runtimeHints.node == "v20")
        #expect(result.warnings.contains("Environment file exists; do not read .env values."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("OPENAI_API_KEY"))
            #expect(!artifact.contains(privateKeyMarker))
        }
    }

    @Test
    func scanPrefersProjectVenvForPythonCommands() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            ".python-version": "3.12\n",
        ])
        try FileManager.default.createDirectory(at: projectURL.appendingPathComponent(".venv"), withIntermediateDirectories: true)

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".venv"))
        #expect(result.project.packageManager == "python")
        #expect(result.project.runtimeHints.python == "3.12")
        #expect(result.policy.preferredCommands.first == ".venv/bin/python -m pytest")
        #expect(result.warnings.contains("Project .venv exists; use .venv/bin/python for Python commands before system python3."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Prefer `.venv/bin/python -m pytest`."))
        #expect(context.contains("Project .venv exists; use .venv/bin/python for Python commands before system python3."))
    }

    @Test
    func scanGuardsUvProjectsWhenUvIsMissing() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            "uv.lock": "version = 1\n",
            ".python-version": "3.12\n",
        ])
        try FileManager.default.createDirectory(at: projectURL.appendingPathComponent(".venv"), withIntermediateDirectories: true)

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env python3 --version": .init(name: "/usr/bin/env", args: ["python3", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Python 3.12.4", stderr: ""),
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
            "/usr/bin/which -a pip3": .init(name: "/usr/bin/which", args: ["-a", "pip3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pip3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "uv")
        #expect(result.project.detectedFiles.contains("uv.lock"))
        #expect(result.policy.preferredCommands == ["uv run", ".venv/bin/python -m pytest"])
        #expect(result.policy.askFirstCommands.contains("substituting another package manager for uv"))
        #expect(result.warnings.contains("Project files prefer uv, but uv was not found on PATH; ask before substituting another package manager."))
        #expect(result.warnings.contains("Project .venv exists; use .venv/bin/python for Python commands before system python3."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `uv` because project files point to it."))
        #expect(context.contains("Prefer `uv run`."))
        #expect(context.contains("Ask before `substituting another package manager for uv`."))
        #expect(policy.contains("`uv run`"))
        #expect(policy.contains("`substituting another package manager for uv`"))
    }

    @Test
    func scanWarnsWhenActivePythonDiffersFromPythonVersion() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            ".python-version": "3.12\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env python3 --version": .init(name: "/usr/bin/env", args: ["python3", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Python 3.11.9", stderr: ""),
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        #expect(result.project.runtimeHints.python == "3.12")
        #expect(result.warnings.contains("Active Python is Python 3.11.9, but project requests 3.12; ask before dependency installs (/opt/homebrew/bin/python3)."))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Python to project version hints"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(policy.contains("`dependency installs before matching active Python to project version hints`"))
    }

    @Test
    func reportWriterCreatesAllArtifacts() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["swift test"], askFirstCommands: ["pnpm install"], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            #expect(FileManager.default.fileExists(atPath: outputURL.appendingPathComponent(name).path))
        }
    }

    @Test
    func agentContextIncludesRuntimeMismatchWarnings() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: [".nvmrc", "pnpm-lock.yaml"], packageManager: "pnpm", runtimeHints: .init(node: "v20", python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["pnpm"], askFirstCommands: ["pnpm install"], forbiddenCommands: ["sudo"]),
            warnings: ["Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node)."],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Active Node is v25.9.0, but project requests v20; ask before dependency installs"))
    }

    @Test
    func commandPolicyIncludesRuntimeMismatchInstallGuard() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: [".nvmrc", "pnpm-lock.yaml"], packageManager: "pnpm", runtimeHints: .init(node: "v20", python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(
                preferredCommands: ["pnpm"],
                askFirstCommands: ["dependency installs before matching active Node to project version hints", "pnpm install"],
                forbiddenCommands: ["sudo"]
            ),
            warnings: ["Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node)."],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(policy.contains("`dependency installs before matching active Node to project version hints`"))
    }

    @Test
    func agentContextMarkdownSnapshotStaysActionable() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = markdownSnapshotScanResult()

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context == """
        # Agent Context

        ## Freshness
        - Scanned at: 2026-04-25T00:00:00Z
        - Project: /tmp/project

        ## Use
        - Use `pnpm` because project files point to it.
        - Prefer `pnpm`.
        - Prefer `pnpm test`.

        ## Avoid
        - Do not run `sudo`.
        - Do not run `brew upgrade`.

        ## Ask First
        - Ask before `substituting another package manager for pnpm`.
        - Ask before `dependency installs before matching active Node to project version hints`.
        - Ask before `pnpm install`.
        - Ask before `modifying lockfiles`.

        ## Mismatches
        - Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node).
        - Project files prefer pnpm, but pnpm was not found on PATH; ask before substituting another package manager.

        ## Notes
        - node --version unavailable: missing
        """)
    }

    @Test
    func commandPolicyMarkdownSnapshotKeepsInstallGuardsVisible() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = markdownSnapshotScanResult()

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(policy == """
        # Command Policy

        ## Allowed
        - `pnpm`
        - `pnpm test`
        - `read-only project inspection`
        - `test commands for the selected project`
        - `build commands for the selected project`

        ## Ask First
        - `substituting another package manager for pnpm`
        - `dependency installs before matching active Node to project version hints`
        - `pnpm install`
        - `modifying lockfiles`

        ## Forbidden
        - `sudo`
        - `brew upgrade`

        ## If Dependency Installation Seems Necessary
        - Re-check lockfiles and version hints first.
        - Prefer the project-specific package manager from `agent_context.md`.
        - Ask before any install, upgrade, uninstall, or global mutation.
        """)
    }

    @Test
    func scanKeepsGoingWhenCommandsAreMissing() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift package"
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "swiftpm")
        #expect(result.commands.allSatisfy { !$0.available })
        #expect(result.diagnostics.count == result.commands.count)
    }

    @Test
    func scanGuardsSwiftPMCommandsWhenSwiftIsMissing() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift package"
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "swiftpm")
        #expect(result.policy.preferredCommands == ["swift test", "swift build"])
        #expect(result.policy.askFirstCommands.contains("running SwiftPM commands before swift is available"))
        #expect(result.warnings.contains("Project files prefer SwiftPM, but swift was not found on PATH; ask before running SwiftPM commands."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running SwiftPM commands before swift is available`."))
        #expect(context.contains("Project files prefer SwiftPM, but swift was not found on PATH; ask before running SwiftPM commands."))
        #expect(policy.contains("`running SwiftPM commands before swift is available`"))
    }

    private func makeProject(files: [String: String]) throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

        for (path, contents) in files {
            let fileURL = root.appendingPathComponent(path)
            try contents.write(to: fileURL, atomically: true, encoding: .utf8)
        }

        return root
    }

    private func markdownSnapshotScanResult() -> ScanResult {
        ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: [".nvmrc", "package.json", "pnpm-lock.yaml"], packageManager: "pnpm", runtimeHints: .init(node: "v20", python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(
                preferredCommands: ["pnpm", "pnpm test"],
                askFirstCommands: [
                    "substituting another package manager for pnpm",
                    "dependency installs before matching active Node to project version hints",
                    "pnpm install",
                    "modifying lockfiles"
                ],
                forbiddenCommands: ["sudo", "brew upgrade"]
            ),
            warnings: [
                "Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node).",
                "Project files prefer pnpm, but pnpm was not found on PATH; ask before substituting another package manager."
            ],
            diagnostics: ["node --version unavailable: missing"]
        )
    }
}
