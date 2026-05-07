import Testing
import Foundation
@testable import HabitatCore

struct BaselineCommandPolicyTests {
    @Test
    func scanAsksBeforeLockfileMutation() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.policy.askFirstCommands.contains("modifying lockfiles"))
        #expect(result.policy.askFirstCommands.contains("modifying version manager files"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(policy.contains("`modifying lockfiles`"))
        #expect(policy.contains("`modifying version manager files`"))
    }

    @Test
    func scanForbidsRemoteScriptShellExecution() throws {
        let projectURL = try makeProject(files: [
            "README.md": "# Demo\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
            "remote script execution through curl or wget",
            "curl | sh",
            "curl | bash",
            "curl | zsh",
            "wget | sh",
            "wget | bash",
            "wget | zsh",
            "sh <(curl ...)",
            "bash <(curl ...)",
            "zsh <(curl ...)",
            "sh <(wget ...)",
            "bash <(wget ...)",
            "zsh <(wget ...)",
        ]

        for command in commands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Do not execute remote scripts through `curl` or `wget` piped into a shell."))
        #expect(!context.contains("Do not run `remote script execution through curl or wget`."))

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func scanForbidsLanguageGlobalPackageMutationCommands() throws {
        let projectURL = try makeProject(files: [
            "README.md": "# Demo\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
            "gem install",
            "gem update",
            "gem uninstall",
            "gem cleanup",
            "go install",
            "cargo install",
            "cargo uninstall",
            "pipx install",
            "pipx install-all",
            "pipx uninstall",
            "pipx uninstall-all",
            "pipx upgrade",
            "pipx upgrade-all",
            "pipx reinstall",
            "pipx reinstall-all",
            "pipx inject",
            "pipx uninject",
            "pipx pin",
            "pipx unpin",
            "pipx ensurepath",
            "uv tool install",
            "uv tool upgrade",
            "uv tool upgrade --all",
            "uv tool uninstall",
        ]

        for command in commands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func scanAsksBeforeGitHubCliLocalAndRemoteMutationCommands() throws {
        let projectURL = try makeProject(files: [
            "README.md": "# Demo\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
            "gh pr checkout",
            "gh pr create",
            "gh pr edit",
            "gh pr close",
            "gh pr reopen",
            "gh pr merge",
            "gh pr comment",
            "gh pr review",
            "gh issue create",
            "gh issue edit",
            "gh issue close",
            "gh issue reopen",
            "gh issue comment",
            "gh repo clone",
            "gh repo fork",
            "gh repo edit",
            "gh repo rename",
            "gh repo archive",
            "gh repo delete",
            "gh workflow run",
            "gh workflow enable",
            "gh workflow disable",
            "gh run cancel",
            "gh run delete",
            "gh run rerun",
            "gh release create",
            "gh release edit",
            "gh release upload",
            "gh release delete",
            "gh release delete-asset",
            "gh secret list",
            "gh secret set",
            "gh secret delete",
            "gh variable list",
            "gh variable get",
            "gh variable set",
            "gh variable delete",
            "gh api",
        ]

        for command in commands {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }
}
