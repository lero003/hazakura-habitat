import Testing
import Foundation
@testable import HabitatCore

struct CoreInfrastructureTests {
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
    func representativeAgentContextExamplesKeepFixedContract() throws {
        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let examplePaths = [
            "examples/swift-package/agent_context.md",
            "examples/node-pnpm-conflict/agent_context.md",
            "examples/python-uv-missing-tool/agent_context.md",
            "examples/cargo-version-check-failure/agent_context.md",
            "examples/secret-bearing-files/agent_context.md",
        ]

        for path in examplePaths {
            let context = try String(contentsOf: rootURL.appendingPathComponent(path), encoding: .utf8)

            assertAgentContextContract(context)
            #expect(!context.contains("## Freshness"), "Representative examples should keep freshness in Notes: \(path)")
            #expect(!context.contains("## Avoid"), "Representative examples should use Do Not for current output shape: \(path)")
            #expect(!context.contains("## Mismatches"), "Representative examples should keep mismatch details in Notes: \(path)")
            #expect(
                context.contains("- Read order: this file first; `command_policy.md` before risky commands; `environment_report.md` only for diagnostics."),
                "Representative examples should tell agents where to stop or continue reading: \(path)"
            )
            #expect(
                context.contains("- Scope: short working context; full approval detail is in `command_policy.md`."),
                "Representative examples should keep full policy detail out of agent_context.md: \(path)"
            )
        }
    }

    @Test
    func packageManagerMutationReviewCommandsStayCentralizedForPolicyConsumers() throws {
        #expect(PolicyReasonCatalog.swiftPackageDependencyResolutionCommands == [
            "swift package update",
            "swift package resolve",
        ])
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "swiftpm") == PolicyReasonCatalog.swiftPackageDependencyResolutionCommands)
        for command in PolicyReasonCatalog.swiftPackageDependencyResolutionCommands {
            #expect(PolicyReasonCatalog.askFirstReason(for: command).code == "dependency_resolution_mutation")
        }
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "npm") == PolicyReasonCatalog.npmDependencyMutationCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "pnpm") == PolicyReasonCatalog.pnpmDependencyMutationCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "yarn") == PolicyReasonCatalog.yarnDependencyMutationCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "bun") == PolicyReasonCatalog.bunDependencyMutationCommands)
        for command in PolicyReasonCatalog.npmDependencyMutationCommands
            + PolicyReasonCatalog.pnpmDependencyMutationCommands
            + PolicyReasonCatalog.yarnDependencyMutationCommands
            + PolicyReasonCatalog.bunDependencyMutationCommands {
            #expect(PolicyReasonCatalog.askFirstReason(for: command).code == "dependency_mutation")
        }
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "homebrew") == [
            "brew bundle",
            "brew bundle install",
            "brew bundle cleanup",
            "brew bundle dump",
            "brew update",
            "brew cleanup",
            "brew autoremove",
            "brew tap",
            "brew tap-new",
        ])
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "unknown") == [])
    }

    @Test
    func pythonUvMissingToolExampleMatchesCurrentGuidanceShape() throws {
        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let context = try String(
            contentsOf: rootURL.appendingPathComponent("examples/python-uv-missing-tool/agent_context.md"),
            encoding: .utf8
        )

        #expect(context.contains("- Verify `uv` before running uv commands."))
        #expect(context.contains("- Prefer read-only inspection before mutation."))
        #expect(context.contains("- Ask before `running uv commands before uv is available`."))
        #expect(context.contains("- Ask before `uv sync`."))
        #expect(context.contains("other reason codes: `dependency_resolution_mutation`, `version_manager_mutation`, `dependency_mutation`, more"))
        #expect(context.contains("Project files prefer uv, but uv was not found on PATH; ask before running uv commands or substituting another package manager."))
        #expect(!context.contains("Do not auto-install uv."))
        #expect(!context.contains("Ask before using `pip install`, `pip sync`, or `python -m pip install` as a fallback."))
    }

    @Test
    func secretBearingCommandPolicyExampleKeepsSearchGuidanceNearTop() throws {
        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let policy = try String(
            contentsOf: rootURL.appendingPathComponent("examples/secret-bearing-files/command_policy.md"),
            encoding: .utf8
        )
        let headings = policy
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .filter { $0.hasPrefix("#") }

        #expect(headings == [
            "# Command Policy",
            "## Policy Index",
            "## Review First",
            "## Reason Codes",
            "## If Secret-Bearing Files Are Detected",
            "## Allowed",
            "## Ask First",
            "## Forbidden",
            "## If Dependency Installation Seems Necessary"
        ])
        #expect(policy.contains("`If Secret-Bearing Files Are Detected` - 3 detected paths requiring exclusions before broad search or export."))
        #expect(policy.contains("`recursive project search without excluding secret-bearing files` (`secret_or_credential_access`) - Command can read, expose, copy, or load secrets or credentials."))
        #expect(policy.contains("Named source or test files that are not detected secret-bearing paths can be inspected directly."))
        #expect(policy.contains("For necessary broad search, start with exclusion-aware `rg`: `rg <pattern> --glob '!.env' --glob '!.env.*' --glob '!.npmrc' --glob '!id_ed25519'`."))
        #expect(policy.contains("For necessary Git-tracked search, use pathspec exclusions: `git grep <pattern> -- . ':(exclude).env' ':(exclude).env.*' ':(exclude).npmrc' ':(exclude)id_ed25519'`."))
        #expect(policy.contains("Apply equivalent exclusions before broad `grep -R`, `git grep`, copy, sync, or archive commands."))
        #expect(policy.contains("Prefer targeted source/test inspection over broad `rg`, `grep -R`, `git grep`, `rsync`, `tar`, `zip`, or `git archive` commands."))
        #expect(policy.contains("`targeted read-only source/test inspection that avoids detected secret-bearing paths`"))
        #expect(!policy.contains("`read-only project inspection, including rg <pattern>`"))
    }

    @Test
    func cargoVersionCheckFailureExampleMatchesCurrentGuidanceShape() throws {
        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let context = try String(
            contentsOf: rootURL.appendingPathComponent("examples/cargo-version-check-failure/agent_context.md"),
            encoding: .utf8
        )

        #expect(context.contains("- Verify `cargo` before running Cargo commands."))
        #expect(context.contains("- Prefer read-only inspection before mutation."))
        #expect(context.contains("- Ask before `running Cargo commands before cargo version check succeeds`."))
        #expect(context.contains("- Ask before `cargo add`."))
        #expect(context.contains("- Ask before `cargo update`."))
        #expect(context.contains("- Ask before `cargo remove`."))
        #expect(context.contains("other reason codes: `dependency_resolution_mutation`, `version_manager_mutation`, `dependency_mutation`, more"))
        #expect(context.contains("cargo --version failed with exit code 1: cargo: rustup toolchain is not installed"))
        #expect(!context.contains("Use `cargo` because project files point to it."))
        #expect(!context.contains("Prefer `cargo test`."))
        #expect(!context.contains("Do not auto-install Rust."))
    }

    @Test
    func swiftPackageExampleArtifactMetadataMatchesFiles() throws {
        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let exampleDirectories = [
            "examples/swift-package",
        ]

        for directory in exampleDirectories {
            let directoryURL = rootURL.appendingPathComponent(directory)
            let scanResultURL = directoryURL.appendingPathComponent("scan_result.json")
            let data = try Data(contentsOf: scanResultURL)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let artifacts = json?["artifacts"] as? [[String: Any]] ?? []
            let policy = json?["policy"] as? [String: Any] ?? [:]
            let commandCounts = policy["commandCounts"] as? [String: Any] ?? [:]
            let preferredCommands = policy["preferredCommands"] as? [String] ?? []
            let askFirstCommands = policy["askFirstCommands"] as? [String] ?? []
            let forbiddenCommands = policy["forbiddenCommands"] as? [String] ?? []
            let commandReasons = policy["commandReasons"] as? [[String: Any]] ?? []
            let expectedAgentUse = [
                "agent_context.md": "read_first",
                "command_policy.md": "consult_before_risky_commands",
                "environment_report.md": "debug_audit_only",
            ]
            let expectedReadTrigger = [
                "agent_context.md": "before_any_project_command",
                "command_policy.md": "before_risky_mutating_secret_or_environment_sensitive_commands",
                "environment_report.md": "only_for_diagnostics_or_audit",
            ]
            let expectedEntrySection = [
                "agent_context.md": "Use",
                "command_policy.md": "Review First",
                "environment_report.md": "Diagnostics",
            ]
            let expectedSections = [
                "agent_context.md": ["Agent Context", "Use", "Prefer", "Ask First", "Do Not", "Notes"],
                "command_policy.md": ["Command Policy", "Policy Index", "Review First", "Reason Codes", "Allowed", "Ask First", "Forbidden", "If Dependency Installation Seems Necessary"],
                "environment_report.md": ["Environment Report", "System", "Project Signals", "Symlinked Project Signals", "Resolved Tools", "Tool Versions", "Changes Since Previous Scan", "Warnings", "Diagnostics", "Privacy Note"],
            ]

            #expect(!artifacts.isEmpty, "Expected example artifact metadata in \(directory)")
            #expect(commandCounts["preferred"] as? Int == preferredCommands.count)
            #expect(commandCounts["askFirst"] as? Int == askFirstCommands.count)
            #expect(commandCounts["reviewFirst"] as? Int == (policy["reviewFirstCommandReasons"] as? [[String: Any]] ?? []).count)
            #expect(commandCounts["forbidden"] as? Int == forbiddenCommands.count)
            #expect(commandCounts["withReasons"] as? Int == commandReasons.count)

            for artifact in artifacts {
                guard let name = artifact["name"] as? String,
                      let expectedLineCount = artifact["lineCount"] as? Int,
                      let expectedCharacterCount = artifact["characterCount"] as? Int else {
                    Issue.record("Malformed artifact metadata in \(directory)")
                    continue
                }

                let artifactURL = directoryURL.appendingPathComponent(name)
                let artifactText = try String(contentsOf: artifactURL, encoding: .utf8)
                #expect(
                    artifact["relativePath"] as? String == name,
                    "Expected \(directory)/\(name) relativePath metadata to point to the report-local artifact file"
                )
                #expect(
                    artifact["agentUse"] as? String == expectedAgentUse[name],
                    "Expected \(directory)/\(name) agentUse metadata to match its AI reading role"
                )
                #expect(
                    artifact["readTrigger"] as? String == expectedReadTrigger[name],
                    "Expected \(directory)/\(name) readTrigger metadata to explain when an agent should read it"
                )
                #expect(
                    artifact["entrySection"] as? String == expectedEntrySection[name],
                    "Expected \(directory)/\(name) entrySection metadata to point at the first useful section"
                )
                #expect(
                    (artifact["sections"] as? [String])?.contains(artifact["entrySection"] as? String ?? "") == true,
                    "Expected \(directory)/\(name) entrySection metadata to point at an existing Markdown heading"
                )
                #expect(
                    artifact["entryLine"] as? Int == headingLine(artifact["entrySection"] as? String ?? "", in: artifactText),
                    "Expected \(directory)/\(name) entryLine metadata to point at the entry heading"
                )
                #expect(
                    artifact["sections"] as? [String] == expectedSections[name],
                    "Expected \(directory)/\(name) sections metadata to match generated Markdown headings"
                )
                let sectionLines = artifact["sectionLines"] as? [[String: Any]]
                #expect(
                    sectionLines?.compactMap { $0["title"] as? String } == expectedSections[name],
                    "Expected \(directory)/\(name) sectionLines metadata to preserve Markdown heading order"
                )
                #expect(
                    sectionLines?.compactMap { $0["line"] as? Int } == expectedSections[name]?.compactMap { headingLine($0, in: artifactText) },
                    "Expected \(directory)/\(name) sectionLines metadata to point at each Markdown heading"
                )
                #expect(
                    lineCount(artifactText) == expectedLineCount,
                    "Expected \(directory)/\(name) lineCount metadata to match the example file"
                )
                #expect(
                    artifactText.count == expectedCharacterCount,
                    "Expected \(directory)/\(name) characterCount metadata to match the example file"
                )

                if name == "agent_context.md" {
                    #expect(artifact["lineLimit"] as? Int == 120)
                    #expect(artifact["withinLineLimit"] as? Bool == true)
                    #expect(expectedLineCount <= 120)
                } else {
                    #expect(artifact["lineLimit"] == nil)
                    #expect(artifact["withinLineLimit"] == nil)
                }
            }
        }
    }

    @Test
    func reportWriterCreatesAllArtifacts() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["swift test"], askFirstCommands: ["pnpm install"], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            #expect(FileManager.default.fileExists(atPath: outputURL.appendingPathComponent(name).path))
        }

        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        #expect(scanResult.contains("\"schemaVersion\" : \"0.1\""))
        #expect(scanResult.contains("\"generatorVersion\" : \"\(HabitatMetadata.generatorVersion)\""))

        let decoded = try JSONDecoder().decode(
            ScanResult.self,
            from: Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        )
        #expect(decoded.artifacts.map(\.name) == [
            "agent_context.md",
            "command_policy.md",
            "environment_report.md"
        ])
        #expect(decoded.artifacts.map(\.relativePath) == [
            "agent_context.md",
            "command_policy.md",
            "environment_report.md"
        ])
        #expect(decoded.artifacts.map(\.role) == [
            "agent_context",
            "command_policy",
            "environment_report"
        ])
        #expect(decoded.artifacts.map(\.agentUse) == [
            "read_first",
            "consult_before_risky_commands",
            "debug_audit_only"
        ])
        #expect(decoded.artifacts.map(\.readTrigger) == [
            "before_any_project_command",
            "before_risky_mutating_secret_or_environment_sensitive_commands",
            "only_for_diagnostics_or_audit"
        ])
        #expect(decoded.artifacts.map(\.readOrder) == [1, 2, 3])
        #expect(decoded.artifacts.map(\.entryLine) == [3, 12, 26])
        #expect(decoded.artifacts.allSatisfy { $0.format == "markdown" })
        #expect(decoded.artifacts.map(\.sections) == [
            ["Agent Context", "Use", "Prefer", "Ask First", "Do Not", "Notes"],
            ["Command Policy", "Policy Index", "Review First", "Reason Codes", "Allowed", "Ask First", "Forbidden", "If Dependency Installation Seems Necessary"],
            ["Environment Report", "System", "Project Signals", "Symlinked Project Signals", "Resolved Tools", "Tool Versions", "Changes Since Previous Scan", "Warnings", "Diagnostics", "Privacy Note"]
        ])
        #expect(decoded.artifacts.map { $0.sectionLines?.map(\.title) } == [
            ["Agent Context", "Use", "Prefer", "Ask First", "Do Not", "Notes"],
            ["Command Policy", "Policy Index", "Review First", "Reason Codes", "Allowed", "Ask First", "Forbidden", "If Dependency Installation Seems Necessary"],
            ["Environment Report", "System", "Project Signals", "Symlinked Project Signals", "Resolved Tools", "Tool Versions", "Changes Since Previous Scan", "Warnings", "Diagnostics", "Privacy Note"]
        ])
        #expect(decoded.artifacts[1].sectionLines?.first { $0.title == "Review First" }?.line == decoded.artifacts[1].entryLine)
        #expect(decoded.artifacts[1].sectionLines?.first { $0.title == "Ask First" }?.line != nil)
        #expect(decoded.artifacts[1].sectionLines?.first { $0.title == "Forbidden" }?.line != nil)
        #expect(decoded.artifacts.map(\.lineLimit) == [120, nil, nil])
        #expect(decoded.artifacts.map(\.withinLineLimit) == [true, nil, nil])
        #expect(decoded.policy.reviewFirstCommandReasons == [
            .init(
                command: "pnpm install",
                classification: "ask_first",
                reasonCode: "dependency_mutation",
                reason: "Dependency install, update, or removal can mutate project state."
            )
        ])
        #expect(decoded.policy.commandCounts.reviewFirst == decoded.policy.reviewFirstCommandReasons.count)
        let agentContextText = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        #expect(decoded.artifacts.first?.lineCount == lineCount(agentContextText))
        #expect(decoded.artifacts.first?.characterCount == agentContextText.count)
        #expect((decoded.artifacts.first?.lineCount ?? 0) <= (decoded.artifacts.first?.lineLimit ?? 0))
        #expect(decoded.artifacts.first?.withinLineLimit == true)
    }

    @Test
    func commandPolicyMarkdownUsesStructuredReasonMetadata() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(
                operatingSystemVersion: "macOS",
                architecture: "arm64",
                shell: "/bin/zsh",
                path: ["/usr/bin"]
            ),
            commands: [],
            project: .init(
                detectedFiles: ["Package.swift"],
                packageManager: "swiftpm",
                packageManagerVersion: nil,
                packageScripts: [],
                runtimeHints: .init(node: nil, python: nil)
            ),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(
                preferredCommands: ["swift test"],
                askFirstCommands: ["pnpm install"],
                forbiddenCommands: ["sudo"],
                reasonCodes: [
                    .init(code: "structured_ask_first", text: "Ask-first reason supplied by scan metadata."),
                    .init(code: "structured_forbidden", text: "Forbidden reason supplied by scan metadata."),
                ],
                commandReasons: [
                    .init(
                        command: "pnpm install",
                        classification: PolicyCommandReason.askFirstClassification,
                        reasonCode: "structured_ask_first",
                        reason: "Ask-first reason supplied by scan metadata."
                    ),
                    .init(
                        command: "sudo",
                        classification: PolicyCommandReason.forbiddenClassification,
                        reasonCode: "structured_forbidden",
                        reason: "Forbidden reason supplied by scan metadata."
                    ),
                ]
            ),
            warnings: [],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        #expect(policy.contains("`structured_ask_first` - Ask-first reason supplied by scan metadata."))
        #expect(policy.contains("`structured_forbidden` - Forbidden reason supplied by scan metadata."))
        #expect(policy.contains("`pnpm install` (`structured_ask_first`)"))
        #expect(policy.contains("`sudo` (`structured_forbidden`)"))
    }

    @Test
    func agentContextOverflowUsesStructuredReasonMetadata() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let askFirstCommands = [
            "review generated output",
            "review snapshots",
            "review examples",
            "review docs",
            "structured hidden command",
            "another structured hidden command",
        ]
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(
                operatingSystemVersion: "macOS",
                architecture: "arm64",
                shell: "/bin/zsh",
                path: ["/usr/bin"]
            ),
            commands: [],
            project: .init(
                detectedFiles: ["Package.swift"],
                packageManager: "swiftpm",
                packageManagerVersion: nil,
                packageScripts: [],
                runtimeHints: .init(node: nil, python: nil)
            ),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(
                preferredCommands: ["swift test"],
                askFirstCommands: askFirstCommands,
                forbiddenCommands: ["sudo"],
                reasonCodes: [
                    .init(code: "visible_structured_reason", text: "Visible commands use structured metadata."),
                    .init(code: "hidden_structured_reason", text: "Hidden commands use structured metadata."),
                ],
                commandReasons: askFirstCommands.prefix(4).map {
                    .init(
                        command: $0,
                        classification: PolicyCommandReason.askFirstClassification,
                        reasonCode: "visible_structured_reason",
                        reason: "Visible commands use structured metadata."
                    )
                } + askFirstCommands.dropFirst(4).map {
                    .init(
                        command: $0,
                        classification: PolicyCommandReason.askFirstClassification,
                        reasonCode: "hidden_structured_reason",
                        reason: "Hidden commands use structured metadata."
                    )
                } + [
                    .init(
                        command: "sudo",
                        classification: PolicyCommandReason.forbiddenClassification,
                        reasonCode: "privileged_command",
                        reason: "Privileged commands can mutate the host outside the project."
                    )
                ]
            ),
            warnings: [],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        assertAgentContextContract(context)
        #expect(context.contains("2 additional Ask First commands or command families in `command_policy.md` (reason codes: `hidden_structured_reason`)."))
        #expect(!context.contains("2 additional Ask First commands or command families in `command_policy.md` (reason codes: `user_approval_required`)."))
    }

    @Test
    func artifactEntrySectionFallsBackWhenReviewFirstIsOmitted() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(
                operatingSystemVersion: "macOS",
                architecture: "arm64",
                shell: "/bin/zsh",
                path: []
            ),
            commands: [],
            project: .init(
                detectedFiles: [],
                packageManager: nil,
                packageManagerVersion: nil,
                packageScripts: [],
                runtimeHints: .init(node: nil, python: nil)
            ),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["read-only inspection"], askFirstCommands: [], forbiddenCommands: []),
            warnings: [],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let decoded = try JSONDecoder().decode(
            ScanResult.self,
            from: Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        )
        let commandPolicyArtifact = try #require(decoded.artifacts.first { $0.name == "command_policy.md" })
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(commandPolicyArtifact.sections?.contains("Review First") == false)
        #expect(commandPolicyArtifact.entrySection == "Policy Index")
        #expect(commandPolicyArtifact.entryLine == 5)
        #expect(commandPolicyArtifact.sections?.contains(commandPolicyArtifact.entrySection ?? "") == true)
        #expect(commandPolicyArtifact.sectionLines?.contains(.init(title: "Policy Index", line: 5)) == true)
        #expect(!policy.contains("`Review First` - 0 highest-priority approval rules"))
        #expect(!policy.contains("`Reason Codes` - 0 reason families"))
        #expect(policy.contains("`Allowed` - 2 concrete safe starting points."))
    }

    @Test
    func generatedArtifactDecodesOlderJsonWithoutReadOrderOrLineLimit() throws {
        let data = """
        {
          "name": "agent_context.md",
          "role": "agent_context",
          "format": "markdown",
          "lineCount": 35
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(GeneratedArtifact.self, from: data)

        #expect(decoded.name == "agent_context.md")
        #expect(decoded.relativePath == nil)
        #expect(decoded.agentUse == nil)
        #expect(decoded.readTrigger == nil)
        #expect(decoded.readOrder == nil)
        #expect(decoded.entryLine == nil)
        #expect(decoded.sections == nil)
        #expect(decoded.sectionLines == nil)
        #expect(decoded.lineCount == 35)
        #expect(decoded.characterCount == nil)
        #expect(decoded.lineLimit == nil)
        #expect(decoded.withinLineLimit == nil)
    }

    @Test
    func agentContextIncludesRuntimeMismatchWarnings() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: [".nvmrc", "pnpm-lock.yaml"], packageManager: "pnpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: "v20", python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["pnpm"], askFirstCommands: ["pnpm install"], forbiddenCommands: ["sudo"]),
            warnings: ["Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node)."],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Active Node is v25.9.0, but project requests v20; ask before dependency installs"))
    }

    @Test
    func commandPolicyIncludesRuntimeMismatchInstallGuard() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: [".nvmrc", "pnpm-lock.yaml"], packageManager: "pnpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: "v20", python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(
                preferredCommands: ["pnpm"],
                askFirstCommands: ["dependency installs before matching active Node to project version hints", "pnpm install"],
                forbiddenCommands: ["sudo"]
            ),
            warnings: ["Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node)."],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(policy.contains("`dependency installs before matching active Node to project version hints`"))
    }

    @Test
    func agentContextMarkdownSnapshotStaysActionable() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = markdownSnapshotScanResult()

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(context == """
        # Agent Context

        ## Use
        - Verify `pnpm` before running pnpm commands.

        ## Prefer
        - Prefer read-only inspection before mutation.

        ## Ask First
        - Ask before `running pnpm commands before pnpm is available`.
        - Ask before `dependency installs before matching active Node to project version hints`.
        - Ask before `pnpm install`.
        - Ask before `modifying lockfiles`.

        ## Do Not
        - Do not run `sudo`.
        - Do not run `brew upgrade`.

        ## Notes
        - Scanned at: 2026-04-25T00:00:00Z
        - Project: /tmp/project
        - Read order: this file first; `command_policy.md` before risky commands; `environment_report.md` only for diagnostics.
        - Scope: short working context; full approval detail is in `command_policy.md`.
        - Mismatch: Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node).
        - Mismatch: Project files prefer pnpm, but pnpm was not found on PATH; ask before running pnpm commands or substituting another package manager.
        - node --version unavailable: missing
        """)
    }

    @Test
    func commandPolicyMarkdownSnapshotKeepsInstallGuardsVisible() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = markdownSnapshotScanResult()

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        assertCommandPolicyContract(policy)
        #expect(policy == """
        # Command Policy

        This policy is advisory. Habitat does not block commands. `Forbidden` means this generated context tells the agent not to run the command.

        ## Policy Index
        - `Review First` - 4 highest-priority approval rules with reasons.
        - `Reason Codes` - 6 reason families used by this policy.
        - `Allowed` - 1 concrete safe starting point.
        - `Ask First` - 4 commands or command families requiring approval.
        - `Forbidden` - 2 commands or command families to avoid.

        ## Review First
        - `running pnpm commands before pnpm is available` (`missing_tool`) - Required project tool is missing on `PATH`.
        - `dependency installs before matching active Node to project version hints` (`runtime_version_mismatch`) - Active runtime differs from project version hints.
        - `pnpm install` (`dependency_mutation`) - Dependency install, update, or removal can mutate project state.
        - `modifying lockfiles` (`dependency_resolution_mutation`) - Dependency resolution or lockfile changes can change project state.

        ## Reason Codes
        - `missing_tool` - Required project tool is missing on `PATH`.
        - `runtime_version_mismatch` - Active runtime differs from project version hints.
        - `dependency_resolution_mutation` - Dependency resolution or lockfile changes can change project state.
        - `dependency_mutation` - Dependency install, update, or removal can mutate project state.
        - `privileged_command` - Privileged commands can mutate the host outside the project.
        - `global_environment_mutation` - Command can mutate global tools or host environment state.

        ## Allowed
        - `read-only project inspection, including rg <pattern>`

        ## Ask First
        - `running pnpm commands before pnpm is available` (`missing_tool`)
        - `dependency installs before matching active Node to project version hints` (`runtime_version_mismatch`)
        - `pnpm install` (`dependency_mutation`)
        - `modifying lockfiles` (`dependency_resolution_mutation`)

        ## Forbidden
        - `sudo` (`privileged_command`)
        - `brew upgrade` (`global_environment_mutation`)

        ## If Dependency Installation Seems Necessary
        - Re-check lockfiles and version hints first.
        - Prefer the project-specific package manager from `agent_context.md`.
        - Ask before any install, upgrade, uninstall, or global mutation.
        """)
    }

    @Test
    func agentContextPrioritizesProjectMutationGuardsOverBroadPackageManagerGuards() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(
                resolvedPaths: [.init(name: "swift", paths: ["/usr/bin/swift"])],
                versions: [.init(name: "swift", version: "Swift version 6.1", available: true)]
            ),
            policy: .init(
                preferredCommands: ["swift test", "swift build"],
                askFirstCommands: [
                    "swift package update",
                    "swift package resolve",
                    "brew install",
                    "brew update",
                    "git add",
                    "git commit",
                    "modifying lockfiles",
                    "modifying version manager files"
                ],
                forbiddenCommands: ["sudo"]
            ),
            warnings: [],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `swift package update`."))
        #expect(context.contains("Ask before `swift package resolve`."))
        #expect(context.contains("Ask before `modifying lockfiles`."))
        #expect(context.contains("Ask before `modifying version manager files`."))
        #expect(!context.contains("Ask before `brew install`."))
        #expect(context.contains("Ask before Git/GitHub workspace, history, branch, or remote mutations; see `command_policy.md`."))
        #expect(context.contains("4 additional Ask First commands or command families in `command_policy.md` (other reason codes: `dependency_mutation`)."))
        let swiftPackageUpdateIndex = try #require(policy.range(of: "`swift package update`")?.lowerBound)
        let modifyingLockfilesIndex = try #require(policy.range(of: "`modifying lockfiles`")?.lowerBound)
        let gitAddIndex = try #require(policy.range(of: "`git add`")?.lowerBound)
        let brewInstallIndex = try #require(policy.range(of: "`brew install`")?.lowerBound)
        #expect(swiftPackageUpdateIndex < brewInstallIndex)
        #expect(modifyingLockfilesIndex < brewInstallIndex)
        #expect(gitAddIndex < brewInstallIndex)
    }

    @Test
    func agentContextSummarizesHiddenGitMutationGuards() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(
                resolvedPaths: [.init(name: "swift", paths: ["/usr/bin/swift"])],
                versions: [.init(name: "swift", version: "Swift version 6.1", available: true)]
            ),
            policy: .init(
                preferredCommands: ["swift test", "swift build"],
                askFirstCommands: [
                    "swift package update",
                    "swift package resolve",
                    "modifying lockfiles",
                    "modifying version manager files",
                    "git add",
                    "git commit",
                    "git push",
                    "gh pr create"
                ],
                forbiddenCommands: ["sudo"]
            ),
            warnings: [],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Ask before `swift package update`."))
        #expect(context.contains("Ask before `modifying version manager files`."))
        #expect(context.contains("Ask before Git/GitHub workspace, history, branch, or remote mutations; see `command_policy.md`."))
        #expect(context.contains("4 additional Ask First commands or command families in `command_policy.md` (Git/GitHub guards summarized above)."))
        #expect(!context.contains("Ask before `git add`."))
    }

    func scanResultDecodesOlderJsonWithoutChanges() throws {
        let result = markdownSnapshotScanResult()
        let data = try JSONEncoder().encode(result)
        var object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        object.removeValue(forKey: "generatorVersion")
        object.removeValue(forKey: "changes")
        object.removeValue(forKey: "artifacts")
        var project = try #require(object["project"] as? [String: Any])
        project.removeValue(forKey: "symlinkedFiles")
        project.removeValue(forKey: "unsafePackageMetadataFields")
        object["project"] = project
        let olderData = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(ScanResult.self, from: olderData)

        #expect(decoded.generatorVersion == "unknown")
        #expect(decoded.changes.isEmpty)
        #expect(decoded.artifacts.isEmpty)
        #expect(decoded.project.symlinkedFiles.isEmpty)
        #expect(decoded.project.unsafePackageMetadataFields.isEmpty)
        #expect(decoded.project.packageManager == "pnpm")
    }

    @Test
    func generatedArtifactDecodesOlderJsonWithoutAgentUse() throws {
        let data = """
        {
          "name": "agent_context.md",
          "role": "agent_context",
          "format": "markdown",
          "readOrder": 1,
          "lineCount": 34,
          "lineLimit": 120,
          "withinLineLimit": true
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(GeneratedArtifact.self, from: data)

        #expect(decoded.agentUse == nil)
        #expect(decoded.readTrigger == nil)
        #expect(decoded.entrySection == nil)
        #expect(decoded.name == "agent_context.md")
        #expect(decoded.sectionLines == nil)
        #expect(decoded.characterCount == nil)
        #expect(decoded.withinLineLimit == true)
    }

    @Test
    func olderPolicySummaryWithoutReasonCodesDecodesAsEmpty() throws {
        let data = """
        {
          "preferredCommands": [],
          "askFirstCommands": ["npm install"],
          "forbiddenCommands": ["sudo"]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(PolicySummary.self, from: data)

        #expect(decoded.reasonCodes.isEmpty)
        #expect(decoded.commandReasons.isEmpty)
        #expect(decoded.reviewFirstCommandReasons.isEmpty)
        #expect(decoded.commandCounts.reviewFirst == 0)
    }

    @Test
    func previousScanLoaderAcceptsReportDirectoryOrScanResultFile() throws {
        let result = markdownSnapshotScanResult()
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let loader = PreviousScanLoader()
        let loadedFromDirectory = try loader.load(from: outputURL)
        let loadedFromFile = try loader.load(from: outputURL.appendingPathComponent("scan_result.json"))

        #expect(loader.scanResultURL(for: outputURL).lastPathComponent == "scan_result.json")
        #expect(loadedFromDirectory.project.packageManager == "pnpm")
        #expect(loadedFromFile.project.packageManager == "pnpm")
        #expect(loadedFromDirectory.scannedAt == loadedFromFile.scannedAt)
    }

    func agentContextOmitsUnrelatedCommandDiagnostics() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["swift test"], askFirstCommands: [], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: [
                "go version failed with exit code 127: env: go: No such file or directory",
                "swift --version failed with exit code 1: swift unavailable"
            ]
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let report = try String(contentsOf: outputURL.appendingPathComponent("environment_report.md"), encoding: .utf8)

        #expect(!context.contains("go version failed"))
        #expect(context.contains("swift --version failed with exit code 1"))
        #expect(report.contains("go version failed with exit code 127"))
    }

    @Test
    func agentContextCapsActionableBullets() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let warnings = (1...12).map { "Warning \($0)" }
        let askFirstCommands = (1...6).map { "ask-first-\($0)" }
        let changes = (1...8).map {
            ScanChange(
                category: "test",
                summary: "Change \($0).",
                impact: "Impact \($0)."
            )
        }
        let diagnostics = (1...6).map { "swift --version failed with exit code \($0): failure \($0)" }
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [.init(name: "swift", paths: ["/usr/bin/swift"])], versions: [.init(name: "swift", version: "Swift version 6.1", available: true)]),
            policy: .init(preferredCommands: ["swift test"], askFirstCommands: askFirstCommands, forbiddenCommands: ["sudo"]),
            warnings: warnings,
            diagnostics: diagnostics,
            changes: changes
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        let report = try String(contentsOf: outputURL.appendingPathComponent("environment_report.md"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(context.contains("Ask before `ask-first-4`."))
        #expect(!context.contains("Ask before `ask-first-5`."))
        #expect(context.contains("2 additional Ask First commands or command families in `command_policy.md` (reason codes: `user_approval_required`)."))
        #expect(policy.contains("`ask-first-6`"))
        #expect(context.contains("Warning 10"))
        #expect(!context.contains("Warning 11"))
        #expect(context.contains("2 additional warnings in `environment_report.md`."))
        #expect(context.contains("Change 6. Impact 6."))
        #expect(!context.contains("Change 7. Impact 7."))
        #expect(context.contains("2 additional scan changes in `environment_report.md`."))
        #expect(context.contains("swift --version failed with exit code 4: failure 4"))
        #expect(!context.contains("swift --version failed with exit code 5: failure 5"))
        #expect(context.contains("2 additional relevant command diagnostics in `environment_report.md`."))
        #expect(context.split(whereSeparator: \.isNewline).count <= 50)
        #expect(report.contains("Warning 12"))
        #expect(report.contains("swift --version failed with exit code 6: failure 6"))
    }

    @Test
    func agentContextOverflowReasonCodesAvoidRepeatingSummarizedGitGuards() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [.init(name: "swift", paths: ["/usr/bin/swift"])], versions: [.init(name: "swift", version: "Swift version 6.1", available: true)]),
            policy: .init(
                preferredCommands: ["swift test"],
                askFirstCommands: [
                    "swift package update",
                    "swift package resolve",
                    "modifying lockfiles",
                    "modifying version manager files",
                    "git clean",
                    "git reset --hard",
                    "npm install",
                    "brew cleanup",
                    "npx",
                ],
                forbiddenCommands: ["sudo"]
            ),
            warnings: [],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(context.contains("Ask before Git/GitHub workspace, history, branch, or remote mutations; see `command_policy.md`."))
        #expect(context.contains("5 additional Ask First commands or command families in `command_policy.md` (other reason codes: `dependency_mutation`, `ephemeral_package_execution`, `user_approval_required`)."))
        #expect(!context.contains("additional Ask First commands or command families in `command_policy.md` (reason codes: `git_mutation`"))
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
