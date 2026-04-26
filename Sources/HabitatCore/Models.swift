import Foundation

public struct ScanResult: Codable {
    public let schemaVersion: String
    public let scannedAt: String
    public let projectPath: String
    public let system: SystemInfo
    public let commands: [CommandInfo]
    public let project: ProjectInfo
    public let tools: ToolSummary
    public let policy: PolicySummary
    public let warnings: [String]
    public let diagnostics: [String]
}

public struct SystemInfo: Codable {
    public let operatingSystemVersion: String
    public let architecture: String
    public let shell: String?
    public let path: [String]
}

public struct CommandInfo: Codable {
    public let name: String
    public let args: [String]
    public let exitCode: Int32?
    public let durationMs: Int
    public let timedOut: Bool
    public let available: Bool
    public let stdout: String
    public let stderr: String
}

public struct ProjectInfo: Codable {
    public let detectedFiles: [String]
    public let packageManager: String?
    public let packageManagerVersion: String?
    public let packageScripts: [String]
    public let runtimeHints: RuntimeHints
}

public struct RuntimeHints: Codable {
    public let node: String?
    public let python: String?
}

public struct ToolSummary: Codable {
    public let resolvedPaths: [ResolvedTool]
    public let versions: [ToolVersion]
}

public struct ResolvedTool: Codable {
    public let name: String
    public let paths: [String]
}

public struct ToolVersion: Codable {
    public let name: String
    public let version: String?
    public let available: Bool
}

public struct PolicySummary: Codable {
    public let preferredCommands: [String]
    public let askFirstCommands: [String]
    public let forbiddenCommands: [String]
}
