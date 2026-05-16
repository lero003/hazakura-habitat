import Foundation

public struct ScanOptions: Equatable {
    public let projectPath: String
    public let outputPath: String
    public let previousScanPath: String?
    public let stdoutArtifact: StdoutArtifact?

    public init(
        projectPath: String,
        outputPath: String,
        previousScanPath: String?,
        stdoutArtifact: StdoutArtifact? = nil
    ) {
        self.projectPath = projectPath
        self.outputPath = outputPath
        self.previousScanPath = previousScanPath
        self.stdoutArtifact = stdoutArtifact
    }
}

public enum StdoutArtifact: String, Equatable {
    case scanResult = "scan-result"
    case agentContext = "agent-context"
    case commandPolicy = "command-policy"
    case environmentReport = "environment-report"

    public static func parse(_ value: String) -> StdoutArtifact? {
        let normalizedValue = normalizedArtifactName(value)
        switch normalizedValue {
        case "scan-result", "scan_result.json":
            return .scanResult
        case "agent-context", "agent_context.md":
            return .agentContext
        case "command-policy", "command_policy.md":
            return .commandPolicy
        case "environment-report", "environment_report.md":
            return .environmentReport
        default:
            return nil
        }
    }

    private static func normalizedArtifactName(_ value: String) -> String {
        var normalizedValue = value
        while normalizedValue.hasPrefix("./") {
            normalizedValue = String(normalizedValue.dropFirst(2))
        }

        switch normalizedValue {
        case "scan-result", "scan_result.json":
            return normalizedValue
        case "agent-context", "agent_context.md":
            return normalizedValue
        case "command-policy", "command_policy.md":
            return normalizedValue
        case "environment-report", "environment_report.md":
            return normalizedValue
        default:
            break
        }

        let components = normalizedValue
            .split(separator: "/", omittingEmptySubsequences: true)
            .map(String.init)
        guard components.count >= 2,
              components[components.count - 2] == "habitat-report" else {
            return normalizedValue
        }

        return components.last ?? normalizedValue
    }
}

public enum ScanArgumentError: LocalizedError, Equatable {
    case missingValue(flag: String)
    case emptyValue(flag: String)
    case duplicateFlag(flag: String)
    case unknownArgument(String)
    case invalidStdoutArtifact(String)
    case incompatibleFlags(String, String)

    public var errorDescription: String? {
        switch self {
        case .missingValue(let flag):
            return "`\(flag)` requires a value."
        case .emptyValue(let flag):
            return "`\(flag)` value cannot be empty."
        case .duplicateFlag(let flag):
            return "`\(flag)` was provided more than once."
        case .unknownArgument(let argument):
            return "Unknown scan argument: `\(argument)`."
        case .invalidStdoutArtifact(let value):
            return "Unsupported `--stdout` artifact `\(value)`; use `scan-result`, `agent-context`, `command-policy`, `environment-report`, or the matching report filename, ./filename, habitat-report/filename, or an absolute saved-report path with a habitat-report path component."
        case .incompatibleFlags(let first, let second):
            return "`\(first)` and `\(second)` cannot be used together."
        }
    }
}

public struct ScanArgumentParser {
    public init() {}

    public func parse(arguments: [String], currentDirectory: String) throws -> ScanOptions {
        var values: [String: String] = [:]
        var index = 0

        while index < arguments.count {
            let argument = arguments[index]
            guard ["--project", "--output", "--previous-scan", "--stdout"].contains(argument) else {
                throw ScanArgumentError.unknownArgument(argument)
            }

            guard values[argument] == nil else {
                throw ScanArgumentError.duplicateFlag(flag: argument)
            }

            guard arguments.indices.contains(index + 1), !arguments[index + 1].hasPrefix("--") else {
                throw ScanArgumentError.missingValue(flag: argument)
            }

            guard !arguments[index + 1].isEmpty else {
                throw ScanArgumentError.emptyValue(flag: argument)
            }

            values[argument] = arguments[index + 1]
            index += 2
        }

        let stdoutArtifact: StdoutArtifact?
        if let stdoutValue = values["--stdout"] {
            guard let parsed = StdoutArtifact.parse(stdoutValue) else {
                throw ScanArgumentError.invalidStdoutArtifact(stdoutValue)
            }
            if values["--output"] != nil {
                throw ScanArgumentError.incompatibleFlags("--stdout", "--output")
            }
            stdoutArtifact = parsed
        } else {
            stdoutArtifact = nil
        }

        let outputPath = values["--output"] ?? URL(fileURLWithPath: currentDirectory)
            .appendingPathComponent("habitat-report")
            .path

        return ScanOptions(
            projectPath: values["--project"] ?? currentDirectory,
            outputPath: outputPath,
            previousScanPath: values["--previous-scan"],
            stdoutArtifact: stdoutArtifact
        )
    }
}
