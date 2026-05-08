import Testing
import Foundation
@testable import HabitatCore

struct ScanExecutionInfrastructureTests {
    @Test
    func scanArgumentParserDefaultsToCurrentDirectory() throws {
        let options = try ScanArgumentParser().parse(
            arguments: [],
            currentDirectory: "/tmp/project"
        )

        #expect(options == ScanOptions(
            projectPath: "/tmp/project",
            outputPath: "/tmp/project/habitat-report",
            previousScanPath: nil
        ))
    }

    @Test
    func scanArgumentParserRejectsUnsafeAmbiguousArguments() throws {
        let parser = ScanArgumentParser()

        #expect(throws: ScanArgumentError.missingValue(flag: "--project")) {
            try parser.parse(arguments: ["--project"], currentDirectory: "/tmp/project")
        }

        #expect(throws: ScanArgumentError.missingValue(flag: "--project")) {
            try parser.parse(arguments: ["--project", "--output", "/tmp/out"], currentDirectory: "/tmp/project")
        }

        #expect(throws: ScanArgumentError.emptyValue(flag: "--output")) {
            try parser.parse(arguments: ["--project", "/tmp/project", "--output", ""], currentDirectory: "/tmp/project")
        }

        #expect(throws: ScanArgumentError.emptyValue(flag: "--previous-scan")) {
            try parser.parse(arguments: ["--previous-scan", ""], currentDirectory: "/tmp/project")
        }

        #expect(throws: ScanArgumentError.duplicateFlag(flag: "--output")) {
            try parser.parse(arguments: ["--output", "/tmp/a", "--output", "/tmp/b"], currentDirectory: "/tmp/project")
        }

        #expect(throws: ScanArgumentError.unknownArgument("--previous_scan")) {
            try parser.parse(arguments: ["--previous_scan", "/tmp/old"], currentDirectory: "/tmp/project")
        }
    }

    @Test
    func processCommandRunnerMarksEnvMissingTargetAsUnavailable() throws {
        let missingTool = "hazakura-definitely-missing-tool-\(UUID().uuidString)"
        let result = ProcessCommandRunner().run(
            executable: "/usr/bin/env",
            arguments: [missingTool, "--version"],
            timeout: 1.0
        )

        #expect(result.available == false)
        #expect(result.exitCode == 127)
        #expect(result.timedOut == false)
        #expect(result.args == [missingTool, "--version"])
    }

    @Test
    func habitatSkillHelperPrefersBuildBinaryOverDistBinary() throws {
        let fileManager = FileManager.default
        let projectURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let outputURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let markerURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)
        try "not a valid manifest".write(
            to: projectURL.appendingPathComponent("Package.swift"),
            atomically: true,
            encoding: .utf8
        )
        try fileManager.createDirectory(
            at: projectURL.appendingPathComponent("Sources/habitat-scan"),
            withIntermediateDirectories: true
        )
        try "".write(
            to: projectURL.appendingPathComponent("Sources/habitat-scan/main.swift"),
            atomically: true,
            encoding: .utf8
        )

        try writeExecutableScript(
            projectURL.appendingPathComponent(".build/debug/habitat-scan"),
            contents: """
            #!/usr/bin/env bash
            printf 'build\\n' > "$HABITAT_HELPER_MARKER"
            """
        )
        try writeExecutableScript(
            projectURL.appendingPathComponent("dist/habitat-scan"),
            contents: """
            #!/usr/bin/env bash
            printf 'dist\\n' > "$HABITAT_HELPER_MARKER"
            """
        )

        let scriptURL = URL(fileURLWithPath: fileManager.currentDirectoryPath)
            .appendingPathComponent("skills/hazakura-habitat/scripts/run_habitat_scan.sh")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [scriptURL.path, projectURL.path, outputURL.path]
        process.environment = ProcessInfo.processInfo.environment.merging([
            "HABITAT_HELPER_MARKER": markerURL.path
        ]) { _, new in new }

        try process.run()
        process.waitUntilExit()

        #expect(process.terminationStatus == 0)
        #expect(try String(contentsOf: markerURL, encoding: .utf8) == "build\n")
    }

    @Test
    func habitatSkillHelperRetriesSourceBuildWithWritableCacheAndNoSandbox() throws {
        let fileManager = FileManager.default
        let projectURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let outputURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let binDirURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let markerURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: binDirURL, withIntermediateDirectories: true)
        try "not a valid manifest".write(
            to: projectURL.appendingPathComponent("Package.swift"),
            atomically: true,
            encoding: .utf8
        )
        try fileManager.createDirectory(
            at: projectURL.appendingPathComponent("Sources/habitat-scan"),
            withIntermediateDirectories: true
        )
        try "".write(
            to: projectURL.appendingPathComponent("Sources/habitat-scan/main.swift"),
            atomically: true,
            encoding: .utf8
        )

        try writeExecutableScript(
            binDirURL.appendingPathComponent("swift"),
            contents: """
            #!/usr/bin/env bash
            if [[ "$*" == *"--disable-sandbox"* && -n "${CLANG_MODULE_CACHE_PATH:-}" ]]; then
              project=""
              while [[ "$#" -gt 0 ]]; do
                if [[ "$1" == "--package-path" ]]; then
                  project="$2"
                  shift 2
                else
                  shift
                fi
              done
              mkdir -p "$project/.build/debug"
              cat > "$project/.build/debug/habitat-scan" <<'EOF'
            #!/usr/bin/env bash
            printf 'fallback\\n' > "$HABITAT_HELPER_MARKER"
            EOF
              chmod +x "$project/.build/debug/habitat-scan"
              exit 0
            fi
            exit 1
            """
        )

        let scriptURL = URL(fileURLWithPath: fileManager.currentDirectoryPath)
            .appendingPathComponent("skills/hazakura-habitat/scripts/run_habitat_scan.sh")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [scriptURL.path, projectURL.path, outputURL.path]
        process.environment = ProcessInfo.processInfo.environment.merging([
            "HABITAT_HELPER_MARKER": markerURL.path,
            "PATH": "\(binDirURL.path):/usr/bin:/bin:/usr/sbin:/sbin",
        ]) { _, new in new }

        try process.run()
        process.waitUntilExit()

        #expect(process.terminationStatus == 0)
        #expect(try String(contentsOf: markerURL, encoding: .utf8) == "fallback\n")
    }

    @Test
    func scanGuardsMissingProjectPathBeforeProjectCommands() throws {
        let projectURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == nil)
        #expect(result.policy.askFirstCommands.first == "running project commands before project path is verified")
        #expect(result.warnings.contains("Project path is not an existing directory; verify --project before running project commands."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify the project path before running project commands."))
        #expect(context.contains("Ask before `running project commands before project path is verified`."))
        #expect(context.contains("Project path is not an existing directory; verify --project before running project commands."))
        #expect(!context.contains("No primary package manager signal detected"))
        #expect(!context.contains("Use read-only inspection first."))
        #expect(policy.contains("`path existence checks`"))
        #expect(policy.contains("`running project commands before project path is verified`"))
        #expect(!policy.contains("`read-only project inspection, including rg <pattern>`"))
    }

    @Test
    func scanKeepsGoingWhenCommandsAreMissing() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift package"
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "swiftpm")
        #expect(result.commands.allSatisfy { !$0.available })
        #expect(result.diagnostics.count == result.commands.count)
    }
}
