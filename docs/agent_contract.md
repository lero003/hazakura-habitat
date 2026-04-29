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
- If the selected project path is not an existing directory, tell the agent to verify the path before running project commands.
- When a previous scan is supplied, include only AI-actionable deltas in `Notes`.
- Prioritize project-relevant secret-reading bans in `Avoid` when secret-bearing files are detected.
- Do not list concrete preferred commands in `Use` when their required executable is missing; keep the missing-tool guard in `Ask First` instead.
- Do not tell agents to use a selected project tool when its executable is missing; tell them to verify the executable before running that tool's commands.
- Do not tell agents to use a selected project tool when its version check failed; tell them to verify the executable before running that tool's commands.
- For JavaScript projects, if both `node` and the selected package manager are missing or unverifiable, mention both in the first `Use` verification line.
- A detected project-local executable path such as `.venv/bin/python` may remain in `Use` / `Allowed` when the selected package-manager executable is missing, but only when the path is executable and the concrete project-local command can run without the missing tool.
- For Python projects, an executable `.venv/bin/python` should prevent a broad missing-`python3` Ask First guard from hiding the project-local test command.
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
- test commands for the selected project, only when generated preferred commands include a concrete test command and the selected executable is available or a project-local executable path is preferred
- build commands for the selected project, only when generated preferred commands include a concrete build command and the selected executable is available
- package manager commands that do not install, update, delete, or mutate global state

Ask First:

