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
        #expect(result.policy.preferredCommands.contains("pnpm run"))
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
    func scanUsesToolVersionsForNodeRuntimeInstallGuard() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
            ".tool-versions": """
            nodejs 24.0.0
            ruby 3.3.0
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v22.15.0", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".tool-versions"))
        #expect(result.project.runtimeHints.node == "24.0.0")
        #expect(result.warnings.contains("Active Node is v22.15.0, but project requests 24.0.0; ask before dependency installs (/opt/homebrew/bin/node)."))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Active Node is v22.15.0, but project requests 24.0.0; ask before dependency installs"))
        #expect(policy.contains("`dependency installs before matching active Node to project version hints`"))
    }

    @Test
    func scanUsesPackageJsonEnginesNodeForRuntimeInstallGuard() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "engines": {
                "node": "20.x"
              },
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "package-lock.json": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v22.15.0", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.project.runtimeHints.node == "20.x")
        #expect(result.policy.preferredCommands == ["npm run test"])
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))
        #expect(result.warnings.contains("Active Node is v22.15.0, but project requests 20.x; ask before dependency installs (/opt/homebrew/bin/node)."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(scanResult.contains("\"node\" : \"20.x\""))
        #expect(context.contains("Active Node is v22.15.0, but project requests 20.x; ask before dependency installs"))
        #expect(policy.contains("`dependency installs before matching active Node to project version hints`"))
    }

    @Test
    func scanAcceptsSatisfiedPackageJsonEnginesNodeRange() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "engines": {
                "node": ">=20 <22"
              },
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "package-lock.json": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v21.6.2", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.project.runtimeHints.node == ">=20 <22")
        #expect(result.policy.preferredCommands == ["npm run test"])
        #expect(!result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))
        #expect(!result.warnings.contains(where: { $0.contains("Project requests Node >=20 <22") }))
        #expect(!result.warnings.contains(where: { $0.contains("project requests >=20 <22") }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(!context.contains("dependency installs before matching active Node to project version hints"))
        #expect(!policy.contains("`dependency installs before matching active Node to project version hints`"))
    }

    @Test
    func scanAcceptsSatisfiedPackageJsonEnginesNodeOrRange() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "engines": {
                "node": ">=18 <19 || >=20 <21"
              },
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "package-lock.json": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.11.1", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.project.runtimeHints.node == ">=18 <19 || >=20 <21")
        #expect(result.policy.preferredCommands == ["npm run test"])
        #expect(!result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))
        #expect(!result.warnings.contains(where: { $0.contains(">=18 <19 || >=20 <21") }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(!context.contains("dependency installs before matching active Node to project version hints"))
        #expect(!policy.contains("`dependency installs before matching active Node to project version hints`"))
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
        #expect(result.policy.askFirstCommands.contains("running pnpm commands before pnpm is available"))
        #expect(result.warnings.contains("Project files prefer pnpm, but pnpm was not found on PATH; ask before running pnpm commands or substituting another package manager."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        #expect(context.contains("Ask before `running pnpm commands before pnpm is available`."))
    }

    @Test
    func scanGuardsNpmLockfileWhenNpmIsMissing() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "package-lock.json": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.policy.preferredCommands == ["npm run test"])
        #expect(result.policy.askFirstCommands.contains("running npm commands before npm is available"))
        #expect(result.policy.askFirstCommands.contains("npm install"))
        #expect(result.warnings.contains("Project files prefer npm, but npm was not found on PATH; ask before running npm commands or substituting another package manager."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running npm commands before npm is available`."))
        #expect(context.contains("Project files prefer npm, but npm was not found on PATH; ask before running npm commands or substituting another package manager."))
        #expect(policy.contains("`running npm commands before npm is available`"))
    }

    @Test
    func scanGuardsYarnAndBunLockfilesWhenPreferredToolIsMissing() throws {
        let cases: [(lockfile: String, packageManager: String, preferredCommand: String, installCommand: String)] = [
            ("yarn.lock", "yarn", "yarn run test", "yarn install"),
            ("bun.lock", "bun", "bun test", "bun install"),
            ("bun.lockb", "bun", "bun test", "bun install"),
        ]

        for testCase in cases {
            let projectURL = try makeProject(files: [
                "package.json": """
                {
                  "name": "demo",
                  "scripts": {
                    "test": "vitest run"
                  }
                }
                """,
                testCase.lockfile: "lockfile",
            ])

            let runner = FakeCommandRunner(results: [
                "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            ])

            let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)
            let missingToolGuard = "running \(testCase.packageManager) commands before \(testCase.packageManager) is available"
            let missingToolWarning = "Project files prefer \(testCase.packageManager), but \(testCase.packageManager) was not found on PATH; ask before running \(testCase.packageManager) commands or substituting another package manager."

            #expect(result.project.packageManager == testCase.packageManager)
            #expect(result.policy.preferredCommands == [testCase.preferredCommand])
            #expect(result.policy.askFirstCommands.contains(missingToolGuard))
            #expect(result.policy.askFirstCommands.contains(testCase.installCommand))
            #expect(result.warnings.contains(missingToolWarning))

            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try ReportWriter().write(scanResult: result, outputURL: outputURL)
            let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
            let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

            #expect(context.contains("Ask before `\(missingToolGuard)`."))
            #expect(context.contains(missingToolWarning))
            #expect(policy.contains("`\(missingToolGuard)`"))
        }
    }

    @Test
    func scanAsksBeforeInstallsWhenMultipleJavaScriptLockfilesExist() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "npm lockfile",
            "pnpm-lock.yaml": "pnpm lockfile",
            "yarn.lock": "yarn lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.policy.askFirstCommands.contains("dependency installs when multiple JavaScript lockfiles exist"))
        #expect(result.warnings.contains("Multiple JavaScript lockfiles detected (package-lock.json, pnpm-lock.yaml, yarn.lock); ask before dependency installs."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `dependency installs when multiple JavaScript lockfiles exist`."))
        #expect(context.contains("Multiple JavaScript lockfiles detected (package-lock.json, pnpm-lock.yaml, yarn.lock); ask before dependency installs."))
        #expect(policy.contains("`dependency installs when multiple JavaScript lockfiles exist`"))
    }

    @Test
    func scanPrefersBunWhenTextLockfileExists() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "scripts": {
                "test": "bun test"
              }
            }
            """,
            "bun.lock": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a bun": .init(name: "/usr/bin/which", args: ["-a", "bun"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/bun", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains("bun.lock"))
        #expect(result.project.packageManager == "bun")
        #expect(result.policy.preferredCommands == ["bun test"])
        #expect(result.policy.askFirstCommands.contains("bun install"))
        #expect(result.policy.askFirstCommands.contains("bun add"))
        #expect(result.policy.askFirstCommands.contains("bun update"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `bun` because project files point to it."))
        #expect(context.contains("Prefer `bun test`."))
        #expect(context.contains("Ask before `bun install`."))
        #expect(policy.contains("`bun test`"))
        #expect(policy.contains("`bun install`"))
    }

    @Test
    func scanPrefersPnpmWhenWorkspaceFileExists() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "workspace-root",
              "scripts": {
                "build": "pnpm -r build",
                "test": "pnpm -r test"
              }
            }
            """,
            "pnpm-workspace.yaml": """
            packages:
              - "packages/*"
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains("pnpm-workspace.yaml"))
        #expect(result.project.packageManager == "pnpm")
        #expect(result.policy.preferredCommands == ["pnpm run test", "pnpm run build"])
        #expect(result.policy.askFirstCommands.contains("pnpm install"))
        #expect(!result.policy.askFirstCommands.contains("running pnpm commands before pnpm is available"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `pnpm` because project files point to it."))
        #expect(context.contains("Prefer `pnpm run test`."))
        #expect(!context.contains("Use `npm`"))
        #expect(policy.contains("`pnpm run build`"))
        #expect(policy.contains("`pnpm install`"))
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
    func scanForbidsDestructiveDeletionOutsideSelectedProject() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.policy.forbiddenCommands.contains("destructive file deletion outside the selected project"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Do not run `destructive file deletion outside the selected project`."))
        #expect(policy.contains("`destructive file deletion outside the selected project`"))
    }

    @Test
    func scanTreatsPackageJsonOnlyAsNpmProjectAndGuardsMissingNpm() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.project.packageScripts.isEmpty)
        #expect(result.policy.preferredCommands == ["npm run"])
        #expect(result.policy.askFirstCommands.contains("npm ci"))
        #expect(result.policy.askFirstCommands.contains("npm update"))
        #expect(result.policy.askFirstCommands.contains("running npm commands before npm is available"))
        #expect(result.warnings.contains("Project files prefer npm, but npm was not found on PATH; ask before running npm commands or substituting another package manager."))
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `npm` because project files point to it."))
        #expect(context.contains("Prefer `npm run`."))
        #expect(context.contains("Ask before `running npm commands before npm is available`."))
        #expect(context.contains("Ask before `npm ci`."))
        #expect(policy.contains("`npm run`"))
        #expect(policy.contains("`npm ci`"))
        #expect(policy.contains("`npm update`"))
        #expect(policy.contains("`running npm commands before npm is available`"))
    }

    @Test
    func scanAsksBeforeJavaScriptCommandsWhenNodeRuntimeIsMissing() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "package-lock.json": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.policy.preferredCommands == ["npm run test"])
        #expect(result.policy.askFirstCommands.contains("running JavaScript commands before node is available"))
        #expect(!result.policy.askFirstCommands.contains("running npm commands before npm is available"))
        #expect(result.warnings.contains("Project files need Node, but node was not found on PATH; ask before running JavaScript commands."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running JavaScript commands before node is available`."))
        #expect(context.contains("Project files need Node, but node was not found on PATH; ask before running JavaScript commands."))
        #expect(policy.contains("`running JavaScript commands before node is available`"))
    }

    @Test
    func scanGuardsJavaScriptDependencyMutationCommands() throws {
        let cases: [(lockfile: String, packageManager: String, commands: [String])] = [
            ("package-lock.json", "npm", ["npm install", "npm ci", "npm update"]),
            ("pnpm-lock.yaml", "pnpm", ["pnpm install", "pnpm add", "pnpm update"]),
            ("yarn.lock", "yarn", ["yarn install", "yarn add", "yarn up"]),
            ("bun.lock", "bun", ["bun install", "bun add", "bun update"]),
            ("bun.lockb", "bun", ["bun install", "bun add", "bun update"]),
        ]

        for testCase in cases {
            let projectURL = try makeProject(files: [
                "package.json": "{}",
                testCase.lockfile: "lockfile",
            ])

            let result = HabitatScanner(runner: FakeCommandRunner(results: [
                "/usr/bin/which -a \(testCase.packageManager)": .init(name: "/usr/bin/which", args: ["-a", testCase.packageManager], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/\(testCase.packageManager)", stderr: ""),
            ])).scan(projectURL: projectURL)

            #expect(result.project.packageManager == testCase.packageManager)

            for command in testCase.commands {
                #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
            }

            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try ReportWriter().write(scanResult: result, outputURL: outputURL)
            let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

            for command in testCase.commands {
                #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
            }
        }
    }

    @Test
    func scanUsesPackageJsonScriptNamesForJavaScriptPreferredCommands() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "scripts": {
                "build": "vite build",
                "deploy": "secret deploy target",
                "test": "vitest run"
              }
            }
            """,
            "package-lock.json": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.project.packageScripts == ["build", "deploy", "test"])
        #expect(result.policy.preferredCommands == ["npm run test", "npm run build"])

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Prefer `npm run test`."))
        #expect(context.contains("Prefer `npm run build`."))
        #expect(!context.contains("secret deploy target"))
        #expect(!context.contains("npm run deploy"))
    }

    @Test
    func scanUsesPackageManagerFieldWhenNoJavaScriptLockfileExists() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "packageManager": "pnpm@9.15.4",
              "scripts": {
                "build": "vite build",
                "test": "vitest run"
              }
            }
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "9.15.4", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.packageManagerVersion == "9.15.4")
        #expect(result.project.packageScripts == ["build", "test"])
        #expect(result.policy.preferredCommands == ["pnpm run test", "pnpm run build"])
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))
        #expect(!result.policy.askFirstCommands.contains("running pnpm commands before pnpm is available"))
        #expect(!result.policy.askFirstCommands.contains("dependency installs before matching pnpm to packageManager version"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `pnpm@9.15.4` because `package.json` packageManager points to it."))
        #expect(context.contains("Prefer `pnpm run test`."))
        #expect(policy.contains("`pnpm run build`"))
    }

    @Test
    func scanAsksBeforeInstallsWhenPackageManagerFieldConflictsWithLockfile() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "packageManager": "pnpm@9.15.4",
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "yarn.lock": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a yarn": .init(name: "/usr/bin/which", args: ["-a", "yarn"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/yarn", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "yarn")
        #expect(result.project.packageManagerVersion == nil)
        #expect(result.project.declaredPackageManager == "pnpm")
        #expect(result.project.declaredPackageManagerVersion == "9.15.4")
        #expect(result.policy.preferredCommands == ["yarn run test"])
        #expect(result.policy.askFirstCommands.contains("dependency installs when package.json packageManager conflicts with lockfiles"))
        #expect(result.warnings.contains("package.json requests pnpm, but project lockfiles select yarn; ask before dependency installs."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(scanResult.contains("\"declaredPackageManager\" : \"pnpm\""))
        #expect(scanResult.contains("\"declaredPackageManagerVersion\" : \"9.15.4\""))
        #expect(context.contains("Use `yarn` because project files point to it."))
        #expect(context.contains("Ask before `dependency installs when package.json packageManager conflicts with lockfiles`."))
        #expect(context.contains("package.json requests pnpm, but project lockfiles select yarn; ask before dependency installs."))
        #expect(policy.contains("`dependency installs when package.json packageManager conflicts with lockfiles`"))
    }

    @Test
    func scanAsksBeforeInstallsWhenPackageManagerVersionDiffers() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "packageManager": "pnpm@9.15.4"
            }
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "10.0.0", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.packageManagerVersion == "9.15.4")
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching pnpm to packageManager version"))
        #expect(result.warnings.contains("Project requests pnpm 9.15.4 via package.json; active pnpm is 10.0.0; ask before dependency installs."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `pnpm@9.15.4` because `package.json` packageManager points to it."))
        #expect(context.contains("Ask before `dependency installs before matching pnpm to packageManager version`."))
        #expect(policy.contains("`dependency installs before matching pnpm to packageManager version`"))
    }

    @Test
    func scanAsksBeforeInstallsWhenPackageManagerVersionCannotBeVerified() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "packageManager": "yarn@4.8.1"
            }
            """,
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "yarn")
        #expect(result.project.packageManagerVersion == "4.8.1")
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching yarn to packageManager version"))
        #expect(result.warnings.contains("Project requests yarn 4.8.1 via package.json; verify active yarn before dependency installs."))
    }

    @Test
    func scanUsesPackageJsonVoltaPinsForNodeAndPackageManagerVersionGuards() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "volta": {
                "node": "20.11.1",
                "pnpm": "9.15.4"
              },
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "pnpm-lock.yaml": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v22.15.0", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "10.0.0", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.packageManagerVersion == "9.15.4")
        #expect(result.project.runtimeHints.node == "20.11.1")
        #expect(result.project.declaredPackageManager == nil)
        #expect(result.policy.preferredCommands == ["pnpm run test"])
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching pnpm to packageManager version"))
        #expect(result.warnings.contains("Active Node is v22.15.0, but project requests 20.11.1; ask before dependency installs (/opt/homebrew/bin/node)."))
        #expect(result.warnings.contains("Project requests pnpm 9.15.4 via package.json; active pnpm is 10.0.0; ask before dependency installs."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(scanResult.contains("\"packageManagerVersion\" : \"9.15.4\""))
        #expect(scanResult.contains("\"node\" : \"20.11.1\""))
        #expect(context.contains("Use `pnpm@9.15.4` because project metadata pins it."))
        #expect(context.contains("Ask before `dependency installs before matching pnpm to packageManager version`."))
        #expect(context.contains("Active Node is v22.15.0, but project requests 20.11.1; ask before dependency installs"))
        #expect(policy.contains("`dependency installs before matching active Node to project version hints`"))
        #expect(policy.contains("`dependency installs before matching pnpm to packageManager version`"))
    }

    @Test
    func scanAsksBeforeInstallsWhenPackageManagerVersionCommandFails() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "packageManager": "pnpm@9.15.4"
            }
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 127, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "env: pnpm: No such file or directory"),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.packageManagerVersion == "9.15.4")
        #expect(result.tools.versions.contains(where: { $0.name == "pnpm" && !$0.available && $0.version == nil }))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching pnpm to packageManager version"))
        #expect(result.warnings.contains("Project requests pnpm 9.15.4 via package.json; verify active pnpm before dependency installs."))
        #expect(result.diagnostics.contains("pnpm --version failed with exit code 127: env: pnpm: No such file or directory"))
    }

    @Test
    func scanDoesNotReadOrEmitSecretFileValues() throws {
        let secretValue = "sk-habitat-test-secret-123"
        let privateKeyMarker = "-----BEGIN OPENSSH PRIVATE KEY-----"
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            ".nvmrc": "v20\n",
            ".env": "OPENAI_API_KEY=\(secretValue)\n",
            ".env.local": "LOCAL_TOKEN=\(secretValue)\n",
            ".env.example": "OPENAI_API_KEY=\n",
            ".npmrc": "//registry.npmjs.org/:_authToken=\(secretValue)\n",
            ".yarnrc.yml": "npmAuthToken: \(secretValue)\n",
            "id_rsa": "\(privateKeyMarker)\n\(secretValue)\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".env"))
        #expect(result.project.detectedFiles.contains(".env.local"))
        #expect(result.project.detectedFiles.contains(".env.example"))
        #expect(result.project.detectedFiles.contains(".npmrc"))
        #expect(result.project.detectedFiles.contains(".yarnrc.yml"))
        #expect(result.project.runtimeHints.node == "v20")
        #expect(result.warnings.contains("Environment file exists; do not read .env values."))
        #expect(result.warnings.contains("Package manager auth config exists; do not read token values from .npmrc or yarn config files."))
        #expect(result.policy.forbiddenCommands.contains("read package manager auth config values"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("OPENAI_API_KEY"))
            #expect(!artifact.contains("LOCAL_TOKEN"))
            #expect(!artifact.contains("_authToken"))
            #expect(!artifact.contains("npmAuthToken"))
            #expect(!artifact.contains(privateKeyMarker))
        }

        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        #expect(context.contains("Do not run `read .env values`."))
        #expect(context.contains("Do not run `read package manager auth config values`."))
    }

    @Test
    func scanWarnsForCommonSecretEnvironmentFiles() throws {
        for envFile in [".env.local", ".env.development", ".env.development.local", ".env.test", ".env.test.local", ".env.production", ".env.production.local"] {
            let projectURL = try makeProject(files: [
                envFile: "SECRET=value\n",
            ])

            let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

            #expect(result.project.detectedFiles.contains(envFile), "Expected \(envFile) to be detected")
            #expect(result.warnings.contains("Environment file exists; do not read .env values."), "Expected \(envFile) to trigger secret env guidance")
        }
    }

    @Test
    func scanDetectsArbitrarySecretEnvironmentFilesWithoutReadingValues() throws {
        let secretValue = "hh_secret_value_from_stage_env"
        let projectURL = try makeProject(files: [
            ".env.staging": "STAGING_TOKEN=\(secretValue)\n",
            ".env.preview.local": "PREVIEW_TOKEN=\(secretValue)\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".env.preview.local"))
        #expect(result.project.detectedFiles.contains(".env.staging"))
        #expect(result.warnings.contains("Environment file exists; do not read .env values."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("STAGING_TOKEN"))
            #expect(!artifact.contains("PREVIEW_TOKEN"))
        }

        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let report = try String(contentsOf: outputURL.appendingPathComponent("environment_report.md"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(scanResult.contains(".env.staging"))
        #expect(report.contains(".env.staging"))
        #expect(context.contains("Do not run `read .env values`."))
    }

    @Test
    func scanDetectsEnvrcFilesWithoutReadingValues() throws {
        let secretValue = "hh_secret_value_from_envrc"
        let projectURL = try makeProject(files: [
            ".envrc": "export HABITAT_TOKEN=\(secretValue)\n",
            ".envrc.private": "export PRIVATE_TOKEN=\(secretValue)\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".envrc"))
        #expect(result.project.detectedFiles.contains(".envrc.private"))
        #expect(result.warnings.contains("Direnv environment file exists; do not read .envrc values."))
        #expect(result.policy.forbiddenCommands.contains("read .envrc values"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("HABITAT_TOKEN"))
            #expect(!artifact.contains("PRIVATE_TOKEN"))
        }

        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Do not run `read .envrc values`."))
        #expect(!context.contains("Do not run `read .env values`."))
        #expect(policy.contains("`read .envrc values`"))
    }

    @Test
    func scanUsesCleanReadOnlyFallbackWhenNoPackageManagerSignalExists() throws {
        let projectURL = try makeProject(files: [:])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == nil)
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("- Use read-only inspection first."))
        #expect(!context.contains("Prefer `Use read-only inspection first`."))
        #expect(policy.contains("`read-only project inspection`"))
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
    func scanTreatsSecondaryPythonSignalsAsPythonProjects() throws {
        for signal in ["requirements-dev.txt", "Pipfile", "Pipfile.lock"] {
            let projectURL = try makeProject(files: [
                signal: "test dependency signal\n",
            ])

            let runner = FakeCommandRunner(results: [
                "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
            ])

            let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

            #expect(result.project.packageManager == "python", "Expected \(signal) to select Python commands")
            #expect(result.policy.preferredCommands == ["python3 -m pytest"])

            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try ReportWriter().write(scanResult: result, outputURL: outputURL)
            let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

            #expect(context.contains("Use `python` because project files point to it."))
            #expect(context.contains("Prefer `python3 -m pytest`."))
        }
    }

    @Test
    func scanGuardsPythonProjectsWhenPython3IsMissing() throws {
        let projectURL = try makeProject(files: [
            "requirements.txt": "pytest\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        #expect(result.policy.preferredCommands == ["python3 -m pytest"])
        #expect(result.policy.askFirstCommands.contains("running Python commands before python3 is available"))
        #expect(result.policy.askFirstCommands.contains("python3 -m pip install"))
        #expect(result.warnings.contains("Project files prefer Python, but python3 was not found on PATH; ask before running Python commands."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `python` because project files point to it."))
        #expect(context.contains("Ask before `running Python commands before python3 is available`."))
        #expect(context.contains("Project files prefer Python, but python3 was not found on PATH; ask before running Python commands."))
        #expect(policy.contains("`running Python commands before python3 is available`"))
        #expect(policy.contains("`python3 -m pytest`"))
    }

    @Test
    func scanGuardsPythonPipInstallAliases() throws {
        let projectURL = try makeProject(files: [
            "requirements.txt": "pytest\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        for command in ["pip install", "pip3 install", "python -m pip install", "python3 -m pip install"] {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }

        for command in ["pip install --user", "pip3 install --user", "python -m pip install --user", "python3 -m pip install --user"] {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `pip install`."))
        #expect(context.contains("Ask before `python3 -m pip install`."))
        #expect(policy.contains("`pip3 install`"))
        #expect(policy.contains("`python -m pip install`"))
        #expect(policy.contains("`python3 -m pip install --user`"))
    }

    @Test
    func scanAsksBeforeInstallsWhenPythonDependencySignalsAreMixed() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            "requirements.txt": "pytest\n",
            "requirements-dev.txt": "ruff\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        #expect(result.policy.askFirstCommands.contains("dependency installs before choosing between pyproject.toml and requirements files"))
        #expect(result.warnings.contains("Python dependency files include both pyproject.toml and requirements files; ask before dependency installs until the source of truth is clear."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `dependency installs before choosing between pyproject.toml and requirements files`."))
        #expect(context.contains("Python dependency files include both pyproject.toml and requirements files; ask before dependency installs until the source of truth is clear."))
        #expect(policy.contains("`dependency installs before choosing between pyproject.toml and requirements files`"))
    }

    @Test
    func scanAsksBeforeInstallsWhenUvLockAndRequirementsFilesCoexist() throws {
        let projectURL = try makeProject(files: [
            "uv.lock": "version = 1\n",
            "requirements.txt": "pytest\n",
            "requirements-dev.txt": "ruff\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a uv": .init(name: "/usr/bin/which", args: ["-a", "uv"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/uv", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "uv")
        #expect(result.policy.preferredCommands == ["uv run"])
        #expect(result.policy.askFirstCommands.contains("uv sync"))
        #expect(result.policy.askFirstCommands.contains("dependency installs before choosing between uv.lock and requirements files"))
        #expect(result.warnings.contains("Python dependency files include both uv.lock and requirements files; ask before dependency installs until the source of truth is clear."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `uv` because project files point to it."))
        #expect(context.contains("Ask before `dependency installs before choosing between uv.lock and requirements files`."))
        #expect(context.contains("Python dependency files include both uv.lock and requirements files; ask before dependency installs until the source of truth is clear."))
        #expect(policy.contains("`dependency installs before choosing between uv.lock and requirements files`"))
    }

    @Test
    func scanResolvesPythonPipAndRubyTooling() throws {
        let projectURL = try makeProject(files: [
            "requirements.txt": "pytest\n",
            "Gemfile": "source \"https://rubygems.org\"\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env python --version": .init(name: "/usr/bin/env", args: ["python", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Python 3.12.4", stderr: ""),
            "/usr/bin/env python3 --version": .init(name: "/usr/bin/env", args: ["python3", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Python 3.12.4", stderr: ""),
            "/usr/bin/env pip --version": .init(name: "/usr/bin/env", args: ["pip", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "pip 24.0", stderr: ""),
            "/usr/bin/env pip3 --version": .init(name: "/usr/bin/env", args: ["pip3", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "pip 24.0", stderr: ""),
            "/usr/bin/env ruby --version": .init(name: "/usr/bin/env", args: ["ruby", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "ruby 3.3.0", stderr: ""),
            "/usr/bin/env gem --version": .init(name: "/usr/bin/env", args: ["gem", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "3.5.0", stderr: ""),
            "/usr/bin/which -a python": .init(name: "/usr/bin/which", args: ["-a", "python"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python", stderr: ""),
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
            "/usr/bin/which -a pip": .init(name: "/usr/bin/which", args: ["-a", "pip"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pip", stderr: ""),
            "/usr/bin/which -a pip3": .init(name: "/usr/bin/which", args: ["-a", "pip3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pip3", stderr: ""),
            "/usr/bin/which -a ruby": .init(name: "/usr/bin/which", args: ["-a", "ruby"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/ruby", stderr: ""),
            "/usr/bin/which -a gem": .init(name: "/usr/bin/which", args: ["-a", "gem"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/gem", stderr: ""),
            "/usr/bin/which -a bundle": .init(name: "/usr/bin/which", args: ["-a", "bundle"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/bundle", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        for tool in ["python", "python3", "pip", "pip3", "ruby", "gem"] {
            #expect(result.tools.resolvedPaths.contains(where: { $0.name == tool && !$0.paths.isEmpty }), "Expected \(tool) paths in scan_result.json")
            #expect(result.tools.versions.contains(where: { $0.name == tool && $0.available }), "Expected \(tool) version in scan_result.json")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let report = try String(contentsOf: outputURL.appendingPathComponent("environment_report.md"), encoding: .utf8)

        #expect(scanResult.contains("\"name\" : \"pip3\""))
        #expect(scanResult.contains("\"name\" : \"ruby\""))
        #expect(report.contains("- pip3: /opt/homebrew/bin/pip3"))
        #expect(report.contains("- ruby: /opt/homebrew/bin/ruby"))
    }

    @Test
    func scanResolvesUvAndPyenvPythonTooling() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            "uv.lock": "version = 1\n",
            ".python-version": "3.12\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env uv --version": .init(name: "/usr/bin/env", args: ["uv", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "uv 0.7.2", stderr: ""),
            "/usr/bin/env pyenv --version": .init(name: "/usr/bin/env", args: ["pyenv", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "pyenv 2.5.5", stderr: ""),
            "/usr/bin/which -a uv": .init(name: "/usr/bin/which", args: ["-a", "uv"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/uv", stderr: ""),
            "/usr/bin/which -a pyenv": .init(name: "/usr/bin/which", args: ["-a", "pyenv"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pyenv", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "uv")
        for tool in ["uv", "pyenv"] {
            #expect(result.tools.resolvedPaths.contains(where: { $0.name == tool && !$0.paths.isEmpty }), "Expected \(tool) paths in scan_result.json")
            #expect(result.tools.versions.contains(where: { $0.name == tool && $0.available }), "Expected \(tool) version in scan_result.json")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let report = try String(contentsOf: outputURL.appendingPathComponent("environment_report.md"), encoding: .utf8)

        #expect(scanResult.contains("\"name\" : \"uv\""))
        #expect(scanResult.contains("\"version\" : \"pyenv 2.5.5\""))
        #expect(report.contains("- uv: /opt/homebrew/bin/uv"))
        #expect(report.contains("- pyenv: pyenv 2.5.5"))
    }

    @Test
    func scanTreatsBundlerSignalsAsRubyProjectsAndGuardsMissingBundle() throws {
        for signal in ["Gemfile", "Gemfile.lock"] {
            let projectURL = try makeProject(files: [
                signal: "ruby dependency signal\n",
            ])

            let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

            #expect(result.project.packageManager == "bundler", "Expected \(signal) to select Bundler commands")
            #expect(result.policy.preferredCommands == ["bundle exec"])
            #expect(result.policy.askFirstCommands.contains("running Bundler commands before bundle is available"))
            #expect(result.policy.askFirstCommands.contains("bundle install"))
            #expect(result.warnings.contains("Project files prefer Bundler, but bundle was not found on PATH; ask before running Bundler commands."))
            #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try ReportWriter().write(scanResult: result, outputURL: outputURL)
            let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
            let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

            #expect(context.contains("Use `bundler` because project files point to it."))
            #expect(context.contains("Prefer `bundle exec`."))
            #expect(context.contains("Ask before `running Bundler commands before bundle is available`."))
            #expect(context.contains("Ask before `bundle install`."))
            #expect(policy.contains("`bundle exec`"))
            #expect(policy.contains("`running Bundler commands before bundle is available`"))
        }
    }

    @Test
    func scanTreatsGoModAsGoProjectAndGuardsMissingGo() throws {
        let projectURL = try makeProject(files: [
            "go.mod": "module example.com/demo\n\ngo 1.22\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "go")
        #expect(result.policy.preferredCommands == ["go test ./...", "go build ./..."])
        #expect(result.policy.askFirstCommands.contains("running Go commands before go is available"))
        #expect(result.policy.askFirstCommands.contains("go get"))
        #expect(result.warnings.contains("Project files prefer Go, but go was not found on PATH; ask before running Go commands."))
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `go` because project files point to it."))
        #expect(context.contains("Prefer `go test ./...`."))
        #expect(context.contains("Ask before `running Go commands before go is available`."))
        #expect(context.contains("Ask before `go mod tidy`."))
        #expect(policy.contains("`go test ./...`"))
        #expect(policy.contains("`go get`"))
    }

    @Test
    func scanTreatsCargoTomlAsCargoProjectAndGuardsMissingCargo() throws {
        let projectURL = try makeProject(files: [
            "Cargo.toml": """
            [package]
            name = "demo"
            version = "0.1.0"
            edition = "2021"
            """,
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "cargo")
        #expect(result.policy.preferredCommands == ["cargo test", "cargo build"])
        #expect(result.policy.askFirstCommands.contains("running Cargo commands before cargo is available"))
        #expect(result.policy.askFirstCommands.contains("cargo add"))
        #expect(result.policy.askFirstCommands.contains("cargo update"))
        #expect(result.warnings.contains("Project files prefer Cargo, but cargo was not found on PATH; ask before running Cargo commands."))
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `cargo` because project files point to it."))
        #expect(context.contains("Prefer `cargo test`."))
        #expect(context.contains("Ask before `running Cargo commands before cargo is available`."))
        #expect(context.contains("Ask before `cargo update`."))
        #expect(policy.contains("`cargo test`"))
        #expect(policy.contains("`cargo add`"))
    }

    @Test
    func scanTreatsBrewfileAsHomebrewProjectAndGuardsBundleMutation() throws {
        let projectURL = try makeProject(files: [
            "Brewfile": "brew \"swiftlint\"\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "homebrew")
        #expect(result.policy.preferredCommands == ["brew bundle check"])
        #expect(result.policy.askFirstCommands.contains("running Homebrew Bundle commands before brew is available"))
        #expect(result.policy.askFirstCommands.contains("brew bundle"))
        #expect(result.policy.askFirstCommands.contains("brew bundle install"))
        #expect(result.policy.askFirstCommands.contains("brew bundle cleanup"))
        #expect(result.policy.askFirstCommands.contains("brew bundle dump"))
        #expect(result.warnings.contains("Project files include Brewfile, but brew was not found on PATH; ask before running Homebrew Bundle commands."))
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `homebrew` because project files point to it."))
        #expect(context.contains("Prefer `brew bundle check`."))
        #expect(context.contains("Ask before `running Homebrew Bundle commands before brew is available`."))
        #expect(context.contains("Ask before `brew bundle`."))
        #expect(context.contains("Project files include Brewfile, but brew was not found on PATH; ask before running Homebrew Bundle commands."))
        #expect(policy.contains("`brew bundle check`"))
        #expect(policy.contains("`brew bundle install`"))
        #expect(policy.contains("`brew bundle cleanup`"))
        #expect(policy.contains("`brew bundle dump`"))
    }

    @Test
    func scanTreatsPodfileAsCocoaPodsProjectAndGuardsPodMutation() throws {
        for signal in ["Podfile", "Podfile.lock"] {
            let projectURL = try makeProject(files: [
                signal: "cocoapods dependency signal\n",
            ])

            let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

            #expect(result.project.packageManager == "cocoapods", "Expected \(signal) to select CocoaPods guidance")
            #expect(result.project.detectedFiles.contains(signal))
            #expect(result.policy.preferredCommands == ["pod --version"])
            #expect(result.policy.askFirstCommands.contains("running CocoaPods commands before pod is available"))
            #expect(result.policy.askFirstCommands.contains("pod install"))
            #expect(result.policy.askFirstCommands.contains("pod update"))
            #expect(result.policy.askFirstCommands.contains("pod repo update"))
            #expect(result.policy.askFirstCommands.contains("pod deintegrate"))
            #expect(result.warnings.contains("Project files prefer CocoaPods, but pod was not found on PATH; ask before running CocoaPods commands."))
            #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try ReportWriter().write(scanResult: result, outputURL: outputURL)
            let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
            let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

            #expect(context.contains("Use `cocoapods` because project files point to it."))
            #expect(context.contains("Prefer `pod --version`."))
            #expect(context.contains("Ask before `running CocoaPods commands before pod is available`."))
            #expect(context.contains("Ask before `pod install`."))
            #expect(context.contains("Project files prefer CocoaPods, but pod was not found on PATH; ask before running CocoaPods commands."))
            #expect(policy.contains("`pod --version`"))
            #expect(policy.contains("`pod install`"))
            #expect(policy.contains("`pod update`"))
            #expect(policy.contains("`pod repo update`"))
            #expect(policy.contains("`pod deintegrate`"))
        }
    }

    @Test
    func scanTreatsCartfileAsCarthageProjectAndGuardsCarthageMutation() throws {
        for signal in ["Cartfile", "Cartfile.resolved"] {
            let projectURL = try makeProject(files: [
                signal: "github \"Alamofire/Alamofire\"\n",
            ])

            let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

            #expect(result.project.packageManager == "carthage", "Expected \(signal) to select Carthage guidance")
            #expect(result.project.detectedFiles.contains(signal))
            #expect(result.policy.preferredCommands == ["carthage version"])
            #expect(result.policy.askFirstCommands.contains("running Carthage commands before carthage is available"))
            #expect(result.policy.askFirstCommands.contains("carthage bootstrap"))
            #expect(result.policy.askFirstCommands.contains("carthage update"))
            #expect(result.policy.askFirstCommands.contains("carthage checkout"))
            #expect(result.policy.askFirstCommands.contains("carthage build"))
            #expect(result.warnings.contains("Project files prefer Carthage, but carthage was not found on PATH; ask before running Carthage commands."))
            #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try ReportWriter().write(scanResult: result, outputURL: outputURL)
            let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
            let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

            #expect(context.contains("Use `carthage` because project files point to it."))
            #expect(context.contains("Prefer `carthage version`."))
            #expect(context.contains("Ask before `running Carthage commands before carthage is available`."))
            #expect(context.contains("Ask before `carthage bootstrap`."))
            #expect(context.contains("Project files prefer Carthage, but carthage was not found on PATH; ask before running Carthage commands."))
            #expect(policy.contains("`carthage version`"))
            #expect(policy.contains("`carthage bootstrap`"))
            #expect(policy.contains("`carthage update`"))
            #expect(policy.contains("`carthage checkout`"))
            #expect(policy.contains("`carthage build`"))
        }
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
        #expect(result.policy.askFirstCommands.contains("running uv commands before uv is available"))
        #expect(result.warnings.contains("Project files prefer uv, but uv was not found on PATH; ask before running uv commands or substituting another package manager."))
        #expect(result.warnings.contains("Project .venv exists; use .venv/bin/python for Python commands before system python3."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `uv` because project files point to it."))
        #expect(context.contains("Prefer `uv run`."))
        #expect(context.contains("Ask before `running uv commands before uv is available`."))
        #expect(policy.contains("`uv run`"))
        #expect(policy.contains("`running uv commands before uv is available`"))
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
    func scanDoesNotWarnWhenActivePythonSatisfiesPythonVersion() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            ".python-version": "3.12\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env python3 --version": .init(name: "/usr/bin/env", args: ["python3", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Python 3.12.4", stderr: ""),
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        #expect(!result.warnings.contains("Project requests Python 3.12; verify active python before installs (/opt/homebrew/bin/python3)."))
        #expect(!result.policy.askFirstCommands.contains("dependency installs before matching active Python to project version hints"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(!context.contains("Project requests Python 3.12; verify active python before installs"))
    }

    @Test
    func scanUsesToolVersionsForPythonRuntimeInstallGuard() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            ".tool-versions": """
            # asdf-style runtime hints
            python 3.12.4 3.11.9
            ruby 3.3.0
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env python3 --version": .init(name: "/usr/bin/env", args: ["python3", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Python 3.11.9", stderr: ""),
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        #expect(result.project.detectedFiles.contains(".tool-versions"))
        #expect(result.project.runtimeHints.python == "3.12.4")
        #expect(result.warnings.contains("Active Python is Python 3.11.9, but project requests 3.12.4; ask before dependency installs (/opt/homebrew/bin/python3)."))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Python to project version hints"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Active Python is Python 3.11.9, but project requests 3.12.4; ask before dependency installs"))
        #expect(policy.contains("`dependency installs before matching active Python to project version hints`"))
    }

    @Test
    func scanAsksBeforeInstallsWhenNodeVersionCommandFails() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
            ".nvmrc": "v20\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 127, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "env: node: No such file or directory"),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.tools.versions.contains(where: { $0.name == "node" && !$0.available && $0.version == nil }))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))
        #expect(result.warnings.contains("Project requests Node v20; verify active node before installs (/opt/homebrew/bin/node)."))
        #expect(result.diagnostics.contains("node --version failed with exit code 127: env: node: No such file or directory"))
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
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
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
            project: .init(detectedFiles: [".nvmrc", "pnpm-lock.yaml"], packageManager: "pnpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: "v20", python: nil)),
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
            project: .init(detectedFiles: [".nvmrc", "pnpm-lock.yaml"], packageManager: "pnpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: "v20", python: nil)),
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
        - Ask before `running pnpm commands before pnpm is available`.
        - Ask before `dependency installs before matching active Node to project version hints`.
        - Ask before `pnpm install`.
        - Ask before `modifying lockfiles`.

        ## Mismatches
        - Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node).
        - Project files prefer pnpm, but pnpm was not found on PATH; ask before running pnpm commands or substituting another package manager.

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
        - `running pnpm commands before pnpm is available`
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
    func agentContextOmitsUnrelatedCommandDiagnostics() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["swift test"], askFirstCommands: [], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: [
                "go version failed with exit code 127: env: go: No such file or directory",
                "swift --version failed with exit code 1: swift unavailable"
            ]
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let report = try String(contentsOf: outputURL.appendingPathComponent("environment_report.md"), encoding: .utf8)

        #expect(!context.contains("go version failed"))
        #expect(context.contains("swift --version failed with exit code 1"))
        #expect(report.contains("go version failed with exit code 127"))
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
        #expect(result.policy.askFirstCommands.contains("swift package update"))
        #expect(result.policy.askFirstCommands.contains("swift package resolve"))
        #expect(result.warnings.contains("Project files prefer SwiftPM, but swift was not found on PATH; ask before running SwiftPM commands."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running SwiftPM commands before swift is available`."))
        #expect(context.contains("Ask before `swift package update`."))
        #expect(policy.contains("`swift package update`"))
        #expect(policy.contains("`swift package resolve`"))
        #expect(context.contains("Project files prefer SwiftPM, but swift was not found on PATH; ask before running SwiftPM commands."))
        #expect(policy.contains("`running SwiftPM commands before swift is available`"))
    }

    @Test
    func scanTreatsPackageResolvedAsSwiftPMSignal() throws {
        let projectURL = try makeProject(files: [
            "Package.resolved": """
            {
              "pins": [],
              "version": 2
            }
            """
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "swiftpm")
        #expect(result.project.detectedFiles.contains("Package.resolved"))
        #expect(result.policy.preferredCommands == ["swift test", "swift build"])
        #expect(result.policy.askFirstCommands.contains("running SwiftPM commands before swift is available"))
        #expect(result.policy.askFirstCommands.contains("swift package resolve"))
        #expect(result.policy.askFirstCommands.contains("swift package update"))
        #expect(result.warnings.contains("Project files prefer SwiftPM, but swift was not found on PATH; ask before running SwiftPM commands."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `swiftpm` because project files point to it."))
        #expect(context.contains("Prefer `swift test`."))
        #expect(context.contains("Ask before `running SwiftPM commands before swift is available`."))
        #expect(policy.contains("`swift package resolve`"))
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
            project: .init(detectedFiles: [".nvmrc", "package.json", "pnpm-lock.yaml"], packageManager: "pnpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: "v20", python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(
                preferredCommands: ["pnpm", "pnpm test"],
                askFirstCommands: [
                    "running pnpm commands before pnpm is available",
                    "dependency installs before matching active Node to project version hints",
                    "pnpm install",
                    "modifying lockfiles"
                ],
                forbiddenCommands: ["sudo", "brew upgrade"]
            ),
            warnings: [
                "Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node).",
                "Project files prefer pnpm, but pnpm was not found on PATH; ask before running pnpm commands or substituting another package manager."
            ],
            diagnostics: ["node --version unavailable: missing"]
        )
    }
}
