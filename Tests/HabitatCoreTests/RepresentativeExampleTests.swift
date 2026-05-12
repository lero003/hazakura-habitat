import Testing
import Foundation
@testable import HabitatCore

struct RepresentativeExampleTests {
    @Test
    func representativeAgentContextExamplesKeepFixedContract() throws {
        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let examplePaths = [
            "examples/swift-package/agent_context.md",
            "examples/node-pnpm-conflict/agent_context.md",
            "examples/python-uv-missing-tool/agent_context.md",
            "examples/cargo-version-check-failure/agent_context.md",
            "examples/secret-bearing-files/agent_context.md",
        ]

        for path in examplePaths {
            let context = try String(contentsOf: rootURL.appendingPathComponent(path), encoding: .utf8)

            assertAgentContextContract(context)
            #expect(!context.contains("## Freshness"), "Representative examples should keep freshness in Notes: \(path)")
            #expect(!context.contains("## Avoid"), "Representative examples should use Do Not for current output shape: \(path)")
            #expect(!context.contains("## Warnings"), "Representative examples should keep warning details in Notes: \(path)")
            #expect(
                context.contains("- Freshness: regenerate if key project files changed after this timestamp; `scan_result.json` includes observed file mtimes."),
                "Representative examples should point stale-report checks to scan_result.json observed file metadata: \(path)"
            )
            #expect(
                context.contains("- Latest observed file: "),
                "Representative examples should show the newest observed project file in the short context: \(path)"
            )
            #expect(
                context.contains("- Read order: this file first; `command_policy.md` before risky commands; `environment_report.md` only for diagnostics."),
                "Representative examples should tell agents where to stop or continue reading: \(path)"
            )
            #expect(
                context.contains("- Scope: short working context; full approval detail is in `command_policy.md`."),
                "Representative examples should keep full policy detail out of agent_context.md: \(path)"
            )
        }
    }

    @Test
    func pythonUvMissingToolExampleMatchesCurrentGuidanceShape() throws {
        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let context = try String(
            contentsOf: rootURL.appendingPathComponent("examples/python-uv-missing-tool/agent_context.md"),
            encoding: .utf8
        )

        #expect(context.contains("- Verify `uv` before running uv commands."))
        #expect(context.contains("- Prefer read-only inspection before mutation."))
        #expect(context.contains("- Ask before `running uv commands before uv is available`."))
        #expect(context.contains("- Ask before `uv sync`."))
        #expect(context.contains("other reason codes: `dependency_resolution_mutation`, `version_manager_mutation`, `dependency_mutation`, more"))
        #expect(context.contains("Project files prefer uv, but uv was not found on PATH; ask before running uv commands or substituting another package manager."))
        #expect(!context.contains("Do not auto-install uv."))
        #expect(!context.contains("Ask before using `pip install`, `pip sync`, or `python -m pip install` as a fallback."))
    }

    @Test
    func secretBearingCommandPolicyExampleKeepsSearchGuidanceNearTop() throws {
        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let policy = try String(
            contentsOf: rootURL.appendingPathComponent("examples/secret-bearing-files/command_policy.md"),
            encoding: .utf8
        )
        let headings = policy
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .filter { $0.hasPrefix("#") }

        #expect(headings == [
            "# Command Policy",
            "## Policy Index",
            "## Review First",
            "## Reason Codes",
            "## If Secret-Bearing Files Are Detected",
            "## Allowed",
            "## Ask First",
            "## Forbidden",
            "## If Dependency Installation Seems Necessary"
        ])
        #expect(policy.contains("`If Secret-Bearing Files Are Detected` - 3 detected paths requiring exclusions before broad search or export."))
        #expect(policy.contains("`recursive project search without excluding secret-bearing files` (`secret_or_credential_access`) - Command can read, expose, copy, or load secrets or credentials."))
        #expect(policy.contains("Named source or test files that are not detected secret-bearing paths can be inspected directly."))
        #expect(policy.contains("For necessary broad search, start with exclusion-aware `rg`: `rg <pattern> --glob '!.env' --glob '!.env.*' --glob '!.npmrc' --glob '!id_ed25519'`."))
        #expect(policy.contains("For necessary Git-tracked search, use pathspec exclusions: `git grep <pattern> -- . ':(exclude).env' ':(exclude).env.*' ':(exclude).npmrc' ':(exclude)id_ed25519'`."))
        #expect(policy.contains("Apply equivalent exclusions before broad `grep -R`, `git grep`, copy, sync, or archive commands."))
        #expect(policy.contains("Prefer targeted source/test inspection over broad `rg`, `grep -R`, `git grep`, `rsync`, `tar`, `zip`, or `git archive` commands."))
        #expect(policy.contains("`targeted read-only source/test inspection that avoids detected secret-bearing paths`"))
        #expect(!policy.contains("`read-only project inspection, including rg <pattern>`"))
    }

    @Test
    func cargoVersionCheckFailureExampleMatchesCurrentGuidanceShape() throws {
        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let context = try String(
            contentsOf: rootURL.appendingPathComponent("examples/cargo-version-check-failure/agent_context.md"),
            encoding: .utf8
        )

        #expect(context.contains("- Verify `cargo` before running Cargo commands."))
        #expect(context.contains("- Prefer read-only inspection before mutation."))
        #expect(context.contains("- Ask before `running Cargo commands before cargo version check succeeds`."))
        #expect(context.contains("- Ask before `cargo add`."))
        #expect(context.contains("- Ask before `cargo update`."))
        #expect(context.contains("- Ask before `cargo remove`."))
        #expect(context.contains("other reason codes: `dependency_resolution_mutation`, `version_manager_mutation`, `dependency_mutation`, more"))
        #expect(context.contains("cargo --version failed with exit code 1: cargo: rustup toolchain is not installed"))
        #expect(!context.contains("Use `cargo` because project files point to it."))
        #expect(!context.contains("Prefer `cargo test`."))
        #expect(!context.contains("Do not auto-install Rust."))
    }

    @Test
    func swiftPackageExampleArtifactMetadataMatchesFiles() throws {
        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let exampleDirectories = [
            "examples/swift-package",
        ]

        for directory in exampleDirectories {
            let directoryURL = rootURL.appendingPathComponent(directory)
            let scanResultURL = directoryURL.appendingPathComponent("scan_result.json")
            let data = try Data(contentsOf: scanResultURL)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let artifacts = json?["artifacts"] as? [[String: Any]] ?? []
            let project = json?["project"] as? [String: Any] ?? [:]
            let observedFiles = project["observedFiles"] as? [[String: Any]] ?? []
            let policy = json?["policy"] as? [String: Any] ?? [:]
            let commandCounts = policy["commandCounts"] as? [String: Any] ?? [:]
            let preferredCommands = policy["preferredCommands"] as? [String] ?? []
            let askFirstCommands = policy["askFirstCommands"] as? [String] ?? []
            let forbiddenCommands = policy["forbiddenCommands"] as? [String] ?? []
            let commandReasons = policy["commandReasons"] as? [[String: Any]] ?? []
            let expectedAgentUse = [
                "agent_context.md": "read_first",
                "command_policy.md": "consult_before_risky_commands",
                "environment_report.md": "debug_audit_only",
            ]
            let expectedReadTrigger = [
                "agent_context.md": "before_any_project_command",
                "command_policy.md": "before_risky_remote_mutating_secret_or_environment_sensitive_commands",
                "environment_report.md": "only_for_diagnostics_or_audit",
            ]
            let expectedEntrySection = [
                "agent_context.md": "Use",
                "command_policy.md": "Review First",
                "environment_report.md": "Diagnostics",
            ]
            let expectedSections = [
                "agent_context.md": ["Agent Context", "Use", "Prefer", "Ask First", "Do Not", "Notes"],
                "command_policy.md": ["Command Policy", "Policy Index", "Review First", "Reason Codes", "Allowed", "Ask First", "Forbidden", "If Dependency Installation Seems Necessary"],
                "environment_report.md": ["Environment Report", "System", "Project Signals", "Symlinked Project Signals", "Resolved Tools", "Tool Versions", "Changes Since Previous Scan", "Warnings", "Diagnostics", "Privacy Note"],
            ]

            #expect(!artifacts.isEmpty, "Expected example artifact metadata in \(directory)")
            #expect(!observedFiles.isEmpty, "Expected example observed project-file freshness metadata in \(directory)")
            #expect(observedFiles.allSatisfy { ($0["path"] as? String)?.hasPrefix("/") == false })
            #expect(observedFiles.allSatisfy { ($0["modifiedAt"] as? String)?.isEmpty == false })
            #expect((project["latestObservedFilePath"] as? String)?.isEmpty == false)
            #expect((project["latestObservedFileModifiedAt"] as? String)?.isEmpty == false)
            #expect(commandCounts["preferred"] as? Int == preferredCommands.count)
            #expect(commandCounts["askFirst"] as? Int == askFirstCommands.count)
            #expect(commandCounts["reviewFirst"] as? Int == (policy["reviewFirstCommandReasons"] as? [[String: Any]] ?? []).count)
            #expect(commandCounts["forbidden"] as? Int == forbiddenCommands.count)
            #expect(commandCounts["withReasons"] as? Int == commandReasons.count)

            for artifact in artifacts {
                guard let name = artifact["name"] as? String,
                      let expectedLineCount = artifact["lineCount"] as? Int,
                      let expectedCharacterCount = artifact["characterCount"] as? Int else {
                    Issue.record("Malformed artifact metadata in \(directory)")
                    continue
                }

                let artifactURL = directoryURL.appendingPathComponent(name)
                let artifactText = try String(contentsOf: artifactURL, encoding: .utf8)
                #expect(
                    artifact["relativePath"] as? String == name,
                    "Expected \(directory)/\(name) relativePath metadata to point to the report-local artifact file"
                )
                #expect(
                    artifact["agentUse"] as? String == expectedAgentUse[name],
                    "Expected \(directory)/\(name) agentUse metadata to match its AI reading role"
                )
                #expect(
                    artifact["readTrigger"] as? String == expectedReadTrigger[name],
                    "Expected \(directory)/\(name) readTrigger metadata to explain when an agent should read it"
                )
                #expect(
                    artifact["entrySection"] as? String == expectedEntrySection[name],
                    "Expected \(directory)/\(name) entrySection metadata to point at the first useful section"
                )
                #expect(
                    (artifact["sections"] as? [String])?.contains(artifact["entrySection"] as? String ?? "") == true,
                    "Expected \(directory)/\(name) entrySection metadata to point at an existing Markdown heading"
                )
                #expect(
                    artifact["entryLine"] as? Int == headingLine(artifact["entrySection"] as? String ?? "", in: artifactText),
                    "Expected \(directory)/\(name) entryLine metadata to point at the entry heading"
                )
                #expect(
                    artifact["sections"] as? [String] == expectedSections[name],
                    "Expected \(directory)/\(name) sections metadata to match generated Markdown headings"
                )
                let sectionLines = artifact["sectionLines"] as? [[String: Any]]
                #expect(
                    sectionLines?.compactMap { $0["title"] as? String } == expectedSections[name],
                    "Expected \(directory)/\(name) sectionLines metadata to preserve Markdown heading order"
                )
                #expect(
                    sectionLines?.compactMap { $0["line"] as? Int } == expectedSections[name]?.compactMap { headingLine($0, in: artifactText) },
                    "Expected \(directory)/\(name) sectionLines metadata to point at each Markdown heading"
                )
                #expect(
                    lineCount(artifactText) == expectedLineCount,
                    "Expected \(directory)/\(name) lineCount metadata to match the example file"
                )
                #expect(
                    artifactText.count == expectedCharacterCount,
                    "Expected \(directory)/\(name) characterCount metadata to match the example file"
                )

                if name == "agent_context.md" {
                    #expect(artifact["lineLimit"] as? Int == 120)
                    #expect(artifact["withinLineLimit"] as? Bool == true)
                    #expect(expectedLineCount <= 120)
                } else {
                    #expect(artifact["lineLimit"] == nil)
                    #expect(artifact["withinLineLimit"] == nil)
                }
            }
        }
    }
}
