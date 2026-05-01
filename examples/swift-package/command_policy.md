# Command Policy

This policy is advisory. Habitat does not block commands. `Forbidden` means this generated context tells the agent not to run the command.

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
