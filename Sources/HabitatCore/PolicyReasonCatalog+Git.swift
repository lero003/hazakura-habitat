extension PolicyReasonCatalog {
    private static let localGitWorkspaceMutationCommandFamily = CommandFamily([
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
    ])
    static let localGitWorkspaceMutationCommands = localGitWorkspaceMutationCommandFamily.commands

    private static let gitHubCliMutationCommandFamily = CommandFamily([
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
    ])
    static let gitHubCliMutationCommands = gitHubCliMutationCommandFamily.commands

    private static let localGitHubWorkspaceMutationCommands = [
        "gh pr checkout",
        "gh repo clone",
    ]
    private static let localGitHubWorkspaceMutationCommandFamily = CommandFamily(localGitHubWorkspaceMutationCommands)

    private static let remoteRepositoryActionCommandFamily = CommandFamily(gitHubCliMutationCommands.filter {
        !localGitHubWorkspaceMutationCommands.contains($0)
    })

    static func isGitOrGitHubMutationGuard(_ command: String) -> Bool {
        localGitWorkspaceMutationCommandFamily.contains(command)
            || localGitHubWorkspaceMutationCommandFamily.contains(command)
    }

    static func isGitOrGitHubPolicyGuard(_ command: String) -> Bool {
        command.hasPrefix("git ")
            || command.hasPrefix("gh ")
    }

    static func isRemoteRepositoryActionCommand(_ command: String) -> Bool {
        remoteRepositoryActionCommandFamily.contains(command)
    }
}
