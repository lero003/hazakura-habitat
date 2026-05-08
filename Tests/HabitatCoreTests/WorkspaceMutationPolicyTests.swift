import Foundation
import Testing
@testable import HabitatCore

struct WorkspaceMutationPolicyTests {
    @Test
    func scanAsksBeforeProjectDeletionCleanupIndexHistoryBranchAndWorktreeCommands() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
            "git clean",
            "git reset --hard",
            "git checkout",
            "git checkout --",
            "git checkout -f",
            "git checkout -B",
            "git switch",
            "git switch --discard-changes",
            "git switch -C",
            "git restore",
            "git rm",
            "git stash",
            "git stash push",
            "git stash pop",
            "git stash apply",
            "git stash drop",
            "git stash clear",
            "git branch -d",
            "git branch -D",
            "git tag -d",
            "git tag",
            "git fetch",
            "git fetch --all",
            "git fetch --prune",
            "git remote add",
            "git remote set-url",
            "git remote remove",
            "git init",
            "git clone",
            "git add",
            "git add -A",
            "git add --all",
            "git add -u",
            "git commit",
            "git commit --amend",
            "git reset",
            "git reset --soft",
            "git reset --mixed",
            "git pull",
            "git merge",
            "git cherry-pick",
            "git revert",
            "git rebase",
            "git submodule update",
            "git submodule update --init",
            "git submodule update --init --recursive",
            "git worktree add",
            "git worktree remove",
            "git worktree move",
            "git worktree prune",
            "git push",
            "git push -u",
            "git push --set-upstream",
            "git push -f",
            "git push --force",
            "git push --force-with-lease",
            "git push --delete",
            "git push --mirror",
            "git push --all",
            "git push --tags",
            "git push <remote> +<ref>",
            "git push <remote> :<ref>",
            "rm",
            "rm -r",
            "rm -rf",
        ]

        for command in commands {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }
        let commandReasonCodes = Dictionary(uniqueKeysWithValues: result.policy.commandReasons.map { ($0.command, $0.reasonCode) })
        for command in ["rm", "rm -r", "rm -rf"] {
            #expect(commandReasonCodes[command] == "user_approval_required", "Expected \(command) to explain workspace mutation risk without dependency-mutation fallback")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
        #expect(policy.contains("`rm -rf` (`user_approval_required`)"))
    }

    @Test
    func scanAsksBeforePermissionAndOwnershipChanges() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
            "chmod",
            "chown",
            "chgrp",
        ]

        for command in commands {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }
        let commandReasonCodes = Dictionary(uniqueKeysWithValues: result.policy.commandReasons.map { ($0.command, $0.reasonCode) })
        for command in PolicyReasonCatalog.localGitWorkspaceMutationCommands {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
            #expect(commandReasonCodes[command] == "git_mutation", "Expected \(command) to explain local Git workspace mutation risk")
        }
        for command in ["gh pr checkout", "gh repo clone"] {
            #expect(commandReasonCodes[command] == "git_mutation", "Expected \(command) to explain local Git workspace mutation risk")
        }
        for command in [
            "gh pr create",
            "gh pr review",
            "gh issue comment",
            "gh workflow run",
            "gh release upload",
            "gh secret list",
            "gh variable get",
            "gh api",
        ] {
            #expect(commandReasonCodes[command] == "remote_repository_action", "Expected \(command) to explain remote repository action risk")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
        #expect(policy.contains("`gh pr checkout` (`git_mutation`)"))
        #expect(policy.contains("`gh pr create` (`remote_repository_action`)"))
        #expect(policy.contains("`gh workflow run` (`remote_repository_action`)"))
        #expect(policy.contains("`gh variable get` (`remote_repository_action`)"))
    }

    @Test
    func scanAsksBeforeBulkRewriteAndDeletionShellCommands() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
            "sed -i",
            "perl -pi",
            "find -delete",
            "xargs rm",
            "truncate",
        ]

        for command in commands {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }
        let commandReasonCodes = Dictionary(uniqueKeysWithValues: result.policy.commandReasons.map { ($0.command, $0.reasonCode) })
        #expect(commandReasonCodes["xargs rm"] == "user_approval_required", "Expected xargs rm to explain workspace mutation risk without dependency-mutation fallback")
        #expect(commandReasonCodes["find -delete"] == "user_approval_required", "Expected find -delete to explain workspace mutation risk")

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func scanAsksBeforeShellCopyMoveSyncAndArchiveExtractionCommands() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
            "cp",
            "cp -R",
            "cp -r",
            "mv",
            "rsync",
            "rsync --delete",
            "ditto",
            "tar -xf",
            "tar -xzf",
            "tar -xJf",
            "unzip",
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

    @Test
    func scanForbidsDestructiveDeletionOutsideSelectedProject() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.policy.forbiddenCommands.contains("destructive file deletion outside the selected project"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Do not delete files outside the selected project."))
        #expect(!context.contains("Do not run `destructive file deletion outside the selected project`."))
        #expect(policy.contains("`destructive file deletion outside the selected project`"))
    }
}
