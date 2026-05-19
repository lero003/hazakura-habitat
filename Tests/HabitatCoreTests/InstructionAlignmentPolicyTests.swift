import Testing
import Foundation
@testable import HabitatCore

struct InstructionAlignmentPolicyTests {
    @Test
    func scanWarnsWhenDocumentedValidationCommandConflictsWithRepositoryFacts() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """,
            "AGENTS.md": "Run npm test before committing changes."
        ])
        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: "")
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(source: "AGENTS.md", command: "npm test")
        ])

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(context.contains("Fact: `Package.swift` is present and `package.json` is absent."))
        #expect(context.contains("Warning: Project instructions mention `npm test`, but repository facts select SwiftPM validation."))
        #expect(context.contains("Hint: Prefer `swift test` unless the task explicitly targets generated docs or external examples."))
        #expect(!context.contains("Run npm test before committing changes."))
        #expect(scanJSON.contains("\"validationCommandClaims\""))
        #expect(scanJSON.contains("\"command\" : \"npm test\""))
        #expect(!scanJSON.contains("Run npm test before committing changes."))
    }

    @Test
    func scanConfirmsWhenDocumentedValidationCommandMatchesRepositoryFacts() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """,
            "AGENTS.md": "Use swift test for validation."
        ])
        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: "")
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(context.contains("Fact: Project instructions and repository files both support SwiftPM validation."))
        #expect(context.contains("Hint: Prefer `swift test` for local validation."))
        #expect(!context.contains("Warning: Project instructions mention"))
        #expect(!context.contains("Use swift test for validation."))
    }

    @Test
    func scanEmitsOpenUncertaintyWhenDocumentedValidationClaimsDisagree() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """,
            "AGENTS.md": "Use swift test for validation.",
            "README.md": "Run npm test before committing changes."
        ])
        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: "")
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(source: "AGENTS.md", command: "swift test"),
            ValidationCommandClaim(source: "README.md", command: "npm test")
        ])
        #expect(context.contains("Fact: Project instructions mention multiple validation workflows: SwiftPM, npm."))
        #expect(context.contains("Open uncertainty: Instruction files disagree on local validation; verify the intended command before following one documented claim."))
        #expect(context.contains("Hint: Prefer `swift test` only for ordinary local validation when repository facts still support it."))
        #expect(!context.contains("Project instructions and repository files both support SwiftPM validation."))
        #expect(!context.contains("Run npm test before committing changes."))
        #expect(!context.contains("Use swift test for validation."))
    }

    @Test
    func scanEmitsOpenUncertaintyWhenDocumentedValidationWorkflowIsUnsupportedByRepositoryFacts() throws {
        let projectURL = try makeProject(files: [
            "AGENTS.md": "Run npm test before committing changes."
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(source: "AGENTS.md", command: "npm test")
        ])
        #expect(context.contains("Fact: Repository files do not identify a primary validation workflow."))
        #expect(context.contains("Open uncertainty: Project instructions mention `npm test`, but repository facts do not confirm that validation workflow."))
        #expect(context.contains("Hint: Verify the documented command before using it for local validation."))
        #expect(!context.contains("Warning: Project instructions mention `npm test`"))
        #expect(!context.contains("Run npm test before committing changes."))
    }

    @Test
    func scanIgnoresNegatedDocumentedValidationCommandClaims() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """,
            "AGENTS.md": "Do not run npm test; use swift test for validation."
        ])
        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: "")
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(source: "AGENTS.md", command: "swift test")
        ])
        #expect(context.contains("Fact: Project instructions and repository files both support SwiftPM validation."))
        #expect(context.contains("Hint: Prefer `swift test` for local validation."))
        #expect(!context.contains("Project instructions mention multiple validation workflows"))
        #expect(!context.contains("Project instructions mention `npm test`"))
        #expect(!scanJSON.contains("\"command\" : \"npm test\""))
        #expect(!scanJSON.contains("Do not run npm test"))
    }

    @Test
    func scanIgnoresDocumentedBuildCommandWithoutValidationContext() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """,
            "README.md": "Run swift build before scanning this repository."
        ])
        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: "")
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(result.project.validationCommandClaims.isEmpty)
        #expect(!context.contains("Project instructions and repository files both support SwiftPM validation."))
    }

    @Test
    func scanIgnoresValidationCommandMetaDiscussion() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """,
            "docs/development_loop.md": """
            The xcodebuild test validation-claim case is now covered by scheme-discovery guidance.
            The Android observation is a good example: executable gradlew can align sanitized ./gradlew test claims with repository facts.
            Prefer swift test before committing core changes.
            """
        ])
        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: "")
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(source: "docs/development_loop.md", command: "swift test")
        ])
        #expect(context.contains("Fact: Project instructions and repository files both support SwiftPM validation."))
        #expect(!context.contains("Project instructions mention multiple validation workflows"))
        #expect(!context.contains("xcodebuild test"))
        #expect(!context.contains("./gradlew test"))
    }

    @Test
    func scanPromotesKnownProjectLocalValidationScriptWithoutExtraUncertainty() throws {
        let projectURL = try makeProject(files: [
            "settings.gradle.kts": "pluginManagement {}\n",
            "build.gradle.kts": "plugins { kotlin(\"jvm\") version \"2.0.0\" }\n",
            "docs/development_loop.md": """
            Unit test を確認する場合:

            HAZAKURA_GRADLE_TASK=:app:testNoLlmDebugUnitTest ./scripts/assemble-debug.sh
            """
        ])
        try writeExecutableScript(
            projectURL.appendingPathComponent("gradlew"),
            contents: "#!/bin/sh\n"
        )
        try writeExecutableScript(
            projectURL.appendingPathComponent("scripts/assemble-debug.sh"),
            contents: "#!/bin/sh\n"
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let writtenResult = try JSONDecoder().decode(
            ScanResult.self,
            from: Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        )

        assertAgentContextContract(context)
        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(source: "docs/development_loop.md", command: "./scripts/assemble-debug.sh")
        ])
        #expect(context.contains("Fact: Project instructions mention project-local validation script `./scripts/assemble-debug.sh`."))
        #expect(!context.contains("Open uncertainty: Verify whether the script wraps Gradle validation before using raw package-manager commands."))
        #expect(context.contains("Hint: Prefer `./scripts/assemble-debug.sh` when repository docs make it the validation entrypoint."))
        #expect(context.contains("Prefer `./scripts/assemble-debug.sh`."))
        #expect(!context.contains("Prefer `./gradlew test`."))
        #expect(!context.contains("Prefer `./gradlew build`."))
        #expect(policy.contains("- `./scripts/assemble-debug.sh`"))
        #expect(writtenResult.policy.preferredCommands == ["./scripts/assemble-debug.sh"])
        #expect(writtenResult.policy.commandCounts.preferred == writtenResult.policy.preferredCommands.count)
        #expect(scanJSON.contains("\"source\" : \"docs/development_loop.md\""))
        #expect(scanJSON.contains("\"command\" : \"./scripts/assemble-debug.sh\""))
        #expect(!scanJSON.contains("HAZAKURA_GRADLE_TASK"))
        #expect(!context.contains("Unit test を確認する場合"))
    }

    @Test
    func scanDetectsGenericSafeProjectLocalValidationScriptClaims() throws {
        let projectURL = try makeProject(files: [
            "settings.gradle.kts": "pluginManagement {}\n",
            "build.gradle.kts": "plugins { kotlin(\"jvm\") version \"2.0.0\" }\n",
            "README.md": "Use ./scripts/verify-local.sh to validate the local build."
        ])
        try writeExecutableScript(
            projectURL.appendingPathComponent("gradlew"),
            contents: "#!/bin/sh\n"
        )
        try writeExecutableScript(
            projectURL.appendingPathComponent("scripts/verify-local.sh"),
            contents: "#!/bin/sh\n"
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(source: "README.md", command: "./scripts/verify-local.sh")
        ])
        #expect(context.contains("Fact: Project instructions mention project-local validation script `./scripts/verify-local.sh`."))
        #expect(context.contains("Open uncertainty: Verify whether the script wraps Gradle validation before using raw package-manager commands."))
        #expect(context.contains("Prefer `./scripts/verify-local.sh`."))
        #expect(context.contains("Prefer `./gradlew test`."))
        #expect(!context.contains("validate the local build"))
        #expect(scanJSON.contains("\"command\" : \"./scripts/verify-local.sh\""))
        #expect(!scanJSON.contains("validate the local build"))
    }

    @Test
    func scanIgnoresUnsafeProjectLocalValidationScriptClaims() throws {
        let projectURL = try makeProject(files: [
            "settings.gradle.kts": "pluginManagement {}\n",
            "build.gradle.kts": "plugins { kotlin(\"jvm\") version \"2.0.0\" }\n",
            "README.md": "Use ./scripts/../verify-local.sh to validate the local build, and keep ./scripts/verify-local.py as an example."
        ])
        try writeExecutableScript(
            projectURL.appendingPathComponent("gradlew"),
            contents: "#!/bin/sh\n"
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(result.project.validationCommandClaims.isEmpty)
        #expect(!context.contains("project-local validation script"))
        #expect(!context.contains("./scripts/../verify-local.sh"))
        #expect(!context.contains("./scripts/verify-local.py"))
        #expect(context.contains("Prefer `./gradlew test`."))
    }

    @Test
    func scanSeparatesReleaseArtifactScriptFromOrdinaryValidationClaim() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.1\n",
            "README.md": """
            Manual artifact build:

            ```bash
            ./scripts/build_release_artifacts.sh
            ```
            """,
            "docs/development_loop.md": "Run swift test before committing core changes."
        ])
        try writeExecutableScript(
            projectURL.appendingPathComponent("scripts/build_release_artifacts.sh"),
            contents: "#!/bin/sh\n"
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: "")
        ])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)

        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(
                source: "README.md",
                command: "./scripts/build_release_artifacts.sh",
                purpose: .releaseArtifact
            ),
            ValidationCommandClaim(source: "docs/development_loop.md", command: "swift test")
        ])
        #expect(!result.policy.preferredCommands.contains("./scripts/build_release_artifacts.sh"))
        #expect(context.contains("Hint: Prefer `swift test` for local validation."))
        #expect(context.contains("Fact: Project instructions mention release/artifact validation `./scripts/build_release_artifacts.sh`."))
        #expect(context.contains("Hint: Keep `./scripts/build_release_artifacts.sh` for release prep or artifact verification, not ordinary local validation."))
        #expect(!context.contains("- Prefer `./scripts/build_release_artifacts.sh`."))
        #expect(scanJSON.contains("\"purpose\" : \"release_artifact\""))
    }

    @Test
    func scanSeparatesDeviceVerificationScriptFromOrdinaryValidationClaim() throws {
        let projectURL = try makeProject(files: [
            "settings.gradle.kts": "pluginManagement {}\n",
            "build.gradle.kts": "plugins { kotlin(\"jvm\") version \"2.0.0\" }\n",
            "docs/development_environment.md": """
            For connected device verification:

            ./scripts/device-test.sh :app:connectedNoLlmDebugAndroidTest
            """
        ])
        try writeExecutableScript(
            projectURL.appendingPathComponent("gradlew"),
            contents: "#!/bin/sh\n"
        )
        try writeExecutableScript(
            projectURL.appendingPathComponent("scripts/device-test.sh"),
            contents: "#!/bin/sh\n"
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let writtenResult = try JSONDecoder().decode(
            ScanResult.self,
            from: Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        )

        assertAgentContextContract(context)
        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(
                source: "docs/development_environment.md",
                command: "./scripts/device-test.sh",
                purpose: .deviceVerification
            )
        ])
        #expect(writtenResult.policy.preferredCommands == ["./gradlew test", "./gradlew build"])
        #expect(!writtenResult.policy.preferredCommands.contains("./scripts/device-test.sh"))
        #expect(context.contains("Fact: Project instructions mention device verification `./scripts/device-test.sh`; keep it for connected-device checks, not ordinary local validation."))
        #expect(!context.contains("- Prefer `./scripts/device-test.sh`."))
        #expect(scanJSON.contains("\"purpose\" : \"device_verification\""))
    }

    @Test
    func scanSeparatesEnvironmentCheckScriptFromOrdinaryValidationClaim() throws {
        let projectURL = try makeProject(files: [
            "settings.gradle.kts": "pluginManagement {}\n",
            "build.gradle.kts": "plugins { kotlin(\"jvm\") version \"2.0.0\" }\n",
            "docs/development_environment.md": """
            Include environment checks when needed:

            ./scripts/dev-env-check.sh
            Then run ./scripts/assemble-debug.sh to validate the build.
            """
        ])
        try writeExecutableScript(
            projectURL.appendingPathComponent("gradlew"),
            contents: "#!/bin/sh\n"
        )
        try writeExecutableScript(
            projectURL.appendingPathComponent("scripts/dev-env-check.sh"),
            contents: "#!/bin/sh\n"
        )
        try writeExecutableScript(
            projectURL.appendingPathComponent("scripts/assemble-debug.sh"),
            contents: "#!/bin/sh\n"
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let writtenResult = try JSONDecoder().decode(
            ScanResult.self,
            from: Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        )

        assertAgentContextContract(context)
        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(
                source: "docs/development_environment.md",
                command: "./scripts/dev-env-check.sh",
                purpose: .environmentCheck
            ),
            ValidationCommandClaim(
                source: "docs/development_environment.md",
                command: "./scripts/assemble-debug.sh"
            )
        ])
        #expect(writtenResult.policy.preferredCommands == ["./scripts/assemble-debug.sh"])
        #expect(!writtenResult.policy.preferredCommands.contains("./scripts/dev-env-check.sh"))
        #expect(context.contains("Fact: Project instructions mention environment check `./scripts/dev-env-check.sh`; keep it for setup/preflight checks, not ordinary local validation."))
        #expect(context.contains("Hint: Prefer `./scripts/assemble-debug.sh` when repository docs make it the validation entrypoint."))
        #expect(!context.contains("- Prefer `./scripts/dev-env-check.sh`."))
        #expect(scanJSON.contains("\"purpose\" : \"environment_check\""))
    }

    @Test
    func scanSeparatesLaunchSmokeScriptFromOrdinaryValidationClaim() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": """
            // swift-tools-version: 6.1
            import PackageDescription
            let package = Package(name: "Demo")
            """,
            "docs/development_loop.md": """
            Run swift test for ordinary local validation.
            Use ./script/build_and_run.sh --verify for the app launch smoke check.
            """
        ])
        try writeExecutableScript(
            projectURL.appendingPathComponent("script/build_and_run.sh"),
            contents: "#!/bin/sh\n"
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [
            "/usr/bin/which -a swift": .init(name: "/usr/bin/which", args: ["-a", "swift"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/swift", stderr: ""),
            "/usr/bin/env swift --version": .init(name: "/usr/bin/env", args: ["swift", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Swift version 6.1", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: "")
        ])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let writtenResult = try JSONDecoder().decode(
            ScanResult.self,
            from: Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        )

        assertAgentContextContract(context)
        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(source: "docs/development_loop.md", command: "swift test"),
            ValidationCommandClaim(
                source: "docs/development_loop.md",
                command: "./script/build_and_run.sh --verify",
                purpose: .launchSmoke
            )
        ])
        #expect(writtenResult.policy.preferredCommands == ["swift test", "swift build"])
        #expect(!writtenResult.policy.preferredCommands.contains("./script/build_and_run.sh --verify"))
        #expect(context.contains("Fact: Project instructions and repository files both support SwiftPM validation."))
        #expect(context.contains("Fact: Project instructions mention launch smoke verification `./script/build_and_run.sh --verify`; keep it for app-launch smoke checks, not ordinary local validation."))
        #expect(context.contains("Hint: Prefer `swift test` for local validation."))
        #expect(!context.contains("- Prefer `./script/build_and_run.sh --verify`."))
        #expect(scanJSON.contains("\"command\" : \"./script/build_and_run.sh --verify\""))
        #expect(scanJSON.contains("\"purpose\" : \"launch_smoke\""))
        #expect(!scanJSON.contains("app launch smoke check"))
    }

    @Test
    func scanDeduplicatesSameValidationCommandAcrossInstructionFiles() throws {
        let projectURL = try makeProject(files: [
            "settings.gradle.kts": "pluginManagement {}\n",
            "build.gradle.kts": "plugins { kotlin(\"jvm\") version \"2.0.0\" }\n",
            "README.md": "Use ./scripts/assemble-debug.sh to validate the debug build.",
            "docs/development_loop.md": "Run ./scripts/assemble-debug.sh when checking the build."
        ])
        try writeExecutableScript(
            projectURL.appendingPathComponent("gradlew"),
            contents: "#!/bin/sh\n"
        )
        try writeExecutableScript(
            projectURL.appendingPathComponent("scripts/assemble-debug.sh"),
            contents: "#!/bin/sh\n"
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(source: "README.md", command: "./scripts/assemble-debug.sh")
        ])
        #expect(context.contains("Fact: Project instructions mention project-local validation script `./scripts/assemble-debug.sh`."))
        #expect(!context.contains("Project instructions mention multiple validation workflows"))
        #expect(scanJSON.components(separatedBy: "\"command\" : \"./scripts/assemble-debug.sh\"").count == 2)
        #expect(!scanJSON.contains("\"source\" : \"docs/development_loop.md\""))
    }

    @Test
    func scanDoesNotPromoteMissingProjectLocalValidationScriptIntoPrefer() throws {
        let projectURL = try makeProject(files: [
            "settings.gradle.kts": "pluginManagement {}\n",
            "build.gradle.kts": "plugins { kotlin(\"jvm\") version \"2.0.0\" }\n",
            "README.md": "Use ./scripts/assemble-debug.sh to validate the debug build."
        ])
        try writeExecutableScript(
            projectURL.appendingPathComponent("gradlew"),
            contents: "#!/bin/sh\n"
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let writtenResult = try JSONDecoder().decode(
            ScanResult.self,
            from: Data(contentsOf: outputURL.appendingPathComponent("scan_result.json"))
        )

        assertAgentContextContract(context)
        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(source: "README.md", command: "./scripts/assemble-debug.sh")
        ])
        #expect(context.contains("Fact: Project instructions mention project-local validation script `./scripts/assemble-debug.sh`."))
        #expect(context.contains("Open uncertainty: Verify whether the script wraps Gradle validation before using raw package-manager commands."))
        #expect(context.contains("Hint: Do not prefer `./scripts/assemble-debug.sh` until the script exists and is executable."))
        #expect(!context.contains("- Prefer `./scripts/assemble-debug.sh`."))
        #expect(context.contains("- Prefer `./gradlew test`."))
        #expect(context.contains("- Prefer `./gradlew build`."))
        #expect(writtenResult.policy.preferredCommands == ["./gradlew test", "./gradlew build"])
    }

    @Test
    func scanConstrainsDocumentedXcodebuildTestClaimToSchemeDiscovery() throws {
        let projectURL = try makeProject(files: [
            "Demo App.xcodeproj/project.pbxproj": "// synthetic project marker",
            "AGENTS.md": "Use xcodebuild test for local validation."
        ])
        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a xcodebuild": .init(name: "/usr/bin/which", args: ["-a", "xcodebuild"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/usr/bin/xcodebuild", stderr: ""),
            "/usr/bin/env xcodebuild -version": .init(name: "/usr/bin/env", args: ["xcodebuild", "-version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Xcode 16.3\nBuild version 16E140", stderr: ""),
            "/usr/bin/xcode-select -p": .init(name: "/usr/bin/xcode-select", args: ["-p"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/Applications/Xcode.app/Contents/Developer", stderr: "")
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let scanJSON = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)

        assertAgentContextContract(context)
        #expect(result.project.validationCommandClaims == [
            ValidationCommandClaim(source: "AGENTS.md", command: "xcodebuild test")
        ])
        #expect(result.project.packageManager == "xcodebuild")
        #expect(context.contains("Fact: Project instructions and repository files both support Xcode validation."))
        #expect(context.contains("Hint: Start with `xcodebuild -list -project 'Demo App.xcodeproj'` before following documented `xcodebuild test` validation."))
        #expect(context.contains("Ask before `xcodebuild build/test/archive before selecting a scheme`."))
        #expect(!context.contains("Use xcodebuild test for local validation."))
        #expect(scanJSON.contains("\"command\" : \"xcodebuild test\""))
        #expect(!scanJSON.contains("Use xcodebuild test for local validation."))
    }
}
