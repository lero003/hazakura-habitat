import Testing
import Foundation
@testable import HabitatCore

struct CoreInfrastructureTests {
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
            "before_risky_remote_mutating_secret_or_environment_sensitive_commands",
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
    func reportWriterRendersStdoutArtifactsFromSameGeneratedReport() throws {
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
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
                askFirstCommands: ["swift package update"],
                forbiddenCommands: ["sudo"]
            ),
            warnings: [],
            diagnostics: []
        )

        let report = ReportWriter().render(scanResult: result)

        #expect(try report.text(for: .agentContext) == report.agentContext)
        #expect(try report.text(for: .commandPolicy) == report.commandPolicy)
        #expect(try report.text(for: .environmentReport) == report.environmentReport)
        #expect(try report.text(for: .scanResult) == String(
            decoding: ReportWriter.jsonData(scanResult: report.scanResult),
            as: UTF8.self
        ))
        #expect(try report.text(for: .scanResult).contains("\"generatorVersion\" : \"\(HabitatMetadata.generatorVersion)\""))
        #expect(report.agentContext.hasPrefix("# Agent Context\n"))
        #expect(report.commandPolicy.hasPrefix("# Command Policy\n"))
        #expect(report.environmentReport.hasPrefix("# Environment Report\n"))
        #expect(report.scanResult.artifacts.map(\.name) == [
            "agent_context.md",
            "command_policy.md",
            "environment_report.md",
        ])
        #expect(report.scanResult.policy.reviewFirstCommandReasons == [
            .init(
                command: "swift package update",
                classification: "ask_first",
                reasonCode: "dependency_resolution_mutation",
                reason: "Dependency resolution or lockfile changes can change project state."
            )
        ])
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
        #expect(policy.contains("`Allowed` - 2 safe starting points."))
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
    func projectInfoDecodesOlderJsonWithoutObservedFiles() throws {
        let data = """
        {
          "detectedFiles": ["Package.swift"],
          "symlinkedFiles": [],
          "packageManager": "swiftpm",
          "packageScripts": [],
          "runtimeHints": {}
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(ProjectInfo.self, from: data)

        #expect(decoded.detectedFiles == ["Package.swift"])
        #expect(decoded.observedFiles.isEmpty)
        #expect(decoded.packageManager == "swiftpm")
    }

    @Test
    func validationCommandClaimsDecodeOlderJsonWithoutPurpose() throws {
        let data = """
        {
          "detectedFiles": ["Package.swift"],
          "symlinkedFiles": [],
          "packageManager": "swiftpm",
          "packageScripts": [],
          "validationCommandClaims": [
            { "source": "README.md", "command": "swift test" }
          ],
          "runtimeHints": {}
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(ProjectInfo.self, from: data)

        #expect(decoded.validationCommandClaims == [
            ValidationCommandClaim(source: "README.md", command: "swift test")
        ])
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
        - Freshness: regenerate if key project files changed after this timestamp; `scan_result.json` includes observed file mtimes.
        - Latest observed file: pnpm-lock.yaml modified at 2026-04-25T00:00:00Z.
        - Read order: this file first; `command_policy.md` before risky commands; `environment_report.md` only for diagnostics.
        - Scope: short working context; full approval detail is in `command_policy.md`.
        - Warning: Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node).
        - Warning: Project files prefer pnpm, but pnpm was not found on PATH; ask before running pnpm commands or substituting another package manager.
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
        - `Allowed` - 1 safe starting point.
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

    @Test
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

}
