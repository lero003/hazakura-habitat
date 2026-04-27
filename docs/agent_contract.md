# Agent Contract

## Purpose

This document defines the contract between Hazakura Habitat and AI coding agents.

The generated artifacts should make the agent's next action safer and more specific.

## Primary Artifact: agent_context.md

`agent_context.md` is the most important human-readable output.

It should be short, direct, and action-oriented.

Required sections:

```markdown
# Agent Context

## Freshness
- Scanned at:
- Project:

## Use
- ...

## Avoid
- ...

## Ask First
- ...

## Mismatches
- ...

## Notes
- ...
```

Guidelines:

- Prefer imperative guidance over narrative explanation.
- Keep it short enough to paste into an AI prompt.
- Mention only details that can affect project work.
- Prioritize project-relevant secret-reading bans in `Avoid` when secret-bearing files are detected.
- Do not dump full package inventories here.
- Include scan freshness because environment data becomes stale quickly.

Example:

```markdown
## Use
- Use `pnpm` because `pnpm-lock.yaml` exists.
- Use Node from `/opt/homebrew/bin/node`.

## Avoid
- Do not run `npm install` unless the user approves switching package managers.
- Do not run `brew upgrade`.

## Ask First
- Active Node is `v22`, but `.nvmrc` requests `v20`.
```

## Primary Artifact: command_policy.md

`command_policy.md` tells the agent how to classify commands.

Required sections:

```markdown
# Command Policy

## Allowed

## Ask First

## Forbidden

## If Dependency Installation Seems Necessary
```

Default classifications:

Allowed:

- read-only project inspection
- test commands for the selected project
- build commands for the selected project
- package manager commands that do not install, update, delete, or mutate global state

Ask First:

- `brew install`
- `pip install`
- `pip3 install`
- `python -m pip install`
- `python3 -m pip install`
- `npm install`
- `npm ci`
- `npm update`
- `pnpm install`
- `pnpm add`
- `pnpm update`
- `yarn install`
- `yarn add`
- `yarn up`
- `bun install`
- `bun add`
- `bun update`
- `uv sync`
- `bundle install`
- `brew bundle`
- `brew bundle install`
- `brew bundle cleanup`
- `brew bundle dump`
- `swift package update`
- `swift package resolve`
- `go get`
- `go mod tidy`
- `cargo add`
- `cargo update`
- `pod install`
- `pod update`
- `pod repo update`
- `pod deintegrate`
- `carthage bootstrap`
- `carthage update`
- `carthage checkout`
- `carthage build`
- dependency installs before matching the selected JavaScript package manager to safe package-manager version metadata from `package.json`
- running JavaScript commands before `node` is available
- running `npm`, `pnpm`, `yarn`, or `bun` commands before the selected package manager is available
- dependency installs before choosing between `pyproject.toml` and `requirements*.txt` when both are present
- dependency installs before choosing between `uv.lock` and `requirements*.txt` when both are present
- creating or deleting virtual environments
- modifying lockfiles
- modifying version manager files

Forbidden in MVP-generated policy:

- `sudo`
- `brew upgrade`
- `brew uninstall`
- `npm install -g`
- global `pip install`
- `pip install --user`
- `pip3 install --user`
- `python -m pip install --user`
- `python3 -m pip install --user`
- destructive file deletion outside the selected project
- reading secret values
- reading `.envrc` values
- reading package manager auth config values such as `.npmrc` or yarn auth tokens

## Machine Artifact: scan_result.json

`scan_result.json` is the stable source of truth.

Top-level shape:

```json
{
  "schemaVersion": "0.1",
  "scannedAt": "2026-04-25T00:00:00Z",
  "projectPath": "/path/to/project",
  "system": {},
  "commands": [],
  "project": {
    "detectedFiles": [],
    "packageManager": "pnpm",
    "packageManagerVersion": "9.15.4",
    "declaredPackageManager": "pnpm",
    "declaredPackageManagerVersion": "9.15.4",
    "packageScripts": ["build", "test"],
    "runtimeHints": {}
  },
  "tools": {},
  "policy": {},
  "warnings": [],
  "diagnostics": []
}
```

Compatibility:

- Add fields freely during `0.x`.
- Do not rename or remove fields without documenting a schema change.
- Generate Markdown from this JSON when possible.
- `runtimeHints` may come from direct version files such as `.nvmrc` and `.python-version`, or safe project metadata such as `.tool-versions`, `package.json` Volta pins, and `package.json` `engines.node`.
- `declaredPackageManager` records the safe `package.json` `packageManager` hint even when a lockfile selects a different package manager.
- Secret-bearing environment files such as `.env`, `.env.*`, `.envrc`, and `.envrc.*` may be detected by filename, but values must not be read or emitted.
- Package-manager auth config files such as `.npmrc`, `.yarnrc`, and `.yarnrc.yml` may be detected by filename, but token values must not be read or emitted.

## Secondary Artifact: environment_report.md

`environment_report.md` is the longer report for audit and debugging.

It can include:

- command resolution table
- detected project files
- tool versions
- scanner diagnostics
- warnings
- privacy note

It should not compete with `agent_context.md`. If a detail is critical for AI behavior, put it in `agent_context.md` first.

## AI Usability Test

Before accepting a report format, ask:

- Can an agent choose the likely package manager?
- Can an agent identify commands that need approval?
- Can an agent notice version mismatches?
- Can an agent avoid global mutation?
- Can an agent ignore irrelevant global inventory?

If not, the artifact is not useful enough.
