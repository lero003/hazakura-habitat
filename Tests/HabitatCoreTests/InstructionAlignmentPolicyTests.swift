import Testing
import Foundation
@testable import HabitatCore

struct InstructionAlignmentPolicyTests {
    @Test
    func scanWarnsWhenDocumentedValidationCommandConflictsWithRepositoryFacts() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """,
            "AGENTS.md": "Run npm test before committing changes."
        ])
        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: "")
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(source: "AGENTS.md", command: "npm test")
        ])

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(context.contains("Fact: `Package.swift` is present and `package.json` is absent."))
        #expect(context.contains("Warning: Project instructions mention `npm test`, but repository facts select SwiftPM validation."))
        #expect(context.contains("Hint: Prefer `swift test` unless the task explicitly targets generated docs or external examples."))
        #expect(!context.contains("Run npm test before committing changes."))
        #expect(scanJSON.contains("\"validationCommandClaims\""))
        #expect(scanJSON.contains("\"command\" : \"npm test\""))
        #expect(!scanJSON.contains("Run npm test before committing changes."))
    }

    @Test
    func scanConfirmsWhenDocumentedValidationCommandMatchesRepositoryFacts() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """,
            "AGENTS.md": "Use swift test for validation."
        ])
        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: "")
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(context.contains("Fact: Project instructions and repository files both support SwiftPM validation."))
        #expect(context.contains("Hint: Prefer `swift test` for local validation."))
        #expect(!context.contains("Warning: Project instructions mention"))
        #expect(!context.contains("Use swift test for validation."))
    }

    @Test
    func scanIgnoresDocumentedBuildCommandWithoutValidationContext() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """,
            "README.md": "Run swift build before scanning this repository."
        ])
        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: "")
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(result.project.validationCommandClaims.isEmpty)
        #expect(!context.contains("Project instructions and repository files both support SwiftPM validation."))
    }
}
