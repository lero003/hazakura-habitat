import Testing
import Foundation
@testable import HabitatCore

struct ScanComparisonTests {
    @Test
    func scanComparisonSurfacesActionableDeltas() throws {
        let previous = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["package.json", "package-lock.json"], packageManager: "npm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(
                resolvedPaths: [
                    .init(name: "node", paths: ["/opt/homebrew/bin/node"]),
                    .init(name: "npm", paths: ["/opt/homebrew/bin/npm"]),
                    .init(name: "pnpm", paths: []),
                ],
                versions: []
            ),
            policy: .init(preferredCommands: ["npm run"], askFirstCommands: ["npm install"], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: []
        )
        let current = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T01:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["package.json", "pnpm-lock.yaml"], packageManager: "pnpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(
                resolvedPaths: [
                    .init(name: "node", paths: []),
                    .init(name: "npm", paths: ["/opt/homebrew/bin/npm"]),
                    .init(name: "pnpm", paths: []),
                ],
                versions: []
            ),
            policy: .init(
                preferredCommands: ["pnpm run"],
                askFirstCommands: ["running pnpm commands before pnpm is available", "pnpm install"],
                forbiddenCommands: ["sudo", "brew upgrade"]
            ),
            warnings: ["Project files prefer pnpm, but pnpm was not found on PATH; ask before running pnpm commands or substituting another package manager."],
            diagnostics: []
        )

        let changes = ScanComparator().compare(previous: previous, current: current)

        #expect(changes.contains(where: { $0.category == "package_manager" && $0.summary.contains("npm to pnpm") }))
        #expect(changes.contains(where: { $0.category == "lockfiles" && $0.summary.contains("added pnpm-lock.yaml") && $0.summary.contains("removed package-lock.json") }))
        #expect(changes.contains(where: { $0.category == "missing_tools" && $0.summary.contains("node") && $0.summary.contains("pnpm") }))
        #expect(changes.contains(where: { $0.category == "command_policy" && $0.summary.contains("New Ask First commands") }))
        #expect(changes.contains(where: { $0.category == "command_policy" && $0.summary.contains("New Forbidden commands") }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: current.withChanges(changes), outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let report = try String(contentsOf: outputURL.appendingPathComponent("environment_report.md"), encoding: .utf8)

        #expect(scanResult.contains("\"changes\""))
        #expect(scanResult.contains("\"category\" : \"package_manager\""))
        #expect(context.contains("Package manager changed from npm to pnpm."))
        #expect(context.contains("Ask before these commands even if a previous scan did not require it."))
        #expect(report.contains("## Changes Since Previous Scan"))
        #expect(report.contains("[lockfiles] Lockfiles changed"))
    }

    @Test
    func scanComparisonSurfacesGeneratorVersionDeltas() throws {
        let previous = ScanResult(
            schemaVersion: "0.1",
            generatorVersion: "0.0.9",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["swift test"], askFirstCommands: [], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: []
        )
        let current = ScanResult(
            schemaVersion: "0.1",
            generatorVersion: HabitatMetadata.generatorVersion,
            scannedAt: "2026-04-25T01:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["swift test"], askFirstCommands: [], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: []
        )

        let changes = ScanComparator().compare(previous: previous, current: current)

        #expect(changes.first?.category == "generator")
        #expect(changes.first?.summary == "Generator version changed from 0.0.9 to \(HabitatMetadata.generatorVersion).")
        #expect(changes.first?.impact.contains("before assuming the local environment changed") == true)
    }

    @Test
    func scanComparisonSeparatesResolvedAndIrrelevantMissingTools() throws {
        let previous = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["go.mod"], packageManager: "go", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(
                resolvedPaths: [
                    .init(name: "go", paths: []),
                    .init(name: "node", paths: []),
                ],
                versions: []
            ),
            policy: .init(
                preferredCommands: ["go test ./..."],
                askFirstCommands: ["running Go commands before go is available", "go get"],
                forbiddenCommands: ["sudo"]
            ),
            warnings: ["Project files prefer Go, but go was not found on PATH; ask before running Go commands."],
            diagnostics: []
        )
        let current = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T01:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["package.json", "package-lock.json"], packageManager: "npm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(
                resolvedPaths: [
                    .init(name: "go", paths: []),
                    .init(name: "node", paths: ["/opt/homebrew/bin/node"]),
                    .init(name: "npm", paths: ["/opt/homebrew/bin/npm"]),
                ],
                versions: []
            ),
            policy: .init(
                preferredCommands: ["npm run"],
                askFirstCommands: ["npm install"],
                forbiddenCommands: ["sudo"]
            ),
            warnings: [],
            diagnostics: []
        )

        let changes = ScanComparator().compare(previous: previous, current: current)

        #expect(changes.contains(where: {
            $0.summary == "Previously missing tools are no longer project-relevant: go."
                && $0.impact == "Do not treat them as available; follow the current project signals and command policy."
        }))
        #expect(!changes.contains(where: {
            $0.summary == "Project-relevant tools are now available: go."
        }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: current.withChanges(changes), outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Previously missing tools are no longer project-relevant: go. Do not treat them as available; follow the current project signals and command policy."))
    }

    @Test
    func scanComparisonDoesNotReportRecoveredToolsWhenVersionChecksFail() throws {
        let previous = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["package.json", "package-lock.json"], packageManager: "npm", packageManagerVersion: nil, packageScripts: ["test"], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(
                resolvedPaths: [
                    .init(name: "node", paths: []),
                    .init(name: "npm", paths: []),
                ],
                versions: []
            ),
            policy: .init(
                preferredCommands: ["npm run test"],
                askFirstCommands: [
                    "running JavaScript commands before node is available",
                    "running npm commands before npm is available",
                    "npm install",
                ],
                forbiddenCommands: ["sudo"]
            ),
            warnings: [],
            diagnostics: []
        )
        let current = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T01:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["package.json", "package-lock.json"], packageManager: "npm", packageManagerVersion: nil, packageScripts: ["test"], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(
                resolvedPaths: [
                    .init(name: "node", paths: ["/opt/homebrew/bin/node"]),
                    .init(name: "npm", paths: ["/opt/homebrew/bin/npm"]),
                ],
                versions: [
                    .init(name: "node", version: nil, available: false),
                    .init(name: "npm", version: nil, available: false),
                ]
            ),
            policy: .init(
                preferredCommands: ["npm run test"],
                askFirstCommands: [
                    "running JavaScript commands before node version check succeeds",
                    "running npm commands before npm version check succeeds",
                    "npm install",
                ],
                forbiddenCommands: ["sudo"]
            ),
            warnings: [],
            diagnostics: [
                "node --version failed with exit code 1: node failed",
                "npm --version failed with exit code 1: npm failed",
            ]
        )

        let changes = ScanComparator().compare(previous: previous, current: current)

        #expect(!changes.contains(where: {
            $0.summary == "Project-relevant tools are now available: node, npm."
        }))
        #expect(changes.contains(where: {
            $0.summary == "Project-relevant tool checks now fail: node, npm."
                && $0.impact == "Treat related build, test, or install commands as Ask First until the current command policy allows them."
        }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: current.withChanges(changes), outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(!context.contains("Project-relevant tools are now available: node, npm."))
        #expect(context.contains("Project-relevant tool checks now fail: node, npm. Treat related build, test, or install commands as Ask First until the current command policy allows them."))
    }

    @Test
    func scanComparisonReportsRelevantToolVerificationFailures() throws {
        let previous = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(
                resolvedPaths: [
                    .init(name: "swift", paths: ["/usr/bin/swift"]),
                    .init(name: "xcode-select", paths: ["/usr/bin/xcode-select"]),
                ],
                versions: [
                    .init(name: "swift", version: "Swift version 6.1", available: true),
                    .init(name: "xcode-select", version: "/Applications/Xcode.app/Contents/Developer", available: true),
                ]
            ),
            policy: .init(
                preferredCommands: ["swift test", "swift build"],
                askFirstCommands: ["swift package update"],
                forbiddenCommands: ["sudo"]
            ),
            warnings: [],
            diagnostics: []
        )
        let current = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T01:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(
                resolvedPaths: [
                    .init(name: "swift", paths: ["/usr/bin/swift"]),
                    .init(name: "xcode-select", paths: ["/usr/bin/xcode-select"]),
                ],
                versions: [
                    .init(name: "swift", version: "Swift version 6.1", available: true),
                    .init(name: "xcode-select", version: nil, available: false),
                ]
            ),
            policy: .init(
                preferredCommands: ["swift test", "swift build"],
                askFirstCommands: ["Swift/Xcode build commands before xcode-select -p succeeds", "swift package update"],
                forbiddenCommands: ["sudo"]
            ),
            warnings: ["xcode-select -p did not return a developer directory; ask before Swift/Xcode build or test commands."],
            diagnostics: ["xcode-select -p failed with exit code 2: xcode-select: error: tool 'xcodebuild' requires Xcode"]
        )

        let changes = ScanComparator().compare(previous: previous, current: current)

        #expect(changes.contains(where: {
            $0.summary == "Project-relevant tool checks now fail: xcode-select."
                && $0.impact == "Treat related build, test, or install commands as Ask First until the current command policy allows them."
        }))
        #expect(!changes.contains(where: {
            $0.category == "missing_tools" && $0.summary.contains("xcode-select")
        }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: current.withChanges(changes), outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)

        #expect(context.contains("Project-relevant tool checks now fail: xcode-select. Treat related build, test, or install commands as Ask First until the current command policy allows them."))
        #expect(scanResult.contains("\"category\" : \"tool_verification\""))
    }

    @Test
    func scanComparisonReportsPackageManagerVersionGuidanceChanges() throws {
        let previous = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(
                detectedFiles: ["package.json", "pnpm-lock.yaml"],
                packageManager: "pnpm",
                packageManagerVersion: "9.15.4",
                packageManagerVersionSource: "package.json",
                packageScripts: ["test"],
                runtimeHints: .init(node: nil, python: nil),
                declaredPackageManager: "pnpm",
                declaredPackageManagerVersion: "9.15.4"
            ),
            tools: .init(
                resolvedPaths: [
                    .init(name: "node", paths: ["/opt/homebrew/bin/node"]),
                    .init(name: "pnpm", paths: ["/opt/homebrew/bin/pnpm"]),
                ],
                versions: [
                    .init(name: "pnpm", version: "9.15.4", available: true),
                ]
            ),
            policy: .init(preferredCommands: ["pnpm run test"], askFirstCommands: ["pnpm install"], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: []
        )
        let current = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T01:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(
                detectedFiles: [".tool-versions", "package.json", "pnpm-lock.yaml"],
                packageManager: "pnpm",
                packageManagerVersion: "10.0.0",
                packageManagerVersionSource: ".tool-versions",
                packageScripts: ["test"],
                runtimeHints: .init(node: nil, python: nil),
                declaredPackageManager: "pnpm",
                declaredPackageManagerVersion: nil
            ),
            tools: .init(
                resolvedPaths: [
                    .init(name: "node", paths: ["/opt/homebrew/bin/node"]),
                    .init(name: "pnpm", paths: ["/opt/homebrew/bin/pnpm"]),
                ],
                versions: [
                    .init(name: "pnpm", version: "10.0.0", available: true),
                ]
            ),
            policy: .init(preferredCommands: ["pnpm run test"], askFirstCommands: ["pnpm install"], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: []
        )

        let changes = ScanComparator().compare(previous: previous, current: current)
        let packageManagerVersionChange = changes.first(where: { $0.category == "package_manager_version" })

        #expect(packageManagerVersionChange?.summary == "Package manager version guidance changed from pnpm@9.15.4 via package.json to pnpm@10.0.0 via .tool-versions.")
        #expect(packageManagerVersionChange?.impact == "Re-check the active pnpm version before dependency installs; follow current agent_context.md guidance.")
        #expect(!changes.contains(where: { $0.category == "package_manager" }))
        #expect(!changes.contains(where: { $0.category == "preferred_commands" }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: current.withChanges(changes), outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(scanResult.contains("\"category\" : \"package_manager_version\""))
        #expect(context.contains("Package manager version guidance changed from pnpm@9.15.4 via package.json to pnpm@10.0.0 via .tool-versions. Re-check the active pnpm version before dependency installs; follow current agent_context.md guidance."))
    }

    @Test
    func scanComparisonReportsRuntimeHintGuidanceChanges() throws {
        let previous = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(
                detectedFiles: [".nvmrc", "package.json", "pnpm-lock.yaml"],
                packageManager: "pnpm",
                packageManagerVersion: nil,
                packageScripts: ["test"],
                runtimeHints: .init(node: "20.11.1", python: nil, ruby: "3.2.0")
            ),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["pnpm run test"], askFirstCommands: ["pnpm install"], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: []
        )
        let current = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T01:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(
                detectedFiles: [".nvmrc", ".python-version", "package.json", "pnpm-lock.yaml"],
                packageManager: "pnpm",
                packageManagerVersion: nil,
                packageScripts: ["test"],
                runtimeHints: .init(node: "22.0.0", python: "3.12.2", ruby: nil)
            ),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["pnpm run test"], askFirstCommands: ["pnpm install"], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: []
        )

        let changes = ScanComparator().compare(previous: previous, current: current)
        let runtimeHintChange = changes.first(where: { $0.category == "runtime_hints" })

        #expect(runtimeHintChange?.summary == "Runtime version guidance changed: Node 20.11.1 -> 22.0.0; Python none -> 3.12.2; Ruby 3.2.0 -> none.")
        #expect(runtimeHintChange?.impact == "Re-check active runtimes before dependency installs or build/test commands; follow current command policy.")
        #expect(!changes.contains(where: { $0.category == "package_manager" }))
        #expect(!changes.contains(where: { $0.category == "preferred_commands" }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: current.withChanges(changes), outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(scanResult.contains("\"category\" : \"runtime_hints\""))
        #expect(context.contains("Runtime version guidance changed: Node 20.11.1 -> 22.0.0; Python none -> 3.12.2; Ruby 3.2.0 -> none. Re-check active runtimes before dependency installs or build/test commands; follow current command policy."))
    }

    @Test
    func scanComparisonReportsPreferredCommandChangesForSamePackageManager() throws {
        let previous = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["package.json"], packageManager: "npm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [
                .init(name: "node", paths: ["/opt/homebrew/bin/node"]),
                .init(name: "npm", paths: ["/opt/homebrew/bin/npm"]),
            ], versions: []),
            policy: .init(preferredCommands: ["npm run"], askFirstCommands: ["npm install"], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: []
        )
        let current = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T01:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["package.json"], packageManager: "npm", packageManagerVersion: nil, packageScripts: ["build", "test"], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [
                .init(name: "node", paths: ["/opt/homebrew/bin/node"]),
                .init(name: "npm", paths: ["/opt/homebrew/bin/npm"]),
            ], versions: []),
            policy: .init(preferredCommands: ["npm run test", "npm run build"], askFirstCommands: ["npm install"], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: []
        )

        let changes = ScanComparator().compare(previous: previous, current: current)
        let preferredChange = changes.first(where: { $0.category == "preferred_commands" })

        #expect(preferredChange?.summary == "Preferred commands changed from npm run to npm run test, npm run build.")
        #expect(preferredChange?.impact == "Re-check command_policy.md; use only current allowed preferred commands.")

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: current.withChanges(changes), outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(scanResult.contains("\"category\" : \"preferred_commands\""))
        #expect(context.contains("Preferred commands changed from npm run to npm run test, npm run build. Re-check command_policy.md; use only current allowed preferred commands."))
    }

    @Test
    func scanComparisonSeparatesCommandPolicyRiskTransitions() throws {
        let previous = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["package.json"], packageManager: "npm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(
                preferredCommands: ["npm run"],
                askFirstCommands: ["npm install", "npx"],
                forbiddenCommands: ["sudo", "brew upgrade"]
            ),
            warnings: [],
            diagnostics: []
        )
        let current = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T01:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["package.json"], packageManager: "npm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(
                preferredCommands: ["npm run"],
                askFirstCommands: ["brew upgrade", "npm install", "pnpm install"],
                forbiddenCommands: ["sudo", "npx", "npm install -g"]
            ),
            warnings: [],
            diagnostics: []
        )

        let changes = ScanComparator().compare(previous: previous, current: current)

        #expect(changes.contains(where: {
            $0.summary == "Commands changed from Ask First to Forbidden: npx."
                && $0.impact == "Refuse these commands under the current scan policy."
        }))
        #expect(changes.contains(where: {
            $0.summary == "Commands changed from Forbidden to Ask First: brew upgrade."
                && $0.impact == "Ask before these commands; do not refuse solely because a previous scan did."
        }))
        #expect(changes.contains(where: {
            $0.summary == "New Ask First commands: pnpm install."
        }))
        #expect(changes.contains(where: {
            $0.summary == "New Forbidden commands: npm install -g."
        }))
        #expect(!changes.contains(where: {
            $0.summary.contains("New Ask First commands") && $0.summary.contains("brew upgrade")
        }))
        #expect(!changes.contains(where: {
            $0.summary.contains("New Forbidden commands") && $0.summary.contains("npx")
        }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: current.withChanges(changes), outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Commands changed from Ask First to Forbidden: npx. Refuse these commands under the current scan policy."))
        #expect(context.contains("Commands changed from Forbidden to Ask First: brew upgrade. Ask before these commands; do not refuse solely because a previous scan did."))
    }

    @Test
    func scanComparisonReportsResolvedCommandPolicyEntries() throws {
        let previous = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["package.json", "pnpm-lock.yaml"], packageManager: "pnpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(
                preferredCommands: ["pnpm run"],
                askFirstCommands: ["running pnpm commands before pnpm is available", "pnpm install"],
                forbiddenCommands: ["sudo", "legacy forbidden command"]
            ),
            warnings: [],
            diagnostics: []
        )
        let current = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T01:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["package.json", "pnpm-lock.yaml"], packageManager: "pnpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(
                preferredCommands: ["pnpm run"],
                askFirstCommands: ["pnpm install"],
                forbiddenCommands: ["sudo"]
            ),
            warnings: [],
            diagnostics: []
        )

        let changes = ScanComparator().compare(previous: previous, current: current)

        #expect(changes.contains(where: {
            $0.summary == "Ask First commands no longer highlighted: running pnpm commands before pnpm is available."
                && $0.impact == "Do not ask solely because a previous scan did; apply the current command policy."
        }))
        #expect(changes.contains(where: {
            $0.summary == "Forbidden commands no longer highlighted: legacy forbidden command."
                && $0.impact == "Do not refuse solely because a previous scan did; apply the current command policy."
        }))
        #expect(!changes.contains(where: {
            $0.summary.contains("changed from Ask First to Forbidden")
        }))
        #expect(!changes.contains(where: {
            $0.summary.contains("changed from Forbidden to Ask First")
        }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: current.withChanges(changes), outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Ask First commands no longer highlighted: running pnpm commands before pnpm is available. Do not ask solely because a previous scan did; apply the current command policy."))
        #expect(context.contains("Forbidden commands no longer highlighted: legacy forbidden command. Do not refuse solely because a previous scan did; apply the current command policy."))
    }
}
