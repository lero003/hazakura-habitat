import Foundation

enum ProjectLocalValidationScript {
    static let knownValidationCommands = [
        "./scripts/assemble-debug.sh",
        "./script/build_and_run.sh --verify"
    ]

    private static let scriptCommandPrefixes = [
        "./scripts/",
        "./script/"
    ]

    static func validationCommands(in line: String) -> [String] {
        let knownCommandsInLine = knownValidationCommands.filter { line.contains($0) }
        let extracted = scriptCommands(in: line).filter { command in
            command.hasSuffix(".sh")
                && isCommand(command)
                && !isReleaseArtifactScript(command)
                && !knownCommandsInLine.contains { known in
                    known.hasPrefix(command + " ")
                }
        }
        return unique(knownCommandsInLine + extracted).filter { command in
            line.contains(command)
        }
    }

    static func releaseArtifactCommands(in line: String) -> [String] {
        let extracted = scriptCommands(in: line).filter { command in
            command.hasSuffix(".sh")
                && isCommand(command)
                && isReleaseArtifactScript(command)
        }
        return unique(extracted).filter { command in
            line.contains(command)
        }
    }

    static func isCommand(_ command: String) -> Bool {
        guard let executable = executableToken(command) else { return false }
        return scriptCommandPrefixes.contains { executable.hasPrefix($0) }
            && executable.hasSuffix(".sh")
            && !executable.contains("..")
            && !executable.contains("\0")
    }

    static func isReleaseArtifactCommand(_ command: String) -> Bool {
        command.contains("release")
            || command.contains("artifact")
            || command.contains("package")
    }

    static func isDeviceVerificationCommand(_ command: String) -> Bool {
        command == "./scripts/device-test.sh"
    }

    static func isEnvironmentCheckCommand(_ command: String) -> Bool {
        command == "./scripts/dev-env-check.sh"
    }

    static func isLaunchSmokeCommand(_ command: String) -> Bool {
        command == "./script/build_and_run.sh --verify"
    }

    private static func isReleaseArtifactScript(_ command: String) -> Bool {
        isReleaseArtifactCommand(command)
    }

    static func isExecutable(command: String, projectPath: String) -> Bool {
        guard isCommand(command),
              let executable = executableToken(command)
        else { return false }

        let scriptPath = URL(fileURLWithPath: projectPath)
            .appendingPathComponent(String(executable.dropFirst(2)))
            .path
        return FileManager.default.isExecutableFile(atPath: scriptPath)
    }

    private static func scriptCommands(in line: String) -> [String] {
        var searchStart = line.startIndex

        var matches: [(index: String.Index, command: String)] = []

        for prefix in scriptCommandPrefixes {
            searchStart = line.startIndex
            while let range = line.range(of: prefix, range: searchStart..<line.endIndex) {
                var end = range.upperBound
                while end < line.endIndex, isScriptPathCharacter(line[end]) {
                    end = line.index(after: end)
                }

                let command = trimmingTrailingPunctuation(String(line[range.lowerBound..<end]))
                if command.count <= 96 {
                    matches.append((range.lowerBound, command))
                }

                searchStart = end
            }
        }

        return matches.sorted { $0.index < $1.index }.map(\.command)
    }

    private static func isScriptPathCharacter(_ character: Character) -> Bool {
        character.isASCII
            && (character.isLetter
                || character.isNumber
                || character == "/"
                || character == "."
                || character == "_"
                || character == "-")
    }

    private static func trimmingTrailingPunctuation(_ command: String) -> String {
        var result = command
        while let last = result.last,
              [".", ",", ";", ":", ")", "`", "]", "}", "'", "\""].contains(last) {
            result.removeLast()
        }
        return result
    }

    private static func unique(_ commands: [String]) -> [String] {
        commands.reduce(into: [String]()) { result, command in
            if !result.contains(command) {
                result.append(command)
            }
        }
    }

    private static func executableToken(_ command: String) -> String? {
        command.split(whereSeparator: \.isWhitespace).first.map(String.init)
    }
}
