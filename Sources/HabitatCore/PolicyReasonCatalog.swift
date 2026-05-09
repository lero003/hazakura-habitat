import Foundation

public struct PolicyReasonCode: Codable, Equatable, Sendable {
    public let code: String
    public let text: String

    public init(code: String, text: String) {
        self.code = code
        self.text = text
    }
}

enum PolicyReasonCatalog {
    struct CommandFamily: Sendable {
        let commands: [String]
        private let commandSet: Set<String>

        init(_ commands: [String]) {
            self.commands = commands
            self.commandSet = Set(commands)
        }

        func contains(_ command: String) -> Bool {
            commandSet.contains(command)
        }
    }

    private struct ReasonRule: Sendable {
        let reasonCode: ReasonCode
        let matches: @Sendable (String) -> Bool
    }

    private static let askFirstReasonRules: [ReasonRule] = [
        .init(reasonCode: .projectPathUnverified) { $0 == "running project commands before project path is verified" },
        .init(reasonCode: .missingTool) { $0.hasPrefix("running ") && $0.contains("is available") },
        .init(reasonCode: .toolVerificationFailed) { $0.hasPrefix("running ") && $0.contains("version check succeeds") },
        .init(reasonCode: .developerDirectoryUnverified) { $0 == "Swift/Xcode build commands before xcode-select -p succeeds" },
        .init(reasonCode: .runtimeVersionMismatch) { $0.hasPrefix("dependency installs before matching active ") },
        .init(reasonCode: .packageManagerVersionMismatch) { $0.hasPrefix("dependency installs before matching ") },
        .init(reasonCode: .dependencySignalConflict) { $0.hasPrefix("dependency installs ") },
        .init(reasonCode: .symlinkTargetReview) { $0 == "following project symlinks before reviewing targets" },
        .init(reasonCode: .secretOrCredentialAccess) { isSecretBearingBroadSearchCommand($0) },
        .init(reasonCode: .dependencyResolutionMutation) { isBaselineLockfileMutationCommand($0) },
        .init(reasonCode: .versionManagerMutation) { isVersionManagerMutationCommand($0) },
        .init(reasonCode: .dependencyResolutionMutation) { isSwiftPackageDependencyResolutionCommand($0) },
        .init(reasonCode: .remoteRepositoryAction) { isRemoteRepositoryActionCommand($0) },
        .init(reasonCode: .gitMutation) { isGitOrGitHubMutationGuard($0) },
        .init(reasonCode: .userApprovalRequired) { isWorkspaceMutationCommand($0) },
        .init(reasonCode: .packageRegistryMutation) { isPackageRegistryMutationCommand($0) },
        .init(reasonCode: .packageManagerActivation) { isPackageManagerActivationCommand($0) },
        .init(reasonCode: .dependencyMutation) { isDependencyMutationCommand($0) },
        .init(reasonCode: .ephemeralPackageExecution) { isEphemeralPackageExecutionCommand($0) },
    ]
    private static let forbiddenReasonRules: [ReasonRule] = [
        .init(reasonCode: .privilegedCommand) { $0 == "sudo" },
        .init(reasonCode: .outsideProjectDeletion) { $0 == "destructive file deletion outside the selected project" },
        .init(reasonCode: .remoteScriptExecution) { isRemoteScriptExecutionCommand($0) },
        .init(reasonCode: .hostPrivateData) { isHostPrivateDataCommand($0) },
        .init(reasonCode: .secretOrCredentialAccess) { isSecretOrCredentialCommand($0) },
        .init(reasonCode: .globalEnvironmentMutation) { isGlobalEnvironmentMutationCommand($0) },
    ]

    static func legend(askFirstCommands: [String], forbiddenCommands: [String]) -> [PolicyReasonCode] {
        let usedCodes = Set(
            askFirstCommands.map { askFirstReason(for: $0).code }
                + forbiddenCommands.map { forbiddenReason(for: $0).code }
        )
        return orderedReasonCodes.filter { usedCodes.contains($0.code) }
    }

