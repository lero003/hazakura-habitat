import Testing
import Foundation
@testable import HabitatCore

struct GoCargoPolicyTests {
    @Test
    func scanTreatsGoModAsGoProjectAndGuardsMissingGo() throws {
        let projectURL = try makeProject(files: [
            "go.mod": "module example.com/demo\n\ngo 1.22\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "go")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Go commands before go is available"))
        #expect(result.policy.askFirstCommands.contains("go get"))
        #expect(result.warnings.contains("Project files prefer Go, but go was not found on PATH; ask before running Go commands."))
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `go` before running Go commands."))
        #expect(context.contains("Ask before `running Go commands before go is available`."))
        #expect(context.contains("Ask before `go mod tidy`."))
        #expect(!context.contains("Prefer `go test ./...`."))
        #expect(!policy.contains("`go test ./...`"))
        #expect(policy.contains("`go get`"))
    }

    @Test
    func scanAsksBeforeGoCommandsWhenGoVersionCheckFails() throws {
        let projectURL = try makeProject(files: [
            "go.mod": "module example.com/demo\n\ngo 1.22\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env go version": .init(name: "/usr/bin/env", args: ["go", "version"], exitCode: 1, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "go: invalid toolchain"),
            "/usr/bin/which -a go": .init(name: "/usr/bin/which", args: ["-a", "go"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/go", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "go")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Go commands before go version check succeeds"))
        #expect(!result.policy.askFirstCommands.contains("running Go commands before go is available"))
        #expect(result.diagnostics.contains("go version failed with exit code 1: go: invalid toolchain"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `go` before running Go commands."))
        #expect(context.contains("Ask before `running Go commands before go version check succeeds`."))
        #expect(context.contains("go version failed with exit code 1: go: invalid toolchain"))
        #expect(!context.contains("Use `go` because project files point to it."))
        #expect(!context.contains("Prefer `go test ./...`."))
        #expect(policy.contains("`running Go commands before go version check succeeds`"))
        #expect(!policy.contains("`go test ./...`"))
        #expect(!policy.contains("`build commands for the selected project`"))
    }

    @Test
    func scanResultReviewFirstMetadataPrioritizesGoAndCargoMissingToolGuards() throws {
        let cases: [(files: [String: String], missingGuard: String, mutationCommand: String)] = [
            (
                ["go.mod": "module example.com/demo\n\ngo 1.22\n"],
                "running Go commands before go is available",
                "go get"
            ),
            (
                [
                    "Cargo.toml": """
                    [package]
                    name = "demo"
                    version = "0.1.0"
                    edition = "2021"
                    """
                ],
                "running Cargo commands before cargo is available",
                "cargo add"
            )
        ]

        for testCase in cases {
            let projectURL = try makeProject(files: testCase.files)
            let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try ReportWriter().write(scanResult: result, outputURL: outputURL)

            let data = try Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
            let decoded = try JSONDecoder().decode(ScanResult.self, from: data)
            let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

            #expect(decoded.policy.reviewFirstCommandReasons.first == PolicyCommandReason(
                command: testCase.missingGuard,
                classification: "ask_first",
                reasonCode: "missing_tool",
                reason: "Required project tool is missing on `PATH`."
            ))
            #expect(decoded.policy.reviewFirstCommandReasons.contains(PolicyCommandReason(
                command: testCase.mutationCommand,
                classification: "ask_first",
                reasonCode: "dependency_mutation",
                reason: "Dependency install, update, or removal can mutate project state."
            )))
            #expect(decoded.policy.commandReasons.contains(where: {
                $0.command == testCase.missingGuard && $0.reasonCode == "missing_tool"
            }))

            let missingLine = "`\(testCase.missingGuard)` (`missing_tool`)"
            let mutationLine = "`\(testCase.mutationCommand)` (`dependency_mutation`)"
            #expect(section(policy, missingLine, appearsBefore: mutationLine))
        }
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
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Cargo commands before cargo is available"))
        #expect(result.policy.askFirstCommands.contains("cargo add"))
        #expect(result.policy.askFirstCommands.contains("cargo update"))
        #expect(result.policy.askFirstCommands.contains("cargo remove"))
        #expect(result.warnings.contains("Project files prefer Cargo, but cargo was not found on PATH; ask before running Cargo commands."))
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `cargo` before running Cargo commands."))
        #expect(context.contains("Ask before `running Cargo commands before cargo is available`."))
        #expect(policy.contains("`cargo remove`"))
        #expect(context.contains("Ask before `cargo update`."))
        #expect(!context.contains("Prefer `cargo test`."))
        #expect(!policy.contains("`cargo test`"))
        #expect(policy.contains("`cargo add`"))
    }

    @Test
    func scanAsksBeforeCargoCommandsWhenCargoVersionCheckFails() throws {
        let projectURL = try makeProject(files: [
            "Cargo.toml": """
            [package]
            name = "demo"
            version = "0.1.0"
            edition = "2021"
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env cargo --version": .init(name: "/usr/bin/env", args: ["cargo", "--version"], exitCode: 1, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "cargo: rustup toolchain is not installed"),
            "/usr/bin/which -a cargo": .init(name: "/usr/bin/which", args: ["-a", "cargo"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/cargo", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "cargo")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Cargo commands before cargo version check succeeds"))
        #expect(!result.policy.askFirstCommands.contains("running Cargo commands before cargo is available"))
        #expect(result.diagnostics.contains("cargo --version failed with exit code 1: cargo: rustup toolchain is not installed"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running Cargo commands before cargo version check succeeds`."))
        #expect(context.contains("cargo --version failed with exit code 1: cargo: rustup toolchain is not installed"))
        #expect(!context.contains("Prefer `cargo test`."))
        #expect(policy.contains("`running Cargo commands before cargo version check succeeds`"))
        #expect(!policy.contains("`cargo test`"))
        #expect(!policy.contains("`build commands for the selected project`"))
    }
}
