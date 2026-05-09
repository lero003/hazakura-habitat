import Testing
@testable import HabitatCore

struct BaselineCommandCatalogTests {
    @Test
    func baselineCommandCatalogOwnsStaticPolicyLists() {
        #expect(PolicyReasonCatalog.baselineAskFirstCommands.first == "brew install")
        #expect(PolicyReasonCatalog.packageManagerMutationReviewCommands(for: "swiftpm").contains("swift package update"))
        #expect(PolicyReasonCatalog.baselineAskFirstCommands.contains("modifying lockfiles"))
        #expect(PolicyReasonCatalog.baselineAskFirstCommands.contains("modifying version manager files"))
        #expect(PolicyReasonCatalog.baselineAskFirstCommands.contains("git push"))
        #expect(PolicyReasonCatalog.baselineAskFirstCommands.contains("rm -rf"))

        #expect(PolicyReasonCatalog.baselineForbiddenCommands.first == "sudo")
        #expect(PolicyReasonCatalog.baselineForbiddenCommands.contains("destructive file deletion outside the selected project"))
        #expect(PolicyReasonCatalog.baselineForbiddenCommands.contains("curl | sh"))
        #expect(PolicyReasonCatalog.baselineForbiddenCommands.contains("env"))
        #expect(PolicyReasonCatalog.baselineForbiddenCommands.contains("gh auth token"))
        #expect(PolicyReasonCatalog.baselineForbiddenCommands.contains("cat ~/.ssh/id_rsa"))
        #expect(PolicyReasonCatalog.baselineForbiddenCommands.contains("read private keys"))
    }

    @Test
    func baselineCommandCatalogDoesNotDuplicateRenderedPolicyEntries() {
        let askFirstCommands = PolicyReasonCatalog.baselineAskFirstCommands
        let forbiddenCommands = PolicyReasonCatalog.baselineForbiddenCommands

        #expect(Set(askFirstCommands).count == askFirstCommands.count)
        #expect(Set(forbiddenCommands).count == forbiddenCommands.count)
        #expect(Set(askFirstCommands).isDisjoint(with: Set(forbiddenCommands)))
    }

    @Test
    func baselineCommandCatalogCoversStaticCommandFamilies() {
        let baselineAskFirstCommands = Set(PolicyReasonCatalog.baselineAskFirstCommands)
        let baselineForbiddenCommands = Set(PolicyReasonCatalog.baselineForbiddenCommands)
        let staticAskFirstFamilyCommands = PolicyReasonCatalog.baselineAskFirstCommandFamilies.flatMap { $0.commands }
        let staticForbiddenFamilyCommands = PolicyReasonCatalog.baselineForbiddenCommandFamilies.flatMap { $0.commands }

        #expect(Set(staticAskFirstFamilyCommands).isSubset(of: baselineAskFirstCommands))
        #expect(Set(staticForbiddenFamilyCommands).isSubset(of: baselineForbiddenCommands))
        #expect(!baselineAskFirstCommands.contains("swift package update"))
        #expect(!baselineAskFirstCommands.contains("recursive project search without excluding secret-bearing files"))
    }

