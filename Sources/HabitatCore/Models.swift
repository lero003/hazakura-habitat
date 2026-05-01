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
    public let artifacts: [GeneratedArtifact]

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
        changes: [ScanChange] = [],
        artifacts: [GeneratedArtifact] = []
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
        self.artifacts = artifacts
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
            changes: changes,
            artifacts: artifacts
        )
    }

    public func withArtifacts(_ artifacts: [GeneratedArtifact]) -> ScanResult {
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
            changes: changes,
            artifacts: artifacts
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
        case artifacts
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
        artifacts = try container.decodeIfPresent([GeneratedArtifact].self, forKey: .artifacts) ?? []
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
        try container.encode(artifacts, forKey: .artifacts)
    }
}

public struct GeneratedArtifact: Codable, Equatable {
    public let name: String
    public let role: String
    public let format: String
    public let readOrder: Int?
    public let lineCount: Int
    public let lineLimit: Int?

    public init(name: String, role: String, format: String, lineCount: Int, readOrder: Int? = nil, lineLimit: Int? = nil) {
        self.name = name
        self.role = role
        self.format = format
        self.readOrder = readOrder
        self.lineCount = lineCount
        self.lineLimit = lineLimit
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
    public let unsafeRuntimeHintFiles: [String]
    public let unsafePackageMetadataFields: [String]
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
        unsafeRuntimeHintFiles: [String] = [],
        unsafePackageMetadataFields: [String] = [],
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
        self.unsafeRuntimeHintFiles = unsafeRuntimeHintFiles
        self.unsafePackageMetadataFields = unsafePackageMetadataFields
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
        case unsafeRuntimeHintFiles
        case unsafePackageMetadataFields
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
        unsafeRuntimeHintFiles = try container.decodeIfPresent([String].self, forKey: .unsafeRuntimeHintFiles) ?? []
        unsafePackageMetadataFields = try container.decodeIfPresent([String].self, forKey: .unsafePackageMetadataFields) ?? []
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
        try container.encode(unsafeRuntimeHintFiles, forKey: .unsafeRuntimeHintFiles)
        try container.encode(unsafePackageMetadataFields, forKey: .unsafePackageMetadataFields)
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

public struct PolicyCommandReason: Codable, Equatable {
    public let command: String
    public let classification: String
    public let reasonCode: String
    public let reason: String

    public init(command: String, classification: String, reasonCode: String, reason: String) {
        self.command = command
        self.classification = classification
        self.reasonCode = reasonCode
        self.reason = reason
    }
}

public struct PolicySummary: Codable {
    public let preferredCommands: [String]
    public let askFirstCommands: [String]
    public let forbiddenCommands: [String]
    public let reasonCodes: [PolicyReasonCode]
    public let commandReasons: [PolicyCommandReason]

    public init(
        preferredCommands: [String],
        askFirstCommands: [String],
        forbiddenCommands: [String],
        reasonCodes: [PolicyReasonCode] = [],
        commandReasons: [PolicyCommandReason] = []
    ) {
        self.preferredCommands = preferredCommands
        self.askFirstCommands = askFirstCommands
        self.forbiddenCommands = forbiddenCommands
        self.reasonCodes = reasonCodes
        self.commandReasons = commandReasons
    }

    private enum CodingKeys: String, CodingKey {
        case preferredCommands
        case askFirstCommands
        case forbiddenCommands
        case reasonCodes
        case commandReasons
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        preferredCommands = try container.decode([String].self, forKey: .preferredCommands)
        askFirstCommands = try container.decode([String].self, forKey: .askFirstCommands)
        forbiddenCommands = try container.decode([String].self, forKey: .forbiddenCommands)
        reasonCodes = try container.decodeIfPresent([PolicyReasonCode].self, forKey: .reasonCodes) ?? []
        commandReasons = try container.decodeIfPresent([PolicyCommandReason].self, forKey: .commandReasons) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(preferredCommands, forKey: .preferredCommands)
        try container.encode(askFirstCommands, forKey: .askFirstCommands)
        try container.encode(forbiddenCommands, forKey: .forbiddenCommands)
        try container.encode(reasonCodes, forKey: .reasonCodes)
        try container.encode(commandReasons, forKey: .commandReasons)
    }
}
