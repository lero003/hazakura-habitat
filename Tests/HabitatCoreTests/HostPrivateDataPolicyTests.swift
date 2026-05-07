import Testing
import Foundation
@testable import HabitatCore

struct HostPrivateDataPolicyTests {
    @Test
    func scanForbidsEnvironmentVariableDumpCommands() throws {
        let projectURL = try makeProject(files: [
            "README.md": "# Demo\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
            "dump environment variables",
            "env",
            "printenv",
            "export -p",
            "set",
            "declare -x",
        ]

        for command in commands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Do not dump environment variables."))
        #expect(!context.contains("Do not run `dump environment variables`."))

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func scanExplainsHostPrivateDataCommandsWithSpecificReasonCode() throws {
        let projectURL = try makeProject(files: [
            "README.md": "# Demo\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commandReasonCodes = Dictionary(uniqueKeysWithValues: result.policy.commandReasons.map { ($0.command, $0.reasonCode) })

        for command in PolicyReasonCatalog.hostPrivateDataCommands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
            #expect(commandReasonCodes[command] == "host_private_data", "Expected \(command) to explain host-private data risk")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in ["pbpaste", "history", "cat ~/Library/Safari/History.db", "open ~/Library/Mail"] {
            #expect(policy.contains("`\(command)` (`host_private_data`)"), "Expected command_policy.md to annotate \(command) with host_private_data")
        }
    }

    @Test
    func scanForbidsClipboardReadCommands() throws {
        let projectURL = try makeProject(files: [
            "README.md": "# Demo\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
            "read clipboard contents",
            "pbpaste",
            "osascript -e 'the clipboard'",
            "osascript -e 'the clipboard as text'",
            "osascript -e \"the clipboard\"",
            "osascript -e \"the clipboard as text\"",
        ]

        for command in commands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Do not read clipboard contents."))
        #expect(!context.contains("Do not run `read clipboard contents`."))

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func scanForbidsShellHistoryReadCommands() throws {
        let projectURL = try makeProject(files: [
            "README.md": "# Demo\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
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
        ]

        for command in commands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Do not read shell history."))
        #expect(!context.contains("Do not run `read shell history`."))

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func scanForbidsBrowserAndMailDataReadCommands() throws {
        let projectURL = try makeProject(files: [
            "README.md": "# Demo\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
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
        ]

        for command in commands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Do not inspect browser profiles, cookies, history, or local mail data."))
        #expect(!context.contains("Do not run `read browser or mail data`."))

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func scanForbidsHomeSSHPrivateKeyReadCommands() throws {
        let projectURL = try makeProject(files: [
            "README.md": "# Demo\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let privateKeyFiles = [
            "~/.ssh/id_rsa",
            "~/.ssh/id_dsa",
            "~/.ssh/id_ecdsa",
            "~/.ssh/id_ed25519",
        ]

        for file in privateKeyFiles {
            for command in ["cat \(file)", "less \(file)", "head \(file)", "tail \(file)", "grep <pattern> \(file)", "rg <pattern> \(file)", "sed -n <range> \(file)", "awk <program> \(file)", "diff \(file) <other>", "cmp \(file) <other>", "bat \(file)", "nl -ba \(file)", "base64 \(file)", "xxd \(file)", "hexdump -C \(file)", "strings \(file)", "open \(file)", "code \(file)", "vim \(file)", "vi \(file)", "nano \(file)", "emacs \(file)", "cp \(file) <destination>", "cp -R \(file) <destination>", "cp -r \(file) <destination>", "mv \(file) <destination>", "rsync \(file) <destination>", "rsync -a \(file) <destination>", "scp \(file) <destination>", "curl -F file=@\(file) <url>", "curl --data-binary @\(file) <url>", "curl -T \(file) <url>", "wget --post-file=\(file) <url>", "tar -cf <archive> \(file)", "tar -czf <archive> \(file)", "tar -cjf <archive> \(file)", "tar -cJf <archive> \(file)", "zip <archive> \(file)", "zip -r <archive> \(file)"] {
                #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
            }

            for command in ["ssh-add \(file)", "ssh-add -K \(file)", "ssh-add --apple-use-keychain \(file)", "ssh-keygen -y -f \(file)"] {
                #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
            }
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, archive, or load private keys."))
        #expect(!context.contains("Do not run `read private keys`."))

        for file in privateKeyFiles {
            #expect(policy.contains("`cat \(file)`"), "Expected command_policy.md to forbid cat \(file)")
            #expect(policy.contains("`grep <pattern> \(file)`"), "Expected command_policy.md to forbid grep <pattern> \(file)")
            #expect(policy.contains("`rg <pattern> \(file)`"), "Expected command_policy.md to forbid rg <pattern> \(file)")
            #expect(policy.contains("`sed -n <range> \(file)`"), "Expected command_policy.md to forbid sed -n <range> \(file)")
            #expect(policy.contains("`awk <program> \(file)`"), "Expected command_policy.md to forbid awk <program> \(file)")
            #expect(policy.contains("`diff \(file) <other>`"), "Expected command_policy.md to forbid diff \(file)")
            #expect(policy.contains("`cmp \(file) <other>`"), "Expected command_policy.md to forbid cmp \(file)")
            #expect(policy.contains("`bat \(file)`"), "Expected command_policy.md to forbid bat \(file)")
            #expect(policy.contains("`nl -ba \(file)`"), "Expected command_policy.md to forbid nl -ba \(file)")
            #expect(policy.contains("`base64 \(file)`"), "Expected command_policy.md to forbid base64 \(file)")
            #expect(policy.contains("`xxd \(file)`"), "Expected command_policy.md to forbid xxd \(file)")
            #expect(policy.contains("`hexdump -C \(file)`"), "Expected command_policy.md to forbid hexdump -C \(file)")
            #expect(policy.contains("`strings \(file)`"), "Expected command_policy.md to forbid strings \(file)")
            #expect(policy.contains("`open \(file)`"), "Expected command_policy.md to forbid open \(file)")
            #expect(policy.contains("`code \(file)`"), "Expected command_policy.md to forbid code \(file)")
            #expect(policy.contains("`vim \(file)`"), "Expected command_policy.md to forbid vim \(file)")
            #expect(policy.contains("`nano \(file)`"), "Expected command_policy.md to forbid nano \(file)")
            #expect(policy.contains("`cp \(file) <destination>`"), "Expected command_policy.md to forbid cp \(file)")
            #expect(policy.contains("`mv \(file) <destination>`"), "Expected command_policy.md to forbid mv \(file)")
            #expect(policy.contains("`rsync \(file) <destination>`"), "Expected command_policy.md to forbid rsync \(file)")
            #expect(policy.contains("`scp \(file) <destination>`"), "Expected command_policy.md to forbid scp \(file)")
            #expect(policy.contains("`curl -F file=@\(file) <url>`"), "Expected command_policy.md to forbid curl form upload \(file)")
            #expect(policy.contains("`curl --data-binary @\(file) <url>`"), "Expected command_policy.md to forbid curl data upload \(file)")
            #expect(policy.contains("`curl -T \(file) <url>`"), "Expected command_policy.md to forbid curl transfer upload \(file)")
            #expect(policy.contains("`wget --post-file=\(file) <url>`"), "Expected command_policy.md to forbid wget post-file \(file)")
            #expect(policy.contains("`tar -cf <archive> \(file)`"), "Expected command_policy.md to forbid tar -cf \(file)")
            #expect(policy.contains("`tar -czf <archive> \(file)`"), "Expected command_policy.md to forbid tar -czf \(file)")
            #expect(policy.contains("`tar -cjf <archive> \(file)`"), "Expected command_policy.md to forbid tar -cjf \(file)")
            #expect(policy.contains("`tar -cJf <archive> \(file)`"), "Expected command_policy.md to forbid tar -cJf \(file)")
            #expect(policy.contains("`zip <archive> \(file)`"), "Expected command_policy.md to forbid zip \(file)")
            #expect(policy.contains("`zip -r <archive> \(file)`"), "Expected command_policy.md to forbid zip -r \(file)")
            #expect(policy.contains("`ssh-add \(file)`"), "Expected command_policy.md to forbid ssh-add \(file)")
            #expect(policy.contains("`ssh-add --apple-use-keychain \(file)`"), "Expected command_policy.md to forbid ssh-add --apple-use-keychain \(file)")
            #expect(policy.contains("`ssh-keygen -y -f \(file)`"), "Expected command_policy.md to forbid ssh-keygen -y -f \(file)")
        }
    }
}
