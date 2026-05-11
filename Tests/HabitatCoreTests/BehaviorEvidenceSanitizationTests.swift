import Testing
import Foundation
@testable import HabitatCore

struct BehaviorEvidenceSanitizationTests {
    @Test
    func behaviorEvaluationFixturesKeepEvidenceContractAndSanitization() throws {
        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let fixturesURL = rootURL.appendingPathComponent("examples/behavior-evaluation")
        let fixtureURLs = try FileManager.default.contentsOfDirectory(
            at: fixturesURL,
            includingPropertiesForKeys: nil
        )
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        #expect(!fixtureURLs.isEmpty)

        let requiredSanitizationFlags = [
            "rawPromptTranscriptStored",
            "secretValuesStored",
            "shellHistoryStored",
            "clipboardStored",
            "privateLocalPathStored",
        ]
        let observedContextKeys = [
            "withHabitatContext",
            "agentContextOnly",
            "withCommandPolicy",
        ]
        let disallowedEvidenceSnippets = [
            "/Users/",
            "/private/",
            "BEGIN ",
            "PRIVATE KEY",
            "AKIA",
            "AIza",
            "ghp_",
            "sk-habitat",
            "sk_live_",
            "sk_test_",
            "xoxb-",
            "\"promptTranscript\"",
            "\"rawPrompt\"",
            "\"secretValue\"",
            "\"clipboardContents\"",
            "\"shellHistory\"",
        ]

        for fixtureURL in fixtureURLs {
            let data = try Data(contentsOf: fixtureURL)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let verdict = json?["verdict"] as? [String: Any]
            let sanitization = json?["sanitization"] as? [String: Bool]
            let fixtureText = try String(contentsOf: fixtureURL, encoding: .utf8)
            let observedContexts = observedContextKeys.compactMap { key in
                json?[key] as? [String: Any]
            }

            #expect(json?["evidenceSchemaVersion"] as? Int == 1)
            #expect((json?["caseId"] as? String)?.isEmpty == false)
            #expect((json?["date"] as? String)?.isEmpty == false)
            #expect((json?["habitatVersion"] as? String)?.isEmpty == false)
            #expect((json?["agentTool"] as? String)?.isEmpty == false)
            #expect(json?["primaryMetric"] as? String == "risk-aware behavior")
            #expect(json?["expectedBehavior"] is [String: Any])
            #expect(json?["contextMode"] != nil || json?["contextComparison"] != nil)
            #expect(!observedContexts.isEmpty)
            #expect(observedContexts.contains { ($0["firstProposedAction"] as? String)?.isEmpty == false })
            #expect(observedContexts.contains { $0["commandsActuallyRun"] is [String] })
            #expect(verdict?["result"] as? String == json?["result"] as? String)
            #expect((verdict?["reason"] as? String)?.isEmpty == false)
            #expect((verdict?["followUpImprovement"] as? String)?.isEmpty == false)
            #expect((json?["artifactImprovementIfFailed"] as? String)?.isEmpty == false)

            for key in requiredSanitizationFlags {
                #expect(sanitization?[key] == false)
            }

            for snippet in disallowedEvidenceSnippets {
                #expect(
                    !fixtureText.contains(snippet),
                    "\(fixtureURL.lastPathComponent) contains disallowed evidence snippet \(snippet)"
                )
            }
        }
    }

    @Test
    func behaviorEvaluationFixtureIndexesListEveryFixture() throws {
        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let fixturesURL = rootURL.appendingPathComponent("examples/behavior-evaluation")
        let fixtureNames = try FileManager.default.contentsOfDirectory(
            at: fixturesURL,
            includingPropertiesForKeys: nil
        )
            .filter { $0.pathExtension == "json" }
            .map(\.lastPathComponent)
            .sorted()
        let examplesReadme = try String(
            contentsOf: rootURL.appendingPathComponent("examples/README.md"),
            encoding: .utf8
        )
        let evaluationDoc = try String(
            contentsOf: rootURL.appendingPathComponent("docs/evaluation.md"),
            encoding: .utf8
        )

        #expect(!fixtureNames.isEmpty)

        for fixtureName in fixtureNames {
            #expect(
                examplesReadme.contains("`behavior-evaluation/\(fixtureName)`"),
                "Expected examples/README.md to list \(fixtureName)"
            )
            #expect(
                evaluationDoc.contains("`examples/behavior-evaluation/\(fixtureName)`"),
                "Expected docs/evaluation.md to summarize \(fixtureName)"
            )
        }
    }
}
