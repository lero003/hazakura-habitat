import Testing
import Foundation
@testable import HabitatCore

struct PolicyOutputContractTests {
    @Test
    func scanResultIncludesPolicyReasonCodes() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commandCounts = result.policy.commandCounts
        let reasonCodes = result.policy.reasonCodes.map { $0.code }
        let commandReasons = result.policy.commandReasons

        #expect(commandCounts.preferred == result.policy.preferredCommands.count)
        #expect(commandCounts.askFirst == result.policy.askFirstCommands.count)
        #expect(commandCounts.reviewFirst == result.policy.reviewFirstCommandReasons.count)
        #expect(commandCounts.forbidden == result.policy.forbiddenCommands.count)
        #expect(commandCounts.withReasons == result.policy.commandReasons.count)
        #expect(reasonCodes.contains("missing_tool"))
        #expect(reasonCodes.contains("dependency_resolution_mutation"))
        #expect(reasonCodes.contains("ephemeral_package_execution"))
        #expect(reasonCodes.contains("privileged_command"))
        #expect(reasonCodes.count == Set(reasonCodes).count)
        #expect(commandReasons.contains(PolicyCommandReason(
            command: "running SwiftPM commands before swift is available",
            classification: "ask_first",
            reasonCode: "missing_tool",
            reason: "Required project tool is missing on `PATH`."
        )))
        #expect(commandReasons.contains(PolicyCommandReason(
            command: "swift package update",
            classification: "ask_first",
            reasonCode: "dependency_resolution_mutation",
            reason: "Dependency resolution or lockfile changes can change project state."
        )))
        #expect(commandReasons.contains(PolicyCommandReason(
            command: "npx",
            classification: "ask_first",
            reasonCode: "ephemeral_package_execution",
            reason: "Ephemeral package execution can fetch or run unpinned code outside the selected workflow."
        )))
        #expect(commandReasons.contains(PolicyCommandReason(
            command: "sudo",
            classification: "forbidden",
            reasonCode: "privileged_command",
            reason: "Privileged commands can mutate the host outside the project."
        )))
    }

    @Test
    func policyFindingsBackCommandReasonMetadata() throws {
        let findings = PolicyReasonCatalog.findings(
            askFirstCommands: ["swift package update"],
            forbiddenCommands: ["sudo"]
        )

        #expect(findings == [
            PolicyFinding(
                command: "swift package update",
                classification: "ask_first",
                reasonCode: "dependency_resolution_mutation",
                reason: "Dependency resolution or lockfile changes can change project state."
            ),
            PolicyFinding(
                command: "sudo",
                classification: "forbidden",
                reasonCode: "privileged_command",
                reason: "Privileged commands can mutate the host outside the project."
            ),
        ])
        #expect(PolicyReasonCatalog.commandReasons(
            askFirstCommands: ["swift package update"],
            forbiddenCommands: ["sudo"]
        ) == findings.map { PolicyCommandReason(finding: $0) })
    }

    @Test
    func scanResultCommandReasonsMirrorPolicyCommandOrder() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
        ])
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let data = try Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        let decoded = try JSONDecoder().decode(ScanResult.self, from: data)
        let expectedReasons = result.policy.askFirstCommands.map(PolicyReasonCatalog.askFirstCommandReason)
            + result.policy.forbiddenCommands.map(PolicyReasonCatalog.forbiddenCommandReason)

        #expect(decoded.policy.commandReasons == expectedReasons)
        #expect(decoded.policy.commandCounts.withReasons == expectedReasons.count)
    }

    @Test
    func scanResultCommandReasonsStayOneToOneWithClassifiedCommands() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
            ".env": "",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let classifiedCommands = result.policy.askFirstCommands.map {
            PolicyCommandReason.askFirstClassification + "\u{0}" + $0
        } + result.policy.forbiddenCommands.map {
            PolicyCommandReason.forbiddenClassification + "\u{0}" + $0
        }
        let reasonCommands = result.policy.commandReasons.map {
            $0.classification + "\u{0}" + $0.command
        }

        #expect(Set(result.policy.askFirstCommands).isDisjoint(with: Set(result.policy.forbiddenCommands)))
        #expect(reasonCommands == classifiedCommands)
        #expect(Set(reasonCommands).count == reasonCommands.count)
    }

    @Test
    func scanResultReviewFirstReasonsStayWithinAskFirstCommandReasons() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
            "package.json": #"{"scripts":{"build":"swift build"}}"#,
            "pnpm-lock.yaml": "",
        ])
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let data = try Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        let decoded = try JSONDecoder().decode(ScanResult.self, from: data)
        let reviewFirstReasons = decoded.policy.reviewFirstCommandReasons
        let askFirstReasonKeys = Set(decoded.policy.commandReasons.filter {
            $0.classification == PolicyCommandReason.askFirstClassification
        }.map(policyCommandReasonKey))
        let reviewFirstReasonKeys = reviewFirstReasons.map(policyCommandReasonKey)

        #expect(!reviewFirstReasons.isEmpty)
        #expect(reviewFirstReasons.count <= 6)
        #expect(reviewFirstReasons.allSatisfy {
            $0.classification == PolicyCommandReason.askFirstClassification
        })
        #expect(reviewFirstReasons.allSatisfy {
            decoded.policy.askFirstCommands.contains($0.command)
        })
        #expect(reviewFirstReasonKeys.allSatisfy { askFirstReasonKeys.contains($0) })
        #expect(Set(reviewFirstReasonKeys).count == reviewFirstReasonKeys.count)
        #expect(decoded.policy.commandCounts.reviewFirst == reviewFirstReasons.count)
    }

    @Test
    func commandPolicyReviewFirstMatchesScanResultMetadata() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
            "package.json": #"{"scripts":{"build":"swift build"}}"#,
            "pnpm-lock.yaml": "",
        ])
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let data = try Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        let decoded = try JSONDecoder().decode(ScanResult.self, from: data)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        let reviewFirstLines = markdownBulletLines(in: "Review First", markdown: policy)

        #expect(!decoded.policy.reviewFirstCommandReasons.isEmpty)
        #expect(reviewFirstLines == decoded.policy.reviewFirstCommandReasons.map {
            "- `\($0.command)` (`\($0.reasonCode)`) - \($0.reason)"
        })
    }

    @Test
    func commandPolicyIndexCountsMatchGeneratedPolicyMetadata() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
            "package.json": #"{"scripts":{"build":"swift build"}}"#,
            "pnpm-lock.yaml": "",
            ".env": "",
        ])
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let data = try Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        let decoded = try JSONDecoder().decode(ScanResult.self, from: data)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        let indexCounts = Dictionary(
            uniqueKeysWithValues: markdownBulletLines(in: "Policy Index", markdown: policy).compactMap(policyIndexCount)
        )

        #expect(indexCounts.count == 6)
        #expect(indexCounts["Review First"] == decoded.policy.commandCounts.reviewFirst)
        #expect(indexCounts["Reason Codes"] == decoded.policy.reasonCodes.count)
        #expect(indexCounts["If Secret-Bearing Files Are Detected"] == SecretBearingEvidence(project: decoded.project).paths.count)
        #expect(indexCounts["Allowed"] == markdownBulletLines(in: "Allowed", markdown: policy).count)
        #expect(indexCounts["Ask First"] == decoded.policy.commandCounts.askFirst)
        #expect(indexCounts["Ask First"] == markdownBulletLines(in: "Ask First", markdown: policy).count)
        #expect(indexCounts["Forbidden"] == decoded.policy.commandCounts.forbidden)
        #expect(indexCounts["Forbidden"] == markdownBulletLines(in: "Forbidden", markdown: policy).count)
    }

    @Test
    func commandPolicyIndexOmitsAbsentConditionalSections() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            scannedAt: "2026-05-08T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(
                operatingSystemVersion: "macOS",
                architecture: "arm64",
                shell: "/bin/zsh",
                path: ["/usr/bin"]
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
            policy: .init(
                preferredCommands: ["read-only inspection"],
                askFirstCommands: [],
                forbiddenCommands: []
            ),
            warnings: [],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        let indexTitles = markdownBulletLines(in: "Policy Index", markdown: policy).compactMap(policyIndexTitle)

        #expect(indexTitles == ["Allowed", "Ask First", "Forbidden"])
        #expect(!policy.contains("## Review First"))
        #expect(!policy.contains("## Reason Codes"))
        #expect(!policy.contains("## If Secret-Bearing Files Are Detected"))
    }

    @Test
    func commandPolicyCommandReasonCodesMatchScanResultMetadata() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
            "package.json": #"{"scripts":{"build":"swift build"}}"#,
            "pnpm-lock.yaml": "",
            ".env": "",
        ])
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let data = try Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        let decoded = try JSONDecoder().decode(ScanResult.self, from: data)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        let renderedReasons = markdownBulletLines(in: "Ask First", markdown: policy).compactMap {
            policyCommandLineReason($0, classification: PolicyCommandReason.askFirstClassification)
        } + markdownBulletLines(in: "Forbidden", markdown: policy).compactMap {
            policyCommandLineReason($0, classification: PolicyCommandReason.forbiddenClassification)
        }
        let renderedReasonKeys = renderedReasons.map(policyCommandReasonKey)
        let metadataReasonKeys = decoded.policy.commandReasons.map {
            policyCommandReasonKey(PolicyCommandReason(
                command: $0.command,
                classification: $0.classification,
                reasonCode: $0.reasonCode,
                reason: ""
            ))
        }

        #expect(renderedReasons.count == decoded.policy.commandReasons.count)
        #expect(Set(renderedReasonKeys) == Set(metadataReasonKeys))
    }

    @Test
    func scanResultReasonLegendCoversAllCommandReasonCodes() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
            "package.json": #"{"scripts":{"build":"swift build"}}"#,
            "pnpm-lock.yaml": "",
            ".env": "",
        ])
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let data = try Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        let decoded = try JSONDecoder().decode(ScanResult.self, from: data)
        let legendCodes = Set(decoded.policy.reasonCodes.map(\.code))
        let commandReasonCodes = Set(decoded.policy.commandReasons.map(\.reasonCode))
        let reviewFirstReasonCodes = Set(decoded.policy.reviewFirstCommandReasons.map(\.reasonCode))

        #expect(!commandReasonCodes.isEmpty)
        #expect(commandReasonCodes.isSubset(of: legendCodes))
        #expect(reviewFirstReasonCodes.isSubset(of: legendCodes))
        #expect(Set(decoded.policy.reasonCodes.map(\.code)).count == decoded.policy.reasonCodes.count)
    }

    @Test
    func scanResultCommandReasonTextMatchesReasonLegend() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
            "package.json": #"{"scripts":{"build":"swift build"}}"#,
            "pnpm-lock.yaml": "",
            ".env": "",
        ])
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let data = try Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        let decoded = try JSONDecoder().decode(ScanResult.self, from: data)
        let reasonTextByCode = Dictionary(
            uniqueKeysWithValues: decoded.policy.reasonCodes.map { ($0.code, $0.text) }
        )
        let allReasons = decoded.policy.commandReasons + decoded.policy.reviewFirstCommandReasons

        #expect(!allReasons.isEmpty)
        #expect(allReasons.allSatisfy { reason in
            reasonTextByCode[reason.reasonCode] == reason.reason
        })
    }

    @Test
    func commandPolicyReasonLegendMatchesScanResultMetadata() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
            "package.json": #"{"scripts":{"build":"swift build"}}"#,
            "pnpm-lock.yaml": "",
            ".env": "",
        ])
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let data = try Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        let decoded = try JSONDecoder().decode(ScanResult.self, from: data)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        let reasonCodeLines = markdownBulletLines(in: "Reason Codes", markdown: policy)

        #expect(!decoded.policy.reasonCodes.isEmpty)
        #expect(reasonCodeLines == decoded.policy.reasonCodes.map {
            "- `\($0.code)` - \($0.text)"
        })
    }

    @Test
    func commandPolicyFullApprovalDetailStaysWithinPreviewBudget() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
            "package.json": #"{"scripts":{"build":"swift build"}}"#,
            "pnpm-lock.yaml": "",
            ".env": "",
        ])
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let data = try Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        let decoded = try JSONDecoder().decode(ScanResult.self, from: data)
        let commandPolicyArtifact = try #require(decoded.artifacts.first { $0.name == "command_policy.md" })

        #expect(commandPolicyArtifact.lineCount <= 950)
    }

    @Test
    func policyReasonLegendIncludesFallbackReasonCodes() throws {
        let fallbackReasons = PolicyReasonCatalog.legend(
            askFirstCommands: ["custom project mutation"],
            forbiddenCommands: ["custom unsafe command"]
        )
        let commandReasons = PolicyReasonCatalog.commandReasons(
            askFirstCommands: ["custom project mutation"],
            forbiddenCommands: ["custom unsafe command"]
        )

        #expect(fallbackReasons == [
            PolicyReasonCode(
                code: "user_approval_required",
                text: "Requires user approval before execution."
            ),
            PolicyReasonCode(
                code: "unsafe_or_sensitive_command",
                text: "Generated policy marks this command as unsafe or sensitive."
            ),
        ])
        #expect(commandReasons == [
            PolicyCommandReason(
                command: "custom project mutation",
                classification: PolicyCommandReason.askFirstClassification,
                reasonCode: "user_approval_required",
                reason: "Requires user approval before execution."
            ),
            PolicyCommandReason(
                command: "custom unsafe command",
                classification: PolicyCommandReason.forbiddenClassification,
                reasonCode: "unsafe_or_sensitive_command",
                reason: "Generated policy marks this command as unsafe or sensitive."
            ),
        ])
    }

    private func policyCommandReasonKey(_ reason: PolicyCommandReason) -> String {
        [
            reason.classification,
            reason.command,
            reason.reasonCode,
            reason.reason,
        ].joined(separator: "\u{0}")
    }

    private func markdownBulletLines(in section: String, markdown: String) -> [String] {
        let lines = markdown.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard let sectionIndex = lines.firstIndex(of: "## \(section)") else {
            return []
        }

        let followingLines = lines[(sectionIndex + 1)...]
        let nextSectionOffset = followingLines.firstIndex { $0.hasPrefix("## ") } ?? lines.endIndex
        return followingLines[..<nextSectionOffset].filter { $0.hasPrefix("- ") }
    }

    private func policyIndexCount(_ line: String) -> (String, Int)? {
        let parts = line.split(separator: "`", maxSplits: 2).map(String.init)
        guard parts.count == 3 else {
            return nil
        }

        let countText = parts[2]
            .trimmingCharacters(in: .whitespaces)
            .dropFirst(2)
            .split(separator: " ")
            .first
        guard let countText, let count = Int(countText) else {
            return nil
        }

        return (parts[1], count)
    }

    private func policyIndexTitle(_ line: String) -> String? {
        let parts = line.split(separator: "`", maxSplits: 2).map(String.init)
        guard parts.count == 3 else {
            return nil
        }

        return parts[1]
    }

    private func policyCommandLineReason(_ line: String, classification: String) -> PolicyCommandReason? {
        let parts = line.split(separator: "`", maxSplits: 4).map(String.init)
        guard parts.count >= 4 else {
            return nil
        }

        let command = parts[1]
        if !line.hasPrefix("- `\(command)` (`") {
            return nil
        }

        let reasonCode = parts[3]
        return PolicyCommandReason(
            command: command,
            classification: classification,
            reasonCode: reasonCode,
            reason: ""
        )
    }

    @Test
    func policySummaryDecodesOlderJsonWithoutCommandCounts() throws {
        let json = """
        {
          "preferredCommands": ["swift test"],
          "askFirstCommands": ["swift package update"],
          "forbiddenCommands": ["sudo"],
          "reasonCodes": [],
          "commandReasons": [
            {
              "command": "swift package update",
              "classification": "ask_first",
              "reasonCode": "dependency_resolution_mutation",
              "reason": "Dependency resolution or lockfile changes can change project state."
            }
          ]
        }
        """

        let policy = try JSONDecoder().decode(PolicySummary.self, from: Data(json.utf8))

        #expect(policy.commandCounts == PolicyCommandCounts(
            preferred: 1,
            askFirst: 1,
            reviewFirst: 0,
            forbidden: 1,
            withReasons: 1
        ))
    }

    @Test
    func policyReasonLegendUsesStableCatalogOrder() throws {
        let firstOrder = PolicyReasonCatalog.legend(
            askFirstCommands: [
                "pnpm install",
                "corepack enable",
                "swift package update",
                "running pnpm commands before pnpm is available",
                "npx",
            ],
            forbiddenCommands: [
                "brew upgrade",
                "env",
                "sudo",
            ]
        ).map(\.code)

        let reversedOrder = PolicyReasonCatalog.legend(
            askFirstCommands: [
                "running pnpm commands before pnpm is available",
                "swift package update",
                "corepack enable",
                "pnpm install",
                "npx",
            ],
            forbiddenCommands: [
                "sudo",
                "env",
                "brew upgrade",
            ]
        ).map(\.code)

        let expectedOrder = [
            "missing_tool",
            "package_manager_activation",
            "dependency_resolution_mutation",
            "dependency_mutation",
            "ephemeral_package_execution",
            "privileged_command",
            "host_private_data",
            "global_environment_mutation",
        ]

        #expect(firstOrder == expectedOrder)
        #expect(reversedOrder == expectedOrder)
    }
}