- `brew install`
- `brew update`
- `brew cleanup`
- `brew autoremove`
- `pip install`
- `pip3 install`
- `python -m pip install`
- `python3 -m pip install`
- `pip uninstall`
- `pip3 uninstall`
- `python -m pip uninstall`
- `python3 -m pip uninstall`
- `pip download`
- `pip3 download`
- `python -m pip download`
- `python3 -m pip download`
- `pip wheel`
- `pip3 wheel`
- `python -m pip wheel`
- `python3 -m pip wheel`
- `pip index`
- `pip3 index`
- `python -m pip index`
- `python3 -m pip index`
- `pip search`
- `pip3 search`
- `python -m pip search`
- `python3 -m pip search`
- `pip cache purge`
- `pip3 cache purge`
- `python -m pip cache purge`
- `python3 -m pip cache purge`
- `pip cache remove`
- `pip3 cache remove`
- `python -m pip cache remove`
- `python3 -m pip cache remove`
- `pip config set`
- `pip3 config set`
- `python -m pip config set`
- `python3 -m pip config set`
- `pip config unset`
- `pip3 config unset`
- `python -m pip config unset`
- `python3 -m pip config unset`
- `pip config edit`
- `pip3 config edit`
- `python -m pip config edit`
- `python3 -m pip config edit`
- `npm install`
- `npm ci`
- `npm update`
- `npm uninstall`
- `npm remove`
- `npm rm`
- `npm exec`
- `npx`
- `pnpm install`
- `pnpm add`
- `pnpm update`
- `pnpm remove`
- `pnpm rm`
- `pnpm uninstall`
- `pnpm dlx`
- `yarn install`
- `yarn add`
- `yarn up`
- `yarn remove`
- `yarn dlx`
- `bun install`
- `bun add`
- `bun update`
- `bun remove`
- `bunx`
- `npm publish`
- `npm unpublish`
- `npm deprecate`
- `npm dist-tag`
- `npm owner`
- `npm access`
- `npm team`
- `pnpm publish`
- `yarn publish`
- `yarn npm publish`
- `bun publish`
- `uv publish`
- `twine upload`
- `python -m twine upload`
- `python3 -m twine upload`
- `gem push`
- `gem yank`
- `gem owner`
- `cargo publish`
- `cargo yank`
- `cargo owner`
- `pod trunk add-owner`
- `pod trunk remove-owner`
- `pod trunk push`
- `pod trunk deprecate`
- `pod trunk delete`
- `corepack enable`
- `corepack disable`
- `corepack prepare`
- `corepack install`
- `corepack use`
- `corepack up`
- `uv sync`
- `uv add`
- `uv remove`
- `uv pip install`
- `uv pip uninstall`
- `uv pip sync`
- `uv pip compile`
- `uvx`
- `uv tool run`
- `pipx run`
- `pipx runpip`
- `bundle install`
- `bundle remove`
- `running Bundler commands before bundle version check succeeds`
- `brew bundle`
- `brew bundle install`
- `brew bundle cleanup`
- `brew bundle dump`
- `running Homebrew Bundle commands before brew version check succeeds`
- `Swift/Xcode build commands before xcode-select -p succeeds`
- `running Xcode build commands before xcodebuild version check succeeds`
- `xcodebuild build/test/archive before selecting a scheme`
- `xcodebuild -resolvePackageDependencies`
- `xcodebuild -allowProvisioningUpdates`
- `swift package update`
- `swift package resolve`
- `go get`
- `go mod tidy`
- `cargo add`
- `cargo update`
- `cargo remove`
- `running Cargo commands before cargo version check succeeds`
- `pod install`
- `pod update`
- `pod repo update`
- `pod deintegrate`
- `running CocoaPods commands before pod version check succeeds`
- `carthage bootstrap`
- `carthage update`
- `carthage checkout`
- `carthage build`
- `running Carthage commands before carthage version check succeeds`
- `git clean`
- `git reset --hard`
- `git checkout`
- `git checkout --`
- `git checkout -f`
- `git checkout -B`
- `git switch`
- `git switch --discard-changes`
- `git switch -C`
- `git restore`
- `git rm`
- `git stash`
- `git stash push`
- `git stash pop`
- `git stash apply`
- `git stash drop`
- `git stash clear`
- `git branch -d`
- `git branch -D`
- `git tag -d`
- `git tag`
- `git fetch`
- `git fetch --all`
- `git fetch --prune`
- `git remote add`
- `git remote set-url`
- `git remote remove`
- `git init`
- `git clone`
- `git add`
- `git add -A`
- `git add --all`
- `git add -u`
- `git commit`
- `git commit --amend`
- `git reset`
- `git reset --soft`
- `git reset --mixed`
- `git pull`
- `git merge`
- `git cherry-pick`
- `git revert`
- `git rebase`
- `git submodule update`
- `git submodule update --init`
- `git submodule update --init --recursive`
- `git worktree add`
- `git worktree remove`
- `git worktree move`
- `git worktree prune`
- `git push`
- `git push -u`
- `git push --set-upstream`
- `git push -f`
- `git push --force`
- `git push --force-with-lease`
- `git push --delete`
- `git push --mirror`
- `git push --all`
- `git push --tags`
- `git push <remote> +<ref>`
- `git push <remote> :<ref>`
- `chmod`
- `chown`
- `chgrp`
- `rm`
- `rm -r`
- `rm -rf`
- dependency installs before matching the selected JavaScript package manager to safe package-manager version metadata from `package.json`
- dependency installs when `package.json` `packageManager` conflicts with project package-manager signals such as `pnpm-workspace.yaml`
- dependency installs when `pnpm-workspace.yaml` conflicts with JavaScript lockfiles
- running JavaScript commands before `node` is available
- running JavaScript commands before `node` version check succeeds
- running `npm`, `pnpm`, `yarn`, or `bun` commands before that selected package manager's version check succeeds
- running `npm`, `pnpm`, `yarn`, or `bun` commands before the selected package manager is available
- running `uv` commands before `uv` is available
- running Python commands before `python3` is available
- running Python commands before project `.venv/bin/python` exists
- running selected project tool commands before that tool's version check succeeds
- dependency installs before matching active Ruby to project version hints
- dependency installs before choosing between `pyproject.toml` and `requirements*.txt` when both are present
- dependency installs before choosing between `uv.lock` and `requirements*.txt` when both are present
- `python -m venv`
- `python3 -m venv`
- `uv venv`
- `virtualenv`
- creating or deleting virtual environments
- modifying lockfiles
- modifying version manager files

Forbidden in MVP-generated policy:

- `sudo`
- `brew upgrade`
- `brew uninstall`
- `npm install -g`
- `npm install --global`
- `npm i -g`
- `npm i --global`
- `npm uninstall -g`
- `npm uninstall --global`
- `npm remove -g`
- `npm remove --global`
- `npm rm -g`
- `npm rm --global`
- `pnpm add -g`
- `pnpm add --global`
- `pnpm remove -g`
- `pnpm remove --global`
- `pnpm rm -g`
- `pnpm rm --global`
- `yarn global add`
- `yarn global remove`
- `yarn add -g`
- `yarn add --global`
- `yarn remove -g`
- `yarn remove --global`
- `bun add -g`
- `bun add --global`
- `bun remove -g`
- `bun remove --global`
- global `pip install`
- global `pip3 install`
- global `python -m pip install`
- global `python3 -m pip install`
- `pip install --user`
- `pip3 install --user`
- `python -m pip install --user`
- `python3 -m pip install --user`
- `pip install --break-system-packages`
- `pip3 install --break-system-packages`
- `python -m pip install --break-system-packages`
- `python3 -m pip install --break-system-packages`
- `pip config list`
- `pip3 config list`
- `python -m pip config list`
- `python3 -m pip config list`
- `pip config get`
- `pip3 config get`
- `python -m pip config get`
- `python3 -m pip config get`
- `pip config debug`
- `pip3 config debug`
- `python -m pip config debug`
- `python3 -m pip config debug`
- `npm token`
- `npm token create`
- `npm token list`
- `npm token revoke`
- `npm login`
- `npm logout`
- `npm adduser`
- `gem signin`
- `gem signout`
- `cargo login`
- `cargo logout`
- `pod trunk register`
- `pod trunk me`
- `pipx install`
- `pipx install-all`
- `pipx uninstall`
- `pipx uninstall-all`
- `pipx upgrade`
- `pipx upgrade-all`
- `pipx reinstall`
- `pipx reinstall-all`
- `pipx inject`
- `pipx uninject`
- `pipx pin`
- `pipx unpin`
- `pipx ensurepath`
- `uv tool install`
- `uv tool upgrade`
- `uv tool upgrade --all`
- `uv tool uninstall`
- `gem install`
- `gem uninstall`
- `go install`
- `cargo install`
- `cargo uninstall`
- destructive file deletion outside the selected project
- reading secret values
- reading `.envrc` values
- reading `.netrc` values
- reading package manager auth config values such as `.npmrc`, `.pnpmrc`, yarn auth tokens, `.pypirc`, `pip.conf`, `.gem/credentials`, `.bundle/config`, `.cargo/credentials.toml`, `.cargo/credentials`, `auth.json`, or `.composer/auth.json`

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
    "packageManagerVersionSource": "package.json",
    "declaredPackageManager": "pnpm",
    "declaredPackageManagerVersion": "9.15.4",
    "packageScripts": ["build", "test"],
    "runtimeHints": {}
  },
  "tools": {},
  "policy": {},
  "changes": [
    {
      "category": "package_manager",
      "summary": "Package manager changed from npm to pnpm.",
      "impact": "Use the current project package manager before running build, test, or install commands."
    }
  ],
  "warnings": [],
  "diagnostics": []
}
```

Compatibility:

- Add fields freely during `0.x`.
- Do not rename or remove fields without documenting a schema change.
- Generate Markdown from this JSON when possible.
- `runtimeHints` may come from direct version files such as `.nvmrc` and `.python-version`, or safe project metadata such as `.tool-versions`, `mise.toml`, `.mise.toml`, `package.json` Volta pins, and `package.json` `engines.node`.
- `packageManagerVersion` may come from `package.json` `packageManager`, package-manager Volta pins, `.tool-versions` entries, or `[tools]` entries in `mise.toml` / `.mise.toml` for `npm`, `pnpm`, `yarn`, or `bun`; `packageManagerVersionSource` records that safe metadata source when known.
- `agent_context.md` should mention the known package-manager version source in `Use`, so agents know which safe metadata file backs the recommended `npm` / `pnpm` / `yarn` / `bun` version.
- Ruby runtime hints from `.ruby-version`, `.tool-versions`, or `mise.toml` may require asking before Bundler dependency installs when active Ruby differs or cannot be verified.
- Bundler projects may verify `bundle --version`; if `bundle` is resolved but the check fails, Markdown artifacts should suppress `bundle exec` and require Ask First before Bundler commands.
- JavaScript projects may verify the selected package manager with `npm --version`, `pnpm --version`, `yarn --version`, or `bun --version` even when `package.json` has no package-manager version pin; if the resolved selected tool check fails, Markdown artifacts should suppress related preferred commands and require Ask First before related commands.
- `packageManagerVersion` and `declaredPackageManagerVersion` should omit Corepack integrity suffixes such as `+sha512...` so Markdown artifacts stay short and compare only the command-relevant version.
- Previous-scan comparison should report JavaScript `packageManagerVersion` or `packageManagerVersionSource` changes when the selected package manager stays the same, so agents re-check active package-manager versions before dependency installs.
- Previous-scan comparison should report Node/Python/Ruby `runtimeHints` changes, so agents re-check active runtimes before dependency installs or build/test commands.
- uv projects may verify `uv --version`; if the resolved `uv` check fails, Markdown artifacts should suppress `uv run` and require Ask First before uv commands.
- Homebrew Bundle, CocoaPods, and Carthage projects may verify `brew --version`, `pod --version`, or `carthage version`; if the selected tool is resolved but the check fails, Markdown artifacts should suppress related preferred commands and require Ask First before related commands.
- Xcode projects may verify `xcodebuild -version`; if `xcodebuild` is resolved but the check fails, Markdown artifacts should suppress `xcodebuild -list` guidance and require Ask First before Xcode build commands.
- `declaredPackageManager` records the safe `package.json` `packageManager` hint even when a lockfile selects a different package manager.
- Secret-bearing environment files such as `.env`, `.env.*`, `.envrc`, `.envrc.*`, and `.envrc.example` may be detected by filename, but values must not be read or emitted.
- Package-manager auth config files such as `.npmrc`, `.pnpmrc`, `.yarnrc`, `.yarnrc.yml`, `.pypirc`, `pip.conf`, `.gem/credentials`, `.bundle/config`, `.cargo/credentials.toml`, `.cargo/credentials`, `auth.json`, and `.composer/auth.json` may be detected by filename, but token values must not be read or emitted.
- Common SSH private key filenames such as `id_rsa`, `id_dsa`, `id_ecdsa`, `id_ed25519`, and the same names under `.ssh/` may be detected by filename, but key contents must not be read or emitted.
- Markdown artifacts may suppress `policy.preferredCommands` and generic selected-project test/build allowance from `Use` / `Allowed` when the required executable is currently missing, while preserving the structured preferred command data in `scan_result.json`.
- Markdown artifacts suppress JavaScript preferred commands and generic selected-project test/build allowance when Node is missing, and suppress concrete SwiftPM/Xcode preferred commands plus generic selected-project test/build allowance when `xcode-select -p` fails.
- When Xcode tooling is missing or unverifiable, `agent_context.md` should tell agents to verify Xcode tooling instead of saying to use `xcodebuild`.
- Markdown artifacts may retain detected executable project-local commands such as `.venv/bin/python -m pytest` even when the selected package-manager executable is missing; in that case, keep broader build commands out of `Allowed` unless the selected executable is available.
- If the selected project path is not an existing directory, generated Markdown should avoid normal project-use guidance and allow only path existence checks while requiring Ask First for project commands.
- `changes` is empty unless `--previous-scan` is supplied. `--previous-scan` may point to a previous report directory or a direct `scan_result.json` file. It is limited to AI-actionable deltas such as package-manager changes, lockfile changes, runtime version guidance changes, secret-bearing file signal changes, missing-tool changes, project-relevant tool verification failures or recoveries, preferred command changes when the selected package manager stays the same, command-policy risk classification changes, and command-policy entries that are no longer highlighted by the current scan.
- Missing-tool comparison must not imply a tool became available just because it stopped being relevant to the current project. Report currently relevant tools with paths as available, and report previously missing tools that are no longer relevant as a separate current-policy guidance change.
- Missing-tool comparison must not report a previously missing tool as recovered when the current version check fails; surface the tool verification failure instead so agents keep related commands Ask First.
- Secret-bearing file comparison must remain filename-only. It may report added or removed `.env*`, `.envrc*`, package-manager auth config, and common top-level or `.ssh/` SSH private-key filename signals, but must not read or emit their values.

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
