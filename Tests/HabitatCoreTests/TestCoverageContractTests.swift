import Foundation
import Testing

struct TestCoverageContractTests {
    @Test
    func swiftTestingScenarioFunctionsStayAnnotated() throws {
        let suiteDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let fileManager = FileManager.default
        let testFiles = try fileManager
            .contentsOfDirectory(at: suiteDirectory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "swift" && $0.lastPathComponent != "TestHelpers.swift" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        var missingAnnotations: [String] = []

        for testFile in testFiles {
            let contents = try String(contentsOf: testFile, encoding: .utf8)
            let lines = contents.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

            for (lineIndex, line) in lines.enumerated() where line.hasPrefix("    func ") {
                let previousSignificantLine = lines[..<lineIndex]
                    .reversed()
                    .first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                    .map { $0.trimmingCharacters(in: .whitespaces) }

                if previousSignificantLine?.hasPrefix("@Test") != true {
                    let lineNumber = lineIndex + 1
                    let functionName = line.trimmingCharacters(in: .whitespaces)
                    missingAnnotations.append("\(testFile.lastPathComponent):\(lineNumber): \(functionName)")
                }
            }
        }

        #expect(
            missingAnnotations == [],
            "Swift Testing scenario functions must be annotated with @Test"
        )
    }
}
