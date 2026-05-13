import Foundation

enum ProjectLocalValidationScript {
    static let knownValidationCommands = [
        "./scripts/assemble-debug.sh"
    ]

    static func validationCommands(in line: String) -> [String] {
        let extracted = scriptCommands(in: line).filter { command in
            command.hasSuffix(".sh")
                && isCommand(command)
                && !isReleaseArtifactScript(command)
        }
        return unique(knownValidationCommands + extracted).filter { command in
            line.contains(command)
        }
    }

    static func isCommand(_ command: String) -> Bool {
        command.hasPrefix("./scripts/")
            && !command.contains("..")
            && !command.contains("\0")
    }

    private static func isReleaseArtifactScript(_ command: String) -> Bool {
        command.contains("release")
            || command.contains("artifact")
            || command.contains("package")
    }

    static func isExecutable(command: String, projectPath: String) -> Bool {
        guard isCommand(command) else { return false }

        let scriptPath = URL(fileURLWithPath: projectPath)
            .appendingPathComponent(String(command.dropFirst(2)))
            .path
        return FileManager.default.isExecutableFile(atPath: scriptPath)
    }

    private static func scriptCommands(in line: String) -> [String] {
        var commands: [String] = []
        var searchStart = line.startIndex

        while let range = line.range(of: "./scripts/", range: searchStart..<line.endIndex) {
            var end = range.upperBound
            while end < line.endIndex, isScriptPathCharacter(line[end]) {
                end = line.index(after: end)
            }

            let command = trimmingTrailingPunctuation(String(line[range.lowerBound..<end]))
            if command.count <= 96 {
                commands.append(command)
            }

            searchStart = end
        }

        return commands
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
}
