# Command Policy

This policy is advisory. Habitat does not block commands. `Forbidden` means this generated context tells the agent not to run the command.

## Policy Index
- `Review First` - 2 highest-priority approval rules with reasons.
- `Reason Codes` - 4 reason families used by this policy.
- `If Secret-Bearing Files Are Detected` - 3 detected paths requiring exclusions before broad search or export.
- `Allowed` - 1 concrete safe starting point.
- `Ask First` - 2 commands or command families requiring approval.
- `Forbidden` - 6 commands or command families to avoid.

## Review First
- `modifying lockfiles` (`dependency_resolution_mutation`) - Dependency resolution or lockfile changes can change project state.
- `git add` (`git_mutation`) - Git/GitHub mutation can change workspace, history, branches, or remotes.

## Reason Codes
- `dependency_resolution_mutation` - Dependency resolution or lockfile changes can change project state.
- `git_mutation` - Git/GitHub mutation can change workspace, history, branches, or remotes.
- `host_private_data` - Command can reveal local private host data.
- `secret_or_credential_access` - Command can read, expose, copy, or load secrets or credentials.

## If Secret-Bearing Files Are Detected
- Detected secret-bearing paths: .env, .npmrc, id_ed25519.
- Before recursive search, copy, sync, or archive commands, review exclusions for these paths.
- Prefer targeted project inspection over broad `rg`, `grep -R`, `rsync`, `tar`, `zip`, or `git archive` commands.

## Allowed
- `read-only project inspection`

## Ask First
- `modifying lockfiles` (`dependency_resolution_mutation`)
- `git add` (`git_mutation`)

## Forbidden
- `read .env values` (`secret_or_credential_access`)
- `read package manager auth config values` (`secret_or_credential_access`)
- `read private keys` (`secret_or_credential_access`)
- `recursive project search without excluding secret-bearing files` (`secret_or_credential_access`)
- `dump environment variables` (`host_private_data`)
- `read shell history` (`host_private_data`)

## If Dependency Installation Seems Necessary
- Re-check lockfiles and version hints first.
- Prefer the project-specific package manager from `agent_context.md`.
- Ask before any install, upgrade, uninstall, or global mutation.
