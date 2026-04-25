import Foundation

public struct ProjectDetector {
    public init() {}

    private let candidateFiles = [
        "package.json",
        "package-lock.json",
        "pnpm-lock.yaml",
        "yarn.lock",
        "bun.lockb",
        "pyproject.toml",
        "requirements.txt",
        "requirements-dev.txt",
        "uv.lock",
        "Pipfile",
        "Pipfile.lock",
        ".venv",
        "Gemfile",
        "go.mod",
        "Cargo.toml",
        "Package.swift",
        "Package.resolved",
        "Podfile",
        "Cartfile",
        "Brewfile",
        "mise.toml",
        ".tool-versions",
        ".python-version",
        ".node-version",
        ".nvmrc",
        ".env",
        ".env.example",
        "README.md",
    ]

    public func detect(projectURL: URL) -> ProjectInfo {
        let manager = FileManager.default
        let detectedFiles = candidateFiles.filter { manager.fileExists(atPath: projectURL.appendingPathComponent($0).path) }

        return ProjectInfo(
            detectedFiles: detectedFiles,
            packageManager: detectPackageManager(files: detectedFiles),
            runtimeHints: RuntimeHints(
                node: firstAvailableLineIfSafe(
                    projectURL.appendingPathComponent(".nvmrc"),
                    projectURL.appendingPathComponent(".node-version")
                ),
                python: firstLineIfSafe(projectURL.appendingPathComponent(".python-version"))
            )
        )
    }

    private func detectPackageManager(files: [String]) -> String? {
        if files.contains("pnpm-lock.yaml") { return "pnpm" }
        if files.contains("yarn.lock") { return "yarn" }
        if files.contains("bun.lockb") { return "bun" }
        if files.contains("package-lock.json") { return "npm" }
        if files.contains("Package.swift") { return "swiftpm" }
        if files.contains("uv.lock") { return "uv" }
        if files.contains("pyproject.toml")
            || files.contains("requirements.txt")
            || files.contains("requirements-dev.txt")
            || files.contains("Pipfile")
            || files.contains("Pipfile.lock") { return "python" }
        return nil
    }

    private func firstAvailableLineIfSafe(_ urls: URL...) -> String? {
        for url in urls {
            if let line = firstLineIfSafe(url) {
                return line
            }
        }

        return nil
    }

    private func firstLineIfSafe(_ url: URL) -> String? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let lastPath = url.lastPathComponent
        guard lastPath == ".nvmrc" || lastPath == ".node-version" || lastPath == ".python-version" else { return nil }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        return content
            .split(whereSeparator: \.isNewline)
            .first
            .map(String.init)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
