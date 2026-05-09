extension PolicyReasonCatalog {
    static let baselineAskFirstCommands = homebrewDirectAskFirstCommands
        + pipAskFirstCommands
        + npmDependencyMutationCommands
        + npmEphemeralPackageExecutionCommands
        + pnpmDependencyMutationCommands
        + pnpmEphemeralPackageExecutionCommands
        + yarnDependencyMutationCommands
        + yarnEphemeralPackageExecutionCommands
        + bunDependencyMutationCommands
        + bunEphemeralPackageExecutionCommands
        + packageRegistryMutationCommands
        + corepackPackageManagerActivationCommands
        + uvDependencyMutationCommands
        + pythonEphemeralPackageExecutionCommands
        + rubyBundlerDependencyMutationCommands
        + homebrewBundleReviewCommands
        + xcodebuildProjectMutationCommands
        + goDependencyMutationCommands
        + cargoDependencyMutationCommands
        + cocoapodsDependencyMutationCommands
        + carthageDependencyMutationCommands
        + virtualEnvironmentMutationCommands
        + baselineLockfileMutationCommands
        + versionManagerMutationCommands
        + localGitWorkspaceMutationCommands
        + gitHubCliMutationCommands
        + workspaceMutationCommands

    static let baselineForbiddenCommands: [String] = baselineForbiddenCoreCommands
        + remoteScriptExecutionCommands
        + globalEnvironmentMutationCommands
        + packageManagerCredentialAndConfigCommands
        + cliAuthAndCredentialStoreCommands
        + cloudAndContainerCredentialCommands
        + hostPrivateDataCommands
        + sshPrivateKeyCommands
        + baselineForbiddenSecretValueCommands
}
