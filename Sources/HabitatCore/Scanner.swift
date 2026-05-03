import Foundation

public struct HabitatScanner {
    private let runner: CommandRunning
    private let detector: ProjectDetector

    public init(runner: CommandRunning = ProcessCommandRunner(), detector: ProjectDetector = ProjectDetector()) {
        self.runner = runner
        self.detector = detector
    }

    public func scan(projectURL: URL) -> ScanResult {
        let project = detector.detect(projectURL: projectURL)
        let projectPathIsExistingDirectory = projectPathIsExistingDirectory(projectURL)
        let pathEntries = (ProcessInfo.processInfo.environment["PATH"] ?? "")
            .split(separator: ":")
            .map(String.init)
            .filter { !$0.isEmpty }

        let baseCommandSpecs: [(String, String, [String])] = [
            ("swift", "/usr/bin/env", ["swift", "--version"]),
            ("git", "/usr/bin/env", ["git", "--version"]),
            ("node", "/usr/bin/env", ["node", "--version"]),
            ("python", "/usr/bin/env", ["python", "--version"]),
            ("python3", "/usr/bin/env", ["python3", "--version"]),
            ("pip", "/usr/bin/env", ["pip", "--version"]),
            ("pip3", "/usr/bin/env", ["pip3", "--version"]),
            ("uv", "/usr/bin/env", ["uv", "--version"]),
            ("pyenv", "/usr/bin/env", ["pyenv", "--version"]),
            ("ruby", "/usr/bin/env", ["ruby", "--version"]),
            ("gem", "/usr/bin/env", ["gem", "--version"]),
            ("go", "/usr/bin/env", ["go", "version"]),
            ("cargo", "/usr/bin/env", ["cargo", "--version"]),
            ("rustc", "/usr/bin/env", ["rustc", "--version"]),
            ("xcode-select", "/usr/bin/xcode-select", ["-p"]),
            ("xcodebuild", "/usr/bin/env", ["xcodebuild", "-version"]),
        ]

        let baseCommands = baseCommandSpecs.map { spec in
            runner.run(executable: spec.1, arguments: spec.2, timeout: 3.0)
        }

        let toolNames = ["python", "python3", "pip", "pip3", "uv", "pyenv", "node", "npm", "pnpm", "yarn", "bun", "ruby", "gem", "bundle", "go", "cargo", "rustc", "swift", "xcode-select", "xcodebuild", "git", "brew", "pod", "carthage"]
        let resolvedPaths = toolNames.map { tool in
            let result = runner.run(executable: "/usr/bin/which", arguments: ["-a", tool], timeout: 2.0)
            let paths = result.available && !result.stdout.isEmpty
                ? result.stdout.split(whereSeparator: \.isNewline).map(String.init)
                : []
            return ResolvedTool(name: tool, paths: Array(NSOrderedSet(array: paths)) as? [String] ?? paths)
        }

        let commandSpecs = baseCommandSpecs
            + projectSpecificVersionCommandSpecs(project: project, resolvedPaths: resolvedPaths)
        let additionalCommands = commandSpecs.dropFirst(baseCommandSpecs.count).map { spec in
            runner.run(executable: spec.1, arguments: spec.2, timeout: 3.0)
        }
        let commands = baseCommands + additionalCommands

        let versions = commandSpecs.map { spec in
            let result = commands.first(where: { $0.args == spec.2 })!
            let versionCommandSucceeded = versionCommandSucceeded(spec: spec, result: result)
            let output = versionCommandSucceeded
                ? [result.stdout, result.stderr].first(where: { !$0.isEmpty })
                : nil
            return ToolVersion(name: spec.0, version: output, available: versionCommandSucceeded)
        }

        let warnings = makeWarnings(
            project: project,
            projectPathIsExistingDirectory: projectPathIsExistingDirectory,
            resolvedPaths: resolvedPaths,
            versions: versions
        )
        let forbiddenCommands = orderedUnique([
            "sudo",
            "destructive file deletion outside the selected project",
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
            ] + PolicyReasonCatalog.packageManagerCredentialAndConfigCommands + [
            ] + PolicyReasonCatalog.cliAuthAndCredentialStoreCommands + [
            ] + PolicyReasonCatalog.cloudAndContainerCredentialCommands + [
                "dump environment variables",
                "env",
                "printenv",
                "export -p",
                "set",
                "declare -x",
                "read clipboard contents",
                "pbpaste",
                "osascript -e 'the clipboard'",
                "osascript -e 'the clipboard as text'",
                "osascript -e \"the clipboard\"",
                "osascript -e \"the clipboard as text\"",
                "read shell history",
                "history",
                "fc -l",
                "cat ~/.zsh_history",
                "cat ~/.bash_history",
                "cat ~/.history",
                "less ~/.zsh_history",
                "less ~/.bash_history",
                "less ~/.history",
                "bat ~/.zsh_history",
                "bat ~/.bash_history",
                "bat ~/.history",
                "nl -ba ~/.zsh_history",
                "nl -ba ~/.bash_history",
                "nl -ba ~/.history",
                "head ~/.zsh_history",
                "head ~/.bash_history",
                "head ~/.history",
                "tail ~/.zsh_history",
                "tail ~/.bash_history",
                "tail ~/.history",
                "grep ~/.zsh_history",
                "grep ~/.bash_history",
                "grep ~/.history",
                "rg <pattern> ~/.zsh_history",
                "rg <pattern> ~/.bash_history",
                "rg <pattern> ~/.history",
                "sed -n <range> ~/.zsh_history",
                "sed -n <range> ~/.bash_history",
                "sed -n <range> ~/.history",
                "awk <program> ~/.zsh_history",
                "awk <program> ~/.bash_history",
                "awk <program> ~/.history",
                "read browser or mail data",
                "ls ~/Library/Application\\ Support/Google/Chrome",
                "find ~/Library/Application\\ Support/Google/Chrome",
                "sqlite3 ~/Library/Application\\ Support/Google/Chrome/Default/Cookies",
                "sqlite3 ~/Library/Application\\ Support/Google/Chrome/Default/Cookies .dump",
                "cp ~/Library/Application\\ Support/Google/Chrome/Default/Cookies <destination>",
                "sqlite3 ~/Library/Application\\ Support/Google/Chrome/Default/Login\\ Data",
                "sqlite3 ~/Library/Application\\ Support/Google/Chrome/Default/Login\\ Data .dump",
                "cp ~/Library/Application\\ Support/Google/Chrome/Default/Login\\ Data <destination>",
                "open ~/Library/Application\\ Support/Google/Chrome",
                "cp -R ~/Library/Application\\ Support/Google/Chrome <destination>",
                "rsync -a ~/Library/Application\\ Support/Google/Chrome <destination>",
                "tar -czf <archive> ~/Library/Application\\ Support/Google/Chrome",
                "ls ~/Library/Application\\ Support/Firefox/Profiles",
                "find ~/Library/Application\\ Support/Firefox/Profiles",
                "open ~/Library/Application\\ Support/Firefox/Profiles",
                "cp -R ~/Library/Application\\ Support/Firefox/Profiles <destination>",
                "zip -r <archive> ~/Library/Application\\ Support/Firefox/Profiles",
                "ls ~/Library/Safari",
                "cat ~/Library/Safari/History.db",
                "sqlite3 ~/Library/Safari/History.db",
                "sqlite3 ~/Library/Safari/History.db .dump",
                "strings ~/Library/Safari/History.db",
                "cp ~/Library/Safari/History.db <destination>",
                "open ~/Library/Safari",
                "cp -R ~/Library/Safari <destination>",
                "zip -r <archive> ~/Library/Safari",
                "ls ~/Library/Mail",
                "find ~/Library/Mail",
                "mdfind kMDItemContentType == com.apple.mail.email",
                "sqlite3 ~/Library/Mail",
                "open ~/Library/Mail",
                "cp -R ~/Library/Mail <destination>",
                "rsync -a ~/Library/Mail <destination>",
                "tar -czf <archive> ~/Library/Mail",
                "cat ~/.ssh/id_rsa",
                "cat ~/.ssh/id_dsa",
                "cat ~/.ssh/id_ecdsa",
                "cat ~/.ssh/id_ed25519",
                "less ~/.ssh/id_rsa",
                "less ~/.ssh/id_dsa",
                "less ~/.ssh/id_ecdsa",
                "less ~/.ssh/id_ed25519",
                "bat ~/.ssh/id_rsa",
                "bat ~/.ssh/id_dsa",
                "bat ~/.ssh/id_ecdsa",
                "bat ~/.ssh/id_ed25519",
                "nl -ba ~/.ssh/id_rsa",
                "nl -ba ~/.ssh/id_dsa",
                "nl -ba ~/.ssh/id_ecdsa",
                "nl -ba ~/.ssh/id_ed25519",
                "base64 ~/.ssh/id_rsa",
                "base64 ~/.ssh/id_dsa",
                "base64 ~/.ssh/id_ecdsa",
                "base64 ~/.ssh/id_ed25519",
                "xxd ~/.ssh/id_rsa",
                "xxd ~/.ssh/id_dsa",
                "xxd ~/.ssh/id_ecdsa",
                "xxd ~/.ssh/id_ed25519",
                "hexdump -C ~/.ssh/id_rsa",
                "hexdump -C ~/.ssh/id_dsa",
                "hexdump -C ~/.ssh/id_ecdsa",
                "hexdump -C ~/.ssh/id_ed25519",
                "strings ~/.ssh/id_rsa",
                "strings ~/.ssh/id_dsa",
                "strings ~/.ssh/id_ecdsa",
                "strings ~/.ssh/id_ed25519",
                "head ~/.ssh/id_rsa",
                "head ~/.ssh/id_dsa",
                "head ~/.ssh/id_ecdsa",
                "head ~/.ssh/id_ed25519",
                "tail ~/.ssh/id_rsa",
                "tail ~/.ssh/id_dsa",
                "tail ~/.ssh/id_ecdsa",
                "tail ~/.ssh/id_ed25519",
                "grep <pattern> ~/.ssh/id_rsa",
                "grep <pattern> ~/.ssh/id_dsa",
                "grep <pattern> ~/.ssh/id_ecdsa",
                "grep <pattern> ~/.ssh/id_ed25519",
                "rg <pattern> ~/.ssh/id_rsa",
                "rg <pattern> ~/.ssh/id_dsa",
                "rg <pattern> ~/.ssh/id_ecdsa",
                "rg <pattern> ~/.ssh/id_ed25519",
                "sed -n <range> ~/.ssh/id_rsa",
                "sed -n <range> ~/.ssh/id_dsa",
                "sed -n <range> ~/.ssh/id_ecdsa",
                "sed -n <range> ~/.ssh/id_ed25519",
                "awk <program> ~/.ssh/id_rsa",
                "awk <program> ~/.ssh/id_dsa",
                "awk <program> ~/.ssh/id_ecdsa",
                "awk <program> ~/.ssh/id_ed25519",
                "diff ~/.ssh/id_rsa <other>",
                "diff ~/.ssh/id_dsa <other>",
                "diff ~/.ssh/id_ecdsa <other>",
                "diff ~/.ssh/id_ed25519 <other>",
                "cmp ~/.ssh/id_rsa <other>",
                "cmp ~/.ssh/id_dsa <other>",
                "cmp ~/.ssh/id_ecdsa <other>",
                "cmp ~/.ssh/id_ed25519 <other>",
                "open ~/.ssh/id_rsa",
                "open ~/.ssh/id_dsa",
                "open ~/.ssh/id_ecdsa",
                "open ~/.ssh/id_ed25519",
                "code ~/.ssh/id_rsa",
                "code ~/.ssh/id_dsa",
                "code ~/.ssh/id_ecdsa",
                "code ~/.ssh/id_ed25519",
                "vim ~/.ssh/id_rsa",
                "vim ~/.ssh/id_dsa",
                "vim ~/.ssh/id_ecdsa",
                "vim ~/.ssh/id_ed25519",
                "vi ~/.ssh/id_rsa",
                "vi ~/.ssh/id_dsa",
                "vi ~/.ssh/id_ecdsa",
                "vi ~/.ssh/id_ed25519",
                "nano ~/.ssh/id_rsa",
                "nano ~/.ssh/id_dsa",
                "nano ~/.ssh/id_ecdsa",
                "nano ~/.ssh/id_ed25519",
                "emacs ~/.ssh/id_rsa",
                "emacs ~/.ssh/id_dsa",
                "emacs ~/.ssh/id_ecdsa",
                "emacs ~/.ssh/id_ed25519",
                "cp ~/.ssh/id_rsa <destination>",
                "cp ~/.ssh/id_dsa <destination>",
                "cp ~/.ssh/id_ecdsa <destination>",
                "cp ~/.ssh/id_ed25519 <destination>",
                "cp -R ~/.ssh/id_rsa <destination>",
                "cp -R ~/.ssh/id_dsa <destination>",
                "cp -R ~/.ssh/id_ecdsa <destination>",
                "cp -R ~/.ssh/id_ed25519 <destination>",
                "cp -r ~/.ssh/id_rsa <destination>",
                "cp -r ~/.ssh/id_dsa <destination>",
                "cp -r ~/.ssh/id_ecdsa <destination>",
                "cp -r ~/.ssh/id_ed25519 <destination>",
                "mv ~/.ssh/id_rsa <destination>",
                "mv ~/.ssh/id_dsa <destination>",
                "mv ~/.ssh/id_ecdsa <destination>",
                "mv ~/.ssh/id_ed25519 <destination>",
                "rsync ~/.ssh/id_rsa <destination>",
                "rsync ~/.ssh/id_dsa <destination>",
                "rsync ~/.ssh/id_ecdsa <destination>",
                "rsync ~/.ssh/id_ed25519 <destination>",
                "rsync -a ~/.ssh/id_rsa <destination>",
                "rsync -a ~/.ssh/id_dsa <destination>",
                "rsync -a ~/.ssh/id_ecdsa <destination>",
                "rsync -a ~/.ssh/id_ed25519 <destination>",
                "scp ~/.ssh/id_rsa <destination>",
                "scp ~/.ssh/id_dsa <destination>",
                "scp ~/.ssh/id_ecdsa <destination>",
                "scp ~/.ssh/id_ed25519 <destination>",
                "curl -F file=@~/.ssh/id_rsa <url>",
                "curl -F file=@~/.ssh/id_dsa <url>",
                "curl -F file=@~/.ssh/id_ecdsa <url>",
                "curl -F file=@~/.ssh/id_ed25519 <url>",
                "curl --data-binary @~/.ssh/id_rsa <url>",
                "curl --data-binary @~/.ssh/id_dsa <url>",
                "curl --data-binary @~/.ssh/id_ecdsa <url>",
                "curl --data-binary @~/.ssh/id_ed25519 <url>",
                "curl -T ~/.ssh/id_rsa <url>",
                "curl -T ~/.ssh/id_dsa <url>",
                "curl -T ~/.ssh/id_ecdsa <url>",
                "curl -T ~/.ssh/id_ed25519 <url>",
                "wget --post-file=~/.ssh/id_rsa <url>",
                "wget --post-file=~/.ssh/id_dsa <url>",
                "wget --post-file=~/.ssh/id_ecdsa <url>",
                "wget --post-file=~/.ssh/id_ed25519 <url>",
                "tar -cf <archive> ~/.ssh/id_rsa",
                "tar -cf <archive> ~/.ssh/id_dsa",
                "tar -cf <archive> ~/.ssh/id_ecdsa",
                "tar -cf <archive> ~/.ssh/id_ed25519",
                "tar -czf <archive> ~/.ssh/id_rsa",
                "tar -czf <archive> ~/.ssh/id_dsa",
                "tar -czf <archive> ~/.ssh/id_ecdsa",
                "tar -czf <archive> ~/.ssh/id_ed25519",
                "tar -cjf <archive> ~/.ssh/id_rsa",
                "tar -cjf <archive> ~/.ssh/id_dsa",
                "tar -cjf <archive> ~/.ssh/id_ecdsa",
                "tar -cjf <archive> ~/.ssh/id_ed25519",
                "tar -cJf <archive> ~/.ssh/id_rsa",
                "tar -cJf <archive> ~/.ssh/id_dsa",
                "tar -cJf <archive> ~/.ssh/id_ecdsa",
                "tar -cJf <archive> ~/.ssh/id_ed25519",
                "zip <archive> ~/.ssh/id_rsa",
                "zip <archive> ~/.ssh/id_dsa",
                "zip <archive> ~/.ssh/id_ecdsa",
                "zip <archive> ~/.ssh/id_ed25519",
                "zip -r <archive> ~/.ssh/id_rsa",
                "zip -r <archive> ~/.ssh/id_dsa",
                "zip -r <archive> ~/.ssh/id_ecdsa",
                "zip -r <archive> ~/.ssh/id_ed25519",
                "ssh-add ~/.ssh/id_rsa",
                "ssh-add ~/.ssh/id_dsa",
                "ssh-add ~/.ssh/id_ecdsa",
                "ssh-add ~/.ssh/id_ed25519",
                "ssh-add -K ~/.ssh/id_rsa",
                "ssh-add -K ~/.ssh/id_dsa",
                "ssh-add -K ~/.ssh/id_ecdsa",
                "ssh-add -K ~/.ssh/id_ed25519",
                "ssh-add --apple-use-keychain ~/.ssh/id_rsa",
                "ssh-add --apple-use-keychain ~/.ssh/id_dsa",
                "ssh-add --apple-use-keychain ~/.ssh/id_ecdsa",
                "ssh-add --apple-use-keychain ~/.ssh/id_ed25519",
                "ssh-keygen -y -f ~/.ssh/id_rsa",
                "ssh-keygen -y -f ~/.ssh/id_dsa",
                "ssh-keygen -y -f ~/.ssh/id_ecdsa",
                "ssh-keygen -y -f ~/.ssh/id_ed25519",
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
                "load secret environment files",
                "read .env values",
                "read .envrc values",
                "read .netrc values",
                "read package manager auth config values",
                "read private keys"
            ] + secretFileAccessForbiddenCommands(project)
            + secretEnvironmentFileLoadForbiddenCommands(project)
            + secretEnvironmentRenderForbiddenCommands(project)
            + secretProjectBulkExportForbiddenCommands(project)
        )
        let preferredCommands = preferredCommands(project: project)
        let askFirstCommands = askFirstCommands(
            project: project,
            projectPathIsExistingDirectory: projectPathIsExistingDirectory,
            resolvedPaths: resolvedPaths,
            versions: versions,
            commands: commands
        )
        let commandPolicy = PolicySummary(
            preferredCommands: actionablePreferredCommands(
                preferredCommands,
                project: project,
                resolvedPaths: resolvedPaths,
                askFirstCommands: askFirstCommands
            ),
            askFirstCommands: askFirstCommands,
            forbiddenCommands: forbiddenCommands,
            reasonCodes: PolicyReasonCatalog.legend(
                askFirstCommands: askFirstCommands,
                forbiddenCommands: forbiddenCommands
            ),
            commandReasons: PolicyReasonCatalog.commandReasons(
                askFirstCommands: askFirstCommands,
                forbiddenCommands: forbiddenCommands
            )
        )
        let diagnostics = commands.compactMap(commandDiagnostic)

        return ScanResult(
            schemaVersion: HabitatMetadata.schemaVersion,
            generatorVersion: HabitatMetadata.generatorVersion,
            scannedAt: ISO8601DateFormatter().string(from: Date()),
            projectPath: projectURL.path,
            system: SystemInfo(
                operatingSystemVersion: ProcessInfo.processInfo.operatingSystemVersionString,
                architecture: hostArchitecture(),
                shell: ProcessInfo.processInfo.environment["SHELL"],
                path: pathEntries
            ),
            commands: commands,
            project: project,
            tools: ToolSummary(
                resolvedPaths: resolvedPaths,
                versions: versions
            ),
            policy: commandPolicy,
            warnings: warnings,
            diagnostics: diagnostics
        )
    }

