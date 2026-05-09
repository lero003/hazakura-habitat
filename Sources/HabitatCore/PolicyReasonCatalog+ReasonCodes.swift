extension PolicyReasonCatalog {
    enum ReasonCode: String, CaseIterable, Sendable {
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

    static let orderedReasonCodes: [PolicyReasonCode] = ReasonCode.allCases.map(\.reason)
}
