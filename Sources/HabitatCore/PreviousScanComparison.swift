import Foundation

public struct PreviousScanComparison {
    private let loader: PreviousScanLoader
    private let comparator: ScanComparator

    public init(
        loader: PreviousScanLoader = PreviousScanLoader(),
        comparator: ScanComparator = ScanComparator()
    ) {
        self.loader = loader
        self.comparator = comparator
    }

    public func changes(fromPreviousScanAt path: String, current: ScanResult) -> [ScanChange] {
        do {
            let previousURL = URL(fileURLWithPath: path).standardizedFileURL
            let previous = try loader.load(from: previousURL)
            return comparator.compare(previous: previous, current: current)
        } catch {
            return [Self.unreadablePreviousScanChange]
        }
    }

    public static let unreadablePreviousScanChange = ScanChange(
        category: "scan_comparison",
        summary: "Previous scan could not be read.",
        impact: "Pass a scan_result.json file or report directory; rely on the current command policy until comparison succeeds."
    )
}
