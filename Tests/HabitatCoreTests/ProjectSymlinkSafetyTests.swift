import Testing
import Foundation
@testable import HabitatCore

struct ProjectSymlinkSafetyTests {
    @Test
    func scanDoesNotReadSymlinkedRuntimeHintValues() throws {
        let secretValue = "HH_SYMLINKED_NVMRC_SECRET_VALUE"
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])
        let externalURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try secretValue.write(to: externalURL, atomically: true, encoding: .utf8)
        try FileManager.default.createSymbolicLink(
            at: projectURL.appendingPathComponent(".nvmrc"),
            withDestinationURL: externalURL
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".nvmrc"))
        #expect(result.project.symlinkedFiles.contains(".nvmrc"))
        #expect(result.project.runtimeHints.node == nil)
        #expect(result.policy.askFirstCommands.contains("following project symlinks before reviewing targets"))
        #expect(result.policy.askFirstCommands.contains("dependency installs before reviewing symlinked project metadata"))
        #expect(result.warnings.contains("Project symlinks detected (.nvmrc); do not follow linked metadata or secret-bearing directories before reviewing targets."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
        }
    }

    @Test
    func scanComparisonSurfacesSymlinkedProjectSignalDeltasWithoutValues() throws {
        let secretValue = "HH_PREVIOUS_SCAN_SYMLINK_SECRET_VALUE"
        let previousProjectURL = try makeProject(files: [:])
        let currentProjectURL = try makeProject(files: [:])
        let externalURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try secretValue.write(to: externalURL, atomically: true, encoding: .utf8)
        try FileManager.default.createSymbolicLink(
            at: currentProjectURL.appendingPathComponent(".nvmrc"),
            withDestinationURL: externalURL
        )
        let runner = FakeCommandRunner(results: [:])
        let previous = HabitatScanner(runner: runner).scan(projectURL: previousProjectURL)
        let current = HabitatScanner(runner: runner).scan(projectURL: currentProjectURL)

        let changes = ScanComparator().compare(previous: previous, current: current)
        let symlinkChange = changes.first(where: { $0.category == "project_symlinks" })

        #expect(symlinkChange?.summary == "Project symlink signals changed: added .nvmrc.")
        #expect(symlinkChange?.impact == "Review symlink targets before following linked metadata or using dependency signals.")

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: current.withChanges(changes), outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Project symlink signals changed: added .nvmrc. Review symlink targets before following linked metadata or using dependency signals."))

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
        }
    }

    @Test
    func scanDoesNotSelectPackageManagerFromSymlinkedWorkflowSignals() throws {
        let secretValue = "HH_SYMLINKED_PACKAGE_JSON_SECRET_VALUE"
        let projectURL = try makeProject(files: [:])
        let externalDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: externalDirectoryURL, withIntermediateDirectories: true)
        try """
        {
          "scripts": {
            "test": "\(secretValue)"
          }
        }
        """.write(to: externalDirectoryURL.appendingPathComponent("package.json"), atomically: true, encoding: .utf8)
        try secretValue.write(
            to: externalDirectoryURL.appendingPathComponent("package-lock.json"),
            atomically: true,
            encoding: .utf8
        )
        try FileManager.default.createSymbolicLink(
            at: projectURL.appendingPathComponent("package.json"),
            withDestinationURL: externalDirectoryURL.appendingPathComponent("package.json")
        )
        try FileManager.default.createSymbolicLink(
            at: projectURL.appendingPathComponent("package-lock.json"),
            withDestinationURL: externalDirectoryURL.appendingPathComponent("package-lock.json")
        )

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v22.15.0", stderr: ""),
            "/usr/bin/env npm --version": .init(name: "/usr/bin/env", args: ["npm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "10.9.0", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains("package.json"))
        #expect(result.project.detectedFiles.contains("package-lock.json"))
        #expect(result.project.symlinkedFiles.contains("package.json"))
        #expect(result.project.symlinkedFiles.contains("package-lock.json"))
        #expect(result.project.packageManager == nil)
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("following project symlinks before reviewing targets"))
        #expect(result.warnings.contains("Project symlinks detected (package-lock.json, package.json); do not follow linked metadata or secret-bearing directories before reviewing targets."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("npm run"))
        }
    }

    @Test
    func scanDoesNotTraverseSymlinkedSSHDirectory() throws {
        let secretValue = "HH_SYMLINKED_SSH_SECRET_VALUE"
        let projectURL = try makeProject(files: [:])
        let externalDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: externalDirectoryURL, withIntermediateDirectories: true)
        try secretValue.write(
            to: externalDirectoryURL.appendingPathComponent("id_ed25519"),
            atomically: true,
            encoding: .utf8
        )
        try FileManager.default.createSymbolicLink(
            at: projectURL.appendingPathComponent(".ssh"),
            withDestinationURL: externalDirectoryURL
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.symlinkedFiles.contains(".ssh"))
        #expect(!result.project.detectedFiles.contains(".ssh/id_ed25519"))
        #expect(result.policy.askFirstCommands.contains("following project symlinks before reviewing targets"))
        #expect(!result.policy.forbiddenCommands.contains("cat .ssh/id_ed25519"))
        #expect(result.warnings.contains("Project symlinks detected (.ssh); do not follow linked metadata or secret-bearing directories before reviewing targets."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("cat .ssh/id_ed25519"))
            #expect(!artifact.contains("- .ssh/id_ed25519"))
        }
    }

    @Test
    func scanRecordsSymlinkedPackageAuthConfigDirectoryWithoutReadingTarget() throws {
        let secretValue = "HH_SYMLINKED_BUNDLE_CONFIG_SECRET_VALUE"
        let projectURL = try makeProject(files: [:])
        let externalDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: externalDirectoryURL, withIntermediateDirectories: true)
        try "BUNDLE_GEMS__EXAMPLE__COM: \(secretValue)\n".write(
            to: externalDirectoryURL.appendingPathComponent("config"),
            atomically: true,
            encoding: .utf8
        )
        try FileManager.default.createSymbolicLink(
            at: projectURL.appendingPathComponent(".bundle"),
            withDestinationURL: externalDirectoryURL
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.symlinkedFiles.contains(".bundle"))
        #expect(!result.project.detectedFiles.contains(".bundle/config"))
        #expect(result.policy.askFirstCommands.contains("following project symlinks before reviewing targets"))
        #expect(result.warnings.contains("Project symlinks detected (.bundle); do not follow linked metadata or secret-bearing directories before reviewing targets."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("BUNDLE_GEMS__EXAMPLE__COM"))
            #expect(!artifact.contains(".bundle/config"))
        }
    }
}