    @Test
    func baselineCommandCatalogHasNoUnownedStaticCommands() {
        let baselineAskFirstCommands = Set(PolicyReasonCatalog.baselineAskFirstCommands)
        let baselineForbiddenCommands = Set(PolicyReasonCatalog.baselineForbiddenCommands)
        let ownedAskFirstCommands = Set(PolicyReasonCatalog.baselineAskFirstCommandFamilies.flatMap { $0.commands })
        let ownedForbiddenCommands = Set(PolicyReasonCatalog.baselineForbiddenCommandFamilies.flatMap { $0.commands })

        #expect(
            baselineAskFirstCommands == ownedAskFirstCommands,
            "Expected every baseline Ask First command to belong to a named catalog family or explicit static guard"
        )
        #expect(
            baselineForbiddenCommands == ownedForbiddenCommands,
            "Expected every baseline Forbidden command to belong to a named catalog family or explicit static guard"
        )
    }

    @Test
    func catalogCommandFamiliesDoNotDuplicateCommands() {
        let commandFamilies: [(name: String, commands: [String])] = [
            ("baselineAskFirstCommands", PolicyReasonCatalog.baselineAskFirstCommands),
            ("baselineForbiddenCommands", PolicyReasonCatalog.baselineForbiddenCommands),
            ("homebrewPackageManagerReviewCommands", PolicyReasonCatalog.homebrewPackageManagerReviewCommands),
            ("pipDependencyMutationCommands", PolicyReasonCatalog.pipDependencyMutationCommands),
            ("pipPackageFetchAndCacheCommands", PolicyReasonCatalog.pipPackageFetchAndCacheCommands),
            ("pipCacheMutationCommands", PolicyReasonCatalog.pipCacheMutationCommands),
            ("pipAskFirstCommands", PolicyReasonCatalog.pipAskFirstCommands),
            ("uvDependencyMutationCommands", PolicyReasonCatalog.uvDependencyMutationCommands),
            ("npmDependencyMutationCommands", PolicyReasonCatalog.npmDependencyMutationCommands),
            ("pnpmDependencyMutationCommands", PolicyReasonCatalog.pnpmDependencyMutationCommands),
            ("yarnDependencyMutationCommands", PolicyReasonCatalog.yarnDependencyMutationCommands),
            ("bunDependencyMutationCommands", PolicyReasonCatalog.bunDependencyMutationCommands),
            ("npmEphemeralPackageExecutionCommands", PolicyReasonCatalog.npmEphemeralPackageExecutionCommands),
            ("pnpmEphemeralPackageExecutionCommands", PolicyReasonCatalog.pnpmEphemeralPackageExecutionCommands),
            ("yarnEphemeralPackageExecutionCommands", PolicyReasonCatalog.yarnEphemeralPackageExecutionCommands),
            ("bunEphemeralPackageExecutionCommands", PolicyReasonCatalog.bunEphemeralPackageExecutionCommands),
            ("pythonEphemeralPackageExecutionCommands", PolicyReasonCatalog.pythonEphemeralPackageExecutionCommands),
            ("ephemeralPackageExecutionCommands", PolicyReasonCatalog.ephemeralPackageExecutionCommands),
            ("packageRegistryMutationCommands", PolicyReasonCatalog.packageRegistryMutationCommands),
            ("corepackPackageManagerActivationCommands", PolicyReasonCatalog.corepackPackageManagerActivationCommands),
            ("rubyBundlerDependencyMutationCommands", PolicyReasonCatalog.rubyBundlerDependencyMutationCommands),
            ("swiftPackageDependencyResolutionCommands", PolicyReasonCatalog.swiftPackageDependencyResolutionCommands),
            ("goDependencyMutationCommands", PolicyReasonCatalog.goDependencyMutationCommands),
            ("cargoDependencyMutationCommands", PolicyReasonCatalog.cargoDependencyMutationCommands),
            ("cocoapodsDependencyMutationCommands", PolicyReasonCatalog.cocoapodsDependencyMutationCommands),
            ("carthageDependencyMutationCommands", PolicyReasonCatalog.carthageDependencyMutationCommands),
            ("xcodebuildProjectMutationCommands", PolicyReasonCatalog.xcodebuildProjectMutationCommands),
            ("virtualEnvironmentMutationCommands", PolicyReasonCatalog.virtualEnvironmentMutationCommands),
            ("baselineLockfileMutationCommands", PolicyReasonCatalog.baselineLockfileMutationCommands),
            ("versionManagerMutationCommands", PolicyReasonCatalog.versionManagerMutationCommands),
            ("localGitWorkspaceMutationCommands", PolicyReasonCatalog.localGitWorkspaceMutationCommands),
            ("gitHubCliMutationCommands", PolicyReasonCatalog.gitHubCliMutationCommands),
            ("workspaceMutationCommands", PolicyReasonCatalog.workspaceMutationCommands),
            ("secretBearingBroadSearchCommands", PolicyReasonCatalog.secretBearingBroadSearchCommands),
        ] + PolicyReasonCatalog.baselineAskFirstCommandFamilies
            + PolicyReasonCatalog.baselineForbiddenCommandFamilies

        for family in commandFamilies {
            #expect(
                Set(family.commands).count == family.commands.count,
                "Expected \(family.name) to avoid duplicate policy entries"
            )
        }
    }
}
