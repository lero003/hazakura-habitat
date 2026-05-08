import Testing
import Foundation
@testable import HabitatCore

struct CiPresencePolicyTests {

    @Test
    func swiftpmWithCiHasConcreteValidationNoUncertainty() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """,
            ".github/workflows/test.yml": "# CI test"
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
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(!context.contains("Open uncertainty: CI configuration detected"))
        #expect(scanJSON.contains("\"ciWorkflowFiles\""))
        #expect(scanJSON.contains(".github/workflows/test.yml"))
        #expect(result.project.ciWorkflowFiles == [".github/workflows/test.yml"])
    }

    @Test
    func npmWithCiAndMissingNodeEmitsOpenUncertainty() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "scripts": {
                "test": "vitest run",
                "build": "vite build"
              }
            }
            """,
            ".github/workflows/ci.yml": "# CI pipeline"
        ])
        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/npm", stderr: ""),
            "/usr/bin/env npm --version": .init(name: "/usr/bin/env", args: ["npm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "10.0.0", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(context.contains("Open uncertainty: CI configuration detected but no local verification command found."))
        #expect(result.project.ciWorkflowFiles == [".github/workflows/ci.yml"])
    }

    @Test
    func npmWithCiAndNoKnownScriptsEmitsOpenUncertainty() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "scripts": {
                "start": "node index.js",
                "deploy": "node deploy.js"
              }
            }
            """,
            ".github/workflows/test.yml": "# CI test"
        ])
        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/npm", stderr: ""),
            "/usr/bin/env npm --version": .init(name: "/usr/bin/env", args: ["npm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "10.0.0", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/node", stderr: ""),
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v20.0.0", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(context.contains("Open uncertainty: CI configuration detected but no local verification command found."))
        #expect(result.project.ciWorkflowFiles == [".github/workflows/test.yml"])
    }

    @Test
    func ciWithoutPackageManagerEmitsOpenUncertainty() throws {
        let projectURL = try makeProject(files: [
            ".github/workflows/ci.yml": """
            name: CI
            on: [push]
            jobs:
              test:
                runs-on: ubuntu-latest
                steps:
                  - run: npm test
            """
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(result.project.ciWorkflowFiles == [".github/workflows/ci.yml"])
        #expect(context.contains("Open uncertainty: CI configuration detected but no local verification command found."))
        #expect(scanJSON.contains("\"ciWorkflowFiles\""))
        #expect(scanJSON.contains("\".github/workflows/ci.yml\""))
        #expect(!scanJSON.contains("npm test"))
    }

    @Test
    func symlinkedCiWorkflowsAreIgnored() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}"
        ])
        let externalURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: externalURL, withIntermediateDirectories: true)
        try "# external CI\n".write(
            to: externalURL.appendingPathComponent("external.yml"),
            atomically: true,
            encoding: .utf8
        )
        let githubURL = projectURL.appendingPathComponent(".github")
        try FileManager.default.createDirectory(at: githubURL, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(
            at: githubURL.appendingPathComponent("workflows"),
            withDestinationURL: externalURL
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.ciWorkflowFiles.isEmpty)
    }

    @Test
    func symlinkedCiWorkflowFilesAreIgnored() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}"
        ])
        let externalURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try "# external CI\n".write(to: externalURL, atomically: true, encoding: .utf8)
        let workflowsURL = projectURL.appendingPathComponent(".github/workflows")
        try FileManager.default.createDirectory(at: workflowsURL, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(
            at: workflowsURL.appendingPathComponent("ci.yml"),
            withDestinationURL: externalURL
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.ciWorkflowFiles.isEmpty)
    }

    @Test
    func noCiDoesNotEmitOpenUncertainty() throws {
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
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(!context.contains("Open uncertainty: CI configuration detected"))
        #expect(scanJSON.contains("\"ciWorkflowFiles\""))
        #expect(result.project.ciWorkflowFiles.isEmpty)
    }
}
