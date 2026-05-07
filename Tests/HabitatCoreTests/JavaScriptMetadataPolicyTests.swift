import Testing
import Foundation
@testable import HabitatCore

struct JavaScriptMetadataPolicyTests {
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
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.11.1", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.project.packageScripts == ["build", "deploy", "test"])
        #expect(result.policy.preferredCommands == ["npm run test", "npm run build"])

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Prefer `npm run test`."))
        #expect(context.contains("Prefer `npm run build`."))
        #expect(policy.contains("`npm run test`"))
        #expect(policy.contains("`npm run build`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`build commands for the selected project`"))
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
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.11.1", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
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
    func scanOmitsPackageManagerIntegritySuffixFromAgentArtifacts() throws {
        let integrity = "sha512-abcdefghijklmnopqrstuvwxyz0123456789"
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "packageManager": "pnpm@9.15.4+\(integrity)",
              "scripts": {
                "test": "vitest run"
              }
            }
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
        #expect(result.project.packageManagerVersion == "9.15.4")
        #expect(result.project.declaredPackageManagerVersion == "9.15.4")
        #expect(!result.policy.askFirstCommands.contains("dependency installs before matching pnpm to packageManager version"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(scanResult.contains("\"packageManagerVersion\" : \"9.15.4\""))
        #expect(context.contains("Use `pnpm@9.15.4` because `package.json` packageManager points to it."))
        #expect(!scanResult.contains(integrity))
        #expect(!context.contains(integrity))
    }

    @Test
    func scanUsesToolVersionsForPackageManagerVersionGuard() throws {
        let integrity = "sha512-toolversionsabcdefghijklmnopqrstuvwxyz0123456789"
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "pnpm-lock.yaml": "lockfile",
            ".tool-versions": """
            nodejs 20.11.1
            pnpm 9.15.4+\(integrity)
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.11.1", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "8.15.9", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.packageManagerVersion == "9.15.4")
        #expect(result.project.packageManagerVersionSource == ".tool-versions")
        #expect(result.project.declaredPackageManager == nil)
        #expect(result.policy.preferredCommands == ["pnpm run test"])
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching pnpm to packageManager version"))
        #expect(result.warnings.contains("Project requests pnpm 9.15.4 via .tool-versions; active pnpm is 8.15.9; ask before dependency installs."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(scanResult.contains("\"packageManagerVersion\" : \"9.15.4\""))
        #expect(scanResult.contains("\"packageManagerVersionSource\" : \".tool-versions\""))
        #expect(context.contains("Use `pnpm@9.15.4` because `.tool-versions` pins it."))
        #expect(context.contains("Ask before `dependency installs before matching pnpm to packageManager version`."))
        #expect(policy.contains("`dependency installs before matching pnpm to packageManager version`"))
        #expect(!scanResult.contains(integrity))
        #expect(!context.contains(integrity))
    }

    @Test
    func scanUsesMiseTomlForRuntimeAndPackageManagerVersionGuards() throws {
        let integrity = "sha512-miseabcdefghijklmnopqrstuvwxyz0123456789"
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "pnpm-lock.yaml": "lockfile",
            "mise.toml": """
            [tools]
            node = "20.11.1"
            pnpm = "9.15.4+\(integrity)"
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v22.15.0", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "8.15.9", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains("mise.toml"))
        #expect(result.project.runtimeHints.node == "20.11.1")
        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.packageManagerVersion == "9.15.4")
        #expect(result.project.packageManagerVersionSource == "mise.toml")
        #expect(result.policy.preferredCommands == ["pnpm run test"])
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching pnpm to packageManager version"))
        #expect(result.warnings.contains("Active Node is v22.15.0, but project requests 20.11.1; ask before dependency installs (/opt/homebrew/bin/node)."))
        #expect(result.warnings.contains("Project requests pnpm 9.15.4 via mise.toml; active pnpm is 8.15.9; ask before dependency installs."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(scanResult.contains("\"packageManagerVersionSource\" : \"mise.toml\""))
        #expect(context.contains("Use `pnpm@9.15.4` because `mise.toml` pins it."))
        #expect(context.contains("Ask before `dependency installs before matching active Node to project version hints`."))
        #expect(context.contains("Ask before `dependency installs before matching pnpm to packageManager version`."))
        #expect(policy.contains("`dependency installs before matching active Node to project version hints`"))
        #expect(policy.contains("`dependency installs before matching pnpm to packageManager version`"))
        #expect(!scanResult.contains(integrity))
        #expect(!context.contains(integrity))
    }

    @Test
    func scanUsesCommentedMiseToolsSectionForVersionGuards() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "pnpm-lock.yaml": "lockfile",
            "mise.toml": """
            [ tools ] # project tool versions
            node = "20.11.1"
            pnpm = "9.15.4"
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v22.15.0", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "8.15.9", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.runtimeHints.node == "20.11.1")
        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.packageManagerVersion == "9.15.4")
        #expect(result.project.packageManagerVersionSource == "mise.toml")
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching pnpm to packageManager version"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(scanResult.contains("\"packageManagerVersionSource\" : \"mise.toml\""))
        #expect(context.contains("Use `pnpm@9.15.4` because `mise.toml` pins it."))
        #expect(context.contains("Ask before `dependency installs before matching active Node to project version hints`."))
        #expect(context.contains("Ask before `dependency installs before matching pnpm to packageManager version`."))
    }

    @Test
    func scanUsesHiddenMiseTomlForRuntimeAndPackageManagerVersionGuards() throws {
        let integrity = "sha512-hiddenmiseabcdefghijklmnopqrstuvwxyz0123456789"
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "pnpm-lock.yaml": "lockfile",
            ".mise.toml": """
            [tools]
            node = "20.11.1"
            pnpm = "9.15.4+\(integrity)"
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v22.15.0", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "8.15.9", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".mise.toml"))
        #expect(result.project.runtimeHints.node == "20.11.1")
        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.packageManagerVersion == "9.15.4")
        #expect(result.project.packageManagerVersionSource == ".mise.toml")
        #expect(result.policy.preferredCommands == ["pnpm run test"])
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching pnpm to packageManager version"))
        #expect(result.warnings.contains("Project requests pnpm 9.15.4 via .mise.toml; active pnpm is 8.15.9; ask before dependency installs."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(scanResult.contains("\"packageManagerVersionSource\" : \".mise.toml\""))
        #expect(context.contains("Use `pnpm@9.15.4` because `.mise.toml` pins it."))
        #expect(context.contains("Ask before `dependency installs before matching active Node to project version hints`."))
        #expect(context.contains("Ask before `dependency installs before matching pnpm to packageManager version`."))
        #expect(policy.contains("`dependency installs before matching active Node to project version hints`"))
        #expect(policy.contains("`dependency installs before matching pnpm to packageManager version`"))
        #expect(!scanResult.contains(integrity))
        #expect(!context.contains(integrity))
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
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.11.1", stderr: ""),
            "/usr/bin/env yarn --version": .init(name: "/usr/bin/env", args: ["yarn", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "1.22.22", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
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
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.11.1", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
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
        #expect(context.contains("Use `pnpm@9.15.4` because `package.json` pins it."))
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
        #expect(policy.contains("`read-only project inspection, including rg <pattern>`"))
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
    func scanGuardsJavaScriptPackageManagerWhenVersionCheckFailsWithoutPackageManagerPin() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "scripts": {
                "test": "vitest run"
              }
            }
            """,
            "pnpm-lock.yaml": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.11.1", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 1, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "pnpm: failed to load"),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.packageManagerVersion == nil)
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running pnpm commands before pnpm version check succeeds"))
        #expect(!result.policy.askFirstCommands.contains("running pnpm commands before pnpm is available"))
        #expect(result.diagnostics.contains("pnpm --version failed with exit code 1: pnpm: failed to load"))
        #expect(result.tools.versions.contains(where: { $0.name == "pnpm" && !$0.available }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `pnpm` before running pnpm commands."))
        #expect(context.contains("Ask before `running pnpm commands before pnpm version check succeeds`."))
        #expect(context.contains("pnpm --version failed with exit code 1: pnpm: failed to load"))
        #expect(!context.contains("Use `pnpm` because project files point to it."))
        #expect(!context.contains("Prefer `pnpm run test`."))
        #expect(policy.contains("`running pnpm commands before pnpm version check succeeds`"))
        #expect(!policy.contains("`pnpm run test`"))
        #expect(!policy.contains("`test commands for the selected project`"))
    }

    @Test
    func scanShowsNodeVersionFailureDiagnosticsForJavaScriptProjects() throws {
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
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 1, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "node: failed to load"),
            "/usr/bin/env npm --version": .init(name: "/usr/bin/env", args: ["npm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "10.8.2", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running JavaScript commands before node version check succeeds"))
        #expect(result.diagnostics.contains("node --version failed with exit code 1: node: failed to load"))
        #expect(result.tools.versions.contains(where: { $0.name == "node" && !$0.available }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `node` before running JavaScript commands."))
        #expect(context.contains("Ask before `running JavaScript commands before node version check succeeds`."))
        #expect(context.contains("node --version failed with exit code 1: node: failed to load"))
        #expect(!context.contains("Use `npm` because project files point to it."))
        #expect(!context.contains("Prefer `npm run test`."))
        #expect(policy.contains("`running JavaScript commands before node version check succeeds`"))
        #expect(!policy.contains("`npm run test`"))
        #expect(!policy.contains("`test commands for the selected project`"))
    }

}
