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
- When `Ask First` is capped for brevity, include an overflow line that points agents to `command_policy.md` for the complete approval list.
- When symlinked project signals change between scans, include a concise `Notes` delta that tells agents to review symlink targets before following linked metadata or using dependency signals.
- Prioritize project-relevant secret access/exfiltration bans in `Avoid` when secret-bearing files are detected.
- When project metadata or secret-bearing directories are symlinks, tell the agent to review symlink targets before following them or trusting linked metadata.
- Do not select a package manager or emit concrete preferred commands from symlinked workflow files such as lockfiles, manifests, or Xcode project containers.
- Do not list concrete preferred commands in `Use` when their required executable is missing; keep the missing-tool guard in `Ask First` instead.
- Do not tell agents to use a selected project tool when its executable is missing; tell them to verify the executable before running that tool's commands.
- Do not tell agents to use a selected project tool when its version check failed; tell them to verify the executable before running that tool's commands.
- For JavaScript projects, if both `node` and the selected package manager are missing or unverifiable, mention both in the first `Use` verification line.
- When the selected project workflow has an internal package-manager label, name the concrete executable in `Use`, such as SwiftPM (`swift`) or Bundler (`bundle`), so agents do not infer a non-existent command.
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
- concrete generated preferred commands, only when the selected executable is available, its version check succeeds, or a project-local executable path is preferred
- package manager commands that do not install, update, delete, or mutate global state

`command_policy.md` should list concrete allowed commands such as `swift test` or `.venv/bin/python -m pytest`.
It should not emit broad Allowed entries like `test commands for the selected project` or `build commands for the selected project`, because those can cause an AI agent to improvise outside the verified command set.

Ask First:

