extension PolicyReasonCatalog {
    static let catalogCommandFamilies = uniqueCommandFamilyManifest([
        .init("baselineAskFirstCommands", baselineAskFirstCommands),
        .init("baselineForbiddenCommands", baselineForbiddenCommands),
        .init("homebrewPackageManagerReviewCommands", homebrewPackageManagerReviewCommands),
        .init("pipDependencyMutationCommands", pipDependencyMutationCommands),
        .init("pipPackageFetchAndCacheCommands", pipPackageFetchAndCacheCommands),
        .init("pipCacheMutationCommands", pipCacheMutationCommands),
        .init("pipAskFirstCommands", pipAskFirstCommands),
        .init("uvDependencyMutationCommands", uvDependencyMutationCommands),
        .init("npmDependencyMutationCommands", npmDependencyMutationCommands),
        .init("pnpmDependencyMutationCommands", pnpmDependencyMutationCommands),
        .init("yarnDependencyMutationCommands", yarnDependencyMutationCommands),
        .init("bunDependencyMutationCommands", bunDependencyMutationCommands),
        .init("npmEphemeralPackageExecutionCommands", npmEphemeralPackageExecutionCommands),
        .init("pnpmEphemeralPackageExecutionCommands", pnpmEphemeralPackageExecutionCommands),
        .init("yarnEphemeralPackageExecutionCommands", yarnEphemeralPackageExecutionCommands),
        .init("bunEphemeralPackageExecutionCommands", bunEphemeralPackageExecutionCommands),
        .init("pythonEphemeralPackageExecutionCommands", pythonEphemeralPackageExecutionCommands),
        .init("ephemeralPackageExecutionCommands", ephemeralPackageExecutionCommands),
        .init("packageRegistryMutationCommands", packageRegistryMutationCommands),
        .init("corepackPackageManagerActivationCommands", corepackPackageManagerActivationCommands),
        .init("rubyBundlerDependencyMutationCommands", rubyBundlerDependencyMutationCommands),
        .init("swiftPackageDependencyResolutionCommands", swiftPackageDependencyResolutionCommands),
        .init("goDependencyMutationCommands", goDependencyMutationCommands),
        .init("cargoDependencyMutationCommands", cargoDependencyMutationCommands),
        .init("cocoapodsDependencyMutationCommands", cocoapodsDependencyMutationCommands),
        .init("carthageDependencyMutationCommands", carthageDependencyMutationCommands),
        .init("xcodebuildProjectMutationCommands", xcodebuildProjectMutationCommands),
        .init("virtualEnvironmentMutationCommands", virtualEnvironmentMutationCommands),
        .init("baselineLockfileMutationCommands", baselineLockfileMutationCommands),
        .init("versionManagerMutationCommands", versionManagerMutationCommands),
        .init("localGitWorkspaceMutationCommands", localGitWorkspaceMutationCommands),
        .init("gitHubCliMutationCommands", gitHubCliMutationCommands),
        .init("workspaceMutationCommands", workspaceMutationCommands),
        .init("secretBearingBroadSearchCommands", secretBearingBroadSearchCommands),
    ] + baselineAskFirstCommandFamilies
        + baselineForbiddenCommandFamilies)

    private static func uniqueCommandFamilyManifest(
        _ families: [CommandFamilyManifestEntry]
    ) -> [CommandFamilyManifestEntry] {
        var seenNames: Set<String> = []
        return families.filter { family in
            seenNames.insert(family.name).inserted
        }
    }
}
