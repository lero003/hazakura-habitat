import Foundation
import Testing
@testable import HabitatCore

struct OperationalGuidanceTests {
    @Test(arguments: ["docs/development-automation.md", "docs/development_automation.md"])
    func automationGuidanceContributesSanitizedValidationClaims(source: String) throws {
        let projectURL = try makeProject(files: [
            "package.json": #"{"scripts":{"test":"vitest","build:vite":"vite build"}}"#,
            "package-lock.json": "{}",
            source: """
            Verification: npm run test and npm run build:vite.
            Do not run npm run build for this check.
            """,
            "docs/handoff.md": "Historical validation: cargo test."
        ])

        let project = ProjectDetector().detect(projectURL: projectURL)

        #expect(project.validationCommandClaims == [
            ValidationCommandClaim(source: source, command: "npm run test"),
            ValidationCommandClaim(source: source, command: "npm run build:vite"),
        ])
        #expect(project.detectedFiles.contains(source))
        #expect(project.detectedFiles.contains("docs/handoff.md"))
        // Handoffs affect freshness without turning historical commands into guidance.
        #expect(project.validationCommandClaims.contains { $0.source == "docs/handoff.md" } == false)
    }

    @Test(arguments: ["docs/development-automation.md", "docs/development_automation.md"])
    func automationGuidanceDoesNotFollowSymlinkedInstructions(source: String) throws {
        let externalURL = try makeProject(files: ["instructions.md": "Validate with cargo test."])
        let projectURL = try makeProject(files: ["Package.swift": "// swift package"])
        let linkURL = projectURL.appendingPathComponent(source)
        try FileManager.default.createDirectory(
            at: linkURL.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try FileManager.default.createSymbolicLink(
            at: linkURL, withDestinationURL: externalURL.appendingPathComponent("instructions.md")
        )

        let project = ProjectDetector().detect(projectURL: projectURL)

        #expect(project.symlinkedFiles.contains(source))
        #expect(project.validationCommandClaims.isEmpty)
    }

    @Test(arguments: ["development-automation.md", "development_automation.md"])
    func automationGuidanceDoesNotFollowSymlinkedParentDirectory(filename: String) throws {
        let externalURL = try makeProject(files: [filename: "Validate with cargo test."])
        let projectURL = try makeProject(files: ["Package.swift": "// swift package"])
        try FileManager.default.createSymbolicLink(
            at: projectURL.appendingPathComponent("docs"), withDestinationURL: externalURL
        )

        let project = ProjectDetector().detect(projectURL: projectURL)

        #expect(project.symlinkedFiles.contains("docs"))
        #expect(project.detectedFiles.contains("docs/\(filename)") == false)
        #expect(project.validationCommandClaims.isEmpty)
    }
}
