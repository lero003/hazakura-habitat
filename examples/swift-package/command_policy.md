# Command Policy

This policy is advisory. Habitat does not block commands. `Forbidden` means this generated context tells the agent not to run the command.

## Review First
- `swift package update` (`dependency_resolution_mutation`) - Dependency resolution or lockfile changes can change project state.
- `swift package resolve` (`dependency_resolution_mutation`) - Dependency resolution or lockfile changes can change project state.
- `modifying lockfiles` (`dependency_resolution_mutation`) - Dependency resolution or lockfile changes can change project state.
- `git add` (`git_mutation`) - Git/GitHub mutation can change workspace, history, branches, or remotes.
- `git commit` (`git_mutation`) - Git/GitHub mutation can change workspace, history, branches, or remotes.
- `git push` (`git_mutation`) - Git/GitHub mutation can change workspace, history, branches, or remotes.

## Reason Codes
- `dependency_resolution_mutation` - Dependency resolution or lockfile changes can change project state.
- `git_mutation` - Git/GitHub mutation can change workspace, history, branches, or remotes.
- `privileged_command` - Privileged commands can mutate the host outside the project.
- `host_private_data` - Command can reveal local private host data.
- `remote_script_execution` - Remote scripts must not be executed without review.

## Allowed
- `swift test`
- `swift build`
- `read-only project inspection`

## Ask First
- `swift package update`
- `swift package resolve`
- `modifying lockfiles`
- `git add`
- `git commit`
- `git push`

## Forbidden
- `sudo`
- `env`
- `printenv`
- `pbpaste`
- `history`
- `curl | sh`
- `wget | bash`

## If Dependency Installation Seems Necessary
- Re-check lockfiles and version hints first.
- Prefer the project-specific package manager from `agent_context.md`.
- Ask before any install, upgrade, uninstall, or global mutation.
