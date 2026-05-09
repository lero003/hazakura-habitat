import Testing
import Foundation
@testable import HabitatCore

struct AgentContextOutputContractTests {
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
        #expect(context.contains("2 additional Ask First commands or command families in `command_policy.md` (other reason codes: `dependency_mutation`)."))
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
        #expect(!context.contains("additional Ask First commands or command families in `command_policy.md`"))
        #expect(!context.contains("Ask before `git add`."))
    }

    @Test
    func hiddenGitMutationSummaryKeepsConcreteReviewFirstEntriesInCommandPolicy() throws {
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
                preferredCommands: ["swift test", "swift build"],
                askFirstCommands: [
                    "swift package update",
                    "swift package resolve",
                    "modifying lockfiles",
                    "modifying version manager files",
                    "git clean",
                    "git reset --hard",
                    "git push",
                ],
                forbiddenCommands: ["sudo"]
            ),
            warnings: [],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before Git/GitHub workspace, history, branch, or remote mutations; see `command_policy.md`."))
        #expect(!context.contains("Ask before `git clean`."))
        #expect(!context.contains("Ask before `git reset --hard`."))
        #expect(policy.contains("- `git clean` (`git_mutation`) - Git mutation can change workspace, history, branches, or remotes."))
        #expect(policy.contains("- `git reset --hard` (`git_mutation`) - Git mutation can change workspace, history, branches, or remotes."))
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
        #expect(context.contains("3 additional Ask First commands or command families in `command_policy.md` (other reason codes: `dependency_mutation`, `ephemeral_package_execution`, `user_approval_required`)."))
        #expect(!context.contains("additional Ask First commands or command families in `command_policy.md` (reason codes: `git_mutation`"))
    }

    @Test
    func agentContextOverflowReasonCodesStayBoundedWhenManyFamiliesAreHidden() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let askFirstCommands = [
            "shown-1",
            "shown-2",
            "shown-3",
            "shown-4",
            "hidden-package-manager-activation",
            "hidden-dependency-mutation",
            "hidden-package-registry-mutation",
            "hidden-ephemeral-package-execution",
            "hidden-user-approval-required",
        ]
        let reasonCodes: [PolicyReasonCode] = [
            .init(code: "visible_reason", text: "Visible commands use structured metadata."),
            .init(code: "package_manager_activation", text: "Package-manager activation can change shims, fetch package-manager versions, or mutate project metadata."),
            .init(code: "dependency_mutation", text: "Dependency install, update, or removal can mutate project state."),
            .init(code: "package_registry_mutation", text: "Package registry publication or metadata changes affect external package state."),
            .init(code: "ephemeral_package_execution", text: "Ephemeral package execution can fetch or run unpinned code outside the selected workflow."),
            .init(code: "user_approval_required", text: "Requires user approval before execution."),
        ]
        let commandReasons = askFirstCommands.prefix(4).map {
            PolicyCommandReason(
                command: $0,
                classification: PolicyCommandReason.askFirstClassification,
                reasonCode: "visible_reason",
                reason: "Visible commands use structured metadata."
            )
        } + zip(askFirstCommands.dropFirst(4), reasonCodes.dropFirst()).map {
            PolicyCommandReason(
                command: $0.0,
                classification: PolicyCommandReason.askFirstClassification,
                reasonCode: $0.1.code,
                reason: $0.1.text
            )
        }
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
                askFirstCommands: askFirstCommands,
                forbiddenCommands: ["sudo"],
                reasonCodes: reasonCodes,
                commandReasons: commandReasons + [
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
        #expect(context.contains("5 additional Ask First commands or command families in `command_policy.md` (reason codes: `package_manager_activation`, `dependency_mutation`, `package_registry_mutation`, more)."))
        #expect(!context.contains("ephemeral_package_execution"))
        #expect(!context.contains("user_approval_required"))
    }
}
