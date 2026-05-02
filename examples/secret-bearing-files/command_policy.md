# Command Policy

This policy is advisory. Habitat does not block commands. `Forbidden` means this generated context tells the agent not to run the command.

## Policy Index
- `Review First` - 3 highest-priority approval rules with reasons.
- `Reason Codes` - 4 reason families used by this policy.
- `If Secret-Bearing Files Are Detected` - 3 detected paths requiring exclusions before broad search or export.
- `Allowed` - 1 concrete safe starting point.
- `Ask First` - 3 commands or command families requiring approval.
- `Forbidden` - 5 commands or command families to avoid.

## Review First
- `recursive project search without excluding secret-bearing files` (`secret_or_credential_access`) - Command can read, expose, copy, or load secrets or credentials.
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
- Named source or test files that are not detected secret-bearing paths can be inspected directly.
- For necessary broad search, start with exclusion-aware `rg`: `rg <pattern> --glob '!.env' --glob '!.env.*' --glob '!.npmrc' --glob '!id_ed25519'`.
- For necessary Git-tracked search, use pathspec exclusions: `git grep <pattern> -- . ':(exclude).env' ':(exclude).env.*' ':(exclude).npmrc' ':(exclude)id_ed25519'`.
- Apply equivalent exclusions before broad `grep -R`, `git grep`, copy, sync, or archive commands.
- Prefer targeted source/test inspection over broad `rg`, `grep -R`, `git grep`, `rsync`, `tar`, `zip`, or `git archive` commands.

## Allowed
- `targeted read-only source/test inspection that avoids detected secret-bearing paths`

## Ask First
- `recursive project search without excluding secret-bearing files` (`secret_or_credential_access`)
- `modifying lockfiles` (`dependency_resolution_mutation`)
- `git add` (`git_mutation`)

## Forbidden
- `read .env values` (`secret_or_credential_access`)
- `read package manager auth config values` (`secret_or_credential_access`)
- `read private keys` (`secret_or_credential_access`)
- `dump environment variables` (`host_private_data`)
- `read shell history` (`host_private_data`)

## If Dependency Installation Seems Necessary
- Re-check lockfiles and version hints first.
- Prefer the project-specific package manager from `agent_context.md`.
- Ask before any install, upgrade, uninstall, or global mutation.
