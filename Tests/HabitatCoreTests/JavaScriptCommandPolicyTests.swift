import Testing
import Foundation
@testable import HabitatCore

struct JavaScriptCommandPolicyTests {
    @Test
    func scanTreatsPackageJsonOnlyAsNpmProjectAndGuardsMissingNpm() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.project.packageScripts.isEmpty)
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("npm ci"))
        #expect(result.policy.askFirstCommands.contains("npm update"))
        #expect(result.policy.askFirstCommands.contains("running npm commands before npm is available"))
        #expect(result.warnings.contains("Project files prefer npm, but npm was not found on PATH; ask before running npm commands or substituting another package manager."))
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `node` and `npm` before running JavaScript commands."))
        #expect(context.contains("Ask before `running JavaScript commands before node is available`."))
        #expect(context.contains("Ask before `running npm commands before npm is available`."))
        #expect(context.contains("Ask before `npm ci`."))
        #expect(!context.contains("Prefer `npm run`."))
        #expect(!policy.contains("`npm run`"))
        #expect(policy.contains("`npm ci`"))
        #expect(policy.contains("`npm update`"))
        #expect(policy.contains("`running npm commands before npm is available`"))
    }

    @Test
    func commandPolicyDoesNotAllowGenericTestOrBuildWithoutConcretePreferredCommands() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.11.1", stderr: ""),
            "/usr/bin/env npm --version": .init(name: "/usr/bin/env", args: ["npm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "10.8.2", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.policy.preferredCommands == ["npm run"])
        #expect(!result.policy.askFirstCommands.contains("running JavaScript commands before node is available"))
        #expect(!result.policy.askFirstCommands.contains("running npm commands before npm is available"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(policy.contains("`npm run`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`build commands for the selected project`"))
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
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running JavaScript commands before node is available"))
        #expect(!result.policy.askFirstCommands.contains("running npm commands before npm is available"))
        #expect(result.warnings.contains("Project files need Node, but node was not found on PATH; ask before running JavaScript commands."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running JavaScript commands before node is available`."))
        #expect(context.contains("Project files need Node, but node was not found on PATH; ask before running JavaScript commands."))
        #expect(!context.contains("Prefer `npm run test`."))
        #expect(!policy.contains("`npm run test`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`build commands for the selected project`"))
        #expect(policy.contains("`running JavaScript commands before node is available`"))
    }

    @Test
    func scanGuardsJavaScriptDependencyMutationCommands() throws {
        let cases: [(lockfile: String, packageManager: String, commands: [String])] = [
            ("package-lock.json", "npm", ["npm install", "npm ci", "npm update", "npm uninstall", "npm remove", "npm rm"]),
            ("pnpm-lock.yaml", "pnpm", ["pnpm install", "pnpm add", "pnpm update", "pnpm remove", "pnpm rm", "pnpm uninstall"]),
            ("yarn.lock", "yarn", ["yarn install", "yarn add", "yarn up", "yarn remove"]),
            ("bun.lock", "bun", ["bun install", "bun add", "bun update", "bun remove"]),
            ("bun.lockb", "bun", ["bun install", "bun add", "bun update", "bun remove"]),
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
    func scanForbidsJavaScriptGlobalPackageInstalls() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "pnpm-lock.yaml": "lockfile",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
            "npm install -g",
            "npm install --global",
            "npm i -g",
            "npm i --global",
            "npm uninstall -g",
            "npm uninstall --global",
            "npm remove -g",
            "npm remove --global",
            "npm rm -g",
            "npm rm --global",
            "pnpm add -g",
            "pnpm add --global",
            "pnpm remove -g",
            "pnpm remove --global",
            "pnpm rm -g",
            "pnpm rm --global",
            "yarn global add",
            "yarn global remove",
            "yarn add -g",
            "yarn add --global",
            "yarn remove -g",
            "yarn remove --global",
            "bun add -g",
            "bun add --global",
            "bun remove -g",
            "bun remove --global",
        ]

        for command in commands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func scanAsksBeforeCorepackMutationCommands() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "packageManager": "pnpm@10.0.0"
            }
            """,
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = PolicyReasonCatalog.corepackPackageManagerActivationCommands

        for command in commands {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }
        #expect(PolicyReasonCatalog.askFirstReason(for: "corepack enable").code == "package_manager_activation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "corepack install").code == "package_manager_activation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "corepack use").code == "package_manager_activation")

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in commands {
            #expect(policy.contains("`\(command)` (`package_manager_activation`)"), "Expected command_policy.md to include \(command) with package-manager activation reason")
        }
    }
}
