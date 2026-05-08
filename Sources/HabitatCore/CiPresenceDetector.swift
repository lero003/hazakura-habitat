import Foundation

public struct CiPresenceDetector {
    public init() {}

    public func detect(projectURL: URL) -> [String] {
        let workflowsDir = projectURL.appendingPathComponent(".github/workflows")
        guard !isSymbolicLink(workflowsDir) else {
            return []
        }
        guard let entries = try? FileManager.default.contentsOfDirectory(atPath: workflowsDir.path) else {
            return []
        }
        return entries
            .filter { entry in
                let entryURL = workflowsDir.appendingPathComponent(entry)
                return isWorkflowFilename(entry)
                    && !isSymbolicLink(entryURL)
                    && isRegularFile(entryURL)
            }
            .sorted()
            .map { ".github/workflows/\($0)" }
    }

    private func isWorkflowFilename(_ entry: String) -> Bool {
        entry.hasSuffix(".yml") || entry.hasSuffix(".yaml")
    }

    private func isSymbolicLink(_ url: URL) -> Bool {
        (try? FileManager.default.destinationOfSymbolicLink(atPath: url.path)) != nil
    }

    private func isRegularFile(_ url: URL) -> Bool {
        ((try? url.resourceValues(forKeys: [.isRegularFileKey]))?.isRegularFile) == true
    }
}
