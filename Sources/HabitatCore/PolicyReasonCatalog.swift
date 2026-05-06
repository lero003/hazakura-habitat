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

    private enum ReasonCode: String, CaseIterable, Sendable {
        case projectPathUnverified = "project_path_unverified"
        case missingTool = "missing_tool"
        case toolVerificationFailed = "tool_verification_failed"
        case developerDirectoryUnverified = "developer_directory_unverified"
        case runtimeVersionMismatch = "runtime_version_mismatch"
        case packageManagerVersionMismatch = "package_manager_version_mismatch"
        case packageManagerActivation = "package_manager_activation"
        case dependencySignalConflict = "dependency_signal_conflict"
        case symlinkTargetReview = "symlink_target_review"
        case dependencyResolutionMutation = "dependency_resolution_mutation"
        case versionManagerMutation = "version_manager_mutation"
        case gitMutation = "git_mutation"
        case remoteRepositoryAction = "remote_repository_action"
        case dependencyMutation = "dependency_mutation"
        case packageRegistryMutation = "package_registry_mutation"
        case ephemeralPackageExecution = "ephemeral_package_execution"
        case userApprovalRequired = "user_approval_required"
        case privilegedCommand = "privileged_command"
        case outsideProjectDeletion = "outside_project_deletion"
        case remoteScriptExecution = "remote_script_execution"
        case hostPrivateData = "host_private_data"
        case secretOrCredentialAccess = "secret_or_credential_access"
        case globalEnvironmentMutation = "global_environment_mutation"
        case unsafeOrSensitiveCommand = "unsafe_or_sensitive_command"

        var reason: PolicyReasonCode {
            switch self {
            case .projectPathUnverified:
                return .init(code: rawValue, text: "Verify `--project` before running project commands.")
            case .missingTool:
                return .init(code: rawValue, text: "Required project tool is missing on `PATH`.")
            case .toolVerificationFailed:
                return .init(code: rawValue, text: "Required project tool is present but unverifiable.")
            case .developerDirectoryUnverified:
                return .init(code: rawValue, text: "Active developer directory is not verified.")
            case .runtimeVersionMismatch:
                return .init(code: rawValue, text: "Active runtime differs from project version hints.")
            case .packageManagerVersionMismatch:
                return .init(code: rawValue, text: "Package-manager version guidance is not yet verified.")
            case .packageManagerActivation:
                return .init(code: rawValue, text: "Package-manager activation can change shims, fetch package-manager versions, or mutate project metadata.")
            case .dependencySignalConflict:
                return .init(code: rawValue, text: "Project dependency signals need review before mutation.")
            case .symlinkTargetReview:
                return .init(code: rawValue, text: "Review symlink targets before trusting linked metadata.")
            case .dependencyResolutionMutation:
                return .init(code: rawValue, text: "Dependency resolution or lockfile changes can change project state.")
            case .versionManagerMutation:
                return .init(code: rawValue, text: "Runtime or tool-version edits change future command behavior.")
            case .gitMutation:
                return .init(code: rawValue, text: "Git mutation can change workspace, history, branches, or remotes.")
            case .remoteRepositoryAction:
                return .init(code: rawValue, text: "Remote repository actions can change or reveal repository metadata, CI state, releases, variables, or remote content.")
            case .dependencyMutation:
                return .init(code: rawValue, text: "Dependency install, update, or removal can mutate project state.")
            case .packageRegistryMutation:
                return .init(code: rawValue, text: "Package registry publication or metadata changes affect external package state.")
            case .ephemeralPackageExecution:
                return .init(code: rawValue, text: "Ephemeral package execution can fetch or run unpinned code outside the selected workflow.")
            case .userApprovalRequired:
                return .init(code: rawValue, text: "Requires user approval before execution.")
            case .privilegedCommand:
                return .init(code: rawValue, text: "Privileged commands can mutate the host outside the project.")
            case .outsideProjectDeletion:
                return .init(code: rawValue, text: "Deletion outside the selected project is out of scope.")
            case .remoteScriptExecution:
                return .init(code: rawValue, text: "Remote scripts must not be executed without review.")
            case .hostPrivateData:
                return .init(code: rawValue, text: "Command can reveal local private host data.")
            case .secretOrCredentialAccess:
                return .init(code: rawValue, text: "Command can read, expose, copy, or load secrets or credentials.")
            case .globalEnvironmentMutation:
                return .init(code: rawValue, text: "Command can mutate global tools or host environment state.")
            case .unsafeOrSensitiveCommand:
                return .init(code: rawValue, text: "Generated policy marks this command as unsafe or sensitive.")
            }
        }
    }

    private static let orderedReasonCodes: [PolicyReasonCode] = ReasonCode.allCases.map(\.reason)

    static let baselineAskFirstCommands = homebrewDirectAskFirstCommands
        + pipAskFirstCommands
        + npmDependencyMutationCommands
        + npmEphemeralPackageExecutionCommands
        + pnpmDependencyMutationCommands
        + pnpmEphemeralPackageExecutionCommands
        + yarnDependencyMutationCommands
        + yarnEphemeralPackageExecutionCommands
        + bunDependencyMutationCommands
        + bunEphemeralPackageExecutionCommands
        + packageRegistryMutationCommands
        + corepackPackageManagerActivationCommands
        + uvDependencyMutationCommands
        + pythonEphemeralPackageExecutionCommands
        + rubyBundlerDependencyMutationCommands
        + homebrewBundleReviewCommands
        + xcodebuildProjectMutationCommands
        + goDependencyMutationCommands
        + cargoDependencyMutationCommands
        + cocoapodsDependencyMutationCommands
        + carthageDependencyMutationCommands
        + virtualEnvironmentMutationCommands
        + [
            "modifying lockfiles",
        ]
        + versionManagerMutationCommands
        + localGitWorkspaceMutationCommands
        + gitHubCliMutationCommands
        + workspaceMutationCommands

    static let baselineForbiddenCommands = [
        "sudo",
        "destructive file deletion outside the selected project",
    ] + remoteScriptExecutionCommands
        + globalEnvironmentMutationCommands
        + packageManagerCredentialAndConfigCommands
        + cliAuthAndCredentialStoreCommands
        + cloudAndContainerCredentialCommands
        + hostPrivateDataCommands
        + sshPrivateKeyCommands
        + [
            "load secret environment files",
            "read .env values",
            "read .envrc values",
            "read .netrc values",
            "read package manager auth config values",
            "read private keys",
        ]

    static func packageManagerMutationReviewCommands(for packageManager: String) -> [String] {
        switch packageManager {
        case "npm":
            return npmDependencyMutationCommands
        case "pnpm":
            return pnpmDependencyMutationCommands
        case "yarn":
            return yarnDependencyMutationCommands
        case "bun":
            return bunDependencyMutationCommands
        case "uv":
            return uvDependencyMutationCommands
        case "python":
            return pipDependencyMutationCommands
        case "bundler":
            return rubyBundlerDependencyMutationCommands
        case "homebrew":
            return homebrewPackageManagerReviewCommands
        case "swiftpm":
            return swiftPackageDependencyResolutionCommands
        case "go":
            return goDependencyMutationCommands
        case "cargo":
            return cargoDependencyMutationCommands
        case "cocoapods":
            return cocoapodsDependencyMutationCommands
        case "carthage":
            return carthageDependencyMutationCommands
        case "xcodebuild":
            return xcodebuildProjectMutationCommands
        default:
            return []
        }
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
        .init(reasonCode: .dependencyResolutionMutation) { $0 == "modifying lockfiles" },
        .init(reasonCode: .versionManagerMutation) { isVersionManagerMutationCommand($0) },
        .init(reasonCode: .dependencyResolutionMutation) { isSwiftPackageDependencyResolutionCommand($0) },
        .init(reasonCode: .remoteRepositoryAction) { isRemoteRepositoryActionCommand($0) },
        .init(reasonCode: .gitMutation) { isGitOrGitHubMutationGuard($0) },
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
        isCredentialOrAuthSessionCommand(command)
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
