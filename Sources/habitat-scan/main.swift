import Foundation
import HabitatCore

struct CLI {
    func run(arguments: [String]) -> Int32 {
        guard arguments.count >= 2 else {
            print(helpText)
            return 0
        }

        switch arguments[1] {
        case "scan":
            return runScan(arguments: Array(arguments.dropFirst(2)))
        case "--help", "-h", "help":
            print(helpText)
            return 0
        case "--version", "-v", "version":
            print("habitat-scan 0.1.0")
            return 0
        default:
            fputs("Unknown command: \(arguments[1])\n\n\(helpText)\n", stderr)
            return 1
        }
    }

    private func runScan(arguments: [String]) -> Int32 {
        let projectPath = argumentValue(flag: "--project", in: arguments) ?? FileManager.default.currentDirectoryPath
        let outputPath = argumentValue(flag: "--output", in: arguments) ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("habitat-report").path
        let previousScanPath = argumentValue(flag: "--previous-scan", in: arguments)

        let scanner = HabitatScanner()
        let writer = ReportWriter()

        do {
            let projectURL = URL(fileURLWithPath: projectPath).standardizedFileURL
            let outputURL = URL(fileURLWithPath: outputPath).standardizedFileURL
            var result = scanner.scan(projectURL: projectURL)
            if let previousScanPath {
                result = result.withChanges(changes(fromPreviousScanAt: previousScanPath, current: result))
            }
            try writer.write(scanResult: result, outputURL: outputURL)
            print("Generated habitat report at \(outputURL.path)")
            return 0
        } catch {
            fputs("Scan failed: \(error.localizedDescription)\n", stderr)
            return 1
        }
    }

    private func argumentValue(flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }

    private var helpText: String {
        """
        habitat-scan 0.1.0

        Usage:
          habitat-scan scan --project /path/to/project --output ./habitat-report
          habitat-scan scan --project /path/to/project --output ./habitat-report --previous-scan ./old/scan_result.json
          habitat-scan --help
          habitat-scan --version
        """
    }

    private func changes(fromPreviousScanAt path: String, current: ScanResult) -> [ScanChange] {
        do {
            let previousURL = URL(fileURLWithPath: path).standardizedFileURL
            let data = try Data(contentsOf: previousURL)
            let previous = try JSONDecoder().decode(ScanResult.self, from: data)
            return ScanComparator().compare(previous: previous, current: current)
        } catch {
            return [
                ScanChange(
                    category: "scan_comparison",
                    summary: "Previous scan could not be read.",
                    impact: "Ignore scan deltas and rely on the current command policy."
                )
            ]
        }
    }
}

exit(CLI().run(arguments: CommandLine.arguments))
