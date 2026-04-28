import Foundation

public struct ScanOptions: Equatable {
    public let projectPath: String
    public let outputPath: String
    public let previousScanPath: String?

    public init(projectPath: String, outputPath: String, previousScanPath: String?) {
        self.projectPath = projectPath
        self.outputPath = outputPath
        self.previousScanPath = previousScanPath
    }
}

public enum ScanArgumentError: LocalizedError, Equatable {
    case missingValue(flag: String)
    case duplicateFlag(flag: String)
    case unknownArgument(String)

    public var errorDescription: String? {
        switch self {
        case .missingValue(let flag):
            return "`\(flag)` requires a value."
        case .duplicateFlag(let flag):
            return "`\(flag)` was provided more than once."
        case .unknownArgument(let argument):
            return "Unknown scan argument: `\(argument)`."
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
            guard ["--project", "--output", "--previous-scan"].contains(argument) else {
                throw ScanArgumentError.unknownArgument(argument)
            }

            guard values[argument] == nil else {
                throw ScanArgumentError.duplicateFlag(flag: argument)
            }

            guard arguments.indices.contains(index + 1), !arguments[index + 1].hasPrefix("--") else {
                throw ScanArgumentError.missingValue(flag: argument)
            }

            values[argument] = arguments[index + 1]
            index += 2
        }

        let outputPath = values["--output"] ?? URL(fileURLWithPath: currentDirectory)
            .appendingPathComponent("habitat-report")
            .path

        return ScanOptions(
            projectPath: values["--project"] ?? currentDirectory,
            outputPath: outputPath,
            previousScanPath: values["--previous-scan"]
        )
    }
}
