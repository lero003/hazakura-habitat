import Testing
import Foundation
@testable import HabitatCore

struct SwiftPackagePolicyTests {
    @Test
    func scanTreatsXcodeWorkspaceAsXcodebuildProject() throws {
        let projectURL = try makeProject(files: [:])
        try FileManager.default.createDirectory(at: projectURL.appendingPathComponent("Demo App.xcworkspace"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: projectURL.appendingPathComponent("Demo App.xcodeproj"), withIntermediateDirectories: true)

        let runner = FakeCommandRunner(results: [
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: ""),
            "/usr/bin/which -a xcodebuild": .init(name: "/usr/bin/which", args: ["-a", "xcodebuild"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/xcodebuild", stderr: ""),
            "/usr/bin/env xcodebuild -version": .init(name: "/usr/bin/env", args: ["xcodebuild", "-version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Xcode 16.3\nBuild version 16E140", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains("Demo App.xcworkspace"))
        #expect(result.project.detectedFiles.contains("Demo App.xcodeproj"))
        #expect(result.project.packageManager == "xcodebuild")
        #expect(result.policy.preferredCommands == ["xcodebuild -list -workspace 'Demo App.xcworkspace'"])
        #expect(result.policy.askFirstCommands.contains("xcodebuild build/test/archive before selecting a scheme"))
        #expect(result.policy.askFirstCommands.contains("xcodebuild -resolvePackageDependencies"))
        #expect(result.policy.askFirstCommands.contains("xcodebuild -allowProvisioningUpdates"))
        #expect(!result.policy.askFirstCommands.contains("running Xcode build commands before xcodebuild is available"))
        #expect(!result.policy.askFirstCommands.contains("Swift/Xcode build commands before xcode-select -p succeeds"))
        #expect(result.tools.resolvedPaths.contains(where: { $0.name == "xcodebuild" && !$0.paths.isEmpty }))
        #expect(result.tools.versions.contains(where: { $0.name == "xcodebuild" && $0.available }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `xcodebuild` because project files point to it."))
        #expect(context.contains("Prefer `xcodebuild -list -workspace 'Demo App.xcworkspace'`."))
        #expect(context.contains("Ask before `xcodebuild build/test/archive before selecting a scheme`."))
        #expect(policy.contains("`xcodebuild -list -workspace 'Demo App.xcworkspace'`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(policy.contains("`xcodebuild -resolvePackageDependencies`"))
    }

    @Test
    func scanGuardsXcodebuildCommandsWhenXcodebuildIsMissing() throws {
        let projectURL = try makeProject(files: [:])
        try FileManager.default.createDirectory(at: projectURL.appendingPathComponent("Demo.xcodeproj"), withIntermediateDirectories: true)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "xcodebuild")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Xcode build commands before xcodebuild is available"))
        #expect(result.policy.askFirstCommands.contains("Swift/Xcode build commands before xcode-select -p succeeds"))
        #expect(result.policy.askFirstCommands.contains("xcodebuild build/test/archive before selecting a scheme"))
        #expect(result.warnings.contains("Project files prefer xcodebuild, but xcodebuild was not found on PATH; ask before running Xcode build commands."))
        #expect(result.warnings.contains("xcode-select -p did not return a developer directory; ask before Swift/Xcode build or test commands."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify Xcode tooling before running Xcode commands."))
        #expect(context.contains("Ask before `running Xcode build commands before xcodebuild is available`."))
        #expect(context.contains("Ask before `Swift/Xcode build commands before xcode-select -p succeeds`."))
        #expect(context.contains("Project files prefer xcodebuild, but xcodebuild was not found on PATH; ask before running Xcode build commands."))
        #expect(context.contains("xcode-select -p unavailable: missing"))
        #expect(!context.contains("Use `xcodebuild` because project files point to it."))
        #expect(!context.contains("Prefer `xcodebuild -list -project Demo.xcodeproj`."))
        #expect(policy.contains("`running Xcode build commands before xcodebuild is available`"))
        #expect(policy.contains("`Swift/Xcode build commands before xcode-select -p succeeds`"))
        #expect(!policy.contains("`xcodebuild -list -project Demo.xcodeproj`"))
    }

    @Test
    func scanSuppressesXcodebuildPreferredCommandsWhenVersionCheckFails() throws {
        let projectURL = try makeProject(files: [:])
        try FileManager.default.createDirectory(at: projectURL.appendingPathComponent("Demo.xcodeproj"), withIntermediateDirectories: true)

        let runner = FakeCommandRunner(results: [
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: ""),
            "/usr/bin/which -a xcodebuild": .init(name: "/usr/bin/which", args: ["-a", "xcodebuild"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/xcodebuild", stderr: ""),
            "/usr/bin/env xcodebuild -version": .init(name: "/usr/bin/env", args: ["xcodebuild", "-version"], exitCode: 1, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "xcodebuild: failed to load developer tools"),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "xcodebuild")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Xcode build commands before xcodebuild version check succeeds"))
        #expect(!result.policy.askFirstCommands.contains("running Xcode build commands before xcodebuild is available"))
        #expect(!result.policy.askFirstCommands.contains("Swift/Xcode build commands before xcode-select -p succeeds"))
        #expect(result.diagnostics.contains("xcodebuild -version failed with exit code 1: xcodebuild: failed to load developer tools"))
        #expect(result.tools.versions.contains(where: { $0.name == "xcodebuild" && !$0.available }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running Xcode build commands before xcodebuild version check succeeds`."))
        #expect(context.contains("xcodebuild -version failed with exit code 1: xcodebuild: failed to load developer tools"))
        #expect(context.contains("Verify Xcode tooling before running Xcode commands."))
        #expect(!context.contains("Use `xcodebuild` because project files point to it."))
        #expect(!context.contains("Prefer `xcodebuild -list -project Demo.xcodeproj`."))
        #expect(policy.contains("`running Xcode build commands before xcodebuild version check succeeds`"))
        #expect(!policy.contains("`xcodebuild -list -project Demo.xcodeproj`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`build commands for the selected project`"))
    }

    @Test
    func scanSuppressesXcodebuildPreferredCommandsWhenDeveloperDirectoryIsMissing() throws {
        let projectURL = try makeProject(files: [:])
        try FileManager.default.createDirectory(at: projectURL.appendingPathComponent("Demo.xcodeproj"), withIntermediateDirectories: true)

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env xcodebuild -version": .init(name: "/usr/bin/env", args: ["xcodebuild", "-version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Xcode 16.3\nBuild version 16E140", stderr: ""),
            "/usr/bin/which -a xcodebuild": .init(name: "/usr/bin/which", args: ["-a", "xcodebuild"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/xcodebuild", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "xcodebuild")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(!result.policy.askFirstCommands.contains("running Xcode build commands before xcodebuild is available"))
        #expect(result.policy.askFirstCommands.contains("Swift/Xcode build commands before xcode-select -p succeeds"))
        #expect(result.warnings.contains("xcode-select -p did not return a developer directory; ask before Swift/Xcode build or test commands."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `Swift/Xcode build commands before xcode-select -p succeeds`."))
        #expect(context.contains("xcode-select -p unavailable: missing"))
        #expect(context.contains("Verify Xcode tooling before running Xcode commands."))
        #expect(!context.contains("Use `xcodebuild` because project files point to it."))
        #expect(!context.contains("Prefer `xcodebuild -list -project Demo.xcodeproj`."))
        #expect(!policy.contains("`xcodebuild -list -project Demo.xcodeproj`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`build commands for the selected project`"))
    }

    @Test
    func scanAsksBeforeSwiftBuildWhenDeveloperDirectoryIsMissing() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift package"
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "swiftpm")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(!result.policy.askFirstCommands.contains("running SwiftPM commands before swift is available"))
        #expect(result.policy.askFirstCommands.contains("Swift/Xcode build commands before xcode-select -p succeeds"))
        #expect(result.warnings.contains("xcode-select -p did not return a developer directory; ask before Swift/Xcode build or test commands."))
        #expect(result.diagnostics.contains("xcode-select -p unavailable: missing"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(!context.contains("Prefer `swift test`."))
        #expect(!context.contains("Prefer `swift build`."))
        #expect(context.contains("Ask before `Swift/Xcode build commands before xcode-select -p succeeds`."))
        #expect(context.contains("xcode-select -p unavailable: missing"))
        #expect(policy.contains("`Swift/Xcode build commands before xcode-select -p succeeds`"))
        #expect(!policy.contains("`swift test`"))
        #expect(!policy.contains("`swift build`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`build commands for the selected project`"))
    }

    @Test
    func scanAsksBeforeSwiftBuildWhenDeveloperDirectoryOutputIsEmpty() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift package"
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: " \n", stderr: ""),
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "swiftpm")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("Swift/Xcode build commands before xcode-select -p succeeds"))
        #expect(result.diagnostics.contains("xcode-select -p returned empty output"))
        #expect(result.tools.versions.contains(where: { $0.name == "xcode-select" && !$0.available && $0.version == nil }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `Swift/Xcode build commands before xcode-select -p succeeds`."))
        #expect(context.contains("xcode-select -p returned empty output"))
        #expect(!context.contains("Prefer `swift test`."))
        #expect(!context.contains("Prefer `swift build`."))
        #expect(policy.contains("`Swift/Xcode build commands before xcode-select -p succeeds`"))
        #expect(!policy.contains("`swift test`"))
        #expect(!policy.contains("`swift build`"))
    }

    @Test
    func agentContextNamesSwiftPMExecutableWhenCommandsAreAllowed() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift package"
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: ""),
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "swiftpm")
        #expect(result.policy.preferredCommands == ["swift test", "swift build"])

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Use SwiftPM (`swift`) because project files point to it."))
        #expect(!context.contains("Use `swiftpm` because project files point to it."))
        #expect(context.contains("Prefer `swift test`."))
        #expect(context.contains("Prefer `swift build`."))
    }

    @Test
    func scanAsksBeforeSwiftPMCommandsWhenSwiftVersionCheckFails() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift package"
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 1, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "swift: failed to load toolchain"),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: ""),
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "swiftpm")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running SwiftPM commands before swift version check succeeds"))
        #expect(!result.policy.askFirstCommands.contains("running SwiftPM commands before swift is available"))
        #expect(!result.policy.askFirstCommands.contains("Swift/Xcode build commands before xcode-select -p succeeds"))
        #expect(result.diagnostics.contains("swift --version failed with exit code 1: swift: failed to load toolchain"))
        #expect(result.tools.versions.contains(where: { $0.name == "swift" && !$0.available }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `swift` before running SwiftPM commands."))
        #expect(context.contains("Ask before `running SwiftPM commands before swift version check succeeds`."))
        #expect(context.contains("swift --version failed with exit code 1: swift: failed to load toolchain"))
        #expect(!context.contains("Use `swiftpm` because project files point to it."))
        #expect(!context.contains("Prefer `swift test`."))
        #expect(!context.contains("Prefer `swift build`."))
        #expect(policy.contains("`running SwiftPM commands before swift version check succeeds`"))
        #expect(!policy.contains("`swift test`"))
        #expect(!policy.contains("`swift build`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`build commands for the selected project`"))
    }

    @Test
    func scanAsksBeforeSwiftPMCommandsWhenSwiftVersionCheckOutputIsEmpty() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift package"
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: " \n", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: ""),
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "swiftpm")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running SwiftPM commands before swift version check succeeds"))
        #expect(!result.policy.askFirstCommands.contains("running SwiftPM commands before swift is available"))
        #expect(!result.policy.askFirstCommands.contains("Swift/Xcode build commands before xcode-select -p succeeds"))
        #expect(result.diagnostics.contains("swift --version returned empty output"))
        #expect(result.tools.versions.contains(where: { $0.name == "swift" && !$0.available && $0.version == nil }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `swift` before running SwiftPM commands."))
        #expect(context.contains("Ask before `running SwiftPM commands before swift version check succeeds`."))
        #expect(context.contains("swift --version returned empty output"))
        #expect(!context.contains("Use `swiftpm` because project files point to it."))
        #expect(!context.contains("Prefer `swift test`."))
        #expect(!context.contains("Prefer `swift build`."))
        #expect(policy.contains("`running SwiftPM commands before swift version check succeeds`"))
        #expect(!policy.contains("`swift test`"))
        #expect(!policy.contains("`swift build`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`build commands for the selected project`"))
    }

    @Test
    func scanAsksBeforeSwiftPMCommandsWhenSwiftVersionCheckTimesOut() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift package"
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: nil, durationMs: 3000, timedOut: true, available: true, stdout: "", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: ""),
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "swiftpm")
        #expect(result.policy.askFirstCommands.contains("running SwiftPM commands before swift version check succeeds"))
        #expect(!result.policy.askFirstCommands.contains("running SwiftPM commands before swift is available"))
        #expect(result.diagnostics.contains("swift --version timed out"))
        #expect(result.tools.versions.contains(where: { $0.name == "swift" && !$0.available }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `swift` before running SwiftPM commands."))
        #expect(context.contains("Ask before `running SwiftPM commands before swift version check succeeds`."))
        #expect(context.contains("swift --version timed out"))
        #expect(!context.contains("Prefer `swift test`."))
        #expect(!context.contains("Prefer `swift build`."))
        #expect(policy.contains("`running SwiftPM commands before swift version check succeeds`"))
        #expect(!policy.contains("`swift test`"))
        #expect(!policy.contains("`swift build`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`build commands for the selected project`"))
    }

    @Test
    func scanGuardsSwiftPMCommandsWhenSwiftIsMissing() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift package"
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "swiftpm")
        #expect(result.policy.preferredCommands.isEmpty)
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
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running SwiftPM commands before swift is available"))
        #expect(result.policy.askFirstCommands.contains("swift package resolve"))
        #expect(result.policy.askFirstCommands.contains("swift package update"))
        #expect(result.warnings.contains("Project files prefer SwiftPM, but swift was not found on PATH; ask before running SwiftPM commands."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `swift` before running SwiftPM commands."))
        #expect(context.contains("Ask before `running SwiftPM commands before swift is available`."))
        #expect(!context.contains("Prefer `swift test`."))
        #expect(!policy.contains("`swift test`"))
        #expect(policy.contains("`swift package resolve`"))
    }
}