    private func hostArchitecture() -> String {
        #if arch(arm64)
        return "arm64"
        #elseif arch(x86_64)
        return "x86_64"
        #else
        return "unknown"
        #endif
    }

    private func versionCommandSucceeded(spec: (String, String, [String]), result: CommandInfo) -> Bool {
        guard result.available, !result.timedOut, result.exitCode == 0 else {
            return false
        }

        return !versionCommandOutputIsEmpty(result)
    }

    private func commandDiagnostic(_ command: CommandInfo) -> String? {
        let label = commandLabel(command)
        if command.timedOut { return "\(label) timed out" }
        if !command.available { return "\(label) unavailable: \(command.stderr)" }
        if let exitCode = command.exitCode, exitCode != 0 {
            let detail = [command.stderr, command.stdout].first(where: { !$0.isEmpty })
            return "\(label) failed with exit code \(exitCode)\(detail.map { ": \($0)" } ?? "")"
        }
        if command.available,
           command.exitCode == 0,
           !command.timedOut,
           versionCommandOutputIsEmpty(command) {
            return "\(label) returned empty output"
        }
        return nil
    }

    private func versionCommandOutputIsEmpty(_ command: CommandInfo) -> Bool {
        [command.stdout, command.stderr]
            .allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private func projectPathIsExistingDirectory(_ projectURL: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: projectURL.path, isDirectory: &isDirectory)
            && isDirectory.boolValue
    }

