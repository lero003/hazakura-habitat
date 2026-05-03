# Command Policy

This policy is advisory. Habitat does not block commands. `Forbidden` means this generated context tells the agent not to run the command.

## Policy Index
- `Review First` - 6 highest-priority approval rules with reasons.
- `Reason Codes` - 5 reason families used by this policy.
- `Allowed` - 3 concrete safe starting points.
- `Ask First` - 6 commands or command families requiring approval.
- `Forbidden` - 7 commands or command families to avoid.

## Review First
- `swift package update` (`dependency_resolution_mutation`) - Dependency resolution or lockfile changes can change project state.
- `swift package resolve` (`dependency_resolution_mutation`) - Dependency resolution or lockfile changes can change project state.
- `modifying lockfiles` (`dependency_resolution_mutation`) - Dependency resolution or lockfile changes can change project state.
- `git add` (`git_mutation`) - Git mutation can change workspace, history, branches, or remotes.
- `git commit` (`git_mutation`) - Git mutation can change workspace, history, branches, or remotes.
- `git push` (`git_mutation`) - Git mutation can change workspace, history, branches, or remotes.

## Reason Codes
- `dependency_resolution_mutation` - Dependency resolution or lockfile changes can change project state.
- `git_mutation` - Git mutation can change workspace, history, branches, or remotes.
- `privileged_command` - Privileged commands can mutate the host outside the project.
- `remote_script_execution` - Remote scripts must not be executed without review.
- `host_private_data` - Command can reveal local private host data.

## Allowed
- `swift test`
- `swift build`
- `read-only project inspection, including rg <pattern>`

## Ask First
- `swift package update` (`dependency_resolution_mutation`)
- `swift package resolve` (`dependency_resolution_mutation`)
- `modifying lockfiles` (`dependency_resolution_mutation`)
- `git add` (`git_mutation`)
- `git commit` (`git_mutation`)
- `git push` (`git_mutation`)

## Forbidden
- `sudo` (`privileged_command`)
- `env` (`host_private_data`)
- `printenv` (`host_private_data`)
- `pbpaste` (`host_private_data`)
- `history` (`host_private_data`)
- `curl | sh` (`remote_script_execution`)
- `wget | bash` (`remote_script_execution`)

## If Dependency Installation Seems Necessary
- Re-check lockfiles and version hints first.
- Prefer the project-specific package manager from `agent_context.md`.
- Ask before any install, upgrade, uninstall, or global mutation.
