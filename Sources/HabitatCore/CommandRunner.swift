import Foundation

public protocol CommandRunning {
    func run(executable: String, arguments: [String], timeout: TimeInterval) -> CommandInfo
}

public struct ProcessCommandRunner: CommandRunning {
    public init() {}

    public func run(executable: String, arguments: [String], timeout: TimeInterval = 3.0) -> CommandInfo {
        let start = Date()
        let process = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        do {
            try process.run()
        } catch {
            return CommandInfo(
                name: executable,
                args: arguments,
                exitCode: nil,
                durationMs: Int(Date().timeIntervalSince(start) * 1000),
                timedOut: false,
                available: false,
                stdout: "",
                stderr: error.localizedDescription
            )
        }

        let timedOut = !wait(process: process, timeout: timeout)
        if timedOut {
            process.terminate()
        }

        let stdout = String(data: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

        return CommandInfo(
            name: executable,
            args: arguments,
            exitCode: timedOut ? nil : process.terminationStatus,
            durationMs: Int(Date().timeIntervalSince(start) * 1000),
            timedOut: timedOut,
            available: true,
            stdout: stdout.trimmingCharacters(in: .whitespacesAndNewlines),
            stderr: stderr.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    private func wait(process: Process, timeout: TimeInterval) -> Bool {
        let group = DispatchGroup()
        group.enter()
        process.terminationHandler = { _ in
            group.leave()
        }
        return group.wait(timeout: .now() + timeout) == .success
    }
}
