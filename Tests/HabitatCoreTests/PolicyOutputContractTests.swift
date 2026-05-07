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
