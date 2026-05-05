import Foundation

public struct SecretBearingEvidence: Equatable {
    public let paths: [String]
    public let environmentValuePaths: [String]
    public let packageManagerAuthConfigPaths: [String]
    public let cloudOrContainerCredentialPaths: [String]
    public let sshPrivateKeyPaths: [String]

    public init(project: ProjectInfo) {
        let detectedFiles = project.detectedFiles
        self.environmentValuePaths = detectedFiles
            .filter { Self.isSecretDotEnvFilename($0) || Self.isSecretEnvrcFilename($0) }
            .sorted()
        self.packageManagerAuthConfigPaths = detectedFiles
            .filter(Self.isPackageManagerAuthConfigFile)
            .sorted()
        self.cloudOrContainerCredentialPaths = detectedFiles
            .filter(Self.isProjectCloudOrContainerCredentialFile)
            .sorted()
        self.sshPrivateKeyPaths = detectedFiles
            .filter(Self.isSSHPrivateKeyFilename)
            .sorted()
        self.paths = detectedFiles
            .filter { file in
                Self.isSecretDotEnvFilename(file)
                    || Self.isSecretEnvrcFilename(file)
                    || file == ".netrc"
                    || Self.isPackageManagerAuthConfigFile(file)
                    || Self.isProjectCloudOrContainerCredentialFile(file)
                    || Self.isSSHPrivateKeyFilename(file)
            }
            .sorted()
    }

    public var hasPaths: Bool {
        !paths.isEmpty
    }

    public var hasDotEnvFile: Bool {
        paths.contains { Self.isSecretDotEnvFilename($0) }
    }

    public var hasEnvrcFile: Bool {
        paths.contains { Self.isSecretEnvrcFilename($0) }
    }

    public var hasNetrcFile: Bool {
        paths.contains(".netrc")
    }

    public var hasPackageManagerAuthConfig: Bool {
        !packageManagerAuthConfigPaths.isEmpty
    }

    public var hasCloudOrContainerCredentialFiles: Bool {
        !cloudOrContainerCredentialPaths.isEmpty
    }

    public var hasSSHPrivateKeyFile: Bool {
        !sshPrivateKeyPaths.isEmpty
    }

    public static func isSecretDotEnvFilename(_ file: String) -> Bool {
        file == ".env" || (file.hasPrefix(".env.") && file != ".env.example")
    }

    public static func isSecretEnvrcFilename(_ file: String) -> Bool {
        file == ".envrc" || (file.hasPrefix(".envrc.") && file != ".envrc.example")
    }

    public static func isPackageManagerAuthConfigFile(_ file: String) -> Bool {
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

    public static func isProjectCloudOrContainerCredentialFile(_ file: String) -> Bool {
        file == ".aws/credentials"
            || file == ".aws/config"
            || file == ".config/gcloud/application_default_credentials.json"
            || file == ".docker/config.json"
            || file == ".kube/config"
    }

    public static func isSSHPrivateKeyFilename(_ file: String) -> Bool {
        let basename = URL(fileURLWithPath: file).lastPathComponent.lowercased()
        guard !basename.hasSuffix(".pub") else { return false }

        if ["id_rsa", "id_dsa", "id_ecdsa", "id_ed25519"].contains(basename) {
            return true
        }

        return [".pem", ".key", ".p8", ".p12", ".ppk"].contains { basename.hasSuffix($0) }
    }
}
