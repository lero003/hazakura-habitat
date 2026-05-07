import Testing
import Foundation
@testable import HabitatCore

struct CredentialPolicyTests {
    @Test
    func scanForbidsPackageRegistryAuthTokenAndSessionCommands() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = PolicyReasonCatalog.packageManagerCredentialAndConfigCommands.filter { command in
            command.hasPrefix("npm token")
                || command.hasPrefix("npm login")
                || command.hasPrefix("npm logout")
                || command.hasPrefix("npm adduser")
                || command.hasPrefix("npm whoami")
                || command.hasPrefix("pnpm login")
                || command.hasPrefix("pnpm logout")
                || command.hasPrefix("pnpm whoami")
                || command.hasPrefix("yarn npm login")
                || command.hasPrefix("yarn npm logout")
                || command.hasPrefix("yarn npm whoami")
                || command.hasPrefix("gem signin")
                || command.hasPrefix("gem signout")
                || command.hasPrefix("cargo login")
                || command.hasPrefix("cargo logout")
                || command.hasPrefix("pod trunk register")
                || command.hasPrefix("pod trunk me")
        }

        for command in commands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }
        let commandReasonCodes = Dictionary(uniqueKeysWithValues: result.policy.commandReasons.map { ($0.command, $0.reasonCode) })
        for command in ["npm whoami", "pnpm whoami", "yarn npm whoami", "gem signin", "cargo login", "pod trunk me"] {
            #expect(commandReasonCodes[command] == "secret_or_credential_access", "Expected \(command) to explain credential/session risk")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func scanForbidsJavaScriptPackageManagerConfigAccessCommands() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
            ".npmrc": "//registry.npmjs.org/:_authToken=secret\n",
            ".pnpmrc": "//registry.npmjs.org/:_authToken=secret\n",
            ".yarnrc.yml": "npmAuthToken: secret\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = PolicyReasonCatalog.packageManagerCredentialAndConfigCommands.filter { command in
            command.hasPrefix("npm config")
                || command.hasPrefix("pnpm config")
                || command.hasPrefix("yarn config")
        }

        for command in commands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }
        let commandReasonCodes = Dictionary(uniqueKeysWithValues: result.policy.commandReasons.map { ($0.command, $0.reasonCode) })
        for command in ["npm config get", "pnpm config get", "yarn config get"] {
            #expect(commandReasonCodes[command] == "secret_or_credential_access", "Expected \(command) to explain credential/config risk")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive package manager auth config files."))

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func scanForbidsCredentialStoreAndCliAuthTokenCommands() throws {
        let projectURL = try makeProject(files: [
            "README.md": "# Demo\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = PolicyReasonCatalog.cliAuthAndCredentialStoreCommands

        for command in commands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }
        let commandReasonCodes = Dictionary(uniqueKeysWithValues: result.policy.commandReasons.map { ($0.command, $0.reasonCode) })
        for command in ["gh auth login", "gh auth setup-git", "git credential fill", "security export"] {
            #expect(commandReasonCodes[command] == "secret_or_credential_access", "Expected \(command) to explain credential/session risk")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func cliAuthAndCredentialStoreCommandsStayCentralizedForPolicyConsumers() {
        let commands = PolicyReasonCatalog.cliAuthAndCredentialStoreCommands

        #expect(commands == [
            "gh auth token",
            "gh auth status --show-token",
            "gh auth status -t",
            "gh auth login",
            "gh auth logout",
            "gh auth refresh",
            "gh auth setup-git",
            "git credential fill",
            "git credential approve",
            "git credential reject",
            "git credential-osxkeychain get",
            "git credential-osxkeychain store",
            "git credential-osxkeychain erase",
            "security find-generic-password -w",
            "security find-internet-password -w",
            "security dump-keychain",
            "security export",
        ])

        for command in commands {
            #expect(PolicyReasonCatalog.forbiddenReason(for: command).code == "secret_or_credential_access")
        }
    }

    @Test
    func scanForbidsCloudAndContainerCredentialReads() throws {
        let projectURL = try makeProject(files: [
            "README.md": "# Demo\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = PolicyReasonCatalog.cloudAndContainerCredentialCommands

        for command in commands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }
        let commandReasonCodes = Dictionary(uniqueKeysWithValues: result.policy.commandReasons.map { ($0.command, $0.reasonCode) })
        for command in ["aws sso login", "gcloud auth login", "docker login", "kubectl config view --raw"] {
            #expect(commandReasonCodes[command] == "secret_or_credential_access", "Expected \(command) to explain credential/session risk")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Do not read, open, copy, upload, or archive local cloud or container credential files, or print cloud auth tokens."))
        #expect(!context.contains("Do not run `read local cloud and container credential files`."))

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func cloudAndContainerCredentialCommandsStayCentralizedForPolicyConsumers() {
        let commands = PolicyReasonCatalog.cloudAndContainerCredentialCommands

        #expect(commands == [
            "read local cloud and container credential files",
            "cat ~/.aws/credentials",
            "less ~/.aws/credentials",
            "head ~/.aws/credentials",
            "tail ~/.aws/credentials",
            "grep <pattern> ~/.aws/credentials",
            "rg <pattern> ~/.aws/credentials",
            "base64 ~/.aws/credentials",
            "xxd ~/.aws/credentials",
            "strings ~/.aws/credentials",
            "open ~/.aws/credentials",
            "cp ~/.aws/credentials <destination>",
            "rsync ~/.aws/credentials <destination>",
            "curl -F file=@~/.aws/credentials <url>",
            "curl --data-binary @~/.aws/credentials <url>",
            "tar -czf <archive> ~/.aws/credentials",
            "zip -r <archive> ~/.aws/credentials",
            "cat ~/.aws/config",
            "open ~/.aws/config",
            "cp ~/.aws/config <destination>",
            "aws configure get aws_access_key_id",
            "aws configure get aws_secret_access_key",
            "aws configure get aws_session_token",
            "aws configure export-credentials",
            "aws configure export-credentials --format env",
            "aws sso get-role-credentials",
            "aws sso login",
            "aws sso logout",
            "aws ecr get-login-password",
            "aws codeartifact get-authorization-token",
            "cat ~/.config/gcloud/application_default_credentials.json",
            "open ~/.config/gcloud/application_default_credentials.json",
            "cp ~/.config/gcloud/application_default_credentials.json <destination>",
            "curl -F file=@~/.config/gcloud/application_default_credentials.json <url>",
            "gcloud auth print-access-token",
            "gcloud auth print-identity-token",
            "gcloud auth application-default print-access-token",
            "gcloud auth login",
            "gcloud auth revoke",
            "gcloud auth application-default login",
            "gcloud auth application-default revoke",
            "gcloud auth configure-docker",
            "gcloud config config-helper --format=json",
            "cat ~/.docker/config.json",
            "open ~/.docker/config.json",
            "cp ~/.docker/config.json <destination>",
            "curl -F file=@~/.docker/config.json <url>",
            "docker login",
            "docker logout",
            "docker context export",
            "cat ~/.kube/config",
            "open ~/.kube/config",
            "cp ~/.kube/config <destination>",
            "curl -F file=@~/.kube/config <url>",
            "tar -czf <archive> ~/.kube/config",
            "zip -r <archive> ~/.kube/config",
            "kubectl config view --raw",
            "kubectl config view --flatten --raw",
            "kubectl config view --minify --raw",
            "kubectl config set-credentials",
            "kubectl config unset",
            "kubectl config delete-user",
            "kubectl create token",
        ])

        for command in commands {
            #expect(PolicyReasonCatalog.forbiddenReason(for: command).code == "secret_or_credential_access")
        }
    }
}
