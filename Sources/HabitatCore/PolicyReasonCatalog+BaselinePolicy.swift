extension PolicyReasonCatalog {
    static let baselineAskFirstCommandFamilies: [CommandFamilyManifestEntry] = [
        .init("homebrewDirectAskFirstCommands", homebrewDirectAskFirstCommands, source: .baselineAskFirst),
        .init("pipAskFirstCommands", pipAskFirstCommands, source: .baselineAskFirst),
        .init("npmDependencyMutationCommands", npmDependencyMutationCommands, source: .baselineAskFirst),
        .init("npmEphemeralPackageExecutionCommands", npmEphemeralPackageExecutionCommands, source: .baselineAskFirst),
        .init("pnpmDependencyMutationCommands", pnpmDependencyMutationCommands, source: .baselineAskFirst),
        .init("pnpmEphemeralPackageExecutionCommands", pnpmEphemeralPackageExecutionCommands, source: .baselineAskFirst),
        .init("yarnDependencyMutationCommands", yarnDependencyMutationCommands, source: .baselineAskFirst),
        .init("yarnEphemeralPackageExecutionCommands", yarnEphemeralPackageExecutionCommands, source: .baselineAskFirst),
        .init("bunDependencyMutationCommands", bunDependencyMutationCommands, source: .baselineAskFirst),
        .init("bunEphemeralPackageExecutionCommands", bunEphemeralPackageExecutionCommands, source: .baselineAskFirst),
        .init("packageRegistryMutationCommands", packageRegistryMutationCommands, source: .baselineAskFirst),
        .init("corepackPackageManagerActivationCommands", corepackPackageManagerActivationCommands, source: .baselineAskFirst),
        .init("uvDependencyMutationCommands", uvDependencyMutationCommands, source: .baselineAskFirst),
        .init("pythonEphemeralPackageExecutionCommands", pythonEphemeralPackageExecutionCommands, source: .baselineAskFirst),
        .init("rubyBundlerDependencyMutationCommands", rubyBundlerDependencyMutationCommands, source: .baselineAskFirst),
        .init("homebrewBundleReviewCommands", homebrewBundleReviewCommands, source: .baselineAskFirst),
        .init("xcodebuildProjectMutationCommands", xcodebuildProjectMutationCommands, source: .baselineAskFirst),
        .init("goDependencyMutationCommands", goDependencyMutationCommands, source: .baselineAskFirst),
        .init("cargoDependencyMutationCommands", cargoDependencyMutationCommands, source: .baselineAskFirst),
        .init("cocoapodsDependencyMutationCommands", cocoapodsDependencyMutationCommands, source: .baselineAskFirst),
        .init("carthageDependencyMutationCommands", carthageDependencyMutationCommands, source: .baselineAskFirst),
        .init("virtualEnvironmentMutationCommands", virtualEnvironmentMutationCommands, source: .baselineAskFirst),
        .init("baselineLockfileMutationCommands", baselineLockfileMutationCommands, source: .baselineAskFirst),
        .init("versionManagerMutationCommands", versionManagerMutationCommands, source: .baselineAskFirst),
        .init("localGitWorkspaceMutationCommands", localGitWorkspaceMutationCommands, source: .baselineAskFirst),
        .init("gitHubCliMutationCommands", gitHubCliMutationCommands, source: .baselineAskFirst),
        .init("workspaceMutationCommands", workspaceMutationCommands, source: .baselineAskFirst),
    ]

    static let baselineForbiddenCommandFamilies: [CommandFamilyManifestEntry] = [
        .init("baselineForbiddenCoreCommands", baselineForbiddenCoreCommands, source: .baselineForbidden),
        .init("remoteScriptExecutionCommands", remoteScriptExecutionCommands, source: .baselineForbidden),
        .init("globalEnvironmentMutationCommands", globalEnvironmentMutationCommands, source: .baselineForbidden),
        .init("packageManagerCredentialAndConfigCommands", packageManagerCredentialAndConfigCommands, source: .baselineForbidden),
        .init("cliAuthAndCredentialStoreCommands", cliAuthAndCredentialStoreCommands, source: .baselineForbidden),
        .init("cloudAndContainerCredentialCommands", cloudAndContainerCredentialCommands, source: .baselineForbidden),
        .init("hostPrivateDataCommands", hostPrivateDataCommands, source: .baselineForbidden),
        .init("sshPrivateKeyCommands", sshPrivateKeyCommands, source: .baselineForbidden),
        .init("baselineForbiddenSecretValueCommands", baselineForbiddenSecretValueCommands, source: .baselineForbidden),
    ]

    static let baselineAskFirstCommands = baselineAskFirstCommandFamilies.flatMap { $0.commands }

    static let baselineForbiddenCommands = baselineForbiddenCommandFamilies.flatMap { $0.commands }
}
