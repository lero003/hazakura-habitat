import Foundation
import Testing
@testable import HabitatCore

struct PackageScriptValidationPurposeTests {
    @Test
    func scanKeepsAppDeliveryScriptsSeparateFromOrdinaryValidation() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "scripts": {
                "test": "node --test",
                "build": "vite build",
                "check": "npm run test && npm run build",
                "testflight": "node scripts/testflight.mjs publish DO_NOT_EMIT_DELIVERY_BODY",
                "testflight:preflight": "node scripts/testflight.mjs preflight",
                "testflight:status": "node scripts/testflight.mjs status",
                "mac:store:preflight": "bash scripts/macos-app-store.sh preflight",
                "mac:store:prepare": "bash scripts/macos-app-store.sh prepare"
              }
            }
            """,
            "AGENTS.md": """
            検証は `npm run check`。
            Store準備: `npm run mac:store:preflight` と `npm run mac:store:prepare`。
            """,
            "README.md": """
            npm run testflight
            npm run testflight:preflight
            npm run testflight:status
            """
        ])
        defer { try? FileManager.default.removeItem(at: projectURL) }

        let result = HabitatScanner(runner: availableJavaScriptTools).scan(projectURL: projectURL)
        let releaseClaims = result.project.validationCommandClaims.filter { $0.purpose == .releaseArtifact }
        #expect(releaseClaims.map(\.command) == [
            "npm run mac:store:preflight",
            "npm run mac:store:prepare",
            "npm run testflight",
            "npm run testflight:preflight",
            "npm run testflight:status"
        ])
        #expect(result.project.validationCommandClaims.filter { $0.purpose == .ordinaryLocal } == [
            ValidationCommandClaim(source: "AGENTS.md", command: "npm run check")
        ])
        #expect(result.policy.preferredCommands == ["npm run test", "npm run build", "npm run check"])

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: outputURL) }
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        assertAgentContextContract(context)
        #expect(context.contains("release/artifact validation `npm run mac:store:preflight`"))
        #expect(context.contains("not ordinary local validation"))
        #expect(context.contains("- Prefer `npm run testflight`.") == false)
        #expect(scanJSON.contains("DO_NOT_EMIT_DELIVERY_BODY") == false)
        #expect(context.contains("DO_NOT_EMIT_DELIVERY_BODY") == false)
    }

    @Test(arguments: ["npm", "pnpm", "yarn", "bun"], ["testflight:preflight", "mac:store:prepare", "release:verify", "publish", "deploy:preview"])
    func documentedDeliveryScriptFamiliesKeepReleasePurpose(packageManager: String, script: String) throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {"packageManager":"\(packageManager)@1.0.0","scripts":{"\(script)":"echo package body"}}
            """,
            "AGENTS.md": "\(packageManager) run \(script)"
        ])
        defer { try? FileManager.default.removeItem(at: projectURL) }

        let project = ProjectDetector().detect(projectURL: projectURL)

        #expect(project.validationCommandClaims == [
            ValidationCommandClaim(source: "AGENTS.md", command: "\(packageManager) run \(script)", purpose: .releaseArtifact)
        ])
    }

    @Test(arguments: ["test:release-unit", "release-unit", "testflight-unit", "test:publish", "mac:test", "mac:build", "store:test"])
    func deliveryWordsInsideOtherScriptNamesDoNotChangeValidationPurpose(script: String) throws {
        let projectURL = try makeProject(files: [
            "package.json": "{\"scripts\":{\"\(script)\":\"echo ordinary check\"}}",
            "AGENTS.md": "Run npm run \(script) for validation."
        ])
        defer { try? FileManager.default.removeItem(at: projectURL) }

        let project = ProjectDetector().detect(projectURL: projectURL)

        #expect(project.validationCommandClaims == [
            ValidationCommandClaim(source: "AGENTS.md", command: "npm run \(script)")
        ])
    }

    @Test
    func deliveryClassificationRequiresDeclaredAndNonNegatedScriptClaims() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{\"scripts\":{\"testflight\":\"echo delivery\"}}",
            "AGENTS.md": """
            Do not run npm run testflight.
            npm run mac:store:prepare
            npm run deploy
            """
        ])
        defer { try? FileManager.default.removeItem(at: projectURL) }

        let project = ProjectDetector().detect(projectURL: projectURL)

        #expect(project.validationCommandClaims.isEmpty)
    }

    @Test(arguments: ["release:`sudo`", "deploy:<tag>", "publish:bad;command", "testflight:`sudo`", "release::verify", "release:" + String(repeating: "a", count: 97)])
    func malformedPackageScriptNamesDoNotBecomeValidationClaims(script: String) throws {
        let packageData = try JSONSerialization.data(withJSONObject: ["scripts": [script: "echo ignored"]])
        let projectURL = try makeProject(files: [
            "package.json": String(decoding: packageData, as: UTF8.self),
            "AGENTS.md": "npm run \(script)"
        ])
        defer { try? FileManager.default.removeItem(at: projectURL) }

        let project = ProjectDetector().detect(projectURL: projectURL)

        #expect(project.validationCommandClaims.isEmpty)
    }

    private var availableJavaScriptTools: FakeCommandRunner {
        FakeCommandRunner(results: [
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v22.0.0", stderr: ""),
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
            "/usr/bin/env npm --version": .init(name: "/usr/bin/env", args: ["npm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "10.0.0", stderr: "")
        ])
    }
}
