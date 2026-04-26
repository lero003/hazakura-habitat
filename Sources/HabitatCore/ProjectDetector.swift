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
        "Gemfile.lock",
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
        ".env.local",
        ".env.development",
        ".env.development.local",
        ".env.test",
        ".env.test.local",
        ".env.production",
        ".env.production.local",
        ".env.example",
        "README.md",
    ]

    public func detect(projectURL: URL) -> ProjectInfo {
        let manager = FileManager.default
        let detectedFiles = candidateFiles.filter { manager.fileExists(atPath: projectURL.appendingPathComponent($0).path) }
        let packageJSON = packageJSONMetadata(projectURL.appendingPathComponent("package.json"))
        let packageManager = detectPackageManager(files: detectedFiles, declaredPackageManager: packageJSON.declaredPackageManager)

        return ProjectInfo(
            detectedFiles: detectedFiles,
            packageManager: packageManager,
            packageManagerVersion: packageJSON.declaredPackageManager?.name == packageManager ? packageJSON.declaredPackageManager?.version : nil,
            packageScripts: packageJSON.scripts,
            runtimeHints: RuntimeHints(
                node: firstAvailableLineIfSafe(
                    projectURL.appendingPathComponent(".nvmrc"),
                    projectURL.appendingPathComponent(".node-version")
                ),
                python: firstLineIfSafe(projectURL.appendingPathComponent(".python-version"))
            )
        )
    }

    private func detectPackageManager(files: [String], declaredPackageManager: DeclaredPackageManager?) -> String? {
        if files.contains("pnpm-lock.yaml") { return "pnpm" }
        if files.contains("yarn.lock") { return "yarn" }
        if files.contains("bun.lockb") { return "bun" }
        if files.contains("package-lock.json") { return "npm" }
        if files.contains("package.json"), let declaredPackageManager {
            return declaredPackageManager.name
        }
        if files.contains("package.json") { return "npm" }
        if files.contains("Package.swift") { return "swiftpm" }
        if files.contains("go.mod") { return "go" }
        if files.contains("Cargo.toml") { return "cargo" }
        if files.contains("Brewfile") { return "homebrew" }
        if files.contains("uv.lock") { return "uv" }
        if files.contains("pyproject.toml")
            || files.contains("requirements.txt")
            || files.contains("requirements-dev.txt")
            || files.contains("Pipfile")
            || files.contains("Pipfile.lock") { return "python" }
        if files.contains("Gemfile") || files.contains("Gemfile.lock") { return "bundler" }
        return nil
    }

    private func packageJSONMetadata(_ url: URL) -> PackageJSONMetadata {
        guard FileManager.default.fileExists(atPath: url.path) else { return .empty }
        guard fileSize(at: url) <= 512 * 1024 else { return .empty }
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return .empty
        }

        let declaredPackageManager = (json["packageManager"] as? String)
            .flatMap(declaredPackageManager(from:))
        let scripts = (json["scripts"] as? [String: Any])?
            .compactMap { key, value in value is String ? key : nil }
            .sorted() ?? []

        return PackageJSONMetadata(declaredPackageManager: declaredPackageManager, scripts: scripts)
    }

    private func declaredPackageManager(from rawPackageManager: String) -> DeclaredPackageManager? {
        let value = rawPackageManager.trimmingCharacters(in: .whitespacesAndNewlines)
        for packageManager in ["pnpm", "yarn", "bun", "npm"] {
            if value == packageManager {
                return DeclaredPackageManager(name: packageManager, version: nil)
            }

            if value.hasPrefix("\(packageManager)@") {
                let version = String(value.dropFirst(packageManager.count + 1))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard !version.isEmpty else { return nil }
                return DeclaredPackageManager(name: packageManager, version: version)
            }
        }

        return nil
    }

    private func fileSize(at url: URL) -> UInt64 {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return (attributes?[.size] as? NSNumber)?.uint64Value ?? UInt64.max
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

private struct DeclaredPackageManager {
    let name: String
    let version: String?
}

private struct PackageJSONMetadata {
    static let empty = PackageJSONMetadata(declaredPackageManager: nil, scripts: [])

    let declaredPackageManager: DeclaredPackageManager?
    let scripts: [String]
}
