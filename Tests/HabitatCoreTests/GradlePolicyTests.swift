import Testing
import Foundation
@testable import HabitatCore

struct GradlePolicyTests {
    @Test
    func scanUsesExecutableGradleWrapperAsLocalValidationEntryPoint() throws {
        let projectURL = try makeProject(files: [
            "settings.gradle.kts": "pluginManagement {}\n",
            "build.gradle.kts": "plugins { kotlin(\"jvm\") version \"2.0.0\" }\n",
        ])
        try writeExecutableScript(
            projectURL.appendingPathComponent("gradlew"),
            contents: "#!/bin/sh\n"
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains("gradlew"))
        #expect(result.project.detectedFiles.contains("settings.gradle.kts"))
        #expect(result.project.packageManager == "gradle")
        #expect(result.policy.preferredCommands == ["./gradlew test", "./gradlew build"])
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use Gradle wrapper (`./gradlew`) because project files point to it."))
        #expect(context.contains("Prefer `./gradlew test`."))
        #expect(context.contains("Prefer `./gradlew build`."))
        #expect(policy.contains("`./gradlew test`"))
        #expect(policy.contains("`./gradlew build`"))
    }

    @Test
    func scanDoesNotSelectGradleWhenWrapperIsNotExecutable() throws {
        let projectURL = try makeProject(files: [
            "gradlew": "#!/bin/sh\n",
            "settings.gradle.kts": "pluginManagement {}\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(!result.project.detectedFiles.contains("gradlew"))
        #expect(result.project.detectedFiles.contains("settings.gradle.kts"))
        #expect(result.project.packageManager == nil)
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))
    }

    @Test
    func gradleValidationClaimAlignsWithExecutableWrapperFacts() throws {
        let projectURL = try makeProject(files: [
            "AGENTS.md": "Run ./gradlew test for local validation.\n",
            "settings.gradle.kts": "pluginManagement {}\n",
        ])
        try writeExecutableScript(
            projectURL.appendingPathComponent("gradlew"),
            contents: "#!/bin/sh\n"
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(source: "AGENTS.md", command: "./gradlew test")
        ])
        #expect(context.contains("Fact: Project instructions and repository files both support Gradle validation."))
        #expect(context.contains("Hint: Prefer `./gradlew test` for local validation."))
        #expect(!context.contains("Project instructions mention `./gradlew test`, but repository facts do not confirm"))
    }

    @Test
    func moduleGradleBuildFilesAreObservedForReportFreshness() throws {
        let projectURL = try makeProject(files: [
            "settings.gradle.kts": "pluginManagement {}\n",
            "build.gradle.kts": "plugins { kotlin(\"jvm\") version \"2.0.0\" }\n",
            "app/build.gradle.kts": "plugins { id(\"com.android.application\") }\n",
        ])
        try writeExecutableScript(
            projectURL.appendingPathComponent("gradlew"),
            contents: "#!/bin/sh\n"
        )

        let moduleBuildURL = projectURL.appendingPathComponent("app/build.gradle.kts")
        let newestDate = Date(timeIntervalSince1970: 1_800_000_100)
        try FileManager.default.setAttributes([.modificationDate: newestDate], ofItemAtPath: moduleBuildURL.path)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let observedFiles = result.project.observedFiles

        #expect(result.project.detectedFiles.contains("app/build.gradle.kts"))
        #expect(observedFiles.map(\.path).contains("app/build.gradle.kts"))
        #expect(result.project.latestObservedFilePath == "app/build.gradle.kts")
        #expect(result.project.latestObservedFileModifiedAt == observedFiles.first { $0.path == "app/build.gradle.kts" }?.modifiedAt)
        #expect(result.project.packageManager == "gradle")
        #expect(result.policy.preferredCommands == ["./gradlew test", "./gradlew build"])
    }
}
