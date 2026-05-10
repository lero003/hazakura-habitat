import Foundation

public struct SecretFileDetector {
    public init() {}

    public func secretBearingEvidence(_ project: ProjectInfo) -> SecretBearingEvidence {
        SecretBearingEvidence(project: project)
    }

    public func hasSymlinkedProjectSignals(_ project: ProjectInfo) -> Bool {
        !project.symlinkedFiles.isEmpty
    }

    public func hasUnsafeRuntimeHintFiles(_ project: ProjectInfo) -> Bool {
        !project.unsafeRuntimeHintFiles.isEmpty
    }

    public func hasUnsafePackageMetadataFields(_ project: ProjectInfo) -> Bool {
        !project.unsafePackageMetadataFields.isEmpty
    }

    public func hasSecretDotEnvFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            isSecretDotEnvFile(file)
        }
    }

    public func secretFileAccessForbiddenCommands(_ project: ProjectInfo) -> [String] {
        secretBearingEvidence(project).paths.flatMap { file in
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

    public func secretEnvironmentFileLoadForbiddenCommands(_ project: ProjectInfo) -> [String] {
        let evidence = secretBearingEvidence(project)
        var commands = evidence.environmentValuePaths.flatMap { file in
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

    public func secretEnvironmentRenderForbiddenCommands(_ project: ProjectInfo) -> [String] {
        let files = secretBearingEvidence(project).environmentValuePaths
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

    public func recursiveSecretSearchAskFirstCommands(_ project: ProjectInfo) -> [String] {
        guard secretBearingEvidence(project).hasPaths else { return [] }

        return PolicyReasonCatalog.secretBearingBroadSearchCommands
    }

    public func secretProjectBulkExportForbiddenCommands(_ project: ProjectInfo) -> [String] {
        guard secretBearingEvidence(project).hasPaths else { return [] }

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

    public func secretEnvironmentValueFiles(_ project: ProjectInfo) -> [String] {
        secretBearingEvidence(project).environmentValuePaths
    }

    public func secretValueFiles(_ project: ProjectInfo) -> [String] {
        secretBearingEvidence(project).paths
    }

    public func isSecretDotEnvFile(_ file: String) -> Bool {
        SecretBearingEvidence.isSecretDotEnvFilename(file)
    }

    public func hasSecretEnvrcFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            isSecretEnvrcFile(file)
        }
    }

    public func isSecretEnvrcFile(_ file: String) -> Bool {
        SecretBearingEvidence.isSecretEnvrcFilename(file)
    }

    public func hasPackageManagerAuthConfig(_ project: ProjectInfo) -> Bool {
        !packageManagerAuthConfigFiles(project).isEmpty
    }

    public func packageManagerAuthConfigFiles(_ project: ProjectInfo) -> [String] {
        secretBearingEvidence(project).packageManagerAuthConfigPaths
    }

    public func isPackageManagerAuthConfigFile(_ file: String) -> Bool {
        SecretBearingEvidence.isPackageManagerAuthConfigFile(file)
    }

    public func hasProjectCloudOrContainerCredentialFiles(_ project: ProjectInfo) -> Bool {
        !projectCloudOrContainerCredentialFiles(project).isEmpty
    }

    public func projectCloudOrContainerCredentialFiles(_ project: ProjectInfo) -> [String] {
        secretBearingEvidence(project).cloudOrContainerCredentialPaths
    }

    public func isProjectCloudOrContainerCredentialFile(_ file: String) -> Bool {
        SecretBearingEvidence.isProjectCloudOrContainerCredentialFile(file)
    }

    public func hasNetrcFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains(".netrc")
    }

    public func hasSSHPrivateKeyFile(_ project: ProjectInfo) -> Bool {
        secretBearingEvidence(project).hasSSHPrivateKeyFile
    }

    public func isSSHPrivateKeyFilename(_ file: String) -> Bool {
        SecretBearingEvidence.isSSHPrivateKeyFilename(file)
    }
}
