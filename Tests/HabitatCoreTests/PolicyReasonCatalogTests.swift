import Testing
@testable import HabitatCore

struct PolicyReasonCatalogTests {
    @Test
    func packageManagerReviewRoutingPreservesCatalogFamilies() {
        #expect(PolicyReasonCatalog.swiftPackageDependencyResolutionCommands == [
            "swift package update",
            "swift package resolve",
        ])
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "npm") == PolicyReasonCatalog.npmDependencyMutationCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "pnpm") == PolicyReasonCatalog.pnpmDependencyMutationCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "yarn") == PolicyReasonCatalog.yarnDependencyMutationCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "bun") == PolicyReasonCatalog.bunDependencyMutationCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "uv") == PolicyReasonCatalog.uvDependencyMutationCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "python") == PolicyReasonCatalog.pipDependencyMutationCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "bundler") == PolicyReasonCatalog.rubyBundlerDependencyMutationCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "homebrew") == PolicyReasonCatalog.homebrewPackageManagerReviewCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "swiftpm") == PolicyReasonCatalog.swiftPackageDependencyResolutionCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "go") == PolicyReasonCatalog.goDependencyMutationCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "cargo") == PolicyReasonCatalog.cargoDependencyMutationCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "cocoapods") == PolicyReasonCatalog.cocoapodsPackageManagerReviewCommands)
        #expect(
            PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "carthage")
                == PolicyReasonCatalog.carthageDependencyMutationCommands
                    + PolicyReasonCatalog.carthageBuildArtifactMutationCommands
        )
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "xcodebuild") == PolicyReasonCatalog.xcodebuildProjectMutationCommands)
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "homebrew") == [
            "brew bundle",
            "brew bundle install",
            "brew bundle cleanup",
            "brew bundle dump",
            "brew update",
            "brew cleanup",
            "brew autoremove",
            "brew tap",
            "brew tap-new",
        ])
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "unknown") == [])
    }

    @Test
    func packageManagerReviewRoutingKeepsBaselineAndSwiftPMBoundariesExplicit() {
        let baselineAskFirstCommands = Set(PolicyReasonCatalog.baselineAskFirstCommands)
        let selectedSwiftPMCommands = Set(PolicyReasonCatalog.swiftPackageDependencyResolutionCommands)
        let routes = PolicyReasonCatalog.packageManagerMutationReviewRoutes
        let packageManagers = routes.map(\.packageManager)

        #expect(Set(packageManagers).count == packageManagers.count, "Expected package-manager Review First routes to avoid duplicate selectors")
        #expect(!routes.contains { $0.commands.isEmpty }, "Expected every package-manager Review First route to expose commands")

        for route in routes {
            let packageManager = route.packageManager
            let reviewCommands = PolicyReasonCatalog.packageManagerMutationReviewCommands(for: packageManager)

            #expect(reviewCommands == route.commands, "Expected \(packageManager) Review First routing to use the catalog route table")
            #expect(!reviewCommands.isEmpty, "Expected \(packageManager) to have Review First routing commands")
            #expect(Set(reviewCommands).count == reviewCommands.count, "Expected \(packageManager) Review First commands to avoid duplicates")

            for command in reviewCommands {
                if packageManager == "swiftpm" {
                    #expect(
                        selectedSwiftPMCommands.contains(command),
                        "Expected SwiftPM Review First command \(command) to stay in the explicit selected-workflow command family"
                    )
                    continue
                }

                #expect(
                    baselineAskFirstCommands.contains(command),
                    "Expected \(packageManager) Review First command \(command) to be promoted from the baseline Ask First catalog"
                )
            }
        }
    }

    @Test
    func githubCliCatalogSeparatesLocalWorkspaceFromRemoteRepositoryActions() {
        let localWorkspaceCommands = [
            "gh pr checkout",
            "gh repo clone",
        ]
        let remoteRepositoryCommands = PolicyReasonCatalog.gitHubCliMutationCommands.filter {
            !localWorkspaceCommands.contains($0)
        }

        #expect(!remoteRepositoryCommands.isEmpty)

        for command in localWorkspaceCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "git_mutation",
                "Expected \(command) to remain a local workspace mutation"
            )
        }

        for command in remoteRepositoryCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "remote_repository_action",
                "Expected \(command) to remain a remote repository action"
            )
        }
    }

    @Test
    func dependencyMutationFallbackStaysBehindSpecificCatalogRules() {
        #expect(PolicyReasonCatalog.askFirstReason(for: "swift package update").code == "dependency_resolution_mutation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "modifying version manager files").code == "version_manager_mutation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "rm -rf").code == "user_approval_required")
        #expect(PolicyReasonCatalog.askFirstReason(for: "npm install").code == "dependency_mutation")

        #expect(PolicyReasonCatalog.askFirstReason(for: "make install").code == "dependency_mutation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "tool bootstrap").code == "dependency_mutation")
    }

    @Test
    func dependencyShapedSpecificRulesStayAheadOfDependencyFallback() {
        #expect(PolicyReasonCatalog.askFirstReason(for: "npm publish").code == "package_registry_mutation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "gem push").code == "package_registry_mutation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "cargo yank").code == "package_registry_mutation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "corepack install").code == "package_manager_activation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "corepack up").code == "package_manager_activation")
        #expect(PolicyReasonCatalog.askFirstReason(for: "uvx").code == "ephemeral_package_execution")
        #expect(PolicyReasonCatalog.askFirstReason(for: "pipx run").code == "ephemeral_package_execution")

        #expect(PolicyReasonCatalog.askFirstReason(for: "make publish").code == "dependency_mutation")
    }

    @Test
    func forbiddenSpecificCatalogRulesStayAheadOfSensitiveFallback() {
        #expect(PolicyReasonCatalog.forbiddenReason(for: "curl | sh").code == "remote_script_execution")
        #expect(PolicyReasonCatalog.forbiddenReason(for: "env").code == "host_private_data")
        #expect(PolicyReasonCatalog.forbiddenReason(for: "gh auth token").code == "secret_or_credential_access")
        #expect(PolicyReasonCatalog.forbiddenReason(for: "brew upgrade").code == "global_environment_mutation")
        #expect(PolicyReasonCatalog.forbiddenReason(for: "destructive file deletion outside the selected project").code == "outside_project_deletion")

        #expect(PolicyReasonCatalog.forbiddenReason(for: "running unknown sensitive command").code == "unsafe_or_sensitive_command")
    }

    @Test
    func baselineSecretValueGuardsStayCredentialSpecific() {
        for command in PolicyReasonCatalog.baselineForbiddenSecretValueCommands {
            #expect(
                PolicyReasonCatalog.baselineForbiddenCommands.contains(command),
                "Expected baseline Forbidden policy to include \(command)"
            )
            #expect(
                PolicyReasonCatalog.forbiddenReason(for: command).code == "secret_or_credential_access",
                "Expected \(command) to keep credential-specific reason metadata"
            )
        }
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
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "user_approval_required",
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
        for command in PolicyReasonCatalog.cocoapodsProjectMutationCommands
            + PolicyReasonCatalog.carthageBuildArtifactMutationCommands
            + PolicyReasonCatalog.xcodebuildProjectMutationCommands {
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

        for command in PolicyReasonCatalog.packageRegistryMutationCommands {
            #expect(
                PolicyReasonCatalog.askFirstReason(for: command).code == "package_registry_mutation",
                "Expected \(command) to keep package-registry mutation classification"
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
