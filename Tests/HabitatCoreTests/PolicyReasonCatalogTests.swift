import Testing
@testable import HabitatCore

struct PolicyReasonCatalogTests {
    @Test
    func baselineCommandCatalogOwnsStaticPolicyLists() {
        #expect(PolicyReasonCatalog.baselineAskFirstCommands.first == "brew install")
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "swiftpm").contains("swift package update"))
        #expect(PolicyReasonCatalog.baselineAskFirstCommands.contains("modifying lockfiles"))
        #expect(PolicyReasonCatalog.baselineAskFirstCommands.contains("git push"))
        #expect(PolicyReasonCatalog.baselineAskFirstCommands.contains("rm -rf"))

        #expect(PolicyReasonCatalog.baselineForbiddenCommands.first == "sudo")
        #expect(PolicyReasonCatalog.baselineForbiddenCommands.contains("curl | sh"))
        #expect(PolicyReasonCatalog.baselineForbiddenCommands.contains("env"))
        #expect(PolicyReasonCatalog.baselineForbiddenCommands.contains("gh auth token"))
        #expect(PolicyReasonCatalog.baselineForbiddenCommands.contains("cat ~/.ssh/id_rsa"))
        #expect(PolicyReasonCatalog.baselineForbiddenCommands.contains("read private keys"))
    }

    @Test
    func catalogFamilyExtractionsPreserveClassification() {
        #expect(PolicyReasonCatalog.askFirstReason(for: "git push").code == "git_mutation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "git commit").code == "git_mutation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "git checkout").code == "git_mutation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "gh pr checkout").code == "git_mutation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "gh repo clone").code == "git_mutation")

        #expect(PolicyReasonCatalog.askFirstReason(for: "gh pr create").code == "remote_repository_action")
        #expect(PolicyReasonCatalog.askFirstReason(for: "gh workflow run").code == "remote_repository_action")

        for command in PolicyReasonCatalog.workspaceMutationCommands {
            let expectedReasonCode = ["xargs rm", "rm", "rm -r", "rm -rf"].contains(command)
                ? "dependency_mutation"
                : "user_approval_required"
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == expectedReasonCode,
                "Expected \(command) to keep existing workspace-mutation approval classification"
            )
        }

        for command in PolicyReasonCatalog.npmDependencyMutationCommands
            + PolicyReasonCatalog.pnpmDependencyMutationCommands
            + PolicyReasonCatalog.yarnDependencyMutationCommands
            + PolicyReasonCatalog.bunDependencyMutationCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "dependency_mutation",
                "Expected \(command) to keep JavaScript dependency-mutation classification"
            )
        }

        for command in PolicyReasonCatalog.swiftPackageDependencyResolutionCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "dependency_resolution_mutation",
                "Expected \(command) to keep SwiftPM dependency-resolution classification"
            )
        }

        for command in PolicyReasonCatalog.pipDependencyMutationCommands
            + PolicyReasonCatalog.pipCacheMutationCommands
            + PolicyReasonCatalog.uvDependencyMutationCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "dependency_mutation",
                "Expected \(command) to keep Python package-manager dependency-mutation classification"
            )
        }
        for command in PolicyReasonCatalog.pipPackageFetchAndCacheCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "user_approval_required",
                "Expected \(command) to keep generic approval classification"
            )
        }

        for command in PolicyReasonCatalog.rubyBundlerDependencyMutationCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "dependency_mutation",
                "Expected \(command) to keep Ruby Bundler dependency-mutation classification"
            )
        }

        for command in PolicyReasonCatalog.goDependencyMutationCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "dependency_mutation",
                "Expected \(command) to keep Go dependency-mutation classification"
            )
        }
        for command in PolicyReasonCatalog.cargoDependencyMutationCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "dependency_mutation",
                "Expected \(command) to keep Cargo dependency-mutation classification"
            )
        }
        for command in ["pod install", "pod update", "pod repo update"]
            + PolicyReasonCatalog.carthageDependencyMutationCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "dependency_mutation",
                "Expected \(command) to keep Apple dependency-mutation classification"
            )
        }
        for command in ["pod deintegrate"] + PolicyReasonCatalog.xcodebuildProjectMutationCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "user_approval_required",
                "Expected \(command) to keep generic approval classification"
            )
        }

        for command in ["brew install", "brew update", "brew bundle install"] {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "dependency_mutation",
                "Expected \(command) to keep Homebrew dependency-mutation classification"
            )
        }
        for command in ["brew cleanup", "brew autoremove", "brew tap", "brew tap-new", "brew bundle", "brew bundle cleanup", "brew bundle dump"] {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "user_approval_required",
                "Expected \(command) to keep generic approval classification"
            )
        }

        for command in PolicyReasonCatalog.corepackPackageManagerActivationCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "package_manager_activation",
                "Expected \(command) to keep package-manager activation classification"
            )
        }

        for command in PolicyReasonCatalog.ephemeralPackageExecutionCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "ephemeral_package_execution",
                "Expected \(command) to keep ephemeral package execution classification"
            )
        }
        #expect(PolicyReasonCatalog.askFirstReason(for: "npx").code == "ephemeral_package_execution")

        for command in PolicyReasonCatalog.secretBearingBroadSearchCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "secret_or_credential_access",
                "Expected \(command) to keep secret-bearing broad-search classification"
            )
        }

        for command in PolicyReasonCatalog.virtualEnvironmentMutationCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "user_approval_required",
                "Expected \(command) to keep virtual-environment approval classification"
            )
        }
        for command in PolicyReasonCatalog.versionManagerMutationCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "version_manager_mutation",
                "Expected \(command) to keep version-manager mutation classification"
            )
        }

        for command in PolicyReasonCatalog.packageManagerCredentialAndConfigCommands {
            #expect(
                PolicyReasonCatalog.forbiddenReason(for: command).code == "secret_or_credential_access",
                "Expected \(command) to keep package-manager credential/config classification"
            )
        }
        #expect(PolicyReasonCatalog.forbiddenReason(for: "gh auth token").code == "secret_or_credential_access")
        #expect(PolicyReasonCatalog.forbiddenReason(for: "git credential fill").code == "secret_or_credential_access")
        #expect(PolicyReasonCatalog.forbiddenReason(for: "aws configure export-credentials").code == "secret_or_credential_access")
        #expect(PolicyReasonCatalog.forbiddenReason(for: "kubectl config view --raw").code == "secret_or_credential_access")
        for command in PolicyReasonCatalog.sshPrivateKeyCommands {
            #expect(
                PolicyReasonCatalog.forbiddenReason(for: command).code == "secret_or_credential_access",
                "Expected \(command) to keep SSH private-key command classification"
            )
        }

        for command in PolicyReasonCatalog.hostPrivateDataCommands {
            #expect(
                PolicyReasonCatalog.forbiddenReason(for: command).code == "host_private_data",
                "Expected \(command) to keep host-private data classification"
            )
        }
        #expect(PolicyReasonCatalog.forbiddenReason(for: "pbpaste").code == "host_private_data")
        #expect(PolicyReasonCatalog.forbiddenReason(for: "cat ~/.zsh_history").code == "host_private_data")

        for command in PolicyReasonCatalog.remoteScriptExecutionCommands {
            #expect(
                PolicyReasonCatalog.forbiddenReason(for: command).code == "remote_script_execution",
                "Expected \(command) to keep remote-script execution classification"
            )
        }

        for command in PolicyReasonCatalog.globalEnvironmentMutationCommands {
            #expect(
                PolicyReasonCatalog.forbiddenReason(for: command).code == "global_environment_mutation",
                "Expected \(command) to keep global environment mutation classification"
            )
        }
        #expect(PolicyReasonCatalog.forbiddenReason(for: "brew upgrade").code == "global_environment_mutation")
        #expect(PolicyReasonCatalog.forbiddenReason(for: "pipx ensurepath").code == "global_environment_mutation")
    }
}
