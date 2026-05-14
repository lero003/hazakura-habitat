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
            print("\(HabitatMetadata.cliName) \(HabitatMetadata.generatorVersion)")
            return 0
        default:
            fputs("Unknown command: \(arguments[1])\n\n\(helpText)\n", stderr)
            return 1
        }
    }

    private func runScan(arguments: [String]) -> Int32 {
        if arguments.count == 1, ["--help", "-h", "help"].contains(arguments[0]) {
            print(helpText)
            return 0
        }

        let options: ScanOptions
        do {
            options = try ScanArgumentParser().parse(
                arguments: arguments,
                currentDirectory: FileManager.default.currentDirectoryPath
            )
        } catch {
            fputs("Invalid scan arguments: \(error.localizedDescription)\n\n\(helpText)\n", stderr)
            return 2
        }

        let scanner = HabitatScanner()
        let writer = ReportWriter()

        do {
            let projectURL = URL(fileURLWithPath: options.projectPath).standardizedFileURL
            let outputURL = URL(fileURLWithPath: options.outputPath).standardizedFileURL
            var result = scanner.scan(projectURL: projectURL)
            if let previousScanPath = options.previousScanPath {
                let comparisonCurrent = writer.render(scanResult: result).scanResult
                result = result.withChanges(changes(fromPreviousScanAt: previousScanPath, current: comparisonCurrent))
            }
            if let stdoutArtifact = options.stdoutArtifact {
                let report = writer.render(scanResult: result)
                print(try report.text(for: stdoutArtifact))
                return 0
            }

            try writer.write(scanResult: result, outputURL: outputURL)
            print("Generated habitat report at \(outputURL.path)")
            return 0
        } catch {
            fputs("Scan failed: \(error.localizedDescription)\n", stderr)
            return 1
        }
    }

    private var helpText: String {
        """
        \(HabitatMetadata.cliName) \(HabitatMetadata.generatorVersion)

        Usage:
          habitat-scan scan --project /path/to/project --output ./habitat-report
          habitat-scan scan --project /path/to/project --output ./habitat-report --previous-scan ./old-habitat-report
          habitat-scan scan --project /path/to/project --stdout scan-result
          habitat-scan scan --project /path/to/project --stdout agent-context
          habitat-scan scan --project /path/to/project --stdout command-policy
          habitat-scan scan --project /path/to/project --stdout environment-report
          habitat-scan scan --project /path/to/project --stdout agent_context.md
          habitat-scan scan --project /path/to/project --stdout habitat-report/agent_context.md
          habitat-scan scan --help
          habitat-scan --help
          habitat-scan --version

        Note:
          Use --stdout for one direct artifact, or --output for durable report files; do not combine them.
          --stdout accepts the artifact token, matching generated report filename, ./filename, habitat-report/filename, or an absolute saved-report path.
        """
    }

    private func changes(fromPreviousScanAt path: String, current: ScanResult) -> [ScanChange] {
        do {
            let previousURL = URL(fileURLWithPath: path).standardizedFileURL
            let previous = try PreviousScanLoader().load(from: previousURL)
            return ScanComparator().compare(previous: previous, current: current)
        } catch {
            return [
                ScanChange(
                    category: "scan_comparison",
                    summary: "Previous scan could not be read.",
                    impact: "Pass a scan_result.json file or report directory; rely on the current command policy until comparison succeeds."
                )
            ]
        }
    }
}

exit(CLI().run(arguments: CommandLine.arguments))
