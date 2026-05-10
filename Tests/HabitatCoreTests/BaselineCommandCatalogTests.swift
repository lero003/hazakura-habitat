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
        for family in PolicyReasonCatalog.catalogCommandFamilies {
            #expect(
                Set(family.commands).count == family.commands.count,
                "Expected \(family.name) to avoid duplicate policy entries"
            )
        }
    }

    @Test
    func catalogCommandFamilyManifestEntriesAreNonEmpty() {
        for family in PolicyReasonCatalog.catalogCommandFamilies {
            #expect(
                !family.commands.isEmpty,
                "Expected \(family.name) to own at least one policy entry"
            )
        }
    }

    @Test
    func catalogCommandFamilyManifestDoesNotDuplicateNames() {
        let familyNames = PolicyReasonCatalog.catalogCommandFamilies.map(\.name)

        #expect(
            Set(familyNames).count == familyNames.count,
            "Expected the catalog-owned family manifest to avoid duplicate family names"
        )
    }

    @Test
    func catalogCommandFamilyManifestDoesNotDuplicateOwnedCommandsAcrossFamilies() {
        var commandOwners: [String: String] = [:]

        for family in PolicyReasonCatalog.catalogCommandFamilies {
            for command in family.commands {
                let existingOwner = commandOwners[command]

                #expect(
                    existingOwner == nil,
                    "Expected \(command) to have one catalog family owner, not both \(existingOwner ?? "") and \(family.name)"
                )

                commandOwners[command] = family.name
            }
        }
    }

    @Test
    func catalogCommandFamilyManifestDoesNotIncludeRenderedBaselineAggregates() {
        let familyNames = Set(PolicyReasonCatalog.catalogCommandFamilies.map(\.name))

        #expect(
            !familyNames.contains("baselineAskFirstCommands"),
            "Expected the manifest to list leaf command families, not the rendered Ask First aggregate"
        )
        #expect(
            !familyNames.contains("baselineForbiddenCommands"),
            "Expected the manifest to list leaf command families, not the rendered Forbidden aggregate"
        )
    }

    @Test
    func dynamicCommandFamilyManifestStaysNarrow() {
        let dynamicFamilyNames = PolicyReasonCatalog.dynamicCommandFamilies.map(\.name)

        #expect(dynamicFamilyNames == [
            "swiftPackageDependencyResolutionCommands",
            "secretBearingBroadSearchCommands",
        ])
    }

    @Test
    func dynamicCommandFamilyCommandsStayOutOfStaticBaseline() {
        let dynamicCommands = Set(PolicyReasonCatalog.dynamicCommandFamilies.flatMap { $0.commands })
        let staticBaselineCommands = Set(
            PolicyReasonCatalog.baselineAskFirstCommands
                + PolicyReasonCatalog.baselineForbiddenCommands
        )

        #expect(
            dynamicCommands.isDisjoint(with: staticBaselineCommands),
            "Expected dynamic command families to be added from current project facts, not duplicated in static baseline policy"
        )
    }

    @Test
    func catalogCommandFamilyManifestStaysPartitionedByPolicySource() {
        typealias Source = PolicyReasonCatalog.CommandFamilyManifestEntry.Source

        let manifestNames = PolicyReasonCatalog.catalogCommandFamilies.map(\.name)
        let manifestSources = PolicyReasonCatalog.catalogCommandFamilies.map(\.source)
        let expectedManifestNames = (
            PolicyReasonCatalog.dynamicCommandFamilies
                + PolicyReasonCatalog.baselineAskFirstCommandFamilies
                + PolicyReasonCatalog.baselineForbiddenCommandFamilies
        ).map(\.name)
        let expectedManifestSources =
            Array(repeating: Source.dynamic, count: PolicyReasonCatalog.dynamicCommandFamilies.count)
            + Array(repeating: .baselineAskFirst, count: PolicyReasonCatalog.baselineAskFirstCommandFamilies.count)
            + Array(repeating: .baselineForbidden, count: PolicyReasonCatalog.baselineForbiddenCommandFamilies.count)

        #expect(
            manifestNames == expectedManifestNames,
            "Expected the catalog manifest to stay limited to dynamic families followed by baseline Ask First and Forbidden families"
        )
        #expect(
            manifestSources == expectedManifestSources,
            "Expected each catalog manifest entry to declare the policy source used by its partition"
        )
    }

    @Test
    func baselineCommandFamilyManifestsDoNotDuplicateNames() {
        let askFirstFamilyNames = PolicyReasonCatalog.baselineAskFirstCommandFamilies.map(\.name)
        let forbiddenFamilyNames = PolicyReasonCatalog.baselineForbiddenCommandFamilies.map(\.name)

        #expect(
            Set(askFirstFamilyNames).count == askFirstFamilyNames.count,
            "Expected the baseline Ask First family manifest to avoid duplicate family names"
        )
        #expect(
            Set(forbiddenFamilyNames).count == forbiddenFamilyNames.count,
            "Expected the baseline Forbidden family manifest to avoid duplicate family names"
        )
    }

    @Test
    func catalogCommandFamilyManifestIncludesBaselineFamilies() {
        let manifestNames = Set(PolicyReasonCatalog.catalogCommandFamilies.map(\.name))
        let baselineFamilyNames = Set(
            (PolicyReasonCatalog.baselineAskFirstCommandFamilies + PolicyReasonCatalog.baselineForbiddenCommandFamilies)
                .map(\.name)
        )

        #expect(
            baselineFamilyNames.isSubset(of: manifestNames),
            "Expected the catalog-owned family manifest to include every baseline command family"
        )
    }
}
