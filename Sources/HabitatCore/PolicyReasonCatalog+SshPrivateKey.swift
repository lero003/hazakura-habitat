extension PolicyReasonCatalog {
    private static let sshPrivateKeyPaths = [
        "~/.ssh/id_rsa",
        "~/.ssh/id_dsa",
        "~/.ssh/id_ecdsa",
        "~/.ssh/id_ed25519",
    ]

    private static let sshPrivateKeyCommandTemplates = [
        "cat %@",
        "less %@",
        "bat %@",
        "nl -ba %@",
        "base64 %@",
        "xxd %@",
        "hexdump -C %@",
        "strings %@",
        "head %@",
        "tail %@",
        "grep <pattern> %@",
        "rg <pattern> %@",
        "sed -n <range> %@",
        "awk <program> %@",
        "diff %@ <other>",
        "cmp %@ <other>",
        "open %@",
        "code %@",
        "vim %@",
        "vi %@",
        "nano %@",
        "emacs %@",
        "cp %@ <destination>",
        "cp -R %@ <destination>",
        "cp -r %@ <destination>",
        "mv %@ <destination>",
        "rsync %@ <destination>",
        "rsync -a %@ <destination>",
        "scp %@ <destination>",
        "curl -F file=@%@ <url>",
        "curl --data-binary @%@ <url>",
        "curl -T %@ <url>",
        "wget --post-file=%@ <url>",
        "tar -cf <archive> %@",
        "tar -czf <archive> %@",
        "tar -cjf <archive> %@",
        "tar -cJf <archive> %@",
        "zip <archive> %@",
        "zip -r <archive> %@",
        "ssh-add %@",
        "ssh-add -K %@",
        "ssh-add --apple-use-keychain %@",
        "ssh-keygen -y -f %@",
    ]

    private static let sshPrivateKeyCommandFamily = CommandFamily(
        sshPrivateKeyCommandTemplates.flatMap { template in
            sshPrivateKeyPaths.map { path in
                template.replacingOccurrences(of: "%@", with: path)
            }
        }
    )
    static let sshPrivateKeyCommands = sshPrivateKeyCommandFamily.commands

    static func isSshPrivateKeyCommand(_ command: String) -> Bool {
        sshPrivateKeyCommandFamily.contains(command)
    }
}
