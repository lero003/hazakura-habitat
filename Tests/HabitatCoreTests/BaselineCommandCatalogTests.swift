import Testing
import Foundation
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
    func dynamicAskFirstCommandFamilyManifestStaysNarrow() {
        let dynamicAskFirstFamilyNames = PolicyReasonCatalog.dynamicAskFirstCommandFamilies.map(\.name)

        #expect(dynamicAskFirstFamilyNames == [
            "swiftPackageDependencyResolutionCommands",
            "secretBearingBroadSearchCommands",
        ])
    }

    @Test
    func dynamicAskFirstCommandFamilyCommandsStayOutOfStaticBaseline() {
        let dynamicAskFirstCommands = Set(PolicyReasonCatalog.dynamicAskFirstCommandFamilies.flatMap { $0.commands })
        let staticBaselineCommands = Set(
            PolicyReasonCatalog.baselineAskFirstCommands
                + PolicyReasonCatalog.baselineForbiddenCommands
        )

        #expect(
            dynamicAskFirstCommands.isDisjoint(with: staticBaselineCommands),
            "Expected dynamic Ask First command families to be added from current project facts, not duplicated in static baseline policy"
        )
    }

    @Test
    func baselineAskFirstCommandFamilyManifestStaysLeafOrdered() {
        let askFirstFamilyNames = PolicyReasonCatalog.baselineAskFirstCommandFamilies.map(\.name)

        #expect(askFirstFamilyNames == [
            "homebrewDirectAskFirstCommands",
            "pipAskFirstCommands",
            "npmDependencyMutationCommands",
            "npmEphemeralPackageExecutionCommands",
            "pnpmDependencyMutationCommands",
            "pnpmEphemeralPackageExecutionCommands",
            "yarnDependencyMutationCommands",
            "yarnEphemeralPackageExecutionCommands",
            "bunDependencyMutationCommands",
            "bunEphemeralPackageExecutionCommands",
            "packageRegistryMutationCommands",
            "corepackPackageManagerActivationCommands",
            "uvDependencyMutationCommands",
            "pythonEphemeralPackageExecutionCommands",
            "rubyBundlerDependencyMutationCommands",
            "homebrewBundleReviewCommands",
            "xcodebuildProjectMutationCommands",
            "goDependencyMutationCommands",
            "cargoDependencyMutationCommands",
            "cocoapodsDependencyMutationCommands",
            "carthageDependencyMutationCommands",
            "virtualEnvironmentMutationCommands",
            "baselineLockfileMutationCommands",
            "versionManagerMutationCommands",
            "localGitWorkspaceMutationCommands",
            "gitHubCliMutationCommands",
            "workspaceMutationCommands",
        ])
    }

    @Test
    func baselineForbiddenCommandFamilyManifestStaysLeafOrdered() {
        let forbiddenFamilyNames = PolicyReasonCatalog.baselineForbiddenCommandFamilies.map(\.name)

        #expect(forbiddenFamilyNames == [
            "privilegedCommands",
            "outsideProjectDeletionCommands",
            "remoteScriptExecutionCommands",
            "globalEnvironmentMutationCommands",
            "packageManagerCredentialAndConfigCommands",
            "cliAuthAndCredentialStoreCommands",
            "cloudAndContainerCredentialCommands",
            "hostPrivateDataCommands",
            "sshPrivateKeyCommands",
            "baselineForbiddenSecretValueCommands",
        ])
    }

    @Test
    func catalogCommandFamilyManifestStaysPartitionedByPolicySource() {
        typealias Source = PolicyReasonCatalog.CommandFamilyManifestEntry.Source

        let manifestNames = PolicyReasonCatalog.catalogCommandFamilies.map(\.name)
        let manifestSources = PolicyReasonCatalog.catalogCommandFamilies.map(\.source)
        let expectedManifestNames = (
            PolicyReasonCatalog.dynamicAskFirstCommandFamilies
                + PolicyReasonCatalog.baselineAskFirstCommandFamilies
                + PolicyReasonCatalog.baselineForbiddenCommandFamilies
        ).map(\.name)
        let expectedManifestSources =
            Array(repeating: Source.dynamicAskFirst, count: PolicyReasonCatalog.dynamicAskFirstCommandFamilies.count)
            + Array(repeating: .baselineAskFirst, count: PolicyReasonCatalog.baselineAskFirstCommandFamilies.count)
            + Array(repeating: .baselineForbidden, count: PolicyReasonCatalog.baselineForbiddenCommandFamilies.count)

        #expect(
            manifestNames == expectedManifestNames,
            "Expected the catalog manifest to stay limited to dynamic Ask First families followed by baseline Ask First and Forbidden families"
        )
        #expect(
            manifestSources == expectedManifestSources,
            "Expected each catalog manifest entry to declare the policy source used by its partition"
        )
    }

    @Test
    func baselineRenderedPolicyOrderFollowsFamilyManifestOrder() {
        #expect(
            PolicyReasonCatalog.baselineAskFirstCommands
                == PolicyReasonCatalog.baselineAskFirstCommandFamilies.flatMap { $0.commands },
            "Expected rendered baseline Ask First order to follow the catalog family manifest order"
        )
        #expect(
            PolicyReasonCatalog.baselineForbiddenCommands
                == PolicyReasonCatalog.baselineForbiddenCommandFamilies.flatMap { $0.commands },
            "Expected rendered baseline Forbidden order to follow the catalog family manifest order"
        )
    }

    @Test
    func catalogCommandFamilyManifestSourcesMatchCommandClassification() {
        let deliberateGenericAskFirstCommands = Set(
            [
                "brew cleanup",
                "brew autoremove",
                "brew tap",
                "brew tap-new",
            ]
            + PolicyReasonCatalog.homebrewBundleReviewCommands
            + ["pod deintegrate"]
            + PolicyReasonCatalog.xcodebuildProjectMutationCommands
            + PolicyReasonCatalog.pipPackageFetchAndCacheCommands
            + PolicyReasonCatalog.virtualEnvironmentMutationCommands
            + PolicyReasonCatalog.workspaceMutationCommands
        )

        for family in PolicyReasonCatalog.catalogCommandFamilies {
            for command in family.commands {
                switch family.source {
                case .dynamicAskFirst, .baselineAskFirst:
                    #expect(
                        PolicyReasonCatalog.askFirstReason(for: command).code != "user_approval_required"
                            || deliberateGenericAskFirstCommands.contains(command),
                        "Expected Ask First manifest entry \(command) from \(family.name) to keep a deliberate Ask First reason"
                    )
                case .baselineForbidden:
                    #expect(
                        PolicyReasonCatalog.forbiddenReason(for: command).code != "unsafe_or_sensitive_command",
                        "Expected Forbidden manifest entry \(command) from \(family.name) to keep a deliberate Forbidden reason"
                    )
                }
            }
        }
    }

    @Test
    func catalogCommandFamilyManifestSourcesMatchRenderedPolicySides() {
        let baselineAskFirstCommands = Set(PolicyReasonCatalog.baselineAskFirstCommands)
        let baselineForbiddenCommands = Set(PolicyReasonCatalog.baselineForbiddenCommands)

        for family in PolicyReasonCatalog.catalogCommandFamilies {
            for command in family.commands {
                switch family.source {
                case .dynamicAskFirst:
                    #expect(
                        !baselineAskFirstCommands.contains(command),
                        "Expected dynamic Ask First command \(command) from \(family.name) to stay outside rendered baseline Ask First policy"
                    )
                    #expect(
                        !baselineForbiddenCommands.contains(command),
                        "Expected dynamic Ask First command \(command) from \(family.name) to stay outside rendered baseline Forbidden policy"
                    )
                    #expect(
                        PolicyReasonCatalog.askFirstFinding(for: command).classification == PolicyFinding.askFirstClassification,
                        "Expected dynamic Ask First command \(command) from \(family.name) to render as Ask First metadata"
                    )
                case .baselineAskFirst:
                    #expect(
                        baselineAskFirstCommands.contains(command),
                        "Expected baseline Ask First command \(command) from \(family.name) to render in Ask First policy"
                    )
                    #expect(
                        !baselineForbiddenCommands.contains(command),
                        "Expected baseline Ask First command \(command) from \(family.name) to stay out of Forbidden policy"
                    )
                case .baselineForbidden:
                    #expect(
                        baselineForbiddenCommands.contains(command),
                        "Expected baseline Forbidden command \(command) from \(family.name) to render in Forbidden policy"
                    )
                    #expect(
                        !baselineAskFirstCommands.contains(command),
                        "Expected baseline Forbidden command \(command) from \(family.name) to stay out of Ask First policy"
                    )
                }
            }
        }
    }

    @Test
    func catalogCommandFamilyManifestSourcesMatchGeneratedPolicyFindingSides() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
            ".env": "",
        ])
        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let generatedAskFirstCommands = Set(result.policy.commandReasons.filter {
            $0.classification == PolicyCommandReason.askFirstClassification
        }.map(\.command))
        let generatedForbiddenCommands = Set(result.policy.commandReasons.filter {
            $0.classification == PolicyCommandReason.forbiddenClassification
        }.map(\.command))

        for family in PolicyReasonCatalog.catalogCommandFamilies {
            for command in family.commands {
                switch family.source {
                case .dynamicAskFirst, .baselineAskFirst:
                    #expect(
                        generatedAskFirstCommands.contains(command),
                        "Expected \(command) from \(family.name) to produce generated Ask First finding metadata"
                    )
                case .baselineForbidden:
                    #expect(
                        generatedForbiddenCommands.contains(command),
                        "Expected \(command) from \(family.name) to produce generated Forbidden finding metadata"
                    )
                }
            }
        }
    }

    @Test
    func catalogCommandFamilyManifestSourcesMatchGeneratedPolicyReasonMetadata() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
            ".env": "",
        ])
        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let generatedReasonsByClassificationAndCommand = Dictionary(
            uniqueKeysWithValues: result.policy.commandReasons.map {
                ("\($0.classification)\u{0}\($0.command)", $0)
            }
        )

        for family in PolicyReasonCatalog.catalogCommandFamilies {
            for command in family.commands {
                let expectedReason: PolicyCommandReason

                switch family.source {
                case .dynamicAskFirst, .baselineAskFirst:
                    expectedReason = PolicyReasonCatalog.askFirstCommandReason(for: command)
                case .baselineForbidden:
                    expectedReason = PolicyReasonCatalog.forbiddenCommandReason(for: command)
                }

                #expect(
                    generatedReasonsByClassificationAndCommand[
                        "\(expectedReason.classification)\u{0}\(expectedReason.command)"
                    ] == expectedReason,
                    "Expected \(command) from \(family.name) to keep generated PolicyCommandReason metadata aligned with its manifest source"
                )
            }
        }
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