    private func preferredCommands(project: ProjectInfo) -> [String] {
        switch project.packageManager {
        case "pnpm":
            return javaScriptPreferredCommands(packageManager: "pnpm", project: project)
        case "yarn":
            return javaScriptPreferredCommands(packageManager: "yarn", project: project)
        case "bun":
            return javaScriptPreferredCommands(packageManager: "bun", project: project)
        case "npm":
            return javaScriptPreferredCommands(packageManager: "npm", project: project)
        case "swiftpm":
            return ["swift test", "swift build"]
        case "go":
            return ["go test ./...", "go build ./..."]
        case "cargo":
            return ["cargo test", "cargo build"]
        case "cocoapods":
            return ["pod --version"]
        case "carthage":
            return ["carthage version"]
        case "xcodebuild":
            return xcodebuildPreferredCommands(project: project)
        case "uv":
            return hasUsableProjectVirtualEnvironment(project) ? [".venv/bin/python -m pytest"] : []
        case "python":
            if hasUsableProjectVirtualEnvironment(project) {
                return [".venv/bin/python -m pytest", ".venv/bin/python"]
            }
            if hasBrokenProjectVirtualEnvironment(project) {
                return []
            }
            return ["python3 -m pytest"]
        case "bundler":
            return []
        case "homebrew":
            return ["brew bundle check"]
        default:
            return []
        }
    }

    private func xcodebuildPreferredCommands(project: ProjectInfo) -> [String] {
        if let workspace = project.detectedFiles.first(where: { $0.hasSuffix(".xcworkspace") }) {
            return ["xcodebuild -list -workspace \(shellQuoted(workspace))"]
        }

        if let projectFile = project.detectedFiles.first(where: { $0.hasSuffix(".xcodeproj") }) {
            return ["xcodebuild -list -project \(shellQuoted(projectFile))"]
        }

        return ["xcodebuild -list"]
    }

    private func javaScriptPreferredCommands(packageManager: String, project: ProjectInfo) -> [String] {
        let knownScriptOrder = ["test", "build", "lint", "typecheck", "check"]
        let knownScripts = knownScriptOrder.filter { project.packageScripts.contains($0) }

        if !knownScripts.isEmpty {
            return knownScripts.map { javaScriptRunCommand(packageManager: packageManager, script: $0) }
        }

        if project.detectedFiles.contains("package.json") {
            return [javaScriptRunCommand(packageManager: packageManager, script: nil)]
        }

        return [packageManager]
    }

    private func javaScriptRunCommand(packageManager: String, script: String?) -> String {
        switch (packageManager, script) {
        case ("bun", "test"):
            return "bun test"
        case ("bun", let script?):
            return "bun run \(script)"
        case ("npm", let script?):
            return "npm run \(script)"
        case ("npm", nil):
            return "npm run"
        case (_, let script?):
            return "\(packageManager) run \(script)"
        case (_, nil):
            return "\(packageManager) run"
        }
    }

    private func actionablePreferredCommands(
        _ preferredCommands: [String],
        project: ProjectInfo,
        resolvedPaths: [ResolvedTool],
        askFirstCommands: [String]
    ) -> [String] {
        guard let packageManager = project.packageManager,
              let executable = executableName(forPackageManager: packageManager)
        else {
            return preferredCommands
        }

        if packageManager == "python",
           hasUsableProjectVirtualEnvironment(project),
           preferredCommands.allSatisfy({ $0.hasPrefix(".venv/bin/python") }) {
            return preferredCommands
        }

        if ["npm", "pnpm", "yarn", "bun"].contains(packageManager),
           askFirstCommands.contains("running JavaScript commands before node is available") {
            return []
        }

        if ["swiftpm", "xcodebuild"].contains(packageManager),
           askFirstCommands.contains("Swift/Xcode build commands before xcode-select -p succeeds") {
            return []
        }

        if selectedExecutableIsMissing(executable, resolvedPaths: resolvedPaths) || projectRelevantVersionCheckGuardApplies(askFirstCommands) {
            return preferredCommands.filter {
                isAvailableProjectLocalPreferredCommand($0, project: project)
            }
        }

        return preferredCommands
    }

    private func selectedExecutableIsMissing(_ executable: String, resolvedPaths: [ResolvedTool]) -> Bool {
        resolvedPaths.first(where: { $0.name == executable })?.paths.isEmpty ?? true
    }

    private func projectRelevantVersionCheckGuardApplies(_ askFirstCommands: [String]) -> Bool {
        askFirstCommands.contains { command in
            command.contains("version check succeeds")
        }
    }

    private func isAvailableProjectLocalPreferredCommand(_ command: String, project: ProjectInfo) -> Bool {
        let executable = command
            .split(whereSeparator: \.isWhitespace)
            .first
            .map(String.init)

        switch executable {
        case ".venv/bin/python":
            return hasUsableProjectVirtualEnvironment(project)
        default:
            return false
        }
    }

