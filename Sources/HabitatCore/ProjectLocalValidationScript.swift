import Foundation

enum ProjectLocalValidationScript {
    static let knownValidationCommands = [
        "./scripts/assemble-debug.sh"
    ]

    static func isCommand(_ command: String) -> Bool {
        command.hasPrefix("./scripts/")
            && !command.contains("..")
            && !command.contains("\0")
    }

    static func isExecutable(command: String, projectPath: String) -> Bool {
        guard isCommand(command) else { return false }

        let scriptPath = URL(fileURLWithPath: projectPath)
            .appendingPathComponent(String(command.dropFirst(2)))
            .path
        return FileManager.default.isExecutableFile(atPath: scriptPath)
    }
}
