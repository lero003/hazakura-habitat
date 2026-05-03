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
    private static let askFirstClassification = "ask_first"
    private static let forbiddenClassification = "forbidden"

    private static let orderedReasonCodes: [PolicyReasonCode] = [
        .init(code: "project_path_unverified", text: "Verify `--project` before running project commands."),
        .init(code: "missing_tool", text: "Required project tool is missing on `PATH`."),
        .init(code: "tool_verification_failed", text: "Required project tool is present but unverifiable."),
        .init(code: "developer_directory_unverified", text: "Active developer directory is not verified."),
        .init(code: "runtime_version_mismatch", text: "Active runtime differs from project version hints."),
        .init(code: "package_manager_version_mismatch", text: "Package-manager version guidance is not yet verified."),
        .init(code: "dependency_signal_conflict", text: "Project dependency signals need review before mutation."),
        .init(code: "symlink_target_review", text: "Review symlink targets before trusting linked metadata."),
        .init(code: "dependency_resolution_mutation", text: "Dependency resolution or lockfile changes can change project state."),
        .init(code: "version_manager_mutation", text: "Runtime or tool-version edits change future command behavior."),
        .init(code: "git_mutation", text: "Git/GitHub mutation can change workspace, history, branches, or remotes."),
        .init(code: "dependency_mutation", text: "Dependency install, update, or removal can mutate project state."),
        .init(code: "ephemeral_package_execution", text: "Ephemeral package execution can fetch or run unpinned code outside the selected workflow."),
        .init(code: "user_approval_required", text: "Requires user approval before execution."),
        .init(code: "privileged_command", text: "Privileged commands can mutate the host outside the project."),
        .init(code: "outside_project_deletion", text: "Deletion outside the selected project is out of scope."),
        .init(code: "remote_script_execution", text: "Remote scripts must not be executed without review."),
        .init(code: "host_private_data", text: "Command can reveal local private host data."),
        .init(code: "secret_or_credential_access", text: "Command can read, expose, copy, or load secrets or credentials."),
        .init(code: "global_environment_mutation", text: "Command can mutate global tools or host environment state."),
        .init(code: "unsafe_or_sensitive_command", text: "Generated policy marks this command as unsafe or sensitive."),
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
            classification: askFirstClassification,
            reason: askFirstReason(for: command)
        )
    }

    static func forbiddenCommandReason(for command: String) -> PolicyCommandReason {
        commandReason(
            command: command,
            classification: forbiddenClassification,
            reason: forbiddenReason(for: command)
        )
    }

    static func askFirstReason(for command: String) -> PolicyReasonCode {
        if command == "running project commands before project path is verified" {
            return .init(code: "project_path_unverified", text: "Verify `--project` before running project commands.")
        }

        if command.hasPrefix("running "), command.contains("is available") {
            return .init(code: "missing_tool", text: "Required project tool is missing on `PATH`.")
        }

        if command.hasPrefix("running "), command.contains("version check succeeds") {
            return .init(code: "tool_verification_failed", text: "Required project tool is present but unverifiable.")
        }

        if command == "Swift/Xcode build commands before xcode-select -p succeeds" {
            return .init(code: "developer_directory_unverified", text: "Active developer directory is not verified.")
        }

        if command.hasPrefix("dependency installs before matching active ") {
            return .init(code: "runtime_version_mismatch", text: "Active runtime differs from project version hints.")
        }

        if command.hasPrefix("dependency installs before matching ") {
            return .init(code: "package_manager_version_mismatch", text: "Package-manager version guidance is not yet verified.")
        }

        if command.hasPrefix("dependency installs ") {
            return .init(code: "dependency_signal_conflict", text: "Project dependency signals need review before mutation.")
        }

        if command == "following project symlinks before reviewing targets" {
            return .init(code: "symlink_target_review", text: "Review symlink targets before trusting linked metadata.")
        }

        if isSecretBearingBroadSearchCommand(command) {
            return .init(code: "secret_or_credential_access", text: "Command can read, expose, copy, or load secrets or credentials.")
        }

        if command == "modifying lockfiles" {
            return .init(code: "dependency_resolution_mutation", text: "Dependency resolution or lockfile changes can change project state.")
        }

        if command == "modifying version manager files" {
            return .init(code: "version_manager_mutation", text: "Runtime or tool-version edits change future command behavior.")
        }

        if command == "swift package update" || command == "swift package resolve" {
            return .init(code: "dependency_resolution_mutation", text: "Dependency resolution or lockfile changes can change project state.")
        }

        if isGitOrGitHubMutationGuard(command) {
            return .init(code: "git_mutation", text: "Git/GitHub mutation can change workspace, history, branches, or remotes.")
        }

        if isDependencyMutationCommand(command) {
            return .init(code: "dependency_mutation", text: "Dependency install, update, or removal can mutate project state.")
        }

        if isEphemeralPackageExecutionCommand(command) {
            return .init(code: "ephemeral_package_execution", text: "Ephemeral package execution can fetch or run unpinned code outside the selected workflow.")
        }

        return .init(code: "user_approval_required", text: "Requires user approval before execution.")
    }

    static func forbiddenReason(for command: String) -> PolicyReasonCode {
        if command == "sudo" {
            return .init(code: "privileged_command", text: "Privileged commands can mutate the host outside the project.")
        }

        if command == "destructive file deletion outside the selected project" {
            return .init(code: "outside_project_deletion", text: "Deletion outside the selected project is out of scope.")
        }

        if command == "remote script execution through curl or wget"
            || command.contains("| sh")
            || command.contains("| bash")
            || command.contains("| zsh")
            || command.contains("<(curl")
            || command.contains("<(wget") {
            return .init(code: "remote_script_execution", text: "Remote scripts must not be executed without review.")
        }

        if command == "dump environment variables"
            || command == "env"
            || command == "printenv"
            || command == "export -p"
            || command == "set"
            || command == "declare -x"
            || command == "read clipboard contents"
            || command == "read shell history"
            || command == "read browser or mail data" {
            return .init(code: "host_private_data", text: "Command can reveal local private host data.")
        }

        if isCredentialOrAuthSessionCommand(command)
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
            || command.contains("~/.kube") {
            return .init(code: "secret_or_credential_access", text: "Command can read, expose, copy, or load secrets or credentials.")
        }

        if command.hasPrefix("brew ")
            || command.contains(" install")
            || command.contains(" uninstall")
            || command.contains(" upgrade")
            || command.contains(" cleanup")
            || command.contains(" ensurepath")
            || command.contains(" add -g")
            || command.contains(" --global")
            || command.contains(" -g") {
            return .init(code: "global_environment_mutation", text: "Command can mutate global tools or host environment state.")
        }

        return .init(code: "unsafe_or_sensitive_command", text: "Generated policy marks this command as unsafe or sensitive.")
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
