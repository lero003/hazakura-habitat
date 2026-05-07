import Testing
import Foundation
@testable import HabitatCore

struct JavaScriptPackagePolicyTests {
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

        #expect(result.schemaVersion == HabitatMetadata.schemaVersion)
        #expect(result.generatorVersion == HabitatMetadata.generatorVersion)
        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.runtimeHints.node == "v20")
        #expect(result.policy.preferredCommands.isEmpty)
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
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.11.1", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
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
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running npm commands before npm is available"))
        #expect(result.policy.askFirstCommands.contains("npm install"))
        #expect(result.warnings.contains("Project files prefer npm, but npm was not found on PATH; ask before running npm commands or substituting another package manager."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running npm commands before npm is available`."))
        #expect(context.contains("Project files prefer npm, but npm was not found on PATH; ask before running npm commands or substituting another package manager."))
        #expect(!context.contains("Prefer `npm run test`."))
        #expect(policy.contains("`running npm commands before npm is available`"))
        #expect(!policy.contains("`npm run test`"))
    }

    @Test
    func scanTreatsNpmShrinkwrapAsNpmLockfileAndGuardsMissingNpm() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "npm-shrinkwrap.json": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains("npm-shrinkwrap.json"))
        #expect(result.project.packageManager == "npm")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running npm commands before npm is available"))
        #expect(result.warnings.contains("Project files prefer npm, but npm was not found on PATH; ask before running npm commands or substituting another package manager."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `npm` before running npm commands."))
        #expect(context.contains("Ask before `running npm commands before npm is available`."))
        #expect(!context.contains("Prefer `npm run test`."))
        #expect(policy.contains("`running npm commands before npm is available`"))
        #expect(!policy.contains("`npm run test`"))
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
            #expect(result.policy.preferredCommands.isEmpty)
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
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.11.1", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
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
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.11.1", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
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
    func scanPrefersPnpmWorkspaceOverConflictingNpmLockfile() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "workspace-root",
              "packageManager": "npm@10.8.2",
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "package-lock.json": "npm lockfile",
            "pnpm-workspace.yaml": """
            packages:
              - "packages/*"
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.11.1", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "9.15.4", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.declaredPackageManager == "npm")
        #expect(result.policy.preferredCommands == ["pnpm run test"])
        #expect(result.policy.askFirstCommands.contains("dependency installs when pnpm-workspace.yaml conflicts with JavaScript lockfiles"))
        #expect(result.policy.askFirstCommands.contains("dependency installs when package.json packageManager conflicts with project package-manager signals"))
        #expect(!result.policy.askFirstCommands.contains("dependency installs when package.json packageManager conflicts with lockfiles"))
        #expect(result.warnings.contains("pnpm-workspace.yaml selects pnpm, but JavaScript lockfiles also include package-lock.json; ask before dependency installs."))
        #expect(result.warnings.contains("package.json requests npm, but pnpm-workspace.yaml selects pnpm; ask before dependency installs."))
        #expect(!result.warnings.contains("package.json requests npm, but project lockfiles select pnpm; ask before dependency installs."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `pnpm` because project files point to it."))
        #expect(context.contains("Prefer `pnpm run test`."))
        #expect(context.contains("Ask before `dependency installs when pnpm-workspace.yaml conflicts with JavaScript lockfiles`."))
        #expect(context.contains("pnpm-workspace.yaml selects pnpm, but JavaScript lockfiles also include package-lock.json; ask before dependency installs."))
        #expect(context.contains("package.json requests npm, but pnpm-workspace.yaml selects pnpm; ask before dependency installs."))
        #expect(!context.contains("Use `npm`"))
        #expect(policy.contains("`dependency installs when pnpm-workspace.yaml conflicts with JavaScript lockfiles`"))
        #expect(policy.contains("`dependency installs when package.json packageManager conflicts with project package-manager signals`"))
        #expect(policy.contains("`pnpm run test`"))
    }

    @Test
    func scanPrefersPnpmWorkspaceOverConflictingPackageManagerField() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "workspace-root",
              "packageManager": "npm@10.8.2",
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "pnpm-workspace.yaml": """
            packages:
              - "packages/*"
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.11.1", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "9.15.4", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.declaredPackageManager == "npm")
        #expect(result.project.declaredPackageManagerVersion == "10.8.2")
        #expect(result.policy.preferredCommands == ["pnpm run test"])
        #expect(result.policy.askFirstCommands.contains("dependency installs when package.json packageManager conflicts with project package-manager signals"))
        #expect(result.warnings.contains("package.json requests npm, but pnpm-workspace.yaml selects pnpm; ask before dependency installs."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `pnpm` because project files point to it."))
        #expect(context.contains("Prefer `pnpm run test`."))
        #expect(context.contains("Ask before `dependency installs when package.json packageManager conflicts with project package-manager signals`."))
        #expect(context.contains("package.json requests npm, but pnpm-workspace.yaml selects pnpm; ask before dependency installs."))
        #expect(!context.contains("Use `npm@10.8.2`"))
        #expect(policy.contains("`dependency installs when package.json packageManager conflicts with project package-manager signals`"))
    }

}
