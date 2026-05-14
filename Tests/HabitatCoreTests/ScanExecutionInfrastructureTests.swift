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

        #expect(throws: ScanArgumentError.invalidStdoutArtifact("environment-json")) {
            try parser.parse(arguments: ["--stdout", "environment-json"], currentDirectory: "/tmp/project")
        }

        #expect(throws: ScanArgumentError.incompatibleFlags("--stdout", "--output")) {
            try parser.parse(
                arguments: ["--stdout", "agent-context", "--output", "/tmp/report"],
                currentDirectory: "/tmp/project"
            )
        }
    }

    @Test
    func scanArgumentParserAcceptsStdoutArtifacts() throws {
        let parser = ScanArgumentParser()

        let scanResultOptions = try parser.parse(
            arguments: ["--project", "/tmp/project", "--stdout", "scan-result"],
            currentDirectory: "/tmp/current"
        )
        #expect(scanResultOptions == ScanOptions(
            projectPath: "/tmp/project",
            outputPath: "/tmp/current/habitat-report",
            previousScanPath: nil,
            stdoutArtifact: .scanResult
        ))

        let agentContextOptions = try parser.parse(
            arguments: ["--project", "/tmp/project", "--stdout", "agent-context"],
            currentDirectory: "/tmp/current"
        )
        #expect(agentContextOptions == ScanOptions(
            projectPath: "/tmp/project",
            outputPath: "/tmp/current/habitat-report",
            previousScanPath: nil,
            stdoutArtifact: .agentContext
        ))

        let commandPolicyOptions = try parser.parse(
            arguments: [
                "--project", "/tmp/project",
                "--previous-scan", "/tmp/old-report",
                "--stdout", "command-policy",
            ],
            currentDirectory: "/tmp/current"
        )
        #expect(commandPolicyOptions == ScanOptions(
            projectPath: "/tmp/project",
            outputPath: "/tmp/current/habitat-report",
            previousScanPath: "/tmp/old-report",
            stdoutArtifact: .commandPolicy
        ))

        let environmentReportOptions = try parser.parse(
            arguments: ["--project", "/tmp/project", "--stdout", "environment-report"],
            currentDirectory: "/tmp/current"
        )
        #expect(environmentReportOptions == ScanOptions(
            projectPath: "/tmp/project",
            outputPath: "/tmp/current/habitat-report",
            previousScanPath: nil,
            stdoutArtifact: .environmentReport
        ))
    }

    @Test
    func scanArgumentParserAcceptsStdoutArtifactFilenames() throws {
        let parser = ScanArgumentParser()

        let aliases: [(String, StdoutArtifact)] = [
            ("scan_result.json", .scanResult),
            ("./scan_result.json", .scanResult),
            ("agent_context.md", .agentContext),
            ("./agent_context.md", .agentContext),
            ("command_policy.md", .commandPolicy),
            ("./command_policy.md", .commandPolicy),
            ("environment_report.md", .environmentReport),
            ("./environment_report.md", .environmentReport),
        ]

        for (value, artifact) in aliases {
            let options = try parser.parse(
                arguments: ["--project", "/tmp/project", "--stdout", value],
                currentDirectory: "/tmp/current"
            )
            #expect(options == ScanOptions(
                projectPath: "/tmp/project",
                outputPath: "/tmp/current/habitat-report",
                previousScanPath: nil,
                stdoutArtifact: artifact
            ))
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
    func metadataCheckScriptAcceptsMatchingBinaryAndGeneratorVersions() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let projectURL = tempURL.appendingPathComponent("project")
        let binaryURL = tempURL.appendingPathComponent("habitat-scan")
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            binaryURL,
            contents: """
            #!/usr/bin/env bash
            set -euo pipefail
            if [[ "$1" == "--version" ]]; then
              printf 'habitat-scan 1.2.3\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "scan-result" ]]; then
              printf '{"schemaVersion":"0.1","generatorVersion":"1.2.3","artifacts":[{"name":"agent_context.md","role":"agent_context","relativePath":"agent_context.md","format":"markdown","readOrder":1,"readTrigger":"before_any_project_command","agentUse":"read_first"},{"name":"command_policy.md","role":"command_policy","relativePath":"command_policy.md","format":"markdown","readOrder":2,"readTrigger":"before_risky_remote_mutating_secret_or_environment_sensitive_commands","agentUse":"consult_before_risky_commands"},{"name":"environment_report.md","role":"environment_report","relativePath":"environment_report.md","format":"markdown","readOrder":3,"readTrigger":"only_for_diagnostics_or_audit","agentUse":"debug_audit_only"}]}\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "agent-context" ]]; then
              printf '# Agent Context\\n\\n## Use\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "command-policy" ]]; then
              printf '# Command Policy\\n\\n## Allowed\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "environment-report" ]]; then
              printf '# Environment Report\\n\\n## Diagnostics\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "scan_result.json" ]]; then
              printf '{"schemaVersion":"0.1","generatorVersion":"1.2.3","artifacts":[{"name":"agent_context.md","role":"agent_context","relativePath":"agent_context.md","format":"markdown","readOrder":1,"readTrigger":"before_any_project_command","agentUse":"read_first"},{"name":"command_policy.md","role":"command_policy","relativePath":"command_policy.md","format":"markdown","readOrder":2,"readTrigger":"before_risky_remote_mutating_secret_or_environment_sensitive_commands","agentUse":"consult_before_risky_commands"},{"name":"environment_report.md","role":"environment_report","relativePath":"environment_report.md","format":"markdown","readOrder":3,"readTrigger":"only_for_diagnostics_or_audit","agentUse":"debug_audit_only"}]}\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "agent_context.md" ]]; then
              printf '# Agent Context\\n\\n## Use\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "command_policy.md" ]]; then
              printf '# Command Policy\\n\\n## Allowed\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "environment_report.md" ]]; then
              printf '# Environment Report\\n\\n## Diagnostics\\n'
              exit 0
            fi
            exit 2
            """
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/check_habitat_metadata.sh",
            binaryURL.path,
            projectURL.path,
            "1.2.3",
        ]

        let stdout = Pipe()
        process.standardOutput = stdout
        try process.run()
        process.waitUntilExit()

        let output = String(decoding: stdout.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 0)
        #expect(output.contains("binaryVersion=1.2.3"))
        #expect(output.contains("schemaVersion=0.1"))
        #expect(output.contains("generatorVersion=1.2.3"))
        #expect(output.contains("agentContext=ok"))
        #expect(output.contains("commandPolicy=ok"))
        #expect(output.contains("environmentReport=ok"))
    }

    @Test
    func releaseVerificationScriptChecksumsBeforeMetadataChecks() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let releaseURL = tempURL.appendingPathComponent("release")
        let projectURL = tempURL.appendingPathComponent("project")
        let binaryURL = releaseURL.appendingPathComponent("habitat-scan")
        try fileManager.createDirectory(at: releaseURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            binaryURL,
            contents: releaseVerificationFakeBinaryScript(version: "1.2.3")
        )
        let checksum = try sha256(binaryURL)
        try "\(checksum)  habitat-scan\n".write(
            to: releaseURL.appendingPathComponent("SHA256SUMS"),
            atomically: true,
            encoding: .utf8
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/verify_habitat_release.sh",
            releaseURL.path,
            projectURL.path,
            "1.2.3",
        ]

        let stdout = Pipe()
        process.standardOutput = stdout
        try process.run()
        process.waitUntilExit()

        let output = String(decoding: stdout.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 0)
        #expect(output.contains("habitat-scan: OK"))
        #expect(output.contains("binaryVersion=1.2.3"))
        #expect(output.contains("schemaVersion=0.1"))
        #expect(output.contains("generatorVersion=1.2.3"))
    }

    @Test
    func releaseVerificationScriptRejectsBadChecksumBeforeRunningBinary() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let releaseURL = tempURL.appendingPathComponent("release")
        let projectURL = tempURL.appendingPathComponent("project")
        let binaryURL = releaseURL.appendingPathComponent("habitat-scan")
        let markerURL = tempURL.appendingPathComponent("binary-ran")
        try fileManager.createDirectory(at: releaseURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            binaryURL,
            contents: """
            #!/usr/bin/env bash
            printf 'ran\\n' > "\(markerURL.path)"
            exit 0
            """
        )
        try "0000000000000000000000000000000000000000000000000000000000000000  habitat-scan\n".write(
            to: releaseURL.appendingPathComponent("SHA256SUMS"),
            atomically: true,
            encoding: .utf8
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/verify_habitat_release.sh",
            releaseURL.path,
            projectURL.path,
            "1.2.3",
        ]

        try process.run()
        process.waitUntilExit()

        #expect(process.terminationStatus != 0)
        #expect(!fileManager.fileExists(atPath: markerURL.path))
    }

    @Test
    func releaseVerificationScriptRejectsChecksumEntriesOutsideReleaseDirectory() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let releaseURL = tempURL.appendingPathComponent("release")
        let projectURL = tempURL.appendingPathComponent("project")
        let binaryURL = releaseURL.appendingPathComponent("habitat-scan")
        let markerURL = tempURL.appendingPathComponent("binary-ran")
        try fileManager.createDirectory(at: releaseURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            binaryURL,
            contents: """
            #!/usr/bin/env bash
            printf 'ran\\n' > "\(markerURL.path)"
            exit 0
            """
        )
        try "0000000000000000000000000000000000000000000000000000000000000000  ../habitat-scan\n".write(
            to: releaseURL.appendingPathComponent("SHA256SUMS"),
            atomically: true,
            encoding: .utf8
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/verify_habitat_release.sh",
            releaseURL.path,
            projectURL.path,
            "1.2.3",
        ]

        let stderr = Pipe()
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let error = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 1)
        #expect(error.contains("SHA256SUMS entry must stay inside release directory"))
        #expect(!fileManager.fileExists(atPath: markerURL.path))
    }

    @Test
    func releaseVerificationScriptRejectsZipEntriesOutsideExtractionDirectory() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let releaseURL = tempURL.appendingPathComponent("release")
        let projectURL = tempURL.appendingPathComponent("project")
        let zipRootURL = tempURL.appendingPathComponent("zip-root")
        let escapedEntryURL = tempURL.appendingPathComponent("escaped-habitat-scan")
        let zipURL = releaseURL.appendingPathComponent("habitat-scan-macos.zip")
        try fileManager.createDirectory(at: releaseURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: zipRootURL, withIntermediateDirectories: true)
        try "not a safe binary".write(to: escapedEntryURL, atomically: true, encoding: .utf8)

        let zipProcess = Process()
        zipProcess.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        zipProcess.currentDirectoryURL = zipRootURL
        zipProcess.arguments = ["-q", zipURL.path, "../escaped-habitat-scan"]
        try zipProcess.run()
        zipProcess.waitUntilExit()
        #expect(zipProcess.terminationStatus == 0)

        let checksum = try sha256(zipURL)
        try "\(checksum)  habitat-scan-macos.zip\n".write(
            to: releaseURL.appendingPathComponent("SHA256SUMS"),
            atomically: true,
            encoding: .utf8
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/verify_habitat_release.sh",
            releaseURL.path,
            projectURL.path,
            "1.2.3",
        ]

        let stderr = Pipe()
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let error = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 1)
        #expect(error.contains("habitat-scan-macos.zip entry must stay inside extraction directory"))
        #expect(error.contains("../escaped-habitat-scan"))
    }

    @Test
    func releaseVerificationScriptRejectsSymlinkedZipBinaryBeforeRunningBinary() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let releaseURL = tempURL.appendingPathComponent("release")
        let projectURL = tempURL.appendingPathComponent("project")
        let zipRootURL = tempURL.appendingPathComponent("zip-root")
        let zipDistURL = zipRootURL.appendingPathComponent("dist")
        let zipBinaryURL = zipDistURL.appendingPathComponent("habitat-scan")
        let outsideBinaryURL = tempURL.appendingPathComponent("outside-habitat-scan")
        let markerURL = tempURL.appendingPathComponent("binary-ran")
        let zipURL = releaseURL.appendingPathComponent("habitat-scan-macos.zip")
        try fileManager.createDirectory(at: releaseURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: zipDistURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            outsideBinaryURL,
            contents: """
            #!/usr/bin/env bash
            printf 'ran\\n' > "\(markerURL.path)"
            exit 0
            """
        )
        try fileManager.createSymbolicLink(at: zipBinaryURL, withDestinationURL: outsideBinaryURL)

        let zipProcess = Process()
        zipProcess.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        zipProcess.currentDirectoryURL = zipRootURL
        zipProcess.arguments = ["-qry", zipURL.path, "dist/habitat-scan"]
        try zipProcess.run()
        zipProcess.waitUntilExit()
        #expect(zipProcess.terminationStatus == 0)

        let checksum = try sha256(zipURL)
        try "\(checksum)  habitat-scan-macos.zip\n".write(
            to: releaseURL.appendingPathComponent("SHA256SUMS"),
            atomically: true,
            encoding: .utf8
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/verify_habitat_release.sh",
            releaseURL.path,
            projectURL.path,
            "1.2.3",
        ]

        let stderr = Pipe()
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let error = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 1)
        #expect(error.contains("verified release binary must not be a symlink"))
        #expect(!fileManager.fileExists(atPath: markerURL.path))
    }

    @Test
    func printArtifactScriptPrintsRequestedArtifactWithoutReportDirectory() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let projectURL = tempURL.appendingPathComponent("project")
        let binaryURL = tempURL.appendingPathComponent("habitat-scan")
        let reportURL = projectURL.appendingPathComponent("habitat-report")
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            binaryURL,
            contents: """
            #!/usr/bin/env bash
            set -euo pipefail
            if [[ "$1" == "--version" ]]; then
              printf 'habitat-scan 1.2.3\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "scan-result" ]]; then
              printf '{"schemaVersion":"0.1","generatorVersion":"1.2.3","artifacts":[{"name":"agent_context.md","role":"agent_context","relativePath":"agent_context.md","format":"markdown","readOrder":1,"readTrigger":"before_any_project_command","agentUse":"read_first"},{"name":"command_policy.md","role":"command_policy","relativePath":"command_policy.md","format":"markdown","readOrder":2,"readTrigger":"before_risky_remote_mutating_secret_or_environment_sensitive_commands","agentUse":"consult_before_risky_commands"},{"name":"environment_report.md","role":"environment_report","relativePath":"environment_report.md","format":"markdown","readOrder":3,"readTrigger":"only_for_diagnostics_or_audit","agentUse":"debug_audit_only"}]}\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "agent_context.md" ]]; then
              printf '# Agent Context\\n\\n## Use\\n- Use SwiftPM.\\n'
              exit 0
            fi
            exit 2
            """
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/print_habitat_artifact.sh",
            binaryURL.path,
            projectURL.path,
            "agent_context.md",
            "1.2.3",
        ]

        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let output = String(decoding: stdout.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        let error = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 0)
        #expect(output == "# Agent Context\n\n## Use\n- Use SwiftPM.\n")
        #expect(error.isEmpty)
        #expect(!fileManager.fileExists(atPath: reportURL.path))
    }

    @Test
    func printArtifactScriptAcceptsReportRelativeArtifactPath() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let projectURL = tempURL.appendingPathComponent("project")
        let binaryURL = tempURL.appendingPathComponent("habitat-scan")
        let reportURL = projectURL.appendingPathComponent("habitat-report")
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            binaryURL,
            contents: """
            #!/usr/bin/env bash
            set -euo pipefail
            if [[ "$1" == "--version" ]]; then
              printf 'habitat-scan 1.2.3\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "scan-result" ]]; then
              printf '{"schemaVersion":"0.1","generatorVersion":"1.2.3","artifacts":[{"name":"agent_context.md","role":"agent_context","relativePath":"agent_context.md","format":"markdown","readOrder":1,"readTrigger":"before_any_project_command","agentUse":"read_first"},{"name":"command_policy.md","role":"command_policy","relativePath":"command_policy.md","format":"markdown","readOrder":2,"readTrigger":"before_risky_remote_mutating_secret_or_environment_sensitive_commands","agentUse":"consult_before_risky_commands"},{"name":"environment_report.md","role":"environment_report","relativePath":"environment_report.md","format":"markdown","readOrder":3,"readTrigger":"only_for_diagnostics_or_audit","agentUse":"debug_audit_only"}]}\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "agent_context.md" ]]; then
              printf '# Agent Context\\n\\n## Use\\n- Use SwiftPM.\\n'
              exit 0
            fi
            exit 2
            """
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/print_habitat_artifact.sh",
            binaryURL.path,
            projectURL.path,
            "./agent_context.md",
            "1.2.3",
        ]

        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let output = String(decoding: stdout.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        let error = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 0)
        #expect(output == "# Agent Context\n\n## Use\n- Use SwiftPM.\n")
        #expect(error.isEmpty)
        #expect(!fileManager.fileExists(atPath: reportURL.path))
    }

    @Test
    func printArtifactScriptRejectsIncompleteRequestedArtifactMetadata() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let projectURL = tempURL.appendingPathComponent("project")
        let binaryURL = tempURL.appendingPathComponent("habitat-scan")
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            binaryURL,
            contents: """
            #!/usr/bin/env bash
            set -euo pipefail
            if [[ "$1" == "--version" ]]; then
              printf 'habitat-scan 1.2.3\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "scan-result" ]]; then
              printf '{"schemaVersion":"0.1","generatorVersion":"1.2.3","artifacts":[{"name":"agent_context.md","role":"agent_context","relativePath":"agent_context.md","format":"markdown","readOrder":2,"readTrigger":"before_risky_remote_mutating_secret_or_environment_sensitive_commands","agentUse":"consult_before_risky_commands"}]}\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "agent_context.md" ]]; then
              printf '# Agent Context\\n'
              exit 0
            fi
            exit 2
            """
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/print_habitat_artifact.sh",
            binaryURL.path,
            projectURL.path,
            "agent_context.md",
            "1.2.3",
        ]

        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let output = String(decoding: stdout.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        let error = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 3)
        #expect(output.isEmpty)
        #expect(error.contains("agent_context.md.readOrder expected 1 but found 2"))
        #expect(error.contains("agent_context.md.readTrigger expected 'before_any_project_command'"))
        #expect(error.contains("agent_context.md.agentUse expected 'read_first'"))
    }

    @Test
    func printArtifactScriptRejectsUnexpectedVersionBeforePrintingArtifact() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let projectURL = tempURL.appendingPathComponent("project")
        let binaryURL = tempURL.appendingPathComponent("habitat-scan")
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            binaryURL,
            contents: """
            #!/usr/bin/env bash
            set -euo pipefail
            if [[ "$1" == "--version" ]]; then
              printf 'habitat-scan 1.2.3\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "scan-result" ]]; then
              printf '{"schemaVersion":"0.1","generatorVersion":"1.2.3","artifacts":[{"name":"agent_context.md","role":"agent_context","relativePath":"agent_context.md","format":"markdown"}]}\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "agent-context" ]]; then
              printf '# Agent Context\\n'
              exit 0
            fi
            exit 2
            """
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/print_habitat_artifact.sh",
            binaryURL.path,
            projectURL.path,
            "agent-context",
            "9.9.9",
        ]

        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let output = String(decoding: stdout.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        let error = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 1)
        #expect(output.isEmpty)
        #expect(error.contains("version 1.2.3 does not match expected version 9.9.9"))
    }

    @Test
    func metadataCheckScriptRejectsUnexpectedSchemaVersion() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let projectURL = tempURL.appendingPathComponent("project")
        let binaryURL = tempURL.appendingPathComponent("habitat-scan")
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            binaryURL,
            contents: """
            #!/usr/bin/env bash
            set -euo pipefail
            if [[ "$1" == "--version" ]]; then
              printf 'habitat-scan 1.2.3\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "scan-result" ]]; then
              printf '{"schemaVersion":"9.9","generatorVersion":"1.2.3","artifacts":[{"name":"agent_context.md","role":"agent_context","relativePath":"agent_context.md","format":"markdown","readOrder":1,"readTrigger":"before_any_project_command","agentUse":"read_first"},{"name":"command_policy.md","role":"command_policy","relativePath":"command_policy.md","format":"markdown","readOrder":2,"readTrigger":"before_risky_remote_mutating_secret_or_environment_sensitive_commands","agentUse":"consult_before_risky_commands"},{"name":"environment_report.md","role":"environment_report","relativePath":"environment_report.md","format":"markdown","readOrder":3,"readTrigger":"only_for_diagnostics_or_audit","agentUse":"debug_audit_only"}]}\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "agent-context" ]]; then
              printf '# Agent Context\\n\\n## Use\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "command-policy" ]]; then
              printf '# Command Policy\\n\\n## Allowed\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "environment-report" ]]; then
              printf '# Environment Report\\n\\n## Diagnostics\\n'
              exit 0
            fi
            exit 2
            """
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/check_habitat_metadata.sh",
            binaryURL.path,
            projectURL.path,
        ]

        let stderr = Pipe()
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let error = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 3)
        #expect(error.contains("schemaVersion '9.9' does not match expected '0.1'"))
    }

    @Test
    func metadataCheckScriptRejectsMismatchedBinaryAndGeneratorVersions() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let projectURL = tempURL.appendingPathComponent("project")
        let binaryURL = tempURL.appendingPathComponent("habitat-scan")
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            binaryURL,
            contents: """
            #!/usr/bin/env bash
            set -euo pipefail
            if [[ "$1" == "--version" ]]; then
              printf 'habitat-scan 1.2.3\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "scan-result" ]]; then
              printf '{"schemaVersion":"0.1","generatorVersion":"1.2.4","artifacts":[{"name":"agent_context.md","role":"agent_context","relativePath":"agent_context.md","format":"markdown","readOrder":1,"readTrigger":"before_any_project_command","agentUse":"read_first"},{"name":"command_policy.md","role":"command_policy","relativePath":"command_policy.md","format":"markdown","readOrder":2,"readTrigger":"before_risky_remote_mutating_secret_or_environment_sensitive_commands","agentUse":"consult_before_risky_commands"},{"name":"environment_report.md","role":"environment_report","relativePath":"environment_report.md","format":"markdown","readOrder":3,"readTrigger":"only_for_diagnostics_or_audit","agentUse":"debug_audit_only"}]}\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "agent-context" ]]; then
              printf '# Agent Context\\n\\n## Use\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "command-policy" ]]; then
              printf '# Command Policy\\n\\n## Allowed\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "environment-report" ]]; then
              printf '# Environment Report\\n\\n## Diagnostics\\n'
              exit 0
            fi
            exit 2
            """
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/check_habitat_metadata.sh",
            binaryURL.path,
            projectURL.path,
        ]

        let stderr = Pipe()
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let error = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 1)
        #expect(error.contains("binary version 1.2.3 does not match generatorVersion 1.2.4"))
    }

    @Test
    func metadataCheckScriptRejectsMissingCoreArtifactMetadata() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let projectURL = tempURL.appendingPathComponent("project")
        let binaryURL = tempURL.appendingPathComponent("habitat-scan")
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            binaryURL,
            contents: """
            #!/usr/bin/env bash
            set -euo pipefail
            if [[ "$1" == "--version" ]]; then
              printf 'habitat-scan 1.2.3\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "scan-result" ]]; then
              printf '{"schemaVersion":"0.1","generatorVersion":"1.2.3","artifacts":[{"name":"scan_result.json"}]}\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "agent-context" ]]; then
              printf '# Agent Context\\n\\n## Use\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "command-policy" ]]; then
              printf '# Command Policy\\n\\n## Allowed\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "environment-report" ]]; then
              printf '# Environment Report\\n\\n## Diagnostics\\n'
              exit 0
            fi
            exit 2
            """
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/check_habitat_metadata.sh",
            binaryURL.path,
            projectURL.path,
        ]

        let stderr = Pipe()
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let error = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 3)
        #expect(error.contains("missing agent_context.md, command_policy.md, environment_report.md"))
    }

    @Test
    func metadataCheckScriptRejectsIncompleteCoreArtifactMetadata() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let projectURL = tempURL.appendingPathComponent("project")
        let binaryURL = tempURL.appendingPathComponent("habitat-scan")
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            binaryURL,
            contents: """
            #!/usr/bin/env bash
            set -euo pipefail
            if [[ "$1" == "--version" ]]; then
              printf 'habitat-scan 1.2.3\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "scan-result" ]]; then
              printf '{"schemaVersion":"0.1","generatorVersion":"1.2.3","artifacts":[{"name":"agent_context.md","role":"agent_context","relativePath":"agent_context.md","format":"markdown","readOrder":2,"readTrigger":"before_any_project_command","agentUse":"read_first"},{"name":"command_policy.md","role":"command_policy","relativePath":"command_policy.md","format":"markdown","readOrder":2,"readTrigger":"before_any_project_command","agentUse":"consult_before_risky_commands"},{"name":"environment_report.md","role":"environment_report","relativePath":"environment_report.md","format":"markdown","readOrder":3,"readTrigger":"only_for_diagnostics_or_audit","agentUse":"debug_audit_only"}]}\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "agent-context" ]]; then
              printf '# Agent Context\\n\\n## Use\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "command-policy" ]]; then
              printf '# Command Policy\\n\\n## Allowed\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "environment-report" ]]; then
              printf '# Environment Report\\n\\n## Diagnostics\\n'
              exit 0
            fi
            exit 2
            """
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/check_habitat_metadata.sh",
            binaryURL.path,
            projectURL.path,
        ]

        let stderr = Pipe()
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let error = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 3)
        #expect(error.contains("agent_context.md.readOrder expected 1 but found 2"))
        #expect(error.contains("command_policy.md.readTrigger expected 'before_risky_remote_mutating_secret_or_environment_sensitive_commands' but found 'before_any_project_command'"))
    }

    @Test
    func metadataCheckScriptRejectsMissingStdoutMarkdownArtifact() throws {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let projectURL = tempURL.appendingPathComponent("project")
        let binaryURL = tempURL.appendingPathComponent("habitat-scan")
        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        try writeExecutableScript(
            binaryURL,
            contents: """
            #!/usr/bin/env bash
            set -euo pipefail
            if [[ "$1" == "--version" ]]; then
              printf 'habitat-scan 1.2.3\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "scan-result" ]]; then
              printf '{"schemaVersion":"0.1","generatorVersion":"1.2.3","artifacts":[{"name":"agent_context.md","role":"agent_context","relativePath":"agent_context.md","format":"markdown","readOrder":1,"readTrigger":"before_any_project_command","agentUse":"read_first"},{"name":"command_policy.md","role":"command_policy","relativePath":"command_policy.md","format":"markdown","readOrder":2,"readTrigger":"before_risky_remote_mutating_secret_or_environment_sensitive_commands","agentUse":"consult_before_risky_commands"},{"name":"environment_report.md","role":"environment_report","relativePath":"environment_report.md","format":"markdown","readOrder":3,"readTrigger":"only_for_diagnostics_or_audit","agentUse":"debug_audit_only"}]}\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "agent-context" ]]; then
              printf '# Agent Context\\n\\n## Use\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "command-policy" ]]; then
              printf '{"not":"markdown"}\\n'
              exit 0
            fi
            if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "environment-report" ]]; then
              printf '# Environment Report\\n\\n## Diagnostics\\n'
              exit 0
            fi
            exit 2
            """
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "scripts/check_habitat_metadata.sh",
            binaryURL.path,
            projectURL.path,
        ]

        let stderr = Pipe()
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()

        let error = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        #expect(process.terminationStatus == 4)
        #expect(error.contains("--stdout command-policy did not return command_policy.md"))
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

    @Test
    func scanRecordsObservedProjectFileModificationTimes() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift package",
            "README.md": "# Project",
            "docs/current_status.md": "# Current Status",
            "docs/development_automation.md": "# Development Automation",
            "docs/development_environment.md": "# Development Environment",
            "nenrin/index.md": "# Nenrin",
            "nenrin/metrics.md": "# Metrics",
            ".github/workflows/ci.yml": "name: CI",
        ])
        let readmeURL = projectURL.appendingPathComponent("docs/current_status.md")
        let newestDate = Date(timeIntervalSince1970: 1_800_000_000)
        try FileManager.default.setAttributes([.modificationDate: newestDate], ofItemAtPath: readmeURL.path)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let observedFiles = result.project.observedFiles

        #expect(observedFiles.map(\.path).contains("Package.swift"))
        #expect(observedFiles.map(\.path).contains("README.md"))
        #expect(observedFiles.map(\.path).contains("docs/current_status.md"))
        #expect(observedFiles.map(\.path).contains("docs/development_automation.md"))
        #expect(observedFiles.map(\.path).contains("docs/development_environment.md"))
        #expect(observedFiles.map(\.path).contains("nenrin/index.md"))
        #expect(observedFiles.map(\.path).contains("nenrin/metrics.md"))
        #expect(observedFiles.map(\.path).contains(".github/workflows/ci.yml"))
        #expect(observedFiles.allSatisfy { !$0.modifiedAt.isEmpty })
        #expect(observedFiles.allSatisfy { !$0.modifiedAt.contains(projectURL.path) })
        #expect(result.project.latestObservedFilePath == "docs/current_status.md")
        #expect(result.project.latestObservedFileModifiedAt == observedFiles.first { $0.path == "docs/current_status.md" }?.modifiedAt)
    }

    private func releaseVerificationFakeBinaryScript(version: String) -> String {
        """
        #!/usr/bin/env bash
        set -euo pipefail
        if [[ "$1" == "--version" ]]; then
          printf 'habitat-scan \(version)\\n'
          exit 0
        fi
        if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "scan-result" ]]; then
          printf '{"schemaVersion":"0.1","generatorVersion":"\(version)","artifacts":[{"name":"agent_context.md","role":"agent_context","relativePath":"agent_context.md","format":"markdown","readOrder":1,"readTrigger":"before_any_project_command","agentUse":"read_first"},{"name":"command_policy.md","role":"command_policy","relativePath":"command_policy.md","format":"markdown","readOrder":2,"readTrigger":"before_risky_remote_mutating_secret_or_environment_sensitive_commands","agentUse":"consult_before_risky_commands"},{"name":"environment_report.md","role":"environment_report","relativePath":"environment_report.md","format":"markdown","readOrder":3,"readTrigger":"only_for_diagnostics_or_audit","agentUse":"debug_audit_only"}]}\\n'
          exit 0
        fi
        if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "agent-context" ]]; then
          printf '# Agent Context\\n\\n## Use\\n'
          exit 0
        fi
        if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "command-policy" ]]; then
          printf '# Command Policy\\n\\n## Allowed\\n'
          exit 0
        fi
        if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "environment-report" ]]; then
          printf '# Environment Report\\n\\n## Diagnostics\\n'
          exit 0
        fi
        if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "scan_result.json" ]]; then
          printf '{"schemaVersion":"0.1","generatorVersion":"\(version)","artifacts":[{"name":"agent_context.md","role":"agent_context","relativePath":"agent_context.md","format":"markdown","readOrder":1,"readTrigger":"before_any_project_command","agentUse":"read_first"},{"name":"command_policy.md","role":"command_policy","relativePath":"command_policy.md","format":"markdown","readOrder":2,"readTrigger":"before_risky_remote_mutating_secret_or_environment_sensitive_commands","agentUse":"consult_before_risky_commands"},{"name":"environment_report.md","role":"environment_report","relativePath":"environment_report.md","format":"markdown","readOrder":3,"readTrigger":"only_for_diagnostics_or_audit","agentUse":"debug_audit_only"}]}\\n'
          exit 0
        fi
        if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "agent_context.md" ]]; then
          printf '# Agent Context\\n\\n## Use\\n'
          exit 0
        fi
        if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "command_policy.md" ]]; then
          printf '# Command Policy\\n\\n## Allowed\\n'
          exit 0
        fi
        if [[ "$1" == "scan" && "$4" == "--stdout" && "$5" == "environment_report.md" ]]; then
          printf '# Environment Report\\n\\n## Diagnostics\\n'
          exit 0
        fi
        exit 2
        """
    }

    private func sha256(_ url: URL) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shasum")
        process.arguments = ["-a", "256", url.path]
        let stdout = Pipe()
        process.standardOutput = stdout
        try process.run()
        process.waitUntilExit()
        let output = String(decoding: stdout.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        return String(output.split(separator: " ").first ?? "")
    }
}
