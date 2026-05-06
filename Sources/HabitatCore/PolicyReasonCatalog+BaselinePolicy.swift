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
        + [
            "modifying lockfiles",
        ]
        + versionManagerMutationCommands
        + localGitWorkspaceMutationCommands
        + gitHubCliMutationCommands
        + workspaceMutationCommands

    static let baselineForbiddenCommands = [
        "sudo",
        "destructive file deletion outside the selected project",
    ] + remoteScriptExecutionCommands
        + globalEnvironmentMutationCommands
        + packageManagerCredentialAndConfigCommands
        + cliAuthAndCredentialStoreCommands
        + cloudAndContainerCredentialCommands
        + hostPrivateDataCommands
        + sshPrivateKeyCommands
        + [
            "load secret environment files",
            "read .env values",
            "read .envrc values",
            "read .netrc values",
            "read package manager auth config values",
            "read private keys",
        ]
}