    private func askFirstCommands(project: ProjectInfo, projectPathIsExistingDirectory: Bool, resolvedPaths: [ResolvedTool], versions: [ToolVersion], commands commandResults: [CommandInfo]) -> [String] {
        var commands = [
            "brew install",
            "brew update",
            "brew cleanup",
            "brew autoremove",
            "brew tap",
            "brew tap-new",
            "pip install",
            "pip3 install",
            "python -m pip install",
            "python3 -m pip install",
            "pip uninstall",
            "pip3 uninstall",
            "python -m pip uninstall",
            "python3 -m pip uninstall",
            "pip download",
            "pip3 download",
            "python -m pip download",
            "python3 -m pip download",
            "pip wheel",
            "pip3 wheel",
            "python -m pip wheel",
            "python3 -m pip wheel",
            "pip index",
            "pip3 index",
            "python -m pip index",
            "python3 -m pip index",
            "pip search",
            "pip3 search",
            "python -m pip search",
            "python3 -m pip search",
            "pip cache purge",
            "pip3 cache purge",
            "python -m pip cache purge",
            "python3 -m pip cache purge",
            "pip cache remove",
            "pip3 cache remove",
            "python -m pip cache remove",
            "python3 -m pip cache remove",
            "npm install",
            "npm ci",
            "npm update",
            "npm uninstall",
            "npm remove",
            "npm rm",
        ] + PolicyReasonCatalog.npmEphemeralPackageExecutionCommands + [
            "pnpm install",
            "pnpm add",
            "pnpm update",
            "pnpm remove",
            "pnpm rm",
            "pnpm uninstall",
        ] + PolicyReasonCatalog.pnpmEphemeralPackageExecutionCommands + [
            "yarn install",
            "yarn add",
            "yarn up",
            "yarn remove",
        ] + PolicyReasonCatalog.yarnEphemeralPackageExecutionCommands + [
            "bun install",
            "bun add",
            "bun update",
            "bun remove",
        ] + PolicyReasonCatalog.bunEphemeralPackageExecutionCommands
            + PolicyReasonCatalog.packageRegistryMutationCommands + [
            "corepack enable",
            "corepack disable",
            "corepack prepare",
            "corepack install",
            "corepack use",
            "corepack up",
            "uv sync",
            "uv add",
            "uv remove",
            "uv pip install",
            "uv pip uninstall",
            "uv pip sync",
            "uv pip compile",
        ] + PolicyReasonCatalog.pythonEphemeralPackageExecutionCommands + [
            "bundle install",
            "bundle add",
            "bundle update",
            "bundle lock",
            "bundle remove",
            "brew bundle",
            "brew bundle install",
            "brew bundle cleanup",
            "brew bundle dump",
            "xcodebuild build/test/archive before selecting a scheme",
            "xcodebuild -resolvePackageDependencies",
            "xcodebuild -allowProvisioningUpdates",
            "go get",
            "go mod tidy",
            "cargo add",
            "cargo update",
            "cargo remove",
            "pod install",
            "pod update",
            "pod repo update",
            "pod deintegrate",
            "carthage bootstrap",
            "carthage update",
            "carthage checkout",
            "carthage build",
            "python -m venv",
            "python3 -m venv",
            "uv venv",
            "virtualenv",
            "creating or deleting virtual environments",
            "modifying lockfiles",
            "modifying version manager files",
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
        ] + PolicyReasonCatalog.gitHubCliMutationCommands + [
            "chmod",
            "chown",
            "chgrp",
            "sed -i",
            "perl -pi",
            "find -delete",
            "xargs rm",
            "cp",
            "cp -R",
            "cp -r",
            "mv",
            "rsync",
            "rsync --delete",
            "ditto",
            "tar -xf",
            "tar -xzf",
            "tar -xJf",
            "unzip",
            "truncate",
            "rm",
            "rm -r",
            "rm -rf"
        ]

        if !projectPathIsExistingDirectory {
            commands.insert("running project commands before project path is verified", at: 0)
        }

        if let packageManager = project.packageManager {
            for command in dependencyMutationCommands(forPackageManager: packageManager).reversed() {
                commands.removeAll { $0 == command }
                commands.insert(command, at: 0)
            }
        }

        if hasMultipleJavaScriptLockfiles(project) {
            commands.insert("dependency installs when multiple JavaScript lockfiles exist", at: 0)
        }

        if pnpmWorkspaceConflictsWithJavaScriptLockfiles(project) {
            commands.insert("dependency installs when pnpm-workspace.yaml conflicts with JavaScript lockfiles", at: 0)
        }

        if declaredPackageManagerConflictsWithSelected(project) {
            commands.insert("dependency installs when package.json packageManager conflicts with lockfiles", at: 0)
        }

        if declaredPackageManagerConflictsWithWorkspace(project) {
            commands.insert("dependency installs when package.json packageManager conflicts with project package-manager signals", at: 0)
        }

        if nodeVersionNeedsVerification(project: project, versions: versions) {
            commands.insert("dependency installs before matching active Node to project version hints", at: 0)
        }

        if pythonVersionNeedsVerification(project: project, versions: versions) {
            commands.insert("dependency installs before matching active Python to project version hints", at: 0)
        }

        if rubyVersionNeedsVerification(project: project, versions: versions) {
            commands.insert("dependency installs before matching active Ruby to project version hints", at: 0)
        }

        for command in projectRelevantVersionCheckAskFirstCommands(project: project, resolvedPaths: resolvedPaths, commands: commandResults).reversed() {
            commands.removeAll { $0 == command }
            commands.insert(command, at: 0)
        }

        if hasMixedPythonDependencyFiles(project) {
            commands.insert("dependency installs before choosing between pyproject.toml and requirements files", at: 0)
        }

        if hasUvRequirementsDependencyFiles(project) {
            commands.insert("dependency installs before choosing between uv.lock and requirements files", at: 0)
        }

        if hasSymlinkedProjectSignals(project) {
            commands.insert("dependency installs before reviewing symlinked project metadata", at: 0)
            commands.insert("following project symlinks before reviewing targets", at: 0)
        }

        if hasUnsafeRuntimeHintFiles(project) {
            commands.insert("dependency installs before verifying unsafe runtime version hint files", at: 0)
        }

        if hasUnsafePackageMetadataFields(project) {
            commands.insert("dependency installs before verifying unsafe package metadata version fields", at: 0)
        }

        if hasBrokenProjectVirtualEnvironment(project) {
            commands.insert("running Python commands before project .venv/bin/python exists", at: 0)
        }

        if packageManagerVersionNeedsVerification(project: project, versions: versions) {
            commands.insert("dependency installs before matching \(project.packageManager ?? "package manager") to packageManager version", at: 0)
        }

        if shouldWarnAboutMissingNodeRuntime(project: project, resolvedPaths: resolvedPaths) {
            commands.insert("running JavaScript commands before node is available", at: 0)
        }

        if xcodeDeveloperDirectoryNeedsVerification(project: project, versions: versions) {
            commands.insert("Swift/Xcode build commands before xcode-select -p succeeds", at: 0)
        }

        if let packageManager = project.packageManager,
           shouldWarnAboutMissingPreferredTool(project: project, packageManager: packageManager, resolvedPaths: resolvedPaths) {
            commands.insert(missingPreferredToolAskFirstCommand(packageManager: packageManager), at: 0)
        }

        let recursiveSearchCommands = recursiveSecretSearchAskFirstCommands(project)
        if !recursiveSearchCommands.isEmpty {
            commands.removeAll { recursiveSearchCommands.contains($0) }
            commands.append(contentsOf: recursiveSearchCommands.dropFirst())
            commands.insert(recursiveSearchCommands[0], at: 0)
        }

        return commands
    }

    private func dependencyMutationCommands(forPackageManager packageManager: String) -> [String] {
        switch packageManager {
        case "npm":
            return ["npm install", "npm ci", "npm update", "npm uninstall", "npm remove", "npm rm"]
        case "pnpm":
            return ["pnpm install", "pnpm add", "pnpm update", "pnpm remove", "pnpm rm", "pnpm uninstall"]
        case "yarn":
            return ["yarn install", "yarn add", "yarn up", "yarn remove"]
        case "bun":
            return ["bun install", "bun add", "bun update", "bun remove"]
        case "uv":
            return ["uv sync", "uv add", "uv remove", "uv pip install", "uv pip uninstall", "uv pip sync", "uv pip compile"]
        case "python":
            return ["pip install", "pip3 install", "python -m pip install", "python3 -m pip install", "pip uninstall", "pip3 uninstall", "python -m pip uninstall", "python3 -m pip uninstall"]
        case "bundler":
            return ["bundle install", "bundle add", "bundle update", "bundle lock", "bundle remove"]
        case "homebrew":
            return ["brew bundle", "brew bundle install", "brew bundle cleanup", "brew bundle dump", "brew update", "brew cleanup", "brew autoremove", "brew tap", "brew tap-new"]
        case "swiftpm":
            return ["swift package update", "swift package resolve"]
        case "go":
            return ["go get", "go mod tidy"]
        case "cargo":
            return ["cargo add", "cargo update", "cargo remove"]
        case "cocoapods":
            return ["pod install", "pod update", "pod repo update", "pod deintegrate"]
        case "carthage":
            return ["carthage bootstrap", "carthage update", "carthage checkout", "carthage build"]
        case "xcodebuild":
            return [
                "xcodebuild build/test/archive before selecting a scheme",
                "xcodebuild -resolvePackageDependencies",
                "xcodebuild -allowProvisioningUpdates",
            ]
        default:
            return []
        }
    }

