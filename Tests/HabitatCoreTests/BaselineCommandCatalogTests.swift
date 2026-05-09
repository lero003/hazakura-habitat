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