- `brew install`
- `brew update`
- `brew cleanup`
- `brew autoremove`
- `brew tap`
- `brew tap-new`
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
- `bundle add`
- `bundle update`
- `bundle lock`
- `bundle remove`
- `running Bundler commands before bundle version check succeeds`
- `brew bundle`
- `brew bundle install`
- `brew bundle cleanup`
- `brew bundle dump`
- `brew tap`
- `brew tap-new`
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
- `following project symlinks before reviewing targets`
- `dependency installs before reviewing symlinked project metadata`
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
- `gh pr checkout`
- `gh pr create`
- `gh pr edit`
- `gh pr close`
- `gh pr reopen`
- `gh pr merge`
- `gh pr comment`
- `gh pr review`
- `gh issue create`
- `gh issue edit`
- `gh issue close`
- `gh issue reopen`
- `gh issue comment`
- `gh repo clone`
- `gh repo fork`
- `gh repo edit`
- `gh repo rename`
- `gh repo archive`
- `gh repo delete`
- `gh workflow run`
- `gh workflow enable`
- `gh workflow disable`
- `gh run cancel`
- `gh run delete`
- `gh run rerun`
- `gh release create`
- `gh release edit`
- `gh release upload`
- `gh release delete`
- `gh release delete-asset`
- `gh secret list`
- `gh secret set`
- `gh secret delete`
- `gh variable list`
- `gh variable get`
- `gh variable set`
- `gh variable delete`
- `gh api`
- `chmod`
- `chown`
- `chgrp`
- `sed -i`
- `perl -pi`
- `find -delete`
- `xargs rm`
- `cp`
- `cp -R`
- `cp -r`
- `mv`
- `rsync`
- `rsync --delete`
- `ditto`
- `tar -xf`
- `tar -xzf`
- `tar -xJf`
- `unzip`
- `truncate`
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
- `brew untap`
- `brew services start`
- `brew services stop`
- `brew services restart`
- `brew services run`
- `brew services cleanup`
- remote script execution through `curl` or `wget` piped into `sh` / `bash` / `zsh`
- `curl | sh`
- `curl | bash`
- `curl | zsh`
- `wget | sh`
- `wget | bash`
- `wget | zsh`
- `sh <(curl ...)`
- `bash <(curl ...)`
- `zsh <(curl ...)`
- `sh <(wget ...)`
- `bash <(wget ...)`
- `zsh <(wget ...)`
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
- `npm config list`
- `npm config ls`
- `npm config get`
- `npm config set`
- `npm config delete`
- `npm config rm`
- `npm config edit`
- `pnpm config list`
- `pnpm config get`
- `pnpm config set`
- `pnpm config delete`
- `yarn config`
- `yarn config list`
- `yarn config get`
- `yarn config set`
- `yarn config unset`
- `yarn config delete`
- `npm token`
- `npm token create`
- `npm token list`
- `npm token revoke`
- `npm login`
- `npm logout`
- `npm adduser`
- `npm whoami`
- `pnpm login`
- `pnpm logout`
- `pnpm whoami`
- `yarn npm login`
- `yarn npm logout`
- `yarn npm whoami`
- `gem signin`
- `gem signout`
- `bundle config`
- `bundle config list`
- `bundle config get`
- `bundle config set`
- `bundle config unset`
- `cargo login`
- `cargo logout`
- `pod trunk register`
- `pod trunk me`
- `gh auth token`
- `gh auth status --show-token`
- `gh auth status -t`
- `gh auth login`
- `gh auth logout`
- recursive project search without excluding secret-bearing files
- `grep -R <pattern> .`
- `grep -r <pattern> .`
- `find . -type f -exec grep <pattern> {} +`
- `find . -type f -exec grep -n <pattern> {} +`
- `find . -type f -print0 | xargs -0 grep <pattern>`
- `find . -type f -print0 | xargs -0 grep -n <pattern>`
- `rg <pattern>`
- `rg <pattern> .`
- `rg --hidden <pattern> .`
- `rg --no-ignore <pattern> .`
- `rg -u <pattern> .`
- `rg -uu <pattern> .`
- `rg -uuu <pattern> .`
- `git grep <pattern>`
- `git grep <pattern> -- .`
- project copy, sync, or archive without excluding secret-bearing files
- `cp -R . <destination>`
- `cp -r . <destination>`
- `rsync -a . <destination>`
- `rsync -av . <destination>`
- `ditto . <destination>`
- `tar -cf <archive> .`
- `tar -czf <archive> .`
- `tar -cjf <archive> .`
- `tar -cJf <archive> .`
- `zip -r <archive> .`
- `gh auth refresh`
- `gh auth setup-git`
- `git credential fill`
- `git credential approve`
- `git credential reject`
- `git credential-osxkeychain get`
- `git credential-osxkeychain store`
- `git credential-osxkeychain erase`
- `security find-generic-password -w`
- `security find-internet-password -w`
- `security dump-keychain`
- `security export`
- local cloud and container credential reads, opens, copies, uploads, archives, or token prints, including `cat ~/.aws/credentials`, `less ~/.aws/credentials`, `head ~/.aws/credentials`, `tail ~/.aws/credentials`, `grep <pattern> ~/.aws/credentials`, `rg <pattern> ~/.aws/credentials`, `base64 ~/.aws/credentials`, `xxd ~/.aws/credentials`, `strings ~/.aws/credentials`, `open ~/.aws/credentials`, `cp ~/.aws/credentials <destination>`, `rsync ~/.aws/credentials <destination>`, `curl -F file=@~/.aws/credentials <url>`, `curl --data-binary @~/.aws/credentials <url>`, `tar -czf <archive> ~/.aws/credentials`, `zip -r <archive> ~/.aws/credentials`, `cat ~/.aws/config`, `open ~/.aws/config`, `cp ~/.aws/config <destination>`, `aws configure get aws_access_key_id`, `aws configure get aws_secret_access_key`, `cat ~/.config/gcloud/application_default_credentials.json`, `open ~/.config/gcloud/application_default_credentials.json`, `cp ~/.config/gcloud/application_default_credentials.json <destination>`, `curl -F file=@~/.config/gcloud/application_default_credentials.json <url>`, `gcloud auth print-access-token`, `gcloud auth application-default print-access-token`, `cat ~/.docker/config.json`, `open ~/.docker/config.json`, `cp ~/.docker/config.json <destination>`, `curl -F file=@~/.docker/config.json <url>`, `cat ~/.kube/config`, `open ~/.kube/config`, `cp ~/.kube/config <destination>`, `curl -F file=@~/.kube/config <url>`, `tar -czf <archive> ~/.kube/config`, `zip -r <archive> ~/.kube/config`, `kubectl config view --raw`, and `kubectl config view --flatten --raw`
- environment variable dumps, including `env`, `printenv`, `export -p`, `set`, and `declare -x`
- clipboard reads, including `pbpaste`, `osascript -e 'the clipboard'`, and `osascript -e "the clipboard as text"`
- shell history reads, including `history`, `fc -l`, `cat ~/.zsh_history`, `less ~/.bash_history`, `bat ~/.history`, `nl -ba ~/.zsh_history`, `head ~/.zsh_history`, `tail ~/.bash_history`, `grep ~/.history`, `rg <pattern> ~/.zsh_history`, `sed -n <range> ~/.bash_history`, and `awk <program> ~/.history`
- browser profile and local mail reads, SQLite dumps, opens, copies, syncs, or archives, including `ls ~/Library/Application\ Support/Google/Chrome`, `find ~/Library/Application\ Support/Firefox/Profiles`, `cat ~/Library/Safari/History.db`, `sqlite3 ~/Library/Safari/History.db`, `sqlite3 ~/Library/Safari/History.db .dump`, `strings ~/Library/Safari/History.db`, `cp ~/Library/Application\ Support/Google/Chrome/Default/Cookies <destination>`, `open ~/Library/Mail`, `cp -R ~/Library/Application\ Support/Google/Chrome <destination>`, `rsync -a ~/Library/Mail <destination>`, `tar -czf <archive> ~/Library/Mail`, `zip -r <archive> ~/Library/Safari`, and `mdfind kMDItemContentType == com.apple.mail.email`
- home SSH private key reads, compares, encoded/binary dumps, opens, edits, copies, moves, syncs, remote copies, uploads, archives, or loads, including `cat ~/.ssh/id_rsa`, `less ~/.ssh/id_ed25519`, `bat ~/.ssh/id_ecdsa`, `nl -ba ~/.ssh/id_rsa`, `base64 ~/.ssh/id_rsa`, `xxd ~/.ssh/id_ed25519`, `hexdump -C ~/.ssh/id_ecdsa`, `strings ~/.ssh/id_dsa`, `head ~/.ssh/id_ecdsa`, `tail ~/.ssh/id_dsa`, `grep <pattern> ~/.ssh/id_rsa`, `rg <pattern> ~/.ssh/id_rsa`, `sed -n <range> ~/.ssh/id_rsa`, `awk <program> ~/.ssh/id_rsa`, `diff ~/.ssh/id_rsa <other>`, `cmp ~/.ssh/id_ed25519 <other>`, `open ~/.ssh/id_rsa`, `code ~/.ssh/id_ed25519`, `vim ~/.ssh/id_ecdsa`, `nano ~/.ssh/id_dsa`, `cp ~/.ssh/id_rsa <destination>`, `mv ~/.ssh/id_ed25519 <destination>`, `rsync ~/.ssh/id_ecdsa <destination>`, `scp ~/.ssh/id_ed25519 <destination>`, `curl -F file=@~/.ssh/id_rsa <url>`, `curl --data-binary @~/.ssh/id_ed25519 <url>`, `curl -T ~/.ssh/id_ecdsa <url>`, `wget --post-file=~/.ssh/id_dsa <url>`, `tar -czf <archive> ~/.ssh/id_dsa`, `zip -r <archive> ~/.ssh/id_rsa`, `ssh-add ~/.ssh/id_ed25519`, `ssh-add --apple-use-keychain ~/.ssh/id_ed25519`, and `ssh-keygen -y -f ~/.ssh/id_rsa`
- concrete reads, compares, encoded/binary dumps, opens, edits, copies, moves, syncs, remote copies, uploads, or archives of detected secret-bearing project files, such as `cat .env`, `less .npmrc`, `head .netrc`, `tail .envrc.local`, `grep <pattern> .pypirc`, `rg <pattern> .env`, `git grep <pattern> -- .env`, `sed -n <range> .env`, `awk <program> .env`, `diff .env <other>`, `git diff -- .env`, `git diff --cached -- .env`, `git diff --staged -- .env`, `git diff HEAD -- .env`, `git log -p -- .npmrc`, `git blame .env`, `git annotate .env`, `git show :.env`, `git show HEAD:.netrc`, `bat .npmrc`, `nl -ba .env`, `base64 .env`, `xxd .npmrc`, `hexdump -C .netrc`, `strings .envrc.local`, `open .env`, `code .npmrc`, `vim .netrc`, `nano .envrc.local`, `cp .env <destination>`, `mv .npmrc <destination>`, `rsync .netrc <destination>`, `scp .env <destination>`, `curl -F file=@.env <url>`, `curl --data-binary @.npmrc <url>`, `curl -T .netrc <url>`, `wget --post-file=.envrc.local <url>`, `tar -cf <archive> .env`, `tar -czf <archive> .env`, `zip -r <archive> id_ed25519`, `ssh-add id_ed25519`, `ssh-add --apple-use-keychain id_ed25519`, or `ssh-keygen -y -f id_ed25519`
- loading detected secret-bearing environment files, such as `source .env`, `. .env`, `source .envrc.local`, `. .envrc.local`, `direnv allow`, `direnv reload`, `direnv export <shell>`, or `direnv exec . <command>`
- project-wide copy, sync, or archive commands that would include detected secret-bearing files unless exclusions are reviewed first, such as `cp -R . <destination>`, `cp -r . <destination>`, `rsync -a . <destination>`, `rsync -av . <destination>`, `ditto . <destination>`, `tar -cf <archive> .`, `tar -czf <archive> .`, `tar -cjf <archive> .`, `tar -cJf <archive> .`, `zip -r <archive> .`, or `git archive HEAD`
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
- `gem update`
- `gem uninstall`
- `gem cleanup`
- `go install`
- `cargo install`
- `cargo uninstall`
- destructive file deletion outside the selected project
- dumping environment variables
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
  "generatorVersion": "0.1.0",
  "scannedAt": "2026-04-25T00:00:00Z",
  "projectPath": "/path/to/project",
  "system": {},
  "commands": [],
  "project": {
    "detectedFiles": [],
    "symlinkedFiles": [],
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
- `generatorVersion` records the Habitat generator release that produced the scan. Previous-scan comparison should surface generator-version changes so agents do not mistake report-shape or policy-generator differences for local environment drift.
- Generate Markdown from this JSON when possible.
- `project.symlinkedFiles` records detected project signals or safety-relevant directories that are symbolic links. Symlinked metadata files should not be read for runtime or package-manager hints, symlinked workflow files should not select the package manager or concrete preferred commands, and `.ssh` symlink targets should not be traversed for private-key filenames.
- `runtimeHints` may come from direct version files such as `.nvmrc` and `.python-version`, or safe project metadata such as `.tool-versions`, `mise.toml`, `.mise.toml`, `package.json` Volta pins, and `package.json` `engines.node`.
- `packageManagerVersion` may come from `package.json` `packageManager`, package-manager Volta pins, `.tool-versions` entries, or `[tools]` entries in `mise.toml` / `.mise.toml` for `npm`, `pnpm`, `yarn`, or `bun`; `packageManagerVersionSource` records that safe metadata source when known.
- `agent_context.md` should mention the known package-manager version source in `Use`, so agents know which safe metadata file backs the recommended `npm` / `pnpm` / `yarn` / `bun` version.
- Ruby runtime hints from `.ruby-version`, `.tool-versions`, or `mise.toml` may require asking before Bundler dependency installs when active Ruby differs or cannot be verified.
- Bundler projects may verify `bundle --version`; if `bundle` is missing or resolved but the check fails, `policy.preferredCommands` should omit Bundler commands and require Ask First before Bundler commands. Even when `bundle` is verified, do not emit incomplete command prefixes such as `bundle exec` without a concrete target.
- JavaScript projects may verify the selected package manager with `npm --version`, `pnpm --version`, `yarn --version`, or `bun --version` even when `package.json` has no package-manager version pin; if Node or the selected package manager is missing or unverifiable, `policy.preferredCommands` should omit related preferred commands and require Ask First before related commands.
- `packageManagerVersion` and `declaredPackageManagerVersion` should omit Corepack integrity suffixes such as `+sha512...` so Markdown artifacts stay short and compare only the command-relevant version.
- Previous-scan comparison should report JavaScript `packageManagerVersion` or `packageManagerVersionSource` changes when the selected package manager stays the same, so agents re-check active package-manager versions before dependency installs.
- Previous-scan comparison should report Node/Python/Ruby `runtimeHints` changes, so agents re-check active runtimes before dependency installs or build/test commands.
- uv projects may verify `uv --version`; if `uv` is missing or resolved but the check fails, `policy.preferredCommands` should omit uv commands and require Ask First before uv commands. Even when `uv` is verified, do not emit incomplete command prefixes such as `uv run` without a concrete target. A detected executable `.venv/bin/python` command may remain as a project-local preferred command.
- Homebrew Bundle, CocoaPods, and Carthage projects may verify `brew --version`, `pod --version`, or `carthage version`; if the selected tool is missing or resolved but the check fails, `policy.preferredCommands` should omit related preferred commands and require Ask First before related commands.
- Xcode projects may verify `xcodebuild -version`; if Xcode tooling is missing or unverifiable, `policy.preferredCommands` should omit `xcodebuild -list` guidance and require Ask First before Xcode build commands.
- `declaredPackageManager` records the safe `package.json` `packageManager` hint even when a lockfile selects a different package manager.
- Secret-bearing environment files such as `.env`, `.env.*`, `.envrc`, `.envrc.*`, and `.envrc.example` may be detected by filename, but values must not be read or emitted.
- Package-manager auth config files such as `.npmrc`, `.pnpmrc`, `.yarnrc`, `.yarnrc.yml`, `.pypirc`, `pip.conf`, `.gem/credentials`, `.bundle/config`, `.cargo/credentials.toml`, `.cargo/credentials`, `auth.json`, and `.composer/auth.json` may be detected by filename, but token values must not be read or emitted.
- Common SSH/private-key-like filenames such as `id_rsa`, `id_dsa`, `id_ecdsa`, `id_ed25519`, and top-level or `.ssh/` files ending in `.pem`, `.key`, `.p8`, `.p12`, or `.ppk` may be detected by filename, but key contents must not be read or emitted.
- `policy.preferredCommands` is an actionable list, not a raw candidate list. Omit concrete commands when their required executable is missing, when a project-relevant version check fails, times out, or returns empty output, when JavaScript needs a missing Node runtime, or when `xcode-select -p` cannot verify Swift/Xcode tooling.
- Markdown artifacts should render `policy.preferredCommands` directly for `Use` / `Allowed` and keep generic selected-project test/build allowances out.
- When Xcode tooling is missing or unverifiable, `agent_context.md` should tell agents to verify Xcode tooling instead of saying to use `xcodebuild`.
- Markdown artifacts may retain detected executable project-local commands such as `.venv/bin/python -m pytest` even when the selected package-manager executable is missing; in that case, keep broader build commands out of `Allowed` unless the selected executable is available.
- If the selected project path is not an existing directory, generated Markdown should avoid normal project-use guidance and allow only path existence checks while requiring Ask First for project commands.
- `changes` is empty unless `--previous-scan` is supplied. `--previous-scan` may point to a previous report directory or a direct `scan_result.json` file. It is limited to AI-actionable deltas such as package-manager changes, lockfile changes, runtime version guidance changes, secret-bearing file signal changes, missing-tool changes, project-relevant tool verification failures or recoveries, preferred command changes when the selected package manager stays the same, command-policy risk classification changes, and command-policy entries that are no longer highlighted by the current scan.
- Missing-tool comparison must not imply a tool became available just because it stopped being relevant to the current project. Report currently relevant tools with paths as available, and report previously missing tools that are no longer relevant as a separate current-policy guidance change.
- Missing-tool comparison must not report a previously missing tool as recovered when the current version check fails; surface the tool verification failure instead so agents keep related commands Ask First.
- Secret-bearing file comparison must remain filename-only. It may report added or removed `.env*`, `.envrc*`, package-manager auth config, and common top-level or `.ssh/` private-key filename signals, but must not read or emit their values.
- Symlink handling must remain conservative: do not follow symlinked metadata to collect hints, do not use symlinked workflow files to select a package manager, do not traverse symlinked `.ssh` directories, and require Ask First before following project symlinks or installing dependencies based on symlinked metadata.

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
