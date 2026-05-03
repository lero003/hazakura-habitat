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
        case dependencySignalConflict = "dependency_signal_conflict"
        case symlinkTargetReview = "symlink_target_review"
        case dependencyResolutionMutation = "dependency_resolution_mutation"
        case versionManagerMutation = "version_manager_mutation"
        case gitMutation = "git_mutation"
        case dependencyMutation = "dependency_mutation"
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
            case .dependencySignalConflict:
                return .init(code: rawValue, text: "Project dependency signals need review before mutation.")
            case .symlinkTargetReview:
                return .init(code: rawValue, text: "Review symlink targets before trusting linked metadata.")
            case .dependencyResolutionMutation:
                return .init(code: rawValue, text: "Dependency resolution or lockfile changes can change project state.")
            case .versionManagerMutation:
                return .init(code: rawValue, text: "Runtime or tool-version edits change future command behavior.")
            case .gitMutation:
                return .init(code: rawValue, text: "Git/GitHub mutation can change workspace, history, branches, or remotes.")
            case .dependencyMutation:
                return .init(code: rawValue, text: "Dependency install, update, or removal can mutate project state.")
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
        .init(reasonCode: .versionManagerMutation) { $0 == "modifying version manager files" },
        .init(reasonCode: .dependencyResolutionMutation) { $0 == "swift package update" || $0 == "swift package resolve" },
        .init(reasonCode: .gitMutation) { isGitOrGitHubMutationGuard($0) },
        .init(reasonCode: .dependencyMutation) { isDependencyMutationCommand($0) },
        .init(reasonCode: .ephemeralPackageExecution) { isEphemeralPackageExecutionCommand($0) },
    ]
    private static let forbiddenReasonRules: [ReasonRule] = [
        .init(reasonCode: .privilegedCommand) { $0 == "sudo" },
        .init(reasonCode: .outsideProjectDeletion) { $0 == "destructive file deletion outside the selected project" },
        .init(reasonCode: .remoteScriptExecution) {
            $0 == "remote script execution through curl or wget"
                || $0.contains("| sh")
                || $0.contains("| bash")
                || $0.contains("| zsh")
                || $0.contains("<(curl")
                || $0.contains("<(wget")
        },
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
        askFirstCommands.map(askFirstCommandReason)
            + forbiddenCommands.map(forbiddenCommandReason)
    }

    static func askFirstCommandReason(for command: String) -> PolicyCommandReason {
        commandReason(
            command: command,
            classification: PolicyCommandReason.askFirstClassification,
            reason: askFirstReason(for: command)
        )
    }

    static func forbiddenCommandReason(for command: String) -> PolicyCommandReason {
        commandReason(
            command: command,
            classification: PolicyCommandReason.forbiddenClassification,
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

    static func isGitOrGitHubMutationGuard(_ command: String) -> Bool {
        command.hasPrefix("git ")
            || command.hasPrefix("gh ")
    }

    private static func commandReason(
        command: String,
        classification: String,
        reason: PolicyReasonCode
    ) -> PolicyCommandReason {
        PolicyCommandReason(
            command: command,
            classification: classification,
            reasonCode: reason.code,
            reason: reason.text
        )
    }

    private static func isDependencyMutationCommand(_ command: String) -> Bool {
        let mutationWords = [
            "install", "ci", "update", "uninstall", "remove", "rm", "add", "sync",
            "compile", "publish", "unpublish", "push", "yank", "resolve", "bootstrap",
            "checkout", "build", "get", "tidy", "lock"
        ]
        let commandWords = command.split(whereSeparator: \.isWhitespace).map(String.init)
        return commandWords.contains { mutationWords.contains($0) }
    }

    private static func isEphemeralPackageExecutionCommand(_ command: String) -> Bool {
        [
            "npm exec",
            "npx",
            "pnpm dlx",
            "yarn dlx",
            "bunx",
            "uvx",
            "uv tool run",
            "pipx run",
            "pipx runpip",
        ].contains(command)
    }

    private static func isHostPrivateDataCommand(_ command: String) -> Bool {
        [
            "dump environment variables",
            "env",
            "printenv",
            "export -p",
            "set",
            "declare -x",
            "read clipboard contents",
            "read shell history",
            "read browser or mail data",
        ].contains(command)
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

    private static func isGlobalEnvironmentMutationCommand(_ command: String) -> Bool {
        command.hasPrefix("brew ")
            || command.contains(" install")
            || command.contains(" uninstall")
            || command.contains(" upgrade")
            || command.contains(" cleanup")
            || command.contains(" ensurepath")
            || command.contains(" add -g")
            || command.contains(" --global")
            || command.contains(" -g")
    }

    private static func isSecretBearingBroadSearchCommand(_ command: String) -> Bool {
        [
            "recursive project search without excluding secret-bearing files",
            "grep -R <pattern> .",
            "grep -r <pattern> .",
            "grep -R -n <pattern> .",
            "grep -r -n <pattern> .",
            "find . -type f -exec grep <pattern> {} +",
            "find . -type f -exec grep -n <pattern> {} +",
            "find . -type f -print0 | xargs -0 grep <pattern>",
            "find . -type f -print0 | xargs -0 grep -n <pattern>",
            "rg <pattern>",
            "rg -n <pattern>",
            "rg <pattern> .",
            "rg -n <pattern> .",
            "rg --line-number <pattern> .",
            "rg --hidden <pattern> .",
            "rg --hidden -n <pattern> .",
            "rg --no-ignore <pattern> .",
            "rg --no-ignore -n <pattern> .",
            "rg -u <pattern> .",
            "rg -uu <pattern> .",
            "rg -uuu <pattern> .",
            "git grep <pattern>",
            "git grep -n <pattern>",
            "git grep <pattern> -- .",
            "git grep -n <pattern> -- .",
        ].contains(command)
    }

    private static func isCredentialOrAuthSessionCommand(_ command: String) -> Bool {
        let prefixes = [
            "npm token",
            "npm login",
            "npm logout",
            "npm adduser",
            "npm whoami",
            "npm config ",
            "pnpm login",
            "pnpm logout",
            "pnpm whoami",
            "pnpm config ",
            "yarn npm login",
            "yarn npm logout",
            "yarn npm whoami",
            "yarn config",
            "gem signin",
            "gem signout",
            "bundle config",
            "cargo login",
            "cargo logout",
            "pod trunk register",
            "pod trunk me",
            "gh auth ",
            "git credential",
            "security find-",
            "security dump-keychain",
            "security export",
            "aws configure ",
            "aws sso ",
            "aws ecr get-login-password",
            "aws codeartifact get-authorization-token",
            "gcloud auth ",
            "gcloud config config-helper",
            "docker login",
            "docker logout",
            "docker context export",
            "kubectl config ",
            "kubectl create token",
            "pip config ",
            "pip3 config ",
            "python -m pip config ",
            "python3 -m pip config ",
        ]

        return prefixes.contains { command.hasPrefix($0) }
    }
}
