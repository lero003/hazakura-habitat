import Testing
import Foundation
@testable import HabitatCore

struct FakeCommandRunner: CommandRunning {
    let results: [String: CommandInfo]

    func run(executable: String, arguments: [String], timeout: TimeInterval) -> CommandInfo {
        let key = ([executable] + arguments).joined(separator: " ")
        return results[key] ?? CommandInfo(
            name: executable,
            args: arguments,
            exitCode: nil,
            durationMs: 0,
            timedOut: false,
            available: false,
            stdout: "",
            stderr: "missing"
        )
    }
}

func assertAgentContextContract(_ context: String) {
    let headings = context
        .split(whereSeparator: \.isNewline)
        .map(String.init)
        .filter { $0.hasPrefix("#") }

    #expect(headings == [
        "# Agent Context",
        "## Use",
        "## Prefer",
        "## Ask First",
        "## Do Not",
        "## Notes"
    ])
    #expect(context.split(whereSeparator: \.isNewline).count <= 120)
}

func assertCommandPolicyContract(_ policy: String) {
    let headings = policy
        .split(whereSeparator: \.isNewline)
        .map(String.init)
        .filter { $0.hasPrefix("#") }

    #expect(headings == [
        "# Command Policy",
        "## Policy Index",
        "## Review First",
        "## Reason Codes",
        "## Allowed",
        "## Ask First",
        "## Forbidden",
        "## If Dependency Installation Seems Necessary"
    ])
}

func lineCount(_ text: String) -> Int {
    guard !text.isEmpty else { return 0 }
    return text.split(separator: "\n", omittingEmptySubsequences: false).count
}

func headingLine(_ heading: String, in text: String) -> Int? {
    text.split(separator: "\n", omittingEmptySubsequences: false)
        .enumerated()
        .first { _, line in
            line.trimmingCharacters(in: .whitespaces) == "## \(heading)"
                || line.trimmingCharacters(in: .whitespaces) == "# \(heading)"
        }
        .map { index, _ in index + 1 }
}

func section(_ text: String, _ heading: String, appearsBefore laterHeading: String) -> Bool {
    guard let headingRange = text.range(of: heading),
          let laterHeadingRange = text.range(of: laterHeading) else {
        return false
    }

    return headingRange.lowerBound < laterHeadingRange.lowerBound
}

func writeExecutableScript(_ url: URL, contents: String) throws {
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try contents.write(to: url, atomically: true, encoding: .utf8)
    try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: url.path)
}

func makeProject(files: [String: String]) throws -> URL {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

    for (path, contents) in files {
        let fileURL = root.appendingPathComponent(path)
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    return root
}

func makeExecutableProjectVenvPython(_ projectURL: URL) throws {
    let pythonURL = projectURL.appendingPathComponent(".venv/bin/python")
    try FileManager.default.createDirectory(at: pythonURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try "#!/bin/sh\n".write(to: pythonURL, atomically: true, encoding: .utf8)
    try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: pythonURL.path)
}

func markdownSnapshotScanResult() -> ScanResult {
    ScanResult(
        schemaVersion: "0.1",
        scannedAt: "2026-04-25T00:00:00Z",
        projectPath: "/tmp/project",
        system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
        commands: [],
        project: .init(detectedFiles: [".nvmrc", "package.json", "pnpm-lock.yaml"], packageManager: "pnpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: "v20", python: nil)),
        tools: .init(resolvedPaths: [], versions: []),
        policy: .init(
            preferredCommands: ["pnpm", "pnpm test"],
            askFirstCommands: [
                "running pnpm commands before pnpm is available",
                "dependency installs before matching active Node to project version hints",
                "pnpm install",
                "modifying lockfiles"
            ],
            forbiddenCommands: ["sudo", "brew upgrade"]
        ),
        warnings: [
            "Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node).",
            "Project files prefer pnpm, but pnpm was not found on PATH; ask before running pnpm commands or substituting another package manager."
        ],
        diagnostics: ["node --version unavailable: missing"]
    )
}
