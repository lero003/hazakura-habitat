import Foundation

public struct ScanResult: Codable {
    public let schemaVersion: String
    public let generatorVersion: String
    public let scannedAt: String
    public let projectPath: String
    public let system: SystemInfo
    public let commands: [CommandInfo]
    public let project: ProjectInfo
    public let tools: ToolSummary
    public let policy: PolicySummary
    public let warnings: [String]
    public let diagnostics: [String]
    public let changes: [ScanChange]

    public init(
        schemaVersion: String = HabitatMetadata.schemaVersion,
        generatorVersion: String = HabitatMetadata.generatorVersion,
        scannedAt: String,
        projectPath: String,
        system: SystemInfo,
        commands: [CommandInfo],
        project: ProjectInfo,
        tools: ToolSummary,
        policy: PolicySummary,
        warnings: [String],
        diagnostics: [String],
        changes: [ScanChange] = []
    ) {
        self.schemaVersion = schemaVersion
        self.generatorVersion = generatorVersion
        self.scannedAt = scannedAt
        self.projectPath = projectPath
        self.system = system
        self.commands = commands
        self.project = project
        self.tools = tools
        self.policy = policy
        self.warnings = warnings
        self.diagnostics = diagnostics
        self.changes = changes
    }

    public func withChanges(_ changes: [ScanChange]) -> ScanResult {
        ScanResult(
            schemaVersion: schemaVersion,
            generatorVersion: generatorVersion,
            scannedAt: scannedAt,
            projectPath: projectPath,
            system: system,
            commands: commands,
            project: project,
            tools: tools,
            policy: policy,
            warnings: warnings,
            diagnostics: diagnostics,
            changes: changes
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case generatorVersion
        case scannedAt
        case projectPath
        case system
        case commands
        case project
        case tools
        case policy
        case warnings
        case diagnostics
        case changes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(String.self, forKey: .schemaVersion)
        generatorVersion = try container.decodeIfPresent(String.self, forKey: .generatorVersion) ?? "unknown"
        scannedAt = try container.decode(String.self, forKey: .scannedAt)
        projectPath = try container.decode(String.self, forKey: .projectPath)
        system = try container.decode(SystemInfo.self, forKey: .system)
        commands = try container.decode([CommandInfo].self, forKey: .commands)
        project = try container.decode(ProjectInfo.self, forKey: .project)
        tools = try container.decode(ToolSummary.self, forKey: .tools)
        policy = try container.decode(PolicySummary.self, forKey: .policy)
        warnings = try container.decode([String].self, forKey: .warnings)
        diagnostics = try container.decode([String].self, forKey: .diagnostics)
        changes = try container.decodeIfPresent([ScanChange].self, forKey: .changes) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(generatorVersion, forKey: .generatorVersion)
        try container.encode(scannedAt, forKey: .scannedAt)
        try container.encode(projectPath, forKey: .projectPath)
        try container.encode(system, forKey: .system)
        try container.encode(commands, forKey: .commands)
        try container.encode(project, forKey: .project)
        try container.encode(tools, forKey: .tools)
        try container.encode(policy, forKey: .policy)
        try container.encode(warnings, forKey: .warnings)
        try container.encode(diagnostics, forKey: .diagnostics)
        try container.encode(changes, forKey: .changes)
    }
}

public struct ScanChange: Codable, Equatable {
    public let category: String
    public let summary: String
    public let impact: String

    public init(category: String, summary: String, impact: String) {
        self.category = category
        self.summary = summary
        self.impact = impact
    }
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
    public let symlinkedFiles: [String]
    public let packageManager: String?
    public let packageManagerVersion: String?
    public let packageManagerVersionSource: String?
    public let packageScripts: [String]
    public let runtimeHints: RuntimeHints
    public let declaredPackageManager: String?
    public let declaredPackageManagerVersion: String?

    public init(
        detectedFiles: [String],
        symlinkedFiles: [String] = [],
        packageManager: String?,
        packageManagerVersion: String?,
        packageManagerVersionSource: String? = nil,
        packageScripts: [String],
        runtimeHints: RuntimeHints,
        declaredPackageManager: String? = nil,
        declaredPackageManagerVersion: String? = nil
    ) {
        self.detectedFiles = detectedFiles
        self.symlinkedFiles = symlinkedFiles
        self.packageManager = packageManager
        self.packageManagerVersion = packageManagerVersion
        self.packageManagerVersionSource = packageManagerVersionSource
        self.packageScripts = packageScripts
        self.runtimeHints = runtimeHints
        self.declaredPackageManager = declaredPackageManager
        self.declaredPackageManagerVersion = declaredPackageManagerVersion
    }

    private enum CodingKeys: String, CodingKey {
        case detectedFiles
        case symlinkedFiles
        case packageManager
        case packageManagerVersion
        case packageManagerVersionSource
        case packageScripts
        case runtimeHints
        case declaredPackageManager
        case declaredPackageManagerVersion
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        detectedFiles = try container.decode([String].self, forKey: .detectedFiles)
        symlinkedFiles = try container.decodeIfPresent([String].self, forKey: .symlinkedFiles) ?? []
        packageManager = try container.decodeIfPresent(String.self, forKey: .packageManager)
        packageManagerVersion = try container.decodeIfPresent(String.self, forKey: .packageManagerVersion)
        packageManagerVersionSource = try container.decodeIfPresent(String.self, forKey: .packageManagerVersionSource)
        packageScripts = try container.decode([String].self, forKey: .packageScripts)
        runtimeHints = try container.decode(RuntimeHints.self, forKey: .runtimeHints)
        declaredPackageManager = try container.decodeIfPresent(String.self, forKey: .declaredPackageManager)
        declaredPackageManagerVersion = try container.decodeIfPresent(String.self, forKey: .declaredPackageManagerVersion)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(detectedFiles, forKey: .detectedFiles)
        try container.encode(symlinkedFiles, forKey: .symlinkedFiles)
        try container.encodeIfPresent(packageManager, forKey: .packageManager)
        try container.encodeIfPresent(packageManagerVersion, forKey: .packageManagerVersion)
        try container.encodeIfPresent(packageManagerVersionSource, forKey: .packageManagerVersionSource)
        try container.encode(packageScripts, forKey: .packageScripts)
        try container.encode(runtimeHints, forKey: .runtimeHints)
        try container.encodeIfPresent(declaredPackageManager, forKey: .declaredPackageManager)
        try container.encodeIfPresent(declaredPackageManagerVersion, forKey: .declaredPackageManagerVersion)
    }
}

public struct RuntimeHints: Codable {
    public let node: String?
    public let python: String?
    public let ruby: String?

    public init(node: String?, python: String?, ruby: String? = nil) {
        self.node = node
        self.python = python
        self.ruby = ruby
    }
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