    private func makeWarnings(project: ProjectInfo, projectPathIsExistingDirectory: Bool, resolvedPaths: [ResolvedTool], versions: [ToolVersion]) -> [String] {
        var warnings: [String] = []

        if !projectPathIsExistingDirectory {
            warnings.append("Project path is not an existing directory; verify --project before running project commands.")
        }

        if let nodeHint = project.runtimeHints.node {
            let activeNode = resolvedPaths.first(where: { $0.name == "node" })?.paths.first ?? "missing"
            let activeVersion = versions.first(where: { $0.name == "node" })?.version

            if let activeVersion, nodeVersionsDiffer(requested: nodeHint, active: activeVersion) {
                warnings.append("Active Node is \(activeVersion), but project requests \(nodeHint); ask before dependency installs (\(activeNode)).")
            } else if activeVersion == nil {
                warnings.append("Project requests Node \(nodeHint); verify active node before installs (\(activeNode)).")
            }
        }

        if let pythonHint = project.runtimeHints.python {
            let activePython = resolvedPaths.first(where: { $0.name == "python3" })?.paths.first ?? "missing"
            let activeVersion = versions.first(where: { $0.name == "python3" })?.version

            if let activeVersion, pythonVersionsDiffer(requested: pythonHint, active: activeVersion) {
                warnings.append("Active Python is \(activeVersion), but project requests \(pythonHint); ask before dependency installs (\(activePython)).")
            } else if activeVersion == nil {
                warnings.append("Project requests Python \(pythonHint); verify active python before installs (\(activePython)).")
            }
        }

        if let rubyHint = project.runtimeHints.ruby {
            let activeRuby = resolvedPaths.first(where: { $0.name == "ruby" })?.paths.first ?? "missing"
            let activeVersion = versions.first(where: { $0.name == "ruby" })?.version

            if let activeVersion, rubyVersionsDiffer(requested: rubyHint, active: activeVersion) {
                warnings.append("Active Ruby is \(activeVersion), but project requests \(rubyHint); ask before dependency installs (\(activeRuby)).")
            } else if activeVersion == nil {
                warnings.append("Project requests Ruby \(rubyHint); verify active ruby before installs (\(activeRuby)).")
            }
        }

        if let packageManager = project.packageManager,
           let requestedVersion = project.packageManagerVersion {
            let source = project.packageManagerVersionSource ?? "project metadata"
            let activeToolVersion = versions.first(where: { $0.name == packageManager })
            if let activeVersion = activeToolVersion?.version,
               activeToolVersion?.available == true,
               packageManagerVersionsDiffer(requested: requestedVersion, active: activeVersion) {
                warnings.append("Project requests \(packageManager) \(requestedVersion) via \(source); active \(packageManager) is \(activeVersion); ask before dependency installs.")
            } else if activeToolVersion?.available != true {
                warnings.append("Project requests \(packageManager) \(requestedVersion) via \(source); verify active \(packageManager) before dependency installs.")
            }
        }

        if hasSecretDotEnvFile(project) {
            warnings.append("Environment file exists; do not read .env values.")
        } else if project.detectedFiles.contains(".env.example") {
            warnings.append("Environment examples exist; do not read real .env values.")
        }

        if hasSecretEnvrcFile(project) {
            warnings.append("Direnv environment file exists; do not read .envrc values.")
        }

        if hasNetrcFile(project) {
            warnings.append("Netrc credentials file exists; do not read .netrc values.")
        }

        if hasPackageManagerAuthConfig(project) {
            warnings.append("Package manager auth config exists; do not read token values from npm, yarn, Python, Ruby, Cargo, or Composer package auth config files.")
            warnings.append("Package manager auth config files detected (\(packageManagerAuthConfigFiles(project).joined(separator: ", "))); do not read credential values.")
        }

        if hasProjectCloudOrContainerCredentialFiles(project) {
            warnings.append("Project cloud/container credential files detected (\(projectCloudOrContainerCredentialFiles(project).joined(separator: ", "))); do not read credential values or print auth tokens.")
        }

        if hasSymlinkedProjectSignals(project) {
            warnings.append("Project symlinks detected (\(project.symlinkedFiles.joined(separator: ", "))); do not follow linked metadata or secret-bearing directories before reviewing targets.")
        }

        if hasUnsafeRuntimeHintFiles(project) {
            warnings.append("Runtime version hint files were not safely read (\(project.unsafeRuntimeHintFiles.joined(separator: ", "))); verify runtimes before dependency installs.")
        }

        if hasUnsafePackageMetadataFields(project) {
            warnings.append("Package metadata version fields were not safely read (\(project.unsafePackageMetadataFields.joined(separator: ", "))); verify runtimes and package managers before dependency installs.")
        }

        if hasSSHPrivateKeyFile(project) {
            warnings.append("Private key file exists; do not read private key values.")
        }

        if project.packageManager == nil, projectPathIsExistingDirectory {
            warnings.append("No primary package manager signal detected; prefer read-only inspection before mutation.")
        }

        let lockfiles = javaScriptLockfiles(project)
        if lockfiles.count > 1 {
            warnings.append("Multiple JavaScript lockfiles detected (\(lockfiles.joined(separator: ", "))); ask before dependency installs.")
        }

        if let warning = declaredPackageManagerConflictWarning(project) {
            warnings.append(warning)
        }

        if let warning = pnpmWorkspaceLockfileConflictWarning(project) {
            warnings.append(warning)
        }

        if hasUsableProjectVirtualEnvironment(project) {
            warnings.append("Project .venv exists; use .venv/bin/python for Python commands before system python3.")
        } else if hasBrokenProjectVirtualEnvironment(project) {
            warnings.append("Project .venv exists, but executable .venv/bin/python was not found; ask before Python commands or recreating the virtual environment.")
        }

        if hasMixedPythonDependencyFiles(project) {
            warnings.append("Python dependency files include both pyproject.toml and requirements files; ask before dependency installs until the source of truth is clear.")
        }

        if hasUvRequirementsDependencyFiles(project) {
            warnings.append("Python dependency files include both uv.lock and requirements files; ask before dependency installs until the source of truth is clear.")
        }

        if xcodeDeveloperDirectoryNeedsVerification(project: project, versions: versions) {
            warnings.append("xcode-select -p did not return a developer directory; ask before Swift/Xcode build or test commands.")
        }

        if let packageManager = project.packageManager,
           shouldWarnAboutMissingPreferredTool(project: project, packageManager: packageManager, resolvedPaths: resolvedPaths) {
            warnings.append(missingPreferredToolWarning(packageManager: packageManager))
        }

        if shouldWarnAboutMissingNodeRuntime(project: project, resolvedPaths: resolvedPaths) {
            warnings.append("Project files need Node, but node was not found on PATH; ask before running JavaScript commands.")
        }

        return warnings
    }

    private func projectRelevantVersionCheckAskFirstCommands(project: ProjectInfo, resolvedPaths: [ResolvedTool], commands: [CommandInfo]) -> [String] {
        projectRelevantVersionCheckFailures(project: project, resolvedPaths: resolvedPaths, commands: commands).map {
            versionCheckAskFirstCommand(packageManager: project.packageManager, executable: $0)
        }
    }

    private func projectRelevantVersionCheckFailures(project: ProjectInfo, resolvedPaths: [ResolvedTool], commands: [CommandInfo]) -> [String] {
        guard let packageManager = project.packageManager else { return [] }

        var executables: [String] = []
        if let selectedExecutable = executableName(forPackageManager: packageManager) {
            executables.append(selectedExecutable)
        }

        if ["npm", "pnpm", "yarn", "bun"].contains(packageManager) {
            executables.append("node")
        }

        if packageManager == "bundler" {
            executables.append("ruby")
        }

        return orderedUnique(executables).filter { executable in
            toolIsResolved(executable, resolvedPaths: resolvedPaths)
                && versionCommandFailedForResolvedTool(executable, commands: commands)
        }
    }

    private func toolIsResolved(_ executable: String, resolvedPaths: [ResolvedTool]) -> Bool {
        resolvedPaths.first(where: { $0.name == executable })?.paths.isEmpty == false
    }

    private func versionCommandFailedForResolvedTool(_ executable: String, commands: [CommandInfo]) -> Bool {
        guard let command = commands.first(where: { commandInfoMatchesTool($0, executable: executable) }) else {
            return false
        }

        return command.available && (
            command.timedOut
                || command.exitCode != 0
                || (command.exitCode == 0 && versionCommandOutputIsEmpty(command))
        )
    }

    private func commandInfoMatchesTool(_ command: CommandInfo, executable: String) -> Bool {
        switch executable {
        case "carthage":
            return command.args == ["carthage", "version"]
        case "go":
            return command.args == ["go", "version"]
        case "xcodebuild":
            return command.args == ["xcodebuild", "-version"]
        default:
            return command.args == [executable, "--version"]
        }
    }

    private func versionCheckAskFirstCommand(packageManager: String?, executable: String) -> String {
        if ["npm", "pnpm", "yarn", "bun"].contains(packageManager ?? ""), executable == "node" {
            return "running JavaScript commands before node version check succeeds"
        }

        switch (packageManager, executable) {
        case ("bundler", "ruby"):
            return "running Bundler commands before ruby version check succeeds"
        case ("bundler", "bundle"):
            return "running Bundler commands before bundle version check succeeds"
        default:
            break
        }

        switch packageManager {
        case "swiftpm":
            return "running SwiftPM commands before swift version check succeeds"
        case "go":
            return "running Go commands before go version check succeeds"
        case "cargo":
            return "running Cargo commands before cargo version check succeeds"
        case "homebrew":
            return "running Homebrew Bundle commands before brew version check succeeds"
        case "cocoapods":
            return "running CocoaPods commands before pod version check succeeds"
        case "carthage":
            return "running Carthage commands before carthage version check succeeds"
        case "python":
            return "running Python commands before python3 version check succeeds"
        case "xcodebuild":
            return "running Xcode build commands before xcodebuild version check succeeds"
        default:
            return "running \(executable) commands before \(executable) version check succeeds"
        }
    }

