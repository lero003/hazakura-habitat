import Testing
import Foundation
@testable import HabitatCore

struct PackageRegistryPolicyTests {
    @Test
    func scanAsksBeforeEphemeralPackageExecutionCommands() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
            "npm exec",
            "npx",
            "pnpm dlx",
            "yarn dlx",
            "bunx",
            "uvx",
            "uv tool run",
            "pipx run",
            "pipx runpip",
        ]

        for command in commands {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func scanAsksBeforePackagePublicationCommands() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            "Gemfile": "source \"https://rubygems.org\"\n",
            "Cargo.toml": "[package]\nname = \"demo\"\nversion = \"0.1.0\"\n",
            "Podfile": "platform :ios, '17.0'\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = PolicyReasonCatalog.packageRegistryMutationCommands.filter {
            !$0.hasPrefix("npm ") || $0 == "npm publish"
        }

        for command in commands {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }
        let commandReasonCodes = Dictionary(uniqueKeysWithValues: result.policy.commandReasons.map { ($0.command, $0.reasonCode) })
        for command in commands {
            #expect(commandReasonCodes[command] == "package_registry_mutation", "Expected \(command) to explain external package registry mutation risk")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
            #expect(policy.contains("`\(command)` (`package_registry_mutation`)"), "Expected command_policy.md to annotate \(command) with package_registry_mutation")
        }
    }

    @Test
    func packageRegistryMutationCommandsStayCentralizedForPolicyConsumers() {
        let commands = PolicyReasonCatalog.packageRegistryMutationCommands

        #expect(commands == [
            "npm publish",
            "npm unpublish",
            "npm deprecate",
            "npm dist-tag",
            "npm owner",
            "npm access",
            "npm team",
            "pnpm publish",
            "yarn publish",
            "yarn npm publish",
            "bun publish",
            "uv publish",
            "twine upload",
            "python -m twine upload",
            "python3 -m twine upload",
            "gem push",
            "gem yank",
            "gem owner",
            "cargo publish",
            "cargo yank",
            "cargo owner",
            "pod trunk add-owner",
            "pod trunk remove-owner",
            "pod trunk push",
            "pod trunk deprecate",
            "pod trunk delete",
        ])

        for command in commands {
            #expect(PolicyReasonCatalog.askFirstReason(for: command).code == "package_registry_mutation")
        }
    }

    @Test
    func scanAsksBeforeRegistryMetadataMutationCommands() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = PolicyReasonCatalog.packageRegistryMutationCommands.filter {
            $0.hasPrefix("npm ") && $0 != "npm publish"
        }

        for command in commands {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }
        let commandReasonCodes = Dictionary(uniqueKeysWithValues: result.policy.commandReasons.map { ($0.command, $0.reasonCode) })
        for command in commands {
            #expect(commandReasonCodes[command] == "package_registry_mutation", "Expected \(command) to explain external package registry mutation risk")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
            #expect(policy.contains("`\(command)` (`package_registry_mutation`)"), "Expected command_policy.md to annotate \(command) with package_registry_mutation")
        }
    }
}
