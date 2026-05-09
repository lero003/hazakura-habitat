extension PolicyReasonCatalog {
    static let baselineAskFirstCommandFamilies: [(name: String, commands: [String])] = [
        ("homebrewDirectAskFirstCommands", homebrewDirectAskFirstCommands),
        ("pipAskFirstCommands", pipAskFirstCommands),
        ("npmDependencyMutationCommands", npmDependencyMutationCommands),
        ("npmEphemeralPackageExecutionCommands", npmEphemeralPackageExecutionCommands),
        ("pnpmDependencyMutationCommands", pnpmDependencyMutationCommands),
        ("pnpmEphemeralPackageExecutionCommands", pnpmEphemeralPackageExecutionCommands),
        ("yarnDependencyMutationCommands", yarnDependencyMutationCommands),
        ("yarnEphemeralPackageExecutionCommands", yarnEphemeralPackageExecutionCommands),
        ("bunDependencyMutationCommands", bunDependencyMutationCommands),
        ("bunEphemeralPackageExecutionCommands", bunEphemeralPackageExecutionCommands),
        ("packageRegistryMutationCommands", packageRegistryMutationCommands),
        ("corepackPackageManagerActivationCommands", corepackPackageManagerActivationCommands),
        ("uvDependencyMutationCommands", uvDependencyMutationCommands),
        ("pythonEphemeralPackageExecutionCommands", pythonEphemeralPackageExecutionCommands),
        ("rubyBundlerDependencyMutationCommands", rubyBundlerDependencyMutationCommands),
        ("homebrewBundleReviewCommands", homebrewBundleReviewCommands),
        ("xcodebuildProjectMutationCommands", xcodebuildProjectMutationCommands),
        ("goDependencyMutationCommands", goDependencyMutationCommands),
        ("cargoDependencyMutationCommands", cargoDependencyMutationCommands),
        ("cocoapodsDependencyMutationCommands", cocoapodsDependencyMutationCommands),
        ("carthageDependencyMutationCommands", carthageDependencyMutationCommands),
        ("virtualEnvironmentMutationCommands", virtualEnvironmentMutationCommands),
        ("baselineLockfileMutationCommands", baselineLockfileMutationCommands),
        ("versionManagerMutationCommands", versionManagerMutationCommands),
        ("localGitWorkspaceMutationCommands", localGitWorkspaceMutationCommands),
        ("gitHubCliMutationCommands", gitHubCliMutationCommands),
        ("workspaceMutationCommands", workspaceMutationCommands),
    ]

    static let baselineForbiddenCommandFamilies: [(name: String, commands: [String])] = [
        ("baselineForbiddenCoreCommands", baselineForbiddenCoreCommands),
        ("remoteScriptExecutionCommands", remoteScriptExecutionCommands),
        ("globalEnvironmentMutationCommands", globalEnvironmentMutationCommands),
        ("packageManagerCredentialAndConfigCommands", packageManagerCredentialAndConfigCommands),
        ("cliAuthAndCredentialStoreCommands", cliAuthAndCredentialStoreCommands),
        ("cloudAndContainerCredentialCommands", cloudAndContainerCredentialCommands),
        ("hostPrivateDataCommands", hostPrivateDataCommands),
        ("sshPrivateKeyCommands", sshPrivateKeyCommands),
        ("baselineForbiddenSecretValueCommands", baselineForbiddenSecretValueCommands),
    ]

    static let baselineAskFirstCommands = baselineAskFirstCommandFamilies.flatMap { $0.commands }

    static let baselineForbiddenCommands = baselineForbiddenCommandFamilies.flatMap { $0.commands }
}
