extension PolicyReasonCatalog {
    static let baselineAskFirstCommandFamilies: [CommandFamilyManifestEntry] = [
        .baselineAskFirst("homebrewDirectAskFirstCommands", homebrewDirectAskFirstCommands),
        .baselineAskFirst("pipDependencyMutationCommands", pipDependencyMutationCommands),
        .baselineAskFirst("pipPackageFetchAndCacheCommands", pipPackageFetchAndCacheCommands),
        .baselineAskFirst("pipCacheMutationCommands", pipCacheMutationCommands),
        .baselineAskFirst("npmDependencyMutationCommands", npmDependencyMutationCommands),
        .baselineAskFirst("npmEphemeralPackageExecutionCommands", npmEphemeralPackageExecutionCommands),
        .baselineAskFirst("pnpmDependencyMutationCommands", pnpmDependencyMutationCommands),
        .baselineAskFirst("pnpmEphemeralPackageExecutionCommands", pnpmEphemeralPackageExecutionCommands),
        .baselineAskFirst("yarnDependencyMutationCommands", yarnDependencyMutationCommands),
        .baselineAskFirst("yarnEphemeralPackageExecutionCommands", yarnEphemeralPackageExecutionCommands),
        .baselineAskFirst("bunDependencyMutationCommands", bunDependencyMutationCommands),
        .baselineAskFirst("bunEphemeralPackageExecutionCommands", bunEphemeralPackageExecutionCommands),
        .baselineAskFirst("packageRegistryMutationCommands", packageRegistryMutationCommands),
        .baselineAskFirst("corepackPackageManagerActivationCommands", corepackPackageManagerActivationCommands),
        .baselineAskFirst("uvDependencyMutationCommands", uvDependencyMutationCommands),
        .baselineAskFirst("pythonEphemeralPackageExecutionCommands", pythonEphemeralPackageExecutionCommands),
        .baselineAskFirst("rubyBundlerDependencyMutationCommands", rubyBundlerDependencyMutationCommands),
        .baselineAskFirst("homebrewBundleReviewCommands", homebrewBundleReviewCommands),
        .baselineAskFirst("xcodebuildProjectMutationCommands", xcodebuildProjectMutationCommands),
        .baselineAskFirst("goDependencyMutationCommands", goDependencyMutationCommands),
        .baselineAskFirst("cargoDependencyMutationCommands", cargoDependencyMutationCommands),
        .baselineAskFirst("cocoapodsDependencyMutationCommands", cocoapodsDependencyMutationCommands),
        .baselineAskFirst("cocoapodsProjectMutationCommands", cocoapodsProjectMutationCommands),
        .baselineAskFirst("carthageDependencyMutationCommands", carthageDependencyMutationCommands),
        .baselineAskFirst("virtualEnvironmentMutationCommands", virtualEnvironmentMutationCommands),
        .baselineAskFirst("baselineLockfileMutationCommands", baselineLockfileMutationCommands),
        .baselineAskFirst("versionManagerMutationCommands", versionManagerMutationCommands),
        .baselineAskFirst("localGitWorkspaceMutationCommands", localGitWorkspaceMutationCommands),
        .baselineAskFirst("gitHubCliMutationCommands", gitHubCliMutationCommands),
        .baselineAskFirst("workspaceMutationCommands", workspaceMutationCommands),
    ]

    static let baselineForbiddenCommandFamilies: [CommandFamilyManifestEntry] = [
        .baselineForbidden("privilegedCommands", privilegedCommands),
        .baselineForbidden("outsideProjectDeletionCommands", outsideProjectDeletionCommands),
        .baselineForbidden("remoteScriptExecutionCommands", remoteScriptExecutionCommands),
        .baselineForbidden("globalEnvironmentMutationCommands", globalEnvironmentMutationCommands),
        .baselineForbidden("packageManagerCredentialAndConfigCommands", packageManagerCredentialAndConfigCommands),
        .baselineForbidden("cliAuthAndCredentialStoreCommands", cliAuthAndCredentialStoreCommands),
        .baselineForbidden("cloudAndContainerCredentialCommands", cloudAndContainerCredentialCommands),
        .baselineForbidden("hostPrivateDataCommands", hostPrivateDataCommands),
        .baselineForbidden("sshPrivateKeyCommands", sshPrivateKeyCommands),
        .baselineForbidden("baselineForbiddenSecretValueCommands", baselineForbiddenSecretValueCommands),
    ]

    static let baselineAskFirstCommands = baselineAskFirstCommandFamilies.flatMap { $0.commands }

    static let baselineForbiddenCommands = baselineForbiddenCommandFamilies.flatMap { $0.commands }
}