    static func commandReasons(askFirstCommands: [String], forbiddenCommands: [String]) -> [PolicyCommandReason] {
        findings(askFirstCommands: askFirstCommands, forbiddenCommands: forbiddenCommands)
            .map { PolicyCommandReason(finding: $0) }
    }

    static func findings(askFirstCommands: [String], forbiddenCommands: [String]) -> [PolicyFinding] {
        askFirstCommands.map(askFirstFinding)
            + forbiddenCommands.map(forbiddenFinding)
    }

    static func askFirstCommandReason(for command: String) -> PolicyCommandReason {
        PolicyCommandReason(finding: askFirstFinding(for: command))
    }

    static func forbiddenCommandReason(for command: String) -> PolicyCommandReason {
        PolicyCommandReason(finding: forbiddenFinding(for: command))
    }

    static func askFirstFinding(for command: String) -> PolicyFinding {
        finding(
            command: command,
            classification: PolicyFinding.askFirstClassification,
            reason: askFirstReason(for: command)
        )
    }

    static func forbiddenFinding(for command: String) -> PolicyFinding {
        finding(
            command: command,
            classification: PolicyFinding.forbiddenClassification,
            reason: forbiddenReason(for: command)
        )
    }

    static func askFirstReason(for command: String) -> PolicyReasonCode {
        askFirstReasonRules.first { $0.matches(command) }?.reasonCode.reason
            ?? ReasonCode.userApprovalRequired.reason
    }

    static func forbiddenReason(for command: String) -> PolicyReasonCode {
        forbiddenReasonRules.first { $0.matches(command) }?.reasonCode.reason
            ?? ReasonCode.unsafeOrSensitiveCommand.reason
    }

    private static func finding(
        command: String,
        classification: String,
        reason: PolicyReasonCode
    ) -> PolicyFinding {
        PolicyFinding(
            command: command,
            classification: classification,
            reasonCode: reason.code,
            reason: reason.text
        )
    }

    private static func isDependencyMutationCommand(_ command: String) -> Bool {
        if isJavaScriptPackageManagerDependencyMutationCommand(command) {
            return true
        }
        if isPythonPackageManagerDependencyMutationCommand(command) {
            return true
        }
        if isRubyPackageManagerDependencyMutationCommand(command) {
            return true
        }
        if isGoCargoDependencyMutationCommand(command) {
            return true
        }

        let mutationWords = [
            "install", "ci", "update", "uninstall", "remove", "rm", "add", "sync",
            "compile", "publish", "unpublish", "push", "yank", "resolve", "bootstrap",
            "checkout", "build", "get", "tidy", "lock"
        ]
        let commandWords = command.split(whereSeparator: \.isWhitespace).map(String.init)
        return commandWords.contains { mutationWords.contains($0) }
    }

    private static func isSwiftPackageDependencyResolutionCommand(_ command: String) -> Bool {
        isSwiftPackageDependencyResolutionMutationCommand(command)
    }

    private static func isSecretOrCredentialCommand(_ command: String) -> Bool {
        isBaselineForbiddenSecretValueCommand(command)
            || isCredentialOrAuthSessionCommand(command)
            || command.contains("secret")
            || command.contains("credential")
            || command.contains("token")
            || command.contains("private key")
            || command.contains(".env")
            || command.contains(".netrc")
            || command.contains(".npmrc")
            || command.contains(".pypirc")
            || command.contains("auth config")
            || command.contains("~/.ssh")
            || command.contains("~/.aws")
            || command.contains("~/.docker")
            || command.contains("~/.kube")
    }

    private static func isCredentialOrAuthSessionCommand(_ command: String) -> Bool {
        if isCliAuthAndCredentialStoreCommand(command) {
            return true
        }
        if isPackageManagerCredentialAndConfigCommand(command) {
            return true
        }
        if isCloudAndContainerCredentialCommand(command) {
            return true
        }
        if isSshPrivateKeyCommand(command) {
            return true
        }
        return false
    }
}
