import Foundation

public struct PolicyReasonCode: Codable, Equatable {
    public let code: String
    public let text: String

    public init(code: String, text: String) {
        self.code = code
        self.text = text
    }
}

enum PolicyReasonCatalog {
    static func legend(askFirstCommands: [String], forbiddenCommands: [String]) -> [PolicyReasonCode] {
        var reasons: [PolicyReasonCode] = []
        for command in askFirstCommands {
            append(askFirstReason(for: command), to: &reasons)
        }
        for command in forbiddenCommands {
            append(forbiddenReason(for: command), to: &reasons)
        }
        return reasons
    }

    static func commandReasons(askFirstCommands: [String], forbiddenCommands: [String]) -> [PolicyCommandReason] {
        askFirstCommands.map { command in
            commandReason(
                command: command,
                classification: "ask_first",
                reason: askFirstReason(for: command)
            )
        } + forbiddenCommands.map { command in
            commandReason(
                command: command,
                classification: "forbidden",
                reason: forbiddenReason(for: command)
            )
        }
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

        if command.contains("secret")
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

    private static func append(_ reason: PolicyReasonCode, to reasons: inout [PolicyReasonCode]) {
        guard !reasons.contains(where: { $0.code == reason.code }) else {
            return
        }

        reasons.append(reason)
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
}
