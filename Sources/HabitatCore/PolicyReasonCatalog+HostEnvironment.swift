extension PolicyReasonCatalog {
    private static let remoteScriptExecutionCommandFamily = CommandFamily([
        "remote script execution through curl or wget",
        "curl | sh",
        "curl | bash",
        "curl | zsh",
        "wget | sh",
        "wget | bash",
        "wget | zsh",
        "sh <(curl ...)",
        "bash <(curl ...)",
        "zsh <(curl ...)",
        "sh <(wget ...)",
        "bash <(wget ...)",
        "zsh <(wget ...)",
    ])
    static let remoteScriptExecutionCommands = remoteScriptExecutionCommandFamily.commands

    private static let globalEnvironmentMutationCommandFamily = CommandFamily([
        "brew upgrade",
        "brew uninstall",
        "brew untap",
        "brew services start",
        "brew services stop",
        "brew services restart",
        "brew services run",
        "brew services cleanup",
        "npm install -g",
        "npm install --global",
        "npm i -g",
        "npm i --global",
        "npm uninstall -g",
        "npm uninstall --global",
        "npm remove -g",
        "npm remove --global",
        "npm rm -g",
        "npm rm --global",
        "pnpm add -g",
        "pnpm add --global",
        "pnpm remove -g",
        "pnpm remove --global",
        "pnpm rm -g",
        "pnpm rm --global",
        "yarn global add",
        "yarn global remove",
        "yarn add -g",
        "yarn add --global",
        "yarn remove -g",
        "yarn remove --global",
        "bun add -g",
        "bun add --global",
        "bun remove -g",
        "bun remove --global",
        "global pip install",
        "global pip3 install",
        "global python -m pip install",
        "global python3 -m pip install",
        "pip install --user",
        "pip3 install --user",
        "python -m pip install --user",
        "python3 -m pip install --user",
        "pip install --break-system-packages",
        "pip3 install --break-system-packages",
        "python -m pip install --break-system-packages",
        "python3 -m pip install --break-system-packages",
        "pipx install",
        "pipx install-all",
        "pipx uninstall",
        "pipx uninstall-all",
        "pipx upgrade",
        "pipx upgrade-all",
        "pipx reinstall",
        "pipx reinstall-all",
        "pipx inject",
        "pipx uninject",
        "pipx pin",
        "pipx unpin",
        "pipx ensurepath",
        "uv tool install",
        "uv tool upgrade",
        "uv tool upgrade --all",
        "uv tool uninstall",
        "gem install",
        "gem update",
        "gem uninstall",
        "gem cleanup",
        "go install",
        "cargo install",
        "cargo uninstall",
    ])
    static let globalEnvironmentMutationCommands = globalEnvironmentMutationCommandFamily.commands

    static func isRemoteScriptExecutionCommand(_ command: String) -> Bool {
        remoteScriptExecutionCommandFamily.contains(command)
            || command.contains("| sh")
            || command.contains("| bash")
            || command.contains("| zsh")
            || command.contains("<(curl")
            || command.contains("<(wget")
    }

    static func isGlobalEnvironmentMutationCommand(_ command: String) -> Bool {
        globalEnvironmentMutationCommandFamily.contains(command)
            || command.hasPrefix("brew ")
            || command.contains(" install")
            || command.contains(" uninstall")
            || command.contains(" upgrade")
            || command.contains(" cleanup")
            || command.contains(" ensurepath")
            || command.contains(" add -g")
            || command.contains(" --global")
            || command.contains(" -g")
    }
}
