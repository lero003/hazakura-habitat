import Foundation

public struct PreviousScanLoader {
    public static let scanResultFileName = "scan_result.json"

    private let fileManager: FileManager
    private let decoder: JSONDecoder

    public init(fileManager: FileManager = .default, decoder: JSONDecoder = JSONDecoder()) {
        self.fileManager = fileManager
        self.decoder = decoder
    }

    public func load(from inputURL: URL) throws -> ScanResult {
        let resolvedURL = scanResultURL(for: inputURL)
        let data = try Data(contentsOf: resolvedURL)
        return try decoder.decode(ScanResult.self, from: data)
    }

    public func scanResultURL(for inputURL: URL) -> URL {
        let standardizedURL = inputURL.standardizedFileURL
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: standardizedURL.path, isDirectory: &isDirectory)

        if exists && isDirectory.boolValue {
            return standardizedURL.appendingPathComponent(Self.scanResultFileName)
        }

        return standardizedURL
    }
}
