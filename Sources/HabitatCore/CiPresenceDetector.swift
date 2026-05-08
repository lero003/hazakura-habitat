import Foundation

public struct CiPresenceDetector {
    public init() {}

    public func detect(projectURL: URL) -> [String] {
        let workflowsDir = projectURL.appendingPathComponent(".github/workflows")
        guard let entries = try? FileManager.default.contentsOfDirectory(atPath: workflowsDir.path) else {
            return []
        }
        return entries
            .filter { $0.hasSuffix(".yml") || $0.hasSuffix(".yaml") }
            .sorted()
            .map { ".github/workflows/\($0)" }
    }
}
