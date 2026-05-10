import Testing
import Foundation
@testable import HabitatCore

struct PreCommitPolicyTests {

    @Test
    func scanWarnsWhenPreCommitConfigPresent() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """,
            ".pre-commit-config.yaml": "repos: []"
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
        #expect(result.project.detectedFiles.contains(".pre-commit-config.yaml"))
        #expect(!result.project.symlinkedFiles.contains(".pre-commit-config.yaml"))
        #expect(context.contains("Warning: Pre-commit configuration detected. Run `git status --short` after commit hooks run."))
    }

    @Test
    func scanDoesNotWarnWhenPreCommitConfigAbsent() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """
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
        #expect(!context.contains("Warning: Pre-commit configuration detected"))
    }

    @Test
    func scanDoesNotWarnWhenPreCommitConfigIsSymlink() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """
        ])
        let externalURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try "repos: []".write(to: externalURL, atomically: true, encoding: .utf8)
        try FileManager.default.createSymbolicLink(
            at: projectURL.appendingPathComponent(".pre-commit-config.yaml"),
            withDestinationURL: externalURL
        )

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
        #expect(result.project.symlinkedFiles.contains(".pre-commit-config.yaml"))
        #expect(!context.contains("Warning: Pre-commit configuration detected"))
    }
}