    private func hasProjectVirtualEnvironment(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains(".venv")
    }

    private func hasUsableProjectVirtualEnvironment(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains(".venv/bin/python")
    }

    private func hasBrokenProjectVirtualEnvironment(_ project: ProjectInfo) -> Bool {
        hasProjectVirtualEnvironment(project) && !hasUsableProjectVirtualEnvironment(project)
    }

    private func hasMixedPythonDependencyFiles(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains("pyproject.toml")
            && (project.detectedFiles.contains("requirements.txt") || project.detectedFiles.contains("requirements-dev.txt"))
    }

    private func hasUvRequirementsDependencyFiles(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains("uv.lock")
            && (project.detectedFiles.contains("requirements.txt") || project.detectedFiles.contains("requirements-dev.txt"))
    }

    private func hasSymlinkedProjectSignals(_ project: ProjectInfo) -> Bool {
        !project.symlinkedFiles.isEmpty
    }

    private func hasUnsafeRuntimeHintFiles(_ project: ProjectInfo) -> Bool {
        !project.unsafeRuntimeHintFiles.isEmpty
    }

    private func hasUnsafePackageMetadataFields(_ project: ProjectInfo) -> Bool {
        !project.unsafePackageMetadataFields.isEmpty
    }

    private func hasSecretDotEnvFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            isSecretDotEnvFile(file)
        }
    }

    private func secretFileAccessForbiddenCommands(_ project: ProjectInfo) -> [String] {
        secretValueFiles(project).flatMap { file in
            var commands = [
                "cat \(file)",
                "less \(file)",
                "head \(file)",
                "tail \(file)",
                "grep <pattern> \(file)",
                "grep -n <pattern> \(file)",
                "rg <pattern> \(file)",
                "rg -n <pattern> \(file)",
                "rg --line-number <pattern> \(file)",
                "git grep <pattern> -- \(file)",
                "git grep -n <pattern> -- \(file)",
                "git grep <pattern> \(file)",
                "git grep -n <pattern> \(file)",
                "sed -n <range> \(file)",
                "awk <program> \(file)",
                "diff \(file) <other>",
                "cmp \(file) <other>",
                "git diff -- \(file)",
                "git diff --cached -- \(file)",
                "git diff --staged -- \(file)",
                "git diff HEAD -- \(file)",
                "git diff <rev> -- \(file)",
                "git diff <rev>..<rev> -- \(file)",
                "git log -p -- \(file)",
                "git blame \(file)",
                "git blame -- \(file)",
                "git annotate \(file)",
                "git annotate -- \(file)",
                "git show -- \(file)",
                "git show HEAD -- \(file)",
                "git show <rev> -- \(file)",
                "git show :\(file)",
                "git show HEAD:\(file)",
                "git show <rev>:\(file)",
                "git cat-file -p :\(file)",
                "git cat-file -p HEAD:\(file)",
                "git cat-file -p <rev>:\(file)",
                "git checkout -- \(file)",
                "git checkout HEAD -- \(file)",
                "git checkout <rev> -- \(file)",
                "git restore -- \(file)",
                "git restore --staged -- \(file)",
                "git restore --worktree -- \(file)",
                "git restore --source HEAD -- \(file)",
                "git restore --source <rev> -- \(file)",
                "bat \(file)",
                "nl -ba \(file)",
                "base64 \(file)",
                "xxd \(file)",
                "hexdump -C \(file)",
                "strings \(file)",
                "open \(file)",
                "code \(file)",
                "vim \(file)",
                "vi \(file)",
                "nano \(file)",
                "emacs \(file)",
                "cp \(file) <destination>",
                "cp -R \(file) <destination>",
                "cp -r \(file) <destination>",
                "mv \(file) <destination>",
                "rsync \(file) <destination>",
                "rsync -a \(file) <destination>",
                "scp \(file) <destination>",
                "curl -F file=@\(file) <url>",
                "curl --data-binary @\(file) <url>",
                "curl -T \(file) <url>",
                "wget --post-file=\(file) <url>",
                "tar -cf <archive> \(file)",
                "tar -czf <archive> \(file)",
                "tar -cjf <archive> \(file)",
                "tar -cJf <archive> \(file)",
                "zip <archive> \(file)",
                "zip -r <archive> \(file)",
            ]

            if isSSHPrivateKeyFilename(file) {
                commands += [
                    "ssh-add \(file)",
                    "ssh-add -K \(file)",
                    "ssh-add --apple-use-keychain \(file)",
                    "ssh-keygen -y -f \(file)",
                ]
            }

            return commands
        }
    }

    private func secretEnvironmentFileLoadForbiddenCommands(_ project: ProjectInfo) -> [String] {
        var commands = secretEnvironmentValueFiles(project).flatMap { file in
            [
                "source \(file)",
                ". \(file)",
            ]
        }

        if hasSecretEnvrcFile(project) {
            commands += [
                "direnv allow",
                "direnv reload",
                "direnv export <shell>",
                "direnv exec . <command>",
            ]
        }

        return commands
    }

    private func secretEnvironmentRenderForbiddenCommands(_ project: ProjectInfo) -> [String] {
        let files = secretEnvironmentValueFiles(project)
        guard !files.isEmpty else { return [] }

        return [
            "render Docker Compose config when secret environment files exist",
            "docker compose config",
            "docker-compose config",
            "docker compose config --environment",
            "docker-compose config --environment",
        ] + files.flatMap { file in
            [
                "docker compose --env-file \(file) config",
                "docker-compose --env-file \(file) config",
            ]
        }
    }

    private func recursiveSecretSearchAskFirstCommands(_ project: ProjectInfo) -> [String] {
        guard !secretValueFiles(project).isEmpty else { return [] }

        return [
            "recursive project search without excluding secret-bearing files",
            "grep -R <pattern> .",
            "grep -r <pattern> .",
            "grep -R -n <pattern> .",
            "grep -r -n <pattern> .",
            "find . -type f -exec grep <pattern> {} +",
            "find . -type f -exec grep -n <pattern> {} +",
            "find . -type f -print0 | xargs -0 grep <pattern>",
            "find . -type f -print0 | xargs -0 grep -n <pattern>",
            "rg <pattern>",
            "rg -n <pattern>",
            "rg <pattern> .",
            "rg -n <pattern> .",
            "rg --line-number <pattern> .",
            "rg --hidden <pattern> .",
            "rg --hidden -n <pattern> .",
            "rg --no-ignore <pattern> .",
            "rg --no-ignore -n <pattern> .",
            "rg -u <pattern> .",
            "rg -uu <pattern> .",
            "rg -uuu <pattern> .",
            "git grep <pattern>",
            "git grep -n <pattern>",
            "git grep <pattern> -- .",
            "git grep -n <pattern> -- .",
        ]
    }

    private func secretProjectBulkExportForbiddenCommands(_ project: ProjectInfo) -> [String] {
        guard !secretValueFiles(project).isEmpty else { return [] }

        return [
            "project copy, sync, or archive without excluding secret-bearing files",
            "cp -R . <destination>",
            "cp -r . <destination>",
            "rsync -a . <destination>",
            "rsync -av . <destination>",
            "ditto . <destination>",
            "tar -cf <archive> .",
            "tar -czf <archive> .",
            "tar -cjf <archive> .",
            "tar -cJf <archive> .",
            "zip -r <archive> .",
            "git archive HEAD",
            "git archive --format=tar HEAD",
            "git archive --format=zip HEAD",
            "git archive -o <archive> HEAD",
            "git archive --output <archive> HEAD",
            "git archive --output=<archive> HEAD",
        ]
    }

    private func secretEnvironmentValueFiles(_ project: ProjectInfo) -> [String] {
        project.detectedFiles
            .filter { file in
                isSecretDotEnvFile(file) || isSecretEnvrcFile(file)
            }
            .sorted()
    }

    private func secretValueFiles(_ project: ProjectInfo) -> [String] {
        project.detectedFiles
            .filter { file in
                isSecretDotEnvFile(file)
                    || isSecretEnvrcFile(file)
                    || file == ".netrc"
                    || isPackageManagerAuthConfigFile(file)
                    || isProjectCloudOrContainerCredentialFile(file)
                    || isSSHPrivateKeyFilename(file)
            }
            .sorted()
    }

    private func isSecretDotEnvFile(_ file: String) -> Bool {
        file == ".env" || (file.hasPrefix(".env.") && file != ".env.example")
    }

    private func hasSecretEnvrcFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            isSecretEnvrcFile(file)
        }
    }

    private func isSecretEnvrcFile(_ file: String) -> Bool {
        file == ".envrc" || (file.hasPrefix(".envrc.") && file != ".envrc.example")
    }

    private func hasPackageManagerAuthConfig(_ project: ProjectInfo) -> Bool {
        !packageManagerAuthConfigFiles(project).isEmpty
    }

    private func packageManagerAuthConfigFiles(_ project: ProjectInfo) -> [String] {
        project.detectedFiles
            .filter(isPackageManagerAuthConfigFile)
            .sorted()
    }

    private func isPackageManagerAuthConfigFile(_ file: String) -> Bool {
        file == ".npmrc"
            || file == ".pnpmrc"
            || file == ".yarnrc"
            || file == ".yarnrc.yml"
            || file == ".pypirc"
            || file == "pip.conf"
            || file == ".gem/credentials"
            || file == ".bundle/config"
            || file == ".cargo/credentials.toml"
            || file == ".cargo/credentials"
            || file == "auth.json"
            || file == ".composer/auth.json"
    }

    private func hasProjectCloudOrContainerCredentialFiles(_ project: ProjectInfo) -> Bool {
        !projectCloudOrContainerCredentialFiles(project).isEmpty
    }

    private func projectCloudOrContainerCredentialFiles(_ project: ProjectInfo) -> [String] {
        project.detectedFiles
            .filter(isProjectCloudOrContainerCredentialFile)
            .sorted()
    }

    private func isProjectCloudOrContainerCredentialFile(_ file: String) -> Bool {
        file == ".aws/credentials"
            || file == ".aws/config"
            || file == ".config/gcloud/application_default_credentials.json"
            || file == ".docker/config.json"
            || file == ".kube/config"
    }

    private func hasNetrcFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains(".netrc")
    }

    private func hasSSHPrivateKeyFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            isSSHPrivateKeyFilename(file)
        }
    }

    private func isSSHPrivateKeyFilename(_ file: String) -> Bool {
        let basename = URL(fileURLWithPath: file).lastPathComponent.lowercased()
        guard !basename.hasSuffix(".pub") else { return false }

        if ["id_rsa", "id_dsa", "id_ecdsa", "id_ed25519"].contains(basename) {
            return true
        }

        return [".pem", ".key", ".p8", ".p12", ".ppk"].contains { basename.hasSuffix($0) }
    }

    private func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }

    private func hasMultipleJavaScriptLockfiles(_ project: ProjectInfo) -> Bool {
        javaScriptLockfiles(project).count > 1
    }

    private func pnpmWorkspaceConflictsWithJavaScriptLockfiles(_ project: ProjectInfo) -> Bool {
        guard project.packageManager == "pnpm",
              project.detectedFiles.contains("pnpm-workspace.yaml"),
              !project.detectedFiles.contains("pnpm-lock.yaml")
        else {
            return false
        }

        return !javaScriptLockfiles(project).isEmpty
    }

    private func pnpmWorkspaceLockfileConflictWarning(_ project: ProjectInfo) -> String? {
        guard pnpmWorkspaceConflictsWithJavaScriptLockfiles(project) else { return nil }
        let lockfiles = javaScriptLockfiles(project).joined(separator: ", ")
        return "pnpm-workspace.yaml selects pnpm, but JavaScript lockfiles also include \(lockfiles); ask before dependency installs."
    }

    private func javaScriptLockfiles(_ project: ProjectInfo) -> [String] {
        ["package-lock.json", "npm-shrinkwrap.json", "pnpm-lock.yaml", "yarn.lock", "bun.lock", "bun.lockb"].filter {
            project.detectedFiles.contains($0)
        }
    }

    private func declaredPackageManagerConflictsWithSelected(_ project: ProjectInfo) -> Bool {
        guard let declaredPackageManager = project.declaredPackageManager,
              let selectedPackageManager = project.packageManager,
              ["npm", "pnpm", "yarn", "bun"].contains(selectedPackageManager)
        else {
            return false
        }

        return declaredPackageManager != selectedPackageManager
            && selectedPackageManagerHasLockfile(project)
    }

    private func declaredPackageManagerConflictsWithWorkspace(_ project: ProjectInfo) -> Bool {
        guard let declaredPackageManager = project.declaredPackageManager,
              let selectedPackageManager = project.packageManager,
              selectedPackageManager == "pnpm",
              project.detectedFiles.contains("pnpm-workspace.yaml")
        else {
            return false
        }

        return declaredPackageManager != selectedPackageManager
            && !selectedPackageManagerHasLockfile(project)
    }

    private func declaredPackageManagerConflictWarning(_ project: ProjectInfo) -> String? {
        guard declaredPackageManagerConflictsWithSelected(project),
              let declaredPackageManager = project.declaredPackageManager,
              let selectedPackageManager = project.packageManager
        else {
            return declaredPackageManagerWorkspaceConflictWarning(project)
        }

        return "package.json requests \(declaredPackageManager), but project lockfiles select \(selectedPackageManager); ask before dependency installs."
    }

    private func declaredPackageManagerWorkspaceConflictWarning(_ project: ProjectInfo) -> String? {
        guard declaredPackageManagerConflictsWithWorkspace(project),
              let declaredPackageManager = project.declaredPackageManager,
              let selectedPackageManager = project.packageManager
        else {
            return nil
        }

        return "package.json requests \(declaredPackageManager), but pnpm-workspace.yaml selects \(selectedPackageManager); ask before dependency installs."
    }

    private func selectedPackageManagerHasLockfile(_ project: ProjectInfo) -> Bool {
        switch project.packageManager {
        case "npm":
            return project.detectedFiles.contains("package-lock.json")
                || project.detectedFiles.contains("npm-shrinkwrap.json")
        case "pnpm":
            return project.detectedFiles.contains("pnpm-lock.yaml")
        case "yarn":
            return project.detectedFiles.contains("yarn.lock")
        case "bun":
            return project.detectedFiles.contains("bun.lock") || project.detectedFiles.contains("bun.lockb")
        default:
            return false
        }
    }

    private func projectSpecificVersionCommandSpecs(project: ProjectInfo, resolvedPaths: [ResolvedTool]) -> [(String, String, [String])] {
        switch project.packageManager {
        case "npm", "pnpm", "yarn", "bun":
            guard let packageManager = project.packageManager,
                  toolIsResolved(packageManager, resolvedPaths: resolvedPaths)
            else {
                return []
            }
            return [(packageManager, "/usr/bin/env", [packageManager, "--version"])]
        case "bundler":
            guard toolIsResolved("bundle", resolvedPaths: resolvedPaths) else { return [] }
            return [("bundle", "/usr/bin/env", ["bundle", "--version"])]
        case "homebrew":
            guard toolIsResolved("brew", resolvedPaths: resolvedPaths) else { return [] }
            return [("brew", "/usr/bin/env", ["brew", "--version"])]
        case "cocoapods":
            guard toolIsResolved("pod", resolvedPaths: resolvedPaths) else { return [] }
            return [("pod", "/usr/bin/env", ["pod", "--version"])]
        case "carthage":
            guard toolIsResolved("carthage", resolvedPaths: resolvedPaths) else { return [] }
            return [("carthage", "/usr/bin/env", ["carthage", "version"])]
        default:
            return []
        }
    }

    private func shouldWarnAboutMissingPreferredTool(project: ProjectInfo, packageManager: String, resolvedPaths: [ResolvedTool]) -> Bool {
        if packageManager == "python", hasUsableProjectVirtualEnvironment(project) {
            return false
        }

        guard let toolName = executableName(forPackageManager: packageManager) else {
            return false
        }

        return resolvedPaths.first(where: { $0.name == toolName })?.paths.isEmpty ?? true
    }

    private func shouldWarnAboutMissingNodeRuntime(project: ProjectInfo, resolvedPaths: [ResolvedTool]) -> Bool {
        guard let packageManager = project.packageManager,
              ["npm", "pnpm", "yarn", "bun"].contains(packageManager)
        else {
            return false
        }

        return resolvedPaths.first(where: { $0.name == "node" })?.paths.isEmpty ?? true
    }

    private func xcodeDeveloperDirectoryNeedsVerification(project: ProjectInfo, versions: [ToolVersion]) -> Bool {
        guard let packageManager = project.packageManager,
              ["swiftpm", "xcodebuild"].contains(packageManager)
        else {
            return false
        }

        return versions.first(where: { $0.name == "xcode-select" })?.available != true
    }

    private func missingPreferredToolAskFirstCommand(packageManager: String) -> String {
        switch packageManager {
        case "npm", "pnpm", "yarn", "bun", "uv":
            return "running \(packageManager) commands before \(packageManager) is available"
        case "bundler":
            return "running Bundler commands before bundle is available"
        case "swiftpm":
            return "running SwiftPM commands before swift is available"
        case "go":
            return "running Go commands before go is available"
        case "cargo":
            return "running Cargo commands before cargo is available"
        case "homebrew":
            return "running Homebrew Bundle commands before brew is available"
        case "cocoapods":
            return "running CocoaPods commands before pod is available"
        case "carthage":
            return "running Carthage commands before carthage is available"
        case "xcodebuild":
            return "running Xcode build commands before xcodebuild is available"
        case "python":
            return "running Python commands before python3 is available"
        default:
            return "substituting another package manager for \(packageManager)"
        }
    }

    private func missingPreferredToolWarning(packageManager: String) -> String {
        switch packageManager {
        case "npm", "pnpm", "yarn", "bun", "uv":
            return "Project files prefer \(packageManager), but \(packageManager) was not found on PATH; ask before running \(packageManager) commands or substituting another package manager."
        case "bundler":
            return "Project files prefer Bundler, but bundle was not found on PATH; ask before running Bundler commands."
        case "swiftpm":
            return "Project files prefer SwiftPM, but swift was not found on PATH; ask before running SwiftPM commands."
        case "go":
            return "Project files prefer Go, but go was not found on PATH; ask before running Go commands."
        case "cargo":
            return "Project files prefer Cargo, but cargo was not found on PATH; ask before running Cargo commands."
        case "homebrew":
            return "Project files include Brewfile, but brew was not found on PATH; ask before running Homebrew Bundle commands."
        case "cocoapods":
            return "Project files prefer CocoaPods, but pod was not found on PATH; ask before running CocoaPods commands."
        case "carthage":
            return "Project files prefer Carthage, but carthage was not found on PATH; ask before running Carthage commands."
        case "xcodebuild":
            return "Project files prefer xcodebuild, but xcodebuild was not found on PATH; ask before running Xcode build commands."
        case "python":
            return "Project files prefer Python, but python3 was not found on PATH; ask before running Python commands."
        default:
            return "Project files prefer \(packageManager), but \(packageManager) was not found on PATH; ask before substituting another package manager."
        }
    }

    private func nodeVersionNeedsVerification(project: ProjectInfo, versions: [ToolVersion]) -> Bool {
        guard let nodeHint = project.runtimeHints.node else {
            return false
        }

        guard let activeToolVersion = versions.first(where: { $0.name == "node" }),
              activeToolVersion.available,
              let activeVersion = activeToolVersion.version
        else {
            return true
        }

        return nodeVersionsDiffer(requested: nodeHint, active: activeVersion)
    }

    private func pythonVersionNeedsVerification(project: ProjectInfo, versions: [ToolVersion]) -> Bool {
        guard let pythonHint = project.runtimeHints.python else {
            return false
        }

        guard let activeToolVersion = versions.first(where: { $0.name == "python3" }),
              activeToolVersion.available,
              let activeVersion = activeToolVersion.version
        else {
            return true
        }

        return pythonVersionsDiffer(requested: pythonHint, active: activeVersion)
    }

    private func rubyVersionNeedsVerification(project: ProjectInfo, versions: [ToolVersion]) -> Bool {
        guard let rubyHint = project.runtimeHints.ruby else {
            return false
        }

        guard let activeToolVersion = versions.first(where: { $0.name == "ruby" }),
              activeToolVersion.available,
              let activeVersion = activeToolVersion.version
        else {
            return true
        }

        return rubyVersionsDiffer(requested: rubyHint, active: activeVersion)
    }

    private func packageManagerVersionNeedsVerification(project: ProjectInfo, versions: [ToolVersion]) -> Bool {
        guard let packageManager = project.packageManager,
              let packageManagerVersion = project.packageManagerVersion
        else {
            return false
        }

        guard let activeToolVersion = versions.first(where: { $0.name == packageManager }),
              activeToolVersion.available,
              let activeVersion = activeToolVersion.version
        else {
            return true
        }

        return packageManagerVersionsDiffer(requested: packageManagerVersion, active: activeVersion)
    }

    private func executableName(forPackageManager packageManager: String) -> String? {
        switch packageManager {
        case "npm", "pnpm", "yarn", "bun", "uv", "xcodebuild":
            return packageManager
        case "bundler":
            return "bundle"
        case "swiftpm":
            return "swift"
        case "go":
            return "go"
        case "cargo":
            return "cargo"
        case "homebrew":
            return "brew"
        case "cocoapods":
            return "pod"
        case "carthage":
            return "carthage"
        case "python":
            return "python3"
        default:
            return nil
        }
    }

    private func versionsDiffer(requested: String, active: String) -> Bool {
        guard let requestedMajor = majorVersion(from: requested),
              let activeMajor = majorVersion(from: active)
        else {
            return false
        }

        return requestedMajor != activeMajor
    }

    private func commandLabel(_ command: CommandInfo) -> String {
        if command.name == "/usr/bin/xcode-select", command.args == ["-p"] {
            return "xcode-select -p"
        }

        return command.args.joined(separator: " ")
    }

    private func shellQuoted(_ value: String) -> String {
        if value.allSatisfy({ $0.isLetter || $0.isNumber || "-_./".contains($0) }) {
            return value
        }

        return "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    private func nodeVersionsDiffer(requested: String, active: String) -> Bool {
        if let satisfiesRange = nodeSatisfiesComparatorRange(requested: requested, active: active) {
            return !satisfiesRange
        }

        return versionsDiffer(requested: requested, active: active)
    }

    private func nodeSatisfiesComparatorRange(requested: String, active: String) -> Bool? {
        guard let activeVersion = semanticVersionComponents(from: active) else {
            return nil
        }

        let alternatives = requested
            .components(separatedBy: "||")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if alternatives.count > 1 {
            var sawUnsupportedAlternative = false

            for alternative in alternatives {
                guard let satisfies = nodeSatisfiesSingleComparatorRange(requested: alternative, activeVersion: activeVersion) else {
                    sawUnsupportedAlternative = true
                    continue
                }

                if satisfies {
                    return true
                }
            }

            return sawUnsupportedAlternative ? nil : false
        }

        return nodeSatisfiesSingleComparatorRange(requested: requested, activeVersion: activeVersion)
    }

    private func nodeSatisfiesSingleComparatorRange(requested: String, activeVersion: [Int]) -> Bool? {
        let tokens = comparatorTokens(from: requested)
        guard !tokens.isEmpty else { return nil }

        var sawComparator = false
        for token in tokens {
            guard let comparator = comparator(from: token) else {
                continue
            }

            sawComparator = true
            guard let requestedVersion = semanticVersionComponents(from: token) else {
                return nil
            }

            let comparison = compareSemanticVersions(activeVersion, requestedVersion)
            switch comparator {
            case ">":
                if comparison <= 0 { return false }
            case ">=":
                if comparison < 0 { return false }
            case "<":
                if comparison >= 0 { return false }
            case "<=":
                if comparison > 0 { return false }
            case "=":
                if comparison != 0 { return false }
            default:
                return nil
            }
        }

        return sawComparator ? true : nil
    }

    private func comparatorTokens(from value: String) -> [String] {
        let rawTokens = value
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
        var tokens: [String] = []
        var index = 0

        while index < rawTokens.count {
            let token = rawTokens[index]
            if [">", ">=", "<", "<=", "="].contains(token),
               index + 1 < rawTokens.count {
                tokens.append(token + rawTokens[index + 1])
                index += 2
            } else {
                tokens.append(token)
                index += 1
            }
        }

        return tokens
    }

    private func comparator(from token: String) -> String? {
        for comparator in [">=", "<=", ">", "<", "="] where token.hasPrefix(comparator) {
            return comparator
        }

        return nil
    }

    private func semanticVersionComponents(from value: String) -> [Int]? {
        let numericVersion = value.drop { !$0.isNumber }
            .prefix { $0.isNumber || $0 == "." }
        let components = numericVersion
            .split(separator: ".")
            .prefix(3)
            .compactMap { Int($0) }
        guard !components.isEmpty else { return nil }

        return Array(components) + Array(repeating: 0, count: max(0, 3 - components.count))
    }

    private func compareSemanticVersions(_ left: [Int], _ right: [Int]) -> Int {
        for index in 0..<min(left.count, right.count) {
            if left[index] < right[index] { return -1 }
            if left[index] > right[index] { return 1 }
        }

        return 0
    }

    private func pythonVersionsDiffer(requested: String, active: String) -> Bool {
        guard let requestedComponents = versionComponents(from: requested),
              let activeComponents = versionComponents(from: active)
        else {
            return false
        }

        return requestedComponents != activeComponents
    }

    private func rubyVersionsDiffer(requested: String, active: String) -> Bool {
        guard let requestedComponents = versionComponents(from: requested),
              let activeComponents = versionComponents(from: active)
        else {
            return false
        }

        return requestedComponents != activeComponents
    }

    private func packageManagerVersionsDiffer(requested: String, active: String) -> Bool {
        guard let requestedComponents = versionComponents(from: requested, limit: 3),
              let activeComponents = versionComponents(from: active, limit: 3),
              activeComponents.count >= requestedComponents.count
        else {
            return false
        }

        return Array(activeComponents.prefix(requestedComponents.count)) != requestedComponents
    }

    private func versionComponents(from value: String, limit: Int = 2) -> [Int]? {
        let numericVersion = value.drop { !$0.isNumber }
            .prefix { $0.isNumber || $0 == "." }
        let components = numericVersion
            .split(separator: ".")
            .prefix(limit)
            .compactMap { Int($0) }
        return components.isEmpty ? nil : Array(components)
    }

    private func majorVersion(from value: String) -> Int? {
        let digits = value
            .drop { !$0.isNumber }
            .prefix { $0.isNumber }
        return Int(digits)
    }
}
