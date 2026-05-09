extension PolicyReasonCatalog {
    static let baselineAskFirstCommandFamilies: [CommandFamilyManifestEntry] = [
        .init("homebrewDirectAskFirstCommands", homebrewDirectAskFirstCommands),
        .init("pipAskFirstCommands", pipAskFirstCommands),
        .init("npmDependencyMutationCommands", npmDependencyMutationCommands),
        .init("npmEphemeralPackageExecutionCommands", npmEphemeralPackageExecutionCommands),
        .init("pnpmDependencyMutationCommands", pnpmDependencyMutationCommands),
        .init("pnpmEphemeralPackageExecutionCommands", pnpmEphemeralPackageExecutionCommands),
        .init("yarnDependencyMutationCommands", yarnDependencyMutationCommands),
        .init("yarnEphemeralPackageExecutionCommands", yarnEphemeralPackageExecutionCommands),
        .init("bunDependencyMutationCommands", bunDependencyMutationCommands),
        .init("bunEphemeralPackageExecutionCommands", bunEphemeralPackageExecutionCommands),
        .init("packageRegistryMutationCommands", packageRegistryMutationCommands),
        .init("corepackPackageManagerActivationCommands", corepackPackageManagerActivationCommands),
        .init("uvDependencyMutationCommands", uvDependencyMutationCommands),
        .init("pythonEphemeralPackageExecutionCommands", pythonEphemeralPackageExecutionCommands),
        .init("rubyBundlerDependencyMutationCommands", rubyBundlerDependencyMutationCommands),
        .init("homebrewBundleReviewCommands", homebrewBundleReviewCommands),
        .init("xcodebuildProjectMutationCommands", xcodebuildProjectMutationCommands),
        .init("goDependencyMutationCommands", goDependencyMutationCommands),
        .init("cargoDependencyMutationCommands", cargoDependencyMutationCommands),
        .init("cocoapodsDependencyMutationCommands", cocoapodsDependencyMutationCommands),
        .init("carthageDependencyMutationCommands", carthageDependencyMutationCommands),
        .init("virtualEnvironmentMutationCommands", virtualEnvironmentMutationCommands),
        .init("baselineLockfileMutationCommands", baselineLockfileMutationCommands),
        .init("versionManagerMutationCommands", versionManagerMutationCommands),
        .init("localGitWorkspaceMutationCommands", localGitWorkspaceMutationCommands),
        .init("gitHubCliMutationCommands", gitHubCliMutationCommands),
        .init("workspaceMutationCommands", workspaceMutationCommands),
    ]

    static let baselineForbiddenCommandFamilies: [CommandFamilyManifestEntry] = [
        .init("baselineForbiddenCoreCommands", baselineForbiddenCoreCommands),
        .init("remoteScriptExecutionCommands", remoteScriptExecutionCommands),
        .init("globalEnvironmentMutationCommands", globalEnvironmentMutationCommands),
        .init("packageManagerCredentialAndConfigCommands", packageManagerCredentialAndConfigCommands),
        .init("cliAuthAndCredentialStoreCommands", cliAuthAndCredentialStoreCommands),
        .init("cloudAndContainerCredentialCommands", cloudAndContainerCredentialCommands),
        .init("hostPrivateDataCommands", hostPrivateDataCommands),
        .init("sshPrivateKeyCommands", sshPrivateKeyCommands),
        .init("baselineForbiddenSecretValueCommands", baselineForbiddenSecretValueCommands),
    ]

    static let baselineAskFirstCommands = baselineAskFirstCommandFamilies.flatMap { $0.commands }

    static let baselineForbiddenCommands = baselineForbiddenCommandFamilies.flatMap { $0.commands }
}
